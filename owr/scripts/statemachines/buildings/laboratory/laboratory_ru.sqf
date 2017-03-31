// get the object from world
_labka = _this select 0;
_assignedWarehouse = _this select 1;

_labka addEventHandler ["HandleDamage", {
	_victim = (_this select 0);
	_revDamage = (_this select 2) - (damage _victim);
	_damageDivisor = 9.4;
	_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
	_newDamage
}];

// only executed on server!
if (!(isServer)) exitWith {};

// state machine init
_b_state = 0;
_upgrade_left = false;
_upgrade_right = false;
_powerReq = 0.0;
_lastPowerReq = 0.0;
_lightCreated = false;
_powerAdd = false;
_lightPos = _labka modelToWorld (_labka selectionPosition ["light_lab_base", "Memory"]);
_bComplx = getNumber (configFile >> "CfgVehicles" >> (typeOf _labka) >> "mComplx");
[_labka, [false, false]] remoteExec ["setUnloadInCombat", owner _labka];

// hide model selections (not upgraded initialy)
_labka animateSource ["hide_adv_bridge", 1, true];
_labka animateSource ["hide_adv_weap", 1, true];
_labka animateSource ["hide_adv_time", 1, true];
_labka animateSource ["hide_adv_siberite", 1, true];
_labka animateSource ["hide_adv_comp", 1, true];
// all main variables for this laboratory
_labka setVariable ["ow_wip_progress", 0.0, true];	
_labka setVariable ["ow_build_ready", false, true];
_labka setVariable ["ow_lab_left", "", true];
_labka setVariable ["ow_lab_right", "", true];
_labka setVariable ["ow_lab_power_req", 0.0, true];
_labka setVariable ["ow_lab_buildmode", 0, true];
_labka setVariable ["ow_curr_res_cat", "", true];	// basic, weap, time, siberite, comp
_labka setVariable ["ow_curr_res_index", 0, true];	// index of chosen research within arrays
_labka setVariable ["ow_build_wrhs", _assignedWarehouse, true];
_labka setVariable ["ow_build_light", false, true];
_labka setVariable ["ow_build_deconstruct", false, true];
_labka setVariable ["ow_build_destroyed", false, true];

while {not (isNull _labka)} do {
	
	
	switch (_b_state) do {
		case 0: {
			/*
				wip state
				building locked in this state (get out cargo if inside)
				progress variable going towards 1.0
				any owr_manbase within radius is contributing towards 1.0
				any owr_manbase with worker class
				any owr_manbase can help

				ui actions:
					delete building
			*/
			//hintSilent "stav 0";
			_labka lock true;
			_wip_progress = _labka getVariable "ow_wip_progress";
			_workers = nearestObjects [_labka, ["owr_manbase"], 15];
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
			_labka setVariable ["ow_wip_progress", _wip_progress, true];	
			if (_wip_progress >= 1.0) then {
				_b_state = 1;
				_labka setVariable ["ow_wip_progress", 1.0, true];	
				_labka lock false;
				_labka setVariable ["ow_build_ready", true, true];

				// message
				//[(_workers select 0), "Building finished", "Basic laboratory", mapGridPosition (getPos _labka)] spawn owr_fn_message;
				[(_workers select 0), "Building finished", "Basic laboratory", mapGridPosition (getPos _labka)] remoteExec ["owr_fn_message", bis_curator_east];
			};

			if ((_labka getVariable "ow_build_light") && !(_lightCreated)) then {
				// create light source (night gameplay)
				[_lightPos] remoteExec ["owr_fn_createPointLight", 0];
				_lightCreated = true;
			};
			if (!(_labka getVariable "ow_build_light") && _lightCreated) then {
				[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
				_lightCreated = false;
			};

			// damage
			if ((damage _labka) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 1: {
			/*
				working state
				building is open
				is active research is chosen, this state is pushing said research towards 1.0 * research complexity
				active research can only be done when owr_manbase with scientist class is within cargo
				every owr_manbase with scientist class receives boost in ow_skill_scientist when doing research

				ui actions:
					change class to scientist for cargo
					choose research
					delete building


				any lab can do basic research
			*/
			_labka lock false;

			if (isNull (_labka getVariable "ow_build_wrhs")) then {
				// link lost to warehouse
				_powerAdd = true;
			} else {
				if (_powerAdd) then {
					// link to a warehouse was restored, we need to request power from it
					_powerAdd = false;
					if (_powerReq != 0) then {
						_warehousePowerLevel = ((_labka getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req");
						(_labka getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_req", (_warehousePowerLevel + _powerReq), true];
					};
				};
				
				if ((_labka getVariable "ow_curr_res_cat") != "") then {
					if (count crew _labka > 0) then {
						// we have some people inside to contribute on research
						// first lets check if there is enough energy for this lab
						if (((_labka getVariable "ow_curr_res_cat") == "basic") || (((_labka getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_avl") >= ((_labka getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req"))) then {
							// OK, good, lets get important values about chosen research
							_research_prog = 0.0;
							_research_compl = 0.0;
							_research_index = (_labka getVariable "ow_curr_res_index");
							switch ((_labka getVariable "ow_curr_res_cat")) do {
								case "basic": {
									_research_prog = (bis_curator_east getVariable "ow_ru_res_basic_prog") select (_research_index);
									_research_compl = (bis_curator_east getVariable "ow_ru_res_basic_comp") select (_research_index);
								};
								case "weap": {
									_research_prog = (bis_curator_east getVariable "ow_ru_res_weap_prog") select (_research_index);
									_research_compl = (bis_curator_east getVariable "ow_ru_res_weap_comp") select (_research_index);
								};
								case "time": {
									_research_prog = (bis_curator_east getVariable "ow_ru_res_time_prog") select (_research_index);
									_research_compl = (bis_curator_east getVariable "ow_ru_res_time_comp") select (_research_index);
								};
								case "siberite": {
									_research_prog = (bis_curator_east getVariable "ow_ru_res_siberite_prog") select (_research_index);
									_research_compl = (bis_curator_east getVariable "ow_ru_res_siberite_comp") select (_research_index);
								};
								case "comp": {
									_research_prog = (bis_curator_east getVariable "ow_ru_res_comp_prog") select (_research_index);
									_research_compl = (bis_curator_east getVariable "ow_ru_res_comp_comp") select (_research_index);
								};
								default {};
							};
							
							// ok go through all scientist within the cargo
							{
								if (((_x getVariable "ow_class") == 3) && (alive _x)) then {
									// cargo is ow man and scientiest class
									//  can contribute to research
									_x_skill = (_x getVariable "ow_skill_scientist");
									_research_prog = _research_prog + ([_research_compl, _x_skill] call owr_fn_makeResProgress);
									// increase scientist skill of _x if not maxed out
									if (_x_skill < 10.0) then {
										_x setVariable ["ow_skill_scientist", _x_skill + ([_research_compl, _x_skill] call owr_fn_makeExpProgress), true];
									};
								};
							} forEach (crew _labka);

							// update research progress array within appropriate research category
							switch ((_labka getVariable "ow_curr_res_cat")) do {
								case "basic": {
									_tempArray = [0,0,0,0,0,0,0,0,0,0,0];
									_tempArray set [(_research_index), _research_prog];
									for "_i" from 0 to (count _tempArray) do {
										if (_i != (_research_index)) then {
											_tempArray set [(_i), (bis_curator_east getVariable "ow_ru_res_basic_prog") select _i];
										};
									};
									bis_curator_east setVariable ["ow_ru_res_basic_prog", _tempArray, true];
								};
								case "weap": {
									_tempArray = [0,0,0,0,0,0,0];
									_tempArray set [(_research_index), _research_prog];
									for "_i" from 0 to (count _tempArray) do {
										if (_i != (_research_index)) then {
											_tempArray set [(_i), (bis_curator_east getVariable "ow_ru_res_weap_prog") select _i];
										};
									};
									bis_curator_east setVariable ["ow_ru_res_weap_prog", _tempArray, true];
								};
								case "time": {
									_tempArray = [0,0,0,0,0,0,0,0,0];
									_tempArray set [(_research_index), _research_prog];
									for "_i" from 0 to (count _tempArray) do {
										if (_i != (_research_index)) then {
											_tempArray set [(_i), (bis_curator_east getVariable "ow_ru_res_time_prog") select _i];
										};
									};
									bis_curator_east setVariable ["ow_ru_res_time_prog", _tempArray, true];
								};
								case "siberite": {
									_tempArray = [0,0,0,0,0];
									_tempArray set [(_research_index), _research_prog];
									for "_i" from 0 to (count _tempArray) do {
										if (_i != (_research_index)) then {
											_tempArray set [(_i), (bis_curator_east getVariable "ow_ru_res_siberite_prog") select _i];
										};
									};
									bis_curator_east setVariable ["ow_ru_res_siberite_prog", _tempArray, true];
								};
								case "comp": {
									_tempArray = [0,0,0,0,0,0];
									_tempArray set [(_research_index), _research_prog];
									for "_i" from 0 to (count _tempArray) do {
										if (_i != (_research_index)) then {
											_tempArray set [(_i), (bis_curator_east getVariable "ow_ru_res_comp_prog") select _i];
										};
									};
									bis_curator_east setVariable ["ow_ru_res_comp_prog", _tempArray, true];
								};
								default {};
							};
							if (_research_prog >= 1.0) then {
								//[(crew _labka) select 0, "Research completed", [(_labka getVariable "ow_curr_res_cat"), _research_index, bis_curator_east] call owr_fn_getResearchName, mapGridPosition (getPos _labka)] spawn owr_fn_message;
								[(crew _labka) select 0, "Research completed", [(_labka getVariable "ow_curr_res_cat"), _research_index, bis_curator_east] call owr_fn_getResearchName, mapGridPosition (getPos _labka)] remoteExec ["owr_fn_message", bis_curator_east];
								_labka setVariable ["ow_curr_res_cat", "", true];
								_labka setVariable ["ow_lab_buildmode", 0, true];
								//hintSilent "done";
							} else {
								//hintSilent format ["lab is researching %1\nresearch #%2 prog %3 comp %4\n\nplayer scientist %5", (_labka getVariable "ow_curr_res_cat"), (_labka getVariable "ow_curr_res_index"), _research_prog, _research_compl, bis_curator_east getVariable "ow_skill_scientist"];
							};
						};
					};
				};


				// upgrade events
				if (((_labka getVariable "ow_lab_left") != "") && (!_upgrade_left)) then {
					_b_state = 3;
					_upgrade_left = true;
					_labka setVariable ["ow_wip_progress", 0.0001, true];
					_labka animateSource ["hide_basic_bridge", 1, true];
					_labka animateSource ["hide_adv_bridge", 0, true];

					_lightPos = _labka modelToWorld (_labka selectionPosition ["light_lab_adv", "Memory"]);

					// left = comp, siberite
					_labka animateSource ["hide_basic_left", 1, true];
					switch (_labka getVariable "ow_lab_left") do {
						case "comp": {
							_labka animateSource ["hide_adv_comp", 0, true];
							_powerReq = _powerReq + 25;
						};
						case "siberite": {
							_labka animateSource ["hide_adv_siberite", 0, true];
							_powerReq = _powerReq + 20;
						};
						default {};
					};
				};

				if (((_labka getVariable "ow_lab_right") != "") && (!_upgrade_right)) then {
					_b_state = 3;
					_upgrade_right = true;
					_labka setVariable ["ow_wip_progress", 0.0001, true];
					_labka animateSource ["hide_basic_bridge", 1, true];
					_labka animateSource ["hide_adv_bridge", 0, true];

					_lightPos = _labka modelToWorld (_labka selectionPosition ["light_lab_adv", "Memory"]);

					// right = weap, time
					_labka animateSource ["hide_basic_right", 1, true];
					switch (_labka getVariable "ow_lab_right") do {
						case "weap": {
							_labka animateSource ["hide_adv_weap", 0, true];
							_powerReq = _powerReq + 15;
						};
						case "time": {
							_labka animateSource ["hide_adv_time", 0, true];
							_powerReq = _powerReq + 25;
						};
						default {};
					};
				};

				if ((_labka getVariable "ow_build_light") && !(_lightCreated)) then {
					// create light source (night gameplay)
					[_lightPos] remoteExec ["owr_fn_createPointLight", 0];
					_lightCreated = true;
				};
				if (!(_labka getVariable "ow_build_light") && _lightCreated) then {
					[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
					_lightCreated = false;
				};
			};

			if (_labka getVariable "ow_build_deconstruct") then {
				{
					moveOut _x;
				} forEach (crew _labka);
				_labka lockCargo true;

				_labka setVariable ["ow_wip_progress", 1.001, true];

				_b_state = 4;
			};

			// damage
			if ((damage _labka) >= 0.95) then {
				_b_state = 2;
			};
		};

		case 2: {
			{
				moveOut _x;
			} forEach (crew _labka);
			_labka lockCargo true;

			// warehouse power disconnect
			if (!(isNull (_labka getVariable "ow_build_wrhs"))) then {
				// get current power level at warehouse
				_warehousePowerLevel = ((_labka getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req");
				// sbustract with power gain from this particular plant
				(_labka getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_req", (_warehousePowerLevel - _powerReq), true];
			};

			if (_lightCreated) then {
				[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
			};

			_labka setVariable ["ow_build_destroyed", true, true];

			if (_labka getVariable "ow_build_deconstruct") then {
				deleteVehicle _labka;
			};

			_b_state = -1; // put it into non-existing state to prevent additional ticking
		};

		case 3: {
			/*
				upgrade state

				AM
				weapon
				time
				siberite
				computer

			*/
			{
				unassignVehicle _x;
				moveOut _x;
			} forEach (crew _labka);
			_labka lock true;

			_wip_progress = _labka getVariable "ow_wip_progress";
			_labka setVariable ["ow_build_ready", false, true];

			_workers = nearestObjects [_labka, ["owr_manbase"], 15];
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
			_labka setVariable ["ow_wip_progress", _wip_progress, true];	
			//hintSilent format["%1", _contr_count];
			if (_wip_progress >= 1.0) then {
				_b_state = 1;
				_labka setVariable ["ow_wip_progress", 1.0, true];
				_labka setVariable ["ow_build_ready", true, true];
				_labka setVariable ["ow_lab_buildmode", 0, true];
				_labka lock false;
				
				// message
				//[(_workers select 0), "Upgrade finished", "Laboratory upgrade", mapGridPosition (getPos _labka)] spawn owr_fn_message;
				[(_workers select 0), "Upgrade finished", "Laboratory upgrade", mapGridPosition (getPos _labka)] remoteExec ["owr_fn_message", bis_curator_east];

				if (!(isNull (_labka getVariable "ow_build_wrhs"))) then {
					if (_lastPowerReq != _powerReq) then {
						_prevPowerReq = ((_labka getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req") - _lastPowerReq;
						// assign new value of available power with updated power gain from this particular plant
						(_labka getVariable "ow_build_wrhs") setVariable ["ow_wrhs_power_req", (_prevPowerReq + _powerReq), true];
						_lastPowerReq = _powerReq;
						_labka setVariable ["ow_lab_power_req", _powerReq, true];
					};
				};
			};

			if ((_labka getVariable "ow_build_light") && !(_lightCreated)) then {
				// create light source (night gameplay)
				[_lightPos] remoteExec ["owr_fn_createPointLight", 0];
				_lightCreated = true;
			};
			if (!(_labka getVariable "ow_build_light") && _lightCreated) then {
				[_lightPos] remoteExec ["owr_fn_removePointLight", 0];
				_lightCreated = false;
			};

			// damage
			if ((damage _labka) >= 0.95) then {
				_b_state = 2;
			};
		};


		case 4: {
			/*
				deconstruction state
			*/

			_wip_progress = _labka getVariable "ow_wip_progress";
			_workers = nearestObjects [_labka, ["owr_manbase"], 15];
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
			_labka setVariable ["ow_wip_progress", _wip_progress, true];

			if ((_labka getVariable "ow_wip_progress") <= 0.0) then {
				// destroy entity
				_b_state = 2;

				// add resources from deconstruction
				if (!(isNull (_labka getVariable "ow_build_wrhs"))) then {
					// add some resources back if assigned warehouse exists
					_resourceArray = [_labka] call owr_fn_getBuildingCost;

					if ((_resourceArray select 0) != 0) then {
						// add crates
						_storedResource = (_labka getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates";
						(_labka getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", _storedResource + (_resourceArray select 0), true];
					};
					if ((_resourceArray select 1) != 0) then {
						// add oil
						_storedResource = (_labka getVariable "ow_build_wrhs") getVariable "ow_wrhs_oil";
						(_labka getVariable "ow_build_wrhs") setVariable ["ow_wrhs_oil", _storedResource + (_resourceArray select 1), true];
					};
					if ((_resourceArray select 2) != 0) then {
						// add siberite
						_storedResource = (_labka getVariable "ow_build_wrhs") getVariable "ow_wrhs_siberite";
						(_labka getVariable "ow_build_wrhs") setVariable ["ow_wrhs_siberite", _storedResource + (_resourceArray select 2), true];
					};
				};
			};
		};


		default {
		};
	};

	sleep 0.1;
};