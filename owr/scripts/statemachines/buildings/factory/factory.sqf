// get the object from world
_factory = _this select 0;
_assignedWarehouse = _this select 1;
_curatorToUse = _this select 2;
_fnVehicleClass = "";
_fnATurretClass = "";
_fnVehicleCost = "";
_vehicleSide = 0;
switch (_curatorToUse) do {
	case bis_curator_west: {
		_vehicleSide = 0;
		_fnVehicleClass = owr_fn_getAMVehicleClass;
		_fnATurretClass = owr_fn_getAMATurretClass;
		_fnVehicleCost = owr_fn_getAMVehicleCost;
		_factory addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 30.0;
			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	};
	case bis_curator_east: {
		_vehicleSide = 1;
		_fnVehicleClass = owr_fn_getRUVehicleClass;
		_fnATurretClass = owr_fn_getRUATurretClass;
		_fnVehicleCost = owr_fn_getRUVehicleCost;
		_factory addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 17.0;
			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	};
	/*case bis_curator_arab: {
		_vehicleSide = 2;
		_fnVehicleClass = owr_fn_getARVehicleClass;
		_fnATurretClass = owr_fn_getARATurretClass;
		_fnVehicleCost = owr_fn_getARVehicleCost;
	};*/
};

// only executed on server!
if (!(isServer)) exitWith {};

_b_state = 0;						// initial state of fsm
_upgraded = false;					// internal upgrade flag
_vehicleClass = "";
_vehicleComplx = 1.0;
_powerReq = 0.0;
_lastPowerReq = 0.0;
_powerAdd = false;
_lightCreated = false;
_lightPos = _factory modelToWorld (_factory selectionPosition ["light_workshop", "Memory"]);
_bComplx = getNumber (configFile >> "CfgVehicles" >> (typeOf _factory) >> "mComplx");
[_factory, [false, false]] remoteExec ["setUnloadInCombat", owner _factory];

// hide model selections
_factory animateSource ["hide_factory", 1, true];
_factory animateSource ["hide_ext_comp", 1, true];
_factory animateSource ["hide_ext_rocket", 1, true];
_factory animateSource ["hide_ext_gun", 1, true];
_factory animateSource ["hide_ext_track", 1, true];
_factory animateSource ["hide_ext_sib", 1, true];

_factory setVariable ["ow_wip_progress", 0.0, true];
_factory setVariable ["ow_build_ready", false, true];
_factory setVariable ["ow_build_upgrade", false, true];
_factory setVariable ["ow_build_light", false, true];

// side upgrades (pristavky)
// -- used
// 0 = track chassis
// 1 = cannon parts storage
// 2 = rocket parts storage
// 3 = siberite motor part storage
// 4 = advanced ai processors
// -- not used
// 5 = radar
// 6 = laser
// 7 = non-combat
// each factory == only 5 side upgrades

_factory setVariable ["ow_factory_upgrades", [false,false,false,false,false,false,false,false], true];
_factory setVariable ["ow_factory_side_upg", -1, true];
/*
// AM template
// index:
//  0 - chassis
//    * 0 lt_wh
//    * 1 md_wh
//    * 2 md_tr
//    * 3 hv_tr
//    * 4 mg
//  1 - engine
// 	  * 0 - cb
//    * 1 - sb
//    * 2 - el
//  2 - control
//    * 0 - mn
//    * 1 - ai
// 	  * 2 - rt
//  3 - function
//    *  0 - mgun
//    *  1 - lgun
//    *  2 - rgun
//    *  3 - dgun
//    *  4 - rlan
//    *  5 - hgun
//    *  6 - laser
//    *  7 - dlaser
//    *  8 - cargo
//    *  9 - radar
//    * 10 - crane

// RU template
// index:
//  0 - chassis
//    * 0 me_wh
//    * 1 me_tr
//    * 2 hv_wh
//    * 3 hv_tr
//  1 - engine
// 	  * 0 - cb
//    * 1 - sb
//  2 - control
//    * 0 - mn
//    * 1 - ai
//  3 - function
//    *  0 - hmgun
//    *  1 - rgun
//    *  2 - gun
//    *  3 - hgun
//    *  4 - rlan
//    *  5 - rocket
//    *  6 - cargo
//    *  7 - crane

*/
_factory setVariable ["ow_factory_template", [-1,-1,-1,-1], true];
_factory setVariable ["ow_factory_lasttemplate", [-1,-1,-1,-1], true];
_factory setVariable ["ow_factory_wtemplate", -1, true];
_factory setVariable ["ow_factory_recycle", [-1,-1,-1,-1], true];

_factory setVariable ["ow_factory_power_req", 0.0, true];
_factory setVariable ["ow_factory_buildmode", 0, true];
_factory setVariable ["ow_build_wrhs", _assignedWarehouse, true];
_factory setVariable ["ow_build_deconstruct", false, true];
_factory setVariable ["ow_build_destroyed", false, true];

_factory lockDriver true;
_factory lockTurret [[0],true];

while {!(isNull _factory)} do {
	switch (_b_state) do {
		case 0: {
			_factory lockCargo true;
			_wip_progress = _factory getVariable "ow_wip_progress";
			_workers = nearestObjects [_factory, ["owr_manbase"], 15];
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
			_factory setVariable ["ow_wip_progress", _wip_progress, true];	
			if (_wip_progress >= 1.0) then {
				_b_state = 1;
				_factory setVariable ["ow_wip_progress", 1.0, true];
				_factory setVariable ["ow_build_ready", true, true];
				_factory lockCargo false;

				// message
				//[(_workers select 0), "Building finished", "Basic factory", mapGridPosition (getPos _factory)] spawn owr_fn_message;
				[(_workers select 0), "Building finished", "Basic factory", mapGridPosition (getPos _factory)] remoteExec ["owr_fn_message", _curatorToUse];
			};

			if ((_factory getVariable "ow_build_light") && !(_lightCreated)) then {
				// create light source (night gameplay)
				[_lightPos] remoteExec ["owr_fn_createPointLight", 0];
				_lightCreated = true;
			};
			if (!(_factory getVariable "ow_build_light") && _lightCreated) then {
				[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
				_lightCreated = false;
			};

			// damage
			if ((damage _factory) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 1: {
			/*
				working state
			*/
			_factory lockCargo false;

			if (isNull (_factory getVariable "ow_build_wrhs")) then {
				// link lost to warehouse
				_powerAdd = true;
			} else {
				if (_powerAdd) then {
					// link to a warehouse was restored, we need to request power from it
					_powerAdd = false;
					if (_powerReq != 0) then {
						_warehousePowerLevel = ((_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req");
						(_factory getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_req", (_warehousePowerLevel + _powerReq), true];
					};
				};

				// upgrade events
				if (_factory getVariable "ow_build_upgrade" && !_upgraded) then {
					_b_state = 3;
					_factory setVariable ["ow_wip_progress", 0.0001, true];
					_factory setVariable ["ow_build_ready", false, true];
					_factory animateSource ["hide_factory", 0, true];
					_factory animateSource ["hide_workshop", 1, true];
					_powerReq = _powerReq + 35;

					_lightPos = _factory modelToWorld (_factory selectionPosition ["light_factory", "Memory"]);
				};
				if (_factory getVariable "ow_build_upgrade") then {
					// factory is upgraded, we can check if player wants to build side upgrades
					if ((_factory getVariable "ow_factory_side_upg") != -1) then {
						_b_state = 4;
						_factory setVariable ["ow_wip_progress", 0.0001, true];
						_factory setVariable ["ow_build_ready", false, true];
						switch (_factory getVariable "ow_factory_side_upg") do {
							case 0: {
								_factory animateSource ["hide_ext_track", 0, true];
								_powerReq = _powerReq + 2.5;
							};
							case 1: {
								_factory animateSource ["hide_ext_gun", 0, true];
								_powerReq = _powerReq + 4.5;
							};
							case 2: {
								_factory animateSource ["hide_ext_rocket", 0, true];
								_powerReq = _powerReq + 4.5;
							};
							case 3: {
								_factory animateSource ["hide_ext_sib", 0, true];
								_powerReq = _powerReq + 7.5;
							};
							case 4: {
								_factory animateSource ["hide_ext_comp", 0, true];
								_powerReq = _powerReq + 10.0;
							};
						};
					};
				};

				if ((_factory getVariable "ow_build_light") && !(_lightCreated)) then {
					// create light source (night gameplay)
					[_lightPos] remoteExec ["owr_fn_createPointLight", 0];
					_lightCreated = true;
				};
				if (!(_factory getVariable "ow_build_light") && _lightCreated) then {
					[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
					_lightCreated = false;
				};

				// manufacture events
				_vehicleToCreate = true;
				_weaponToCreate = false;
				_vehicleToRecycle = false;
				_vehicleRecycleTemplate = (_factory getVariable "ow_factory_recycle");
				_vehicleTemplate = (_factory getVariable "ow_factory_template");
				_weaponTemplate = (_factory getVariable "ow_factory_wtemplate");
				for "_i" from 0 to 3 do {
					if ((_vehicleTemplate select _i) == -1) then {
						_vehicleToCreate = false;
					};
				};
				for "_i" from 0 to 3 do {
					if ((_vehicleRecycleTemplate select _i) != -1) then {
						_vehicleToRecycle = true;
					} else {
						_vehicleToRecycle = false;
					};
				};
				if (!_vehicleToCreate) then {
					if (_weaponTemplate != -1) then {
						_weaponToCreate = true;
					};
				};

				if (_vehicleToCreate) then {
					_b_state = 5;
					_factory setVariable ["ow_wip_progress", 0.0001, true];
					// get target classname together
					_vehicleClass = [_factory getVariable "ow_factory_template"] call _fnVehicleClass;
					// get manufacturing complexity from cfg
					_vehicleComplx = getNumber (configFile >> "CfgVehicles" >> _vehicleClass >> "mComplx");
				} else {
					if (_weaponToCreate) then {
						_b_state = 6;
						_factory setVariable ["ow_wip_progress", 0.0001, true];
						// get manufacturing complexity from cfg
						_weaponClass = [_factory getVariable "ow_factory_wtemplate"] call _fnATurretClass;
						_vehicleComplx = getNumber (configFile >> "CfgVehicles" >> _weaponClass >> "mComplx");
					} else {
						if (_vehicleToRecycle) then {
							_b_state = 7;
							_factory setVariable ["ow_wip_progress", 0.0001, true];
							// get manufacturing complexity from cfg
							_vehicleComplx = getNumber (configFile >> "CfgVehicles" >> _vehicleClass >> "mComplx");
						};
					};
				};
			};

			if (_factory getVariable "ow_build_deconstruct") then {
				{
					moveOut _x;
				} forEach (crew _factory);
				_factory lockCargo true;

				_factory setVariable ["ow_wip_progress", 1.001, true];

				_b_state = 8;
			};

			// damage
			if ((damage _factory) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 2: {
			/*
				damaged state
			*/
			{
				moveOut _x;
			} forEach (crew _factory);
			_factory lockCargo true;

			// remove power req (if warehouse is connected)
			if (!(isNull (_factory getVariable "ow_build_wrhs"))) then {
				_prevPowerReq = ((_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req");
				(_factory getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_req", (_prevPowerReq - _powerReq), true];
			};

			if (_lightCreated) then {
				[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
			};

			if (_factory getVariable "ow_build_deconstruct") then {
				deleteVehicle _factory;
			};

			_factory setVariable ["ow_build_destroyed", true, true];

			_b_state = -1; // put it into non-existing state to prevent additional ticking
		};

		case 3: {
			/*
				upgrade state
			*/
			{
				moveOut _x;
			} forEach (crew _factory);
			_factory lockCargo true;

			_wip_progress = _factory getVariable "ow_wip_progress";
			_workers = nearestObjects [_factory, ["owr_manbase"], 15];
			{
				if (alive _x) then {
					_x_skill = (_x getVariable "ow_skill_worker");
					if ((_x getVariable "ow_class") == 1) then {
						// owr worker, contributes fully - higher skill = better
						_wip_progress = _wip_progress + ([_bComplx * 2.0, _x_skill] call owr_fn_makeBuildProgress);
						// increase worker skill of _x if not maxed out
						if (_x_skill < 10.0) then {
							_x setVariable ["ow_skill_worker", _x_skill + ([_bComplx * 2.0, _x_skill] call owr_fn_makeExpProgress), true];
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
			_factory setVariable ["ow_wip_progress", _wip_progress, true];	

			if (_wip_progress >= 1.0) then {
				_b_state = 1;
				_factory setVariable ["ow_wip_progress", 1.0, true];
				_factory setVariable ["ow_build_ready", true, true];
				_factory lockCargo false;
				_upgraded = true;

				// message
				//[(_workers select 0), "Upgrade finished", "Advanced factory", mapGridPosition (getPos _factory)] spawn owr_fn_message;
				[(_workers select 0), "Upgrade finished", "Advanced factory", mapGridPosition (getPos _factory)] remoteExec ["owr_fn_message", _curatorToUse];

				// power drain update
				if (!(isNull (_factory getVariable "ow_build_wrhs"))) then {
					if (_lastPowerReq != _powerReq) then {
						_prevPowerReq = ((_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req") - _lastPowerReq;
						// assign new value of available power with updated power gain from this particular building
						(_factory getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_req", (_prevPowerReq + _powerReq), true];
						_lastPowerReq = _powerReq;
						_factory setVariable ["ow_factory_power_req", _powerReq, true];
					};
				};
			};

			if ((_factory getVariable "ow_build_light") && !(_lightCreated)) then {
				// create light source (night gameplay)
				[_lightPos] remoteExec ["owr_fn_createPointLight", 0];
				_lightCreated = true;
			};
			if (!(_factory getVariable "ow_build_light") && _lightCreated) then {
				[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
				_lightCreated = false;
			};

			// damage
			if ((damage _factory) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 4: {
			/*
				side upgrade state
			*/
			{
				moveOut _x;
			} forEach (crew _factory);
			_factory lockCargo true;

			_wip_progress = _factory getVariable "ow_wip_progress";
			_workers = nearestObjects [_factory, ["owr_manbase"], 15];
			{
				if (alive _x) then {
					_x_skill = (_x getVariable "ow_skill_worker");
					if ((_x getVariable "ow_class") == 1) then {
						// owr worker, contributes fully - higher skill = better
						_wip_progress = _wip_progress + ([_bComplx * 0.25, _x_skill] call owr_fn_makeBuildProgress);
						// increase worker skill of _x if not maxed out
						if (_x_skill < 10.0) then {
							_x setVariable ["ow_skill_worker", _x_skill + ([_bComplx * 0.25, _x_skill] call owr_fn_makeExpProgress), true];
						};
					} else {
						// just normal owr man, still useful to have some worker skills though (but only contributes third)
						_wip_progress = _wip_progress + ([(_bComplx * 1.5), _x_skill] call owr_fn_makeBuildProgress);
						// increase worker skill of _x
						if (_x_skill < 10.0) then {
							_x setVariable ["ow_skill_worker", _x_skill + ([(_bComplx / 1.5), _x_skill] call owr_fn_makeExpProgress), true];
						};
					};
				};
			} forEach _workers;
			_factory setVariable ["ow_wip_progress", _wip_progress, true];	

			if (_wip_progress >= 1.0) then {
				_b_state = 1;
				_factory setVariable ["ow_wip_progress", 1.0, true];
				_factory setVariable ["ow_build_ready", true, true];
				_factory lockCargo false;
				_upgraded = true;

				// message
				_upgradeString = "";
				switch (_factory getVariable "ow_factory_side_upg") do {
					case 0: {
						_upgradeString = "Track chassis parts";
					};
					case 1: {
						_upgradeString = "Cannon parts storage";
					};
					case 2: {
						_upgradeString = "Rocket parts storage";
					};
					case 3: {
						_upgradeString = "Siberite motor parts";
					};
					case 4: {
						_upgradeString = "Advanced ai processors";
					};
				};
				_upgradesBck = _factory getVariable "ow_factory_upgrades";
				_upgradesBck set [(_factory getVariable "ow_factory_side_upg"), true];
				_factory setVariable ["ow_factory_upgrades", _upgradesBck, true];
				_factory setVariable ["ow_factory_side_upg", -1, true];
				_factory setVariable ["ow_factory_buildmode", 0, true];

				// message
				//[(_workers select 0), "Side upgrade finished", _upgradeString, mapGridPosition (getPos _factory)] spawn owr_fn_message;
				[(_workers select 0), "Side upgrade finished", _upgradeString, mapGridPosition (getPos _factory)] remoteExec ["owr_fn_message", _curatorToUse];

				// power drain update
				if (!(isNull (_factory getVariable "ow_build_wrhs"))) then {
					if (_lastPowerReq != _powerReq) then {
						_prevPowerReq = ((_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req") - _lastPowerReq;
						// assign new value of available power with updated power gain from this particular building
						(_factory getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_req", (_prevPowerReq + _powerReq), true];
						_lastPowerReq = _powerReq;
						_factory setVariable ["ow_factory_power_req", _powerReq, true];
					};
				};
			};
			
			if ((_factory getVariable "ow_build_light") && !(_lightCreated)) then {
				// create light source (night gameplay)
				[_lightPos] remoteExec ["owr_fn_createPointLight", 0];
				_lightCreated = true;
			};
			if (!(_factory getVariable "ow_build_light") && _lightCreated) then {
				[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
				_lightCreated = false;
			};

			// damage
			if ((damage _factory) >= 0.95) then {
				_b_state = 2;
			};
		};


		case 5: {
			// vehicle manufacturing state
			// start progress
			if (isNull (_factory getVariable "ow_build_wrhs")) then {
				_powerAdd = true;
			} else {
				if (_powerAdd) then {
					// link to a warehouse was restored, we need to request power from it
					_powerAdd = false;
					if (_powerReq != 0) then {
						_warehousePowerLevel = ((_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req");
						(_factory getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_req", (_warehousePowerLevel + _powerReq), true];
					};
				};

				_canStart = false;
				if (_factory getVariable "ow_build_upgrade") then {
					if (((_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_avl") >= ((_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req")) then {
						_canStart = true;
					};
				} else {
					_canStart = true;
				};
				if (_canStart) then {
					_wip_progress = _factory getVariable "ow_wip_progress";
					_mechanics = crew _factory;
					{
						if (alive _x) then {
							_x_skill = (_x getVariable "ow_skill_mechanic");
							if ((_x getVariable "ow_class") == 2) then {
								// owr mechanic, contributes fully - higher skill = better
								_wip_progress = _wip_progress + ([(_vehicleComplx), _x_skill] call owr_fn_makeManProgress);
								// increase mechanic skill of _x if not maxed out
								if (_x_skill < 10.0) then {
									_x setVariable ["ow_skill_mechanic", _x_skill + ([(_vehicleComplx), _x_skill] call owr_fn_makeExpProgress), true];
								};
							};
						};
					} forEach _mechanics;
					_factory setVariable ["ow_wip_progress", _wip_progress, true];	

					if (_wip_progress >= 1.0) then {
						_b_state = 1;
						_factory setVariable ["ow_wip_progress", 1.0, true];
						_factory setVariable ["ow_factory_lasttemplate", _factory getVariable "ow_factory_template", true];
						_factory setVariable ["ow_factory_template", [-1,-1,-1,-1], true];
						_factory setVariable ["ow_factory_buildmode", 0, true];
						_outputVehicle = _vehicleClass createVehicle (getPos _factory);
						_outputVehicle setVariable ["ow_vehicle_template", _factory getVariable "ow_factory_lasttemplate", true];

						// IF CARGO - set cargo amount and cargo type!
						if (_outputVehicle isKindOf "owr_car_am") then {
							if (((_outputVehicle getVariable "ow_vehicle_template") select 3) == 8) then {
								_outputVehicle setVariable ["ow_vehicle_cargo", 0, true];
								_outputVehicle setVariable ["ow_vehicle_cargo_type", 0, true];

								// med or heavy?
								//  0 - chassis
								//    * 0 lt_wh
								//    * 1 md_wh
								//    * 2 md_tr
								//    * 3 hv_tr
								//    * 4 mg
								if ((((_outputVehicle getVariable "ow_vehicle_template") select 0) == 1) || (((_outputVehicle getVariable "ow_vehicle_template") select 0) == 2)) then {
									// med
									_outputVehicle setVariable ["ow_vehicle_cargo_cap", 50, true];
								} else {
									// heavy
									_outputVehicle setVariable ["ow_vehicle_cargo_cap", 100, true];
								};
							};
						};
						if (_outputVehicle isKindOf "owr_car_ru") then {
							if (((_outputVehicle getVariable "ow_vehicle_template") select 3) == 6) then {
								_outputVehicle setVariable ["ow_vehicle_cargo", 0, true];
								_outputVehicle setVariable ["ow_vehicle_cargo_type", 0, true];

								// med or heavy?
								//  0 - chassis
								//    * 0 me_wh
								//    * 1 me_tr
								//    * 2 hv_wh
								//    * 3 hv_tr
								if ((((_outputVehicle getVariable "ow_vehicle_template") select 0) == 0) || (((_outputVehicle getVariable "ow_vehicle_template") select 0) == 1)) then {
									// med
									_outputVehicle setVariable ["ow_vehicle_cargo_cap", 50, true];
								} else {
									// heavy
									_outputVehicle setVariable ["ow_vehicle_cargo_cap", 100, true];
								};
							};
						};

						if (_outputVehicle isKindOf "owr_car_am") then {
							// vehicle script init
							if ((((_outputVehicle getVariable "ow_vehicle_template") select 3) == 8) || (((_outputVehicle getVariable "ow_vehicle_template") select 3) == 9) || (((_outputVehicle getVariable "ow_vehicle_template") select 3) == 10)) then {
								[_outputVehicle, ((_factory getVariable "ow_factory_lasttemplate") select 1), ((_factory getVariable "ow_factory_lasttemplate") select 2), _vehicleSide, ((_outputVehicle getVariable "ow_vehicle_template") select 0)] spawn owr_fn_ncombat_vehicle;
							} else {
								[_outputVehicle, ((_factory getVariable "ow_factory_lasttemplate") select 1), ((_factory getVariable "ow_factory_lasttemplate") select 2), _vehicleSide, ((_outputVehicle getVariable "ow_vehicle_template") select 0)] spawn owr_fn_combat_vehicle;
							};
						} else {
							if ((((_outputVehicle getVariable "ow_vehicle_template") select 3) == 6) || (((_outputVehicle getVariable "ow_vehicle_template") select 3) == 7)) then {
								[_outputVehicle, ((_factory getVariable "ow_factory_lasttemplate") select 1), ((_factory getVariable "ow_factory_lasttemplate") select 2), _vehicleSide, ((_outputVehicle getVariable "ow_vehicle_template") select 0)] spawn owr_fn_ncombat_vehicle;
							} else {
								[_outputVehicle, ((_factory getVariable "ow_factory_lasttemplate") select 1), ((_factory getVariable "ow_factory_lasttemplate") select 2), _vehicleSide, ((_outputVehicle getVariable "ow_vehicle_template") select 0)] spawn owr_fn_combat_vehicle;
							};
						};

						// vehicle zeus assign
						_curatorToUse addCuratorEditableObjects [[_outputVehicle], true];

						//[(_mechanics select 0), "Vehicle finished", _vehicleClass, mapGridPosition (getPos _factory)] spawn owr_fn_message;
						[(_mechanics select 0), "Vehicle finished", _vehicleClass, mapGridPosition (getPos _factory)] remoteExec ["owr_fn_message", _curatorToUse];
					};
				};
			};

			// damage
			if ((damage _factory) >= 0.95) then {
				_b_state = 2;
			};
		};


		case 6: {
			// weapon turret manufacturing state
			// start progress
			if (isNull (_factory getVariable "ow_build_wrhs")) then {
				_powerAdd = true;
			} else {
				if (_powerAdd) then {
					// link to a warehouse was restored, we need to request power from it
					_powerAdd = false;
					if (_powerReq != 0) then {
						_warehousePowerLevel = ((_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req");
						(_factory getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_req", (_warehousePowerLevel + _powerReq), true];
					};
				};

				_canStart = false;
				if (_factory getVariable "ow_build_upgrade") then {
					if (((_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_avl") >= ((_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req")) then {
						_canStart = true;
					};
				} else {
					_canStart = true;
				};
				if (_canStart) then {
					_wip_progress = _factory getVariable "ow_wip_progress";
					_mechanics = crew _factory;
					{
						if (alive _x) then {
							_x_skill = (_x getVariable "ow_skill_mechanic");
							if ((_x getVariable "ow_class") == 2) then {
								// owr mechanic, contributes fully - higher skill = better
								_wip_progress = _wip_progress + ([(_vehicleComplx), _x_skill] call owr_fn_makeManProgress);
								// increase mechanic skill of _x if not maxed out
								if (_x_skill < 10.0) then {
									_x setVariable ["ow_skill_mechanic", _x_skill + ([(_vehicleComplx), _x_skill] call owr_fn_makeExpProgress), true];
								};
							};
						};
					} forEach _mechanics;
					_factory setVariable ["ow_wip_progress", _wip_progress, true];	

					if (_wip_progress >= 1.0) then {
						_b_state = 1;
						_factory setVariable ["ow_wip_progress", 1.0, true];
						_factory setVariable ["ow_factory_buildmode", 0, true];
						[(_mechanics select 0), "Vehicle finished", ([_factory getVariable "ow_factory_wtemplate"] call _fnATurretClass), mapGridPosition (getPos _factory)] remoteExec ["owr_fn_message", _curatorToUse];
						_factory setVariable ["ow_factory_wtemplate", -1, true];
					};
				};
			};
			// damage
			if ((damage _factory) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 7: {
			// vehicle recycling state
			if (isNull (_factory getVariable "ow_build_wrhs")) then {
				_powerAdd = true;
			} else {
				if (_powerAdd) then {
					// link to a warehouse was restored, we need to request power from it
					_powerAdd = false;
					if (_powerReq != 0) then {
						_warehousePowerLevel = ((_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req");
						(_factory getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_req", (_warehousePowerLevel + _powerReq), true];
					};
				};

				_canStart = false;
				if (_factory getVariable "ow_build_upgrade") then {
					if (((_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_avl") >= ((_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req")) then {
						_canStart = true;
					};
				} else {
					_canStart = true;
				};
				if (_canStart) then {
					_wip_progress = _factory getVariable "ow_wip_progress";
					_mechanics = crew _factory;
					{
						if (alive _x) then {
							_x_skill = (_x getVariable "ow_skill_mechanic");
							if ((_x getVariable "ow_class") == 2) then {
								// owr mechanic, contributes fully - higher skill = better
								_wip_progress = _wip_progress + ([(_vehicleComplx), _x_skill] call owr_fn_makeManProgress);
								// increase mechanic skill of _x if not maxed out
								if (_x_skill < 10.0) then {
									_x setVariable ["ow_skill_mechanic", _x_skill + ([(_vehicleComplx), _x_skill] call owr_fn_makeExpProgress), true];
								};
							};
						};
					} forEach _mechanics;
					_factory setVariable ["ow_wip_progress", _wip_progress, true];	

					if (_wip_progress >= 1.0) then {
						_b_state = 1;
						
						_resourcesToAdd = [_factory getVariable "ow_factory_recycle"] call _fnVehicleCost;
						if ((_resourcesToAdd select 0) != 0) then {
							// some crates left, add them
							_currCrates = (_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates";
							(_factory getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", (_currCrates + (_resourcesToAdd select 0)), true];
						};
						if ((_resourcesToAdd select 1) != 0) then {
							// some oil left, add it
							_currOil = (_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_oil";
							(_factory getVariable "ow_build_wrhs") setVariable ["ow_wrhs_oil", (_currOil + (_resourcesToAdd select 1)), true];
						};
						if ((_resourcesToAdd select 2) != 0) then {
							// some siberite left, add it
							_currSiberite = (_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_siberite";
							(_factory getVariable "ow_build_wrhs") setVariable ["ow_wrhs_siberite", (_currSiberite + (_resourcesToAdd select 2)), true];
						};

						_factory setVariable ["ow_factory_recycle", [-1,-1,-1,-1], true];
						_factory setVariable ["ow_wip_progress", 1.0, true];
						_factory setVariable ["ow_factory_buildmode", 0, true];
						_factory setVariable ["ow_factory_wtemplate", -1, true];

						[(_mechanics select 0), "Vehicle recycled", format ["%1 crates, %2 oil, %3 siberite", (_resourcesToAdd select 0), (_resourcesToAdd select 1), (_resourcesToAdd select 2)], mapGridPosition (getPos _factory)] remoteExec ["owr_fn_message", _curatorToUse];
					};
				};
			};

			// damage
			if ((damage _factory) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 8: {
			/*
				deconstruction state
			*/

			_wip_progress = _factory getVariable "ow_wip_progress";
			_workers = nearestObjects [_factory, ["owr_manbase"], 15];
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
			_factory setVariable ["ow_wip_progress", _wip_progress, true];

			if ((_factory getVariable "ow_wip_progress") <= 0.0) then {
				// destroy entity
				_b_state = 2;

				// add resources from deconstruction
				if (!(isNull (_factory getVariable "ow_build_wrhs"))) then {
					// add some resources back if assigned warehouse exists
					_resourceArray = [_factory] call owr_fn_getBuildingCost;

					if ((_resourceArray select 0) != 0) then {
						// add crates
						_storedResource = (_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates";
						(_factory getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", _storedResource + (_resourceArray select 0), true];
					};
					if ((_resourceArray select 1) != 0) then {
						// add oil
						_storedResource = (_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_oil";
						(_factory getVariable "ow_build_wrhs") setVariable ["ow_wrhs_oil", _storedResource + (_resourceArray select 1), true];
					};
					if ((_resourceArray select 2) != 0) then {
						// add siberite
						_storedResource = (_factory getVariable "ow_build_wrhs") getVariable "ow_wrhs_siberite";
						(_factory getVariable "ow_build_wrhs") setVariable ["ow_wrhs_siberite", _storedResource + (_resourceArray select 2), true];
					};
				};
			};
		};

		default {
		};
	};

	sleep 0.1;
};