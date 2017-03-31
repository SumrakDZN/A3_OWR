// get the object from world
_barracks = _this select 0;
_assignedWarehouse = _this select 1;
_curatorToUse = _this select 2;

switch (typeOf _barracks) do {
	case "barracks_am": {
		_barracks addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 20;
			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	};
	case "barracks_ru": {
		_barracks addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 20;
			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	};
};

// only executed on server!
if (!(isServer)) exitWith {};

_b_state = 0;						// initial state of fsm
_upgraded = false;					// internal upgrade flag
_lightCreated = false;
_lightPos = _barracks modelToWorld (_barracks selectionPosition ["light_armoury", "Memory"]);
_bComplx = getNumber (configFile >> "CfgVehicles" >> (typeOf _barracks) >> "mComplx");

// hide model selections
_barracks animateSource ["hide_barracks", 1, true];

_barracks setVariable ["ow_wip_progress", 0.0, true];
_barracks setVariable ["ow_build_ready", false, true];
_barracks setVariable ["ow_build_upgrade", false, true];
_barracks setVariable ["ow_build_wrhs", _assignedWarehouse, true];
_barracks setVariable ["ow_build_light", false, true];
_barracks setVariable ["ow_build_deconstruct", false, true];
_barracks setVariable ["ow_build_destroyed", false, true];

_barracks lockDriver true;
_barracks lockTurret [[0],true];
[_barracks, [false, false]] remoteExec ["setUnloadInCombat", owner _barracks];

while {!(isNull _barracks)} do {
	switch (_b_state) do {
		case 0: {
			_barracks lockCargo true;
			_wip_progress = _barracks getVariable "ow_wip_progress";
			_workers = nearestObjects [_barracks, ["owr_manbase"], 15];
			{
				_x_skill = (_x getVariable "ow_skill_worker");
				if (alive _x) then {
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
			_barracks setVariable ["ow_wip_progress", _wip_progress, true];	
			// finished?
			if (_wip_progress >= 1.0) then {
				_b_state = 1;
				_barracks setVariable ["ow_wip_progress", 1.0, true];
				_barracks setVariable ["ow_build_ready", true, true];
				_barracks lockCargo false;

				// message
				//[(_workers select 0), "Building finished", "Basic armoury", mapGridPosition (getPos _barracks)] spawn owr_fn_message;
				[(_workers select 0), "Building finished", "Basic armoury", mapGridPosition (getPos _barracks)] remoteExec ["owr_fn_message", _curatorToUse];

				if ((_barracks getVariable "ow_build_light") && !(_lightCreated)) then {
					// create light source (night gameplay)
					[_lightPos] remoteExec ["owr_fn_createPointLight", 0];
					_lightCreated = true;
				};
				if (!(_barracks getVariable "ow_build_light") && _lightCreated) then {
					[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
					_lightCreated = false;
				};
			};

			// damage
			if ((damage _barracks) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 1: {
			/*
				working state
			*/
			_barracks lockCargo false;

			// upgrade events
			if (_barracks getVariable "ow_build_upgrade" && !_upgraded) then {
				_b_state = 3;
				_barracks setVariable ["ow_wip_progress", 0.0001, true];
				_barracks setVariable ["ow_build_ready", false, true];
				_barracks animateSource ["hide_barracks", 0, true];
				_barracks animateSource ["hide_armoury", 1, true];

				_lightPos = _barracks modelToWorld (_barracks selectionPosition ["light_barracks", "Memory"]);
			};

			if (_barracks getVariable "ow_build_deconstruct") then {
				{
					moveOut _x;
				} forEach (crew _barracks);
				_barracks lockCargo true;

				_barracks setVariable ["ow_wip_progress", 1.001, true];

				_b_state = 4;
			};

			if ((_barracks getVariable "ow_build_light") && !(_lightCreated)) then {
				// create light source (night gameplay)
				[_lightPos] remoteExec ["owr_fn_createPointLight", 0];
				_lightCreated = true;
			};
			if (!(_barracks getVariable "ow_build_light") && _lightCreated) then {
				[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
				_lightCreated = false;
			};

			// damage
			if ((damage _barracks) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 2: {
			/*
				damaged state
			*/
			
			{
				moveOut _x;
			} forEach (crew _barracks);
			_barracks lockCargo true;

			if (_lightCreated) then {
				[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
			};

			_barracks setVariable ["ow_build_destroyed", true, true];

			if (_barracks getVariable "ow_build_deconstruct") then {
				deleteVehicle _barracks;
			};

			_b_state = -1; // put it into non-existing state to prevent additional ticking
		};

		case 3: {
			/*
				upgrade state
			*/
			{
				moveOut _x;
			} forEach (crew _barracks);
			_barracks lockCargo true;

			_wip_progress = _barracks getVariable "ow_wip_progress";
			_workers = nearestObjects [_barracks, ["owr_manbase"], 15];
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
			_barracks setVariable ["ow_wip_progress", _wip_progress, true];	

			if (_wip_progress >= 1.0) then {
				_b_state = 1;
				_barracks setVariable ["ow_wip_progress", 1.0, true];
				_barracks setVariable ["ow_build_ready", true, true];
				_barracks lockCargo false;
				_upgraded = true;

				// message
				//[(_workers select 0), "Upgrade finished", "Advanced barracks", mapGridPosition (getPos _barracks)] spawn owr_fn_message;
				[(_workers select 0), "Upgrade finished", "Advanced barracks", mapGridPosition (getPos _barracks)] remoteExec ["owr_fn_message", _curatorToUse];
			};

			if ((_barracks getVariable "ow_build_light") && !(_lightCreated)) then {
				// create light source (night gameplay)
				[_lightPos] remoteExec ["owr_fn_createPointLight", 0];
				_lightCreated = true;
			};
			if (!(_barracks getVariable "ow_build_light") && _lightCreated) then {
				[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
				_lightCreated = false;
			};

			// damage
			if ((damage _barracks) >= 0.95) then {
				_b_state = 2;
			};
		};


		case 4: {
			/*
				deconstruction state
			*/

			_wip_progress = _barracks getVariable "ow_wip_progress";
			_workers = nearestObjects [_barracks, ["owr_manbase"], 15];
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
			_barracks setVariable ["ow_wip_progress", _wip_progress, true];

			if ((_barracks getVariable "ow_wip_progress") <= 0.0) then {
				// destroy entity
				_b_state = 2;

				// add resources from deconstruction
				if (!(isNull (_barracks getVariable "ow_build_wrhs"))) then {
					// add some resources back if assigned warehouse exists
					_resourceArray = [_barracks] call owr_fn_getBuildingCost;

					if ((_resourceArray select 0) != 0) then {
						// add crates
						_storedResource = (_barracks getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates";
						(_barracks getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", _storedResource + (_resourceArray select 0), true];
					};
					if ((_resourceArray select 1) != 0) then {
						// add oil
						_storedResource = (_barracks getVariable "ow_build_wrhs") getVariable "ow_wrhs_oil";
						(_barracks getVariable "ow_build_wrhs") setVariable ["ow_wrhs_oil", _storedResource + (_resourceArray select 1), true];
					};
					if ((_resourceArray select 2) != 0) then {
						// add siberite
						_storedResource = (_barracks getVariable "ow_build_wrhs") getVariable "ow_wrhs_siberite";
						(_barracks getVariable "ow_build_wrhs") setVariable ["ow_wrhs_siberite", _storedResource + (_resourceArray select 2), true];
					};
				};
			};
		};

		default {
		};
	};

	sleep 0.1;
};