_debugModeParam = ["CheatMode"] call BIS_fnc_getParamValue;

owr_devhax = false;

if (_debugModeParam == 1) then {
	owr_devhax = true;
};


//////////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION INIT
//////////////////////////////////////////////////////////////////////////////////////////////
owr_fn_depositTick = {
	_deposit = _this select 0;

	_isSiberite = false;
	_foundByWest = false;
	_foundByEast = false;
	_foundByResistance = false;

	if (_deposit isKindOf "owr_deposit_siberite") then {
		_isSiberite = true;
	};
	while {!(isNull _deposit)} do {
		_scientists = nearestObjects [_deposit, ["owr_manbase"], 50];
		if ((count _scientists) > 0) then {
			if (((_scientists select 0) getVariable "ow_class") == 3) then {
				switch (side (_scientists select 0)) do {
					case west: {
						if (_isSiberite) then {						
							if (["basic", 5, bis_curator_west] call owr_fn_isResearchComplete) then {
								if (!_foundByWest) then {
									[(_scientists select 0), "Resource found", "Siberite deposit", mapGridPosition (getPos (_scientists select 0))] remoteExec ["owr_fn_message", bis_curator_west];
								};
								bis_curator_west addCuratorEditableObjects [[_deposit], false];		
								_foundByWest = true;
							};
						} else {
							if (!_foundByWest) then {
								[(_scientists select 0), "Resource found", "Oil deposit", mapGridPosition (getPos (_scientists select 0))] remoteExec ["owr_fn_message", bis_curator_west];
							};
							bis_curator_west addCuratorEditableObjects [[_deposit], false];
							_foundByWest = true;
						};
					};
					case east: {
						if (_isSiberite) then {						
							if (["basic", 5, bis_curator_east] call owr_fn_isResearchComplete) then {
								if (!_foundByEast) then {
									[(_scientists select 0), "Resource found", "Alaskite deposit", mapGridPosition (getPos (_scientists select 0))] remoteExec ["owr_fn_message", bis_curator_east];
								};
								bis_curator_east addCuratorEditableObjects [[_deposit], false];		
								_foundByEast = true;
							};
						} else {
							if (!_foundByEast) then {
								[(_scientists select 0), "Resource found", "Oil deposit", mapGridPosition (getPos (_scientists select 0))] remoteExec ["owr_fn_message", bis_curator_east];
							};
							bis_curator_east addCuratorEditableObjects [[_deposit], false];
							_foundByEast = true;
						};
					};
					case resistance: {
						if (_isSiberite) then {						
							if (["basic", 5, bis_curator_arab] call owr_fn_isResearchComplete) then {
								if (!_foundByResistance) then {
									[(_scientists select 0), "Resource found", "Siberite deposit", mapGridPosition (getPos (_scientists select 0))] remoteExec ["owr_fn_message", bis_curator_arab];
								};
								bis_curator_arab addCuratorEditableObjects [[_deposit], false];		
								_foundByResistance = true;
							};
						} else {
							if (!_foundByResistance) then {
								[(_scientists select 0), "Resource found", "Oil deposit", mapGridPosition (getPos (_scientists select 0))] remoteExec ["owr_fn_message", bis_curator_arab];
							};
							bis_curator_arab addCuratorEditableObjects [[_deposit], false];
							_foundByResistance = true;
						};
					};
				};
			};
		};

		sleep 1;
	};
};
owr_fn_owman_am_ai = {
	_owman = _this select 0;
	_cratesToGoBack = objNull;
	_lastLvl1 = floor (_owman getVariable "ow_skill_soldier");	// soldier
	_lastLvl2 = floor (_owman getVariable "ow_skill_worker");  // worker
	_lastLvl3 = floor (_owman getVariable "ow_skill_mechanic");  // mechanic
	_lastLvl4 = floor (_owman getVariable "ow_skill_scientist");  // scientist

	while {(alive _owman)} do {
		// class related stuff
		switch (_owman getVariable "ow_class") do {
			case 0: {
				// soldier
				_jobWIP = false;

				if ((vehicle _owman) != _owman) then {
					_jobWIP = true;
				};

				if (((_owman getVariable "ow_aitype") == 1) && !_jobWIP) then {
					// [ACTIVE] can help with construction (move closer to constr. site) - attractor: !ready within radius
					_wipBuildings = nearestObjects [_owman, ["owr_base0c_am", "owr_base1c_am", "owr_base6c_am"], 15];
					if ((count _wipBuildings) > 0) then {
						_isAnyWIP = false;
						_whichOne = 0;
						for "_i" from 0 to (count _wipBuildings) do {
							if (!((_wipBuildings select _i) getVariable "ow_build_ready") && !((_wipBuildings select _i) getVariable "ow_build_deconstruct") && !_isAnyWIP) then {
								_isAnyWIP = true;
								_whichOne = _i;
							};
						};
						if (_isAnyWIP) then {
							[_owman] doMove (getPos (_wipBuildings select _whichOne));
						};
					};
				};
			};

			case 1: {
				// worker
				_jobWIP = false;

				if (((_owman getVariable "ow_aitype") == 1) && !_jobWIP) then {
					// [ACTIVE] can help with construction/deconstruction (move closer to constr. site) - attractor: !ready within radius
					if (!_jobWIP) then {
						_wipBuildings = nearestObjects [_owman, ["owr_base0c_am", "owr_base1c_am", "owr_base6c_am"], 15];
						if ((count _wipBuildings) > 0) then {
							_isAnyWIP = false;
							_whichOne = 0;
							for "_i" from 0 to (count _wipBuildings) do {
								if ((!((_wipBuildings select _i) getVariable "ow_build_ready") || ((_wipBuildings select _i) getVariable "ow_build_deconstruct")) && !_isAnyWIP) then {
									_isAnyWIP = true;
									_whichOne = _i;
								};
							};
							if (_isAnyWIP) then {
								[_owman] doMove (getPos (_wipBuildings select _whichOne));
								_jobWIP = true;
							};
						};
					};

					// [ACTIVE] can repair damaged building (by moving closer to building area) - attractor: damage > 0 within radius
					if (!_jobWIP) then {
						_nearestBuildingsToRepair = nearestObjects [getPos _owman, ["owr_base0c_am", "owr_base1c_am", "owr_base6c_am"], 15];
						if ((count _nearestBuildingsToRepair) > 0) then {
							_i = 0;
							_indexOfDamagedBuilding = 0;
							for "_i" from 0 to ((count _nearestBuildingsToRepair) - 1) do {
								if (((damage (_nearestBuildingsToRepair select _i)) > 0.05) && ((damage (_nearestBuildingsToRepair select _i)) < 1.0) && (!_jobWIP)) then {
									_jobWIP = true;
									_indexOfDamagedBuilding = _i;
								};
							};
							if (_jobWIP) then {
								_buildingToRepair = (_nearestBuildingsToRepair select _indexOfDamagedBuilding);

								[_owman] doMove (getPos _buildingToRepair);

								if ((_owman distance _buildingToRepair) < 10) then {
									// remove some damage - based on skill + increase skill
									_owman_skill = (_owman getVariable "ow_skill_worker");
									// todo: could take a building complexity from the cfg in future
									_repairContr = ((1.0 / (2.0 * 2.0 * 2.0)) / 10.0) + (_owman_skill / 1000.0);
									// increase worker skill of _owman if not maxed out
									if (_owman_skill < 10.0) then {
										_owman setVariable ["ow_skill_worker", _owman_skill + ([(2.0 / 3.0), _owman_skill] call owr_fn_makeExpProgress), true];
									};
									_buildingToRepair setDamage ((damage _buildingToRepair) - _repairContr);
								};
							};
						};
					};

					// [ACTIVE] picking up crates, storing them in nearest warehouse
					if (!_jobWIP) then {
						// [ACTIVE] can carry crates automatically to closests warehouse - attractor: crate object within radius
						_hasEmptyBpck = backpack _owman;
						if (_hasEmptyBpck == "owr_backpack_crate_empty") then {
							// can take crates
							if (isNull _cratesToGoBack) then {
								_crates = nearestObjects [_owman, ["owr_crates_pile_1","owr_crates_pile_2","owr_crates_pile_3","owr_crates_pile_4","owr_crates_pile_5"], 15];
								if ((count _crates) > 0) then {
									// crates found
									[_owman] doMove (getPos (_crates select 0));
									_cratesToGoBack = (_crates select 0);
								};
							} else {
								// actively search for other crates in vicinity of worker
								_crates = nearestObjects [_owman, ["owr_crates_pile_1","owr_crates_pile_2","owr_crates_pile_3","owr_crates_pile_4","owr_crates_pile_5"], 15];
								if ((count _crates) > 0) then {
									_cratesToGoBack = (_crates select 0);
								};
								if ((_cratesToGoBack distance _owman) <= 15) then {
									[_owman] doMove (getPos _cratesToGoBack);
								};
							};
							//hintSilent format ["%1", (_cratesToGoBack distance _owman)];
							if ((_cratesToGoBack distance _owman) < 5) then {
								removeBackpackGlobal _owman;
								_owman addBackpackGlobal "owr_backpack_crate_full";
								if (!(isNull _cratesToGoBack)) then {
									_crateCnt = _cratesToGoBack getVariable "owr_crate_amount";
									_cratesToGoBack setVariable ["owr_crate_amount", _crateCnt - 1, true];
									switch (_crateCnt) do {
										case 5: {
											_cratesToGoBack animate ["hide_c1", 1, true];
										};
										case 4: {
											_cratesToGoBack animate ["hide_c2", 1, true];
										};
										case 3: {
											_cratesToGoBack animate ["hide_c3", 1, true];
										};
										case 2: {
											_cratesToGoBack animate ["hide_c4", 1, true];
										};
										case 1: {
											if (!(isNull _cratesToGoBack)) then {
												deleteVehicle _cratesToGoBack;
											};
										};
									};
								};
							};
						} else {
							if (_hasEmptyBpck == "owr_backpack_crate_full") then {
								// find closest warehouse to store crates
								_warehousesAround = _owman nearEntities [["warehouse_am"], 100];
								if ((count _warehousesAround) > 0) then {
									// warehouse found
									[_owman] doMove (getPos (_warehousesAround select 0));
									if (((_warehousesAround select 0) distance _owman) < 15) then {
										_owman assignAsCargo (_warehousesAround select 0);
										[_owman] orderGetIn true;
									};
								};
								//hintSilent format ["%1", ((_warehousesAround select 0) distance _owman)];
								/*if (((_warehousesAround select 0) distance _owman) < 8) then {
									removeBackpackGlobal _owman;
									_owman addBackpackGlobal "owr_backpack_crate_empty";
								};*/
								if ((vehicle _owman) == (_warehousesAround select 0)) then {
									removeBackpackGlobal _owman;
									_owman addBackpackGlobal "owr_backpack_crate_empty";

									_cratesInWrhs = (_warehousesAround select 0) getVariable "ow_wrhs_crates";
									(_warehousesAround select 0) setVariable ["ow_wrhs_crates", _cratesInWrhs + 10, true];

									unassignVehicle _owman;
								};
							};
						};
					};
				};
				if (((_owman getVariable "ow_aitype") == 0) && !_jobWIP) then {
					// [PASSIVE] 
					_cratesToGoBack = objNull;
					_hasEmptyBpck = backpack _owman;
					if (_hasEmptyBpck == "owr_backpack_crate_empty") then {
						// can take crates Box_East_AmmoOrd_F
						_crates = nearestObjects [_owman, ["owr_crates_pile_1","owr_crates_pile_2","owr_crates_pile_3","owr_crates_pile_4","owr_crates_pile_5"], 5];
						if ((count _crates) > 0) then {
							// crates found, pick them up
							removeBackpackGlobal _owman;
							_owman addBackpackGlobal "owr_backpack_crate_full";
							_crateCnt = (_crates select 0) getVariable "owr_crate_amount";
							(_crates select 0) setVariable ["owr_crate_amount", _crateCnt - 1, true];
							switch (_crateCnt) do {
								case 5: {
									(_crates select 0) animate ["hide_c1", 1, true];
								};
								case 4: {
									(_crates select 0) animate ["hide_c2", 1, true];
								};
								case 3: {
									(_crates select 0) animate ["hide_c3", 1, true];
								};
								case 2: {
									(_crates select 0) animate ["hide_c4", 1, true];
								};
								case 1: {
									if (!(isNull (_crates select 0))) then {
										deleteVehicle (_crates select 0);
									};
								};
							};
						};
					} else {
						if (_hasEmptyBpck == "owr_backpack_crate_full") then {
							// find closest warehouse to store crates
							_warehousesAround = nearestObjects [_owman, ["warehouse_am"], 8];
							if ((count _warehousesAround) > 0) then {
								_owman assignAsCargo (_warehousesAround select 0);
								[_owman] orderGetIn true;
							};
							if ((vehicle _owman) == (_warehousesAround select 0)) then {
								removeBackpackGlobal _owman;
								_owman addBackpackGlobal "owr_backpack_crate_empty";

								_cratesInWrhs = (_warehousesAround select 0) getVariable "ow_wrhs_crates";
								(_warehousesAround select 0) setVariable ["ow_wrhs_crates", _cratesInWrhs + 10, true];

								unassignVehicle _owman;
							};
						};
					};
				};
			};

			case 2: {
				// mechanic
				_jobWIP = false;

				if ((vehicle _owman) != _owman) then {
					_jobWIP = true;
				};

				// [ACTIVE/PASSIVE] can repair damaged vehicles - attractor: damage > 0
				if (((_owman getVariable "ow_aitype") == 1) && !_jobWIP) then {
					_nearestVehiclesToRepair = nearestObjects [getPos _owman, ["owr_car_am"], 10];
					if ((count _nearestVehiclesToRepair) > 0) then {
						_i = 0;
						_indexOfBrokenVehicle = 0;
						for "_i" from 0 to ((count _nearestVehiclesToRepair) - 1) do {
							if (((damage (_nearestVehiclesToRepair select _i)) > 0.05) && ((damage (_nearestVehiclesToRepair select _i)) < 1.0) && (!_jobWIP)) then {
								_jobWIP = true;
								_indexOfBrokenVehicle = _i;
							};
						};
						if (_jobWIP) then {
							_vehicleToRepair = (_nearestVehiclesToRepair select _indexOfBrokenVehicle);
							[_owman] doMove (getPos _vehicleToRepair);

							// remove some damage - based on skill + increase skill
							_owman_skill = (_owman getVariable "ow_skill_mechanic");
							_vehicleComplx = getNumber (configFile >> "CfgVehicles" >> (typeOf _vehicleToRepair) >> "mComplx");
							_repairContr = ((1.0 / (_vehicleComplx * _vehicleComplx * _vehicleComplx)) / 100.0) + (_owman_skill / 100.0);
							// increase mechanic skill of _owman if not maxed out
							if (_owman_skill < 10.0) then {
								_owman setVariable ["ow_skill_mechanic", _owman_skill + ([(2.0 / 3.0), _owman_skill] call owr_fn_makeExpProgress), true];
							};
							_vehicleToRepair setDamage ((damage _vehicleToRepair) - _repairContr);
						};
					};
				};

				if (((_owman getVariable "ow_aitype") == 1) && (!_jobWIP)) then {
					// [ACTIVE] can help with construction (move closer to constr. site) - attractor: !ready within radius
					_wipBuildings = nearestObjects [_owman, ["owr_base0c_am", "owr_base1c_am", "owr_base6c_am"], 15];
					if ((count _wipBuildings) > 0) then {
						_isAnyWIP = false;
						_whichOne = 0;
						for "_i" from 0 to (count _wipBuildings) do {
							if (!((_wipBuildings select _i) getVariable "ow_build_ready") && !((_wipBuildings select _i) getVariable "ow_build_deconstruct") && !_isAnyWIP) then {
								_isAnyWIP = true;
								_whichOne = _i;
							};
						};
						if (_isAnyWIP) then {
							[_owman] doMove (getPos (_wipBuildings select _whichOne));
						};
					};
				};
			};
			case 3: {
				// scientist
				_jobWIP = false;

				if ((vehicle _owman) != _owman) then {
					_jobWIP = true;
				};

				if (((_owman getVariable "ow_aitype") == 1) && !_jobWIP) then {
					// [ACTIVE] can help with construction (move closer to constr. site) - attractor: !ready within radius
					_wipBuildings = nearestObjects [_owman, ["owr_base0c_am", "owr_base1c_am", "owr_base6c_am"], 15];
					if ((count _wipBuildings) > 0) then {
						_isAnyWIP = false;
						_whichOne = 0;
						for "_i" from 0 to (count _wipBuildings) do {
							if (!((_wipBuildings select _i) getVariable "ow_build_ready") && !((_wipBuildings select _i) getVariable "ow_build_deconstruct") && !_isAnyWIP) then {
								_isAnyWIP = true;
								_whichOne = _i;
							};
						};
						if (_isAnyWIP) then {
							[_owman] doMove (getPos (_wipBuildings select _whichOne));
						};
					};
				};
			};
			default {};
		};

		// level/up checker
		if ((floor (_owman getVariable "ow_skill_soldier")) != _lastLvl1) then {
			// level-up as soldier
			_lastLvl1 = (floor (_owman getVariable "ow_skill_soldier"));
			[(_owman), "Combat experience increased", format ["Level up %1", (floor (_owman getVariable "ow_skill_soldier"))], mapGridPosition (getPos _owman)] remoteExec ["owr_fn_message", bis_curator_west];
		};
		if ((floor (_owman getVariable "ow_skill_worker")) != _lastLvl2) then {
			// level-up as worker
			_lastLvl2 = (floor (_owman getVariable "ow_skill_worker"));
			[(_owman), "Worker experience increased", format ["Level up %1", (floor (_owman getVariable "ow_skill_worker"))], mapGridPosition (getPos _owman)] remoteExec ["owr_fn_message", bis_curator_west];
		};
		if ((floor (_owman getVariable "ow_skill_mechanic")) != _lastLvl3) then {
			// level-up as mechanic
			_lastLvl3 = (floor (_owman getVariable "ow_skill_mechanic"));
			[(_owman), "Mechanic experience increased", format ["Level up %1", (floor (_owman getVariable "ow_skill_mechanic"))], mapGridPosition (getPos _owman)] remoteExec ["owr_fn_message", bis_curator_west];
		};
		if ((floor (_owman getVariable "ow_skill_scientist")) != _lastLvl4) then {
			// level-up as scientist
			_lastLvl4 = (floor (_owman getVariable "ow_skill_scientist"));
			[(_owman), "Scientific knowledge increased", format ["Level up %1", (floor (_owman getVariable "ow_skill_scientist"))], mapGridPosition (getPos _owman)] remoteExec ["owr_fn_message", bis_curator_west];
		};

		sleep 2.5;
	};
};
owr_fn_owman_ru_ai = {
	_owman = _this select 0;
	_cratesToGoBack = objNull;
	_lastLvl1 = floor (_owman getVariable "ow_skill_soldier");	// soldier
	_lastLvl2 = floor (_owman getVariable "ow_skill_worker");  // worker
	_lastLvl3 = floor (_owman getVariable "ow_skill_mechanic");  // mechanic
	_lastLvl4 = floor (_owman getVariable "ow_skill_scientist");  // scientist

	while {(alive _owman)} do {
		// class related stuff
		switch (_owman getVariable "ow_class") do {
			case 0: {
				// soldier
				_jobWIP = false;

				if ((vehicle _owman) != _owman) then {
					_jobWIP = true;
				};

				if (((_owman getVariable "ow_aitype") == 1) && !_jobWIP) then {
					// [ACTIVE] can help with construction (move closer to constr. site) - attractor: !ready within radius
					_wipBuildings = nearestObjects [_owman, ["owr_base0c_ru", "owr_base1c_ru", "owr_base6c_ru"], 15];
					if ((count _wipBuildings) > 0) then {
						_isAnyWIP = false;
						_whichOne = 0;
						for "_i" from 0 to (count _wipBuildings) do {
							if (!((_wipBuildings select _i) getVariable "ow_build_ready") && !((_wipBuildings select _i) getVariable "ow_build_deconstruct") && !_isAnyWIP) then {
								_isAnyWIP = true;
								_whichOne = _i;
							};
						};
						if (_isAnyWIP) then {
							[_owman] doMove (getPos (_wipBuildings select _whichOne));
						};
					};
				};
			};

			case 1: {
				// worker
				_jobWIP = false;

				if (((_owman getVariable "ow_aitype") == 1) && !_jobWIP) then {
					// [ACTIVE] can help with construction/deconstruction (move closer to constr. site) - attractor: !ready within radius
					if (!_jobWIP) then {
						_wipBuildings = nearestObjects [_owman, ["owr_base0c_ru", "owr_base1c_ru", "owr_base6c_ru"], 15];
						if ((count _wipBuildings) > 0) then {
							_isAnyWIP = false;
							_whichOne = 0;
							for "_i" from 0 to (count _wipBuildings) do {
								if ((!((_wipBuildings select _i) getVariable "ow_build_ready") || ((_wipBuildings select _i) getVariable "ow_build_deconstruct")) && !_isAnyWIP) then {
									_isAnyWIP = true;
									_whichOne = _i;
								};
							};
							if (_isAnyWIP) then {
								[_owman] doMove (getPos (_wipBuildings select _whichOne));
								_jobWIP = true;
							};
						};
					};

					// [ACTIVE] can repair damaged building (by moving closer to building area) - attractor: damage > 0 within radius
					if (!_jobWIP) then {
						_nearestBuildingsToRepair = nearestObjects [getPos _owman, ["owr_base0c_ru", "owr_base1c_ru", "owr_base6c_ru"], 15];
						if ((count _nearestBuildingsToRepair) > 0) then {
							_i = 0;
							_indexOfDamagedBuilding = 0;
							for "_i" from 0 to ((count _nearestBuildingsToRepair) - 1) do {
								if (((damage (_nearestBuildingsToRepair select _i)) > 0.05) && ((damage (_nearestBuildingsToRepair select _i)) < 1.0) && (!_jobWIP)) then {
									_jobWIP = true;
									_indexOfDamagedBuilding = _i;
								};
							};
							if (_jobWIP) then {
								_buildingToRepair = (_nearestBuildingsToRepair select _indexOfDamagedBuilding);

								[_owman] doMove (getPos _buildingToRepair);

								if ((_owman distance _buildingToRepair) < 10) then {
									// remove some damage - based on skill + increase skill
									_owman_skill = (_owman getVariable "ow_skill_worker");
									// todo: could take a building complexity from the cfg in future
									_repairContr = ((1.0 / (2.0 * 2.0 * 2.0)) / 10.0) + (_owman_skill / 1000.0);
									// increase worker skill of _owman if not maxed out
									if (_owman_skill < 10.0) then {
										_owman setVariable ["ow_skill_worker", _owman_skill + ([(2.0 / 3.0), _owman_skill] call owr_fn_makeExpProgress), true];
									};
									_buildingToRepair setDamage ((damage _buildingToRepair) - _repairContr);
								};
							};
						};
					};

					// [ACTIVE] picking up crates, storing them in nearest warehouse
					if (!_jobWIP) then {
						// [ACTIVE] can carry crates automatically to closests warehouse - attractor: crate object within radius
						_hasEmptyBpck = backpack _owman;
						if (_hasEmptyBpck == "owr_backpack_crate_empty") then {
							// can take crates
							if (isNull _cratesToGoBack) then {
								_crates = nearestObjects [_owman, ["owr_crates_pile_1","owr_crates_pile_2","owr_crates_pile_3","owr_crates_pile_4","owr_crates_pile_5"], 15];
								if ((count _crates) > 0) then {
									// crates found
									[_owman] doMove (getPos (_crates select 0));
									_cratesToGoBack = (_crates select 0);
								};
							} else {
								// actively search for other crates in vicinity of worker
								_crates = nearestObjects [_owman, ["owr_crates_pile_1","owr_crates_pile_2","owr_crates_pile_3","owr_crates_pile_4","owr_crates_pile_5"], 15];
								if ((count _crates) > 0) then {
									_cratesToGoBack = (_crates select 0);
								};
								if ((_cratesToGoBack distance _owman) <= 15) then {
									[_owman] doMove (getPos _cratesToGoBack);
								};
							};
							//hintSilent format ["%1", (_cratesToGoBack distance _owman)];
							if ((_cratesToGoBack distance _owman) < 5) then {
								removeBackpackGlobal _owman;
								_owman addBackpackGlobal "owr_backpack_crate_full";
								if (!(isNull _cratesToGoBack)) then {
									_crateCnt = _cratesToGoBack getVariable "owr_crate_amount";
									_cratesToGoBack setVariable ["owr_crate_amount", _crateCnt - 1, true];
									switch (_crateCnt) do {
										case 5: {
											_cratesToGoBack animate ["hide_c1", 1, true];
										};
										case 4: {
											_cratesToGoBack animate ["hide_c2", 1, true];
										};
										case 3: {
											_cratesToGoBack animate ["hide_c3", 1, true];
										};
										case 2: {
											_cratesToGoBack animate ["hide_c4", 1, true];
										};
										case 1: {
											if (!(isNull _cratesToGoBack)) then {
												deleteVehicle _cratesToGoBack;
											};
										};
									};
								};
							};
						} else {
							if (_hasEmptyBpck == "owr_backpack_crate_full") then {
								// find closest warehouse to store crates
								_warehousesAround = _owman nearEntities [["warehouse_ru"], 100];
								if ((count _warehousesAround) > 0) then {
									// warehouse found
									[_owman] doMove (getPos (_warehousesAround select 0));
									if (((_warehousesAround select 0) distance _owman) < 15) then {
										_owman assignAsCargo (_warehousesAround select 0);
										[_owman] orderGetIn true;
									};
								};
								//hintSilent format ["%1", ((_warehousesAround select 0) distance _owman)];
								/*if (((_warehousesAround select 0) distance _owman) < 8) then {
									removeBackpackGlobal _owman;
									_owman addBackpackGlobal "owr_backpack_crate_empty";
								};*/
								if ((vehicle _owman) == (_warehousesAround select 0)) then {
									removeBackpackGlobal _owman;
									_owman addBackpackGlobal "owr_backpack_crate_empty";

									_cratesInWrhs = (_warehousesAround select 0) getVariable "ow_wrhs_crates";
									(_warehousesAround select 0) setVariable ["ow_wrhs_crates", _cratesInWrhs + 10, true];

									unassignVehicle _owman;
								};
							};
						};
					};
				};
				if (((_owman getVariable "ow_aitype") == 0) && !_jobWIP) then {
					// [PASSIVE] 
					_cratesToGoBack = objNull;
					_hasEmptyBpck = backpack _owman;
					if (_hasEmptyBpck == "owr_backpack_crate_empty") then {
						// can take crates Box_East_AmmoOrd_F
						_crates = nearestObjects [_owman, ["owr_crates_pile_1","owr_crates_pile_2","owr_crates_pile_3","owr_crates_pile_4","owr_crates_pile_5"], 5];
						if ((count _crates) > 0) then {
							// crates found, pick them up
							removeBackpackGlobal _owman;
							_owman addBackpackGlobal "owr_backpack_crate_full";
							_crateCnt = (_crates select 0) getVariable "owr_crate_amount";
							(_crates select 0) setVariable ["owr_crate_amount", _crateCnt - 1, true];
							switch (_crateCnt) do {
								case 5: {
									(_crates select 0) animate ["hide_c1", 1, true];
								};
								case 4: {
									(_crates select 0) animate ["hide_c2", 1, true];
								};
								case 3: {
									(_crates select 0) animate ["hide_c3", 1, true];
								};
								case 2: {
									(_crates select 0) animate ["hide_c4", 1, true];
								};
								case 1: {
									if (!(isNull (_crates select 0))) then {
										deleteVehicle (_crates select 0);
									};
								};
							};
						};
					} else {
						if (_hasEmptyBpck == "owr_backpack_crate_full") then {
							// find closest warehouse to store crates
							_warehousesAround = nearestObjects [_owman, ["warehouse_ru"], 8];
							if ((count _warehousesAround) > 0) then {
								_owman assignAsCargo (_warehousesAround select 0);
								[_owman] orderGetIn true;
							};
							if ((vehicle _owman) == (_warehousesAround select 0)) then {
								removeBackpackGlobal _owman;
								_owman addBackpackGlobal "owr_backpack_crate_empty";

								_cratesInWrhs = (_warehousesAround select 0) getVariable "ow_wrhs_crates";
								(_warehousesAround select 0) setVariable ["ow_wrhs_crates", _cratesInWrhs + 10, true];

								unassignVehicle _owman;
							};
						};
					};
				};
			};

			case 2: {
				// mechanic
				_jobWIP = false;

				if ((vehicle _owman) != _owman) then {
					_jobWIP = true;
				};

				// [ACTIVE/PASSIVE] can repair damaged vehicles - attractor: damage > 0
				if (((_owman getVariable "ow_aitype") == 1) && !_jobWIP) then {
					_nearestVehiclesToRepair = nearestObjects [getPos _owman, ["owr_car_ru"], 10];
					if ((count _nearestVehiclesToRepair) > 0) then {
						_i = 0;
						_indexOfBrokenVehicle = 0;
						for "_i" from 0 to ((count _nearestVehiclesToRepair) - 1) do {
							if (((damage (_nearestVehiclesToRepair select _i)) > 0.05) && ((damage (_nearestVehiclesToRepair select _i)) < 1.0) && (!_jobWIP)) then {
								_jobWIP = true;
								_indexOfBrokenVehicle = _i;
							};
						};
						if (_jobWIP) then {
							_vehicleToRepair = (_nearestVehiclesToRepair select _indexOfBrokenVehicle);
							[_owman] doMove (getPos _vehicleToRepair);

							// remove some damage - based on skill + increase skill
							_owman_skill = (_owman getVariable "ow_skill_mechanic");
							_vehicleComplx = getNumber (configFile >> "CfgVehicles" >> (typeOf _vehicleToRepair) >> "mComplx");
							_repairContr = ((1.0 / (_vehicleComplx * _vehicleComplx * _vehicleComplx)) / 100.0) + (_owman_skill / 100.0);
							// increase mechanic skill of _owman if not maxed out
							if (_owman_skill < 10.0) then {
								_owman setVariable ["ow_skill_mechanic", _owman_skill + ([(2.0 / 3.0), _owman_skill] call owr_fn_makeExpProgress), true];
							};
							_vehicleToRepair setDamage ((damage _vehicleToRepair) - _repairContr);
						};
					};
				};

				if (((_owman getVariable "ow_aitype") == 1) && (!_jobWIP)) then {
					// [ACTIVE] can help with construction (move closer to constr. site) - attractor: !ready within radius
					_wipBuildings = nearestObjects [_owman, ["owr_base0c_ru", "owr_base1c_ru", "owr_base6c_ru"], 15];
					if ((count _wipBuildings) > 0) then {
						_isAnyWIP = false;
						_whichOne = 0;
						for "_i" from 0 to (count _wipBuildings) do {
							if (!((_wipBuildings select _i) getVariable "ow_build_ready") && !((_wipBuildings select _i) getVariable "ow_build_deconstruct") && !_isAnyWIP) then {
								_isAnyWIP = true;
								_whichOne = _i;
							};
						};
						if (_isAnyWIP) then {
							[_owman] doMove (getPos (_wipBuildings select _whichOne));
						};
					};
				};
			};
			case 3: {
				// scientist
				_jobWIP = false;

				if ((vehicle _owman) != _owman) then {
					_jobWIP = true;
				};

				if (((_owman getVariable "ow_aitype") == 1) && !_jobWIP) then {
					// [ACTIVE] can help with construction (move closer to constr. site) - attractor: !ready within radius
					_wipBuildings = nearestObjects [_owman, ["owr_base0c_ru", "owr_base1c_ru", "owr_base6c_ru"], 15];
					if ((count _wipBuildings) > 0) then {
						_isAnyWIP = false;
						_whichOne = 0;
						for "_i" from 0 to (count _wipBuildings) do {
							if (!((_wipBuildings select _i) getVariable "ow_build_ready") && !((_wipBuildings select _i) getVariable "ow_build_deconstruct") && !_isAnyWIP) then {
								_isAnyWIP = true;
								_whichOne = _i;
							};
						};
						if (_isAnyWIP) then {
							[_owman] doMove (getPos (_wipBuildings select _whichOne));
						};
					};
				};
			};
			default {};
		};

		// "fog of war" test
		//_enemyAround = nearestObjects [_owman, ["owr_man_ru"], 15];
		//_owman setVariable ["ow_enemies_around", _enemyAround, true];

		// level/up checker
		if ((floor (_owman getVariable "ow_skill_soldier")) != _lastLvl1) then {
			// level-up as soldier
			_lastLvl1 = (floor (_owman getVariable "ow_skill_soldier"));
			[(_owman), "Combat experience increased", format ["Level up %1", (floor (_owman getVariable "ow_skill_soldier"))], mapGridPosition (getPos _owman)] remoteExec ["owr_fn_message", bis_curator_east];
		};
		if ((floor (_owman getVariable "ow_skill_worker")) != _lastLvl2) then {
			// level-up as worker
			_lastLvl2 = (floor (_owman getVariable "ow_skill_worker"));
			[(_owman), "Worker experience increased", format ["Level up %1", (floor (_owman getVariable "ow_skill_worker"))], mapGridPosition (getPos _owman)] remoteExec ["owr_fn_message", bis_curator_east];
		};
		if ((floor (_owman getVariable "ow_skill_mechanic")) != _lastLvl3) then {
			// level-up as mechanic
			_lastLvl3 = (floor (_owman getVariable "ow_skill_mechanic"));
			[(_owman), "Mechanic experience increased", format ["Level up %1", (floor (_owman getVariable "ow_skill_mechanic"))], mapGridPosition (getPos _owman)] remoteExec ["owr_fn_message", bis_curator_east];
		};
		if ((floor (_owman getVariable "ow_skill_scientist")) != _lastLvl4) then {
			// level-up as scientist
			_lastLvl4 = (floor (_owman getVariable "ow_skill_scientist"));
			[(_owman), "Scientific knowledge increased", format ["Level up %1", (floor (_owman getVariable "ow_skill_scientist"))], mapGridPosition (getPos _owman)] remoteExec ["owr_fn_message", bis_curator_east];
		};
		sleep 2.5;
	};
};
owr_fn_owman_ar_ai = {
	_owman = _this select 0;
	_cratesToGoBack = objNull;
	_lastLvl1 = floor (_owman getVariable "ow_skill_soldier");	// soldier
	_lastLvl2 = floor (_owman getVariable "ow_skill_worker");  // worker
	_lastLvl3 = floor (_owman getVariable "ow_skill_mechanic");  // mechanic
	_lastLvl4 = floor (_owman getVariable "ow_skill_scientist");  // scientist

	while {(alive _owman)} do {
		// class related stuff
		switch (_owman getVariable "ow_class") do {
			case 0: {
				// soldier
				_jobWIP = false;

				if ((vehicle _owman) != _owman) then {
					_jobWIP = true;
				};

				if (((_owman getVariable "ow_aitype") == 1) && !_jobWIP) then {
					// [ACTIVE] can help with construction (move closer to constr. site) - attractor: !ready within radius
					_wipBuildings = nearestObjects [_owman, ["owr_base0c_ar", "owr_base1c_ar", "owr_base6c_ar"], 15];
					if ((count _wipBuildings) > 0) then {
						_isAnyWIP = false;
						_whichOne = 0;
						for "_i" from 0 to (count _wipBuildings) do {
							if (!((_wipBuildings select _i) getVariable "ow_build_ready") && !((_wipBuildings select _i) getVariable "ow_build_deconstruct") && !_isAnyWIP) then {
								_isAnyWIP = true;
								_whichOne = _i;
							};
						};
						if (_isAnyWIP) then {
							[_owman] doMove (getPos (_wipBuildings select _whichOne));
						};
					};
				};
			};

			case 1: {
				// worker
				_jobWIP = false;

				if (((_owman getVariable "ow_aitype") == 1) && !_jobWIP) then {
					// [ACTIVE] can help with construction/deconstruction (move closer to constr. site) - attractor: !ready within radius
					if (!_jobWIP) then {
						_wipBuildings = nearestObjects [_owman, ["owr_base0c_ar", "owr_base1c_ar", "owr_base6c_ar"], 15];
						if ((count _wipBuildings) > 0) then {
							_isAnyWIP = false;
							_whichOne = 0;
							for "_i" from 0 to (count _wipBuildings) do {
								if ((!((_wipBuildings select _i) getVariable "ow_build_ready") || ((_wipBuildings select _i) getVariable "ow_build_deconstruct")) && !_isAnyWIP) then {
									_isAnyWIP = true;
									_whichOne = _i;
								};
							};
							if (_isAnyWIP) then {
								[_owman] doMove (getPos (_wipBuildings select _whichOne));
								_jobWIP = true;
							};
						};
					};

					// [ACTIVE] can repair damaged building (by moving closer to building area) - attractor: damage > 0 within radius
					if (!_jobWIP) then {
						_nearestBuildingsToRepair = nearestObjects [getPos _owman, ["owr_base0c_ar", "owr_base1c_ar", "owr_base6c_ar"], 15];
						if ((count _nearestBuildingsToRepair) > 0) then {
							_i = 0;
							_indexOfDamagedBuilding = 0;
							for "_i" from 0 to ((count _nearestBuildingsToRepair) - 1) do {
								if (((damage (_nearestBuildingsToRepair select _i)) > 0.05) && ((damage (_nearestBuildingsToRepair select _i)) < 1.0) && (!_jobWIP)) then {
									_jobWIP = true;
									_indexOfDamagedBuilding = _i;
								};
							};
							if (_jobWIP) then {
								_buildingToRepair = (_nearestBuildingsToRepair select _indexOfDamagedBuilding);

								[_owman] doMove (getPos _buildingToRepair);

								if ((_owman distance _buildingToRepair) < 10) then {
									// remove some damage - based on skill + increase skill
									_owman_skill = (_owman getVariable "ow_skill_worker");
									// todo: could take a building complexity from the cfg in future
									_repairContr = ((1.0 / (2.0 * 2.0 * 2.0)) / 10.0) + (_owman_skill / 1000.0);
									// increase worker skill of _owman if not maxed out
									if (_owman_skill < 10.0) then {
										_owman setVariable ["ow_skill_worker", _owman_skill + ([(2.0 / 3.0), _owman_skill] call owr_fn_makeExpProgress), true];
									};
									_buildingToRepair setDamage ((damage _buildingToRepair) - _repairContr);
								};
							};
						};
					};

					// [ACTIVE] picking up crates, storing them in nearest warehouse
					if (!_jobWIP) then {
						// [ACTIVE] can carry crates automatically to closests warehouse - attractor: crate object within radius
						_hasEmptyBpck = backpack _owman;
						if (_hasEmptyBpck == "owr_backpack_crate_empty") then {
							// can take crates
							if (isNull _cratesToGoBack) then {
								_crates = nearestObjects [_owman, ["owr_crates_pile_1","owr_crates_pile_2","owr_crates_pile_3","owr_crates_pile_4","owr_crates_pile_5"], 15];
								if ((count _crates) > 0) then {
									// crates found
									[_owman] doMove (getPos (_crates select 0));
									_cratesToGoBack = (_crates select 0);
								};
							} else {
								// actively search for other crates in vicinity of worker
								_crates = nearestObjects [_owman, ["owr_crates_pile_1","owr_crates_pile_2","owr_crates_pile_3","owr_crates_pile_4","owr_crates_pile_5"], 15];
								if ((count _crates) > 0) then {
									_cratesToGoBack = (_crates select 0);
								};
								if ((_cratesToGoBack distance _owman) <= 15) then {
									[_owman] doMove (getPos _cratesToGoBack);
								};
							};
							//hintSilent format ["%1", (_cratesToGoBack distance _owman)];
							if ((_cratesToGoBack distance _owman) < 5) then {
								removeBackpackGlobal _owman;
								_owman addBackpackGlobal "owr_backpack_crate_full";
								if (!(isNull _cratesToGoBack)) then {
									_crateCnt = _cratesToGoBack getVariable "owr_crate_amount";
									_cratesToGoBack setVariable ["owr_crate_amount", _crateCnt - 1, true];
									switch (_crateCnt) do {
										case 5: {
											_cratesToGoBack animate ["hide_c1", 1, true];
										};
										case 4: {
											_cratesToGoBack animate ["hide_c2", 1, true];
										};
										case 3: {
											_cratesToGoBack animate ["hide_c3", 1, true];
										};
										case 2: {
											_cratesToGoBack animate ["hide_c4", 1, true];
										};
										case 1: {
											if (!(isNull _cratesToGoBack)) then {
												deleteVehicle _cratesToGoBack;
											};
										};
									};
								};
							};
						} else {
							if (_hasEmptyBpck == "owr_backpack_crate_full") then {
								// find closest warehouse to store crates
								_warehousesAround = _owman nearEntities [["warehouse_ar"], 100];
								if ((count _warehousesAround) > 0) then {
									// warehouse found
									[_owman] doMove (getPos (_warehousesAround select 0));
									if (((_warehousesAround select 0) distance _owman) < 15) then {
										_owman assignAsCargo (_warehousesAround select 0);
										[_owman] orderGetIn true;
									};
								};
								//hintSilent format ["%1", ((_warehousesAround select 0) distance _owman)];
								/*if (((_warehousesAround select 0) distance _owman) < 8) then {
									removeBackpackGlobal _owman;
									_owman addBackpackGlobal "owr_backpack_crate_empty";
								};*/
								if ((vehicle _owman) == (_warehousesAround select 0)) then {
									removeBackpackGlobal _owman;
									_owman addBackpackGlobal "owr_backpack_crate_empty";

									_cratesInWrhs = (_warehousesAround select 0) getVariable "ow_wrhs_crates";
									(_warehousesAround select 0) setVariable ["ow_wrhs_crates", _cratesInWrhs + 10, true];

									unassignVehicle _owman;
								};
							};
						};
					};
				};
				if (((_owman getVariable "ow_aitype") == 0) && !_jobWIP) then {
					// [PASSIVE] 
					_cratesToGoBack = objNull;
					_hasEmptyBpck = backpack _owman;
					if (_hasEmptyBpck == "owr_backpack_crate_empty") then {
						// can take crates Box_East_AmmoOrd_F
						_crates = nearestObjects [_owman, ["owr_crates_pile_1","owr_crates_pile_2","owr_crates_pile_3","owr_crates_pile_4","owr_crates_pile_5"], 5];
						if ((count _crates) > 0) then {
							// crates found, pick them up
							removeBackpackGlobal _owman;
							_owman addBackpackGlobal "owr_backpack_crate_full";
							_crateCnt = (_crates select 0) getVariable "owr_crate_amount";
							(_crates select 0) setVariable ["owr_crate_amount", _crateCnt - 1, true];
							switch (_crateCnt) do {
								case 5: {
									(_crates select 0) animate ["hide_c1", 1, true];
								};
								case 4: {
									(_crates select 0) animate ["hide_c2", 1, true];
								};
								case 3: {
									(_crates select 0) animate ["hide_c3", 1, true];
								};
								case 2: {
									(_crates select 0) animate ["hide_c4", 1, true];
								};
								case 1: {
									if (!(isNull (_crates select 0))) then {
										deleteVehicle (_crates select 0);
									};
								};
							};
						};
					} else {
						if (_hasEmptyBpck == "owr_backpack_crate_full") then {
							// find closest warehouse to store crates
							_warehousesAround = nearestObjects [_owman, ["warehouse_ar"], 8];
							if ((count _warehousesAround) > 0) then {
								_owman assignAsCargo (_warehousesAround select 0);
								[_owman] orderGetIn true;
							};
							if ((vehicle _owman) == (_warehousesAround select 0)) then {
								removeBackpackGlobal _owman;
								_owman addBackpackGlobal "owr_backpack_crate_empty";

								_cratesInWrhs = (_warehousesAround select 0) getVariable "ow_wrhs_crates";
								(_warehousesAround select 0) setVariable ["ow_wrhs_crates", _cratesInWrhs + 10, true];

								unassignVehicle _owman;
							};
						};
					};
				};
			};

			case 2: {
				// mechanic
				_jobWIP = false;

				if ((vehicle _owman) != _owman) then {
					_jobWIP = true;
				};

				// [ACTIVE/PASSIVE] can repair damaged vehicles - attractor: damage > 0
				if (((_owman getVariable "ow_aitype") == 1) && !_jobWIP) then {
					_nearestVehiclesToRepair = nearestObjects [getPos _owman, ["owr_car_ar"], 10];
					if ((count _nearestVehiclesToRepair) > 0) then {
						_i = 0;
						_indexOfBrokenVehicle = 0;
						for "_i" from 0 to ((count _nearestVehiclesToRepair) - 1) do {
							if (((damage (_nearestVehiclesToRepair select _i)) > 0.05) && ((damage (_nearestVehiclesToRepair select _i)) < 1.0) && (!_jobWIP)) then {
								_jobWIP = true;
								_indexOfBrokenVehicle = _i;
							};
						};
						if (_jobWIP) then {
							_vehicleToRepair = (_nearestVehiclesToRepair select _indexOfBrokenVehicle);
							[_owman] doMove (getPos _vehicleToRepair);

							// remove some damage - based on skill + increase skill
							_owman_skill = (_owman getVariable "ow_skill_mechanic");
							_vehicleComplx = getNumber (configFile >> "CfgVehicles" >> (typeOf _vehicleToRepair) >> "mComplx");
							_repairContr = ((1.0 / (_vehicleComplx * _vehicleComplx * _vehicleComplx)) / 100.0) + (_owman_skill / 100.0);
							// increase mechanic skill of _owman if not maxed out
							if (_owman_skill < 10.0) then {
								_owman setVariable ["ow_skill_mechanic", _owman_skill + ([(2.0 / 3.0), _owman_skill] call owr_fn_makeExpProgress), true];
							};
							_vehicleToRepair setDamage ((damage _vehicleToRepair) - _repairContr);
						};
					};
				};

				if (((_owman getVariable "ow_aitype") == 1) && (!_jobWIP)) then {
					// [ACTIVE] can help with construction (move closer to constr. site) - attractor: !ready within radius
					_wipBuildings = nearestObjects [_owman, ["owr_base0c_ar", "owr_base1c_ar", "owr_base6c_ar"], 15];
					if ((count _wipBuildings) > 0) then {
						_isAnyWIP = false;
						_whichOne = 0;
						for "_i" from 0 to (count _wipBuildings) do {
							if (!((_wipBuildings select _i) getVariable "ow_build_ready") && !((_wipBuildings select _i) getVariable "ow_build_deconstruct") && !_isAnyWIP) then {
								_isAnyWIP = true;
								_whichOne = _i;
							};
						};
						if (_isAnyWIP) then {
							[_owman] doMove (getPos (_wipBuildings select _whichOne));
						};
					};
				};
			};
			case 3: {
				// scientist
				_jobWIP = false;

				if ((vehicle _owman) != _owman) then {
					_jobWIP = true;
				};

				if (((_owman getVariable "ow_aitype") == 1) && !_jobWIP) then {
					// [ACTIVE] can help with construction (move closer to constr. site) - attractor: !ready within radius
					_wipBuildings = nearestObjects [_owman, ["owr_base0c_ar", "owr_base1c_ar", "owr_base6c_ar"], 15];
					if ((count _wipBuildings) > 0) then {
						_isAnyWIP = false;
						_whichOne = 0;
						for "_i" from 0 to (count _wipBuildings) do {
							if (!((_wipBuildings select _i) getVariable "ow_build_ready") && !((_wipBuildings select _i) getVariable "ow_build_deconstruct") && !_isAnyWIP) then {
								_isAnyWIP = true;
								_whichOne = _i;
							};
						};
						if (_isAnyWIP) then {
							[_owman] doMove (getPos (_wipBuildings select _whichOne));
						};
					};
				};
			};
			default {};
		};

		// "fog of war" test
		//_enemyAround = nearestObjects [_owman, ["owr_man_ru"], 15];
		//_owman setVariable ["ow_enemies_around", _enemyAround, true];

		// level/up checker
		if ((floor (_owman getVariable "ow_skill_soldier")) != _lastLvl1) then {
			// level-up as soldier
			_lastLvl1 = (floor (_owman getVariable "ow_skill_soldier"));
			[(_owman), "Combat experience increased", format ["Level up %1", (floor (_owman getVariable "ow_skill_soldier"))], mapGridPosition (getPos _owman)] remoteExec ["owr_fn_message", bis_curator_arab];
		};
		if ((floor (_owman getVariable "ow_skill_worker")) != _lastLvl2) then {
			// level-up as worker
			_lastLvl2 = (floor (_owman getVariable "ow_skill_worker"));
			[(_owman), "Worker experience increased", format ["Level up %1", (floor (_owman getVariable "ow_skill_worker"))], mapGridPosition (getPos _owman)] remoteExec ["owr_fn_message", bis_curator_arab];
		};
		if ((floor (_owman getVariable "ow_skill_mechanic")) != _lastLvl3) then {
			// level-up as mechanic
			_lastLvl3 = (floor (_owman getVariable "ow_skill_mechanic"));
			[(_owman), "Mechanic experience increased", format ["Level up %1", (floor (_owman getVariable "ow_skill_mechanic"))], mapGridPosition (getPos _owman)] remoteExec ["owr_fn_message", bis_curator_arab];
		};
		if ((floor (_owman getVariable "ow_skill_scientist")) != _lastLvl4) then {
			// level-up as scientist
			_lastLvl4 = (floor (_owman getVariable "ow_skill_scientist"));
			[(_owman), "Scientific knowledge increased", format ["Level up %1", (floor (_owman getVariable "ow_skill_scientist"))], mapGridPosition (getPos _owman)] remoteExec ["owr_fn_message", bis_curator_arab];
		};
		sleep 2.5;
	};
};
owr_fn_assignClassGear = {
	_owman = _this select 0;
	_targetClass = _this select 1;
	_side = _this select 2;

	switch (_targetClass) do {
		case 0: {
			// CHANGE TO SOLDIER
			switch (_side) do {
				case "am": {
					// AM soldier loadout
					removeAllWeapons _owman;
					removeAllItems _owman;
					removeAllAssignedItems _owman;
					removeUniform _owman;
					removeVest _owman;
					removeBackpackGlobal _owman;
					removeHeadgear _owman;
					removeGoggles _owman;

					_owman forceAddUniform "U_B_CTRG_1";
					_owman addItemToUniform "FirstAidKit";
					_owman addVest "V_Chestrig_blk";
					for "_i" from 1 to 5 do {_owman addItemToVest "20Rnd_762x51_Mag";};
					for "_i" from 1 to 4 do {_owman addItemToVest "SmokeShellBlue";};
					for "_i" from 1 to 5 do {_owman addItemToVest "HandGrenade";};
					for "_i" from 1 to 5 do {_owman addItemToVest "Chemlight_blue";};
					_owman addBackpackGlobal "B_ViperLightHarness_blk_F";
					for "_i" from 1 to 2 do {_owman addItemToBackpack "FirstAidKit";};
					for "_i" from 1 to 5 do {_owman addItemToBackpack "20Rnd_762x51_Mag";};
					for "_i" from 1 to 5 do {_owman addItemToBackpack "Chemlight_blue";};
					for "_i" from 1 to 5 do {_owman addItemToBackpack "HandGrenade";};
					for "_i" from 1 to 5 do {_owman addItemToBackpack "SmokeShellBlue";};
					_owman addHeadgear "H_HelmetB_light";
					_owman addGoggles "G_Bandanna_blk";

					_owman addWeaponGlobal "arifle_SPAR_03_blk_F";
					_owman addPrimaryWeaponItem "acc_flashlight";
					_owman addPrimaryWeaponItem "optic_AMS";
					_owman addPrimaryWeaponItem "bipod_01_F_blk";
					_owman addWeaponGlobal "Rangefinder";

					_owman linkItem "ItemMap";
					_owman linkItem "ItemCompass";
					_owman linkItem "ItemWatch";
					_owman linkItem "ItemRadio";
					_owman linkItem "NVGoggles_OPFOR";
				};
				case "ru": {
					// RU soldier loadout
					removeAllWeapons _owman;
					removeAllItems _owman;
					removeAllAssignedItems _owman;
					removeUniform _owman;
					removeVest _owman;
					removeBackpackGlobal _owman;
					removeHeadgear _owman;
					removeGoggles _owman;

					_owman forceAddUniform "U_B_T_Soldier_SL_F";
					_owman addItemToUniform "FirstAidKit";
					_owman addItemToUniform "30Rnd_762x39_Mag_F";
					_owman addVest "V_HarnessOGL_ghex_F";
					for "_i" from 1 to 5 do {_owman addItemToVest "HandGrenade";};
					for "_i" from 1 to 3 do {_owman addItemToVest "SmokeShellRed";};
					for "_i" from 1 to 5 do {_owman addItemToVest "30Rnd_762x39_Mag_F";};
					for "_i" from 1 to 2 do {_owman addItemToVest "Chemlight_red";};
					_owman addBackpackGlobal "B_ViperLightHarness_oli_F";
					for "_i" from 1 to 2 do {_owman addItemToBackpack "FirstAidKit";};
					for "_i" from 1 to 5 do {_owman addItemToBackpack "30Rnd_762x39_Mag_F";};
					for "_i" from 1 to 5 do {_owman addItemToBackpack "SmokeShellRed";};
					for "_i" from 1 to 5 do {_owman addItemToBackpack "HandGrenade";};
					for "_i" from 1 to 5 do {_owman addItemToBackpack "Chemlight_red";};
					_owman addHeadgear "H_HelmetB_light_black";
					_owman addGoggles "G_Bandanna_oli";

					_owman addWeaponGlobal "arifle_AK12_F";
					_owman addPrimaryWeaponItem "acc_flashlight";
					_owman addPrimaryWeaponItem "optic_SOS";
					_owman addPrimaryWeaponItem "bipod_01_F_blk";
					_owman addWeaponGlobal "Rangefinder";

					_owman linkItem "ItemMap";
					_owman linkItem "ItemCompass";
					_owman linkItem "ItemWatch";
					_owman linkItem "ItemRadio";
					_owman linkItem "NVGoggles_OPFOR";
				};
				case "ar": {
					// AR soldier loadout
					removeAllWeapons _owman;
					removeAllItems _owman;
					removeAllAssignedItems _owman;
					removeUniform _owman;
					removeVest _owman;
					removeBackpackGlobal _owman;
					removeHeadgear _owman;
					removeGoggles _owman;

					_owman forceAddUniform "U_O_SpecopsUniform_ocamo";
					_owman addItemToUniform "FirstAidKit";
					_owman addVest "V_HarnessO_brn";
					for "_i" from 1 to 5 do {_owman addItemToVest "30Rnd_556x45_Stanag";};
					for "_i" from 1 to 5 do {_owman addItemToVest "HandGrenade";};
					for "_i" from 1 to 5 do {_owman addItemToVest "Chemlight_yellow";};
					for "_i" from 1 to 5 do {_owman addItemToVest "SmokeShellYellow";};
					_owman addBackpackGlobal "B_Kitbag_cbr";
					for "_i" from 1 to 2 do {_owman addItemToBackpack "FirstAidKit";};
					for "_i" from 1 to 5 do {_owman addItemToBackpack "30Rnd_556x45_Stanag";};
					for "_i" from 1 to 5 do {_owman addItemToBackpack "SmokeShellYellow";};
					for "_i" from 1 to 5 do {_owman addItemToBackpack "HandGrenade";};
					for "_i" from 1 to 5 do {_owman addItemToBackpack "Chemlight_yellow";};
					_owman addHeadgear "H_HelmetB_desert";
					_owman addGoggles "G_Bandanna_tan";

					_owman addWeaponGlobal "arifle_SPAR_01_snd_F";
					_owman addPrimaryWeaponItem "muzzle_snds_m_snd_F";
					_owman addPrimaryWeaponItem "acc_flashlight";
					_owman addPrimaryWeaponItem "optic_ERCO_snd_F";
					_owman addPrimaryWeaponItem "bipod_01_F_snd";
					_owman addWeaponGlobal "Rangefinder";

					_owman linkItem "ItemMap";
					_owman linkItem "ItemCompass";
					_owman linkItem "ItemWatch";
					_owman linkItem "ItemRadio";
					_owman linkItem "NVGoggles";
				};
			};
		};
		case 1: {
			// CHANGE TO WORKER
			switch (_side) do {
				case "am": {
					// AM worker loadout
					removeAllWeapons _owman;
					removeAllItems _owman;
					removeAllAssignedItems _owman;
					removeUniform _owman;
					removeVest _owman;
					removeBackpackGlobal _owman;
					removeHeadgear _owman;
					removeGoggles _owman;

					_owman forceAddUniform "U_C_WorkerCoveralls";
					_owman addItemToUniform "FirstAidKit";
					_owman addBackpackGlobal "owr_backpack_crate_empty";
					_owman addHeadgear "H_Watchcap_cbr";

					_owman linkItem "ItemMap";
					_owman linkItem "ItemCompass";
					_owman linkItem "ItemWatch";
					_owman linkItem "ItemRadio";
				};
				case "ru": {
					// RU worker loadout
					removeAllWeapons _owman;
					removeAllItems _owman;
					removeAllAssignedItems _owman;
					removeUniform _owman;
					removeVest _owman;
					removeBackpackGlobal _owman;
					removeHeadgear _owman;
					removeGoggles _owman;

					_owman forceAddUniform "U_C_WorkerCoveralls";
					_owman addItemToUniform "FirstAidKit";
					_owman addBackpackGlobal "owr_backpack_crate_empty";
					_owman addHeadgear "H_Watchcap_cbr";

					_owman linkItem "ItemMap";
					_owman linkItem "ItemCompass";
					_owman linkItem "ItemWatch";
					_owman linkItem "ItemRadio";
				};
				case "ar": {
					// AR worker loadout
					removeAllWeapons _owman;
					removeAllItems _owman;
					removeAllAssignedItems _owman;
					removeUniform _owman;
					removeVest _owman;
					removeBackpackGlobal _owman;
					removeHeadgear _owman;
					removeGoggles _owman;

					_owman forceAddUniform "U_C_WorkerCoveralls";
					_owman addItemToUniform "FirstAidKit";
					_owman addBackpackGlobal "owr_backpack_crate_empty";
					_owman addHeadgear "H_Watchcap_cbr";

					_owman linkItem "ItemMap";
					_owman linkItem "ItemCompass";
					_owman linkItem "ItemWatch";
					_owman linkItem "ItemRadio";
				};
			};
		};
		case 2: {
			// CHANGE TO MECHANIC
			switch (_side) do {
				case "am": {
					// AM mechanic loadout
					removeAllWeapons _owman;
					removeAllItems _owman;
					removeAllAssignedItems _owman;
					removeUniform _owman;
					removeVest _owman;
					removeBackpackGlobal _owman;
					removeHeadgear _owman;
					removeGoggles _owman;

					_owman forceAddUniform "U_B_HeliPilotCoveralls";
					for "_i" from 1 to 2 do {_owman addItemToUniform "FirstAidKit";};
					for "_i" from 1 to 2 do {_owman addItemToUniform "16Rnd_9x21_Mag";};
					_owman addVest "V_TacVest_oli";
					for "_i" from 1 to 2 do {_owman addItemToVest "FirstAidKit";};
					for "_i" from 1 to 5 do {_owman addItemToVest "16Rnd_9x21_Mag";};
					_owman addHeadgear "H_Cap_headphones";

					_owman addWeaponGlobal "hgun_P07_khk_F";

					_owman linkItem "NVGoggles_OPFOR";

					_owman linkItem "ItemMap";
					_owman linkItem "ItemCompass";
					_owman linkItem "ItemWatch";
					_owman linkItem "ItemRadio";
				};
				case "ru": {
					// RU mechanic loadout
					removeAllWeapons _owman;
					removeAllItems _owman;
					removeAllAssignedItems _owman;
					removeUniform _owman;
					removeVest _owman;
					removeBackpackGlobal _owman;
					removeHeadgear _owman;
					removeGoggles _owman;

					_owman forceAddUniform "U_B_HeliPilotCoveralls";
					for "_i" from 1 to 2 do {_owman addItemToUniform "FirstAidKit";};
					for "_i" from 1 to 2 do {_owman addItemToUniform "16Rnd_9x21_Mag";};
					_owman addVest "V_TacVest_oli";
					for "_i" from 1 to 2 do {_owman addItemToVest "FirstAidKit";};
					for "_i" from 1 to 5 do {_owman addItemToVest "16Rnd_9x21_Mag";};
					_owman addHeadgear "H_Cap_headphones";

					_owman addWeaponGlobal "hgun_P07_khk_F";

					_owman linkItem "NVGoggles_OPFOR";

					_owman linkItem "ItemMap";
					_owman linkItem "ItemCompass";
					_owman linkItem "ItemWatch";
					_owman linkItem "ItemRadio";
				};
				case "ar": {
					// AR mechanic loadout
					removeAllWeapons _owman;
					removeAllItems _owman;
					removeAllAssignedItems _owman;
					removeUniform _owman;
					removeVest _owman;
					removeBackpackGlobal _owman;
					removeHeadgear _owman;
					removeGoggles _owman;

					_owman forceAddUniform "U_B_HeliPilotCoveralls";
					for "_i" from 1 to 2 do {_owman addItemToUniform "FirstAidKit";};
					for "_i" from 1 to 2 do {_owman addItemToUniform "16Rnd_9x21_Mag";};
					_owman addVest "V_TacVest_oli";
					for "_i" from 1 to 2 do {_owman addItemToVest "FirstAidKit";};
					for "_i" from 1 to 5 do {_owman addItemToVest "16Rnd_9x21_Mag";};
					_owman addHeadgear "H_Cap_headphones";

					_owman addWeaponGlobal "hgun_P07_khk_F";

					_owman linkItem "NVGoggles_OPFOR";

					_owman linkItem "ItemMap";
					_owman linkItem "ItemCompass";
					_owman linkItem "ItemWatch";
					_owman linkItem "ItemRadio";
				};
			};
		};
		case 3: {
			// CHANGE TO SCIENTIST
			switch (_side) do {
				case "am": {
					// AM scientist loadout
					removeAllWeapons _owman;
					removeAllItems _owman;
					removeAllAssignedItems _owman;
					removeUniform _owman;
					removeVest _owman;
					removeBackpackGlobal _owman;
					removeHeadgear _owman;
					removeGoggles _owman;

					_owman forceAddUniform "U_C_Scientist";
					_owman addItemToUniform "FirstAidKit";
					_owman addItemToUniform "FirstAidKit";
					_owman addGoggles "G_Tactical_Clear";

					_owman linkItem "ItemMap";
					_owman linkItem "ItemCompass";
					_owman linkItem "ItemWatch";
					_owman linkItem "ItemRadio";
				};
				case "ru": {
					// RU scientist loadout
					removeAllWeapons _owman;
					removeAllItems _owman;
					removeAllAssignedItems _owman;
					removeUniform _owman;
					removeVest _owman;
					removeBackpack _owman;
					removeHeadgear _owman;
					removeGoggles _owman;

					_owman forceAddUniform "U_C_Scientist";
					_owman addItemToUniform "FirstAidKit";
					_owman addItemToUniform "FirstAidKit";
					_owman addGoggles "G_Tactical_Clear";

					_owman linkItem "ItemMap";
					_owman linkItem "ItemCompass";
					_owman linkItem "ItemWatch";
					_owman linkItem "ItemRadio";
				};
				case "ar": {
					// AR scientist loadout
					removeAllWeapons _owman;
					removeAllItems _owman;
					removeAllAssignedItems _owman;
					removeUniform _owman;
					removeVest _owman;
					removeBackpackGlobal _owman;
					removeHeadgear _owman;
					removeGoggles _owman;

					_owman forceAddUniform "U_C_Scientist";
					_owman addItemToUniform "FirstAidKit";
					_owman addItemToUniform "FirstAidKit";
					_owman addGoggles "G_Tactical_Clear";

					_owman linkItem "ItemMap";
					_owman linkItem "ItemCompass";
					_owman linkItem "ItemWatch";
					_owman linkItem "ItemRadio";
				};
			};
		};
	};
};
owr_fn_makeBuildProgress = {
	_complexity = _this select 0;
	_skill = _this select 1;

	_progress = (((1 / (_complexity * _complexity))) / 25.0) + ((_skill / 100.0) / 750.0);

	//hintSilent format ["%1\n%2\n\n%3\n\n%4", (((1 / (_complexity * _complexity))) / 25.0), ((_skill / 100.0) / 750.0), _complexity, _skill];

	if (owr_devhax) then {
		_progress = 0.1;
	};

	_progress
};
owr_fn_makeResProgress = {
	_complexity = _this select 0;
	_skill = _this select 1;

	_progress = (((1 / (_complexity * _complexity)) / 100.0) / 25.0) + ((_skill / 100.0) / 750.0);

	// res cmplx 4
	// scientist lvl 4
	// 0.00025 + 0.000053

	// 6x level 1, complx 4      0.000025    0.0000133   => 0.0000383  - 2610 sec
	// 6x level 5, complx 4      0.000025    0.0000666   => 0.0000916  - 1091 sec
	// 

	if (owr_devhax) then {
		_progress = 0.1;
	};

	//hintSilent format ["%1\n%2\n\n%3\n\n%4", (((1 / (_complexity * _complexity)) / 100.0) / 25.0), ((_skill / 100.0) / 750.0), _complexity, _skill];

	_progress
};
owr_fn_makeManProgress = {
	_complexity = (_this select 0) + 0.1;
	_skill = _this select 1;

	_progress = (((1 / (_complexity * _complexity)) / 4.5) / 25.0) + ((_skill / 100.0) / 150.0);

	// 0.00016 + 0.000066
	//  0.00128

	// 5,5 - 0.000226667
	//       0.000270857
	//       0.000220906
	//       0.000433766 

	if (owr_devhax) then {
		_progress = 0.1;
	};

	//hintSilent format ["%1\n%2\n\n%3\n\n%4", (((1 / (_complexity * _complexity)) / 10.0) / 25.0), ((_skill / 100.0) / 750.0), _complexity, _skill];

	_progress
};
owr_fn_makeExpProgress = {
	_complexity = _this select 0;
	_skill = _this select 1;

	_skill = ((_complexity) / 75000.0) + ((_complexity) / (_skill * 10000));

	// this script is caled every 0.1 for each personnel - if they are manufacturing / building / researching
	// the higher level, the lower gain should be
	// the more complex thing, the higher gain should be

	if (owr_devhax) then {
		_skill = 0.1;
	};

	_skill
};

//////////////////////////////////////////////////////////////////////////////////////////////
// VARIABLE INIT
//////////////////////////////////////////////////////////////////////////////////////////////

// WEST - AM side, adding characters
owr_am_characters = [am01,am02,am03,am04,am05,am06];
{
	_majorPref = getNumber (missionConfigFile >> "CfgIdentities" >> format["ow_%1", _x] >> "prefMajor");
	_minorPref = getNumber (missionConfigFile >> "CfgIdentities" >> format["ow_%1", _x] >> "prefMinor");
	_x allowFleeing 0;
	_x disableAI "FSM";
	_x disableAI "SUPPRESSION";
	_x disableAI "AIMINGERROR";
	_x disableAI "COVER";
	_x setVariable ["ow_class", _majorPref, true];
	_x setVariable ["ow_ctype", false, true];
	_x setVariable ["ow_aitype", 1, true];
	_x setVariable ["ow_worker_buildmode", 0, true];
	_x setVariable ["ow_skill_soldier", random [0.01, 2, 4.0], true];
	_x setVariable ["ow_skill_worker", random [0.01, 2, 4.0], true];
	_x setVariable ["ow_skill_mechanic", random [0.01, 2, 4.0], true];
	_x setVariable ["ow_skill_scientist", random [0.01, 2, 4.0], true];
	switch (_majorPref) do {
		case 0: {
			_x setVariable ["ow_skill_soldier", random [4.0, 5, 6.0], true];
		};
		case 1: {
			_x setVariable ["ow_skill_worker", random [4.0, 5, 6.0], true];
		};
		case 2: {
			_x setVariable ["ow_skill_mechanic", random [4.0, 5, 6.0], true];
		};
		case 3: {
			_x setVariable ["ow_skill_scientist", random [4.0, 5, 6.0], true];
		};
	};
	switch (_minorPref) do {
		case 0: {
			_x setVariable ["ow_skill_soldier", random [2.0, 3, 4.0], true];
		};
		case 1: {
			_x setVariable ["ow_skill_worker", random [2.0, 3, 4.0], true];
		};
		case 2: {
			_x setVariable ["ow_skill_mechanic", random [2.0, 3, 4.0], true];
		};
		case 3: {
			_x setVariable ["ow_skill_scientist", random [2.0, 3, 4.0], true];
		};
	};
	bis_curator_west addCuratorEditableObjects [[_x], false];
	[_x] spawn owr_fn_owman_am_ai;
	if (local _x) then {
		[_x, _x getVariable "ow_class", "am"] call owr_fn_assignClassGear;
		_damageIgnoreSet = _x addEventHandler ["GetInMan", {[(_this select 0), false] remoteExec ["allowDamage", 0];}];
		_damageIgnoreOff = _x addEventHandler ["GetOutMan", {[(_this select 0), true] remoteExec ["allowDamage", 0];}];
		_x addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 12;

			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	} else {
		//[_x, [_x, _x getVariable "ow_class", "am"]] remoteExec ["owr_fn_assignClassGear", 0];	// done in init.sqf
		[_x, ["GetOutMan", {[(_this select 0), true] remoteExec ["allowDamage", 0];}]] remoteExec ["addEventHandler", 0];
		[_x, ["GetInMan", {[(_this select 0), false] remoteExec ["allowDamage", 0];}]] remoteExec ["addEventHandler", 0];
		[_x, ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 12;

			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}]] remoteExec ["addEventHandler", 0];
	};
} foreach owr_am_characters;
removeAllCuratorEditingAreas bis_curator_west;
bis_curator_west addCuratorEditingArea [5, [10,10,1000], 0.1];

bis_curator_west setVariable ["ow_am_res_basic_dep", [[],[0],[0,1],[],[3],[],[],[6],[],[8],[8]], true];
bis_curator_west setVariable ["ow_am_res_basic_comp", [3.0, 4.0, 5.0, 1.25, 1.5, 1.25, 1.35, 1.60, 1.5, 1.75, 1.75], true];
bis_curator_west setVariable ["ow_am_res_basic_prog", [0,0,0,0,0,0,0,0,0,0,0], true];
bis_curator_west setVariable ["ow_am_res_basic_strings", ["Base tech I","Base tech II","Base tech III","Oil utilization","Combustion engine","Siberite detection","Solar power","Electric motor","Ape language","Ape psychology","Ape aggression"], true];

bis_curator_west setVariable ["ow_am_res_weap_dep", [[],[1],[0,1],[],[],[1,4],[2,4]], true];
bis_curator_west setVariable ["ow_am_res_weap_comp", [5.0, 6.0, 7.0, 4.5, 5.5, 6.5, 7.5], true];
bis_curator_west setVariable ["ow_am_res_weap_prog", [0,0,0,0,0,0,0], true];
bis_curator_west setVariable ["ow_am_res_weap_strings", ["Weapon tech I","Weapon tech II","Weapon tech III","Minigun","Cannon","Vehicle rocket launcher","Cannon improvements"], true];

bis_curator_west setVariable ["ow_am_res_opto_dep", [[],[0],[0,1],[],[3],[3],[3,4],[3],[3,7]], true];
bis_curator_west setVariable ["ow_am_res_opto_comp", [5.0, 6.0, 7.0, 4.5, 4.5, 3.5, 6.5, 5.5, 7.5], true];
bis_curator_west setVariable ["ow_am_res_opto_prog", [0,0,0,0,0,0,0,0,0], true];
bis_curator_west setVariable ["ow_am_res_opto_strings", ["Opto tech I","Opto tech II","Opto tech III","Radar","Remote control","Materialization detection","Partial invisibility","Laser","Synchronized laser"], true];

bis_curator_west setVariable ["ow_am_res_siberite_dep", [[],[0],[0,1],[],[3]], true];
bis_curator_west setVariable ["ow_am_res_siberite_comp", [5.0, 6.0, 7.0, 3.75, 4.25], true];
bis_curator_west setVariable ["ow_am_res_siberite_prog", [0,0,0,0,0], true];
bis_curator_west setVariable ["ow_am_res_siberite_strings", ["Siberite tech I","Siberite tech II","Siberite tech III","Siberite energy","Siberite motor"], true];

bis_curator_west setVariable ["ow_am_res_comp_dep", [[],[1],[0,1],[], [3],[3]], true];
bis_curator_west setVariable ["ow_am_res_comp_comp", [5.0, 6.0, 7.0, 2.5, 3.5, 3.5], true];
bis_curator_west setVariable ["ow_am_res_comp_prog", [0,0,0,0,0,0], true];
bis_curator_west setVariable ["ow_am_res_comp_strings", ["Computer tech I","Computer tech II","Computer tech III","Artificial intelligence","Advanced AI","Smart half-track chassis"], true];

// start check - make sure there is at least one worker
_randomCharacter = selectRandom owr_am_characters;
_randomCharacter setVariable ["ow_class", 1, true];
[_randomCharacter, 1, "am"] call owr_fn_assignClassGear;



// ARAB - resistance side, adding characters
owr_ar_characters = [ar01,ar02,ar03,ar04,ar05,ar06];
{
	_majorPref = getNumber (missionConfigFile >> "CfgIdentities" >> format["ow_%1", _x] >> "prefMajor");
	_minorPref = getNumber (missionConfigFile >> "CfgIdentities" >> format["ow_%1", _x] >> "prefMinor");
	_x allowFleeing 0;
	_x disableAI "FSM";
	_x disableAI "SUPPRESSION";
	_x disableAI "AIMINGERROR";
	_x disableAI "COVER";
	_x setVariable ["ow_class", _majorPref, true];
	_x setVariable ["ow_ctype", false, true];
	_x setVariable ["ow_aitype", 1, true];
	_x setVariable ["ow_worker_buildmode", 0, true];
	_x setVariable ["ow_skill_soldier", random [0.01, 2, 4.0], true];
	_x setVariable ["ow_skill_worker", random [0.01, 2, 4.0], true];
	_x setVariable ["ow_skill_mechanic", random [0.01, 2, 4.0], true];
	_x setVariable ["ow_skill_scientist", random [0.01, 2, 4.0], true];
	switch (_majorPref) do {
		case 0: {
			_x setVariable ["ow_skill_soldier", random [4.0, 5, 6.0], true];
		};
		case 1: {
			_x setVariable ["ow_skill_worker", random [4.0, 5, 6.0], true];
		};
		case 2: {
			_x setVariable ["ow_skill_mechanic", random [4.0, 5, 6.0], true];
		};
		case 3: {
			_x setVariable ["ow_skill_scientist", random [4.0, 5, 6.0], true];
		};
	};
	switch (_minorPref) do {
		case 0: {
			_x setVariable ["ow_skill_soldier", random [2.0, 3, 4.0], true];
		};
		case 1: {
			_x setVariable ["ow_skill_worker", random [2.0, 3, 4.0], true];
		};
		case 2: {
			_x setVariable ["ow_skill_mechanic", random [2.0, 3, 4.0], true];
		};
		case 3: {
			_x setVariable ["ow_skill_scientist", random [2.0, 3, 4.0], true];
		};
	};
	bis_curator_arab addCuratorEditableObjects [[_x], false];
	[_x] spawn owr_fn_owman_ar_ai;
	if (local _x) then {
		[_x, _x getVariable "ow_class", "ar"] call owr_fn_assignClassGear;
		_damageIgnoreSet = _x addEventHandler ["GetInMan", {[(_this select 0), false] remoteExec ["allowDamage", 0];}];
		_damageIgnoreOff = _x addEventHandler ["GetOutMan", {[(_this select 0), true] remoteExec ["allowDamage", 0];}];
		_x addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 12;

			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	} else {
		//[_x, [_x, _x getVariable "ow_class", "ar"]] remoteExec ["owr_fn_assignClassGear", 0];	// done in init.sqf
		[_x, ["GetOutMan", {[(_this select 0), true] remoteExec ["allowDamage", 0];}]] remoteExec ["addEventHandler", 0];
		[_x, ["GetInMan", {[(_this select 0), false] remoteExec ["allowDamage", 0];}]] remoteExec ["addEventHandler", 0];
		[_x, ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 12;

			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}]] remoteExec ["addEventHandler", 0];
	};
} foreach owr_ar_characters;
removeAllCuratorEditingAreas bis_curator_arab;
bis_curator_arab addCuratorEditingArea [5, [10,10,1000], 0.1];
/*

RESEARCH PART
put arab research variables here


*/

// start check - make sure there is at least one worker
_randomCharacter = selectRandom owr_ar_characters;
_randomCharacter setVariable ["ow_class", 1, true];
[_randomCharacter, 1, "ar"] call owr_fn_assignClassGear;




// EAST - RU side, adding characters
owr_ru_characters = [ru01,ru02,ru03,ru04,ru05,ru06];
{
	_majorPref = getNumber (missionConfigFile >> "CfgIdentities" >> format["ow_%1", _x] >> "prefMajor");
	_minorPref = getNumber (missionConfigFile >> "CfgIdentities" >> format["ow_%1", _x] >> "prefMinor");
	_x allowFleeing 0;
	_x disableAI "FSM";
	_x disableAI "SUPPRESSION";
	_x disableAI "AIMINGERROR";
	_x disableAI "COVER";
	_x setVariable ["ow_class", _majorPref, true];
	_x setVariable ["ow_ctype", false, true];
	_x setVariable ["ow_aitype", 1, true];
	_x setVariable ["ow_worker_buildmode", 0, true];
	_x setVariable ["ow_skill_soldier", random [0.01, 2, 4.0], true];
	_x setVariable ["ow_skill_worker", random [0.01, 2, 4.0], true];
	_x setVariable ["ow_skill_mechanic", random [0.01, 2, 4.0], true];
	_x setVariable ["ow_skill_scientist", random [0.01, 2, 4.0], true];
	switch (_majorPref) do {
		case 0: {
			_x setVariable ["ow_skill_soldier", random [4.0, 5, 6.0], true];
		};
		case 1: {
			_x setVariable ["ow_skill_worker", random [4.0, 5, 6.0], true];
		};
		case 2: {
			_x setVariable ["ow_skill_mechanic", random [4.0, 5, 6.0], true];
		};
		case 3: {
			_x setVariable ["ow_skill_scientist", random [4.0, 5, 6.0], true];
		};
	};
	switch (_minorPref) do {
		case 0: {
			_x setVariable ["ow_skill_soldier", random [2.0, 3, 4.0], true];
		};
		case 1: {
			_x setVariable ["ow_skill_worker", random [2.0, 3, 4.0], true];
		};
		case 2: {
			_x setVariable ["ow_skill_mechanic", random [2.0, 3, 4.0], true];
		};
		case 3: {
			_x setVariable ["ow_skill_scientist", random [2.0, 3, 4.0], true];
		};
	};
	bis_curator_east addCuratorEditableObjects [[_x], false];
	[_x] spawn owr_fn_owman_ru_ai;
	if (local _x) then {
		[_x, _x getVariable "ow_class", "ru"] call owr_fn_assignClassGear;
		_damageIgnoreSet = _x addEventHandler ["GetInMan", {[(_this select 0), false] remoteExec ["allowDamage", 0];}];
		_damageIgnoreOff = _x addEventHandler ["GetOutMan", {[(_this select 0), true] remoteExec ["allowDamage", 0];}];
		_x addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 12;

			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	} else {
		//[_x, [_x, _x getVariable "ow_class", "ru"]] remoteExec ["owr_fn_assignClassGear", 0];	// done in init.sqf
		[_x, ["GetOutMan", {[(_this select 0), true] remoteExec ["allowDamage", 0];}]] remoteExec ["addEventHandler", 0];
		[_x, ["GetInMan", {[(_this select 0), false] remoteExec ["allowDamage", 0];}]] remoteExec ["addEventHandler", 0];
		[_x, ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 12;

			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}]] remoteExec ["addEventHandler", 0];
	};
} foreach owr_ru_characters;
removeAllCuratorEditingAreas bis_curator_east;
bis_curator_east addCuratorEditingArea [4, [0,0,1000], 0.1];

bis_curator_east setVariable ["ow_ru_res_basic_dep", [[],[0],[0,1],[],[3],[],[],[6],[],[8],[8]], true];
bis_curator_east setVariable ["ow_ru_res_basic_comp", [3.0, 4.0, 5.0, 1.25, 1.5, 1.25, 1.35, 1.60, 1.5, 1.75, 1.75], true];
bis_curator_east setVariable ["ow_ru_res_basic_prog", [0,0,0,0,0,0,0,0,0,0,0], true];
bis_curator_east setVariable ["ow_ru_res_basic_strings", ["Base tech I","Base tech II","Base tech III","Oil utilization","Combustion engine","Alaskite detection","Solar power","Electric motor","Ape language","Ape psychology","Ape aggression"], true];

bis_curator_east setVariable ["ow_ru_res_weap_dep", [[],[1],[0,1],[],[],[1,4],[2,4],[2,5],[2,5,6]], true];
bis_curator_east setVariable ["ow_ru_res_weap_comp", [5.0, 6.0, 7.0, 4.5, 5.5, 6.5, 7.5, 7.5, 8.0], true];
bis_curator_east setVariable ["ow_ru_res_weap_prog", [0,0,0,0,0,0,0,0,0], true];
bis_curator_east setVariable ["ow_ru_res_weap_strings", ["Weapon tech I","Weapon tech II","Weapon tech III","Minigun","Cannon","Vehicle rocket launcher","Cannon improvements","Rocket","Behemoth"], true];

bis_curator_east setVariable ["ow_ru_res_time_dep", [[],[0],[0,1],[],[],[],[5],[4]], true];
bis_curator_east setVariable ["ow_ru_res_time_comp", [5.0, 6.0, 7.0, 4.5, 4.5, 3.5, 6.5, 5.5], true];
bis_curator_east setVariable ["ow_ru_res_time_prog", [0,0,0,0,0,0,0,0,0], true];
bis_curator_east setVariable ["ow_ru_res_time_strings", ["Space-time tech I","Space-time tech II","Space-time tech III","Tau radiation","Space anomalies","Local Tau-field","Homogenic Tau-field","Limited spontaneous teleportation"], true];

bis_curator_east setVariable ["ow_ru_res_siberite_dep", [[],[0],[0,1],[],[3],[]], true];
bis_curator_east setVariable ["ow_ru_res_siberite_comp", [5.0, 6.0, 7.0, 3.75, 4.25, 3.0], true];
bis_curator_east setVariable ["ow_ru_res_siberite_prog", [0,0,0,0,0,0], true];
bis_curator_east setVariable ["ow_ru_res_siberite_strings", ["Alaskite tech I","Alaskite tech II","Alaskite tech III","Alaskite energy","Alaskite motor","Alaskite targeting"], true];

bis_curator_east setVariable ["ow_ru_res_comp_dep", [[],[1],[0,1],[],[3],[4],[3],[4]], true];
bis_curator_east setVariable ["ow_ru_res_comp_comp", [5.0, 6.0, 7.0, 2.5, 3.5, 3.5,3.0,5.0], true];
bis_curator_east setVariable ["ow_ru_res_comp_prog", [0,0,0,0,0,0,0,0], true];
bis_curator_east setVariable ["ow_ru_res_comp_strings", ["Computer tech I","Computer tech II","Computer tech III","Artificial intelligence","Advanced AI","Hacking","Materialization forecast","Precise teleportation"], true];

// start check - make sure there is at least one worker
_randomCharacter = selectRandom owr_ru_characters;
_randomCharacter setVariable ["ow_class", 1, true];
[_randomCharacter, 1, "ru"] call owr_fn_assignClassGear;



// dynamic character spawn
// two types of arrays for the randomization,(_di) and actual ingame entity link (_d) 
owr_am_characters_di = ["am07","am08","am09","am10","am11","am12","am13","am14","am15","am16","am17","am18","am19","am20"];
owr_ru_characters_di = ["ru07","ru08","ru09","ru10","ru11","ru12","ru13","ru14","ru15","ru16","ru17","ru18","ru19","ru20"];
owr_ar_characters_di = ["ar07","ar08","ar09","ar10","ar11","ar12","ar13","ar14","ar15","ar16","ar17","ar18","ar19","ar20"];
owr_am_characters_d = [objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull];
owr_ru_characters_d = [objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull];
owr_ar_characters_d = [objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull];
bis_curator_west setVariable ["owr_am_characters_d", owr_am_characters_d, true];
bis_curator_east setVariable ["owr_ru_characters_d", owr_ru_characters_d, true];
bis_curator_arab setVariable ["owr_ar_characters_d", owr_ar_characters_d, true];

// _di array contents shifted (so you wont be able to tell who will arrive next)
// AM side
_i = 0;
for "_i" from 0 to 13 do {
	_rndIndex = (round (random 14)) min 13;
	_rndItem = owr_am_characters_di select _rndIndex;
	_rndNIndex = (round (random 14)) min 13;
	_temp = owr_am_characters_di select _rndNIndex;
	owr_am_characters_di set [_rndNIndex, _rndItem];
	owr_am_characters_di set [_rndIndex, _temp];
};
// RU side
_i = 0;
for "_i" from 0 to 13 do {
	_rndIndex = (round (random 14)) min 13;
	_rndItem = owr_ru_characters_di select _rndIndex;
	_rndNIndex = (round (random 14)) min 13;
	_temp = owr_ru_characters_di select _rndNIndex;
	owr_ru_characters_di set [_rndNIndex, _rndItem];
	owr_ru_characters_di set [_rndIndex, _temp];
};
// RU side
_i = 0;
for "_i" from 0 to 13 do {
	_rndIndex = (round (random 14)) min 13;
	_rndItem = owr_ar_characters_di select _rndIndex;
	_rndNIndex = (round (random 14)) min 13;
	_temp = owr_ar_characters_di select _rndNIndex;
	owr_ar_characters_di set [_rndNIndex, _rndItem];
	owr_ar_characters_di set [_rndIndex, _temp];
};

// update _di array for curators - so client with curator now knows who the dynamic characters are in this game
bis_curator_west setVariable ["owr_am_characters_di", owr_am_characters_di, true];
bis_curator_east setVariable ["owr_ru_characters_di", owr_ru_characters_di, true];
bis_curator_arab setVariable ["owr_ar_characters_di", owr_ar_characters_di, true];

// now to the actual spawning
// setting up limits of dynamic characters
owr_dyn_char_frequency = (["DynCharsFreq"] call BIS_fnc_getParamValue) / 100;
owr_dyn_char_cap = ["DynChars"] call BIS_fnc_getParamValue;		// this is the limit (for both side the same), 14 is maximum!
owr_dyn_char_am_cur = 0;	// this will increment
owr_dyn_char_ru_cur = 0;	// this will increment
owr_dyn_char_ar_cur = 0;	// this will increment

// actual spawning threads later - we need to have crate positions first (characters use the same positions as crates)


//////////////////////////////////////////////////////////////////////////////////////////////
// ENVIRONMENT INIT
//////////////////////////////////////////////////////////////////////////////////////////////

setViewDistance 1000;

owr_res_density_oil = (["OilAmount"] call BIS_fnc_getParamValue) / 100; 		// higher = lower density (less amount of oil sources)
owr_res_density_siberite = (["SibAmount"] call BIS_fnc_getParamValue) / 100; 	// higher = lower density (less amount of siberite sources)

owr_startpos_ar = selectRandom (getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "start_ar"));
owr_startpos_am = selectRandom (getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "start_am"));
owr_startpos_ru = selectRandom (getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "start_ru"));

/*_i = 0;
_arPoses = (getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "start_ar"));
for "_i" from 0 to ((count _arPoses) - 1) do {
	createMarkerLocal [format ["owr_startpos_ar_%1", _i], _arPoses select _i];
	format ["owr_startpos_ar_%1", _i] setMarkerTypeLocal "hd_destroy";
	format ["owr_startpos_ar_%1", _i] setMarkerColorLocal "ColorYellow";
	format ["owr_startpos_ar_%1", _i] setMarkerTextLocal format ["%1", _i];
};
_i = 0;
_amPoses = (getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "start_am"));
for "_i" from 0 to ((count _amPoses) - 1) do {
	createMarkerLocal [format ["owr_startpos_am_%1", _i], _amPoses select _i];
	format ["owr_startpos_am_%1", _i] setMarkerTypeLocal "hd_destroy";
	format ["owr_startpos_am_%1", _i] setMarkerColorLocal "ColorBlue";
	format ["owr_startpos_am_%1", _i] setMarkerTextLocal format ["%1", _i];
};
_i = 0;
_ruPoses = (getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "start_ru"));
for "_i" from 0 to ((count _ruPoses) - 1) do {
	createMarkerLocal [format ["owr_startpos_ru_%1", _i], _ruPoses select _i];
	format ["owr_startpos_ru_%1", _i] setMarkerTypeLocal "hd_destroy";
	format ["owr_startpos_ru_%1", _i] setMarkerColorLocal "ColorRed";
	format ["owr_startpos_ru_%1", _i] setMarkerTextLocal format ["%1", _i];
};*/

if (owr_devhax) then {
	createMarkerLocal ["owr_startpos_ar", owr_startpos_ar];
	"owr_startpos_ar" setMarkerTypeLocal "hd_destroy";
	"owr_startpos_ar" setMarkerColorLocal "ColorYellow";
	createMarkerLocal ["owr_startpos_am", owr_startpos_am];
	"owr_startpos_am" setMarkerTypeLocal "hd_destroy";
	"owr_startpos_am" setMarkerColorLocal "ColorBlue";
	createMarkerLocal ["owr_startpos_ru", owr_startpos_ru];
	"owr_startpos_ru" setMarkerTypeLocal "hd_destroy";
	"owr_startpos_ru" setMarkerColorLocal "ColorRed";
};

owr_res_crates_0 = getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "crates00");
owr_res_crates_1 = getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "crates10");
owr_res_crates_2 = getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "crates20");
owr_res_crates_3 = getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "crates01");
owr_res_crates_4 = getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "crates11");
owr_res_crates_5 = getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "crates21");
owr_res_crates_6 = getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "crates02");
owr_res_crates_7 = getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "crates12");
owr_res_crates_8 = getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "crates22");

owr_res_oil = getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "oil");
owr_res_siberite = getArray (configFile >> "CfgWorlds" >> "Pliocen" >> "owr" >> "resources" >> "siberite");

// ENVIRONMENT - SIDE MOVER
// arab
{
	if (local _x) then {
		_x setPos [(owr_startpos_ar select 0) + random [0, 5, 10], (owr_startpos_ar select 1) + random [0, 5, 10]];
	} else {
		[_x, [(owr_startpos_ar select 0) + random [0, 5, 10], (owr_startpos_ar select 1) + random [0, 5, 10]]] remoteExec ["setPos", 0];
	};
} foreach owr_ar_characters;
bis_curator_arab setPos owr_startpos_ar;
bis_curatorUnit_arab setPos owr_startpos_ar;
// am
{
	if (local _x) then {
		_x setPos [(owr_startpos_am select 0) + random [0, 5, 10], (owr_startpos_am select 1) + random [0, 5, 10]];
	} else {
		[_x, [(owr_startpos_am select 0) + random [0, 5, 10], (owr_startpos_am select 1) + random [0, 5, 10]]] remoteExec ["setPos", 0];
	};
} foreach owr_am_characters;
bis_curator_west setPos owr_startpos_am;
bis_curatorUnit_west setPos owr_startpos_am;
// ru
{
	if (local _x) then {
		_x setPos [(owr_startpos_ru select 0) + random [0, 5, 10], (owr_startpos_ru select 1) + random [0, 5, 10]];
	} else {
		[_x, [(owr_startpos_ru select 0) + random [0, 5, 10], (owr_startpos_ru select 1) + random [0, 5, 10]]] remoteExec ["setPos", 0];
	};
} foreach owr_ru_characters;
bis_curator_east setPos owr_startpos_ru;
bis_curatorUnit_east setPos owr_startpos_ru;


// ENVIRONMENT - CRATE SPAWNER
// definitions
owr_fn_getCrateArray = {
	_arrayName = _this select 0;
	_arrayToUse = [];
	switch (_arrayName) do {
		case "owr_res_crates_0": {
			_arrayToUse = owr_res_crates_0;
		};
		case "owr_res_crates_1": {
			_arrayToUse = owr_res_crates_1;
		};
		case "owr_res_crates_2": {
			_arrayToUse = owr_res_crates_2;
		};
		case "owr_res_crates_3": {
			_arrayToUse = owr_res_crates_3;
		};
		case "owr_res_crates_4": {
			_arrayToUse = owr_res_crates_4;
		};
		case "owr_res_crates_5": {
			_arrayToUse = owr_res_crates_5;
		};
		case "owr_res_crates_6": {
			_arrayToUse = owr_res_crates_6;
		};
		case "owr_res_crates_7": {
			_arrayToUse = owr_res_crates_7;
		};
		case "owr_res_crates_8": {
			_arrayToUse = owr_res_crates_8;
		};
	};

	_arrayToUse
};
_spawnStartCrates = {
	_startPos = _this select 0;
	_crateTypes = ["owr_crates_pile_1", "owr_crates_pile_2", "owr_crates_pile_3", "owr_crates_pile_4", "owr_crates_pile_5"];

	// calculate start tile, (5120/3) = 1706
	_startTileX = floor ((_startPos select 0) / 1706);
	_startTileY = floor ((_startPos select 1) / 1706);
	_arrayToUseName = format ["owr_res_crates_%1", (3 * _startTileY) + _startTileX];
	_arrayToUse = [_arrayToUseName] call owr_fn_getCrateArray;

	// use appropriate array to check for distances (should be no longer than 500 meters)
	_availableCratePositions = [];
	_i = 0;
	for "_i" from 0 to (count _arrayToUse) do {
		if ((_startPos distance (_arrayToUse select _i)) < 750) then {
			_availableCratePositions = _availableCratePositions + [(_arrayToUse select _i)];
		};
	};

	for "_i" from 0 to (50 min (count _availableCratePositions)) do {
		_crates = (selectRandom _crateTypes) createVehicle (selectRandom _availableCratePositions); 
		_crates enableSimulationGlobal false;
		switch (typeOf _crates) do {
			case "owr_crates_pile_1": {
				_crates setVariable ["owr_crate_amount", 5, true];
			};
			case "owr_crates_pile_2": {
				_crates setVariable ["owr_crate_amount", 2, true];
			};
			case "owr_crates_pile_3": {
				_crates setVariable ["owr_crate_amount", 3, true];
			};
			case "owr_crates_pile_4": {
				_crates setVariable ["owr_crate_amount", 4, true];
			};
			case "owr_crates_pile_5": {
				_crates setVariable ["owr_crate_amount", 1, true];
			};
		};

		if (owr_devhax) then {
			createMarkerLocal [format ["crate_%1_%2", _i, _startPos select 0], (getPos _crates)];
			format ["crate_%1_%2", _i, _startPos select 0] setMarkerTypeLocal "hd_dot";
			format ["crate_%1_%2", _i, _startPos select 0] setMarkerColorLocal "ColorYellow";
		};
	};
};

// spawn first wave of crates - spawned around starting locations of both sides
[owr_startpos_ar] call _spawnStartCrates;
[owr_startpos_am] call _spawnStartCrates;
[owr_startpos_ru] call _spawnStartCrates;


// dynamic crate spawner
owr_res_dynamicspawners = [false, false, false, false, false, false, false, false, false];
// allow spawn of crates at starting positions
_startTileAR = (3 * floor ((owr_startpos_ar select 1) / 1706)) + floor ((owr_startpos_ar select 0) / 1706);
_startTileAM = (3 * floor ((owr_startpos_am select 1) / 1706)) + floor ((owr_startpos_am select 0) / 1706);
_startTileRU = (3 * floor ((owr_startpos_ru select 1) / 1706)) + floor ((owr_startpos_ru select 0) / 1706);
owr_res_dynamicspawners set [_startTileAR, true];
owr_res_dynamicspawners set [_startTileAM, true];
owr_res_dynamicspawners set [_startTileRU, true];

[] spawn {
	_crateTypes = ["owr_crates_pile_1", "owr_crates_pile_2", "owr_crates_pile_3", "owr_crates_pile_4", "owr_crates_pile_5"];
	// crate cont. spawner
	while {true} do {
		// time between each crate spawn - fixed interval
		_wait = [random [2, 4, 6], random [6, 9, 12], random [12, 16, 20]];
		sleep (selectRandom _wait);
		// how many crates will appear?
		_noOfCrates = round random 3;
		_noOfCrates = _noOfCrates max 1;
		// collect active tiles for crate spawn (based on "logged" warehouses)
		_i = 0;
		_availableTiles = [];
		for "_i" from 0 to (count owr_res_dynamicspawners) do {
			if (owr_res_dynamicspawners select _i) then {
				_availableTiles = _availableTiles + [_i];
			};
		};
		// crate an array of chosen crate spawn positions (based on _noOfCrates - multiple can spawn per this pass)
		_i = 0;
		_cratesPos = [];
		for "_i" from 0 to (_noOfCrates - 1) do {
			_cratesPos = _cratesPos + [(selectRandom ([format ["owr_res_crates_%1", selectRandom _availableTiles]] call owr_fn_getCrateArray))];
		};
		// got it, lets sent to RU signal that crate/s are incoming (needs to have a research completed!)
		if (["comp", 6, bis_curator_east] call owr_fn_isResearchComplete) then {
			[_cratesPos] remoteExec ["owr_fn_materialization_forecast", 0];
		};
		// aaand wait
		sleep 5;

		// aaand start spawning chosen amount of crates on chosen spawns
		_i = 0;
		for "_i" from 0 to (_noOfCrates - 1) do {
			_crates = (selectRandom _crateTypes) createVehicle (_cratesPos select _i);
			_crates enableSimulationGlobal false;

			switch (typeOf _crates) do {
				case "owr_crates_pile_1": {
					_crates setVariable ["owr_crate_amount", 5, true];
				};
				case "owr_crates_pile_2": {
					_crates setVariable ["owr_crate_amount", 2, true];
				};
				case "owr_crates_pile_3": {
					_crates setVariable ["owr_crate_amount", 3, true];
				};
				case "owr_crates_pile_4": {
					_crates setVariable ["owr_crate_amount", 4, true];
				};
				case "owr_crates_pile_5": {
					_crates setVariable ["owr_crate_amount", 1, true];
				};
			};
			[_crates, "owr_resource_materialization"] remoteExec ["say3D", 0];
			[_crates] remoteExec ["owr_fn_materialization_effect", 0];

			// re call for precise materialization detection (AM curator only + needs to have a research completed!)
			if (["opto", 5, bis_curator_west] call owr_fn_isResearchComplete) then {
				[getPos _crates] remoteExec ["owr_fn_materialization_detect", 0];
			};
		};
	};
};


// ENVIRONMENT - RESOURCE SPAWNER
// OIL
_i = 0;
for "_i" from 0 to ((count owr_res_oil) - 1) do {
	_chance = random 1;
	if (_chance > owr_res_density_oil) then {
		_oil_deposit = "owr_deposit_oil" createVehicle (owr_res_oil select _i);
		_oil_deposit enableSimulationGlobal false;
		//_oil_deposit = createSimpleObject ["owr_deposit_oil", (owr_res_oil select _i)];
		[_oil_deposit] spawn owr_fn_depositTick;
		if (owr_devhax) then {
			createMarkerLocal [format ["oil_%1", _i], (owr_res_oil select _i)];
			format ["oil_%1", _i] setMarkerTypeLocal "hd_dot";
			format ["oil_%1", _i] setMarkerColorLocal "ColorOrange";
		};
	};
};
// SIBERITE
_i = 0;
_actualSibPoses = [];
for "_i" from 0 to ((count owr_res_siberite) - 1) do {
	_chance = random 1;
	if (_chance > owr_res_density_siberite) then {
		_sib_deposit = "owr_deposit_siberite" createVehicle (owr_res_siberite select _i);
		_sib_deposit enableSimulationGlobal false;
		_actualSibPoses = _actualSibPoses + [(owr_res_siberite select _i)];
		//_sib_deposit = createSimpleObject ["owr_deposit_siberite", (owr_res_siberite select _i)];
		[_sib_deposit] spawn owr_fn_depositTick;
	};
};

// for siberite source detection
bis_curator_east setVariable ["owr_ru_siberite_sources", _actualSibPoses, true];


// ENVIRONMENT - FASTER TIME
[] spawn {
	while {true} do {
		// normal rate for nice day times
		_rate = 0.000265;
		if (((daytime > 9.5) && (daytime < 15.5)) || ((daytime > 22.5) || (daytime < 3.5))) then {
			// apply faster rate - dont stay in dark for too long
			// also dont stay in bright day for too long
			_rate = 0.00053;
		};
		_i = 0;
		for "_i" from 0 to 30 do {
			skipTime _rate;
			sleep 0.03;
		};
	};
};


sleep 3;

// ENVIRONMENT - CHARACTER SPAWNERS
// this code creates a new unit to AM side - each side has its own spawn thread
[] spawn {
	while {(owr_dyn_char_am_cur < 14) && ((owr_dyn_char_am_cur + 1) <= owr_dyn_char_cap)} do {
		// wait some time
		_freqMod = 0.25;
		if (owr_dyn_char_am_cur == 1) then {
			_freqMod = 0.45;
		} else {
			if (owr_dyn_char_am_cur > 1) then {
				_freqMod = 1 - (1 / (owr_dyn_char_am_cur));
			};
		};
		_nextCharIn = selectRandom [random [340 * owr_dyn_char_frequency, 440 * owr_dyn_char_frequency, 540 * owr_dyn_char_frequency], random [540 * owr_dyn_char_frequency, 640 * owr_dyn_char_frequency, 740 * owr_dyn_char_frequency], random [840 * owr_dyn_char_frequency, 940 * owr_dyn_char_frequency, 1040 * owr_dyn_char_frequency]];
		sleep _nextCharIn;

		// create entity
		_tempGroup = createGroup west;
		_tempUnit = _tempGroup createUnit ["owr_man_am", [0,0,0], [], 100, "FORM"];

		// move it to a selected position
		_tempUnit setPos (selectRandom ([format ["owr_res_crates_%1", (3 * floor ((owr_startpos_am select 1) / 1706)) + floor ((owr_startpos_am select 0) / 1706)]] call owr_fn_getCrateArray));

		// re call for materialization forecast (RU curator only + needs to have a research completed!)
		if (["comp", 6, bis_curator_east] call owr_fn_isResearchComplete) then {
			[[getPos _tempUnit]] remoteExec ["owr_fn_materialization_forecast", 0];
		};
		sleep 5;

		// set identity - done on client side!
		[_tempUnit, format["ow_%1", owr_am_characters_di select owr_dyn_char_am_cur]] remoteExec ["owr_fn_setIdentity", bis_curator_west];

		// assign OWR vars
		_majorPref = getNumber (missionConfigFile >> "CfgIdentities" >> format["ow_%1", owr_am_characters_di select owr_dyn_char_am_cur] >> "prefMajor");
		_minorPref = getNumber (missionConfigFile >> "CfgIdentities" >> format["ow_%1", owr_am_characters_di select owr_dyn_char_am_cur] >> "prefMinor");
		_tempUnit allowFleeing 0;
		_tempUnit disableAI "FSM";
		_tempUnit disableAI "SUPPRESSION";
		_tempUnit disableAI "AIMINGERROR";
		_tempUnit disableAI "COVER";
		_tempUnit setVariable ["ow_class", _majorPref, true];
		_tempUnit setVariable ["ow_ctype", true, true];
		_tempUnit setVariable ["ow_aitype", 1, true];
		_tempUnit setVariable ["ow_worker_buildmode", 0, true];
		_tempUnit setVariable ["ow_skill_soldier", random [0.01, 2, 4.0], true];
		_tempUnit setVariable ["ow_skill_worker", random [0.01, 2, 4.0], true];
		_tempUnit setVariable ["ow_skill_mechanic", random [0.01, 2, 4.0], true];
		_tempUnit setVariable ["ow_skill_scientist", random [0.01, 2, 4.0], true];
		switch (_majorPref) do {
			case 0: {
				_tempUnit setVariable ["ow_skill_soldier", random [4.0, 5, 6.0], true];
			};
			case 1: {
				_tempUnit setVariable ["ow_skill_worker", random [4.0, 5, 6.0], true];
			};
			case 2: {
				_tempUnit setVariable ["ow_skill_mechanic", random [4.0, 5, 6.0], true];
			};
			case 3: {
				_tempUnit setVariable ["ow_skill_scientist", random [4.0, 5, 6.0], true];
			};
		};
		switch (_minorPref) do {
			case 0: {
				_tempUnit setVariable ["ow_skill_soldier", random [2.0, 3, 4.0], true];
			};
			case 1: {
				_tempUnit setVariable ["ow_skill_worker", random [2.0, 3, 4.0], true];
			};
			case 2: {
				_tempUnit setVariable ["ow_skill_mechanic", random [2.0, 3, 4.0], true];
			};
			case 3: {
				_tempUnit setVariable ["ow_skill_scientist", random [2.0, 3, 4.0], true];
			};
		};
		_damageIgnoreSet = _tempUnit addEventHandler ["GetInMan", {[(_this select 0), false] remoteExec ["allowDamage", 0];}];
		_damageIgnoreOff = _tempUnit addEventHandler ["GetOutMan", {[(_this select 0), true] remoteExec ["allowDamage", 0];}];
		_tempUnit addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 12;

			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];

		// assign OWR logic stuff
		[_tempUnit] spawn owr_fn_owman_am_ai;
		[_tempUnit, _tempUnit getVariable "ow_class", "am"] call owr_fn_assignClassGear;

		// hand over the control to curator
		bis_curator_west addCuratorEditableObjects [[_tempUnit], false];

		// public sets
		owr_am_characters_d set [owr_dyn_char_am_cur, _tempUnit];
		owr_dyn_char_am_cur = owr_dyn_char_am_cur + 1;

		// send update to curator
		bis_curator_west setVariable ["owr_am_characters_d", owr_am_characters_d, true];

		// make materialization sound on the position of spawn
		[_tempUnit, "owr_resource_materialization"] remoteExec ["say3D", 0];

		sleep 1.7;

		[_tempUnit] remoteExec ["owr_fn_materialization_effect", 0];

		// re call for precise materialization detection (AM curator only + needs to have a research completed!)
		if (["opto", 5, bis_curator_west] call owr_fn_isResearchComplete) then {
			[getPos _tempUnit] remoteExec ["owr_fn_materialization_detect", 0];
		};

		// let curator know about its presence
		[(_tempUnit), "Requesting assistance", "Reinforcement", mapGridPosition (getPos _tempUnit)] remoteExec ["owr_fn_message", bis_curator_west];
	};
};
// same for RU side
[] spawn {
	while {(owr_dyn_char_ru_cur < 14) && ((owr_dyn_char_ru_cur + 1) <= owr_dyn_char_cap)} do {
		// wait some time
		_freqMod = 0.25;
		if (owr_dyn_char_ru_cur == 1) then {
			_freqMod = 0.45;
		} else {
			if (owr_dyn_char_ru_cur > 1) then {
				_freqMod = 1 - (1 / (owr_dyn_char_ru_cur));
			};
		};
		_nextCharIn = selectRandom [random [340 * owr_dyn_char_frequency * _freqMod, 440 * owr_dyn_char_frequency * _freqMod, 540 * owr_dyn_char_frequency * _freqMod], random [540 * owr_dyn_char_frequency * _freqMod, 640 * owr_dyn_char_frequency * _freqMod, 740 * owr_dyn_char_frequency * _freqMod], random [840 * owr_dyn_char_frequency * _freqMod, 940 * owr_dyn_char_frequency * _freqMod, 1040 * owr_dyn_char_frequency * _freqMod]];
		sleep _nextCharIn;

		// create entity
		_tempGroup = createGroup east;
		_tempUnit = _tempGroup createUnit ["owr_man_ru", [0,0,0], [], 100, "FORM"];

		// move it to a selected position
		_tempUnit setPos (selectRandom ([format ["owr_res_crates_%1", (3 * floor ((owr_startpos_ru select 1) / 1706)) + floor ((owr_startpos_ru select 0) / 1706)]] call owr_fn_getCrateArray));

		// re call for materialization forecast (RU curator only + needs to have a research completed!)
		if (["comp", 6, bis_curator_east] call owr_fn_isResearchComplete) then {
			[[getPos _tempUnit]] remoteExec ["owr_fn_materialization_forecast", 0];
		};
		sleep 5;

		// set identity - done on client side!
		[_tempUnit, format["ow_%1", owr_ru_characters_di select owr_dyn_char_ru_cur]] remoteExec ["owr_fn_setIdentity", bis_curator_east];

		// assign OWR vars
		_majorPref = getNumber (missionConfigFile >> "CfgIdentities" >> format["ow_%1", owr_ru_characters_di select owr_dyn_char_ru_cur] >> "prefMajor");
		_minorPref = getNumber (missionConfigFile >> "CfgIdentities" >> format["ow_%1", owr_ru_characters_di select owr_dyn_char_ru_cur] >> "prefMinor");
		_tempUnit allowFleeing 0;
		_tempUnit disableAI "FSM";
		_tempUnit disableAI "SUPPRESSION";
		_tempUnit disableAI "AIMINGERROR";
		_tempUnit disableAI "COVER";
		_tempUnit setVariable ["ow_class", _majorPref, true];
		_tempUnit setVariable ["ow_ctype", true, true];
		_tempUnit setVariable ["ow_aitype", 1, true];
		_tempUnit setVariable ["ow_worker_buildmode", 0, true];
		_tempUnit setVariable ["ow_skill_soldier", random [0.01, 2, 4.0], true];
		_tempUnit setVariable ["ow_skill_worker", random [0.01, 2, 4.0], true];
		_tempUnit setVariable ["ow_skill_mechanic", random [0.01, 2, 4.0], true];
		_tempUnit setVariable ["ow_skill_scientist", random [0.01, 2, 4.0], true];
		switch (_majorPref) do {
			case 0: {
				_tempUnit setVariable ["ow_skill_soldier", random [4.0, 5, 6.0], true];
			};
			case 1: {
				_tempUnit setVariable ["ow_skill_worker", random [4.0, 5, 6.0], true];
			};
			case 2: {
				_tempUnit setVariable ["ow_skill_mechanic", random [4.0, 5, 6.0], true];
			};
			case 3: {
				_tempUnit setVariable ["ow_skill_scientist", random [4.0, 5, 6.0], true];
			};
		};
		switch (_minorPref) do {
			case 0: {
				_tempUnit setVariable ["ow_skill_soldier", random [2.0, 3, 4.0], true];
			};
			case 1: {
				_tempUnit setVariable ["ow_skill_worker", random [2.0, 3, 4.0], true];
			};
			case 2: {
				_tempUnit setVariable ["ow_skill_mechanic", random [2.0, 3, 4.0], true];
			};
			case 3: {
				_tempUnit setVariable ["ow_skill_scientist", random [2.0, 3, 4.0], true];
			};
		};
		_damageIgnoreSet = _tempUnit addEventHandler ["GetInMan", {[(_this select 0), false] remoteExec ["allowDamage", 0];}];
		_damageIgnoreOff = _tempUnit addEventHandler ["GetOutMan", {[(_this select 0), true] remoteExec ["allowDamage", 0];}];
		_tempUnit addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 12;

			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];

		// assign OWR logic stuff
		[_tempUnit] spawn owr_fn_owman_ru_ai;
		[_tempUnit, _tempUnit getVariable "ow_class", "ru"] call owr_fn_assignClassGear;

		// hand over the control to curator
		bis_curator_east addCuratorEditableObjects [[_tempUnit], false];

		// public sets
		owr_ru_characters_d set [owr_dyn_char_ru_cur, _tempUnit];
		owr_dyn_char_ru_cur = owr_dyn_char_ru_cur + 1;

		// send update to curator
		bis_curator_east setVariable ["owr_ru_characters_d", owr_ru_characters_d, true];

		// make materialization sound on the position of spawn
		[_tempUnit, "owr_resource_materialization"] remoteExec ["say3D", 0];

		sleep 1.7;

		[_tempUnit] remoteExec ["owr_fn_materialization_effect", 0];

		// re call for precise materialization detection (AM curator only + needs to have a research completed!)
		if (["opto", 5, bis_curator_west] call owr_fn_isResearchComplete) then {
			[getPos _tempUnit] remoteExec ["owr_fn_materialization_detect", 0];
		};

		// let curator know about its presence
		[(_tempUnit), "Requesting assistance", "Reinforcement", mapGridPosition (getPos _tempUnit)] remoteExec ["owr_fn_message", bis_curator_east];
	};
};
// same for AR side
[] spawn {
	while {(owr_dyn_char_ar_cur < 14) && ((owr_dyn_char_ar_cur + 1) <= owr_dyn_char_cap)} do {
		// wait some time
		_freqMod = 0.25;
		if (owr_dyn_char_ar_cur == 1) then {
			_freqMod = 0.45;
		} else {
			if (owr_dyn_char_ar_cur > 1) then {
				_freqMod = 1 - (1 / (owr_dyn_char_ar_cur));
			};
		};
		_nextCharIn = selectRandom [random [340 * owr_dyn_char_frequency, 440 * owr_dyn_char_frequency, 540 * owr_dyn_char_frequency], random [540 * owr_dyn_char_frequency, 640 * owr_dyn_char_frequency, 740 * owr_dyn_char_frequency], random [840 * owr_dyn_char_frequency, 940 * owr_dyn_char_frequency, 1040 * owr_dyn_char_frequency]];
		sleep _nextCharIn;

		// create entity
		_tempGroup = createGroup resistance;
		_tempUnit = _tempGroup createUnit ["owr_man_ar", [0,0,0], [], 100, "FORM"];

		// move it to a selected position
		_tempUnit setPos (selectRandom ([format ["owr_res_crates_%1", (3 * floor ((owr_startpos_ar select 1) / 1706)) + floor ((owr_startpos_ar select 0) / 1706)]] call owr_fn_getCrateArray));

		// re call for materialization forecast (RU curator only + needs to have a research completed!)
		if (["comp", 6, bis_curator_east] call owr_fn_isResearchComplete) then {
			[[getPos _tempUnit]] remoteExec ["owr_fn_materialization_forecast", 0];
		};
		sleep 5;

		// set identity - done on client side!
		[_tempUnit, format["ow_%1", owr_ar_characters_di select owr_dyn_char_ar_cur]] remoteExec ["owr_fn_setIdentity", bis_curator_arab];

		// assign OWR vars
		_majorPref = getNumber (missionConfigFile >> "CfgIdentities" >> format["ow_%1", owr_ar_characters_di select owr_dyn_char_ar_cur] >> "prefMajor");
		_minorPref = getNumber (missionConfigFile >> "CfgIdentities" >> format["ow_%1", owr_ar_characters_di select owr_dyn_char_ar_cur] >> "prefMinor");
		_tempUnit allowFleeing 0;
		_tempUnit disableAI "FSM";
		_tempUnit disableAI "SUPPRESSION";
		_tempUnit disableAI "AIMINGERROR";
		_tempUnit disableAI "COVER";
		_tempUnit setVariable ["ow_class", _majorPref, true];
		_tempUnit setVariable ["ow_ctype", true, true];
		_tempUnit setVariable ["ow_aitype", 1, true];
		_tempUnit setVariable ["ow_worker_buildmode", 0, true];
		_tempUnit setVariable ["ow_skill_soldier", random [0.01, 2, 4.0], true];
		_tempUnit setVariable ["ow_skill_worker", random [0.01, 2, 4.0], true];
		_tempUnit setVariable ["ow_skill_mechanic", random [0.01, 2, 4.0], true];
		_tempUnit setVariable ["ow_skill_scientist", random [0.01, 2, 4.0], true];
		switch (_majorPref) do {
			case 0: {
				_tempUnit setVariable ["ow_skill_soldier", random [4.0, 5, 6.0], true];
			};
			case 1: {
				_tempUnit setVariable ["ow_skill_worker", random [4.0, 5, 6.0], true];
			};
			case 2: {
				_tempUnit setVariable ["ow_skill_mechanic", random [4.0, 5, 6.0], true];
			};
			case 3: {
				_tempUnit setVariable ["ow_skill_scientist", random [4.0, 5, 6.0], true];
			};
		};
		switch (_minorPref) do {
			case 0: {
				_tempUnit setVariable ["ow_skill_soldier", random [2.0, 3, 4.0], true];
			};
			case 1: {
				_tempUnit setVariable ["ow_skill_worker", random [2.0, 3, 4.0], true];
			};
			case 2: {
				_tempUnit setVariable ["ow_skill_mechanic", random [2.0, 3, 4.0], true];
			};
			case 3: {
				_tempUnit setVariable ["ow_skill_scientist", random [2.0, 3, 4.0], true];
			};
		};
		_damageIgnoreSet = _tempUnit addEventHandler ["GetInMan", {[(_this select 0), false] remoteExec ["allowDamage", 0];}];
		_damageIgnoreOff = _tempUnit addEventHandler ["GetOutMan", {[(_this select 0), true] remoteExec ["allowDamage", 0];}];
		_tempUnit addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 12;

			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];

		// assign OWR logic stuff
		[_tempUnit] spawn owr_fn_owman_ar_ai;
		[_tempUnit, _tempUnit getVariable "ow_class", "ar"] call owr_fn_assignClassGear;

		// hand over the control to curator
		bis_curator_arab addCuratorEditableObjects [[_tempUnit], false];

		// public sets
		owr_ar_characters_d set [owr_dyn_char_ar_cur, _tempUnit];
		owr_dyn_char_ar_cur = owr_dyn_char_ar_cur + 1;

		// send update to curator
		bis_curator_arab setVariable ["owr_ar_characters_d", owr_ar_characters_d, true];

		// make materialization sound on the position of spawn
		[_tempUnit, "owr_resource_materialization"] remoteExec ["say3D", 0];

		sleep 1.7;

		[_tempUnit] remoteExec ["owr_fn_materialization_effect", 0];

		// re call for precise materialization detection (AM curator only + needs to have a research completed!)
		if (["opto", 5, bis_curator_west] call owr_fn_isResearchComplete) then {
			[getPos _tempUnit] remoteExec ["owr_fn_materialization_detect", 0];
		};

		// let curator know about its presence
		[(_tempUnit), "Requesting assistance", "Reinforcement", mapGridPosition (getPos _tempUnit)] remoteExec ["owr_fn_message", bis_curator_arab];
	};
};

// DOMINATION SYSTEM
// main win condition loop
[] spawn {
	_someOneDidIt = false;
	while {!_someOneDidIt} do {
		// check for presence of a control tower on primary siberite deposit
		// if present, keep checking ow_wrhs_siberite value, if it reaches 1000, owner won!
		sleep 10;
		_nearestTower = nearestObjects [[3076.5,2276.03], ["control_tower_am", "control_tower_ru", "control_tower_ar"], 10];
		if ((count _nearestTower) > 0) then {
			if (((_nearestTower select 0) getVariable "ow_wrhs_siberite") >= 1000) then {
				_someOneDidIt = true;
			};
		};
	};

	sleep 20;

	"SideScore" call BIS_fnc_endMissionServer;
};