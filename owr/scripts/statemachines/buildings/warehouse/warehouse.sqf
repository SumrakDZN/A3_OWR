// get the object from world
_depot = _this select 0;

_curatorToUse = "";
switch (typeOf _depot) do {
	case "warehouse_am": {
		_curatorToUse = bis_curator_west;
		_depot addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 30;
			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	};
	case "warehouse_ru": {
		_curatorToUse = bis_curator_east;
		_depot addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 30;
			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	};
	case "warehouse_ar": {
		// ??
	};
};

// the rest is only executed on server!
if (!(isServer)) exitWith {};

// warehouse built, crates should spawn in this tile - let main script know! - currently done ONLY for Pliocen
_tileNo = (3 * floor (((getPos _depot) select 1) / 1706)) + floor (((getPos _depot) select 0) / 1706);
owr_res_dynamicspawners set [_tileNo, true];

_b_state = 0;						// initial state of fsm
_upgraded = false;					// internal upgrade flag
_lightCreated = false;
_lightPos = _depot modelToWorld (_depot selectionPosition ["light_depot", "Memory"]);
_bComplx = getNumber (configFile >> "CfgVehicles" >> (typeOf _depot) >> "mComplx");

// hide model selections
_depot animateSource ["hide_warehouse", 1, true];

_depot setVariable ["ow_wip_progress", 0.0, true];
_depot setVariable ["ow_build_ready", false, true];
_depot setVariable ["ow_build_upgrade", false, true];
_depot setVariable ["ow_build_light", false, true];

_depot setVariable ["ow_wrhs_range_0", 100.0, true];	// range of basic _depott (radius within anyone can build something and will belong to this warehouse), ow_build_upgrade to decide
_depot setVariable ["ow_wrhs_range_1", 150.0, true];	// range of advanced warehouse (radius within anyone can build something and will belong to this warehouse), ow_build_upgrade to decide
_depot setVariable ["ow_wrhs_power_avl", 0.0, true];	// how much it has from all buildings
_depot setVariable ["ow_wrhs_power_req", 0.0, true];	// how much power it needs in ow_wrhs_power_avl

_depot setVariable ["ow_wrhs_crates", 0.0, true];
_depot setVariable ["ow_wrhs_oil", 0.0, true];
_depot setVariable ["ow_wrhs_siberite", 0.0, true];
_depot setVariable ["ow_build_deconstruct", false, true];
_depot setVariable ["ow_build_destroyed", false, true];

_depot lockDriver true;
_depot lockTurret [[0],true];
[_depot, [false, false]] remoteExec ["setUnloadInCombat", owner _depot];

while {!(isNull _depot)} do {
	switch (_b_state) do {
		case 0: {
			_depot lockCargo true;
			_wip_progress = _depot getVariable "ow_wip_progress";
			_workers = nearestObjects [_depot, ["owr_manbase"], 15];
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
			_depot setVariable ["ow_wip_progress", _wip_progress, true];	
			if (_wip_progress >= 1.0) then {
				_b_state = 1;
				_depot setVariable ["ow_wip_progress", 1.0, true];
				_depot setVariable ["ow_build_ready", true, true];
				_depot lockCargo false;

				// message
				//[(_workers select 0), "Building finished", "Basic depot", mapGridPosition (getPos _depot)] spawn owr_fn_message;
				[(_workers select 0), "Building finished", "Basic depot", mapGridPosition (getPos _depot)] remoteExec ["owr_fn_message", _curatorToUse];
			};
			if ((_depot getVariable "ow_build_light") && !(_lightCreated)) then {
				// create light source (night gameplay)
				[_lightPos] remoteExec ["owr_fn_createPointLight", 0];
				_lightCreated = true;
			};
			if (!(_depot getVariable "ow_build_light") && _lightCreated) then {
				[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
				_lightCreated = false;
			};

			// damage
			if ((damage _depot) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 1: {
			/*
				working state
			*/
			_depot lockCargo false;

			// upgrade events
			if (_depot getVariable "ow_build_upgrade" && !_upgraded) then {
				_b_state = 3;
				_depot setVariable ["ow_wip_progress", 0.0001, true];
				_depot setVariable ["ow_build_ready", false, true];
				_depot animateSource ["hide_warehouse", 0, true];
				_depot animateSource ["hide_depot", 1, true];

				_lightPos = _depot modelToWorld (_depot selectionPosition ["light_warehouse", "Memory"]);
			};

			if (_depot getVariable "ow_build_deconstruct") then {
				{
					moveOut _x;
				} forEach (crew _depot);
				_depot lockCargo true;

				_depot setVariable ["ow_wip_progress", 1.001, true];

				_b_state = 4;
			};

			// light
			if ((_depot getVariable "ow_build_light") && !(_lightCreated)) then {
				// create light source (night gameplay)
				[_lightPos] remoteExec ["owr_fn_createPointLight", 0];
				_lightCreated = true;
			};
			if (!(_depot getVariable "ow_build_light") && _lightCreated) then {
				[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
				_lightCreated = false;
			};

			// damage
			if ((damage _depot) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 2: {
			{
				moveOut _x;
			} forEach (crew _depot);
			_depot lockCargo true;

			if (_lightCreated) then {
				[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
			};
			deleteVehicle _depot;
			_depot setVariable ["ow_build_destroyed", true, true];

			_b_state = -1;
		};

		case 3: {
			/*
				upgrade state
			*/
			{
				moveOut _x;
			} forEach (crew _depot);
			_depot lockCargo true;

			_wip_progress = _depot getVariable "ow_wip_progress";
			_workers = nearestObjects [_depot, ["owr_manbase"], 15];
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
						_wip_progress = _wip_progress + ([(_bComplx * 6.0), _x_skill] call owr_fn_makeBuildProgress);
						// increase worker skill of _x
						if (_x_skill < 10.0) then {
							_x setVariable ["ow_skill_worker", _x_skill + ([(_bComplx / 6.0), _x_skill] call owr_fn_makeExpProgress), true];
						};
					};
				};
			} forEach _workers;
			_depot setVariable ["ow_wip_progress", _wip_progress, true];	

			if (_wip_progress >= 1.0) then {
				_b_state = 1;
				_depot setVariable ["ow_wip_progress", 1.0, true];
				_depot setVariable ["ow_build_ready", true, true];
				_depot lockCargo false;
				_upgraded = true;

				// message
				//[(_workers select 0), "Upgrade finished", "Advanced warehouse", mapGridPosition (getPos _depot)] spawn owr_fn_message;
				[(_workers select 0), "Upgrade finished", "Advanced warehouse", mapGridPosition (getPos _depot)] remoteExec ["owr_fn_message", _curatorToUse];
			};
			
			if ((_depot getVariable "ow_build_light") && !(_lightCreated)) then {
				// create light source (night gameplay)
				[_lightPos] remoteExec ["owr_fn_createPointLight", 0];
				_lightCreated = true;
			};
			if (!(_depot getVariable "ow_build_light") && _lightCreated) then {
				[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
				_lightCreated = false;
			};

			// damage
			if ((damage _depot) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 4: {
			_wip_progress = _depot getVariable "ow_wip_progress";
			_workers = nearestObjects [_depot, ["owr_manbase"], 15];
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
			_depot setVariable ["ow_wip_progress", _wip_progress, true];

			if ((_depot getVariable "ow_wip_progress") <= 0.0) then {
				// destroy entity
				_b_state = 2;
			};
		};


		default {
		};
	};

	sleep 0.1;
};