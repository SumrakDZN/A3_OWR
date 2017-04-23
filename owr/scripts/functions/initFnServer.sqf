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

	_progress = _progress * owr_gameSpeed;

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

	_progress = _progress * owr_gameSpeed;

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

	_progress = _progress * owr_gameSpeed;

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

	_skill = _skill * (owr_gameSpeed / 2.0);

	// this script is caled every 0.1 for each personnel - if they are manufacturing / building / researching
	// the higher level, the lower gain should be
	// the more complex thing, the higher gain should be

	if (owr_devhax) then {
		_skill = 0.1;
	};

	_skill
};
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
owr_fn_cratesInitSpawn = {
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