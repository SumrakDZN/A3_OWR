_resMine = _this select 0;
_resType = _this select 1;
_assignedWarehouse = _this select 2;
_curatorToCheck = _this select 3;

switch (typeOf _resMine) do {
	case "source_sib_am": {
		_resMine addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 6;
			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	};
	case "source_sib_ar": {};
	case "source_sib_ru": {
		_resMine addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 6.4;
			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	};
	case "source_oil_am": {
		_resMine addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 6.4;
			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	};
	case "source_oil_ar": {};
	case "source_oil_ru": {
		_resMine addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 7.2;
			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	};
};

// only executed on server!
if (!(isServer)) exitWith {};

_b_state = 0;						// initial state of fsm
_bComplx = getNumber (configFile >> "CfgVehicles" >> (typeOf _resMine) >> "mComplx");
_tickNo = 0;
_baseTick = 85;
_miningTick = _baseTick;
_resMine setVariable ["ow_resourcemine_level", 0, true];
switch (_resType) do {
	case "ow_wrhs_siberite": {
		_wip_prog_base = 0.0005;
		if (["siberite", 0, _curatorToCheck] call owr_fn_isResearchComplete) then {
			if (["siberite", 1, _curatorToCheck] call owr_fn_isResearchComplete) then {
				if (["siberite", 2, _curatorToCheck] call owr_fn_isResearchComplete) then {
					_baseTick = 55;
					_resMine setVariable ["ow_resourcemine_level", 3, true];
				} else {
					_baseTick = 65;
					_resMine setVariable ["ow_resourcemine_level", 2, true];
				};
			} else {
				_baseTick = 75;
				_resMine setVariable ["ow_resourcemine_level", 1, true];
			};
		};
		_miningTick = (_baseTick * 2) + random [7, 10, 15];		// siberite tick is slower
	};
	case "ow_wrhs_oil": {
		_wip_prog_base = 0.001;
		if (["basic", 0, _curatorToCheck] call owr_fn_isResearchComplete) then {
			if (["basic", 1, _curatorToCheck] call owr_fn_isResearchComplete) then {
				if (["basic", 2, _curatorToCheck] call owr_fn_isResearchComplete) then {
					_baseTick = 55;
					_resMine setVariable ["ow_resourcemine_level", 3, true];
				} else {
					_baseTick = 65;
					_resMine setVariable ["ow_resourcemine_level", 2, true];
				};
			} else {
				_baseTick = 75;
				_resMine setVariable ["ow_resourcemine_level", 1, true];
			};
		};
		_miningTick = _baseTick + random [7, 10, 15]; 				// default tick for oil
	};
};

_resMine setVariable ["ow_wip_progress", 0.0, true];
_resMine setVariable ["ow_build_ready", false, true];
_resMine setVariable ["ow_resourcemine_refresh", false, true];
_resMine setVariable ["ow_build_wrhs", _assignedWarehouse, true];
_resMine setVariable ["ow_build_deconstruct", false, true];
_resMine setVariable ["ow_build_destroyed", false, true];

_resMine lock true;


while {!(isNull _resMine)} do {
	switch (_b_state) do {
		case 0: {
			_wip_progress = _resMine getVariable "ow_wip_progress";
			_workers = nearestObjects [_resMine, ["owr_manbase"], 15];
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
			_resMine setVariable ["ow_wip_progress", _wip_progress, true];	
			if (_wip_progress >= 1.0) then {
				_b_state = 1;
				_resMine setVariable ["ow_wip_progress", 1.0, true];
				_resMine setVariable ["ow_build_ready", true, true];
				
				if (!(isNull (_resMine getVariable "ow_build_wrhs"))) then {
					switch (typeof (_resMine getVariable "ow_build_wrhs")) do {
						case "warehouse_ru": {
							switch (_resType) do {
								case "ow_wrhs_siberite": {
									[(_workers select 0), "Building finished", "Siberite mine", mapGridPosition (getPos _resMine)] remoteExec ["owr_fn_message", bis_curator_east];
								};
								case "ow_wrhs_oil": {
									[(_workers select 0), "Building finished", "Oil drilling rig", mapGridPosition (getPos _resMine)] remoteExec ["owr_fn_message", bis_curator_east];
								};
							};
						};
						case "warehouse_am": {
							switch (_resType) do {
								case "ow_wrhs_siberite": {
									[(_workers select 0), "Building finished", "Siberite mine", mapGridPosition (getPos _resMine)] remoteExec ["owr_fn_message", bis_curator_west];
								};
								case "ow_wrhs_oil": {
									[(_workers select 0), "Building finished", "Oil drilling rig", mapGridPosition (getPos _resMine)] remoteExec ["owr_fn_message", bis_curator_west];
								};
							};
						};
						case "warehouse_ar": {};
					};
				};
			};

			// damage check
			if ((damage _resMine) >= 0.95) then {
				_b_state = 2;
			};
		};
		case 1: {
			// ready state
			if (_tickNo >= _miningTick) then {
				_tickNo = 0;
				if (!(isNull (_resMine getVariable "ow_build_wrhs"))) then {
					_prevResQuantity = (_resMine getVariable "ow_build_wrhs") getVariable _resType;
					(_resMine getVariable "ow_build_wrhs") setVariable [_resType, _prevResQuantity + 1, true];
				};
			};

			// mining tick update (in case of a new research, upgrade requested manually by curator)
			if (_resMine getVariable "ow_resourcemine_refresh") then {
				_resMine setVariable ["ow_resourcemine_refresh", false, true];

				switch (_resMine getVariable "ow_resourcemine_level") do {
					case 0: {
						_baseTick = 85;
					};
					case 1: {
						_baseTick = 75;
					};
					case 2: {
						_baseTick = 65;
					};
					case 3: {
						_baseTick = 55;
					};
				};
				switch (_resType) do {
					case "ow_wrhs_siberite": {
						_miningTick = (_baseTick * 2) + random [7, 10, 15];		// siberite tick is slower
					};
					case "ow_wrhs_oil": {
						_miningTick = _baseTick + random [7, 10, 15]; 			// default tick for oil
					};
				};
			};

			if (_resMine getVariable "ow_build_deconstruct") then {
				_resMine setVariable ["ow_wip_progress", 1.001, true];
				_b_state = 3;
			};

			// damage check
			if ((damage _resMine) >= 0.95) then {
				_b_state = 2;
			};
		};
		case 2: {
			// damaged state
			_resMine setVariable ["ow_build_destroyed", true, true];
			
			if (_resMine getVariable "ow_build_deconstruct") then {
				deleteVehicle _resMine;
			};

			_b_state = -1;
		};

		case 3: {
			// deconstruct state
			_wip_progress = _resMine getVariable "ow_wip_progress";
			_workers = nearestObjects [_resMine, ["owr_manbase"], 15];
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
			_resMine setVariable ["ow_wip_progress", _wip_progress, true];

			if ((_resMine getVariable "ow_wip_progress") <= 0.0) then {
				// destroy entity
				_b_state = 2;

				// add resources from deconstruction
				if (!(isNull (_resMine getVariable "ow_build_wrhs"))) then {
					// add some resources back if assigned warehouse exists
					_resourceArray = [_resMine] call owr_fn_getBuildingCost;

					if ((_resourceArray select 0) != 0) then {
						// add crates
						_storedResource = (_resMine getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates";
						(_resMine getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", _storedResource + (_resourceArray select 0), true];
					};
					if ((_resourceArray select 1) != 0) then {
						// add oil
						_storedResource = (_resMine getVariable "ow_build_wrhs") getVariable "ow_wrhs_oil";
						(_resMine getVariable "ow_build_wrhs") setVariable ["ow_wrhs_oil", _storedResource + (_resourceArray select 1), true];
					};
					if ((_resourceArray select 2) != 0) then {
						// add siberite
						_storedResource = (_resMine getVariable "ow_build_wrhs") getVariable "ow_wrhs_siberite";
						(_resMine getVariable "ow_build_wrhs") setVariable ["ow_wrhs_siberite", _storedResource + (_resourceArray select 2), true];
					};
				};
			};
		};

		default {
		};
	};

	//hintSilent format ["%1\n%2", _tickNo, _b_state];
	if (_b_state == 1) then {
		_tickNo = _tickNo + 1;
	};
	sleep 0.1;
};