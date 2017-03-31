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

/*

function:

	normal build-up procedure
	once built, it will continously search for nearest possible factory with the same warehouse
	 this can be however overriden by user if requested (different cfg of factories), but still has to be the same warehouse!
	if a factory is present(assigned), it will display possible mount-able weapons
	 all actions will be greyed out if factory is busy, otherwise by clicking a button in the weapon list will execute job in factory
	 statemachine in aturret will wait until it is finished and do appropriate placing of a weapon turret itself
	aturret drains power from warehouse (20)

*/

// get the object from world
_turret = _this select 0;
_assignedWarehouse = _this select 1;
_curatorToUse = _this select 2;
_fnMTurretClass = "";
_factoryClassToSearch = "";
switch (_curatorToUse) do {
	case bis_curator_west: {
		_factoryClassToSearch = "factory_am";
		_fnMTurretClass = owr_fn_getAMMTurretClass;
	};
	case bis_curator_east: {
		_factoryClassToSearch = "factory_ru";
		_fnMTurretClass = owr_fn_getRUMTurretClass;
	};
	/*case bis_curator_arab: {
		_factoryClassToSearch = "factory_ar";
		_fnMTurretClass = owr_fn_getARMTurretClass;
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
				//[(_workers select 0), "Building finished", "Manual turret", mapGridPosition (getPos _turret)] spawn owr_fn_message;
				[(_workers select 0), "Building finished", "Manual turret", mapGridPosition (getPos _turret)] remoteExec ["owr_fn_message", _curatorToUse];
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
			// remove power req (if warehouse is connected)
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
					_weapon = ([_weaponClass] call _fnMTurretClass) createVehicle (getPos _turret);
					_weapon setPos (getPos _turret);
					
					switch (typeOf _turret) do {
						case "mturret_am": {
							bis_curator_west addCuratorEditableObjects [[_weapon], false];
							bis_curator_west removeCuratorEditableObjects [[_turret], false];
							_weapon addEventHandler ["HandleDamage", {
								_victim = (_this select 0);
								_revDamage = (_this select 2) - (damage _victim);
								_damageDivisor = 14;
								_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
								_newDamage
							}];
						};
						case "mturret_ru": {
							bis_curator_east addCuratorEditableObjects [[_weapon], false];
							bis_curator_east removeCuratorEditableObjects [[_turret], false];
							_weapon addEventHandler ["HandleDamage", {
								_victim = (_this select 0);
								_revDamage = (_this select 2) - (damage _victim);
								_damageDivisor = 8;
								_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
								_newDamage
							}];
						};
						/*case "mturret_ar": {
							bis_curator_arab addCuratorEditableObjects [[_weapon], false];
							bis_curator_arab removeCuratorEditableObjects [[_turret], false];
						};*/
					};

					_turret setVariable ["ow_turret_weapon", _weapon, true];
					_weapon setVariable ["ow_turret_stand", _turret, true];
					_b_state = 1;
					_hasWeapon = true;
					_turret setVariable ["ow_turret_power_req", 20.0, true];

					_weapon selectWeaponTurret [((_weapon weaponsTurret [0]) select 0), [0]];
					_vehicleMagazineType = _weapon currentMagazineTurret [0];

					// power drain update
					if (!(isNull (_turret getVariable "ow_build_wrhs"))) then {
						_warehousePowerLevel = ((_turret getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req");
						(_turret getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_req", (_warehousePowerLevel + (_turret getVariable "ow_turret_power_req")), true];
					};
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