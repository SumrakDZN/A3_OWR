// only executed on server!
if (!(isServer)) exitWith {};

_b_state = 0;						// initial state of fsm
_hasWeapon = false;					// internal flag
_ammoRemove = false;
_ammoAdded = true;
_powerRemove = false;
_powerAdded = true;
_weaponClass = -1;

_vehicleMagazineType = "";

// get the object from world
_turret = _this select 0;
_assignedWarehouse = _this select 1;
_curatorToUse = _this select 2;
_fnATurretClass = "";
_factoryClassToSearch = "";
switch (_curatorToUse) do {
	case bis_curator_west: {
		_factoryClassToSearch = "factory_am";
		_fnATurretClass = owr_fn_getAMATurretClass;
	};
	case bis_curator_east: {
		_factoryClassToSearch = "factory_ru";
		_fnATurretClass = owr_fn_getRUATurretClass;
	};
	/*case bis_curator_arab: {
		_factoryClassToSearch = "factory_ar";
		_fnATurretClass = owr_fn_getARATurretClass;
	};*/
};
_bComplx = getNumber (configFile >> "CfgVehicles" >> (typeOf _turret) >> "mComplx");
[_turret, [false, false]] remoteExec ["setUnloadInCombat", owner _turret];

_turret setVariable ["ow_wip_progress", 0.0, true];
_turret setVariable ["ow_build_ready", false, true];
_turret setVariable ["ow_build_upgrade", false, true];
_turret setVariable ["ow_build_wrhs", _assignedWarehouse, true];
_turret setVariable ["ow_build_pause", false, true];
_turret setVariable ["ow_turret_power_req", 0.0, true];
_turret setVariable ["ow_turret_buildmode", 0, true];
_turret setVariable ["ow_turret_fac", objNull, true];
_turret setVariable ["ow_turret_usecustomfac", false, true];
_turret setVariable ["ow_turret_weaponassign", false, true];
_turret setVariable ["ow_turret_weapon", _turret, true];
_turret setVariable ["ow_build_deconstruct", false, true];
_turret setVariable ["ow_build_destroyed", false, true];

while {!(isNull _turret)} do {
	switch (_b_state) do {
		case 0: {
			_wip_progress = _turret getVariable "ow_wip_progress";
			_workers = nearestObjects [_turret, ["owr_manbase"], 15];
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
			_turret setVariable ["ow_wip_progress", _wip_progress, true];	
			if (_wip_progress >= 1.0) then {
				_b_state = 1;
				_turret setVariable ["ow_wip_progress", 1.0, true];
				_turret setVariable ["ow_build_ready", true, true];

				// message
				//[(_workers select 0), "Building finished", "Automatic turret", mapGridPosition (getPos _turret)] spawn owr_fn_message;
				[(_workers select 0), "Building finished", "Automatic turret", mapGridPosition (getPos _turret)] remoteExec ["owr_fn_message", _curatorToUse];
			};

			// damage
			if ((damage (_turret getVariable "ow_turret_weapon")) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 1: {
			// working state
			if (!_hasWeapon) then {
				// responsible factory
				_factoryChosen = false;
				if (!(isNull (_turret getVariable "ow_build_wrhs"))) then {
					if (_turret getVariable "ow_turret_usecustomfac") then {
						_selectedFac = _turret getVariable "ow_turret_fac";
						_factoryChosen = true;
						if ((_selectedFac getVariable "ow_build_wrhs") != (_turret getVariable "ow_build_wrhs")) then {
							_turret setVariable ["ow_turret_usecustomfac", false, true];
							_turret setVariable ["ow_turret_fac", objNull, true];
							_factoryChosen = false;
						};
					} else {
						_factories = nearestObjects [(_turret getVariable "ow_build_wrhs"), [_factoryClassToSearch], 150];
						if ((count _factories) > 0) then {
							_turret setVariable ["ow_turret_fac", _factories select 0, true];
							_factoryChosen = true;
						};
					};
				};

				// factory is assigned
				if (_factoryChosen) then {
					if (_turret getVariable "ow_turret_weaponassign") then {
						// weapon chosen, manufacturing task started
						// switch state
						_b_state = 3;
					};
				};
			} else {
				if (isNull (_turret getVariable "ow_build_wrhs")) then {
					// no warehouse, remove ammo
					if (_ammoAdded) then {
						_ammoRemove = true;
					};
					_powerAdded = false;
				} else {
					// warehouse present, is turret supposed to be turned on?
					if (!(_turret getVariable "ow_build_pause")) then {
						// yes, check if it is necessary to re-add power req to warehouse
						if (!_powerAdded) then {
							// yes it is necessary
							_powerAdded = true;
							_warehousePowerLevel = ((_turret getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req");
							// assign new value of available power with updated power gain from this particular building
							(_turret getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_req", (_warehousePowerLevel + (_turret getVariable "ow_turret_power_req")), true];
						};
						// check for available power
						if (((_turret getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_avl") >= ((_turret getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req")) then {
							// normal state
							_ammoRemove = false;
							_powerRemove = false;
							if (!_ammoAdded) then {
								_ammoAdded = true;
								_ammoCnt = (getNumber (configFile >> "CfgMagazines" >> _vehicleMagazineType >> "count"));
								(_turret getVariable "ow_turret_weapon") addMagazineTurret [_vehicleMagazineType, [0], _ammoCnt];
							};
						} else {
							// not enough power, remove ammo
							if (_ammoAdded) then {
								_ammoRemove = true;
							};
							_powerRemove = false;
						};
					} else {
						// no, remove power req and ammo
						if (_ammoAdded) then {
							_ammoRemove = true;
						}; 
						if (_powerAdded) then {
							_powerRemove = true;
						};
					};
				};

				// actual ammo remove action, one-time only
				if (_ammoRemove) then {
					_ammoRemove = false;
					(_turret getVariable "ow_turret_weapon") removeMagazinesTurret [_vehicleMagazineType, [0]];
					_ammoAdded = false;
				};
				// actual power req remove action, one-time only
				if (_powerRemove) then {
					_powerRemove = false;
					// get current req power level at warehouse
					_warehousePowerLevel = ((_turret getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req");
					// assign new value of available power with updated power gain from this particular building
					(_turret getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_req", (_warehousePowerLevel - (_turret getVariable "ow_turret_power_req")), true];
					_powerAdded = false;
				};
			};

			if (_turret getVariable "ow_build_deconstruct") then {
				{
					moveOut _x;
				} forEach (crew _turret);
				_turret lockCargo true;

				_turret setVariable ["ow_wip_progress", 1.001, true];

				_b_state = 4;
			};

			// damage
			if ((damage (_turret getVariable "ow_turret_weapon")) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 2: {
			// damaged state
			// remove power req (if warehouse is connected and turret is not in pause mode)
			if ((!(isNull (_turret getVariable "ow_build_wrhs"))) && (!(_turret getVariable "ow_build_pause"))) then {
				_warehousePowerLevel = ((_turret getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req");
				(_turret getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_req", (_warehousePowerLevel - (_turret getVariable "ow_turret_power_req")), true];
			};

			_turret setVariable ["ow_build_destroyed", true, true];

			if (_turret getVariable "ow_build_deconstruct") then {
				if (_turret != (_turret getVariable "ow_turret_weapon")) then {
					deleteVehicle _turret;
					deleteVehicle (_turret getVariable "ow_turret_weapon");
				} else {
					deleteVehicle _turret;
				};
			};

			_b_state = -1;
		};

		case 3: {
			// upgrade state
			_fac = _turret getVariable "ow_turret_fac";
			if (!(isNull(_fac))) then {
				if (((_fac getVariable "ow_wip_progress") > 0) && ((_fac getVariable "ow_wip_progress") < 1)) then {
					// turret waits
					_weaponClass = _fac getVariable "ow_factory_wtemplate";
				} else {
					// weapon done (factory task finished)
					// create actual class of the weapon turret on the exact position of this turret base
					//_weapon = ([_weaponClass] call _fnATurretClass) createVehicle (getPos _turret);
					_turretSide = west;
					switch (_curatorToUse) do {
						case bis_curator_west: {
							_turretSide = west;
						};
						case bis_curator_east: {
							_turretSide = east;
						};
						/*case bis_curator_arab: {
							_turretSide = resistance;
						};*/
					};
					_farray = [(getPos _turret), 0, ([_weaponClass] call _fnATurretClass), _turretSide] call bis_fnc_spawnvehicle;
					_weapon = _farray select 0;
					//_weapon = ([_weaponClass] call _fnATurretClass) createVehicle (getPos _turret);
					_weapon selectWeaponTurret [((_weapon weaponsTurret [0]) select 0), [0]];
					_vehicleMagazineType = _weapon currentMagazineTurret [0];
					_weapon setPos (getPos _turret);
					_turret setVariable ["ow_turret_weapon", _weapon, true];
					_b_state = 1;
					_hasWeapon = true;
					_turret setVariable ["ow_turret_power_req", 20.0, true];

					switch (_curatorToUse) do {
						case bis_curator_west: {
							_weapon addEventHandler ["HandleDamage", {
								_victim = (_this select 0);
								_revDamage = (_this select 2) - (damage _victim);
								_damageDivisor = 12;
								_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
								_newDamage
							}];
						};
						case bis_curator_east: {
							_weapon addEventHandler ["HandleDamage", {
								_victim = (_this select 0);
								_revDamage = (_this select 2) - (damage _victim);
								_damageDivisor = 3.6;
								_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
								_newDamage
							}];
						};
						/*case bis_curator_arab: {
							_weapon addEventHandler ["HandleDamage", {
								_victim = (_this select 0);
								_revDamage = (_this select 2) - (damage _victim);
								_damageDivisor = 1.0;
								_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
								_newDamage
							}];
						};*/
					};

					// add power req to warehouse (if exists)
					if (!(isNull (_turret getVariable "ow_build_wrhs"))) then {
						_warehousePowerLevel = ((_turret getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req");
						(_turret getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_req", (_warehousePowerLevel + (_turret getVariable "ow_turret_power_req")), true];
					};

					// add ai gunner
					//createVehicleCrew _weapon;
					/*_gunner = (group guy_from_west) createUnit ["B_UAV_AI", getPos _weapon, [], 0, "FORM"];
					[_gunner] join grpNull;*/
					// set skill based on CPU research
					if (["comp", 0, _curatorToUse] call owr_fn_isResearchComplete) then {
						if ((["comp", 1, _curatorToUse] call owr_fn_isResearchComplete)) then {
							if ((["comp", 2, _curatorToUse] call owr_fn_isResearchComplete)) then {
								[((crew _weapon) select 0), 1.00] remoteExec ["setSkill", owner _weapon];
								[((crew _weapon) select 0), "COMBAT"] remoteExec ["setBehaviour", owner _weapon];	// not working uav units seems to be in careless constantly
							} else {
								[((crew _weapon) select 0), 0.85] remoteExec ["setSkill", owner _weapon];
								[((crew _weapon) select 0), "COMBAT"] remoteExec ["setBehaviour", owner _weapon];
							};
						} else {
							[((crew _weapon) select 0), 0.75] remoteExec ["setSkill", owner _weapon];
							[((crew _weapon) select 0), "COMBAT"] remoteExec ["setBehaviour", owner _weapon];
						};
					} else {
						// no cpu research at all - ai dumb
						[((crew _weapon) select 0), 0.60] remoteExec ["setSkill", owner _weapon];
						[((crew _weapon) select 0), "COMBAT"] remoteExec ["setBehaviour", owner _weapon];
					};
					// move him into vehicle (not used atm)
					//_gunner moveInGunner _weapon;
				};
			} else {
				_b_state = 1;
			};

			// damage
			if ((damage (_turret getVariable "ow_turret_weapon")) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 4: {
			/*
				deconstruction state
			*/
			_wip_progress = _turret getVariable "ow_wip_progress";
			_workers = nearestObjects [_turret, ["owr_manbase"], 15];
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
			_turret setVariable ["ow_wip_progress", _wip_progress, true];

			if ((_turret getVariable "ow_wip_progress") <= 0.0) then {
				// destroy entity
				_b_state = 2;

				// add resources from deconstruction
				if (!(isNull (_turret getVariable "ow_build_wrhs"))) then {
					// add some resources back if assigned warehouse exists
					_resourceArray = [_turret] call owr_fn_getBuildingCost;

					if ((_resourceArray select 0) != 0) then {
						// add crates
						_storedResource = (_turret getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates";
						(_turret getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", _storedResource + (_resourceArray select 0), true];
					};
					if ((_resourceArray select 1) != 0) then {
						// add oil
						_storedResource = (_turret getVariable "ow_build_wrhs") getVariable "ow_wrhs_oil";
						(_turret getVariable "ow_build_wrhs") setVariable ["ow_wrhs_oil", _storedResource + (_resourceArray select 1), true];
					};
					if ((_resourceArray select 2) != 0) then {
						// add siberite
						_storedResource = (_turret getVariable "ow_build_wrhs") getVariable "ow_wrhs_siberite";
						(_turret getVariable "ow_build_wrhs") setVariable ["ow_wrhs_siberite", _storedResource + (_resourceArray select 2), true];
					};
				};
			};
		};


		default {
		};
	};

	sleep 0.1;
};