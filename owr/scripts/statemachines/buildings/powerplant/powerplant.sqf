_powerPlant = _this select 0;
_powerType = _this select 1;
_assignedWarehouse = _this select 2;
_curatorToUse = _this select 3;

switch (typeOf _powerPlant) do {
	case "power_sol_am": {	
		_powerPlant addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 20;
			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	};
	case "power_sol_ar": {};

	case "power_sib_am": {	
		_powerPlant addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 12;
			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	};
	case "power_sib_ru": {	
		_powerPlant addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 14;
			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	};
	case "power_sib_ar": {};

	case "power_oil_am": {	
		_powerPlant addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 16;
			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	};
	case "power_oil_ru": {	
		_powerPlant addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 16;
			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	};
	case "power_oil_ar": {};
};

// only executed on server!
if (!(isServer)) exitWith {};

_b_state = 0;						// initial state of fsm
_powerConnected = false;
_powerGain = 15.0;
_powerGainMod = 1.00;
_lastPowerGain = 0.0;
_powerResTick = random [85, 95, 100];
_tickNo = 0;
_researchCatToCheck = "basic";
_oilDrainTick = 0.0;
_oilTickNo = 0;
_oilNoResource = false;
_stopPowerSupply = false;
_bComplx = getNumber (configFile >> "CfgVehicles" >> (typeOf _powerPlant) >> "mComplx");

_powerPlant setVariable ["ow_wip_progress", 0.0, true];
_powerPlant setVariable ["ow_build_ready", false, true];
_powerPlant setVariable ["ow_build_pause", false, true];
_powerPlant setVariable ["ow_powerplant_refresh", false, true];
_powerPlant setVariable ["ow_build_wrhs", _assignedWarehouse, true];
_powerPlant setVariable ["ow_build_deconstruct", false, true];
_powerPlant setVariable ["ow_build_destroyed", false, true];

_powerPlant lock true;

if ((_powerType == "solar") || (_powerType == "oil")) then {
	_researchCatToCheck = "basic";
	_powerGainMod = 1.5;
	_wip_prog_base = 0.0007;
	if (_powerType == "oil") then {
		_wip_prog_base = 0.0009;
		_powerGainMod = 1.1;
		_oilDrainTick = random [154,175,200];
	};
} else {
	if (_powerType == "siberite") then {
		_researchCatToCheck = "siberite";
		_powerGainMod = 1.50;
		_wip_prog_base = 0.0005;
	} else {
		// neco spatne
	};
};

while {!(isNull _powerPlant)} do {
	switch (_b_state) do {
		case 0: {
			_wip_progress = _powerPlant getVariable "ow_wip_progress";
			_workers = nearestObjects [_powerPlant, ["owr_manbase"], 15];
			{
				if (alive _x) then {
					_x_skill = (_x getVariable "ow_skill_worker");
					if ((_x getVariable "ow_class") == 1) then {
						// owr worker, contributes fully - higher skill = better
						_wip_progress = _wip_progress + ([_bComplx, _x_skill] call owr_fn_makeBuildProgress);
						// increase worker skill of _x if not maxed out
						if (_x_skill < 10.0) then {
							_x setVariable ["ow_skill_worker", _x_skill + ([_bComplx, _x_skill] call owr_fn_makeExpProgress), true];
						};
					} else {
						// just normal owr man, still useful to have some worker skills though (but only contributes third)
						_wip_progress = _wip_progress + ([(_bComplx * 3.0), _x_skill] call owr_fn_makeBuildProgress);
						// increase worker skill of _x
						if (_x_skill < 10.0) then {
							_x setVariable ["ow_skill_worker", _x_skill + ([(_bComplx / 3.0), _x_skill] call owr_fn_makeExpProgress), true];
						};
					};
				};
			} forEach _workers;
			_powerPlant setVariable ["ow_wip_progress", _wip_progress, true];	
			if (_wip_progress >= 1.0) then {
				_b_state = 1;
				_powerPlant setVariable ["ow_wip_progress", 1.0, true];
				_powerPlant setVariable ["ow_build_ready", true, true];

				// message
				_stringPowerType = "";
				switch (_powerType) do {
					case "oil": {
						_stringPowerType = "Diesel power plant";
					};
					case "solar": {
						_stringPowerType = "Solar power plant";
					};
					case "siberite": {
						switch (_curatorToUse) do {
							case bis_curator_west: {
								_stringPowerType = "Siberite power plant";
							};
							case bis_curator_east: {
								_stringPowerType = "Alaskite power plant";
							};
						};
					};
					default {};
				};

				//[(_workers select 0), "Building finished", _stringPowerType, mapGridPosition (getPos _powerPlant)] spawn owr_fn_message;
				[(_workers select 0), "Building finished", _stringPowerType, mapGridPosition (getPos _powerPlant)] remoteExec ["owr_fn_message", _curatorToUse];
			};

			// damage check
			if ((damage _powerPlant) >= 0.95) then {
				_b_state = 2;
			};
		};
		case 1: {
			// ready state
			/*
			// used for debug
			if (!_stopPowerSupply) then {
				_powerPlant setDir _tickNo;
			};
			*/


			if (isNull (_powerPlant getVariable "ow_build_wrhs")) then {
				// warehouse is disconnected
				// set powerGain to zero
				_powerGain = 0;
				_lastPowerGain = 0;
			} else {
				// keep an eye on research status - if it can provide more power
				if (_tickNo >= _powerResTick) then {
					_tickNo = 0;
					_powerResTick = random [85, 95, 100];
					if ([_researchCatToCheck, 0, _curatorToUse] call owr_fn_isResearchComplete) then {
						if ([_researchCatToCheck, 1, _curatorToUse] call owr_fn_isResearchComplete) then {
							if ([_researchCatToCheck, 2, _curatorToUse] call owr_fn_isResearchComplete) then {
								_powerGain = 20.0 * _powerGainMod;
							} else {
								_powerGain = 15.0 * _powerGainMod;
							};
						} else {
							_powerGain = 12.5 * _powerGainMod;
						};
					} else {
						_powerGain = 10.0 * _powerGainMod;
					};

					if ((_lastPowerGain != _powerGain) || _stopPowerSupply || (_powerPlant getVariable "ow_powerplant_refresh")) then {
						_powerPlant setVariable ["ow_powerplant_refresh", false, true];

						if (_stopPowerSupply) then {
							_powerGain = 0;
						};

						// warehouse power connection
						if (!(isNull (_powerPlant getVariable "ow_build_wrhs"))) then {
							// get current power level at warehouse and substract last gain from this particular plant
							_prevPowerAvl = ((_powerPlant getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_avl") - _lastPowerGain;
							// assign new value of available power with updated power gain from this particular plant
							(_powerPlant getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_avl", (_prevPowerAvl + _powerGain), true];
							_lastPowerGain = _powerGain;
						};
					};
				};

				if (_powerPlant getVariable "ow_build_pause") then {
					_stopPowerSupply = true;
				} else {
					if (_oilNoResource) then {
						_stopPowerSupply = true;
					} else {
						_stopPowerSupply = false;
					};
				};

				// ONLY FOR diesel power plants
				// oil consumption from warehouse 
				if (_powerType == "oil") then {
					if (!(_powerPlant getVariable "ow_build_pause")) then {
						if (_oilTickNo >= _oilDrainTick) then {
							_oilTickNo = 0;
							_oilStorage = 0;
							if (!(isNull (_powerPlant getVariable "ow_build_wrhs"))) then {
								_oilStorage = (_powerPlant getVariable "ow_build_wrhs") getVariable "ow_wrhs_oil";
							};
							if ((_oilStorage) > 0) then {
								_stopPowerSupply = false;
								_oilNoResource = false;
								(_powerPlant getVariable "ow_build_wrhs") setVariable ["ow_wrhs_oil", (_oilStorage - 1), true];
							} else {
								// no resource, stop power supply
								_stopPowerSupply = true;
								_oilNoResource = true;
							};
						};
					};
				} else {
					if (_powerType == "solar") then {
						// solar plants cannot generate electricity over night
						if (sunOrMoon <= 0.1) then {
							_stopPowerSupply = true;
						};
					};
				};
			};

			// deconstruct check
			if (_powerPlant getVariable "ow_build_deconstruct") then {
				_powerPlant setVariable ["ow_wip_progress", 1.001, true];
				_b_state = 3;
			};

			// damage check
			if ((damage _powerPlant) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 2: {
			// damaged state
			// warehouse power disconnect
			if (!(isNull (_powerPlant getVariable "ow_build_wrhs"))) then {
				// get current power level at warehouse
				_prevPowerAvl = ((_powerPlant getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_avl");
				// substract with power gain from this particular plant
				(_powerPlant getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_avl", (_prevPowerAvl - _powerGain), true];
			};
			_powerPlant setVariable ["ow_build_destroyed", true, true];
			
			// entity removal
			if (_powerPlant getVariable "ow_build_deconstruct") then {
				deleteVehicle _powerPlant;
			};

			_b_state = -1;	// non existing state to prevent further ticking
		};

		case 3: {
			_wip_progress = _powerPlant getVariable "ow_wip_progress";
			_workers = nearestObjects [_powerPlant, ["owr_manbase"], 15];
			{
				_x_skill = (_x getVariable "ow_skill_worker");
				if (alive _x) then {
					if ((_x getVariable "ow_class") == 1) then {
						// owr worker, contributes fully - higher skill = better
						_wip_progress = _wip_progress - ([(_bComplx * 0.75), _x_skill] call owr_fn_makeBuildProgress);
						// increase worker skill of _x if not maxed out
						if (_x_skill < 10.0) then {
							_x setVariable ["ow_skill_worker", _x_skill + ([(_bComplx * 0.75), _x_skill] call owr_fn_makeExpProgress), true];
						};
					};
				};
			} forEach _workers;
			_powerPlant setVariable ["ow_wip_progress", _wip_progress, true];

			if ((_powerPlant getVariable "ow_wip_progress") <= 0.0) then {
				// destroy entity
				_b_state = 2;

				// add resources from deconstruction
				if (!(isNull (_powerPlant getVariable "ow_build_wrhs"))) then {
					// add some resources back if assigned warehouse exists
					_resourceArray = [_powerPlant] call owr_fn_getBuildingCost;

					if ((_resourceArray select 0) != 0) then {
						// add crates
						_storedResource = (_powerPlant getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates";
						(_powerPlant getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", _storedResource + (_resourceArray select 0), true];
					};
					if ((_resourceArray select 1) != 0) then {
						// add oil
						_storedResource = (_powerPlant getVariable "ow_build_wrhs") getVariable "ow_wrhs_oil";
						(_powerPlant getVariable "ow_build_wrhs") setVariable ["ow_wrhs_oil", _storedResource + (_resourceArray select 1), true];
					};
					if ((_resourceArray select 2) != 0) then {
						// add siberite
						_storedResource = (_powerPlant getVariable "ow_build_wrhs") getVariable "ow_wrhs_siberite";
						(_powerPlant getVariable "ow_build_wrhs") setVariable ["ow_wrhs_siberite", _storedResource + (_resourceArray select 2), true];
					};
				};
			};
		};

		default {
		};
	};

	//hintSilent format ["type:%1\n\ntick:%2\noilTick:%3\nbState:%4\nbuild_pause:%5\nstopPowerSupply:%6\npowerGain:%7\nsunOrMoon:%8", _powerType, _tickNo, _oilTickNo, _b_state, (_powerPlant getVariable "ow_build_pause"),_stopPowerSupply,_powerGain,sunOrMoon];

	_tickNo = _tickNo + 1;
	if (_powerType == "oil") then {
		_oilTickNo = _oilTickNo + 1;
	};
	sleep 0.1;
};