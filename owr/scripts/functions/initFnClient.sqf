owr_fn_remoteControl = compile preprocessFileLineNumbers "\owr\scripts\functions\owr_fn_moduleRemoteControl.sqf";

owr_fn_nodeMarkerManager = {

	for "_i" from 0 to ((count owr_positions_nodes) - 1) do {
		createMarkerLocal [format ["node_%1", _i], owr_positions_nodes select _i];
		format ["node_%1", _i] setMarkerTypeLocal "mil_circle";
		format ["node_%1", _i] setMarkerColorLocal "ColorBlack";
		format ["node_%1", _i] setMarkerSizeLocal [0.75, 0.75];
	};

	while {true} do {
		_i = 0;
		for "_i" from 0 to ((count owr_positions_nodes) - 1) do {
			_nearestTower = nearestObjects [owr_positions_nodes select _i, ["control_tower_am", "control_tower_ru", "control_tower_ar"], 10];
			if ((count _nearestTower) > 0) then {
				switch (typeOf (_nearestTower select 0)) do {
					case "control_tower_am": {
						format ["node_%1", _i] setMarkerColorLocal "ColorBlue";
					};
					case "control_tower_ru": {
						format ["node_%1", _i] setMarkerColorLocal "ColorRed";
					};
					case "control_tower_ar": {
						format ["node_%1", _i] setMarkerColorLocal "ColorYellow";
					};
					default {
						format ["node_%1", _i] setMarkerColorLocal "ColorBlack";
					};
				};
			} else {
				format ["node_%1", _i] setMarkerColorLocal "ColorBlack";
			};
		};
		sleep 10;
	};

};

owr_fn_taskManagerSide = {
	// manages tasks for all available people (run on all player-clients) within the mission (per side)
	// loop that keeps an eye on player's side progress
	// continuously show new available tasks, downgrade if necessary (if player loses some captured location)
	// eventualy shows the final destination and 1000 siberite task

	_unitToInform = _this select 0;
	_controlTType = _this select 1;
	_entryNode = _this select 2;
	_firstMiddle = _this select 3;
	_fmCaptured = false;
	_secondMiddle = _this select 4;
	_smCaptured = false;
	_farMiddle = _this select 5;
	_faCaptured = false;
	_centralNode = _this select 6;
	_depositCaptured = false;

	_captureNodeEntry = objNull;
	_captureNodesMiddle = objNull;
	_captureNodeMiddleFirst = objNull;
	_captureNodeMiddleSecond = objNull;
	_captureNodeMiddleFar = objNull;
	_captureNodeCentral = objNull;
	_collect1kSiberite = objNull;

	while {true} do {
		_nearestTower = nearestObjects [_entryNode, [_controlTType], 10];
		if ((count _nearestTower) > 0) then {
			if (((_nearestTower select 0) getVariable "ow_wip_progress") >= 1.0) then {
				// entry node is captured
				if ((taskState _captureNodeEntry) == "Assigned") then {
					// announce change
					_captureNodeEntry setTaskState "Succeeded";
					["Tasksucceeded",["","Capture entry node"]] call BIS_fnc_showNotification;

					// create middle tasks
					if (isNull _captureNodesMiddle) then {
						_captureNodesMiddle = _unitToInform createSimpleTask ["Capture at least 2 central nodes"];
						_captureNodesMiddle setSimpleTaskDescription [
						   "Capturing and holding at least two central nodes will gain your side access to the primary siberite deposit node.",
						   "Capture at least 2 central nodes",
						   "Capture at least 2 central nodes"
						];

						_captureNodeMiddleFirst = _unitToInform createSimpleTask ["Capture middle node", _captureNodesMiddle];
						_captureNodeMiddleFirst setSimpleTaskDescription [
						   "Capturing and holding at least two central nodes will gain your side access to the primary siberite deposit node.",
						   "Capture middle node",
						   "Capture middle node"
						];
						_captureNodeMiddleFirst setSimpleTaskDestination _firstMiddle;
						_captureNodeMiddleFirst setTaskState "Assigned";

						_captureNodeMiddleSecond = _unitToInform createSimpleTask ["Capture middle node", _captureNodesMiddle];
						_captureNodeMiddleSecond setSimpleTaskDescription [
						   "Capturing and holding at least two central nodes will gain your side access to the primary siberite deposit node.",
						   "Capture middle node",
						   "Capture middle node"
						];
						_captureNodeMiddleSecond setSimpleTaskDestination _secondMiddle;
						_captureNodeMiddleSecond setTaskState "Assigned";
					};

					// announce change
					_captureNodesMiddle setTaskState "Assigned";
					["TaskAssigned",["","Capture at least 2 central nodes"]] call BIS_fnc_showNotification;
				};

				// search for progress elsewhere
				_capturedCnt = 0;
				_nearestTower = nearestObjects [_firstMiddle, [_controlTType], 10];
				if ((count _nearestTower) > 0) then {
					if (((_nearestTower select 0) getVariable "ow_wip_progress") >= 1.0) then {
						_capturedCnt = _capturedCnt + 1;
						_fmCaptured = true;
					};
				} else {
					_fmCaptured = false;
					// check if player had this node captured
					if (((taskState _captureNodeMiddleFirst) == "Succeeded") && ((taskState _captureNodesMiddle) == "Succeeded")) then {
						// announce task update
						_captureNodeMiddleFirst setTaskState "Assigned";
						["TaskAssigned",["","Capture middle node"]] call BIS_fnc_showNotification;
					};
				};


				_nearestTower = nearestObjects [_secondMiddle, [_controlTType], 10];
				if ((count _nearestTower) > 0) then {
					if (((_nearestTower select 0) getVariable "ow_wip_progress") >= 1.0) then {
						_capturedCnt = _capturedCnt + 1;
						_smCaptured = true;
					};
				} else {
					_smCaptured = false;
					// check if player had this node captured
					if (((taskState _captureNodeMiddleSecond) == "Succeeded") && ((taskState _captureNodesMiddle) == "Succeeded")) then {
						// announce task update
						_captureNodeMiddleSecond setTaskState "Assigned";
						["TaskAssigned",["","Capture middle node"]] call BIS_fnc_showNotification;
					};
				};


				_nearestTower = nearestObjects [_farMiddle, [_controlTType], 10];
				if ((count _nearestTower) > 0) then {
					if (((_nearestTower select 0) getVariable "ow_wip_progress") >= 1.0) then {
						_capturedCnt = _capturedCnt + 1;
						_faCaptured = true;
					};
				} else {
					_faCaptured = false;
					// check if player had this node captured
					if (!(isNull _captureNodeMiddleFar)) then {
						if (((taskState _captureNodeMiddleFar) == "Succeeded") && ((taskState _captureNodesMiddle) == "Succeeded")) then {
							// announce task update
							_captureNodeMiddleFar setTaskState "Assigned";
							["TaskAssigned",["","Capture middle node"]] call BIS_fnc_showNotification;
						};
					};
				};


				if (((taskState _captureNodeMiddleFirst) == "Assigned") && _fmCaptured) then {
					// announce task update
					_captureNodeMiddleFirst setTaskState "Succeeded";
					["Tasksucceeded",["","Capture middle node"]] call BIS_fnc_showNotification;

					if (isNull _captureNodeMiddleFar) then {
						_captureNodeMiddleFar = _unitToInform createSimpleTask ["Capture middle node", _captureNodesMiddle];
						_captureNodeMiddleFar setSimpleTaskDescription [
						   "Capturing and holding at least two central nodes will gain your side access to the primary siberite deposit node.",
						   "Capture middle node",
						   "Capture middle node"
						];
						_captureNodeMiddleFar setSimpleTaskDestination _farMiddle;
						_captureNodeMiddleFar setTaskState "Assigned";
					};
				};
				if (((taskState _captureNodeMiddleSecond) == "Assigned") && _smCaptured) then {
					// announce task update
					_captureNodeMiddleSecond setTaskState "Succeeded";
					["Tasksucceeded",["","Capture middle node"]] call BIS_fnc_showNotification;

					if (isNull _captureNodeMiddleFar) then {
						_captureNodeMiddleFar = _unitToInform createSimpleTask ["Capture middle node", _captureNodesMiddle];
						_captureNodeMiddleFar setSimpleTaskDescription [
						   "Capturing and holding at least two central nodes will gain your side access to the primary siberite deposit node.",
						   "Capture middle node",
						   "Capture middle node"
						];
						_captureNodeMiddleFar setSimpleTaskDestination _farMiddle;
						_captureNodeMiddleFar setTaskState "Assigned";
					};
				};
				if (!(isNull _captureNodeMiddleFar)) then {
					if (((taskState _captureNodeMiddleFar) == "Assigned") && _faCaptured) then {
						// announce task update
						_captureNodeMiddleFar setTaskState "Succeeded";
						["Tasksucceeded",["","Capture middle node"]] call BIS_fnc_showNotification;
					};
				};



				if (_capturedCnt >= 2) then {
					if ((taskState _captureNodesMiddle) == "Assigned") then {
						// hide un-captured middle node task (if available)
						if (_capturedCnt == 2) then {
							if ((taskState _captureNodeMiddleFar) != "Succeeded") then {
								_captureNodeMiddleFar setTaskState "Succeeded";
							};
							if ((taskState _captureNodeMiddleSecond) != "Succeeded") then {
								_captureNodeMiddleSecond setTaskState "Succeeded";
							};
							if ((taskState _captureNodeMiddleFirst) != "Succeeded") then {
								_captureNodeMiddleFirst setTaskState "Succeeded";
							};
						};

						// announce change
						_captureNodesMiddle setTaskState "Succeeded";
						["Tasksucceeded",["","Capture at least 2 central nodes"]] call BIS_fnc_showNotification;

						// create primary deposit task
						if (isNull _captureNodeCentral) then {
							_captureNodeCentral = _unitToInform createSimpleTask ["Capture primary deposit"];
							_captureNodeCentral setSimpleTaskDescription [
							   "Capturing and holding primary deposit node allows you to reach victory conditions.",
							   "Capture primary deposit",
							   "Capture primary deposit"
							];
							_captureNodeCentral setSimpleTaskDestination _centralNode;

							// announce change
							_captureNodeCentral setTaskState "Assigned";
							["TaskAssigned",["","Capture primary deposit"]] call BIS_fnc_showNotification;
						} else {
							_captureNodeCentral setTaskState "Assigned";
						};
					};

					_nearestTower = nearestObjects [_centralNode, [_controlTType], 10];
					if ((count _nearestTower) > 0) then {
						if (((_nearestTower select 0) getVariable "ow_wip_progress") >= 1.0) then {
							_depositCaptured = true;
						};
					} else {
						_depositCaptured = false;
						// check if player had this node captured
						if (!(isNull _captureNodeCentral)) then {
							if ((taskState _captureNodeCentral) == "Succeeded") then {
								// announce task update
								_captureNodeCentral setTaskState "Assigned";
								["TaskAssigned", ["","Capture primary deposit"]] call BIS_fnc_showNotification;

								if (!(isNull _collect1kSiberite)) then {
									if ((taskState _collect1kSiberite) == "Assigned") then {
										_wordForSiberite = "siberite";
										if (_controlTType == "control_tower_ru") then {
											_wordForSiberite = "alaskite";
										};
										// announce task update
										_collect1kSiberite setTaskState "Failed";
										["TaskFailed", ["",format ["Collect 1000 %1", _wordForSiberite]]] call BIS_fnc_showNotification;
									};
								};
							};
						};
					};

					if (((taskState _captureNodeCentral) == "Assigned") && _depositCaptured) then {
						// announce task update
						_captureNodeCentral setTaskState "Succeeded";
						["Tasksucceeded",["","Capture primary deposit"]] call BIS_fnc_showNotification;
					};

					// central success
					if (((taskState _captureNodeCentral) == "Succeeded") && _depositCaptured) then {
						if (isNull _collect1kSiberite) then {
							_wordForSiberite = "siberite";
							if (_controlTType == "control_tower_ru") then {
								_wordForSiberite = "alaskite";
							};
							_collect1kSiberite = _unitToInform createSimpleTask [format ["Collect 1000 %1", _wordForSiberite]];
							_collect1kSiberite setSimpleTaskDescription [
							   format ["Achieve a total domination over the lands of Pliocen by collecting 1000 units of %1.", _wordForSiberite],
							   format ["Collect 1000 %1", _wordForSiberite],
							   format ["Collect 1000 %1", _wordForSiberite]
							];
							_collect1kSiberite setSimpleTaskDestination _centralNode;

							// announce task update
							_collect1kSiberite setTaskState "Assigned";
							["TaskAssigned",["", format ["Collect 1000 %1", _wordForSiberite]]] call BIS_fnc_showNotification;
						};

						if ((((_nearestTower select 0) getVariable "ow_wrhs_siberite") >= 1000) && ((taskState _collect1kSiberite) == "Assigned")) then {
							_wordForSiberite = "siberite";
							if (_controlTType == "control_tower_ru") then {
								_wordForSiberite = "alaskite";
							};
							// mission success
							// announce task update
							_collect1kSiberite setTaskState "Succeeded";
							["Tasksucceeded",["", format ["Collect 1000 %1", _wordForSiberite]]] call BIS_fnc_showNotification;

							switch (_controlTType) do {
								case "control_tower_am": {
									owr_stopmusic = true;
									"EventTrack02_F_Curator" remoteExec ["playMusic", 0];
									playMusic "owr_am_vic";
								};
								case "control_tower_ru": {
									owr_stopmusic = true;
									"EventTrack02_F_Curator" remoteExec ["playMusic", 0];
									playMusic "owr_ru_vic";
								};
								case "control_tower_ar": {
									owr_stopmusic = true;
									"EventTrack02_F_Curator" remoteExec ["playMusic", 0];
									playMusic "owr_ar_vic";
								};
								default {};
							};
						};
					};
				};
			};
		} else {
			// entry node is not captured or has been lost
			if (isNull _captureNodeEntry) then {
				_captureNodeEntry = _unitToInform createSimpleTask ["Capture entry node"];
				_captureNodeEntry setSimpleTaskDestination _entryNode;
				_captureNodeEntry setSimpleTaskDescription [
				   "Capturing and holding entry point will gain your side access to central nodes.",
				   "Capture entry node",
				   "Capture entry node"
				];

				// announce change
				_captureNodeEntry setTaskState "Assigned";
				["TaskAssigned",["","Capture entry node"]] call BIS_fnc_showNotification;
			};

			if ((taskState _captureNodeEntry) == "Succeeded") then {
				_captureNodeEntry setTaskState "Assigned";
				["TaskAssigned",["","Capture entry node"]] call BIS_fnc_showNotification;
			};
		};
		sleep 1;
	};

};
owr_fn_unitGetNextBehaviour = {
	_unit = _this select 0;
	_nextBehaviour = "";
	switch (behaviour _unit) do {
		case "CARELESS": {
			_nextBehaviour = "SAFE";
		};
		case "SAFE": {
			_nextBehaviour = "AWARE";
		};
		case "AWARE": {
			_nextBehaviour = "COMBAT";
		};
		case "COMBAT": {
			_nextBehaviour = "STEALTH";
		};
		case "STEALTH": {
			_nextBehaviour = "CARELESS";
		};
	};
	_nextBehaviour
};
owr_fn_getOutOfVehicle = {
	_unitToHandle = _this select 0;
	_vehicle = vehicle _unitToHandle;
	_unitToHandle setBehaviour "AWARE";
	_unitToHandle leaveVehicle _vehicle;
};
owr_fn_stopCombatWaypoint = {
	_unitToHandle = _this select 0;
	sleep 0.01;
	_unitToHandle setBehaviour "AWARE";
};
owr_fn_materialization_effect = {
	_materializedObject = _this select 0;

	// sound starts, wait until it reaches max amp
	sleep 1.7;

	// flash
	_light = "#lightpoint" createvehiclelocal (getPos _materializedObject);
	_light setposatl [(getPos _materializedObject) select 0, (getPos _materializedObject) select 1, ((getPos _materializedObject) select 2) + 10];
	_light setLightDayLight true;
	_light setLightBrightness 300;
	_light setLightAmbient [0.05, 0.05, 0.1];
	_light setlightcolor [1, 1, 2];
	sleep 0.1;
	_light setLightBrightness 0;
	deleteVehicle _light;
};
owr_fn_createPointLight = {
	_lightPos = _this select 0;
	_light = "#lightpoint" createVehicle _lightPos;
	_light setLightBrightness 0.6;
	_light setLightAmbient [0.1, 0.1, 0.1];
	_light setLightColor [1.0, 0.89, 0.807];
};
owr_fn_removePointLight = {
	_lightPos = _this select 0;
	_light = nearestObject [_lightPos, "#lightpoint"];
	deleteVehicle _light;
};
owr_fn_backgroundMusic = {
	_side = _this select 0;

	switch (_side) do {
		case "am": {
			_tracksPrep = ["owr_am_prepa", "owr_am_prepb", "owr_am_prepc", "owr_am_prepd", "owr_am_prepe", "owr_am_prepf", "owr_am_prepg", "owr_am_preph"];
			_tracksRoam = ["owr_am_roama", "owr_am_roamb", "owr_am_roamc"];
			while {!owr_stopmusic} do {
				_randCat = random 10;
				_trackToPlay = "";
				if (_randCat < 4) then {
					_trackToPlay = selectRandom _tracksPrep;
				} else {
					_trackToPlay = selectRandom _tracksRoam;
				};

				playMusic _trackToPlay;
				_timeToWait = 2 + (getNumber (configFile >> "CfgMusic" >> _trackToPlay >> "duration"));
				sleep _timeToWait;
			};
		};
		case "ru": {
			_tracksPrep = ["owr_ru_prepa", "owr_ru_prepb", "owr_ru_prepc"];
			_tracksRoam = ["owr_ru_roama", "owr_ru_roamb", "owr_ru_roamc", "owr_ru_roamd"];
			while {!owr_stopmusic} do {
				_randCat = random 10;
				_trackToPlay = "";
				if (_randCat < 4) then {
					_trackToPlay = selectRandom _tracksPrep;
				} else {
					_trackToPlay = selectRandom _tracksRoam;
				};

				playMusic _trackToPlay;
				_timeToWait = 2 + (getNumber (configFile >> "CfgMusic" >> _trackToPlay >> "duration"));
				sleep _timeToWait;
			};
		};
		case "ar": {
			_tracksPrep = ["owr_ar_prepa", "owr_ar_prepb", "owr_ar_prepc","owr_ar_prepd", "owr_ar_prepe", "owr_ar_prepf","owr_ar_prepg", "owr_ar_preph"];
			_tracksRoam = ["owr_ar_roama", "owr_ar_roamb", "owr_ar_roamc","owr_ar_roamd", "owr_ar_roame", "owr_ar_roamf","owr_ar_roamg", "owr_ar_roamh"];
			while {!owr_stopmusic} do {
				_randCat = random 10;
				_trackToPlay = "";
				if (_randCat < 4) then {
					_trackToPlay = selectRandom _tracksPrep;
				} else {
					_trackToPlay = selectRandom _tracksRoam;
				};

				playMusic _trackToPlay;
				_timeToWait = 2 + (getNumber (configFile >> "CfgMusic" >> _trackToPlay >> "duration"));
				sleep _timeToWait;
			};
		};
	};
};
owr_fn_unitScanner = {
	_unitToScan = _this select 0;
	_classesToScan = "";
	_side = 0;
	switch (_unitToScan) do {
		case bis_curator_west: {
			_side = west;
			_classesToScan = ["owr_man_am", "owr_am_light_wheeled", "owr_am_medium_wheeled", "owr_am_medium_tracked", "owr_am_heavy_tracked", "owr_base6c_am", "owr_base0c_am"];
		};
		case bis_curator_east: {
			_side = east;
			_classesToScan = ["owr_man_ru", "owr_ru_heavy_tracked", "owr_ru_heavy_wheeled", "owr_ru_medium_tracked", "owr_ru_medium_wheeled", "owr_base6c_ru", "owr_base0c_ru"];
		};
		case bis_curator_arab: {
			_side = resistance;
			_classesToScan = ["owr_man_ar", "owr_base6c_ar", "owr_base0c_ar"];
		};
	};

	while {true} do {
		_unitsAroundCam = curatorCamera nearEntities [_classesToScan, 60];
		_i = 0;
		for "_i" from 0 to ((count _unitsAroundCam)  - 1) do {
			_unit = _unitsAroundCam select _i;

			// check for turrets, replace hp bar of base with the one of the turret itself
			if ((_unit isKindOf "owr_base0c_am") || (_unit isKindOf "owr_base0c_ru") || (_unit isKindOf "owr_base0c_ar")) then {
				if ((_unit isKindOf "aturret_am") || (_unit isKindOf "aturret_ru") || (_unit isKindOf "mturret_am") || (_unit isKindOf "mturret_ru") || (_unit isKindOf "mturret_ar")) then {
					if (!(isNull (_unit getVariable "ow_turret_weapon"))) then {
						_unitsAroundCam set [_i, (_unit getVariable "ow_turret_weapon")];
					} else {
						_unitsAroundCam set [_i, objNull];
					};
				};
			};
		};
		_unitToScan setVariable ["ow_units_around", _unitsAroundCam];
		sleep 1;
	};
};
owr_fn_am_fov = {
	onEachFrame {
		_healthInfoAroundCamera = bis_curator_west getVariable "ow_units_around";

		{
			_dmg_bar_color = [0,1,0,1];
			if (((damage _x) > 0.55) && ((damage _x) <= 0.85)) then {
				_dmg_bar_color = [0.937,0.839,0,1];
			} else {
				if ((damage _x) > 0.85) then {
					_dmg_bar_color = [1,0,0,1];
				};
			};
			drawIcon3D ["\owr\ui\data\bar_damage_co.paa", _dmg_bar_color, [(getPos _x) select 0, (getPos _x) select 1, 2], 1.5 - (1.25 * (damage _x)), 0.08, 45];

			// show fuel - if car and not siberite engine
			if ((_x isKindOf "owr_car")) then {
				if (((_x getVariable "ow_vehicle_template") select 1) == 0) then {
					_fuel_bar_color = [0.952,0.694,0,1];
					if ((fuel _x) < 0.15) then {
						_fuel_bar_color = [1,0,0,1];
					};
					drawIcon3D ["\owr\ui\data\bar_damage_co.paa", _fuel_bar_color, [(getPos _x) select 0, (getPos _x) select 1, 1.9], (1.25 * (fuel _x)), 0.08, 45];
				} else {
					if (((_x getVariable "ow_vehicle_template") select 1) == 2) then {
						_fuel_bar_color = [0.380,0.6,1,1];
						if ((fuel _x) < 0.15) then {
							_fuel_bar_color = [1,0,0,1];
						};
						drawIcon3D ["\owr\ui\data\bar_damage_co.paa", _fuel_bar_color, [(getPos _x) select 0, (getPos _x) select 1, 1.9], (1.25 * (fuel _x)), 0.08, 45];
					};
				};
			};

			// show building progress
			if ((_x isKindOf "owr_base0c") || (_x isKindOf "owr_base6c")) then {
				if ((_x getVariable "ow_wip_progress") < 1.0) then {
					_fuel_bar_color = [0.952,0.694,0,1];
					drawIcon3D ["\owr\ui\data\bar_damage_co.paa", _fuel_bar_color, [(getPos _x) select 0, (getPos _x) select 1, 1.9], (1.25 * ((_x getVariable "ow_wip_progress"))), 0.08, 45];
				};
				if (_x isKindOf "lab_am") then {
					// owr_fn_getResearchProgress
					if (_x getVariable "ow_curr_res_cat" != "") then {
						_fuel_bar_color = [0.952,0.694,0,1];
						_progress = [_x getVariable "ow_curr_res_cat", _x getVariable "ow_curr_res_index", bis_curator_west] call owr_fn_getResearchProgress;
						drawIcon3D ["\owr\ui\data\bar_damage_co.paa", _fuel_bar_color, [(getPos _x) select 0, (getPos _x) select 1, 1.9], (1.25 * (_progress)), 0.08, 45];
					};
				};
			};

			//drawLine3D [[(getPos _x) select 0, ((getPos _x) select 1) - 1], [(getPos _x) select 0, ((getPos _x) select 1) + 1], [1,0,0,1]];
		} forEach (_healthInfoAroundCamera);
	};
};
owr_fn_ru_fov = {
	onEachFrame {
		_healthInfoAroundCamera = bis_curator_east getVariable "ow_units_around";

		{
			_dmg_bar_color = [0,1,0,1];
			if (((damage _x) > 0.55) && ((damage _x) <= 0.85)) then {
				_dmg_bar_color = [0.937,0.839,0,1];
			} else {
				if ((damage _x) > 0.85) then {
					_dmg_bar_color = [1,0,0,1];
				};
			};
			drawIcon3D ["\owr\ui\data\bar_damage_co.paa", _dmg_bar_color, [(getPos _x) select 0, (getPos _x) select 1, 2], 1.5 - (1.25 * (damage _x)), 0.08, 45];

			// show fuel - if car and not siberite engine
			if ((_x isKindOf "owr_car")) then {
				if (((_x getVariable "ow_vehicle_template") select 1) == 0) then {
					_fuel_bar_color = [0.952,0.694,0,1];
					if ((fuel _x) < 0.15) then {
						_fuel_bar_color = [1,0,0,1];
					};
					drawIcon3D ["\owr\ui\data\bar_damage_co.paa", _fuel_bar_color, [(getPos _x) select 0, (getPos _x) select 1, 1.9], (1.25 * (fuel _x)), 0.08, 45];
				} else {
					if (((_x getVariable "ow_vehicle_template") select 1) == 2) then {
						_fuel_bar_color = [0.380,0.6,1,1];
						if ((fuel _x) < 0.15) then {
							_fuel_bar_color = [1,0,0,1];
						};
						drawIcon3D ["\owr\ui\data\bar_damage_co.paa", _fuel_bar_color, [(getPos _x) select 0, (getPos _x) select 1, 1.9], (1.25 * (fuel _x)), 0.08, 45];
					};
				};
			};

			// show building progress
			if ((_x isKindOf "owr_base0c") || (_x isKindOf "owr_base6c")) then {
				if ((_x getVariable "ow_wip_progress") < 1.0) then {
					_fuel_bar_color = [0.952,0.694,0,1];
					drawIcon3D ["\owr\ui\data\bar_damage_co.paa", _fuel_bar_color, [(getPos _x) select 0, (getPos _x) select 1, 1.9], (1.25 * ((_x getVariable "ow_wip_progress"))), 0.08, 45];
				};
				if (_x isKindOf "lab_ru") then {
					// owr_fn_getResearchProgress
					if (_x getVariable "ow_curr_res_cat" != "") then {
						_fuel_bar_color = [0.952,0.694,0,1];
						_progress = [_x getVariable "ow_curr_res_cat", _x getVariable "ow_curr_res_index", bis_curator_east] call owr_fn_getResearchProgress;
						drawIcon3D ["\owr\ui\data\bar_damage_co.paa", _fuel_bar_color, [(getPos _x) select 0, (getPos _x) select 1, 1.9], (1.25 * (_progress)), 0.08, 45];
					};
				};
			};

			//drawLine3D [[(getPos _x) select 0, ((getPos _x) select 1) - 1], [(getPos _x) select 0, ((getPos _x) select 1) + 1], [1,0,0,1]];
		} forEach (_healthInfoAroundCamera);
	};
};
owr_fn_ar_fov = {
	onEachFrame {
		_healthInfoAroundCamera = bis_curator_arab getVariable "ow_units_around";

		{
			_dmg_bar_color = [0,1,0,1];
			if (((damage _x) > 0.55) && ((damage _x) <= 0.85)) then {
				_dmg_bar_color = [0.937,0.839,0,1];
			} else {
				if ((damage _x) > 0.85) then {
					_dmg_bar_color = [1,0,0,1];
				};
			};
			drawIcon3D ["\owr\ui\data\bar_damage_co.paa", _dmg_bar_color, [(getPos _x) select 0, (getPos _x) select 1, 2], 1.5 - (1.25 * (damage _x)), 0.08, 45];

			// show fuel - if car and not siberite engine
			if ((_x isKindOf "owr_car")) then {
				if (((_x getVariable "ow_vehicle_template") select 1) == 0) then {
					_fuel_bar_color = [0.952,0.694,0,1];
					if ((fuel _x) < 0.15) then {
						_fuel_bar_color = [1,0,0,1];
					};
					drawIcon3D ["\owr\ui\data\bar_damage_co.paa", _fuel_bar_color, [(getPos _x) select 0, (getPos _x) select 1, 1.9], (1.25 * (fuel _x)), 0.08, 45];
				} else {
					if (((_x getVariable "ow_vehicle_template") select 1) == 2) then {
						_fuel_bar_color = [0.380,0.6,1,1];
						if ((fuel _x) < 0.15) then {
							_fuel_bar_color = [1,0,0,1];
						};
						drawIcon3D ["\owr\ui\data\bar_damage_co.paa", _fuel_bar_color, [(getPos _x) select 0, (getPos _x) select 1, 1.9], (1.25 * (fuel _x)), 0.08, 45];
					};
				};
			};

			// show building progress
			if ((_x isKindOf "owr_base0c") || (_x isKindOf "owr_base6c")) then {
				if ((_x getVariable "ow_wip_progress") < 1.0) then {
					_fuel_bar_color = [0.952,0.694,0,1];
					drawIcon3D ["\owr\ui\data\bar_damage_co.paa", _fuel_bar_color, [(getPos _x) select 0, (getPos _x) select 1, 1.9], (1.25 * ((_x getVariable "ow_wip_progress"))), 0.08, 45];
				};
				if (_x isKindOf "lab_ar") then {
					// owr_fn_getResearchProgress
					if (_x getVariable "ow_curr_res_cat" != "") then {
						_fuel_bar_color = [0.952,0.694,0,1];
						_progress = [_x getVariable "ow_curr_res_cat", _x getVariable "ow_curr_res_index", bis_curator_arab] call owr_fn_getResearchProgress;
						drawIcon3D ["\owr\ui\data\bar_damage_co.paa", _fuel_bar_color, [(getPos _x) select 0, (getPos _x) select 1, 1.9], (1.25 * (_progress)), 0.08, 45];
					};
				};
			};

			//drawLine3D [[(getPos _x) select 0, ((getPos _x) select 1) - 1], [(getPos _x) select 0, ((getPos _x) select 1) + 1], [1,0,0,1]];
		} forEach (_healthInfoAroundCamera);
	};
};
owr_fn_addEntityToCurator = {
	// only executed on server!
	if (!(isServer)) exitWith {};

	_entity = _this select 0;
	_curator = _this select 1;

	_curator addCuratorEditableObjects [[_entity], false];
};
owr_fn_materialization_forecast = {
	_cratesPoses = _this select 0;

	if ((player == bis_curatorUnit_east) || (player isKindOf "owr_man_ru")) then {
		_j = 0;

		playSound "owr_ui_mat_detection";
		for "_j" from 0 to ((count _cratesPoses) - 1) do {
			format ["crate_predict_%1", _j] setMarkerPosLocal (_cratesPoses select _j);
		};

		_i = 0;
		_scale = 0.25;
		for "_i" from 0 to 10 do {
			for "_j" from 0 to ((count _cratesPoses) - 1) do {
				format ["crate_predict_%1", _j] setMarkerSizeLocal [_scale, _scale];
			};
			sleep 0.1;
			_scale = _scale + 0.1;
		};

		_i = 0;
		_scale = 0.25;
		for "_i" from 0 to 10 do {
			for "_j" from 0 to ((count _cratesPoses) - 1) do {
				format ["crate_predict_%1", _j] setMarkerSizeLocal [_scale, _scale];
			};
			sleep 0.1;
			_scale = _scale + 0.1;
		};

		_i = 0;
		_scale = 0.25;
		for "_i" from 0 to 10 do {
			for "_j" from 0 to ((count _cratesPoses) - 1) do {
				format ["crate_predict_%1", _j] setMarkerSizeLocal [_scale, _scale];
			};
			sleep 0.1;
			_scale = _scale + 0.1;
		};

		_i = 0;
		_scale = 0.25;
		for "_i" from 0 to 10 do {
			for "_j" from 0 to ((count _cratesPoses) - 1) do {
				format ["crate_predict_%1", _j] setMarkerSizeLocal [_scale, _scale];
			};
			sleep 0.1;
			_scale = _scale + 0.1;
		};

		_i = 0;
		_scale = 0.25;
		for "_i" from 0 to 10 do {
			for "_j" from 0 to ((count _cratesPoses) - 1) do {
				format ["crate_predict_%1", _j] setMarkerSizeLocal [_scale, _scale];
			};
			sleep 0.1;
			_scale = _scale + 0.1;
		};

		sleep 40;
		for "_j" from 0 to ((count _cratesPoses) - 1) do {
			format ["crate_predict_%1", _j] setMarkerSizeLocal [0, 0];
		};
	};
};
owr_fn_materialization_detect = {
	// keeps an info about last 10 shipments
	_newPos = _this select 0;

	if (player == bis_curatorUnit_west) then {
		// shift fifo and insert new pos
		_currentPositions = [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]];
		_i = 0;
		for "_i" from 0 to 39 do {
			_currentPositions set [_i, (bis_curator_west getVariable "ow_am_mat_detect_poses") select _i];
		};

		_i = 0;
		for "_i" from 1 to 39 do {
			_currentPositions set [_i, (bis_curator_west getVariable "ow_am_mat_detect_poses") select (_i - 1)];
		};
		_currentPositions set [0, _newPos];
		bis_curator_west setVariable ["ow_am_mat_detect_poses", _currentPositions, true];
		//hint format ["%1", (bis_curator_west getVariable "ow_am_mat_detect_poses")];
	};

	if ((player isKindOf "owr_man_am") || (player == bis_curatorUnit_west)) then {
		// update markers
		_i = 0;
		for "_i" from 0 to 39 do {
			if ((((bis_curator_west getVariable "ow_am_mat_detect_poses") select _i) select 0) != 0) then {
				format ["crate_detect_%1", _i] setMarkerPosLocal ((bis_curator_west getVariable "ow_am_mat_detect_poses") select _i);
			};
		};
	};
	//hintSilent format ["%1", (bis_curator_west getVariable "ow_am_mat_detect_poses")];
};
owr_fn_siberite_detect = {
	// bis_curator_east owr_ru_siberite_sources
	for "_i" from 0 to ((count (bis_curator_east getVariable "owr_ru_siberite_sources")) - 1) do {
		createMarkerLocal [format ["sib_detect_sources_%1",_i], (bis_curator_east getVariable "owr_ru_siberite_sources") select _i];
		format ["sib_detect_sources_%1",_i] setMarkerTypeLocal "mil_dot";
		format ["sib_detect_sources_%1",_i] setMarkerColorLocal "ColorGreen";
	};

	// create a sufficient amount of markers for siberite engine detection (lets say 100)
	_i = 0;
	for "_i" from 0 to 99 do {
		createMarkerLocal [format ["sib_detect_cars_%1",_i], [0,0]];
		format ["sib_detect_cars_%1",_i] setMarkerTypeLocal "mil_dot";
		format ["sib_detect_cars_%1",_i] setMarkerColorLocal "ColorGreen";
	};

	while {true} do {
		_owr_cars = [2500, 2500] nearEntities [["owr_car", "power_sib_am", "power_sib_ru", "warehouse_am", "warehouse_ru"], 4000];
		_i = 0;
		{
			_entity = _owr_cars select _i;
			_include = false;
			// check if it is car
			if (_entity isKindOf "owr_car") then {
				if (((_entity getVariable "ow_vehicle_template") select 1) == 1) then {
					_include = true;
				};
			} else {
				// check if it is power plant
				if ((_entity isKindOf "power_sib_am") || (_entity isKindOf "power_sib_ru")) then {
					_include = true;
				};
				// check if it is warehouse with siberite stored
				if ((_entity isKindOf "warehouse_am") || (_entity isKindOf "warehouse_ru")) then {
					if ((_entity getVariable "ow_wrhs_siberite") > 0) then {
						_include = true;
					};
				};
			};
			if (_include) then {
				format ["sib_detect_cars_%1",_i] setMarkerPosLocal (getPos (_entity));
			};
			_i = _i + 1;
		} forEach _owr_cars;

		if (_i < 99) then {
			// reset not used markers to 0,0
			_j = 0;
			for "_j" from _i to 99 do {
				format ["sib_detect_cars_%1",_j] setMarkerPosLocal [0,0];
			};
		};
		sleep 3;
	};
};
owr_fn_messageBoxInit = {
	disableSerialization;
	_display = findDisplay 312;

	/* message box - test
	 	disableSerialization;
		disp = findDisplay 312;
		messageBox = disp displayctrl 11220;

		ctrlShown messageBox;
	*/ 
	_messageBox = _display displayctrl 11220;
	_messageBox ctrlShow false;
	//_messageBox ctrlEnable false;
	_messageBoxPicture = _display displayctrl 112201;
	_messageBoxPicture ctrlSetText "";
};
owr_fn_message = {
	_who = _this select 0;			// name of the chracters
	_what = _this select 1;			// building finished,..
	_whatExactly = _this select 2;	// [what kind of building]
	_where = _this select 3;		// [mapGridPosition]

	if ((player == bis_curatorUnit_west) && ((side _who) != west)) exitWith {};
	if ((player == bis_curatorUnit_east) && ((side _who) != east)) exitWith {};
	if ((player == bis_curatorUnit_arab) && ((side _who) != resistance)) exitWith {};

	disableSerialization;
	_display = findDisplay 312;
	_messageBox = _display displayctrl 11220;
	_messageBoxText = _display displayctrl 112202;
	_messageBoxPicture = _display displayctrl 112201;
	if ((ctrlText _messageBoxPicture) != "") then {
		// probably some message already visible
		// lets wait for a bit - TEMPORARY WAIT
		sleep 3.5;
	};

	_messageBox ctrlShow true;

	_messageBoxText ctrlSetStructuredText parseText format["<t size='0.70' color='#ffffff' shadow='2'>%1: %2 [%3][%4]</t>", name _who, _what, _whatExactly, _where];

	if (!(_who getVariable "ow_ctype")) then {
		switch (_who getVariable "ow_class") do {
			case 0: {
				_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_soldier.paa", _who];
			};
			case 1: {
				_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_worker.paa", _who];
			};
			case 2: {
				_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_mechanic.paa", _who];
			};
			case 3: {
				_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_scientist.paa", _who];
			};
			default {
			};
		};
	} else {
		_characterIndex = 0;
		switch (player) do {
			case bis_curatorUnit_west: {
				_i = 0;
				{
					if (_x == _who) then {
						_characterIndex = _i;
					};
					_i = _i + 1;
				} forEach (bis_curator_west getVariable "owr_am_characters_d");

				switch (_who getVariable "ow_class") do {
					case 0: {
						_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_soldier.paa", ((bis_curator_west getVariable "owr_am_characters_di") select _characterIndex)];
					};
					case 1: {
						_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_worker.paa", ((bis_curator_west getVariable "owr_am_characters_di") select _characterIndex)];
					};
					case 2: {
						_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_mechanic.paa", ((bis_curator_west getVariable "owr_am_characters_di") select _characterIndex)];
					};
					case 3: {
						_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_scientist.paa", ((bis_curator_west getVariable "owr_am_characters_di") select _characterIndex)];
					};
					default {
					};
				};
			};
			case bis_curatorUnit_east: {
				_i = 0;
				{
					if (_x == _who) then {
						_characterIndex = _i;
					};
					_i = _i + 1;
				} forEach (bis_curator_east getVariable "owr_ru_characters_d");

				switch (_who getVariable "ow_class") do {
					case 0: {
						_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_soldier.paa", ((bis_curator_east getVariable "owr_ru_characters_di") select _characterIndex)];
					};
					case 1: {
						_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_worker.paa", ((bis_curator_east getVariable "owr_ru_characters_di") select _characterIndex)];
					};
					case 2: {
						_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_mechanic.paa", ((bis_curator_east getVariable "owr_ru_characters_di") select _characterIndex)];
					};
					case 3: {
						_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_scientist.paa", ((bis_curator_east getVariable "owr_ru_characters_di") select _characterIndex)];
					};
					default {
					};
				};
			};
			case bis_curatorUnit_arab: {
				_i = 0;
				{
					if (_x == _who) then {
						_characterIndex = _i;
					};
					_i = _i + 1;
				} forEach (bis_curator_east getVariable "owr_ar_characters_d");

				switch (_who getVariable "ow_class") do {
					case 0: {
						_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_soldier.paa", ((bis_curator_arab getVariable "owr_ar_characters_di") select _characterIndex)];
					};
					case 1: {
						_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_worker.paa", ((bis_curator_arab getVariable "owr_ar_characters_di") select _characterIndex)];
					};
					case 2: {
						_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_mechanic.paa", ((bis_curator_arab getVariable "owr_ar_characters_di") select _characterIndex)];
					};
					case 3: {
						_messageBoxPicture ctrlSetText format["\owr\ui\data\characters\%1_scientist.paa", ((bis_curator_arab getVariable "owr_ar_characters_di") select _characterIndex)];
					};
					default {
					};
				};
			};
		};
	};


	sleep 7.5;
	_messageBoxPicture ctrlSetText "";
	_messageBox ctrlShow false;
};
owr_fn_isAllowedToResearch = {
	_category = _this select 0;
	_researchId = _this select 1;
	_side = _this select 2;

	_sideStr = "";
	switch (_side) do {
		case bis_curator_west: {
			_sideStr = "am";
		};
		case bis_curator_east: {
			_sideStr = "ru";
		};
	};



	_allowed = true;
	switch (_category) do {
		case "basic": {
			_dependencyArray = ((_side getVariable format["ow_%1_res_basic_dep", _sideStr]) select _researchId);
			for "_i" from 0 to (count _dependencyArray) do {
				if (((_side getVariable format["ow_%1_res_basic_prog", _sideStr]) select (_dependencyArray select _i)) < 1.0) then {
					_allowed = false;
				};
			};
		};
		case "weap": {
			_dependencyArray = ((_side getVariable format["ow_%1_res_weap_dep", _sideStr]) select _researchId);
			for "_i" from 0 to (count _dependencyArray) do {
				if (((_side getVariable format["ow_%1_res_weap_prog", _sideStr]) select (_dependencyArray select _i)) < 1.0) then {
					_allowed = false;
				};
			};
		};
		case "siberite": {
			_dependencyArray = ((_side getVariable format["ow_%1_res_siberite_dep", _sideStr]) select _researchId);
			for "_i" from 0 to (count _dependencyArray) do {
				if (((_side getVariable format["ow_%1_res_siberite_prog", _sideStr]) select (_dependencyArray select _i)) < 1.0) then {
					_allowed = false;
				};
			};
		};
		case "opto": {
			_dependencyArray = ((_side getVariable format["ow_%1_res_opto_dep", "am"]) select _researchId);
			for "_i" from 0 to (count _dependencyArray) do {
				if (((_side getVariable format["ow_%1_res_opto_prog", "am"]) select (_dependencyArray select _i)) < 1.0) then {
					_allowed = false;
				};
			};
		};
		case "time": {
			_dependencyArray = ((_side getVariable format["ow_%1_res_time_dep", "ru"]) select _researchId);
			for "_i" from 0 to (count _dependencyArray) do {
				if (((_side getVariable format ["ow_%1_res_time_prog", "ru"]) select (_dependencyArray select _i)) < 1.0) then {
					_allowed = false;
				};
			};
		};
		case "comp": {
			_dependencyArray = ((_side getVariable format["ow_%1_res_comp_dep", _sideStr]) select _researchId);
			for "_i" from 0 to (count _dependencyArray) do {
				if (((_side getVariable format["ow_%1_res_comp_prog", _sideStr]) select (_dependencyArray select _i)) < 1.0) then {
					_allowed = false;
				};
			};
		};
	};

	if (owr_devhax) then {
		true
	} else {
		_allowed
	};
};
owr_fn_isResearchComplete = {
	_category = _this select 0;
	_researchId = _this select 1;
	_side = _this select 2;

	_complete = false;
	switch (_category) do {
		case "basic": {
			if (_side == bis_curator_west) then {
				if (((_side getVariable "ow_am_res_basic_prog") select _researchId) >= 1.0) then {
					_complete = true;
				};
			};
			if (_side == bis_curator_east) then {
				if (((_side getVariable "ow_ru_res_basic_prog") select _researchId) >= 1.0) then {
					_complete = true;
				};
			};
		};
		case "weap": {
			if (_side == bis_curator_west) then {
				if (((_side getVariable "ow_am_res_weap_prog") select _researchId) >= 1.0) then {
					_complete = true;
				};
			};
			if (_side == bis_curator_east) then {
				if (((_side getVariable "ow_ru_res_weap_prog") select _researchId) >= 1.0) then {
					_complete = true;
				};
			};
		};
		case "siberite": {
			if (_side == bis_curator_west) then {
				if (((_side getVariable "ow_am_res_siberite_prog") select _researchId) >= 1.0) then {
					_complete = true;
				};
			};
			if (_side == bis_curator_east) then {
				if (((_side getVariable "ow_ru_res_siberite_prog") select _researchId) >= 1.0) then {
					_complete = true;
				};
			};
		};
		case "comp": {
			if (_side == bis_curator_west) then {
				if (((_side getVariable "ow_am_res_comp_prog") select _researchId) >= 1.0) then {
					_complete = true;
				};
			};
			if (_side == bis_curator_east) then {
				if (((_side getVariable "ow_ru_res_comp_prog") select _researchId) >= 1.0) then {
					_complete = true;
				};
			};
		};

		// side specific
		case "opto": {
			if (((_side getVariable "ow_am_res_opto_prog") select _researchId) >= 1.0) then {
				_complete = true;
			};
		};
		case "time": {
			if (((_side getVariable "ow_ru_res_time_prog") select _researchId) >= 1.0) then {
				_complete = true;
			};
		};
	};

	if (owr_devhax) then {
		true
	} else {
		_complete
	};
};
owr_fn_getResearchProgress = {
	_resCat = _this select 0;
	_resId = _this select 1;
	_side = _this select 2;
	_sideStr = "";
	switch (_side) do {
		case bis_curator_west: {
			_sideStr = "am";
		};
		case bis_curator_east: {
			_sideStr = "ru";
		};
	};

	_progress = 0.0;
	switch (_resCat) do {
		case "basic": {
			_progress = ((_side getVariable (format ["ow_%1_res_basic_prog", _sideStr])) select _resId);
		};
		case "weap": {
			_progress = ((_side getVariable (format ["ow_%1_res_weap_prog", _sideStr])) select _resId);
		};
		case "siberite": {
			_progress = ((_side getVariable (format ["ow_%1_res_siberite_prog", _sideStr])) select _resId);
		};
		case "opto": {
			_progress = ((_side getVariable (format ["ow_%1_res_opto_prog", "am"])) select _resId);
		};
		case "time": {
			_progress = ((_side getVariable (format ["ow_%1_res_time_prog", "ru"])) select _resId);
		};
		case "comp": {
			_progress = ((_side getVariable (format ["ow_%1_res_comp_prog", _sideStr])) select _resId);
		};
	};
	_progress
};
owr_fn_getResearchName = {
	_resCat = _this select 0;
	_resId = _this select 1;
	_side = _this select 2;
	_sideStr = "";
	switch (_side) do {
		case bis_curator_west: {
			_sideStr = "am";
		};
		case bis_curator_east: {
			_sideStr = "ru";
		};
	};

	_resName = "";
	switch (_resCat) do {
		case "basic": {
			_resName = ((_side getVariable (format ["ow_%1_res_basic_strings", _sideStr])) select _resId);
		};
		case "weap": {
			_resName = ((_side getVariable (format ["ow_%1_res_weap_strings", _sideStr])) select _resId);
		};
		case "siberite": {
			_resName = ((_side getVariable (format ["ow_%1_res_siberite_strings", _sideStr])) select _resId);
		};
		case "opto": {
			_resName = ((_side getVariable (format ["ow_%1_res_opto_strings", "am"])) select _resId);
		};
		case "time": {
			_resName = ((_side getVariable (format ["ow_%1_res_time_strings", "ru"])) select _resId);
		};
		case "comp": {
			_resName = ((_side getVariable (format ["ow_%1_res_comp_strings", _sideStr])) select _resId);
		};
	};
	_resName
};
owr_fn_getAMVehicleClass = {
	_templateArray = _this select 0;
	_chassis = "lt_wh";
	switch (_templateArray select 0) do {
		case 1: {_chassis = "me_wh";};
		case 2: {_chassis = "me_tr";};
		case 3: {_chassis = "hv_tr";};
		case 4: {_chassis = "mg";};
	};
	_engine = "cb";
	switch (_templateArray select 1) do {
		case 1: {_engine = "sb";};
		case 2: {_engine = "el";};
	};
	_control = "mn";
	switch (_templateArray select 2) do {
		case 1: {_control = "ai";};
		case 2: {_control = "rt";};
	};
	_function = "mgun";
	switch (_templateArray select 3) do {
		case 1: {_function = "lgun";};
		case 2: {_function = "rgun";};
		case 3: {_function = "dgun";};
		case 4: {_function = "rlan";};
		case 5: {_function = "hgun";};
		case 6: {_function = "laser";};
		case 7: {_function = "dlaser";};
		case 8: {_function = "cargo";};
		case 9: {_function = "radar";};
		case 10: {_function = "crane";};
	};

	_vehicleClass = format["owr_am_%1_%2_%3_%4", _chassis, _control, _engine, _function];

	_vehicleClass
};
owr_fn_getAMVehicleCost = {
	_templateArray = _this select 0;
	_costCrates = 0;
	_costOil = 0;
	_costSiberite = 0;

	switch (_templateArray select 0) do {
		case 0: {
			//_chassis = "lt_wh";
			_costCrates =_costCrates + 15;
		};
		case 1: {
			//_chassis = "me_wh";
			_costCrates =_costCrates + 35;
		};
		case 2: {
			//_chassis = "me_tr";
			_costCrates =_costCrates + 40;
		};
		case 3: {
			//_chassis = "hv_tr";
			_costCrates =_costCrates + 55;
		};
		case 4: {
			//_chassis = "mg";
			_costCrates =_costCrates + 45;
		};
	};
	switch (_templateArray select 1) do {
		case 0: {
			// _engine = "cb";
			_costCrates =_costCrates + 15;
			switch (_templateArray select 0) do {
				case 0: {
					//_chassis = "lt_wh";
					_costOil =_costOil + 10;
				};
				case 1: {
					//_chassis = "me_wh";
					_costOil =_costOil + 15;
				};
				case 2: {
					//_chassis = "me_tr";
					_costOil =_costOil + 15;
				};
				case 3: {
					//_chassis = "hv_tr";
					_costOil =_costOil + 20;
				};
				case 4: {
					//_chassis = "mg";
					_costOil =_costOil + 20;
				};
			};
		};
		case 1: {
			//_engine = "sb";
			_costCrates =_costCrates + 20;
			switch (_templateArray select 0) do {
				case 1: {
					//_chassis = "me_wh";
					_costSiberite = _costSiberite + 10;
				};
				case 2: {
					//_chassis = "me_tr";
					_costSiberite = _costSiberite + 10;
				};
				case 3: {
					//_chassis = "hv_tr";
					_costSiberite = _costSiberite + 15;
				};
				case 4: {
					//_chassis = "mg";
					_costSiberite = _costSiberite + 15;
				};
			};
		};
		case 2: {
			//_engine = "el";
			_costCrates =_costCrates + 20;
		};
	};
	
	switch (_templateArray select 2) do {
		case 0: {
			// _control = "mn";
			_costCrates = _costCrates + 10;
		};
		case 1: {
			//_control = "ai";
			_costCrates = _costCrates + 5;
		};
		case 2: {
			//_control = "rt";
			_costCrates = _costCrates + 5;
		};
	};
	
	switch (_templateArray select 3) do {
		case 0: {
			// _function = "mgun";
			_costCrates = _costCrates + 5;
		};
		case 1: {
			//_function = "lgun";
			_costCrates = _costCrates + 5;
		};
		case 2: {
			//_function = "rgun";
			_costCrates = _costCrates + 10;
		};
		case 3: {
			//_function = "dgun";
			_costCrates = _costCrates + 15;
		};
		case 4: {
			//_function = "rlan";
			_costCrates = _costCrates + 15;
		};
		case 5: {
			//_function = "hgun";
			_costCrates = _costCrates + 25;
		};
		case 6: {
			//_function = "laser";
			_costCrates = _costCrates + 10;
			_costSiberite = _costSiberite + 5;
		};
		case 7: {
			//_function = "dlaser";
			_costCrates = _costCrates + 10;
			_costSiberite = _costSiberite + 10;
		};
		case 8: {
			//_function = "cargo";
		};
		case 9: {
			//_function = "radar";
		};
		case 10: {
			//_function = "crane";
			_costCrates = _costCrates + 10;
		};
	};

	 [_costCrates, _costOil, _costSiberite]
};
owr_fn_getAMTurretCost = {
	_weaponId = _this select 0;
	_costCrates = 0;
	_costOil = 0;
	_costSiberite = 0;

	switch (_weaponId) do {
		case 0: {
			// _function = "mgun";
			_costCrates = _costCrates + 5;
		};
		case 1: {
			//_function = "lgun";
			_costCrates = _costCrates + 5;
		};
		case 2: {
			//_function = "rgun";
			_costCrates = _costCrates + 10;
		};
		case 3: {
			//_function = "dgun";
			_costCrates = _costCrates + 10;
		};
		case 4: {
			//_function = "rlan";
			_costCrates = _costCrates + 15;
		};
		case 5: {
			//_function = "hgun";
			_costCrates = _costCrates + 15;
		};
		case 6: {
			//_function = "laser";
			_costCrates = _costCrates + 10;
			_costSiberite = _costSiberite + 5;
		};
		case 7: {
			//_function = "dlaser";
			_costCrates = _costCrates + 10;
			_costSiberite = _costSiberite + 10;
		};
		case 8: {
			//_function = "cargo";
		};
		case 9: {
			//_function = "radar";
		};
		case 10: {
			//_function = "crane";
			_costCrates = _costCrates + 10;
		};
	};

	[_costCrates, _costOil, _costSiberite]
};
owr_fn_getRUTurretCost = {
	_weaponId = _this select 0;
	_costCrates = 0;
	_costOil = 0;
	_costSiberite = 0;

	switch (_weaponId) do {
		case 0: {
			// _function = "hmgun";
			_costCrates = _costCrates + 5;
		};
		case 1: {
			//_function = "rgun";
			_costCrates = _costCrates + 5;
		};
		case 2: {
			//_function = "gun";
			_costCrates = _costCrates + 10;
		};
		case 3: {
			//_function = "hgun";
			_costCrates = _costCrates + 15;
		};
		case 4: {
			//_function = "rlan";
			_costCrates = _costCrates + 10;
		};
		case 5: {
			//_function = "rocket";
			_costCrates = _costCrates + 25;
		};
		case 6: {
			//_function = "cargo";
		};
		case 7: {
			//_function = "crane";
			_costCrates = _costCrates + 10;
		};
	};
	
	[_costCrates, _costOil, _costSiberite]
};
owr_fn_getBuildingCost = {
	_buildingEntity = _this select 0;
	_costCrates = 0;
	_costOil = 0;
	_costSiberite = 0;

	switch (typeOf _buildingEntity) do {
		// BARRACKS
		case "barracks_am": {
			if (_buildingEntity getVariable "ow_build_upgrade") then {
				_costCrates = 45;
			} else {
				_costCrates = 30;
			};
		};
		case "barracks_ar": {
			if (_buildingEntity getVariable "ow_build_upgrade") then {
				_costCrates = 45;
			} else {
				_costCrates = 30;
			};
		};
		case "barracks_ru": {
			if (_buildingEntity getVariable "ow_build_upgrade") then {
				_costCrates = 45;
			} else {
				_costCrates = 30;
			};
		};

		// LABORATORIES
		case "lab_am": {
			_costCrates = 20;
			// left = comp, siberite
			if ((_buildingEntity getVariable "ow_lab_left") == "comp") then {
				_costCrates = _costCrates + 10;
			};
			if ((_buildingEntity getVariable "ow_lab_left") == "siberite") then {
				_costCrates = _costCrates + 5;
				_costSiberite = _costSiberite + 10;
			};
			// right = weap, opto
			if ((_buildingEntity getVariable "ow_lab_right") == "weap") then {
				_costCrates = _costCrates + 10;
			};
			if ((_buildingEntity getVariable "ow_lab_right") == "opto") then {
				_costCrates = _costCrates + 10;
			};
		};
		case "lab_ru": {
			_costCrates = 20;
			// left = comp, siberite
			if ((_buildingEntity getVariable "ow_lab_left") == "comp") then {
				_costCrates = _costCrates + 10;
			};
			if ((_buildingEntity getVariable "ow_lab_left") == "siberite") then {
				_costCrates = _costCrates + 5;
				_costSiberite = _costSiberite + 10;
			};
			// right = weap, time
			if ((_buildingEntity getVariable "ow_lab_right") == "weap") then {
				_costCrates = _costCrates + 10;
			};
			if ((_buildingEntity getVariable "ow_lab_right") == "time") then {
				_costCrates = _costCrates + 5;
				_costSiberite = _costSiberite + 10;
			};
		};
		//case "lab_ar": {};


		// FACTORY
		case "factory_am": {
			if (_buildingEntity getVariable "ow_build_upgrade") then {
				_costCrates = 50;
				if ((_buildingEntity getVariable "ow_factory_upgrades") select 0) then {
					// track
					_costCrates = _costCrates + 10;
				};
				if ((_buildingEntity getVariable "ow_factory_upgrades") select 1) then {
					// cannon
					_costCrates = _costCrates + 7;
				};
				if ((_buildingEntity getVariable "ow_factory_upgrades") select 2) then {
					// rocket
					_costCrates = _costCrates + 7;
				};
				if ((_buildingEntity getVariable "ow_factory_upgrades") select 3) then {
					// siberite
					_costCrates = _costCrates + 5;
					_costSiberite = 5;
				};
				if ((_buildingEntity getVariable "ow_factory_upgrades") select 4) then {
					// ai
					_costCrates = _costCrates + 10;
				};
			} else {
				_costCrates = 35;
			};
		};
		case "factory_ru": {
			if (_buildingEntity getVariable "ow_build_upgrade") then {
				_costCrates = 50;
				if ((_buildingEntity getVariable "ow_factory_upgrades") select 0) then {
					_costCrates = _costCrates + 10;
				};
				if ((_buildingEntity getVariable "ow_factory_upgrades") select 1) then {
					_costCrates = _costCrates + 7;
				};
				if ((_buildingEntity getVariable "ow_factory_upgrades") select 2) then {
					_costCrates = _costCrates + 7;
				};
				if ((_buildingEntity getVariable "ow_factory_upgrades") select 3) then {
					_costCrates = _costCrates + 5;
					_costSiberite = 5;
				};
				if ((_buildingEntity getVariable "ow_factory_upgrades") select 4) then {
					_costCrates = _costCrates + 10;
				};
			} else {
				_costCrates = 35;
			};
		};
		//case "factory_ar": {};


		// RESOURCE MINES
		case "source_oil_ru": {
			_costCrates = 10;
		};
		case "source_oil_am": {
			_costCrates = 10;
		};
		case "source_oil_ar": {
			_costCrates = 10;
		};
		case "source_sib_ru": {
			_costCrates = 10;
		};
		case "source_sib_am": {
			_costCrates = 10;
		};
		case "source_sib_ar": {
			_costCrates = 10;
		};


		// OIL POWER PLANTS
		case "power_oil_ru": {
			_costCrates = 10;
			_costOil = 5;
		};
		case "power_oil_am": {
			_costCrates = 10;
			_costOil = 5;
		};
		case "power_oil_ar": {
			_costCrates = 10;
			_costOil = 5;
		};


		// SIB POWER PLANTS
		case "power_sib_ru": {
			_costCrates = 10;
			_costSiberite = 10;
		};
		case "power_sib_am": {
			_costCrates = 10;
			_costSiberite = 10;
		};
		case "power_sib_ar": {
			_costCrates = 10;
			_costSiberite = 10;
		};


		// SOLAR POWER PLANTS
		case "power_sol_am": {
			_costCrates = 15;
		};
		case "power_sol_ar": {
			_costCrates = 15;
		};


		// TURRETS
		case "aturret_am": {
			_costCrates = 10;
		};
		case "mturret_am": {
			_costCrates = 10;
		};
		case "aturret_ru": {
			_costCrates = 10;
		};
		case "mturret_ru": {
			_costCrates = 10;
		};
	};

	 [_costCrates, _costOil, _costSiberite]
};
owr_fn_getBuildingCostStr = {
	_buildingEntity = _this select 0;
	_costCrates = 0;
	_costOil = 0;
	_costSiberite = 0;

	switch (_buildingEntity) do {
		// BARRACKS
		case "barracks_am": {
			_costCrates = 30;
		};
		case "barracks_ar": {
			_costCrates = 30;
		};
		case "barracks_ru": {
			_costCrates = 30;
		};

		// LABORATORIES
		case "lab_am": {
			_costCrates = 20;
		};
		case "lab_ru": {
			_costCrates = 20;
		};
		case "lab_ar": {
			_costCrates = 20;
		};

		// FACTORY
		case "factory_am": {
			_costCrates = 35;
		};
		case "factory_ru": {
			_costCrates = 35;
		};
		case "factory_ar": {
			_costCrates = 35;
		};


		// RESOURCE MINES
		case "source_oil_ru": {
			_costCrates = 10;
		};
		case "source_oil_am": {
			_costCrates = 10;
		};
		case "source_oil_ar": {
			_costCrates = 10;
		};
		case "source_sib_ru": {
			_costCrates = 10;
		};
		case "source_sib_am": {
			_costCrates = 10;
		};
		case "source_sib_ar": {
			_costCrates = 10;
		};


		// OIL POWER PLANTS
		case "power_oil_ru": {
			_costCrates = 10;
			_costOil = 5;
		};
		case "power_oil_am": {
			_costCrates = 10;
			_costOil = 5;
		};
		case "power_oil_ar": {
			_costCrates = 10;
			_costOil = 5;
		};


		// SIB POWER PLANTS
		case "power_sib_ru": {
			_costCrates = 10;
			_costSiberite = 10;
		};
		case "power_sib_am": {
			_costCrates = 10;
			_costSiberite = 10;
		};
		case "power_sib_ar": {
			_costCrates = 10;
			_costSiberite = 10;
		};


		// SOLAR POWER PLANTS
		case "power_sol_am": {
			_costCrates = 15;
		};
		case "power_sol_ar": {
			_costCrates = 15;
		};


		// TURRETS
		case "aturret_am": {
			_costCrates = 10;
		};
		case "mturret_am": {
			_costCrates = 10;
		};
		case "aturret_ru": {
			_costCrates = 10;
		};
		case "mturret_ru": {
			_costCrates = 10;
		};
	};

	 [_costCrates, _costOil, _costSiberite]
};
owr_fn_getUpgradeCostStr = {
	_upgradeType = _this select 0;
	_costCrates = 0;
	_costOil = 0;
	_costSiberite = 0;

	switch (_upgradeType) do {
		case "warehouse_am": {
			_costCrates = 25;
		};
		case "warehouse_ar": {
			_costCrates = 25;
		};
		case "warehouse_ru": {
			_costCrates = 25;
		};

		case "barracks_am": {
			_costCrates = 15;
		};
		case "barracks_ar": {
			_costCrates = 15;
		};
		case "barracks_ru": {
			_costCrates = 15;
		};

		case "factory_am": {
			_costCrates = 25;
		};
		case "factory_ar": {
			_costCrates = 25;
		};
		case "factory_ru": {
			_costCrates = 25;
		};
		case "factory_ai": {
			_costCrates = 10;
		};
		case "factory_sib": {
			_costCrates = 5;
			_costSiberite = 5;
		};
		case "factory_rocket": {
			_costCrates = 7;
		};
		case "factory_cannon": {
			_costCrates = 7;
		};
		case "factory_track": {
			_costCrates = 10;
		};

		case "lab_weap": {
			_costCrates = 10;
		};
		case "lab_comp": {
			_costCrates = 10;
		};
		case "lab_siberite": {
			_costCrates = 5;
			_costSiberite = 10;
		};
		case "lab_opto": {
			_costCrates = 10;
		};
		case "lab_time": {
			_costCrates = 5;
			_costSiberite = 10;
		};
	};

	 [_costCrates, _costOil, _costSiberite]
};
owr_fn_getCostStr = {
	_resourceArray = _this select 0;
	_costString = " ( costs ";
	if ((_resourceArray select 0) != 0) then {
		_costString = _costString + format ["%1 crates ", (_resourceArray select 0)];
	};
	if ((_resourceArray select 1) != 0) then {
		_costString = _costString + format ["%1 oil ", (_resourceArray select 1)];
	};
	if ((_resourceArray select 2) != 0) then {
		_costString = _costString + format ["%1 siberite ", (_resourceArray select 2)];
	};
	_costString = _costString + ")";

	_costString
};
owr_fn_wrhsCostCheck = {
	_resourceArray = _this select 0;
	_warehouseToCheck = _this select 1;
	_enoughResources = true;

	if (!(isNull _warehouseToCheck)) then {
		if ((_resourceArray select 0) != 0) then {
			if ((_warehouseToCheck getVariable "ow_wrhs_crates") < (_resourceArray select 0)) then {
				_enoughResources = false;
			};
		};
		if ((_resourceArray select 1) != 0) then {
			if ((_warehouseToCheck getVariable "ow_wrhs_oil") < (_resourceArray select 1)) then {
				_enoughResources = false;
			};
		};
		if ((_resourceArray select 2) != 0) then {
			if ((_warehouseToCheck getVariable "ow_wrhs_siberite") < (_resourceArray select 2)) then {
				_enoughResources = false;
			};
		};
	};

	if (owr_devhax) then {
		_enoughResources = true;
	};
	_enoughResources
};
owr_fn_wrhsResourceTake = {
	_resourceArray = _this select 0;
	_warehouseToCheck = _this select 1;
	if ((_resourceArray select 0) != 0) then {
		// substract resources
		_currentAmount = (_warehouseToCheck getVariable "ow_wrhs_crates");
		_warehouseToCheck setVariable ["ow_wrhs_crates", _currentAmount - (_resourceArray select 0), true];
	};
	if ((_resourceArray select 1) != 0) then {
		// substract resources
		_currentAmount = (_warehouseToCheck getVariable "ow_wrhs_oil");
		_warehouseToCheck setVariable ["ow_wrhs_oil", _currentAmount - (_resourceArray select 1), true];
	};
	if ((_resourceArray select 2) != 0) then {
		// substract resources
		_currentAmount = (_warehouseToCheck getVariable "ow_wrhs_siberite");
		_warehouseToCheck setVariable ["ow_wrhs_siberite", _currentAmount - (_resourceArray select 2), true];
	};
};
owr_fn_getAMATurretClass = {
	_templateID = _this select 0;

	//hintSilent format["%1", _templateID];

	_function = "mgun";
	switch (_templateID) do {
		case 1: {_function = "lgun";};
		case 2: {_function = "rgun";};
		case 3: {_function = "dgun";};
		case 4: {_function = "rlan";};
		case 5: {_function = "hgun";};
		case 6: {_function = "laser";};
		case 7: {_function = "dlaser";};
		case 8: {_function = "cargo";};
		case 9: {_function = "radar";};
		case 10: {_function = "crane";};
	};

	_aturretClass = format["owr_am_aturret_%1", _function];

	_aturretClass
};
owr_fn_getAMMTurretClass = {
	_templateID = _this select 0;

	//hintSilent format["%1", _templateID];

	_function = "mgun";
	switch (_templateID) do {
		case 1: {_function = "lgun";};
		case 2: {_function = "rgun";};
		case 3: {_function = "dgun";};
		case 4: {_function = "rlan";};
		case 5: {_function = "hgun";};
		case 6: {_function = "laser";};
		case 7: {_function = "dlaser";};
		case 8: {_function = "cargo";};
		case 9: {_function = "radar";};
		case 10: {_function = "crane";};
	};

	_mturretClass = format["owr_am_mturret_%1", _function];

	_mturretClass
};
owr_fn_getRUVehicleClass = {
	_templateArray = _this select 0;
	_chassis = "me_wh";
	switch (_templateArray select 0) do {
		case 1: {_chassis = "me_tr";};
		case 2: {_chassis = "hv_wh";};
		case 3: {_chassis = "hv_tr";};
	};
	_engine = "cb";
	switch (_templateArray select 1) do {
		case 1: {_engine = "sb";};
	};
	_control = "mn";
	switch (_templateArray select 2) do {
		case 1: {_control = "ai";};
	};
	_function = "hmgun";
	switch (_templateArray select 3) do {
		case 1: {_function = "rgun";};
		case 2: {_function = "gun";};
		case 3: {_function = "hgun";};
		case 4: {_function = "rlan";};
		case 5: {_function = "rocket";};
		case 6: {_function = "cargo";};
		case 7: {_function = "crane";};
	};

	_vehicleClass = format["owr_ru_%1_%2_%3_%4", _chassis, _control, _engine, _function];

	_vehicleClass
};
owr_fn_getRUVehicleCost = {
	_templateArray = _this select 0;
	_costCrates = 0;
	_costOil = 0;
	_costSiberite = 0;

	switch (_templateArray select 0) do {
		case 0: {
			//_chassis = "me_wh";
			_costCrates =_costCrates + 35;
		};
		case 1: {
			//_chassis = "me_tr";
			_costCrates =_costCrates + 40;
		};
		case 2: {
			//_chassis = "hv_wh";
			_costCrates =_costCrates + 50;
		};
		case 3: {
			//_chassis = "hv_tr";
			_costCrates =_costCrates + 55;
		};
	};
	switch (_templateArray select 1) do {
		case 0: {
			// _engine = "cb";
			_costCrates =_costCrates + 15;
			switch (_templateArray select 0) do {
				case 0: {
					//_chassis = "me_wh";
					_costOil =_costOil + 15;
				};
				case 1: {
					//_chassis = "me_tr";
					_costOil =_costOil + 15;
				};
				case 2: {
					//_chassis = "hv_wh";
					_costOil =_costOil + 15;
				};
				case 3: {
					//_chassis = "hv_tr";
					_costOil =_costOil + 15;
				};
			};
		};
		case 1: {
			//_engine = "sb";
			_costCrates =_costCrates + 20;
			switch (_templateArray select 0) do {
				case 0: {
					//_chassis = "me_wh";
					_costSiberite =_costSiberite + 10;
				};
				case 1: {
					//_chassis = "me_tr";
					_costSiberite =_costSiberite + 10;
				};
				case 2: {
					//_chassis = "hv_wh";
					_costSiberite =_costSiberite + 20;
				};
				case 3: {
					//_chassis = "hv_tr";
					_costSiberite =_costSiberite + 20;
				};
			};
		};
	};
	
	switch (_templateArray select 2) do {
		case 0: {
			// _control = "mn";
			_costCrates = _costCrates + 10;
		};
		case 1: {
			//_control = "ai";
			_costCrates = _costCrates + 5;
		};
	};
	
	switch (_templateArray select 3) do {
		case 0: {
			// _function = "hmgun";
			_costCrates = _costCrates + 5;
		};
		case 1: {
			//_function = "rgun";
			_costCrates = _costCrates + 5;
		};
		case 2: {
			//_function = "gun";
			_costCrates = _costCrates + 10;
		};
		case 3: {
			//_function = "hgun";
			_costCrates = _costCrates + 25;
		};
		case 4: {
			//_function = "rlan";
			_costCrates = _costCrates + 10;
		};
		case 5: {
			//_function = "rocket";
			_costCrates = _costCrates + 25;
		};
		case 6: {
			//_function = "cargo";
		};
		case 7: {
			//_function = "crane";
			_costCrates = _costCrates + 10;
		};
	};

	[_costCrates, _costOil, _costSiberite]
};
owr_fn_getRUATurretClass = {
	_templateID = _this select 0;

	//hintSilent format["%1", _templateID];

	_function = "hmgun";
	switch (_templateID) do {
		case 1: {_function = "rgun";};
		case 2: {_function = "gun";};
		case 3: {_function = "hgun";};
		case 4: {_function = "rlan";};
		case 5: {_function = "rocket";};
	};

	_aturretClass = format["owr_ru_aturret_%1", _function];

	_aturretClass
};
owr_fn_getRUMTurretClass = {
	_templateID = _this select 0;

	//hintSilent format["%1", _templateID];

	_function = "hmgun";
	switch (_templateID) do {
		case 1: {_function = "rgun";};
		case 2: {_function = "gun";};
		case 3: {_function = "hgun";};
		case 4: {_function = "rlan";};
		case 5: {_function = "rocket";};
	};

	_mturretClass = format["owr_ru_mturret_%1", _function];

	_mturretClass
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
owr_fn_changeClassGear = {
	_owman = _this select 0;
	_targetClass = _this select 1;

	switch (_targetClass) do {
		case 0: {
			// CHANGE TO SOLDIER
			switch (typeOf (vehicle _owman)) do {
				case "barracks_am": {
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
				case "barracks_ru": {
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
					_owman addPrimaryWeaponItem "optic_SOS";
					_owman addPrimaryWeaponItem "acc_flashlight";
					_owman addPrimaryWeaponItem "bipod_01_F_blk";
					_owman addWeaponGlobal "Rangefinder";

					_owman linkItem "ItemMap";
					_owman linkItem "ItemCompass";
					_owman linkItem "ItemWatch";
					_owman linkItem "ItemRadio";
					_owman linkItem "NVGoggles_OPFOR";
				};
				case "barracks_ar": {
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
			switch (typeOf (vehicle _owman)) do {
				case "warehouse_am": {
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
				case "warehouse_ru": {
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
				case "warehouse_ar": {
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
			switch (typeOf (vehicle _owman)) do {
				case "factory_am": {
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

					_owman addWeapon "hgun_P07_khk_F";

					_owman linkItem "NVGoggles_OPFOR";
					_owman linkItem "ItemMap";
					_owman linkItem "ItemCompass";
					_owman linkItem "ItemWatch";
					_owman linkItem "ItemRadio";
				};
				case "factory_ru": {
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
				case "factory_ar": {
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
					_owman addVest "V_TacVest_oli";
					for "_i" from 1 to 2 do {_owman addItemToVest "FirstAidKit";};
					_owman addHeadgear "H_Cap_headphones";

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
			switch (typeOf (vehicle _owman)) do {
				case "lab_am": {
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
				case "lab_ru": {
					// RU scientist loadout
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
				case "lab_ar": {
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
owr_fn_changeAMSoldierGear = {
	// available classes:
	// rifle auto life drone sharp at aa
	_owman = _this select 0;
	_loadoutType = _this select 1;

	switch (_loadoutType) do {
		case "rifle": {
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

		case "auto": {
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
			for "_i" from 1 to 4 do {_owman addItemToVest "SmokeShellBlue";};
			for "_i" from 1 to 5 do {_owman addItemToVest "HandGrenade";};
			for "_i" from 1 to 5 do {_owman addItemToVest "Chemlight_blue";};
			_owman addBackpackGlobal "B_ViperLightHarness_blk_F";
			for "_i" from 1 to 2 do {_owman addItemToBackpack "FirstAidKit";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "Chemlight_blue";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "HandGrenade";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "SmokeShellBlue";};
			for "_i" from 1 to 3 do {_owman addItemToBackpack "200Rnd_556x45_Box_F";};
			_owman addHeadgear "H_HelmetB_light";
			_owman addGoggles "G_Bandanna_blk";

			_owman addWeaponGlobal "LMG_03_F";
			_owman addPrimaryWeaponItem "optic_AMS";
			_owman addWeaponGlobal "Rangefinder";

			_owman linkItem "ItemMap";
			_owman linkItem "ItemCompass";
			_owman linkItem "ItemWatch";
			_owman linkItem "ItemRadio";
			_owman linkItem "B_UavTerminal";
			_owman linkItem "NVGoggles_OPFOR";
		};

		case "life": {
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
			for "_i" from 1 to 5 do {_owman addItemToVest "FirstAidKit";};
			for "_i" from 1 to 4 do {_owman addItemToVest "SmokeShellBlue";};
			for "_i" from 1 to 5 do {_owman addItemToVest "Chemlight_blue";};
			for "_i" from 1 to 2 do {_owman addItemToVest "HandGrenade";};
			for "_i" from 1 to 5 do {_owman addItemToVest "30Rnd_65x39_caseless_green";};
			_owman addBackpackGlobal "B_ViperLightHarness_blk_F";
			for "_i" from 1 to 13 do {_owman addItemToBackpack "FirstAidKit";};
			_owman addItemToBackpack "Medikit";
			for "_i" from 1 to 5 do {_owman addItemToBackpack "Chemlight_blue";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "30Rnd_65x39_caseless_green";};
			for "_i" from 1 to 2 do {_owman addItemToBackpack "SmokeShellBlue";};
			_owman addHeadgear "H_HelmetB_light";
			_owman addGoggles "G_Bandanna_blk";

			_owman addWeaponGlobal "arifle_ARX_blk_F";
			_owman addPrimaryWeaponItem "acc_flashlight";
			_owman addPrimaryWeaponItem "optic_AMS";
			_owman addPrimaryWeaponItem "bipod_01_F_blk";
			_owman addWeaponGlobal "Rangefinder";

			_owman linkItem "ItemMap";
			_owman linkItem "ItemCompass";
			_owman linkItem "ItemWatch";
			_owman linkItem "ItemRadio";
			_owman linkItem "B_UavTerminal";
			_owman linkItem "NVGoggles_OPFOR";
		};

		case "drone": {
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
			for "_i" from 1 to 5 do {_owman addItemToVest "FirstAidKit";};
			for "_i" from 1 to 4 do {_owman addItemToVest "SmokeShellBlue";};
			for "_i" from 1 to 5 do {_owman addItemToVest "Chemlight_blue";};
			for "_i" from 1 to 2 do {_owman addItemToVest "HandGrenade";};
			for "_i" from 1 to 5 do {_owman addItemToVest "30Rnd_65x39_caseless_green";};
			_owman addBackpack "B_UAV_01_backpack_F";
			_owman addHeadgear "H_HelmetB_light";
			_owman addGoggles "G_Bandanna_blk";

			_owman addWeaponGlobal "arifle_ARX_blk_F";
			_owman addPrimaryWeaponItem "acc_flashlight";
			_owman addPrimaryWeaponItem "optic_AMS";
			_owman addPrimaryWeaponItem "bipod_01_F_blk";
			_owman addWeaponGlobal "Rangefinder";

			_owman linkItem "ItemMap";
			_owman linkItem "ItemCompass";
			_owman linkItem "ItemWatch";
			_owman linkItem "ItemRadio";
			_owman linkItem "B_UavTerminal";
			_owman linkItem "NVGoggles_OPFOR";
		};

		case "sharp": {
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
			for "_i" from 1 to 4 do {_owman addItemToVest "SmokeShellBlue";};
			for "_i" from 1 to 5 do {_owman addItemToVest "HandGrenade";};
			for "_i" from 1 to 5 do {_owman addItemToVest "Chemlight_blue";};
			for "_i" from 1 to 2 do {_owman addItemToVest "7Rnd_408_Mag";};
			_owman addBackpackGlobal "B_ViperLightHarness_blk_F";
			for "_i" from 1 to 2 do {_owman addItemToBackpack "FirstAidKit";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "Chemlight_blue";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "HandGrenade";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "SmokeShellBlue";};
			for "_i" from 1 to 6 do {_owman addItemToBackpack "7Rnd_408_Mag";};
			_owman addHeadgear "H_HelmetB_light";
			_owman addGoggles "G_Bandanna_blk";

			_owman addWeaponGlobal "srifle_LRR_F";
			_owman addPrimaryWeaponItem "optic_AMS";
			_owman addWeaponGlobal "Rangefinder";

			_owman linkItem "ItemMap";
			_owman linkItem "ItemCompass";
			_owman linkItem "ItemWatch";
			_owman linkItem "ItemRadio";
			_owman linkItem "NVGoggles_OPFOR";
		};

		case "at": {
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
			for "_i" from 1 to 4 do {_owman addItemToVest "SmokeShellBlue";};
			for "_i" from 1 to 5 do {_owman addItemToVest "Chemlight_blue";};
			for "_i" from 1 to 2 do {_owman addItemToVest "HandGrenade";};
			for "_i" from 1 to 5 do {_owman addItemToVest "30Rnd_65x39_caseless_green";};
			_owman addBackpackGlobal "B_ViperLightHarness_blk_F";
			for "_i" from 1 to 5 do {_owman addItemToBackpack "Chemlight_blue";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "30Rnd_65x39_caseless_green";};
			for "_i" from 1 to 2 do {_owman addItemToBackpack "NLAW_F";};
			_owman addHeadgear "H_HelmetB_light";
			_owman addGoggles "G_Bandanna_blk";

			_owman addWeaponGlobal "arifle_ARX_blk_F";
			_owman addPrimaryWeaponItem "acc_flashlight";
			_owman addPrimaryWeaponItem "optic_AMS";
			_owman addPrimaryWeaponItem "bipod_01_F_blk";
			_owman addWeaponGlobal "launch_NLAW_F";
			_owman addWeaponGlobal "Rangefinder";

			_owman linkItem "ItemMap";
			_owman linkItem "ItemCompass";
			_owman linkItem "ItemWatch";
			_owman linkItem "ItemRadio";
			_owman linkItem "NVGoggles_OPFOR";
		};

		// future maybe
		case "aa": {};
	};
};
owr_fn_changeRUSoldierGear = {
	// available classes:
	// rifle auto life drone sharp at aa
	_owman = _this select 0;
	_loadoutType = _this select 1;

	switch (_loadoutType) do {
		case "rifle": {
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
			_owman addPrimaryWeaponItem "optic_SOS";
			_owman addPrimaryWeaponItem "acc_flashlight";
			_owman addPrimaryWeaponItem "bipod_01_F_blk";
			_owman addWeaponGlobal "Rangefinder";

			_owman linkItem "ItemMap";
			_owman linkItem "ItemCompass";
			_owman linkItem "ItemWatch";
			_owman linkItem "ItemRadio";
			_owman linkItem "NVGoggles_OPFOR";
		};

		case "auto": {
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
			_owman addVest "V_HarnessOGL_ghex_F";
			for "_i" from 1 to 5 do {_owman addItemToVest "HandGrenade";};
			for "_i" from 1 to 3 do {_owman addItemToVest "SmokeShellRed";};
			for "_i" from 1 to 2 do {_owman addItemToVest "Chemlight_red";};
			_owman addBackpackGlobal "B_ViperLightHarness_oli_F";
			for "_i" from 1 to 2 do {_owman addItemToBackpack "FirstAidKit";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "SmokeShellRed";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "HandGrenade";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "Chemlight_red";};
			for "_i" from 1 to 3 do {_owman addItemToBackpack "150Rnd_762x54_Box";};
			_owman addHeadgear "H_HelmetB_light_black";
			_owman addGoggles "G_Bandanna_oli";

			_owman addWeaponGlobal "LMG_Zafir_F";
			_owman addWeaponGlobal "Rangefinder";

			_owman linkItem "ItemMap";
			_owman linkItem "ItemCompass";
			_owman linkItem "ItemWatch";
			_owman linkItem "ItemRadio";
			_owman linkItem "NVGoggles_OPFOR";
		};

		case "life": {
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
			_owman addItemToUniform "30Rnd_556x45_Stanag";
			_owman addVest "V_HarnessOGL_ghex_F";
			for "_i" from 1 to 6 do {_owman addItemToVest "FirstAidKit";};
			for "_i" from 1 to 3 do {_owman addItemToVest "SmokeShellRed";};
			for "_i" from 1 to 2 do {_owman addItemToVest "Chemlight_red";};
			for "_i" from 1 to 5 do {_owman addItemToVest "30Rnd_556x45_Stanag";};
			_owman addBackpackGlobal "B_ViperLightHarness_oli_F";
			for "_i" from 1 to 11 do {_owman addItemToBackpack "FirstAidKit";};
			_owman addItemToBackpack "Medikit";
			for "_i" from 1 to 5 do {_owman addItemToBackpack "SmokeShellRed";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "Chemlight_red";};
			for "_i" from 1 to 2 do {_owman addItemToBackpack "HandGrenade";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "30Rnd_556x45_Stanag";};
			_owman addHeadgear "H_HelmetB_light_black";
			_owman addGoggles "G_Bandanna_oli";

			_owman addWeaponGlobal "arifle_SPAR_01_khk_F";
			_owman addPrimaryWeaponItem "optic_SOS_khk_F";
			_owman addWeaponGlobal "Rangefinder";

			_owman linkItem "ItemMap";
			_owman linkItem "ItemCompass";
			_owman linkItem "ItemWatch";
			_owman linkItem "ItemRadio";
			_owman linkItem "NVGoggles_OPFOR";
		};

		case "drone": {
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
			for "_i" from 1 to 2 do {_owman addItemToUniform "30Rnd_556x45_Stanag";};
			_owman addVest "V_HarnessOGL_ghex_F";
			for "_i" from 1 to 6 do {_owman addItemToVest "FirstAidKit";};
			for "_i" from 1 to 3 do {_owman addItemToVest "SmokeShellRed";};
			for "_i" from 1 to 2 do {_owman addItemToVest "Chemlight_red";};
			for "_i" from 1 to 5 do {_owman addItemToVest "30Rnd_556x45_Stanag";};
			_owman addBackpackGlobal "O_UAV_01_backpack_F";
			_owman addHeadgear "H_HelmetB_light_black";
			_owman addGoggles "G_Bandanna_oli";

			_owman addWeaponGlobal "arifle_SPAR_01_khk_F";
			_owman addPrimaryWeaponItem "optic_SOS_khk_F";
			_owman addWeaponGlobal "Rangefinder";

			_owman linkItem "ItemMap";
			_owman linkItem "ItemCompass";
			_owman linkItem "ItemWatch";
			_owman linkItem "ItemRadio";
			_owman linkItem "O_UavTerminal";
			_owman linkItem "NVGoggles_OPFOR";
		};

		case "sharp": {
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
			_owman addItemToUniform "5Rnd_127x108_Mag";
			_owman addVest "V_HarnessOGL_ghex_F";
			for "_i" from 1 to 5 do {_owman addItemToVest "HandGrenade";};
			for "_i" from 1 to 3 do {_owman addItemToVest "SmokeShellRed";};
			for "_i" from 1 to 2 do {_owman addItemToVest "Chemlight_red";};
			for "_i" from 1 to 2 do {_owman addItemToVest "5Rnd_127x108_Mag";};
			_owman addBackpackGlobal "B_ViperLightHarness_oli_F";
			for "_i" from 1 to 2 do {_owman addItemToBackpack "FirstAidKit";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "SmokeShellRed";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "HandGrenade";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "Chemlight_red";};
			for "_i" from 1 to 6 do {_owman addItemToBackpack "5Rnd_127x108_Mag";};
			_owman addHeadgear "H_HelmetB_light_black";
			_owman addGoggles "G_Bandanna_oli";

			_owman addWeaponGlobal "srifle_GM6_F";
			_owman addPrimaryWeaponItem "optic_SOS";
			_owman addWeaponGlobal "Rangefinder";

			_owman linkItem "ItemMap";
			_owman linkItem "ItemCompass";
			_owman linkItem "ItemWatch";
			_owman linkItem "ItemRadio";
			_owman linkItem "NVGoggles_OPFOR";
		};

		case "at": {
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
			_owman addItemToUniform "30Rnd_556x45_Stanag";
			_owman addVest "V_HarnessOGL_ghex_F";
			for "_i" from 1 to 6 do {_owman addItemToVest "FirstAidKit";};
			for "_i" from 1 to 3 do {_owman addItemToVest "SmokeShellRed";};
			for "_i" from 1 to 2 do {_owman addItemToVest "Chemlight_red";};
			for "_i" from 1 to 5 do {_owman addItemToVest "30Rnd_556x45_Stanag";};
			_owman addBackpackGlobal "B_ViperLightHarness_oli_F";
			for "_i" from 1 to 5 do {_owman addItemToBackpack "SmokeShellRed";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "Chemlight_red";};
			for "_i" from 1 to 5 do {_owman addItemToBackpack "30Rnd_556x45_Stanag";};
			for "_i" from 1 to 2 do {_owman addItemToBackpack "RPG32_F";};
			_owman addHeadgear "H_HelmetB_light_black";
			_owman addGoggles "G_Bandanna_oli";

			_owman addWeaponGlobal "arifle_SPAR_01_khk_F";
			_owman addPrimaryWeaponItem "optic_SOS_khk_F";
			_owman addWeaponGlobal "launch_RPG32_ghex_F";
			_owman addWeaponGlobal "Rangefinder";

			_owman linkItem "ItemMap";
			_owman linkItem "ItemCompass";
			_owman linkItem "ItemWatch";
			_owman linkItem "ItemRadio";
			_owman linkItem "NVGoggles_OPFOR";
		};

		// future maybe
		case "aa": {};
	};
};
owr_fn_attackSomething = {
	_responsibleUnit = _this select 0;
	_mouseWorldpos = [0,0];

	/*

	// does not work atm

	player setVariable ["owr_confirm", false, true];
	player setVariable ["owr_cancel", false, true];

	_target = objNull;

	while {!(player getVariable "owr_confirm") || !(player getVariable "owr_cancel")} do {
		_mouseWorldpos = screenToWorld (uiNamespace getVariable "RscDisplayCurator_mousePos");
		_unitsToAttack = nearestObjects [_mouseWorldpos, ["owr_car", "owr_manbase", "owr_base0c", "owr_base1c", "owr_base6c"], 2];
		if (count (_unitsToAttack) > 0) then {
			_target = _unitsToAttack select 0;
		};
		hintSilent format ["%1 searching for target :: %2", _responsibleUnit, _target];
	};

	if (player getVariable "owr_confirm") then {
		hintSilent format ["%1 attack at target :: %2", _responsibleUnit, _target];
		_responsibleUnit doFire _target;
	} else {
		hintSilent format ["%1 attack cancelled on target :: %2", _responsibleUnit, _target];
	};

	player setVariable ["owr_confirm", false, true];
	player setVariable ["owr_cancel", false, true];
	*/
};
owr_fn_buildSomething = {
	_responsibleUnit = _this select 0;
	_wantedBuilding = _this select 1;

	_isWarehouse = false;
	_isMiscObj = false;
	_isMine = false;
	_isControlTower = false;
	_controlTFixatedOn = -1;
	_cargoVehicle = objNull;	// for case of control tower building process (basicaly warehouse that needs resources to be built)
	_mineType = "";
	_naturalDeposits = [];
	_warehouses = [];
	if (_wantedBuilding == "warehouse_am" || _wantedBuilding == "warehouse_ru" || _wantedBuilding == "warehouse_ar") then {
		_isWarehouse = true;
	};
	if (_wantedBuilding == "source_oil_am" || _wantedBuilding == "source_sib_am" || _wantedBuilding == "source_oil_ru" || _wantedBuilding == "source_sib_ru" || _wantedBuilding == "source_oil_ar" || _wantedBuilding == "source_sib_ar") then {
		_isMine = true;
		if (_wantedBuilding == "source_oil_am" || _wantedBuilding == "source_oil_ru" || _wantedBuilding == "source_oil_ar") then {
			_mineType = "owr_deposit_oil";
		};
		if (_wantedBuilding == "source_sib_am" || _wantedBuilding == "source_sib_ru" || _wantedBuilding == "source_sib_ar") then {
			_mineType = "owr_deposit_siberite";
		};
	};
	if (_wantedBuilding == "control_tower_am" || _wantedBuilding == "control_tower_ru" || _wantedBuilding == "control_tower_ar") then {
		_isControlTower = true;
	};

	_success = false;

	_obj_placing_lastpos = [0,0];
	_obj_placing_distance = 0.1;
	_obj_placing_angle = 0.0;
	_mouseWorldpos = [0,0];

	_ghost = (getText (configFile >> "CfgVehicles" >> _wantedBuilding >> "ghost")) createVehicle _mouseWorldpos;
	if (isNull _ghost) then {
		_ghost = _wantedBuilding createVehicle _mouseWorldpos;
		_isMiscObj = true;
	};

	player setVariable ["owr_confirm", false, true];
	player setVariable ["owr_cancel", false, true];

	while {_responsibleUnit getVariable "ow_worker_buildmode" == 4} do {
		// we need to do this before
		_positionConstraint = false;
		if (_isMine) then {
			_naturalDeposits = nearestObjects [_obj_placing_lastpos, [_mineType], 10.0];
			if ((count _naturalDeposits) > 0) then {
				// check if this resource site is not occupied already first!
				_existingMines = nearestObjects [(getPos (_naturalDeposits select 0)), ["source_oil_am","source_sib_am","source_oil_ru","source_sib_ru","source_oil_ar","source_sib_ar"], 1.0];
				if ((count _existingMines) > 0) then {
					// there is already resource extraction built
					_positionConstraint = false;
				} else {
					// this resource deposit is free
					_ghost setPos (getPos (_naturalDeposits select 0));
					_positionConstraint = true;
				};
			};
		};

		if (_isControlTower) then {
			_i = 0;
			_positions = owr_positions_nodes;
			for "_i" from 0 to ((count _positions) - 1) do {
				if ((_obj_placing_lastpos distance (_positions select _i)) < 50) then {
					_ghost setPos (_positions select _i);
					_controlTFixatedOn = _i;
					_positionConstraint = true;
				};
			};
		};

		_mouseWorldpos = screenToWorld (uiNamespace getVariable "RscDisplayCurator_mousePos");
		if (uinamespace getVariable "owr_rotleftctrl") then {
			_obj_placing_distance = sqrt (((_mouseWorldpos select 0) - (_obj_placing_lastpos select 0)) * ((_mouseWorldpos select 0) - (_obj_placing_lastpos select 0)) + ((_mouseWorldpos select 1) - (_obj_placing_lastpos select 1)) * ((_mouseWorldpos select 1) - (_obj_placing_lastpos select 1)));
			_obj_placing_angle = asin (((_mouseWorldpos select 0) - (_obj_placing_lastpos select 0)) / (0.0001 max _obj_placing_distance));
			
			if (((_mouseWorldpos select 1) - (_obj_placing_lastpos select 1)) < 0) then {
				_obj_placing_angle = -1.0 * (180 + _obj_placing_angle);
			} else {

			};
			if (!_positionConstraint) then {
				_ghost setDir _obj_placing_angle;
			};
		} else {
			if (!_positionConstraint) then {
				_ghost setPos _mouseWorldpos;
			};
			_obj_placing_lastpos = _mouseWorldpos;
		};



		_distanceContraint = false;
		_warehouses = nearestObjects [_obj_placing_lastpos, ["warehouse_am", "warehouse_ru", "warehouse_ar"], 150.0];
		if ((_wantedBuilding != "warehouse_am") && (_wantedBuilding != "warehouse_ru") && (_wantedBuilding != "warehouse_ar") && (_wantedBuilding != "control_tower_am") && (_wantedBuilding != "control_tower_ru") && (_wantedBuilding != "control_tower_ar")) then {
			// player wants to build a normal building
			if ((count _warehouses) > 0) then {
				_dist = _obj_placing_lastpos distance (getPos (_warehouses select 0));
				_warehouseType = "";
				switch (player) do {
					case bis_curatorUnit_west: {
						_warehouseType = "warehouse_am";
					};
					case bis_curatorUnit_east: {
						_warehouseType = "warehouse_ru";
					};
					case bis_curatorUnit_arab: {
						_warehouseType = "warehouse_ar";
					};
				};
				if ((_warehouses select 0) isKindOf _warehouseType) then {
					if ((_warehouses select 0) getVariable "ow_build_ready") then {
						if ((_warehouses select 0) getVariable "ow_build_upgrade") then {
							// upgraded version - allows bigger bases
							if ((_dist) < ((_warehouses select 0) getVariable "ow_wrhs_range_1")) then {
								_distanceContraint = true;
							};
						} else {
							// normal version - standard size of bases
							if ((_dist) < ((_warehouses select 0) getVariable "ow_wrhs_range_0")) then {
								_distanceContraint = true;
							};
						};
					};
				};
			};
			//hintSilent format ["normal building chosen, warehouse available around: %1", count _warehouses];
		} else {
			// player wants to build a warehouse or control tower itself
			_warehouses = nearestObjects [_obj_placing_lastpos, ["warehouse_am", "warehouse_ru", "warehouse_ar", "control_tower_am", "control_tower_ru", "control_tower_ar"], 150.0];
			if ((count _warehouses) == 0) then {
				_distanceContraint = true;
			};
			//hintSilent format ["warehouse chosen, available around: %1, dist is %2", count _warehouses, _obj_placing_lastpos distance (_warehouses select 0)];
			// lets check one more time in case it is a warehouse - we need to make sure that it is not built around beacon position
			if ((_wantedBuilding == "warehouse_am") || (_wantedBuilding == "warehouse_ru") || (_wantedBuilding == "warehouse_ar")) then {
				_i = 0;
				_positions = owr_positions_nodes;
				for "_i" from 0 to ((count _positions) - 1) do {
					if ((_obj_placing_lastpos distance (_positions select _i)) < 150) then {
						_distanceContraint = false;
					};
				};
				// ignore node-warehouse limitations when domination mode is off
				_domiSwitch = ["DominationVictory"] call BIS_fnc_getParamValue;
				if (_domiSwitch == 0) then {
					_distanceContraint = true;
				};
			};
			// node order check - can player actualy build it?
			if (_controlTFixatedOn != -1) then {
				// is fixated on something, lets see what is it
				// WARNING - HEAVILY hardcoded and work-in-progress!
				_canBuild = false;
				switch (_wantedBuilding) do {
					case "control_tower_am": {
						switch (_controlTFixatedOn) do {
							case 1: {
								// entry node
								_canBuild = true;
							};
							case 2: {
								// middle node
								_nearestTower = nearestObjects [owr_positions_nodes select 1, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_canBuild = true;
								};
							};
							case 4: {
								// middle node
								// 2 or 6 has to be captured
								_captured = false;
								_nearestTower = nearestObjects [owr_positions_nodes select 2, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_captured = true;
								};
								_nearestTower = nearestObjects [owr_positions_nodes select 6, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_captured = true;
								};
								if (_captured) then {
									_canBuild = true;
								};
							};
							case 6: {
								// middle node
								_nearestTower = nearestObjects [owr_positions_nodes select 1, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_canBuild = true;
								};
							};
							case 5: {
								// primary deposit
								// check for two captured
								_captured = 0;
								_nearestTower = nearestObjects [owr_positions_nodes select 4, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_captured = _captured + 1;
								};
								_nearestTower = nearestObjects [owr_positions_nodes select 6, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_captured = _captured + 1;
								};
								_nearestTower = nearestObjects [owr_positions_nodes select 2, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_captured = _captured + 1;
								};

								if (_captured >= 2) then {
									// two captured, check for entry
									_nearestTower = nearestObjects [owr_positions_nodes select 1, [_wantedBuilding], 10];
									if ((count _nearestTower) > 0) then {
										// entry point exists too, player can build it on primary deposit
										_canBuild = true;
									};
								};
							};
							default {
								_canBuild = false;
							};
						};
					};
					case "control_tower_ar": {
						switch (_controlTFixatedOn) do {
							case 3: {
								// entry node
								_canBuild = true;
							};
							case 2: {
								// middle node
								_nearestTower = nearestObjects [owr_positions_nodes select 3, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_canBuild = true;
								};
							};
							case 6: {
								// middle node
								// 2 or 4 has to be captured
								_captured = false;
								_nearestTower = nearestObjects [owr_positions_nodes select 2, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_captured = true;
								};
								_nearestTower = nearestObjects [owr_positions_nodes select 4, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_captured = true;
								};
								if (_captured) then {
									_canBuild = true;
								};
							};
							case 4: {
								// middle node
								_nearestTower = nearestObjects [owr_positions_nodes select 3, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_canBuild = true;
								};
							};
							case 5: {
								// primary deposit
								// check for two captured
								_captured = 0;
								_nearestTower = nearestObjects [owr_positions_nodes select 4, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_captured = _captured + 1;
								};
								_nearestTower = nearestObjects [owr_positions_nodes select 6, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_captured = _captured + 1;
								};
								_nearestTower = nearestObjects [owr_positions_nodes select 2, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_captured = _captured + 1;
								};

								if (_captured >= 2) then {
									// two captured, check for entry
									_nearestTower = nearestObjects [owr_positions_nodes select 3, [_wantedBuilding], 10];
									if ((count _nearestTower) > 0) then {
										// entry point exists too, player can build it on primary deposit
										_canBuild = true;
									};
								};
							};
							default {
								_canBuild = false;
							};
						};
					};
					case "control_tower_ru": {
						switch (_controlTFixatedOn) do {
							case 0: {
								// entry node
								_canBuild = true;
							};
							case 4: {
								// middle node
								_nearestTower = nearestObjects [owr_positions_nodes select 0, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_canBuild = true;
								};
							};
							case 2: {
								// middle node
								// 6 or 4 has to be captured
								_captured = false;
								_nearestTower = nearestObjects [owr_positions_nodes select 4, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_captured = true;
								};
								_nearestTower = nearestObjects [owr_positions_nodes select 6, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_captured = true;
								};
								if (_captured) then {
									_canBuild = true;
								};
							};
							case 6: {
								// middle node
								_nearestTower = nearestObjects [owr_positions_nodes select 0, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_canBuild = true;
								};
							};
							case 5: {
								// primary deposit
								// check for two captured
								_captured = 0;
								_nearestTower = nearestObjects [owr_positions_nodes select 4, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_captured = _captured + 1;
								};
								_nearestTower = nearestObjects [owr_positions_nodes select 6, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_captured = _captured + 1;
								};
								_nearestTower = nearestObjects [owr_positions_nodes select 2, [_wantedBuilding], 10];
								if ((count _nearestTower) > 0) then {
									_captured = _captured + 1;
								};

								if (_captured >= 2) then {
									// two captured, check for entry
									_nearestTower = nearestObjects [owr_positions_nodes select 0, [_wantedBuilding], 10];
									if ((count _nearestTower) > 0) then {
										// entry point exists too, player can build it on primary deposit
										_canBuild = true;
									};
								};
							};
							default {
								_canBuild = false;
							};
						};
					};
				};
				if (!_canBuild) then {
					_distanceContraint = false;
				};
			};
		};



		// misc objects can be built anywhere (no dep. on warehouse)
		if (_isMiscObj) then {
			_distanceContraint = true;
		};

		_resourceConstraint = false;
		// check if there is enough resources for this object
		if ((_wantedBuilding != "warehouse_am") && (_wantedBuilding != "warehouse_ru") && (_wantedBuilding != "warehouse_ar") && (_wantedBuilding != "control_tower_am") && (_wantedBuilding != "control_tower_ru") && (_wantedBuilding != "control_tower_ar")) then {
			_resourceArray = [_wantedBuilding] call owr_fn_getBuildingCostStr;
			if ((count _warehouses) != 0) then {
				_resourceConstraint = [_resourceArray, (_warehouses select 0)] call owr_fn_wrhsCostCheck;
			} else {
				_resourceConstraint = false;
			};
		} else {
			// warehouse type = free
			_resourceConstraint = true;
			// or control tower type, in that case, check further
			if ((_wantedBuilding == "control_tower_am") || (_wantedBuilding == "control_tower_ru") || (_wantedBuilding == "control_tower_ar")) then {
				_vehicleArray = "";
				switch (_wantedBuilding) do {
					case "control_tower_am": {
						_vehicleArray = ["owr_am_hv_tr_mn_cb_cargo","owr_am_hv_tr_mn_sb_cargo","owr_am_hv_tr_ai_cb_cargo","owr_am_hv_tr_ai_sb_cargo","owr_am_me_tr_mn_cb_cargo","owr_am_me_tr_mn_sb_cargo","owr_am_me_tr_ai_cb_cargo","owr_am_me_tr_ai_sb_cargo","owr_am_me_wh_mn_cb_cargo","owr_am_me_wh_mn_el_cargo","owr_am_me_wh_mn_sb_cargo","owr_am_me_wh_ai_cb_cargo","owr_am_me_wh_ai_el_cargo","owr_am_me_wh_ai_sb_cargo"];
					};
					case "control_tower_ar": {
						_vehicleArray = [];	// todo
					};
					case "control_tower_ru": {
						_vehicleArray = ["owr_ru_hv_tr_mn_cb_cargo","owr_ru_hv_tr_mn_sb_cargo","owr_ru_hv_tr_ai_cb_cargo","owr_ru_hv_tr_ai_sb_cargo","owr_ru_hv_wh_mn_cb_cargo","owr_ru_hv_wh_mn_sb_cargo","owr_ru_hv_wh_ai_cb_cargo","owr_ru_hv_wh_ai_sb_cargo","owr_ru_me_tr_mn_cb_cargo","owr_ru_me_tr_mn_sb_cargo","owr_ru_me_tr_ai_cb_cargo","owr_ru_me_tr_ai_sb_cargo","owr_ru_me_wh_mn_cb_cargo","owr_ru_me_wh_mn_sb_cargo","owr_ru_me_wh_ai_cb_cargo","owr_ru_me_wh_ai_sb_cargo"];
					};
				};
				_cargoVehicles = nearestObjects [_obj_placing_lastpos, _vehicleArray, 15];
				if ((count _cargoVehicles) > 0) then {
					_cargoVehicle = (_cargoVehicles select 0);
					// does it carry crates?
					if ((_cargoVehicle getVariable "ow_vehicle_cargo_type") == 0) then {
						// does it have 50 of them?
						if ((_cargoVehicle getVariable "ow_vehicle_cargo") >= 50) then {
							// good, lets remember this vehicle
						} else {
							_resourceConstraint = false;
						};
					} else {
						_resourceConstraint = false;
					};
				} else {
					_resourceConstraint = false;
				};
			};
		};
		if (_isMiscObj) then {
			_resourceConstraint = true;
		};

		//hintSilent format ["%1 %2 %3", _distanceContraint, _resourceConstraint, _positionConstraint];

		if (player getVariable "owr_confirm" && _distanceContraint && _resourceConstraint) then {
			if (_isMine && _positionConstraint) then {
				_success = true;
				if (!_isMiscObj) then {
					_responsibleUnit setVariable ["ow_worker_buildmode", 1, true];
				} else {
					_responsibleUnit setVariable ["ow_worker_buildmode", 6, true];
				};
				player setVariable ["owr_confirm", false, true];
			} else {
				if (!_isMine) then {
					_success = true;
					if (!_isMiscObj) then {
						_responsibleUnit setVariable ["ow_worker_buildmode", 1, true];
					} else {
						_responsibleUnit setVariable ["ow_worker_buildmode", 6, true];
					};
					player setVariable ["owr_confirm", false, true];
				};
			};
		} else {
			if (player getVariable "owr_confirm") then {
				_success = false;
				if (!_isMiscObj) then {
					_responsibleUnit setVariable ["ow_worker_buildmode", 1, true];
				} else {
					_responsibleUnit setVariable ["ow_worker_buildmode", 6, true];
				};
				player setVariable ["owr_cancel", false, true];
			};
		};
		if (player getVariable "owr_cancel") then {
			_success = false;
			if (!_isMiscObj) then {
				_responsibleUnit setVariable ["ow_worker_buildmode", 1, true];
			} else {
				_responsibleUnit setVariable ["ow_worker_buildmode", 6, true];
			};
			player setVariable ["owr_cancel", false, true];
		};
	};


	if (!_success) then {
		deleteVehicle _ghost;
		playSound "owr_ui_button_cancel";
	} else {
		deleteVehicle _ghost;
		playSound "owr_ui_button_confirm";
		_trueObject = createVehicle [_wantedBuilding, _obj_placing_lastpos, [], 0, "NONE"];
		_trueObject setPos _obj_placing_lastpos;
		if (_isMine) then {
			_trueObject setPos (getPos (_naturalDeposits select 0));
			//bis_curator_west removeCuratorEditableObjects [[(_naturalDeposits select 0)], true]; ;
		};
		_trueObject setDir _obj_placing_angle;
		if (!_isWarehouse) then {
			[[_wantedBuilding] call owr_fn_getBuildingCostStr, (_warehouses select 0)] call owr_fn_wrhsResourceTake;
			
			switch (_wantedBuilding) do {
				// AMERICAN BUILDINGS
				case "lab_am": {
					[_trueObject, (_warehouses select 0)] remoteExec ["owr_fn_laboratory_am", 0];
				};
				case "barracks_am": {
					[_trueObject, (_warehouses select 0), bis_curator_west] remoteExec ["owr_fn_barracks", 0];
				};
				case "factory_am": {
					[_trueObject, (_warehouses select 0), bis_curator_west] remoteExec ["owr_fn_factory", 0];
				};
				case "aturret_am": {
					[_trueObject, (_warehouses select 0), bis_curator_west] remoteExec ["owr_fn_aturret", 0];
				};
				case "mturret_am": {
					[_trueObject, (_warehouses select 0), bis_curator_west] remoteExec ["owr_fn_mturret", 0];
				};
				case "power_sol_am": {
					[_trueObject, "solar", (_warehouses select 0), bis_curator_west] remoteExec ["owr_fn_powerPlant", 0];
				};
				case "power_sib_am": {
					[_trueObject, "siberite", (_warehouses select 0), bis_curator_west] remoteExec ["owr_fn_powerPlant", 0];
				};
				case "power_oil_am": {
					[_trueObject, "oil", (_warehouses select 0), bis_curator_west] remoteExec ["owr_fn_powerPlant", 0];
				};
				case "source_sib_am": {
					[_trueObject, "ow_wrhs_siberite", (_warehouses select 0), bis_curator_west] remoteExec ["owr_fn_resourceMine", 0];
				};
				case "source_oil_am": {
					[_trueObject, "ow_wrhs_oil", (_warehouses select 0), bis_curator_west] remoteExec ["owr_fn_resourceMine", 0];
				};
				case "control_tower_am": {
					_crateAmount = _cargoVehicle getVariable "ow_vehicle_cargo";
					_cargoVehicle setVariable ["ow_vehicle_cargo", _crateAmount - 50, true];
				};


				// RUSSIAN BUILDINGS
				case "lab_ru": {
					[_trueObject, (_warehouses select 0)] remoteExec ["owr_fn_laboratory_ru", 0];
				};
				case "barracks_ru": {
					[_trueObject, (_warehouses select 0), bis_curator_east] remoteExec ["owr_fn_barracks", 0];
				};
				case "factory_ru": {
					[_trueObject, (_warehouses select 0), bis_curator_east] remoteExec ["owr_fn_factory", 0];
				};
				case "aturret_ru": {
					[_trueObject, (_warehouses select 0), bis_curator_east] remoteExec ["owr_fn_aturret", 0];
				};
				case "mturret_ru": {
					[_trueObject, (_warehouses select 0), bis_curator_east] remoteExec ["owr_fn_mturret", 0];
				};
				case "source_sib_ru": {
					[_trueObject, "ow_wrhs_siberite", (_warehouses select 0), bis_curator_east] remoteExec ["owr_fn_resourceMine", 0];
				};
				case "source_oil_ru": {
					[_trueObject, "ow_wrhs_oil", (_warehouses select 0), bis_curator_east] remoteExec ["owr_fn_resourceMine", 0];
				};
				case "power_sib_ru": {
					[_trueObject, "siberite", (_warehouses select 0), bis_curator_east] remoteExec ["owr_fn_powerPlant", 0];
				};
				case "power_oil_ru": {
					[_trueObject, "oil", (_warehouses select 0), bis_curator_east] remoteExec ["owr_fn_powerPlant", 0];
				};
				case "control_tower_ru": {
					_crateAmount = _cargoVehicle getVariable "ow_vehicle_cargo";
					_cargoVehicle setVariable ["ow_vehicle_cargo", _crateAmount - 50, true];
				};
			};
		};

		// make object accessible for zeus
		if (player == bis_curatorUnit_west) then {
			//bis_curator_west addCuratorEditableObjects [[_trueObject], false];
			//[_trueObject, bis_curator_west] call owr_fn_addEntityToCurator;
			[_trueObject, bis_curator_west] remoteExec ["owr_fn_addEntityToCurator", 0];
		};
		if (player == bis_curatorUnit_east) then {
			//bis_curator_east addCuratorEditableObjects [[_trueObject], false];
			//[_trueObject, bis_curator_east] call owr_fn_addEntityToCurator;
			[_trueObject, bis_curator_east] remoteExec ["owr_fn_addEntityToCurator", 0];
		};
		if (player == bis_curatorUnit_arab) then {
			//bis_curator_arab addCuratorEditableObjects [[_trueObject], false];
			//[_trueObject, bis_curator_arab] call owr_fn_addEntityToCurator;
			[_trueObject, bis_curator_arab] remoteExec ["owr_fn_addEntityToCurator", 0];
		};

		// move worker to that particular place
		if (!_isMiscObj) then {
			_wp = (group _responsibleUnit) addWaypoint [(getPos _trueObject), 0];
		} else {
			// set flag so it can be deleted if needed
			_trueObject setVariable ["ow_misc_object", true, true];
		};
	};
};
owr_fn_stopUnit = {
	_unitToStop = _this select 0;
	_group  = group _unitToStop;
	while {(count (waypoints _group)) > 1} do {
		deleteWaypoint ((waypoints _group) select 1);
	};
	_wp = _group addWaypoint [getPos _unitToStop, 0];
	//_unitToStop doMove (getPos _unitToStop);
	[_unitToStop, (getPos _unitToStop)] remoteExec ["doMove", owner _unitToStop];
};
owr_fn_cargoCratePickUp = {
	_cratesToPick = _this select 0;
	_responsibleVehicle = _this select 1;

	_vehicleCargo = _responsibleVehicle getVariable "ow_vehicle_cargo";	// can be 0,10,20,30,40,50,60,70,80,90,100 = FULL
	while {(_vehicleCargo < (_responsibleVehicle getVariable "ow_vehicle_cargo_cap")) && ((_cratesToPick getVariable "owr_crate_amount") > 0)} do {
		_crateCnt = _cratesToPick getVariable "owr_crate_amount";
		switch (_crateCnt) do {
			case 5: {
				_cratesToPick animate ["hide_c1", 1, true];
			};
			case 4: {
				_cratesToPick animate ["hide_c2", 1, true];
			};
			case 3: {
				_cratesToPick animate ["hide_c3", 1, true];
			};
			case 2: {
				_cratesToPick animate ["hide_c4", 1, true];
			};
			case 1: {
				if (!(isNull _cratesToPick)) then {
					deleteVehicle _cratesToPick;
				};
			};
		};
		_cratesToPick setVariable ["owr_crate_amount", _crateCnt - 1, true];
		_responsibleVehicle setVariable ["ow_vehicle_cargo", _vehicleCargo + 10, true];
		_vehicleCargo = _responsibleVehicle getVariable "ow_vehicle_cargo";
		//hintSilent format ["%1 %2", (_cratesToPick getVariable "owr_crate_amount"), _vehicleCargo];
		sleep 1;
	};
	if (player == (driver _responsibleVehicle)) then {
		hintSilent format ["%1/%2", _vehicleCargo, (_responsibleVehicle getVariable "ow_vehicle_cargo_cap")];
	};
};
owr_fn_resourcePickUp = {
	_resType = _this select 0;	// can be ow_wrhs_crates, ow_wrhs_oil, ow_wrhs_siberite
	_warehouse = _this select 1;
	_vehicle = _this select 2;

	_vehicleCargo = _vehicle getVariable "ow_vehicle_cargo";	// can be 0,10,20,30,40,50,60,70,80,90,100 = FULL
	while {(_vehicleCargo < (_vehicle getVariable "ow_vehicle_cargo_cap")) && ((_warehouse getVariable _resType) > 0)} do {
		_warehouseStorage = _warehouse getVariable _resType;
		_warehouse setVariable [_resType, _warehouseStorage - 10, true];
		_vehicle setVariable ["ow_vehicle_cargo", (_vehicleCargo + 10), true];
		_vehicleCargo = _vehicle getVariable "ow_vehicle_cargo";
		sleep 0.1;
	};

	if (player == (driver _vehicle)) then {
		hintSilent format ["%1/%2", _vehicleCargo, (_vehicle getVariable "ow_vehicle_cargo_cap")];
	};
};
owr_fn_resourceDrop = {
	_resType = _this select 0;	// can be ow_wrhs_crates, ow_wrhs_oil, ow_wrhs_siberite
	_warehouse = _this select 1;
	_vehicle = _this select 2;

	_vehicleCargo = _vehicle getVariable "ow_vehicle_cargo";	// can be 0,10,20,30,40,50,60,70,80,90,100 = FULL
	while {_vehicleCargo > 0} do {
		_warehouseStorage = _warehouse getVariable _resType;
		_warehouse setVariable [_resType, _warehouseStorage + 10, true];
		_vehicle setVariable ["ow_vehicle_cargo", (_vehicleCargo - 10), true];
		_vehicleCargo = _vehicle getVariable "ow_vehicle_cargo";
		sleep 0.1;
	};
};
owr_fn_setIdentity = {
	_unitToSet = _this select 0;
	_identity = _this select 1;
	_unitToSet setIdentity _identity;
};
owr_fn_GUIActiveCharacterList = {
	disableSerialization;
	_display = findDisplay 312;

	while {true} do {
		if (isNull _display) then {
			_display = findDisplay 312;
		} else {
			mouseConfirmEH = _display displayAddEventHandler ["MouseButtonUp", {
				_mouseButton = _this select 1;
				if (_mouseButton == 0) then {
					player setVariable ["owr_confirm", true, true];
				} else {
					if (_mouseButton == 1) then {
						player setVariable ["owr_cancel", true, true];
					};
				};
			}];

			_characterArray = _this select 0;
			_characterArrayD = _this select 1;

			_buttonLoc = 0;
			for "_buttonLoc" from 0 to 19 do {
				_buttonCtrl =  _display displayctrl (112246 + _buttonLoc);
				_buttonCtrl ctrlSetText "";
				_buttonCtrl ctrlSetTooltip "";
			};

			_buttonLoc = 0;
			// static characters
			for "_buttonLoc" from 0 to ((count _characterArray) - 1) do {
				_buttonCtrl = _display displayctrl (112246 + _buttonLoc);
				_buttonCtrl ctrlRemoveAllEventHandlers "buttonclick";
				_buttonCtrl ctrladdeventhandler ["buttonclick", {
					_unitId = (ctrlIDC (_this select 0)) - 112246;
					_characterArray = [];
					if (player == bis_curatorUnit_west) then {
						_characterArray = owr_am_characters;
					};
					if (player == bis_curatorUnit_east) then {
						_characterArray = owr_ru_characters;
					};
					if (player == bis_curatorUnit_arab) then {
						_characterArray = owr_ar_characters;
					};
					curatorCamera setPos [(getPos (_characterArray select _unitId) select 0), (getPos (_characterArray select _unitId) select 1) - 10,5];
					curatorCamera setVectorDirAndUp [[0,1,-0.5],[0,0,1]];
				}];
			};

			//hint format ["%1", ((count (_characterArrayD)) - 1)];

			// dynamic characters
			for "_buttonLoc" from ((count _characterArray)) to (((count (_characterArrayD)) - 1) + 6) do {
				_buttonCtrl = _display displayctrl (112246 + _buttonLoc);
				_buttonCtrl ctrlRemoveAllEventHandlers "buttonclick";
				_buttonCtrl ctrladdeventhandler ["buttonclick", {
					_unitId = ((ctrlIDC (_this select 0)) - 112246) - 6;
					_characterArray = [];
					if (player == bis_curatorUnit_west) then {
						_characterArray = (bis_curator_west getVariable "owr_am_characters_d");
					};
					if (player == bis_curatorUnit_east) then {
						_characterArray = (bis_curator_east getVariable "owr_ru_characters_d");
					};
					if (player == bis_curatorUnit_arab) then {
						_characterArray = (bis_curator_arab getVariable "owr_ar_characters_d");
					};
					curatorCamera setPos [(getPos (_characterArray select _unitId) select 0), (getPos (_characterArray select _unitId) select 1) - 10,5];
					curatorCamera setVectorDirAndUp [[0,1,-0.5],[0,0,1]];
				}];
			};

			while {!(isNull _display)} do {
				//hintSilent format ["%1\n%2", _characterArray, ];
				if (player == bis_curatorUnit_west) then {
					_characterArrayD = (bis_curator_west getVariable "owr_am_characters_d");
				};
				if (player == bis_curatorUnit_east) then {
					_characterArrayD = (bis_curator_east getVariable "owr_ru_characters_d");
				};
				if (player == bis_curatorUnit_arab) then {
					_characterArrayD = (bis_curator_arab getVariable "owr_ar_characters_d");
				};

				_buttonLoc = 0;
				// static characters
				{
					_buttonCtrl =  _display displayctrl (112246 + _buttonLoc);
					switch (_x getVariable "ow_class") do {
						case 0: {
							_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_soldier.paa", _x];
							if (alive _x) then {
								_buttonCtrl ctrlSetTooltip (name _x);
							} else {
								_buttonCtrl ctrlSetTooltip "KIA";
							};
						};
						case 1: {
							_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_worker.paa", _x];
							if (alive _x) then {
								_buttonCtrl ctrlSetTooltip (name _x);
							} else {
								_buttonCtrl ctrlSetTooltip "KIA";
							};
						};
						case 2: {
							_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_mechanic.paa", _x];
							if (alive _x) then {
								_buttonCtrl ctrlSetTooltip (name _x);
							} else {
								_buttonCtrl ctrlSetTooltip "KIA";
							};
						};
						case 3: {
							_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_scientist.paa", _x];
							if (alive _x) then {
								_buttonCtrl ctrlSetTooltip (name _x);
							} else {
								_buttonCtrl ctrlSetTooltip "KIA";
							};
						};
						default {};
					};
					if (!(alive _x)) then {
						_buttonCtrl ctrlSetTextColor [0.1, 0.1, 0.1, 1];
						_buttonCtrl ctrlSetActiveColor [0.15, 0.15, 0.15, 1];
					};
					_buttonLoc = _buttonLoc + 1;
				} foreach _characterArray;

				// dynamic characters
				_charIndex = 0;
				{
					_buttonCtrl =  _display displayctrl (112246 + _buttonLoc);

					if (!(isNull _x)) then {
						switch (player) do {
							case bis_curatorUnit_west: {
								switch (_x getVariable "ow_class") do {
									case 0: {
										_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_soldier.paa", ((bis_curator_west getVariable "owr_am_characters_di") select _charIndex)];
										if (alive ((bis_curator_west getVariable "owr_am_characters_d") select _charIndex)) then {
											_buttonCtrl ctrlSetTooltip (name ((bis_curator_west getVariable "owr_am_characters_d") select _charIndex));
										} else {
											_buttonCtrl ctrlSetTooltip "KIA";
										};
									};
									case 1: {
										_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_worker.paa", ((bis_curator_west getVariable "owr_am_characters_di") select _charIndex)];
										if (alive ((bis_curator_west getVariable "owr_am_characters_d") select _charIndex)) then {
											_buttonCtrl ctrlSetTooltip (name ((bis_curator_west getVariable "owr_am_characters_d") select _charIndex));
										} else {
											_buttonCtrl ctrlSetTooltip "KIA";
										};
									};
									case 2: {
										_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_mechanic.paa", ((bis_curator_west getVariable "owr_am_characters_di") select _charIndex)];
										if (alive ((bis_curator_west getVariable "owr_am_characters_d") select _charIndex)) then {
											_buttonCtrl ctrlSetTooltip (name ((bis_curator_west getVariable "owr_am_characters_d") select _charIndex));
										} else {
											_buttonCtrl ctrlSetTooltip "KIA";
										};
									};
									case 3: {
										_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_scientist.paa", ((bis_curator_west getVariable "owr_am_characters_di") select _charIndex)];
										if (alive ((bis_curator_west getVariable "owr_am_characters_d") select _charIndex)) then {
											_buttonCtrl ctrlSetTooltip (name ((bis_curator_west getVariable "owr_am_characters_d") select _charIndex));
										} else {
											_buttonCtrl ctrlSetTooltip "KIA";
										};
									};
									default {};
								};
								if (!(alive _x)) then {
									_buttonCtrl ctrlSetTextColor [0.1, 0.1, 0.1, 1];
									_buttonCtrl ctrlSetActiveColor [0.15, 0.15, 0.15, 1];
								};
							};
							case bis_curatorUnit_east: {
								switch (_x getVariable "ow_class") do {
									case 0: {
										_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_soldier.paa", ((bis_curator_east getVariable "owr_ru_characters_di") select _charIndex)];
										if (alive ((bis_curator_west getVariable "owr_ru_characters_d") select _charIndex)) then {
											_buttonCtrl ctrlSetTooltip (name ((bis_curator_east getVariable "owr_ru_characters_d") select _charIndex));
										} else {
											_buttonCtrl ctrlSetTooltip "KIA";
										};
									};
									case 1: {
										_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_worker.paa", ((bis_curator_east getVariable "owr_ru_characters_di") select _charIndex)];
										if (alive ((bis_curator_west getVariable "owr_ru_characters_d") select _charIndex)) then {
											_buttonCtrl ctrlSetTooltip (name ((bis_curator_east getVariable "owr_ru_characters_d") select _charIndex));
										} else {
											_buttonCtrl ctrlSetTooltip "KIA";
										};
									};
									case 2: {
										_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_mechanic.paa", ((bis_curator_east getVariable "owr_ru_characters_di") select _charIndex)];
										if (alive ((bis_curator_west getVariable "owr_ru_characters_d") select _charIndex)) then {
											_buttonCtrl ctrlSetTooltip (name ((bis_curator_east getVariable "owr_ru_characters_d") select _charIndex));
										} else {
											_buttonCtrl ctrlSetTooltip "KIA";
										};
									};
									case 3: {
										_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_scientist.paa", ((bis_curator_east getVariable "owr_ru_characters_di") select _charIndex)];
										if (alive ((bis_curator_west getVariable "owr_ru_characters_d") select _charIndex)) then {
											_buttonCtrl ctrlSetTooltip (name ((bis_curator_east getVariable "owr_ru_characters_d") select _charIndex));
										} else {
											_buttonCtrl ctrlSetTooltip "KIA";
										};
									};
									default {};
								};
								if (!(alive _x)) then {
									_buttonCtrl ctrlSetTextColor [0.1, 0.1, 0.1, 1];
									_buttonCtrl ctrlSetActiveColor [0.15, 0.15, 0.15, 1];
								};
							};
							case bis_curatorUnit_arab: {
								switch (_x getVariable "ow_class") do {
									case 0: {
										_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_soldier.paa", ((bis_curator_arab getVariable "owr_ar_characters_di") select _charIndex)];
										if (alive ((bis_curator_arab getVariable "owr_ar_characters_d") select _charIndex)) then {
											_buttonCtrl ctrlSetTooltip (name ((bis_curator_arab getVariable "owr_ar_characters_d") select _charIndex));
										} else {
											_buttonCtrl ctrlSetTooltip "KIA";
										};
									};
									case 1: {
										_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_worker.paa", ((bis_curator_arab getVariable "owr_ar_characters_di") select _charIndex)];
										if (alive ((bis_curator_arab getVariable "owr_ar_characters_d") select _charIndex)) then {
											_buttonCtrl ctrlSetTooltip (name ((bis_curator_arab getVariable "owr_ar_characters_d") select _charIndex));
										} else {
											_buttonCtrl ctrlSetTooltip "KIA";
										};
									};
									case 2: {
										_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_mechanic.paa", ((bis_curator_arab getVariable "owr_ar_characters_di") select _charIndex)];
										if (alive ((bis_curator_arab getVariable "owr_ar_characters_d") select _charIndex)) then {
											_buttonCtrl ctrlSetTooltip (name ((bis_curator_arab getVariable "owr_ar_characters_d") select _charIndex));
										} else {
											_buttonCtrl ctrlSetTooltip "KIA";
										};
									};
									case 3: {
										_buttonCtrl ctrlSetText format["\owr\ui\data\characters\%1_scientist.paa", ((bis_curator_arab getVariable "owr_ar_characters_di") select _charIndex)];
										if (alive ((bis_curator_arab getVariable "owr_ar_characters_d") select _charIndex)) then {
											_buttonCtrl ctrlSetTooltip (name ((bis_curator_arab getVariable "owr_ar_characters_d") select _charIndex));
										} else {
											_buttonCtrl ctrlSetTooltip "KIA";
										};
									};
									default {};
								};
								if (!(alive _x)) then {
									_buttonCtrl ctrlSetTextColor [0.1, 0.1, 0.1, 1];
									_buttonCtrl ctrlSetActiveColor [0.15, 0.15, 0.15, 1];
								};
							};
						};
					};
					_buttonLoc = _buttonLoc + 1;
					_charIndex = _charIndex + 1;
				} foreach (_characterArrayD);

				sleep 0.1;
			};
		};
	};
};
owr_fn_GUIActiveInfoBox = {
	// init-stage
	disableSerialization;

	_display = findDisplay 312;
	_owr_info_brief = _display displayctrl 112213;
	_owr_info_picture = _display displayctrl 112214;
	_owr_info_skills = _display displayctrl 112215;

	_owr_info_brief ctrlSetFont "PuristaMedium";
	_owr_info_brief ctrlCommit 0; 
	_owr_info_picture ctrlSetFont "PuristaMedium";
	_owr_info_picture ctrlSetPosition [0.3 * (((safezoneW / safezoneH) min 1.2) / 40), 0.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25), 2.85 *   (((safezoneW / safezoneH) min 1.2) / 40), 3.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)];  
	_owr_info_picture ctrlCommit 0; 
	_owr_info_skills ctrlSetFont "PuristaMedium";
	_owr_info_skills ctrlCommit 0; 

	_owr_info_brief ctrlSetStructuredText parseText "";
	_owr_info_skills ctrlSetStructuredText parseText "";
	_owr_info_picture ctrlSetText "";

	while {true} do {
		if (isNull _display) then {
			// curator is controlling an unit
			// keep checking for not null _display
			_display = findDisplay 312;
			if (!(isNull _display)) then {
				// its back!
				_owr_info_brief = _display displayctrl 112213;
				_owr_info_picture = _display displayctrl 112214;
				_owr_info_skills = _display displayctrl 112215;
				_owr_info_brief ctrlSetFont "PuristaMedium";
				_owr_info_brief ctrlCommit 0; 
				_owr_info_picture ctrlSetFont "PuristaMedium";
				_owr_info_picture ctrlSetPosition [0.3 * (((safezoneW / safezoneH) min 1.2) / 40), 0.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25), 2.85 *   (((safezoneW / safezoneH) min 1.2) / 40), 3.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)];  
				_owr_info_picture ctrlCommit 0; 
				_owr_info_skills ctrlSetFont "PuristaMedium";
				_owr_info_skills ctrlCommit 0; 

				_owr_info_brief ctrlSetStructuredText parseText "";
				_owr_info_skills ctrlSetStructuredText parseText "";
				_owr_info_picture ctrlSetText "";

				// + re-init message box
				[] call owr_fn_messageBoxInit;
			};
		} else {
			// get-info-stage
			_featureSelected = 0;
			_selected = curatorSelected select 0;
			if (count _selected == 1) then {
				// player has single unit selected
				if ((_selected select 0) isKindOf "owr_manbase") then {
					// ow man selected
					_featureSelected = 1;
				} else {
					if ((_selected select 0) isKindOf "owr_base6c") then {
						// complex ow building selected
						_featureSelected = 2;
					} else {
						if ((_selected select 0) isKindOf "owr_car") then {
							// ow vehicle
							_featureSelected = 3;
						} else {
							if ((_selected select 0) isKindOf "owr_base0c") then {
								_featureSelected = 4;
							} else {
								if ((_selected select 0) isKindOf "owr_base1c") then {
									_featureSelected = 5;
								};
							};
						};
					};
				};
			} else {
				// player has multiple units selected (think about the possibilities)
			};


			// process-info-stage
			switch (_featureSelected) do {
				case 1: {
					// ow man selected
					_owman = (_selected select 0);
					// show owman skills
					_owr_info_skills ctrlSetStructuredText parseText format["<img image='\owr\ui\data\skill_soldier.paa' /><t size='0.75' color='#ffffff' shadow='2'>  %1</t><br/><img image='\owr\ui\data\skill_worker.paa' /><t size='0.75' color='#ffffff' shadow='2'>  %2</t><br/><img image='\owr\ui\data\skill_mechanic.paa' /><t size='0.75' color='#ffffff' shadow='2'>  %3</t><br/><img image='\owr\ui\data\skill_scientist.paa' /><t size='0.75' color='#ffffff' shadow='2'>  %4</t>", floor (_owman getVariable "ow_skill_soldier"), floor (_owman getVariable "ow_skill_worker"), floor (_owman getVariable "ow_skill_mechanic"), floor (_owman getVariable "ow_skill_scientist")];
					// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
					if (!(_owman getVariable "ow_ctype")) then {
						_characterName = "KIA";
						if (alive _owman) then {
							_characterName = name _owman;
						};
						switch (_owman getVariable "ow_class") do {
							case 0: {
								_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_soldier.paa", _owman];
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#4DE027' shadow='2'> Soldier level %2</t>", _characterName, floor (_owman getVariable "ow_skill_soldier")];					
							};
							case 1: {
								_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_worker.paa", _owman];
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'> Worker level %2</t>", _characterName, floor (_owman getVariable "ow_skill_worker")];
							};
							case 2: {
								_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_mechanic.paa", _owman];
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#26ABFF' shadow='2'> Mechanic level %2</t>", _characterName, floor (_owman getVariable "ow_skill_mechanic")];
							};
							case 3: {
								_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_scientist.paa", _owman];
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'> Scientist level %2</t>", _characterName, floor (_owman getVariable "ow_skill_scientist")];
							};
							default {
							};
						};
					} else {
						_characterIndex = 0;
						switch (player) do {
							case bis_curatorUnit_west: {
								_i = 0;
								{
									if (_x == _owman) then {
										_characterIndex = _i;
									};
									_i = _i + 1;
								} forEach (bis_curator_west getVariable "owr_am_characters_d");

								_characterName = "KIA";
								if (alive _owman) then {
									_characterName = name _owman;
								};

								switch (_owman getVariable "ow_class") do {
									case 0: {
										_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_soldier.paa", ((bis_curator_west getVariable "owr_am_characters_di") select _characterIndex)];
										_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#4DE027' shadow='2'> Soldier level %2</t>", _characterName, floor (_owman getVariable "ow_skill_soldier")];					
									};
									case 1: {
										_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_worker.paa", ((bis_curator_west getVariable "owr_am_characters_di") select _characterIndex)];
										_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'> Worker level %2</t>", _characterName, floor (_owman getVariable "ow_skill_worker")];
									};
									case 2: {
										_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_mechanic.paa", ((bis_curator_west getVariable "owr_am_characters_di") select _characterIndex)];
										_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#26ABFF' shadow='2'> Mechanic level %2</t>", _characterName, floor (_owman getVariable "ow_skill_mechanic")];
									};
									case 3: {
										_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_scientist.paa", ((bis_curator_west getVariable "owr_am_characters_di") select _characterIndex)];
										_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'> Scientist level %2</t>", _characterName, floor (_owman getVariable "ow_skill_scientist")];
									};
									default {
									};
								};
							};
							case bis_curatorUnit_east: {
								_i = 0;
								{
									if (_x == _owman) then {
										_characterIndex = _i;
									};
									_i = _i + 1;
								} forEach (bis_curator_east getVariable "owr_ru_characters_d");

								_characterName = "KIA";
								if (alive _owman) then {
									_characterName = name _owman;
								};

								switch (_owman getVariable "ow_class") do {
									case 0: {
										_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_soldier.paa", ((bis_curator_east getVariable "owr_ru_characters_di") select _characterIndex)];
										_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#4DE027' shadow='2'> Soldier level %2</t>", _characterName, floor (_owman getVariable "ow_skill_soldier")];					
									};
									case 1: {
										_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_worker.paa", ((bis_curator_east getVariable "owr_ru_characters_di") select _characterIndex)];
										_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'> Worker level %2</t>", _characterName, floor (_owman getVariable "ow_skill_worker")];
									};
									case 2: {
										_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_mechanic.paa", ((bis_curator_east getVariable "owr_ru_characters_di") select _characterIndex)];
										_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#26ABFF' shadow='2'> Mechanic level %2</t>", _characterName, floor (_owman getVariable "ow_skill_mechanic")];
									};
									case 3: {
										_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_scientist.paa", ((bis_curator_east getVariable "owr_ru_characters_di") select _characterIndex)];
										_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'> Scientist level %2</t>", _characterName, floor (_owman getVariable "ow_skill_scientist")];
									};
									default {
									};
								};
							};
							case bis_curatorUnit_arab: {
								_i = 0;
								{
									if (_x == _owman) then {
										_characterIndex = _i;
									};
									_i = _i + 1;
								} forEach (bis_curator_arab getVariable "owr_ar_characters_d");

								_characterName = "KIA";
								if (alive _owman) then {
									_characterName = name _owman;
								};

								switch (_owman getVariable "ow_class") do {
									case 0: {
										_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_soldier.paa", ((bis_curator_arab getVariable "owr_ar_characters_di") select _characterIndex)];
										_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#4DE027' shadow='2'> Soldier level %2</t>", _characterName, floor (_owman getVariable "ow_skill_soldier")];					
									};
									case 1: {
										_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_worker.paa", ((bis_curator_arab getVariable "owr_ar_characters_di") select _characterIndex)];
										_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'> Worker level %2</t>", _characterName, floor (_owman getVariable "ow_skill_worker")];
									};
									case 2: {
										_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_mechanic.paa", ((bis_curator_arab getVariable "owr_ar_characters_di") select _characterIndex)];
										_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#26ABFF' shadow='2'> Mechanic level %2</t>", _characterName, floor (_owman getVariable "ow_skill_mechanic")];
									};
									case 3: {
										_owr_info_picture ctrlSetText format["\owr\ui\data\characters\%1_scientist.paa", ((bis_curator_arab getVariable "owr_ar_characters_di") select _characterIndex)];
										_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'> Scientist level %2</t>", _characterName, floor (_owman getVariable "ow_skill_scientist")];
									};
									default {
									};
								};
							};
						};
					};
				};
				case 2: {
					// complex ow building selected
					_owcbuild = (_selected select 0);

					_owr_info_skills ctrlSetStructuredText parseText "";
					_owr_info_picture ctrlSetText "";


					if ((_owcbuild isKindOf "lab_am") || (_owcbuild isKindOf "lab_ru") ) then {
						_sideStr = "am";
						_side = bis_curator_west;
						if (_owcbuild isKindOf "lab_ru") then {
							_sideStr = "ru";
							_side = bis_curator_east;
						};

						if (_owcbuild getVariable "ow_build_ready") then {
							_resInfo = "no research in progress";
							_occupancy = format ["<t size='0.75' color='#ffffff' shadow='2'> (%1/6)", count (crew _owcbuild)];

							if (_owcbuild getVariable "ow_curr_res_cat" != "") then {
								_progress = [_owcbuild getVariable "ow_curr_res_cat", _owcbuild getVariable "ow_curr_res_index", _side] call owr_fn_getResearchProgress;
								_resInfo = format["%1<br/>",  [_owcbuild getVariable "ow_curr_res_cat", _owcbuild getVariable "ow_curr_res_index", _side] call owr_fn_getResearchName];
								_progressBarRepeat = floor ((_progress * 100) / 2);
								//hintSilent format["%1", _progressBarRepeat];
								for "_i" from 0 to _progressBarRepeat do {
									_resInfo = _resInfo + "|";
								};

								_anyoneAScientist = false;
								{
									if (_x getVariable "ow_class" == 3) then {
										_anyoneAScientist = true;
									};
								} forEach (crew _owcbuild);
								if (!_anyoneAScientist) then {
									// no scientist inside, show red icon
									_occupancy = format ["<t size='0.75' color='#ff0000' shadow='2'><img image='\owr\ui\data\actions\icon_action_scientist_ca.paa' /> (%1/6)", count (crew _owcbuild)];
								};
							};

							if (_owcbuild getVariable "ow_lab_left" == "" && _owcbuild getVariable "ow_lab_right" == "") then {
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'>%2</t>", "Basic laboratory", _resInfo];
							} else {
								_left = _owcbuild getVariable "ow_lab_left";
								switch (_left) do {
									case "comp": {_left = "<img image='\owr\ui\data\research\icon_rescat_comp_ca.paa' /> " + _left;};
									case "siberite": {
										_left = "<img image='\owr\ui\data\research\icon_rescat_siberite_ca.paa' />" + _left;
										if (_owcbuild isKindOf "lab_ru") then {
											_left = "<img image='\owr\ui\data\research\icon_rescat_siberite_ca.paa' />" + "alaskite";
										};
									};
									default {left = "";};
								};
								_right = _owcbuild getVariable "ow_lab_right";
								switch (_right) do {
									case "weap": {_right = "<img image='\owr\ui\data\research\icon_rescat_weap_ca.paa' /> " + _right;};
									case "opto": {_right = "<img image='\owr\ui\data\research\icon_rescat_opto_ca.paa' />" + _right;};
									case "time": {_right = "<img image='\owr\ui\data\research\icon_rescat_timespace_ca.paa' />" + _right;};
									default {_right = "";};
								};
								if (_left == "") then {_left = "basic"};
								if (_right == "") then {_right = "basic"};
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'>%2</t>", "Advanced laboratory", _resInfo];
								_occupancy = _occupancy + format ["<t size='0.65' color='#E6D51C' shadow='2'><br/> %1<br/> %2</t>", _left, _right];
								if (((_owcbuild getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_avl") < ((_owcbuild getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req")) then {
									_occupancy = _occupancy + format ["</t><t size='0.65' color='#FF0000' shadow='2'><br/><img image='\owr\ui\data\actions\icon_action_power_ca.paa' /> %1</t>", _owcbuild getVariable "ow_lab_power_req"];
								};
							};

							_owr_info_skills ctrlSetStructuredText parseText _occupancy;

						} else {
							if (_owcbuild getVariable "ow_lab_left" == "" && _owcbuild getVariable "ow_lab_right" == "") then {
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'>under construction<br/> %2 done</t>", "Basic laboratory", (_owcbuild getVariable "ow_wip_progress")*100];
							} else {
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'>under construction<br/> %2 done</t>", "Advanced laboratory", (_owcbuild getVariable "ow_wip_progress")*100];
							};
						};
					};

					if ((_owcbuild isKindOf "factory_am") || (_owcbuild isKindOf "factory_ru")) then {
						if (_owcbuild getVariable "ow_build_ready") then {
							_factoryInfo = "no manufacturing in progress";
							_occupancy = format ["<t size='0.75' color='#ffffff' shadow='2'> (%1/6)<br/>", count (crew _owcbuild)];
							_sideUpgrades = "";

							// <img image='\owr\ui\data\buildings\icon_fext_comp_ca.paa' /> <img image='\owr\ui\data\buildings\icon_fext_siberite_ca.paa' /> <img image='\owr\ui\data\buildings\icon_fext_rocket_ca.paa' />
							if (_owcbuild getVariable "ow_build_upgrade") then {
								if ((_owcbuild getVariable "ow_factory_upgrades") select 0) then {
									//_sideUpgrades = format ["%1", "\owr\ui\data\buildings\icon_fext_tracked_ca.paa"];
									_sideUpgrades = _sideUpgrades + "<img image='\owr\ui\data\buildings\icon_fext_tracked_ca.paa' />";
								};
								if ((_owcbuild getVariable "ow_factory_upgrades") select 1) then {
									//_sideUpgrades = format ["%1<br/>%2", _sideUpgrades, "\owr\ui\data\buildings\icon_fext_gun_ca.paa"];
									_sideUpgrades = _sideUpgrades + " <img image='\owr\ui\data\buildings\icon_fext_gun_ca.paa' />";
								};
								if ((_owcbuild getVariable "ow_factory_upgrades") select 2) then {
									//_sideUpgrades = format ["%1<br/>%2", _sideUpgrades, "\owr\ui\data\buildings\icon_fext_rocket_ca.paa"];
									_sideUpgrades = _sideUpgrades + "<br/><img image='\owr\ui\data\buildings\icon_fext_rocket_ca.paa' />";
								};
								if ((_owcbuild getVariable "ow_factory_upgrades") select 3) then {
									//_sideUpgrades = format ["%1<br/>%2", _sideUpgrades, "\owr\ui\data\buildings\icon_fext_siberite_ca.paa"];
									_sideUpgrades = _sideUpgrades + " <img image='\owr\ui\data\buildings\icon_fext_siberite_ca.paa' />";
								};
								if ((_owcbuild getVariable "ow_factory_upgrades") select 4) then {
									//_sideUpgrades = format ["%1<br/>%2", _sideUpgrades, "\owr\ui\data\buildings\icon_fext_comp_ca.paa"];
									_sideUpgrades = _sideUpgrades + "<br/><img image='\owr\ui\data\buildings\icon_fext_comp_ca.paa' />";
								};
							};
							_occupancy = _occupancy + _sideUpgrades;

							if (((_owcbuild getVariable "ow_wip_progress") > 0) && ((_owcbuild getVariable "ow_wip_progress") < 1)) then {
								// manufacturing in progress
								_vClassName = [_owcbuild getVariable "ow_factory_template"] call owr_fn_getAMVehicleClass;
								if (_owcbuild isKindOf "factory_ru") then {
									_vClassName = [_owcbuild getVariable "ow_factory_template"] call owr_fn_getRUVehicleClass;
								};

								_factoryInfo = format["%1<br/>", _vClassName];

								_anyoneAMechanic = false;
								{
									if (_x getVariable "ow_class" == 2) then {
										_anyoneAMechanic = true;
									};
								} forEach (crew _owcbuild);
								if (!_anyoneAMechanic) then {
									// no mechanic inside, show red icon
									_occupancy = format ["<t size='0.75' color='#ff0000' shadow='2'><img image='\owr\ui\data\actions\icon_action_mechanic_ca.paa' /> (%1/6)<br/>", count (crew _owcbuild)];
									_occupancy = _occupancy + _sideUpgrades;
								};

								_progress = (_owcbuild getVariable "ow_wip_progress");
								_progressBarRepeat = floor ((_progress * 100) / 2);	
								for "_i" from 0 to _progressBarRepeat do {
									_factoryInfo = _factoryInfo + "|";
								};

								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.65' color='#ffffff' shadow='2'>%1</t><br/><t size='0.55' color='#E6D51C' shadow='2'>%2</t>", "Manufacturing in progress", _factoryInfo];
							} else {
								// idling
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'>%2</t>", "Factory", _factoryInfo];
							};

							if ((_owcbuild getVariable "ow_build_upgrade") && (((_owcbuild getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_avl") < ((_owcbuild getVariable "ow_build_wrhs") getVariable "ow_wrhs_power_req"))) then {
								_occupancy = _occupancy + format ["</t><t size='0.65' color='#FF0000' shadow='2'><br/><img image='\owr\ui\data\actions\icon_action_power_ca.paa' /> %1</t>", _owcbuild getVariable "ow_factory_power_req"];
							} else {
								// _sideUpgrades
								_occupancy = _occupancy + "</t>";
							};
							_owr_info_skills ctrlSetStructuredText parseText _occupancy;

						} else {
							// wip cases
							if (_owcbuild getVariable "ow_build_upgrade") then {
								if ((_owcbuild getVariable "ow_factory_side_upg") == -1) then {
									_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'>under construction<br/> %2 done</t>", "Advanced factory", (_owcbuild getVariable "ow_wip_progress")*100];
								} else {
									_sideUpgString = "";
									switch (_owcbuild getVariable "ow_factory_side_upg") do {
										case 0: {
											_sideUpgString = "Track chassis parts";
										};
										case 1: {
											_sideUpgString = "Cannon parts storage";
										};
										case 2: {
											_sideUpgString = "Rocket parts storage";
										};
										case 3: {
											_sideUpgString = "Siberite motor parts";
										};
										case 4: {
											_sideUpgString = "Advanced ai processors";
										};
									};
									_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.65' color='#ffffff' shadow='2'>Side upgrade</t><t size='0.55' color='#ffffff' shadow='2'><br/>%1</t><br/><t size='0.55' color='#E6D51C' shadow='2'>under construction<br/> %2 done</t>", _sideUpgString, (_owcbuild getVariable "ow_wip_progress")*100];
								};
							} else {
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'>under construction<br/> %2 done</t>", "Basic factory", (_owcbuild getVariable "ow_wip_progress")*100];
							};
						};
					};

					if ((_owcbuild isKindOf "warehouse_am") || (_owcbuild isKindOf "warehouse_ru")) then {
						if (_owcbuild getVariable "ow_build_ready") then {
							_tinyInfo = format ["<t size='0.75' color='#ffffff' shadow='2'> (%1/6)<br/><img image='\owr\ui\data\icon_resource_crates_ca.paa' /> %2<br/><img image='\owr\ui\data\icon_resource_oil_ca.paa' /> %3<br/><img image='\owr\ui\data\icon_resource_siberite_ca.paa' /> %4<br/></t>", count (crew _owcbuild), _owcbuild getVariable "ow_wrhs_crates", _owcbuild getVariable "ow_wrhs_oil", _owcbuild getVariable "ow_wrhs_siberite"];
							_reqPower = (_owcbuild getVariable "ow_wrhs_power_req");
							_avlPower = (_owcbuild getVariable "ow_wrhs_power_avl");
							if (_reqPower > _avlPower) then {
								_tinyInfo = _tinyInfo + format["<t size='0.75' color='#ff0000' shadow='2'><img image='\owr\ui\data\icon_resource_power_ca.paa' /> %1/%2", _reqPower, _avlPower];
							} else {
								_tinyInfo = _tinyInfo + format["<t size='0.75' color='#ffffff' shadow='2'><img image='\owr\ui\data\icon_resource_power_ca.paa' /> %1/%2", _reqPower, _avlPower];
							};
							_owr_info_skills ctrlSetStructuredText parseText _tinyInfo;
							if (_owcbuild getVariable "ow_build_upgrade") then {
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'></t>", "Warehouse"];
							} else {
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'></t>", "Depot"];
							};

						} else {
							if (_owcbuild getVariable "ow_build_upgrade") then {
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'>under construction<br/> %2 done</t>", "Warehouse", (_owcbuild getVariable "ow_wip_progress")*100];
							} else {
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'>under construction<br/> %2 done</t>", "Depot", (_owcbuild getVariable "ow_wip_progress")*100];
							};
						};
					};

					if ((_owcbuild isKIndOf "barracks_am") || (_owcbuild isKIndOf "barracks_ru")) then {
						if (_owcbuild getVariable "ow_build_ready") then {
							_tinyInfo = format ["<t size='0.75' color='#ffffff' shadow='2'> (%1/6)</t>", count (crew _owcbuild)];
							_owr_info_skills ctrlSetStructuredText parseText _tinyInfo;
							if (_owcbuild getVariable "ow_build_upgrade") then {
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'></t>", "Barracks"];
							} else {
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'></t>", "Armoury"];
							};
						} else {
							if (!(_owcbuild getVariable "ow_build_upgrade")) then {
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'>under construction<br/> %2 done</t>", "Basic armoury", (_owcbuild getVariable "ow_wip_progress")*100];
							} else {
								_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'>under construction<br/> %2 done</t>", "Advanced barracks", (_owcbuild getVariable "ow_wip_progress")*100];
							};
						};
					};
				};
				case 3: {
					// vehicle selected
					_owveh = (_selected select 0);

					_owr_info_brief ctrlSetStructuredText parseText format["%1", _owveh];
					_owr_info_skills ctrlSetStructuredText parseText "";
					_owr_info_picture ctrlSetText "";

					_cargoValue = 8;		// default for AM
					_cargoWarehouse = "warehouse_am";
					if (_owveh isKindOf "owr_car_ru") then {
						_cargoValue = 6;	// value for RU
						_cargoWarehouse = "warehouse_ru";
					};
					/*if (_owveh isKindOf "owr_car_ar") then {
						_cargoValue = 5;	// value for AR
						_cargoWarehouse = "warehouse_ar";
					};*/

					if (((_owveh getVariable "ow_vehicle_template") select 3) == _cargoValue) then {
						switch (_owveh getVariable "ow_vehicle_cargo_type") do {
							case 0: {
								_owr_info_skills ctrlSetStructuredText parseText format ["<img image='\owr\ui\data\icon_resource_crates_ca.paa' /> %1", _owveh getVariable "ow_vehicle_cargo"];
							};
							case 1: {
								_owr_info_skills ctrlSetStructuredText parseText format ["<img image='\owr\ui\data\icon_resource_oil_ca.paa' /> %1", _owveh getVariable "ow_vehicle_cargo"];
							};
							case 2: {
								_owr_info_skills ctrlSetStructuredText parseText format ["<img image='\owr\ui\data\icon_resource_siberite_ca.paa' /> %1", _owveh getVariable "ow_vehicle_cargo"];
							};
						};
						
					};
				};
				case 4: {
					// simple buildign selected (mine, plant,..)
					_simpleb = (_selected select 0);
					_stringTypeOf = "";
					_isOther = false;

					if ((_simpleb isKindOf "owr_deposit_siberite") || (_simpleb isKindOf "owr_deposit_oil")) then {
						_stringTypeOf = "Resource deposit";
						_isOther = true;
					};
					if ((_simpleb isKindOf "source_sib_am") || (_simpleb isKindOf "source_sib_ru") || (_simpleb isKindOf "source_sib_ar")) then {
						_stringTypeOf = "Siberite mine";
					};
					if ((_simpleb isKindOf "source_oil_am") || (_simpleb isKindOf "source_oil_ru") || (_simpleb isKindOf "source_oil_ar")) then {
						_stringTypeOf = "Oil drill";
					};
					if ((_simpleb isKindOf "power_sol_am") || (_simpleb isKindOf "power_sol_ar")) then {
						_stringTypeOf = "Solar power plant";
					};
					if ((_simpleb isKindOf "power_oil_am") || (_simpleb isKindOf "power_oil_ru") || (_simpleb isKindOf "power_oil_ar")) then {
						_stringTypeOf = "Diesel power plant";
					};
					if ((_simpleb isKindOf "power_sib_am") || (_simpleb isKindOf "power_sib_ru") || (_simpleb isKindOf "power_sib_ar")) then {
						_stringTypeOf = "Siberite power plant";
					};
					if ((_simpleb isKindOf "aturret_am") || (_simpleb isKindOf "aturret_ru") || (_simpleb isKindOf "aturret_ar")) then {
						_stringTypeOf = "Automatic turret base";
					};
					if ((_simpleb isKindOf "mturret_am") || (_simpleb isKindOf "mturret_ru") || (_simpleb isKindOf "mturret_ar")) then {
						_stringTypeOf = "Manual turret base";
					};

					if (_isOther) then {
						_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t>", _stringTypeOf];
						_owr_info_skills ctrlSetStructuredText parseText "";
						_owr_info_picture ctrlSetText "";
					} else {
						if (_simpleb getVariable "ow_build_ready") then {
							_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t>", _stringTypeOf];
							_owr_info_skills ctrlSetStructuredText parseText "";
							_owr_info_picture ctrlSetText "";
						} else {
							_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'>under construction<br/> %2 done</t>", _stringTypeOf, (_simpleb getVariable "ow_wip_progress")*100];
							_owr_info_skills ctrlSetStructuredText parseText "";
							_owr_info_picture ctrlSetText "";
						};
					};
				};
				case 5: {
					// turret selected
					_turret = (_selected select 0);
					_stringTypeOf = "";
					_stringTypeOfGun = "";

					if (_turret isKindOf "owr_base1c_am") then {
						switch (typeOf _turret) do {
							//mturrets
							case "owr_am_mturret_hgun": {
								_stringTypeOf = "Manual turret";
								_stringTypeOfGun = "Heavy cannon";
							};
							case "owr_am_mturret_rgun": {
								_stringTypeOf = "Manual turret";
								_stringTypeOfGun = "Minigün";
							};
							case "owr_am_mturret_mgun": {
								_stringTypeOf = "Manual turret";
								_stringTypeOfGun = "Machine gun";
							};
							case "owr_am_mturret_lgun": {
								_stringTypeOf = "Manual turret";
								_stringTypeOfGun = "Light cannon";
							};
							case "owr_am_mturret_dgun": {
								_stringTypeOf = "Manual turret";
								_stringTypeOfGun = "Double cannon";
							};
							case "owr_am_mturret_rlan": {
								_stringTypeOf = "Manual turret";
								_stringTypeOfGun = "Rocket launcher";
							};
							case "owr_am_mturret_laser": {
								_stringTypeOf = "Manual turret";
								_stringTypeOfGun = "Laser";
							};

							//aturrets
							case "owr_am_aturret_hgun": {
								_stringTypeOf = "Automatic turret";
								_stringTypeOfGun = "Heavy cannon";
							};
							case "owr_am_aturret_rgun": {
								_stringTypeOf = "Automatic turret";
								_stringTypeOfGun = "Minigun";
							};
							case "owr_am_aturret_mgun": {
								_stringTypeOf = "Automatic turret";
								_stringTypeOfGun = "Machine gun";
							};
							case "owr_am_aturret_lgun": {
								_stringTypeOf = "Automatic turret";
								_stringTypeOfGun = "Light cannon";
							};
							case "owr_am_aturret_dgun": {
								_stringTypeOf = "Automatic turret";
								_stringTypeOfGun = "Double cannon";
							};
							case "owr_am_aturret_rlan": {
								_stringTypeOf = "Automatic turret";
								_stringTypeOfGun = "Rocket launcher";
							};
							case "owr_am_aturret_laser": {
								_stringTypeOf = "Automatic turret";
								_stringTypeOfGun = "Laser";
							};
						};
					};
					if (_turret isKindOf "owr_base1c_ru") then {
						switch (typeOf _turret) do {
							//mturrets
							case "owr_ru_mturret_hgun": {
								_stringTypeOf = "Manual turret";
								_stringTypeOfGun = "Heavy cannon";
							};
							case "owr_ru_mturret_rgun": {
								_stringTypeOf = "Manual turret";
								_stringTypeOfGun = "Minigun";
							};
							case "owr_ru_mturret_hmgun": {
								_stringTypeOf = "Manual turret";
								_stringTypeOfGun = "Heavy machine gun";
							};
							case "owr_ru_mturret_gun": {
								_stringTypeOf = "Manual turret";
								_stringTypeOfGun = "Light cannon";
							};
							case "owr_ru_mturret_rlan": {
								_stringTypeOf = "Manual turret";
								_stringTypeOfGun = "Rocket launcher";
							};

							//aturrets
							case "owr_ru_mturret_hgun": {
								_stringTypeOf = "Automatic turret";
								_stringTypeOfGun = "Heavy cannon";
							};
							case "owr_ru_mturret_rgun": {
								_stringTypeOf = "Automatic turret";
								_stringTypeOfGun = "Minigun";
							};
							case "owr_ru_mturret_hmgun": {
								_stringTypeOf = "Automatic turret";
								_stringTypeOfGun = "Heavy machine gun";
							};
							case "owr_ru_mturret_gun": {
								_stringTypeOf = "Automatic turret";
								_stringTypeOfGun = "Light cannon";
							};
							case "owr_ru_mturret_rlan": {
								_stringTypeOf = "Automatic turret";
								_stringTypeOfGun = "Rocket launcher";
							};
						};
					};

					_owr_info_brief ctrlSetStructuredText parseText format["<t size='0.75' color='#ffffff' shadow='2'>%1</t><br/><t size='0.65' color='#E6D51C' shadow='2'>%2</t>", _stringTypeOf, _stringTypeOfGun];
					_owr_info_skills ctrlSetStructuredText parseText "";
					_owr_info_picture ctrlSetText "";
				};
				case 0: {
					// clear all
					_owr_info_brief ctrlSetStructuredText parseText "";
					_owr_info_skills ctrlSetStructuredText parseText "";
					_owr_info_picture ctrlSetText "";
				};
				default {};
			};
			sleep 0.1;
		};
	};
};
owr_fn_GUIActiveResourceBar = {
	disableSerialization;
	_display = findDisplay 312;
	_resourceBar = _display displayctrl 112233;
	_warehouseType = _this select 0;

	while {true} do {
		if (isNull _display) then {
			_display = findDisplay 312;
			if (!(isNull _display)) then {
				// its back!
				_resourceBar = _display displayctrl 112233;
			};
		} else {
			_warehousesAroundCamera = curatorCamera nearEntities [[_warehouseType], 300];
			_zeusCamGrid = (mapGridPosition curatorCamera);
			_warehouseInfo = "";
			if ((count _warehousesAroundCamera) > 0) then {
				_wrhs = _warehousesAroundCamera select 0;
				_wrhsType = "Basic depot at grid ";
				if (_wrhs getVariable "ow_build_upgrade") then {
					_wrhsType = "Advanced Warehouse at grid ";
				};
				_wrhsType = _wrhsType + (mapGridPosition _wrhs);

				_pwrReq = _wrhs getVariable "ow_wrhs_power_req";
				_pwrAvl = _wrhs getVariable "ow_wrhs_power_avl";
				_wrhsPowerState = format ["<t color='#eeeeee'>%1/%2</t>", _pwrReq, _pwrAvl];
				if (_pwrReq > _pwrAvl) then {
					_wrhsPowerState = format ["<t color='#ff0000' shadow='2'>%1/%2</t>", _pwrReq, _pwrAvl];
				};
				_warehouseInfo = format["<t color='#eeeeee' align='center' shadow='2'>%1  | <img image='\owr\ui\data\icon_resource_crates_ca.paa' /> %2  <img image='\owr\ui\data\icon_resource_oil_ca.paa' /> %3  <img image='\owr\ui\data\icon_resource_siberite_ca.paa' /> %4  |  <img image='\owr\ui\data\icon_resource_power_ca.paa' /> %5</t>", _wrhsType, _wrhs getVariable "ow_wrhs_crates", _wrhs getVariable "ow_wrhs_oil", _wrhs getVariable "ow_wrhs_siberite", _wrhsPowerState];
			};
			_resourceBar ctrlSetStructuredText parseText format ["<t color='#eeeeee'>Camera grid %1</t> %2", _zeusCamGrid, _warehouseInfo];
			sleep 1;
		};
	};
};
owr_fn_GUIActiveActionButtons = {

	disableSerialization;
	_display = findDisplay 312;
	_owr_action1 = _display displayctrl 112224;
	_owr_action2 = _display displayctrl 112225;
	_owr_action3 = _display displayctrl 112226;
	_owr_action4 = _display displayctrl 112227;
	_owr_action5 = _display displayctrl 112228;
	_owr_action6 = _display displayctrl 112229;
	_owr_action7 = _display displayctrl 112230;
	_owr_action8 = _display displayctrl 112231;
	_owr_action9 = _display displayctrl 112232;

	_actionButtons = [_owr_action1, _owr_action2, _owr_action3, _owr_action4, _owr_action5, _owr_action6, _owr_action7, _owr_action8, _owr_action9];

	while {true} do {
		if (isNull _display) then {
			_display = findDisplay 312;
			if (!(isNull _display)) then {
				_owr_action1 = _display displayctrl 112224;
				_owr_action2 = _display displayctrl 112225;
				_owr_action3 = _display displayctrl 112226;
				_owr_action4 = _display displayctrl 112227;
				_owr_action5 = _display displayctrl 112228;
				_owr_action6 = _display displayctrl 112229;
				_owr_action7 = _display displayctrl 112230;
				_owr_action8 = _display displayctrl 112231;
				_owr_action9 = _display displayctrl 112232;
				_actionButtons = [_owr_action1, _owr_action2, _owr_action3, _owr_action4, _owr_action5, _owr_action6, _owr_action7, _owr_action8, _owr_action9];
			};
		} else {
			// get-info-stage
			_featureSelected = 0;
			_selected = curatorSelected select 0;
			if (count _selected == 1) then {
				// player has single unit selected
				if (((_selected select 0) isKindOf "owr_manbase")) then {
					// ow man selected
					if (alive (_selected select 0)) then {
						_featureSelected = 1;
					} else {
						// dead personnel
						_featureSelected = 6;
					};
				} else {
					if ((_selected select 0) isKindOf "owr_base6c") then {
						// complex ow building selected
						if (((damage (_selected select 0)) < 1.0) && !((_selected select 0) getVariable "ow_build_destroyed")) then {
							_featureSelected = 2;
						} else {
							// destroyed building
							_featureSelected = 7;
						};
					} else {
						if ((_selected select 0) isKindOf "owr_car") then {
							// ow vehicle
							if ((damage (_selected select 0)) < 1.0) then {
								_featureSelected = 3;
							} else {
								// destroyed vehicle
								_featureSelected = 7;
							};
						} else {
							if (((_selected select 0) isKindOf "owr_base0c")) then {
								if (((damage (_selected select 0)) < 1.0) && !((_selected select 0) getVariable "ow_build_destroyed")) then {
									_featureSelected = 4;
								} else {
									// destroyed building
									_featureSelected = 7;
								};
							} else {
								if (((_selected select 0) isKindOf "owr_base1c")) then {
									if (((damage (_selected select 0)) < 1.0) && !(((_selected select 0) getVariable "ow_turret_stand") getVariable "ow_build_destroyed")) then {
										_featureSelected = 4;
									} else {
										// destroyed mturret
										_featureSelected = 7;
									};
								} else {
									// something else..
									_featureSelected = 5;
								};								
							};
						};
					};
				};
			} else {
				if ((count _selected) > 1) then {
					// player has multiple units selected (think about the possibilities)
					_multiSelect = (curatorSelected select 0);
					// test if all the selected units are kind of owr_manbase
					_allOwMans = true;
					{
						if (_x isKindOf "owr_manbase") then {
						} else {
							_allOwMans = false;
						};
					} foreach _multiSelect;

					if (_allOwMans) then {
						_featureSelected = 8;
					};
				};
			};

			// process-info-stage
			switch (_featureSelected) do {
				case 1: {
					// ow man selected
					_owman = (_selected select 0);
					// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
					switch (_owman getVariable "ow_class") do {
						case 0: {
							/*
							// SOLDIER
							// default actions:
							// a1 = move
							// a2 = attack
							// a3 = station/active
							// a4 = stand up
							// a5 = -
							// a6 = -
							// a7 = prone
							// a8 = -
							// a9 = cancel / stop
							*/

							{
								_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
								_x ctrlSetActiveColor [1, 1, 1, 1];
							} forEach _actionButtons;

							if ((vehicle _owman) != _owman) then {
								_barrMode = 0;
								if (((vehicle _owman) isKindOf "barracks_am") || ((vehicle _owman) isKindOf "barracks_ru") || ((vehicle _owman) isKindOf "barracks_ar")) then {
									_barr = (vehicle _owman);
									if ((_barr getVariable "ow_build_upgrade") && !(isNull (_barr getVariable "ow_build_wrhs"))) then {
										// upgraded barracks - connected to storage house (offer basic and special loadouts for soldiers)
										_barrMode = 1;
									} else {
										if (!(_barr getVariable "ow_build_upgrade") && !(isNull (_barr getVariable "ow_build_wrhs"))) then {
											// normal barracks - connected to storage house (offer basic loadouts for soldiers)
											_barrMode = 2;
										} else {
											// normal/upgraded barracks - disconnected from storage (do not offer special loadouts for soldiers)
											_barrMode = 3;
										};
									};
								};

								switch (_barrMode) do {
									// soldier is in another building (not barracks)
									case 0: {
										_owr_action9 ctrlSetText "";
										_owr_action9 ctrlSetTooltip "";
										_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action8 ctrlSetText "";
										_owr_action8 ctrlSetTooltip "";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action7 ctrlSetText "";
										_owr_action7 ctrlSetTooltip "";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action6 ctrlSetText "";
										_owr_action6 ctrlSetTooltip "e";
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action5 ctrlSetText "";
										_owr_action5 ctrlSetTooltip "";
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action4 ctrlSetText "";
										_owr_action4 ctrlSetTooltip "";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

										if (((vehicle _owman) isKindOf "lab_am") || ((vehicle _owman) isKindOf "lab_ru") || ((vehicle _owman) isKindOf "lab_ar")) then {
											_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makescientist_ca.paa";
											_owr_action3 ctrlSetTooltip "Change class to scientist";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_owman = (curatorSelected select 0) select 0;
												_owman setVariable ["ow_class", 3, true];
												//[_owman, 3] call owr_fn_changeClassGear;
												[_owman, 3] remoteExec ["owr_fn_changeClassGear", owner _owman];
												playSound "owr_ui_button_confirm";
											}];
										} else {
											if (((vehicle _owman) isKindOf "factory_am") || ((vehicle _owman) isKindOf "factory_ru") || ((vehicle _owman) isKindOf "factory_ar")) then {
												_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makemechanic_ca.paa";
												_owr_action3 ctrlSetTooltip "Change class to mechanic";
												_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action3 ctrladdeventhandler ["buttonclick", {
													_owman = (curatorSelected select 0) select 0;
													_owman setVariable ["ow_class", 2, true];
													//[_owman, 2] call owr_fn_changeClassGear;
													[_owman, 2] remoteExec ["owr_fn_changeClassGear", owner _owman];
													playSound "owr_ui_button_confirm";
												}];
											} else {
												if (((vehicle _owman) isKindOf "warehouse_am") || ((vehicle _owman) isKindOf "warehouse_ru") || ((vehicle _owman) isKindOf "warehouse_ar")) then {
													_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makeworker_ca.paa";
													_owr_action3 ctrlSetTooltip "Change class to worker";
													_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
													_owr_action3 ctrladdeventhandler ["buttonclick", {
														_owman = (curatorSelected select 0) select 0;
														_owman setVariable ["ow_class", 1, true];
														//[_owman, 1] call owr_fn_changeClassGear;
														[_owman, 1] remoteExec ["owr_fn_changeClassGear", owner _owman];
														playSound "owr_ui_button_confirm";
													}];
												} else {
													_owr_action3 ctrlSetText "";
													_owr_action3 ctrlSetTooltip "";
													_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
												};
											};
										};

										_owr_action2 ctrlSetText "";
										_owr_action2 ctrlSetTooltip "";
										_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
										_owr_action1 ctrlSetTooltip "Get out (G)";
										_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_unitToEject = (curatorSelected select 0) select 0;
											[_unitToEject] call owr_fn_getOutOfVehicle;
											playSound "owr_ui_button_confirm";
										}];	
									};

									// basic and special loadouts (adv. barracks)
									//  rifle auto life drone sharp at aa
									case 1: {
										_owr_action9 ctrlSetText "";
										_owr_action9 ctrlSetTooltip "";
										_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action8 ctrlSetText "";
										_owr_action8 ctrlSetTooltip "";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										//_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_makesoldier_ca.paa";
										//_owr_action8 ctrlSetTooltip "Special: Missile specialist (AA) (Costs: 5 crates)";
										//_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_makesoldier_ca.paa";
										_owr_action7 ctrlSetTooltip "Special: Missile specialist (AT) (Costs: 5 crates)";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action7 ctrladdeventhandler ["buttonclick", {
											_unitToChange = (curatorSelected select 0) select 0;
											_loadoutType = "at";
											_cost = 5;
											if (((((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates") >= _cost) || owr_devhax) then {
												// enough crates
												_crateCnt = (((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates");
												((vehicle _unitToChange) getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", (_crateCnt - _cost), true];
												if (_unitToChange isKindOf "owr_man_am") then {
													[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeAMSoldierGear", owner _owman];
												} else {
													if (_unitToChange isKindOf "owr_man_ru") then {
														[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeRUSoldierGear", owner _owman];
													} else {
														//[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeARSoldierGear", owner _owman];
													};
												};
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	

										_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_action_makesoldier_ca.paa";
										_owr_action6 ctrlSetTooltip "Special: Sharpshooter (Costs: 3 crates)";
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action6 ctrladdeventhandler ["buttonclick", {
											_unitToChange = (curatorSelected select 0) select 0;
											_loadoutType = "sharp";
											_cost = 3;
											if (((((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates") >= _cost) || owr_devhax) then {
												// enough crates
												_crateCnt = (((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates");
												((vehicle _unitToChange) getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", (_crateCnt - _cost), true];
												if (_unitToChange isKindOf "owr_man_am") then {
													[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeAMSoldierGear", owner _owman];
												} else {
													if (_unitToChange isKindOf "owr_man_ru") then {
														[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeRUSoldierGear", owner _owman];
													} else {
														//[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeARSoldierGear", owner _owman];
													};
												};
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	

										_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_makesoldier_ca.paa";
										_owr_action5 ctrlSetTooltip "Special: Drone operator (Costs: 3 crates)";
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action5 ctrladdeventhandler ["buttonclick", {
											_unitToChange = (curatorSelected select 0) select 0;
											_loadoutType = "drone";
											_cost = 3;
											if (((((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates") >= _cost) || owr_devhax) then {
												// enough crates
												_crateCnt = (((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates");
												((vehicle _unitToChange) getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", (_crateCnt - _cost), true];
												if (_unitToChange isKindOf "owr_man_am") then {
													[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeAMSoldierGear", owner _owman];
												} else {
													if (_unitToChange isKindOf "owr_man_ru") then {
														[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeRUSoldierGear", owner _owman];
													} else {
														//[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeARSoldierGear", owner _owman];
													};
												};
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	

										_owr_action4 ctrlSetText "\owr\ui\data\actions\icon_action_makesoldier_ca.paa";
										_owr_action4 ctrlSetTooltip "Basic: Combat life saver (Costs: 2 crates)";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action4 ctrladdeventhandler ["buttonclick", {
											_unitToChange = (curatorSelected select 0) select 0;
											_loadoutType = "life";
											_cost = 2;
											if (((((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates") >= _cost) || owr_devhax) then {
												// enough crates
												_crateCnt = (((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates");
												((vehicle _unitToChange) getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", (_crateCnt - _cost), true];
												if (_unitToChange isKindOf "owr_man_am") then {
													[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeAMSoldierGear", owner _owman];
												} else {
													if (_unitToChange isKindOf "owr_man_ru") then {
														[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeRUSoldierGear", owner _owman];
													} else {
														//[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeARSoldierGear", owner _owman];
													};
												};
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	

										_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makesoldier_ca.paa";
										_owr_action3 ctrlSetTooltip "Basic: Autorifleman (Costs: 1 crate)";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_unitToChange = (curatorSelected select 0) select 0;
											_loadoutType = "auto";
											_cost = 1;
											if (((((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates") >= _cost) || owr_devhax) then {
												// enough crates
												_crateCnt = (((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates");
												((vehicle _unitToChange) getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", (_crateCnt - _cost), true];
												if (_unitToChange isKindOf "owr_man_am") then {
													[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeAMSoldierGear", owner _owman];
												} else {
													if (_unitToChange isKindOf "owr_man_ru") then {
														[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeRUSoldierGear", owner _owman];
													} else {
														//[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeARSoldierGear", owner _owman];
													};
												};
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	

										_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_makesoldier_ca.paa";
										_owr_action2 ctrlSetTooltip "Basic: Rifleman (Costs: 1 crate)";
										_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_unitToChange = (curatorSelected select 0) select 0;
											_loadoutType = "rifle";
											_cost = 0;
											if (((((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates") >= _cost) || owr_devhax) then {
												// enough crates
												_crateCnt = (((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates");
												((vehicle _unitToChange) getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", (_crateCnt - _cost), true];
												if (_unitToChange isKindOf "owr_man_am") then {
													[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeAMSoldierGear", owner _owman];
												} else {
													if (_unitToChange isKindOf "owr_man_ru") then {
														[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeRUSoldierGear", owner _owman];
													} else {
														//[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeARSoldierGear", owner _owman];
													};
												};
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	

										_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
										_owr_action1 ctrlSetTooltip "Get out (G)";
										_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_unitToEject = (curatorSelected select 0) select 0;
											[_unitToEject] call owr_fn_getOutOfVehicle;
											playSound "owr_ui_button_confirm";
										}];	
									};

									// basic loadouts (normal barracks)
									case 2: {
										_owr_action9 ctrlSetText "";
										_owr_action9 ctrlSetTooltip "";
										_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action8 ctrlSetText "";
										_owr_action8 ctrlSetTooltip "";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action7 ctrlSetText "";
										_owr_action7 ctrlSetTooltip "";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action6 ctrlSetText "";
										_owr_action6 ctrlSetTooltip "";
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action5 ctrlSetText "";
										_owr_action5 ctrlSetTooltip "";
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action4 ctrlSetText "\owr\ui\data\actions\icon_action_makesoldier_ca.paa";
										_owr_action4 ctrlSetTooltip "Basic: Combat life saver (Costs: 2 crates)";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action4 ctrladdeventhandler ["buttonclick", {
											_unitToChange = (curatorSelected select 0) select 0;
											_loadoutType = "life";
											_cost = 2;
											if (((((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates") >= _cost) || owr_devhax) then {
												// enough crates
												_crateCnt = (((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates");
												((vehicle _unitToChange) getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", (_crateCnt - _cost), true];
												if (_unitToChange isKindOf "owr_man_am") then {
													[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeAMSoldierGear", owner _owman];
												} else {
													if (_unitToChange isKindOf "owr_man_ru") then {
														[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeRUSoldierGear", owner _owman];
													} else {
														//[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeARSoldierGear", owner _owman];
													};
												};
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	

										_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makesoldier_ca.paa";
										_owr_action3 ctrlSetTooltip "Basic: Autorifleman (Costs: 1 crate)";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_unitToChange = (curatorSelected select 0) select 0;
											_loadoutType = "auto";
											_cost = 1;
											if (((((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates") >= _cost) || owr_devhax) then {
												// enough crates
												_crateCnt = (((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates");
												((vehicle _unitToChange) getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", (_crateCnt - _cost), true];
												if (_unitToChange isKindOf "owr_man_am") then {
													[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeAMSoldierGear", owner _owman];
												} else {
													if (_unitToChange isKindOf "owr_man_ru") then {
														[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeRUSoldierGear", owner _owman];
													} else {
														//[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeARSoldierGear", owner _owman];
													};
												};
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	

										_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_makesoldier_ca.paa";
										_owr_action2 ctrlSetTooltip "Basic: Rifleman";
										_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_unitToChange = (curatorSelected select 0) select 0;
											_loadoutType = "rifle";
											_cost = 0;
											if (((((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates") >= _cost) || owr_devhax) then {
												// enough crates
												_crateCnt = (((vehicle _unitToChange) getVariable "ow_build_wrhs") getVariable "ow_wrhs_crates");
												((vehicle _unitToChange) getVariable "ow_build_wrhs") setVariable ["ow_wrhs_crates", (_crateCnt - _cost), true];
												if (_unitToChange isKindOf "owr_man_am") then {
													[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeAMSoldierGear", owner _owman];
												} else {
													if (_unitToChange isKindOf "owr_man_ru") then {
														[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeRUSoldierGear", owner _owman];
													} else {
														//[_unitToChange, _loadoutType] remoteExec ["owr_fn_changeARSoldierGear", owner _owman];
													};
												};
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	

										// 

										_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
										_owr_action1 ctrlSetTooltip "Get out (G)";
										_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_unitToEject = (curatorSelected select 0) select 0;
											[_unitToEject] call owr_fn_getOutOfVehicle;
											playSound "owr_ui_button_confirm";
										}];	
									};

									// disconnected barracks (no custom loadouts)
									case 3: {
										_owr_action9 ctrlSetText "";
										_owr_action9 ctrlSetTooltip "";
										_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action8 ctrlSetText "";
										_owr_action8 ctrlSetTooltip "";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action7 ctrlSetText "";
										_owr_action7 ctrlSetTooltip "";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action6 ctrlSetText "";
										_owr_action6 ctrlSetTooltip "";
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action5 ctrlSetText "";
										_owr_action5 ctrlSetTooltip "";
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action4 ctrlSetText "";
										_owr_action4 ctrlSetTooltip "";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action3 ctrlSetText "";
										_owr_action3 ctrlSetTooltip "";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action2 ctrlSetText "";
										_owr_action2 ctrlSetTooltip "";
										_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
										_owr_action1 ctrlSetTooltip "Get out (G)";
										_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_unitToEject = (curatorSelected select 0) select 0;
											[_unitToEject] call owr_fn_getOutOfVehicle;
											playSound "owr_ui_button_confirm";
										}];	
									};
								};
							} else {
								_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
								_owr_action9 ctrlSetTooltip "Cancel / Stop";
								_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action9 ctrladdeventhandler ["buttonclick", {
									_unitToStop = (curatorSelected select 0) select 0;
									[_unitToStop] call owr_fn_stopUnit;
									playSound "owr_ui_button_cancel";
								}];	

								_owr_action8 ctrlSetText "";
								_owr_action8 ctrlSetTooltip "";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action7 ctrlSetText "\A3\ui_f_curator\Data\Logos\arma3_curator_logo_ca.paa";
								_owr_action7 ctrlSetTooltip "Take control";
								_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action7 ctrladdeventhandler ["buttonclick", {
									_unitToTakeControl = (curatorSelected select 0) select 0;
									[_unitToTakeControl] spawn owr_fn_remoteControl;
									playSound "owr_ui_button_confirm";
								}];

								_owr_action6 ctrlSetText "";
								_owr_action6 ctrlSetTooltip "";
								_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action5 ctrlSetText "";
								_owr_action5 ctrlSetTooltip "";
								_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action4 ctrlSetText "";
								_owr_action4 ctrlSetTooltip "";
								_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

								if ((_owman getVariable "ow_aitype") == 0) then {
									_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_standstill_ca.paa";
									_owr_action3 ctrlSetTooltip "Stationary mode";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_aitype", 1, true];
										playSound "owr_ui_button_confirm";
									}];
								} else {
									_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_free_ca.paa";
									_owr_action3 ctrlSetTooltip "Active mode";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_aitype", 0, true];
										[_unitToChange] call owr_fn_stopUnit;
										playSound "owr_ui_button_confirm";
									}];
								};

								_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_attack_ca.paa";
								_owr_action2 ctrlSetTooltip "Attack";
								_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action2 ctrladdeventhandler ["buttonclick", {
									_unitToChange = (curatorSelected select 0) select 0;
									playSound "owr_ui_button_confirm";
									[_unitToChange] spawn owr_fn_attackSomething;
								}];

								_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_move_ca.paa";
								_owr_action1 ctrlSetTooltip format ["Change behaviour to %1", [(curatorSelected select 0) select 0] call owr_fn_unitGetNextBehaviour];
								_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action1 ctrladdeventhandler ["buttonclick", {
									_unitToChange = (curatorSelected select 0) select 0;
									[_unitToChange, [_unitToChange] call owr_fn_unitGetNextBehaviour] remoteExec ["setBehaviour", owner _unitToChange];
									playSound "owr_ui_button_confirm";
								}];
							};
						};
						case 1: {
							/*
							// WORKER
							// default actions:
							// a1 = move
							// a2 = attack
							// a3 = station/active
							// a4 = build
							// a5 = repair
							// a6 = pickup
							// a7 = recycle
							// a8 = -
							// a9 = cancel / stop 
							*/
							{
								_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
								_x ctrlSetActiveColor [1, 1, 1, 1];
							} forEach _actionButtons;

							// if in vehicle / building - show only Get out (G) action
							if ((vehicle _owman) != _owman) then {
								_owman setVariable ["ow_worker_buildmode", 0, true];
							};

							// check side of the unit
							_sideStr = "am";
							if (_owman isKindOf "owr_man_ru") then {
								_sideStr = "ru";
							} else {
								if (_owman isKindOf "owr_man_ar") then {
									_sideStr = "ar";
								};
							};

							switch ((_owman getVariable "ow_worker_buildmode")) do {
								case 0: {
									// NORMAL WORKER BUTTONS
									if ((vehicle _owman) != _owman) then {
										_owr_action9 ctrlSetText "";
										_owr_action9 ctrlSetTooltip "";
										_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action8 ctrlSetText "";
										_owr_action8 ctrlSetTooltip "";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action7 ctrlSetText "";
										_owr_action7 ctrlSetTooltip "";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action6 ctrlSetText "";
										_owr_action6 ctrlSetTooltip "";
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action5 ctrlSetText "";
										_owr_action5 ctrlSetTooltip "";
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action4 ctrlSetText "";
										_owr_action4 ctrlSetTooltip "";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

										if (((vehicle _owman) isKindOf "lab_am") || ((vehicle _owman) isKindOf "lab_ru") || ((vehicle _owman) isKindOf "lab_ar")) then {
											_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makescientist_ca.paa";
											_owr_action3 ctrlSetTooltip "Change class to scientist";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_owman = (curatorSelected select 0) select 0;
												_owman setVariable ["ow_class", 3, true];
												//[_owman, 3] call owr_fn_changeClassGear;
												[_owman, 3] remoteExec ["owr_fn_changeClassGear", owner _owman];
												playSound "owr_ui_button_confirm";
											}];
										} else {
											if (((vehicle _owman) isKindOf "factory_am") || ((vehicle _owman) isKindOf "factory_ru") || ((vehicle _owman) isKindOf "factory_ar")) then {
												_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makemechanic_ca.paa";
												_owr_action3 ctrlSetTooltip "Change class to mechanic";
												_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action3 ctrladdeventhandler ["buttonclick", {
													_owman = (curatorSelected select 0) select 0;
													_owman setVariable ["ow_class", 2, true];
													//[_owman, 2] call owr_fn_changeClassGear;
													[_owman, 2] remoteExec ["owr_fn_changeClassGear", owner _owman];
													playSound "owr_ui_button_confirm";
												}];
											} else {
												if (((vehicle _owman) isKindOf "barracks_am") || ((vehicle _owman) isKindOf "barracks_ru") || ((vehicle _owman) isKindOf "barracks_ar")) then {
													_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makesoldier_ca.paa";
													_owr_action3 ctrlSetTooltip "Change class to soldier";
													_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
													_owr_action3 ctrladdeventhandler ["buttonclick", {
														_owman = (curatorSelected select 0) select 0;
														_owman setVariable ["ow_class", 0, true];
														//[_owman, 0] call owr_fn_changeClassGear;
														[_owman, 0] remoteExec ["owr_fn_changeClassGear", owner _owman];
														playSound "owr_ui_button_confirm";
													}];
												} else {
													_owr_action3 ctrlSetText "";
													_owr_action3 ctrlSetTooltip "";
													_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
												};
											};
										};

										_owr_action2 ctrlSetText "";
										_owr_action2 ctrlSetTooltip "";
										_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
										_owr_action1 ctrlSetTooltip "Get out (G)";
										_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_unitToEject = (curatorSelected select 0) select 0;
											[_unitToEject] call owr_fn_getOutOfVehicle;
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
										_owr_action9 ctrlSetTooltip "Cancel / Stop";
										_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action9 ctrladdeventhandler ["buttonclick", {
											_unitToStop = (curatorSelected select 0) select 0;
											[_unitToStop] call owr_fn_stopUnit;
											playSound "owr_ui_button_cancel";
										}];	

										_owr_action8 ctrlSetText "";
										_owr_action8 ctrlSetTooltip "";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action7 ctrlSetText "\A3\ui_f_curator\Data\Logos\arma3_curator_logo_ca.paa";
										_owr_action7 ctrlSetTooltip "Take control";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action7 ctrladdeventhandler ["buttonclick", {
											_unitToTakeControl = (curatorSelected select 0) select 0;
											[_unitToTakeControl] spawn owr_fn_remoteControl;
											playSound "owr_ui_button_confirm";
										}];

										_owr_action6 ctrlSetText "";
										_owr_action6 ctrlSetTooltip "";
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_bbuild_ca.paa";
										_owr_action5 ctrlSetTooltip "Build misc assets ( warning - usage is un-limited - use it in a fair way please! )";
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action5 ctrladdeventhandler ["buttonclick", {
											_unitToChange = (curatorSelected select 0) select 0;
											_unitToChange setVariable ["ow_worker_buildmode", 6, true];
											playSound "owr_ui_button_confirm";
										}];	

										_owr_action4 ctrlSetText "\owr\ui\data\actions\icon_action_bbuild_ca.paa";
										_owr_action4 ctrlSetTooltip "Build";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action4 ctrladdeventhandler ["buttonclick", {
											_unitToChange = (curatorSelected select 0) select 0;
											_unitToChange setVariable ["ow_worker_buildmode", 1, true];
											playSound "owr_ui_button_confirm";
										}];	

										if ((_owman getVariable "ow_aitype") == 0) then {
											_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_standstill_ca.paa";
											_owr_action3 ctrlSetTooltip "Stationary mode";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_aitype", 1, true];
												playSound "owr_ui_button_confirm";
											}];
										} else {
											_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_free_ca.paa";
											_owr_action3 ctrlSetTooltip "Active mode";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_aitype", 0, true];
												[_unitToChange] call owr_fn_stopUnit;
												playSound "owr_ui_button_confirm";
											}];
										};

										_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_attack_ca.paa";
										_owr_action2 ctrlSetTooltip "Attack";
										_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_unitToChange = (curatorSelected select 0) select 0;
											playSound "owr_ui_button_confirm";
											[_unitToChange] spawn owr_fn_attackSomething;
										}];

										_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_move_ca.paa";
										_owr_action1 ctrlSetTooltip format ["Change behaviour to %1", [(curatorSelected select 0) select 0] call owr_fn_unitGetNextBehaviour];
										_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_unitToChange = (curatorSelected select 0) select 0;
											[_unitToChange, [_unitToChange] call owr_fn_unitGetNextBehaviour] remoteExec ["setBehaviour", owner _unitToChange];
											playSound "owr_ui_button_confirm";
										}];
									};
								};
								case 1: {
									// MAIN BUILDINGS
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	


									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									switch (_sideStr) do {
										case "am": {
											_owr_action8 ctrlSetText "";
											_owr_action8 ctrlSetTooltip "";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										};
										case "ru": {
											_owr_action8 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action8 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_teleport_ca.paa";
											_owr_action8 ctrlSetTooltip "Build teleport ( not yet implemented )";
											/*_owr_action8 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "lab_ru"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];	*/
										};
										case "ar": {
											_owr_action8 ctrlSetText "";
											_owr_action8 ctrlSetTooltip "";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										};
									};

									_domiSwitch = ["DominationVictory"] call BIS_fnc_getParamValue;	// check if it is enabled
									if (_domiSwitch == 1) then {
										_owr_action7 ctrlSetTooltip "Build control tower (costs 50 crates, can only be built on a node)";
										_owr_action7 ctrlSetText "\owr\ui\data\buildings\icon_control_tower_ca.paa";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
										switch (_sideStr) do {
											case "am": {
												_owr_action7 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "control_tower_am"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];	
											};
											case "ru": {
												_owr_action7 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "control_tower_ru"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];	
											};
											case "ar": {
												_owr_action7 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "control_tower_ar"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];	
											};
										};
									} else {
										_owr_action7 ctrlSetTooltip "Build control tower (domination disabled)";
										_owr_action7 ctrlSetText "\owr\ui\data\buildings\icon_control_tower_ca.paa";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action7 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action7 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
									};

									_owr_action6 ctrlSetText "\owr\ui\data\buildings\icon_defense_ca.paa";
									_owr_action6 ctrlSetTooltip "Build defense";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action6 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 3, true];
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action5 ctrlSetText "\owr\ui\data\buildings\icon_sources_ca.paa";
									_owr_action5 ctrlSetTooltip "Manage resources";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action5 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 2, true];
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action4 ctrlSetText "\owr\ui\data\buildings\icon_lab_ca";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									switch (_sideStr) do {
										case "am": {
											_resourceArray = ["lab_am"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action4 ctrlSetTooltip format ["Build laboratory %1", _costString];

											_owr_action4 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "lab_am"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];	
										};
										case "ru": {
											_resourceArray = ["lab_ru"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action4 ctrlSetTooltip format ["Build laboratory %1", _costString];

											_owr_action4 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "lab_ru"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];	
										};
										case "ar": {
											_resourceArray = ["lab_ar"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action4 ctrlSetTooltip format ["Build laboratory %1", _costString];

											_owr_action4 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "lab_ar"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];	
										};
									};

									_owr_action3 ctrlSetText "\owr\ui\data\buildings\icon_barracks_ca.paa";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									switch (_sideStr) do {
										case "am": {
											_resourceArray = ["barracks_am"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action3 ctrlSetTooltip format ["Build barracks %1", _costString];

											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "barracks_am"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];	
										};
										case "ru": {
											_resourceArray = ["barracks_ru"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action3 ctrlSetTooltip format ["Build barracks %1", _costString];

											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "barracks_ru"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];	
										};
										case "ar": {
											_resourceArray = ["barracks_ar"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action3 ctrlSetTooltip format ["Build barracks %1", _costString];

											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "barracks_ar"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];	
										};
									};

									_owr_action2 ctrlSetText "\owr\ui\data\buildings\icon_factory_ca.paa";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									switch (_sideStr) do {
										case "am": {
											_resourceArray = ["factory_am"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action2 ctrlSetTooltip format ["Build factory %1", _costString];

											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "factory_am"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];	
										};
										case "ru": {
											_resourceArray = ["factory_ru"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action2 ctrlSetTooltip format ["Build factory %1", _costString];

											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "factory_ru"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];
										};
										case "ar": {
											_resourceArray = ["factory_ar"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action2 ctrlSetTooltip format ["Build factory %1", _costString];

											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "factory_ar"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];
										};
									};

									_owr_action1 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
									_owr_action1 ctrlSetTooltip "Build warehouse";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									switch (_sideStr) do {
										case "am": {
											_owr_action1 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "warehouse_am"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];	
										};
										case "ru": {
											_owr_action1 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "warehouse_ru"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];	
										};
										case "ar": {
											_owr_action1 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "warehouse_ar"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];	
										};
									};
								};
								case 2: {
									// RESOURCES
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 1, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "\owr\ui\data\buildings\icon_psib_ca.paa";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									switch (_sideStr) do {
										case "am": {
											_resourceArray = ["power_sib_am"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action6 ctrlSetTooltip format ["Build siberite power plant %1", _costString];

											if (["siberite", 3, bis_curator_west] call owr_fn_isResearchComplete) then {
												_owr_action6 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "power_sib_am"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];	
											} else {
												_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
												_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											};
										};
										case "ru": {
											_resourceArray = ["power_sib_ru"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action6 ctrlSetTooltip format ["Build siberite power plant %1", _costString];

											if (["siberite", 3, bis_curator_east] call owr_fn_isResearchComplete) then {
												_owr_action6 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "power_sib_ru"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];	
											} else {
												_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
												_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											};
										};
										case "ar": {
											_resourceArray = ["power_sib_ar"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action6 ctrlSetTooltip format ["Build siberite power plant %1", _costString];

											if (["siberite", 3, bis_curator_arab] call owr_fn_isResearchComplete) then {
												_owr_action6 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "power_sib_ar"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];	
											} else {
												_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
												_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											};
										};
									};



									_owr_action5 ctrlSetText "\owr\ui\data\buildings\icon_poil_ca.paa";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									switch (_sideStr) do {
										case "am": {
											_resourceArray = ["power_oil_am"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action5 ctrlSetTooltip format ["Build diesel power plant %1", _costString];

											if (["basic", 3, bis_curator_west] call owr_fn_isResearchComplete) then {
												_owr_action5 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "power_oil_am"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];	
											} else {
												_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
												_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											};
										};
										case "ru": {
											_resourceArray = ["power_oil_ru"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action5 ctrlSetTooltip format ["Build diesel power plant %1", _costString];

											if (["basic", 3, bis_curator_east] call owr_fn_isResearchComplete) then {
												_owr_action5 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "power_oil_ru"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];	
											} else {
												_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
												_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											};
										};
										case "ar": {
											_resourceArray = ["power_oil_ar"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action5 ctrlSetTooltip format ["Build diesel power plant %1", _costString];
											
											if (["basic", 3, bis_curator_arab] call owr_fn_isResearchComplete) then {
												_owr_action5 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "power_oil_ar"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];	
											} else {
												_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
												_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											};
										};
									};

									switch (_sideStr) do {
										case "am": {
											_owr_action4 ctrlSetText "\owr\ui\data\buildings\icon_psol_ca.paa";
											_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

											_resourceArray = ["power_sol_am"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action4 ctrlSetTooltip format ["Build solar power plant %1", _costString];

											if (["basic", 6, bis_curator_west] call owr_fn_isResearchComplete) then {
												_owr_action4 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "power_sol_am"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action4 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
												_owr_action4 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											};
										};
										case "ru": {
											_owr_action4 ctrlSetText "";
											_owr_action4 ctrlSetTooltip "";
											_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
										};
										case "ar": {
											_owr_action4 ctrlSetText "\owr\ui\data\buildings\icon_psol_ca.paa";
											_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

											_resourceArray = ["power_sol_ar"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action4 ctrlSetTooltip format ["Build solar power plant %1", _costString];

											if (["basic", 6, bis_curator_arab] call owr_fn_isResearchComplete) then {
												_owr_action4 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "power_sol_ar"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action4 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
												_owr_action4 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											};
										};
									};


									_owr_action3 ctrlSetText "\owr\ui\data\buildings\icon_ssib_ca.paa";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									switch (_sideStr) do {
										case "am": {
											_resourceArray = ["source_sib_am"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action3 ctrlSetTooltip format ["Build siberite mine %1 (requires scientist to locate deposit)", _costString];

											if (["basic", 5, bis_curator_west] call owr_fn_isResearchComplete) then {
												_owr_action3 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "source_sib_am"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
												_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											};
										};
										case "ru": {
											_resourceArray = ["source_sib_ru"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action3 ctrlSetTooltip format ["Build alaskite mine %1 (requires scientist to locate deposit)", _costString];

											if (["basic", 5, bis_curator_east] call owr_fn_isResearchComplete) then {
												_owr_action3 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "source_sib_ru"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
												_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											};
										};
										case "ar": {
											_resourceArray = ["source_sib_ar"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action3 ctrlSetTooltip format ["Build siberite mine %1", _costString];

											if (["basic", 5, bis_curator_arab] call owr_fn_isResearchComplete) then {
												_owr_action3 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "source_sib_ar"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
												_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											};
										};
									};

									_owr_action2 ctrlSetText "\owr\ui\data\buildings\icon_soil_ca.paa";
									_owr_action2 ctrlSetTooltip "Build oil drill";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									switch (_sideStr) do {
										case "am": {
											_resourceArray = ["source_oil_am"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action2 ctrlSetTooltip format ["Build oil drill %1 (requires scientist to locate deposit)", _costString];

											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "source_oil_am"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];
										};
										case "ru": {
											_resourceArray = ["source_oil_ru"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action2 ctrlSetTooltip format ["Build oil drill %1 (requires scientist to locate deposit)", _costString];

											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "source_oil_ru"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];
										};
										case "ar": {
											_resourceArray = ["source_oil_ar"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action2 ctrlSetTooltip format ["Build oil drill %1 (requires scientist to locate deposit)", _costString];
											
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "source_oil_ar"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];
										};
									};

									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};
								case 3: {
									// DEFENSE
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 1, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "\owr\ui\data\buildings\icon_turret_auto_ca.paa";
									_owr_action3 ctrlSetTooltip "Build automatic weapon turrent";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									switch (_sideStr) do {
										case "am": {
											_resourceArray = ["aturret_am"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action3 ctrlSetTooltip format ["Build automatic weapon turrent %1", _costString];

											if (["comp", 3, bis_curator_west] call owr_fn_isResearchComplete) then {
												_owr_action3 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "aturret_am"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
												_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											};
										};
										case "ru": {
											_resourceArray = ["aturret_ru"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action3 ctrlSetTooltip format ["Build automatic weapon turrent %1", _costString];

											if (["comp", 3, bis_curator_east] call owr_fn_isResearchComplete) then {
												_owr_action3 ctrladdeventhandler ["buttonclick", {
													_unitToChange = (curatorSelected select 0) select 0;
													_unitToChange setVariable ["ow_worker_buildmode", 4, true];
													[_unitToChange, "aturret_ru"] spawn owr_fn_buildSomething;
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
												_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											};
										};
										case "ar": {
											_owr_action3 ctrlSetText "";
											_owr_action3 ctrlSetTooltip "";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										};
									};


									_owr_action2 ctrlSetText "\owr\ui\data\buildings\icon_turret_man_ca.paa";
									_owr_action2 ctrlSetTooltip "Build manned weapon turret";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									switch (_sideStr) do {
										case "am": {
											_resourceArray = ["mturret_am"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action2 ctrlSetTooltip format ["Build manned weapon turret %1", _costString];

											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "mturret_am"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];
										};
										case "ru": {
											_resourceArray = ["mturret_ru"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action2 ctrlSetTooltip format ["Build manned weapon turret %1", _costString];

											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "mturret_ru"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];
										};
										case "ar": {
											_resourceArray = ["mturret_ar"] call owr_fn_getBuildingCostStr;
											_costString = [_resourceArray] call owr_fn_getCostStr;

											_owr_action2 ctrlSetTooltip format ["Build manned weapon turret %1", _costString];
											
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_unitToChange = (curatorSelected select 0) select 0;
												_unitToChange setVariable ["ow_worker_buildmode", 4, true];
												[_unitToChange, "mturret_ar"] spawn owr_fn_buildSomething;
												playSound "owr_ui_button_confirm";
											}];
										};
									};

									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};
								case 4: {
									// BUILDING SELECTED
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 1, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "";
									_owr_action2 ctrlSetTooltip "";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};

								case 5: {
									// ATTACK BTN SELECTED
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "";
									_owr_action2 ctrlSetTooltip "";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};

								// MISC ASSETS MODE
								case 6: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_PortableLight_double_F.jpg";
									_owr_action7 ctrlSetTooltip "Electric devices and misc";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 12, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action6 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_TentDome_F.jpg";
									_owr_action6 ctrlSetTooltip "Camping assets";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action6 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 20, true];
										playSound "owr_ui_button_cancel";
									}];	


									_owr_action5 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_FieldToilet_F.jpg";
									_owr_action5 ctrlSetTooltip "Base support objects";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action5 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 17, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action4 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_WaterTank_F.jpg";
									_owr_action4 ctrlSetTooltip "Cisterns and barels";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 15, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action3 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_WoodenCrate_01_stack_x5_F.jpg";
									_owr_action3 ctrlSetTooltip "Crates";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 13, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_cargo_addon02_V1_F.jpg";
									_owr_action2 ctrlSetTooltip "Roofs and covers";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 7, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_HBarrier_01_big_tower_green_F.jpg";
									_owr_action1 ctrlSetTooltip "Fortification";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 9, true];
										playSound "owr_ui_button_cancel";
									}];	
								};

								// MISC - ROOFS AND COVERS #1
								case 7: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_move_ca.paa";
									_owr_action8 ctrlSetTooltip "Next";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 8, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action7 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_cargo_addon01_V1_F.jpg";
									_owr_action7 ctrlSetTooltip "Land_cargo_addon01_V1_F";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_cargo_addon01_V1_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action6 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_cargo_addon02_V1_F.jpg";
									_owr_action6 ctrlSetTooltip "Land_cargo_addon02_V1_F";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action6 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_cargo_addon02_V1_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action5 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_cargo_addon02_V2_F.jpg";
									_owr_action5 ctrlSetTooltip "Land_cargo_addon02_V2_F";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action5 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_cargo_addon02_V2_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action4 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\CamoNet_ghex_F.jpg";
									_owr_action4 ctrlSetTooltip "CamoNet_ghex_F";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "CamoNet_ghex_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action3 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\CamoNet_ghex_open_F.jpg";
									_owr_action3 ctrlSetTooltip "CamoNet_ghex_open_F";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "CamoNet_ghex_open_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\CamoNet_OPFOR_F.jpg";
									_owr_action2 ctrlSetTooltip "CamoNet_OPFOR_F";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "CamoNet_OPFOR_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\CamoNet_OPFOR_open_F.jpg";
									_owr_action1 ctrlSetTooltip "CamoNet_OPFOR_open_F";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "CamoNet_OPFOR_open_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	
								};
								// MISC - ROOFS AND COVERS #1
								case 8: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 7, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_WoodenShelter_01_F.jpg";
									_owr_action2 ctrlSetTooltip "Land_WoodenShelter_01_F";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_WoodenShelter_01_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_cargo_addon01_V2_F.jpg";
									_owr_action1 ctrlSetTooltip "Land_cargo_addon01_V2_F";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_cargo_addon01_V2_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	
								};

								// MISC - FORTIFICATION SELECTION
								case 9: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Mil_WiredFence_Gate_F.jpg";
									_owr_action8 ctrlSetTooltip "Land_Mil_WiredFence_Gate_F";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Mil_WiredFence_Gate_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action7 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Mil_WiredFence_F.jpg";
									_owr_action7 ctrlSetTooltip "Land_Mil_WiredFence_F";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Mil_WiredFence_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action6 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Razorwire_F.jpg";
									_owr_action6 ctrlSetTooltip "Land_Razorwire_F";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action6 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Razorwire_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action5 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_HBarrierTower_F.jpg";
									_owr_action5 ctrlSetTooltip "Land_HBarrierTower_F";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action5 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrierTower_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action4 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_HBarrier_01_big_tower_green_F.jpg";
									_owr_action4 ctrlSetTooltip "Land_HBarrier_01_big_tower_green_F";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrier_01_big_tower_green_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_HBarrierWall_corridor_F.jpg";
									_owr_action2 ctrlSetTooltip "Gray hbarriers";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 11, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_HBarrier_01_wall_corridor_green_F.jpg";
									_owr_action1 ctrlSetTooltip "Green hbarriers";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 10, true];
										playSound "owr_ui_button_cancel";
									}];	
								};
								// MISC - FORTIFICATION - GREEN HB
								case 10: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 9, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_HBarrier_01_wall_corridor_green_F.jpg";
									_owr_action8 ctrlSetTooltip "Land_HBarrier_01_wall_corridor_green_F";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrier_01_wall_corridor_green_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action7 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_HBarrier_01_wall_corner_green_F.jpg";
									_owr_action7 ctrlSetTooltip "Land_HBarrier_01_wall_corner_green_F";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrier_01_wall_corner_green_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action6 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_HBarrier_01_wall_6_green_F.jpg";
									_owr_action6 ctrlSetTooltip "Land_HBarrier_01_wall_6_green_F";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action6 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrier_01_wall_6_green_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action5 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_HBarrier_01_wall_4_green_F.jpg";
									_owr_action5 ctrlSetTooltip "Land_HBarrier_01_wall_4_green_F";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action5 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrier_01_wall_4_green_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action4 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_HBarrier_01_big_4_green_F.jpg";
									_owr_action4 ctrlSetTooltip "Land_HBarrier_01_big_4_green_F";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrier_01_big_4_green_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action3 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_HBarrier_01_line_5_green_F.jpg";
									_owr_action3 ctrlSetTooltip "Land_HBarrier_01_line_5_green_F";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrier_01_line_5_green_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_HBarrier_01_line_3_green_F.jpg";
									_owr_action2 ctrlSetTooltip "Land_HBarrier_01_line_3_green_F";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrier_01_line_3_green_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_HBarrier_01_line_1_green_F.jpg";
									_owr_action1 ctrlSetTooltip "Land_HBarrier_01_line_1_green_F";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrier_01_line_1_green_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	
								};
								// MISC - FORTIFICATION - GRAY HB
								case 11: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 9, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_HBarrierWall_corridor_F.jpg";
									_owr_action8 ctrlSetTooltip "Land_HBarrierWall_corridor_F";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrierWall_corridor_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action7 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_HBarrierWall_corner_F.jpg";
									_owr_action7 ctrlSetTooltip "Land_HBarrierWall_corner_F";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrierWall_corner_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action6 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_HBarrierWall6_F.jpg";
									_owr_action6 ctrlSetTooltip "Land_HBarrierWall6_F";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action6 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrierWall6_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action5 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_HBarrierWall4_F.jpg";
									_owr_action5 ctrlSetTooltip "Land_HBarrierWall4_F";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action5 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrierWall4_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action4 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_HBarrier_Big_F.jpg";
									_owr_action4 ctrlSetTooltip "Land_HBarrier_Big_F";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrier_Big_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action3 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_HBarrier_5_F.jpg";
									_owr_action3 ctrlSetTooltip "Land_HBarrier_5_F";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrier_5_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_HBarrier_3_F.jpg";
									_owr_action2 ctrlSetTooltip "Land_HBarrier_3_F";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrier_3_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_HBarrier_1_F.jpg";
									_owr_action1 ctrlSetTooltip "Land_HBarrier_1_F";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_HBarrier_1_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	
								};

								// MISC - ELECTRICITY
								case 12: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_PortableLight_double_F.jpg";
									_owr_action4 ctrlSetTooltip "Land_PortableLight_double_F";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_PortableLight_double_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action3 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_PortableLight_single_F.jpg";
									_owr_action3 ctrlSetTooltip "Land_PortableLight_single_F";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_PortableLight_single_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_TTowerSmall_2_F.jpg";
									_owr_action2 ctrlSetTooltip "Land_TTowerSmall_2_F";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_TTowerSmall_2_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_TTowerSmall_1_F.jpg";
									_owr_action1 ctrlSetTooltip "Land_TTowerSmall_1_F";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_TTowerSmall_1_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	
								};

								// MISC - CRATES #1
								case 13: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_move_ca.paa";
									_owr_action8 ctrlSetTooltip "Next";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 14, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action7 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_PaperBox_open_full_F.jpg";
									_owr_action7 ctrlSetTooltip "Land_PaperBox_open_full_F";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_PaperBox_open_full_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action6 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_PaperBox_open_empty_F.jpg";
									_owr_action6 ctrlSetTooltip "Land_PaperBox_open_empty_F";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action6 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_PaperBox_open_empty_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action5 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_PaperBox_closed_F.jpg";
									_owr_action5 ctrlSetTooltip "Land_PaperBox_closed_F";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action5 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_PaperBox_closed_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action4 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_CratesWooden_F.jpg";
									_owr_action4 ctrlSetTooltip "Land_CratesWooden_F";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_CratesWooden_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action3 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_WoodenCrate_01_stack_x5_F.jpg";
									_owr_action3 ctrlSetTooltip "Land_WoodenCrate_01_stack_x5_F";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_WoodenCrate_01_stack_x5_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_WoodenCrate_01_stack_x3_F.jpg";
									_owr_action2 ctrlSetTooltip "Land_WoodenCrate_01_stack_x3_F";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_WoodenCrate_01_stack_x3_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_WoodenCrate_01_F.jpg";
									_owr_action1 ctrlSetTooltip "Land_WoodenCrate_01_F";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_WoodenCrate_01_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	
								};
								// MISC - CRATES #2
								case 14: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_CratesShabby_F.jpg";
									_owr_action3 ctrlSetTooltip "Land_CratesShabby_F";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_CratesShabby_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_CratesPlastic_F.jpg";
									_owr_action2 ctrlSetTooltip "Land_CratesPlastic_F";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_CratesPlastic_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Pallet_MilBoxes_F.jpg";
									_owr_action1 ctrlSetTooltip "Land_Pallet_MilBoxes_F";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Pallet_MilBoxes_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	
								};

								// MISC - TANKS #1
								case 15: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_move_ca.paa";
									_owr_action8 ctrlSetTooltip "Next";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 16, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action7 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_BarrelWater_F.jpg";
									_owr_action7 ctrlSetTooltip "Land_BarrelWater_F";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_BarrelWater_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action6 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_BarrelSand_F.jpg";
									_owr_action6 ctrlSetTooltip "Land_BarrelSand_F";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action6 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_BarrelSand_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action5 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_BarrelEmpty_F.jpg";
									_owr_action5 ctrlSetTooltip "Land_BarrelEmpty_F";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action5 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_BarrelEmpty_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action4 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_MetalBarrel_F.jpg";
									_owr_action4 ctrlSetTooltip "Land_MetalBarrel_F";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_MetalBarrel_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action3 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_WaterTank_04_F.jpg";
									_owr_action3 ctrlSetTooltip "Land_WaterTank_04_F";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_WaterTank_04_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_WaterTank_03_F.jpg";
									_owr_action2 ctrlSetTooltip "Land_WaterTank_03_F";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_WaterTank_03_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_WaterTank_F.jpg";
									_owr_action1 ctrlSetTooltip "Land_WaterTank_F";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_WaterTank_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	
								};
								// MISC - TANKS #2
								case 16: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_BarrelWater_grey_F.jpg";
									_owr_action3 ctrlSetTooltip "Land_BarrelWater_grey_F";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_BarrelWater_grey_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_BarrelSand_grey_F.jpg";
									_owr_action2 ctrlSetTooltip "Land_BarrelSand_grey_F";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_BarrelSand_grey_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_BarrelEmpty_grey_F.jpg";
									_owr_action1 ctrlSetTooltip "Land_BarrelEmpty_grey_F";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_BarrelEmpty_grey_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	
								};

								// MISC - BASE #1
								case 17: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_move_ca.paa";
									_owr_action8 ctrlSetTooltip "Next";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 18, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action7 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Pallets_F.jpg";
									_owr_action7 ctrlSetTooltip "Land_Pallets_F";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Pallets_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action6 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Pallet_vertical_F.jpg";
									_owr_action6 ctrlSetTooltip "Land_Pallet_vertical_F";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action6 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Pallet_vertical_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action5 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Pallet_F.jpg";
									_owr_action5 ctrlSetTooltip "Land_Pallet_F";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action5 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Pallet_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action4 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_MapBoard_F.jpg";
									_owr_action4 ctrlSetTooltip "Land_MapBoard_F";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_MapBoard_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action3 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_PicnicTable_01_F.jpg";
									_owr_action3 ctrlSetTooltip "Land_PicnicTable_01_F";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_PicnicTable_01_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_FieldToilet_F.jpg";
									_owr_action2 ctrlSetTooltip "Land_FieldToilet_F";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_FieldToilet_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Sink_F.jpg";
									_owr_action1 ctrlSetTooltip "Land_Sink_F";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Sink_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	
								};
								// MISC - BASE #2
								case 18: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_move_ca.paa";
									_owr_action8 ctrlSetTooltip "Next";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 19, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action7 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_CampingChair_V2_F.jpg";
									_owr_action7 ctrlSetTooltip "Land_CampingChair_V2_F";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_CampingChair_V2_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action6 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_ShelvesWooden_khaki_F.jpg";
									_owr_action6 ctrlSetTooltip "Land_ShelvesWooden_khaki_F";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action6 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_ShelvesWooden_khaki_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action5 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Bench_F.jpg";
									_owr_action5 ctrlSetTooltip "Land_Bench_F";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action5 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Bench_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action4 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_WoodenCounter_01_F.jpg";
									_owr_action4 ctrlSetTooltip "Land_WoodenCounter_01_F";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_WoodenCounter_01_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action3 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_WorkStand_F.jpg";
									_owr_action3 ctrlSetTooltip "Land_WorkStand_F";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_WorkStand_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_Plank_01_8m_F.jpg";
									_owr_action2 ctrlSetTooltip "Land_Plank_01_8m_F";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Plank_01_8m_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F_exp\Data\CfgVehicles\Land_Plank_01_4m_F.jpg";
									_owr_action1 ctrlSetTooltip "Land_Plank_01_4m_F";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Plank_01_4m_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	
								};
								// MISC - BASE #3
								case 19: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_WoodenTable_small_F.jpg";
									_owr_action2 ctrlSetTooltip "Land_WoodenTable_small_F";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_WoodenTable_small_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_WoodenTable_large_F.jpg";
									_owr_action1 ctrlSetTooltip "Land_WoodenTable_large_F";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_WoodenTable_large_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	
								};

								// MISC - CAMPING #1
								case 20: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_move_ca.paa";
									_owr_action8 ctrlSetTooltip "Next";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 21, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action7 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Ground_sheet_folded_OPFOR_F.jpg";
									_owr_action7 ctrlSetTooltip "Land_Ground_sheet_folded_OPFOR_F";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Ground_sheet_folded_OPFOR_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action6 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Ground_sheet_OPFOR_F.jpg";
									_owr_action6 ctrlSetTooltip "Land_Ground_sheet_OPFOR_F";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action6 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Ground_sheet_OPFOR_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action5 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Ground_sheet_folded_khaki_F.jpg";
									_owr_action5 ctrlSetTooltip "Land_Ground_sheet_folded_khaki_F";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action5 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Ground_sheet_folded_khaki_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action4 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Ground_sheet_khaki_F.jpg";
									_owr_action4 ctrlSetTooltip "Land_Ground_sheet_khaki_F";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Ground_sheet_khaki_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action3 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_CampingChair_V1_F.jpg";
									_owr_action3 ctrlSetTooltip "Land_CampingChair_V1_F";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_CampingChair_V1_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_CampingTable_F.jpg";
									_owr_action2 ctrlSetTooltip "Land_CampingTable_F";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_CampingTable_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_TentDome_F.jpg";
									_owr_action1 ctrlSetTooltip "Land_TentDome_F";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_TentDome_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	
								};
								// MISC - CAMPING #2
								case 21: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_move_ca.paa";
									_owr_action8 ctrlSetTooltip "Next";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 22, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action7 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_WoodenLog_F.jpg";
									_owr_action7 ctrlSetTooltip "Land_WoodenLog_F";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_WoodenLog_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action6 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Campfire_F.jpg";
									_owr_action6 ctrlSetTooltip "Land_Campfire_F";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action6 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Campfire_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action5 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Camping_Light_F.jpg";
									_owr_action5 ctrlSetTooltip "Land_Camping_Light_F";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action5 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Camping_Light_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action4 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Sleeping_bag_brown_folded_F.jpg";
									_owr_action4 ctrlSetTooltip "Land_Sleeping_bag_brown_folded_F";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Sleeping_bag_brown_folded_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action3 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Sleeping_bag_brown_F.jpg";
									_owr_action3 ctrlSetTooltip "Land_Sleeping_bag_brown_F";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Sleeping_bag_brown_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Sleeping_bag_folded_F.jpg";
									_owr_action2 ctrlSetTooltip "Land_Sleeping_bag_folded_F";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Sleeping_bag_folded_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_Sleeping_bag_F.jpg";
									_owr_action1 ctrlSetTooltip "Land_Sleeping_bag_F";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_Sleeping_bag_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	
								};
								// MISC - CAMPING #1
								case 22: {
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_WoodPile_large_F.jpg";
									_owr_action2 ctrlSetTooltip "Land_WoodPile_large_F";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_WoodPile_large_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\A3\EditorPreviews_F\Data\CfgVehicles\Land_WoodPile_F.jpg";
									_owr_action1 ctrlSetTooltip "Land_WoodPile_F";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_worker_buildmode", 4, true];
										[_unitToChange, "Land_WoodPile_F"] spawn owr_fn_buildSomething;
										playSound "owr_ui_button_confirm";
									}];	
								};
							};
						};
						case 2: {

							/*
							// MECHANIC
							// default actions:
							// a1 = move
							// a2 = attack
							// a3 = station/active
							// a4 = build
							// a5 = repair
							// a6 = pickup
							// a7 = recycle
							// a8 = -
							// a9 = cancel / stop 
							*/

							{
								_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
								_x ctrlSetActiveColor [1, 1, 1, 1];
							} forEach _actionButtons;

							if ((vehicle _owman) != _owman) then {
								_owr_action9 ctrlSetText "";
								_owr_action9 ctrlSetTooltip "";
								_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action8 ctrlSetText "";
								_owr_action8 ctrlSetTooltip "";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action7 ctrlSetText "";
								_owr_action7 ctrlSetTooltip "";
								_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action6 ctrlSetText "";
								_owr_action6 ctrlSetTooltip "e";
								_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action5 ctrlSetText "";
								_owr_action5 ctrlSetTooltip "";
								_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action4 ctrlSetText "";
								_owr_action4 ctrlSetTooltip "";
								_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

								if (((vehicle _owman) isKindOf "lab_am") || ((vehicle _owman) isKindOf "lab_ru") || ((vehicle _owman) isKindOf "lab_ar")) then {
									_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makescientist_ca.paa";
									_owr_action3 ctrlSetTooltip "Change class to scientist";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_owman = (curatorSelected select 0) select 0;
										_owman setVariable ["ow_class", 3, true];
										//[_owman, 3] call owr_fn_changeClassGear;
										[_owman, 3] remoteExec ["owr_fn_changeClassGear", owner _owman];
										playSound "owr_ui_button_confirm";
									}];
								} else {
									if (((vehicle _owman) isKindOf "barracks_am") || ((vehicle _owman) isKindOf "barracks_ru") || ((vehicle _owman) isKindOf "barracks_ar")) then {
										_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makesoldier_ca.paa";
										_owr_action3 ctrlSetTooltip "Change class to soldier";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_owman = (curatorSelected select 0) select 0;
											_owman setVariable ["ow_class", 0, true];
											//[_owman, 0] call owr_fn_changeClassGear;
											[_owman, 0] remoteExec ["owr_fn_changeClassGear", owner _owman];
											playSound "owr_ui_button_confirm";
										}];
									} else {
										if (((vehicle _owman) isKindOf "warehouse_am") || ((vehicle _owman) isKindOf "warehouse_ru") || ((vehicle _owman) isKindOf "warehouse_ar")) then {
											_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makeworker_ca.paa";
											_owr_action3 ctrlSetTooltip "Change class to worker";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_owman = (curatorSelected select 0) select 0;
												_owman setVariable ["ow_class", 1, true];
												//[_owman, 1] call owr_fn_changeClassGear;
												[_owman, 1] remoteExec ["owr_fn_changeClassGear", owner _owman];
												playSound "owr_ui_button_confirm";
											}];
										} else {
											_owr_action3 ctrlSetText "";
											_owr_action3 ctrlSetTooltip "";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										};
									};
								};

								_owr_action2 ctrlSetText "";
								_owr_action2 ctrlSetTooltip "";
								_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
								_owr_action1 ctrlSetTooltip "Get out (G)";
								_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action1 ctrladdeventhandler ["buttonclick", {
									_unitToEject = (curatorSelected select 0) select 0;
									[_unitToEject] call owr_fn_getOutOfVehicle;
									playSound "owr_ui_button_confirm";
								}];	
							} else {
								_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
								_owr_action9 ctrlSetTooltip "Cancel / Stop";
								_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action9 ctrladdeventhandler ["buttonclick", {
									_unitToStop = (curatorSelected select 0) select 0;
									[_unitToStop] call owr_fn_stopUnit;
									playSound "owr_ui_button_cancel";
								}];	

								_owr_action8 ctrlSetText "";
								_owr_action8 ctrlSetTooltip "";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action7 ctrlSetText "\A3\ui_f_curator\Data\Logos\arma3_curator_logo_ca.paa";
								_owr_action7 ctrlSetTooltip "Take control";
								_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action7 ctrladdeventhandler ["buttonclick", {
									_unitToTakeControl = (curatorSelected select 0) select 0;
									[_unitToTakeControl] spawn owr_fn_remoteControl;
									playSound "owr_ui_button_confirm";
								}];

								_owr_action6 ctrlSetText "";
								_owr_action6 ctrlSetTooltip "";
								_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action5 ctrlSetText "";
								_owr_action5 ctrlSetTooltip "";
								_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

								if ((_owman getVariable "ow_aitype") == 1) then {
									_nearestVehiclesToRepair =  nearestObjects [getPos _owman, ["owr_car"], 10];
									if ((count _nearestVehiclesToRepair) > 0) then {
										if (((damage (_nearestVehiclesToRepair select 0)) > 0.05) && ((damage (_nearestVehiclesToRepair select 0)) < 1.0)) then {
											_owr_action4 ctrlSetText "\owr\ui\data\actions\icon_action_vrepair_ca.paa";
											_owr_action4 ctrlSetTooltip format["Repair in progress ( %1 )", (_nearestVehiclesToRepair select 0)];
											_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action4 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
											_owr_action4 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
										} else {
											_owr_action4 ctrlSetText "\owr\ui\data\actions\icon_action_vrepair_ca.paa";
											_owr_action4 ctrlSetTooltip "No vehicles to repair in vicinity";
											_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action4 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action4 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										};
									} else {
										_owr_action4 ctrlSetText "\owr\ui\data\actions\icon_action_vrepair_ca.paa";
										_owr_action4 ctrlSetTooltip "No vehicles to repair in vicinity";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action4 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action4 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
									};
								} else {
									_owr_action4 ctrlSetText "\owr\ui\data\actions\icon_action_vrepair_ca.paa";
									_owr_action4 ctrlSetTooltip "Active mode is OFF ( no repairs )";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
									_owr_action4 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
								};

								if ((_owman getVariable "ow_aitype") == 0) then {
									_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_standstill_ca.paa";
									_owr_action3 ctrlSetTooltip "Stationary mode";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_aitype", 1, true];
										playSound "owr_ui_button_confirm";
									}];
								} else {
									_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_free_ca.paa";
									_owr_action3 ctrlSetTooltip "Active mode";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_aitype", 0, true];
										[_unitToChange] call owr_fn_stopUnit;
										playSound "owr_ui_button_confirm";
									}];
								};

								_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_attack_ca.paa";
								_owr_action2 ctrlSetTooltip "Attack";
								_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action2 ctrladdeventhandler ["buttonclick", {
									_unitToChange = (curatorSelected select 0) select 0;
									playSound "owr_ui_button_confirm";
									[_unitToChange] spawn owr_fn_attackSomething;
								}];

								_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_move_ca.paa";
								_owr_action1 ctrlSetTooltip format ["Change behaviour to %1", [(curatorSelected select 0) select 0] call owr_fn_unitGetNextBehaviour];
								_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action1 ctrladdeventhandler ["buttonclick", {
									_unitToChange = (curatorSelected select 0) select 0;
									[_unitToChange, [_unitToChange] call owr_fn_unitGetNextBehaviour] remoteExec ["setBehaviour", owner _unitToChange];
									playSound "owr_ui_button_confirm";
								}];
							};
						};
						case 3: {
							{
								_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
								_x ctrlSetActiveColor [1, 1, 1, 1];
							} forEach _actionButtons;

							if ((vehicle _owman) != _owman) then {
								_owr_action9 ctrlSetText "";
								_owr_action9 ctrlSetTooltip "";
								_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action8 ctrlSetText "";
								_owr_action8 ctrlSetTooltip "";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action7 ctrlSetText "";
								_owr_action7 ctrlSetTooltip "";
								_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action6 ctrlSetText "";
								_owr_action6 ctrlSetTooltip "e";
								_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action5 ctrlSetText "";
								_owr_action5 ctrlSetTooltip "";
								_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action4 ctrlSetText "";
								_owr_action4 ctrlSetTooltip "";
								_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

								if (((vehicle _owman) isKindOf "factory_am") || ((vehicle _owman) isKindOf "factory_ru") || ((vehicle _owman) isKindOf "factory_ar")) then {
									_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makemechanic_ca.paa";
									_owr_action3 ctrlSetTooltip "Change class to mechanic";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_owman = (curatorSelected select 0) select 0;
										_owman setVariable ["ow_class", 2, true];
										//[_owman, 2] call owr_fn_changeClassGear;
										[_owman, 2] remoteExec ["owr_fn_changeClassGear", owner _owman];
										playSound "owr_ui_button_confirm";
									}];
								} else {
									if (((vehicle _owman) isKindOf "barracks_am") || ((vehicle _owman) isKindOf "barracks_ru") || ((vehicle _owman) isKindOf "barracks_ar")) then {
										_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makesoldier_ca.paa";
										_owr_action3 ctrlSetTooltip "Change class to soldier";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_owman = (curatorSelected select 0) select 0;
											_owman setVariable ["ow_class", 0, true];
											//[_owman, 0] call owr_fn_changeClassGear;
											[_owman, 0] remoteExec ["owr_fn_changeClassGear", owner _owman];
											playSound "owr_ui_button_confirm";
										}];
									} else {
										if (((vehicle _owman) isKindOf "warehouse_am") || ((vehicle _owman) isKindOf "warehouse_ru") || ((vehicle _owman) isKindOf "warehouse_ar")) then {
											_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makeworker_ca.paa";
											_owr_action3 ctrlSetTooltip "Change class to worker";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_owman = (curatorSelected select 0) select 0;
												_owman setVariable ["ow_class", 1, true];
												//[_owman, 1] call owr_fn_changeClassGear;
												[_owman, 1] remoteExec ["owr_fn_changeClassGear", owner _owman];
												playSound "owr_ui_button_confirm";
											}];
										} else {
											_owr_action3 ctrlSetText "";
											_owr_action3 ctrlSetTooltip "";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										};
									};
								};

								_owr_action2 ctrlSetText "";
								_owr_action2 ctrlSetTooltip "";
								_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
								_owr_action1 ctrlSetTooltip "Get out (G)";
								_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action1 ctrladdeventhandler ["buttonclick", {
									_unitToEject = (curatorSelected select 0) select 0;
									[_unitToEject] call owr_fn_getOutOfVehicle;
									playSound "owr_ui_button_confirm";
								}];	
							} else {
								_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
								_owr_action9 ctrlSetTooltip "Cancel / Stop";
								_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action9 ctrladdeventhandler ["buttonclick", {
									_unitToStop = (curatorSelected select 0) select 0;
									[_unitToStop] call owr_fn_stopUnit;
									playSound "owr_ui_button_cancel";
								}];	

								_owr_action8 ctrlSetText "";
								_owr_action8 ctrlSetTooltip "";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action7 ctrlSetText "\A3\ui_f_curator\Data\Logos\arma3_curator_logo_ca.paa";
								_owr_action7 ctrlSetTooltip "Take control";
								_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action7 ctrladdeventhandler ["buttonclick", {
									_unitToTakeControl = (curatorSelected select 0) select 0;
									[_unitToTakeControl] spawn owr_fn_remoteControl;
									playSound "owr_ui_button_confirm";
								}];

								_owr_action6 ctrlSetText "\owr\ui\data\research\icon_res_comp_t3_ca";
								_owr_action6 ctrlSetTooltip "Detect slow frame (can reveal interrrrresting information, only in arma3diag.exe)";
								_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action6 ctrladdeventhandler ["buttonclick", {
									//diag_captureSlowFrame ['total', 0.3];
									playSound "owr_ui_button_confirm";
								}];

								_owr_action5 ctrlSetText "\owr\ui\data\research\icon_res_comp_t2_ca";
								_owr_action5 ctrlSetTooltip "Profile 24 frames (can reveal interrrrresting information, only in arma3diag.exe)";
								_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action5 ctrladdeventhandler ["buttonclick", {
									//diag_captureFrame 24;
									playSound "owr_ui_button_confirm";
								}];

								_owr_action4 ctrlSetText "\owr\ui\data\research\icon_res_comp_t1_ca";
								_owr_action4 ctrlSetTooltip "Profile one frame (can reveal interrrrresting information, only in arma3diag.exe)";
								_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action4 ctrladdeventhandler ["buttonclick", {
									//diag_captureFrame 1;
									playSound "owr_ui_button_confirm";
								}];

								/*
								_owr_action4 ctrlSetText "\owr\ui\data\actions\icon_action_heal_ca.paa";
								_owr_action4 ctrlSetTooltip "Heal unit";
								_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action4 ctrladdeventhandler ["buttonclick", {
									_unitToChange = (curatorSelected select 0) select 0;
									// TODO
									playSound "owr_ui_button_confirm";
								}];
								*/

								if ((_owman getVariable "ow_aitype") == 0) then {
									_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_standstill_ca.paa";
									_owr_action3 ctrlSetTooltip "Stationary mode";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_aitype", 1, true];
										playSound "owr_ui_button_confirm";
									}];
								} else {
									_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_free_ca.paa";
									_owr_action3 ctrlSetTooltip "Active mode";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToChange = (curatorSelected select 0) select 0;
										_unitToChange setVariable ["ow_aitype", 0, true];
										[_unitToChange] call owr_fn_stopUnit;
										playSound "owr_ui_button_confirm";
									}];
								};

								_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_attack_ca.paa";
								_owr_action2 ctrlSetTooltip "Attack";
								_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action2 ctrladdeventhandler ["buttonclick", {
									_unitToChange = (curatorSelected select 0) select 0;
									playSound "owr_ui_button_confirm";
									[_unitToChange] spawn owr_fn_attackSomething;
								}];

								_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_move_ca.paa";
								_owr_action1 ctrlSetTooltip format ["Change behaviour to %1", [(curatorSelected select 0) select 0] call owr_fn_unitGetNextBehaviour];
								_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action1 ctrladdeventhandler ["buttonclick", {
									_unitToChange = (curatorSelected select 0) select 0;
									[_unitToChange, [_unitToChange] call owr_fn_unitGetNextBehaviour] remoteExec ["setBehaviour", owner _unitToChange];
									playSound "owr_ui_button_confirm";
								}];
							};
						};
						default {};
					};
				};
				case 2: {
					// complex ow building selected
					// AM - LAB
					if ((_selected select 0) isKindOf "lab_am") then {
						_labka = (_selected select 0);
						{
							_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
							_x ctrlSetActiveColor [1, 1, 1, 1];
						} forEach _actionButtons;

						if (_labka getVariable "ow_build_ready") then {
							// 4 - basic, 5 - left, 6 - right
							switch (_labka getVariable "ow_lab_buildmode") do {
								case 0: {

									if (count (crew _labka) > 0) then {
										_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
										_owr_action1 ctrlSetTooltip "Order all to exit building (G)";
										_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_labkaToUse = (curatorSelected select 0) select 0;
											{
												[_x] call owr_fn_getOutOfVehicle;
											} forEach (crew _labkaToUse);
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action1 ctrlSetText "";
										_owr_action1 ctrlSetTooltip "";
										_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									};

									_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
									_owr_action2 ctrlSetTooltip "Deconstruct building";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_labToUse = (curatorSelected select 0) select 0;
										_labToUse setVariable ["ow_build_deconstruct", true, true];
										_labToUse setVariable ["ow_build_ready", false, true];
										playSound "owr_ui_button_confirm";
									}];

									// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
									_someoneNotAScientist = false;
									{
										if (_x getVariable "ow_class" != 3) then {
											_someoneNotAScientist = true;
										};
									} forEach (crew _labka);

									if (_someoneNotAScientist) then {
										_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makescientist_ca.paa";
										_owr_action3 ctrlSetTooltip "Change class to scientist";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_labToChange = (curatorSelected select 0) select 0;
											{
												_x setVariable ["ow_class", 3, true];
												//[_x, 3] call owr_fn_changeClassGear;
												[_x, 3] remoteExec ["owr_fn_changeClassGear", owner _owman];
											} forEach (crew _labToChange);
											playSound "owr_ui_button_confirm";
										}];
									} else {
										_owr_action3 ctrlSetText "";
										_owr_action3 ctrlSetTooltip "";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									};

									_owr_action9 ctrlSetText "";
									_owr_action9 ctrlSetTooltip "";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

									if (isNull (_labka getVariable "ow_build_wrhs")) then {
										_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
										_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_objectToSearchAround = (curatorSelected select 0) select 0;
											_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_am"], 150];
											if ((count _warehousesAvailable) > 0) then {
												_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
											};
										}];
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
										_owr_action8 ctrlSetTooltip "Warehouse connected";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									};

									_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
									_owr_action7 ctrlSetTooltip "Lights On/Off";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_labToUse = (curatorSelected select 0) select 0;
										_lightState = _labToUse getVariable "ow_build_light";
										if (_lightState) then {
											_labToUse setVariable ["ow_build_light", false, true];
										} else {
											_labToUse setVariable ["ow_build_light", true, true];
										};
										playSound "owr_ui_button_confirm";
									}];

									if (!(isNull (_labka getVariable "ow_build_wrhs"))) then {
										_owr_action4 ctrlSetText "\owr\ui\data\research\icon_rescat_basic_ca.paa";
										_owr_action4 ctrlSetTooltip "Basic research";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action4 ctrladdeventhandler ["buttonclick", {
											_labToUse = (curatorSelected select 0) select 0;
											_labToUse setVariable ["ow_lab_buildmode", 3, true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action4 ctrlSetText "\owr\ui\data\research\icon_rescat_basic_ca.paa";
										_owr_action4 ctrlSetTooltip "Basic research ( connect warehouse )";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									};

									if (!(isNull (_labka getVariable "ow_build_wrhs"))) then {
										if ((_labka getVariable "ow_lab_left") == "") then {
											_owr_action5 ctrlSetText "\owr\ui\data\research\icon_labupgrade_left_ca.paa";
											_owr_action5 ctrlSetTooltip "Upgrade left";
											_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action5 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 1, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											switch (_labka getVariable "ow_lab_left") do {
												case "comp": {
													_owr_action5 ctrlSetText "\owr\ui\data\research\icon_rescat_comp_ca.paa";
													_owr_action5 ctrlSetTooltip "Computer research";
													_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
													_owr_action5 ctrladdeventhandler ["buttonclick", {
														_labToUpgrade = (curatorSelected select 0) select 0;
														_labToUpgrade setVariable ["ow_lab_buildmode", 4, true];
														playSound "owr_ui_button_confirm";
													}];	
												};
												case "siberite": {
													_owr_action5 ctrlSetText "\owr\ui\data\research\icon_rescat_siberite_ca.paa";
													_owr_action5 ctrlSetTooltip "Siberite research";
													_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
													_owr_action5 ctrladdeventhandler ["buttonclick", {
														_labToUpgrade = (curatorSelected select 0) select 0;
														_labToUpgrade setVariable ["ow_lab_buildmode", 6, true];
														playSound "owr_ui_button_confirm";
													}];	
												};
											};
										};
									} else {
										_owr_action5 ctrlSetText "\owr\ui\data\research\icon_labupgrade_left_ca.paa";
										_owr_action5 ctrlSetTooltip "Upgrade left ( connect warehouse )";
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									};

									if (!(isNull (_labka getVariable "ow_build_wrhs"))) then {
										if ((_labka getVariable "ow_lab_right") == "") then {
											_owr_action6 ctrlSetText "\owr\ui\data\research\icon_labupgrade_right_ca.paa";
											_owr_action6 ctrlSetTooltip "Upgrade right";
											_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action6 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											switch (_labka getVariable "ow_lab_right") do {
												case "weap": {
													_owr_action6 ctrlSetText "\owr\ui\data\research\icon_rescat_weap_ca.paa";
													_owr_action6 ctrlSetTooltip "Weapon research";
													_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
													_owr_action6 ctrladdeventhandler ["buttonclick", {
														_labToUpgrade = (curatorSelected select 0) select 0;
														_labToUpgrade setVariable ["ow_lab_buildmode", 7, true];
														playSound "owr_ui_button_confirm";
													}];	
												};
												case "opto": {
													_owr_action6 ctrlSetText "\owr\ui\data\research\icon_rescat_opto_ca.paa";
													_owr_action6 ctrlSetTooltip "Opto-electronics research";
													_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
													_owr_action6 ctrladdeventhandler ["buttonclick", {
														_labToUpgrade = (curatorSelected select 0) select 0;
														_labToUpgrade setVariable ["ow_lab_buildmode", 5, true];
														playSound "owr_ui_button_confirm";
													}];	
												};
											};
										};
									} else {
										_owr_action6 ctrlSetText "\owr\ui\data\research\icon_labupgrade_left_ca.paa";
										_owr_action6 ctrlSetTooltip "Upgrade right ( connect warehouse )";
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									};
								};

								case 1: {
									// upgrade left
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
									_owr_action7 ctrlSetTooltip "Lights On/Off";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_labToUse = (curatorSelected select 0) select 0;
										_lightState = _labToUse getVariable "ow_build_light";
										if (_lightState) then {
											_labToUse setVariable ["ow_build_light", false, true];
										} else {
											_labToUse setVariable ["ow_build_light", true, true];
										};
										playSound "owr_ui_button_confirm";
									}];

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_rescat_siberite_ca.paa";
									_resourceArray = ["lab_siberite"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action3 ctrlSetTooltip format["Siberite lab upgrade %1", _costString];
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										// get the resources needed
										_resourceArray = ["lab_siberite"] call owr_fn_getUpgradeCostStr;
										if ([_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
											// we have enough resource in warehouse, take them out
											[_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
											// let the upgrade begin
											_labToUpgrade setVariable ["ow_lab_left", "siberite", true];
											playSound "owr_ui_button_confirm";
										} else {
											playSound "owr_ui_button_cancel";
										};
									}];	

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_rescat_comp_ca.paa";
									_resourceArray = ["lab_comp"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action2 ctrlSetTooltip format["Computer lab upgrade %1", _costString];
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										// get the resources needed
										_resourceArray = ["lab_comp"] call owr_fn_getUpgradeCostStr;
										if ([_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
											// we have enough resource in warehouse, take them out
											[_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
											// let the upgrade begin
											_labToUpgrade setVariable ["ow_lab_left", "comp", true];
											playSound "owr_ui_button_confirm";
										} else {
											playSound "owr_ui_button_cancel";
										};
									}];	

									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};

								case 2: {
									// upgrade left
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
									_owr_action7 ctrlSetTooltip "Lights On/Off";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_labToUse = (curatorSelected select 0) select 0;
										_lightState = _labToUse getVariable "ow_build_light";
										if (_lightState) then {
											_labToUse setVariable ["ow_build_light", false, true];
										} else {
											_labToUse setVariable ["ow_build_light", true, true];
										};
										playSound "owr_ui_button_confirm";
									}];

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";



									_owr_action4 ctrlSetText "\owr\ui\data\research\icon_rescat_opto_ca.paa";
									_resourceArray = ["lab_opto"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action4 ctrlSetTooltip format["Opto-electronics lab upgrade %1", _costString];
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										// get the resources needed
										_resourceArray = ["lab_opto"] call owr_fn_getUpgradeCostStr;
										if ([_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
											// we have enough resource in warehouse, take them out
											[_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
											// let the upgrade begin
											_labToUpgrade setVariable ["ow_lab_right", "opto", true];
											playSound "owr_ui_button_confirm";
										} else {
											playSound "owr_ui_button_cancel";
										};
									}];


									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "";
									_owr_action2 ctrlSetTooltip "";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_rescat_weap_ca.paa";
									_resourceArray = ["lab_weap"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action1 ctrlSetTooltip format["Weapon lab upgrade %1", _costString];
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										// get the resources needed
										_resourceArray = ["lab_weap"] call owr_fn_getUpgradeCostStr;
										if ([_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
											// we have enough resource in warehouse, take them out
											[_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
											// let the upgrade begin
											_labToUpgrade setVariable ["ow_lab_right", "weap", true];
											playSound "owr_ui_button_confirm";
										} else {
											playSound "owr_ui_button_cancel";
										};
									}];	
								};

								case 3: {
									// BASIC RESEARCH
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	


									if (["basic", 0, bis_curator_west] call owr_fn_isResearchComplete) then {
										if (!(["basic", 1, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_basic_t2_ca.paa";
											_owr_action8 ctrlSetTooltip "Research basic tech tier II upgrade";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 1, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											if (!(["basic", 2, bis_curator_west] call owr_fn_isResearchComplete)) then {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_basic_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research basic tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
												_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
												_owr_action8 ctrladdeventhandler ["buttonclick", {
													_labToUpgrade = (curatorSelected select 0) select 0;
													_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
													_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
													_labToUpgrade setVariable ["ow_curr_res_index", 2, true];
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_basic_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research basic tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
												_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
											};
										};
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_basic_t1_ca.paa";
										_owr_action8 ctrlSetTooltip "Research basic tech tier I upgrade";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 0, true];
											playSound "owr_ui_button_confirm";
										}];	
									};

									_owr_action7 ctrlSetText "\owr\ui\data\research\icon_res_sib_detect_ca.paa";
									_owr_action7 ctrlSetTooltip "Research a way to detect siberite deposits";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 5, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action7 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 
										_owr_action7 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									} else {
										_owr_action7 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action7 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action7 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 5, true];
											playSound "owr_ui_button_confirm";
										}];	
									};

									_owr_action6 ctrlSetText "\owr\ui\data\research\icon_res_opo_help_ca.paa";
									_owr_action6 ctrlSetTooltip "Research a way to learn apes to be a worker";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									if (["basic", 9, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action6 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action6 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									} else {
										if (false) then {	//["basic", 9, bis_curator_west] call owr_fn_isAllowedToResearch
											_owr_action6 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action6 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action6 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 9, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action6 ctrlSetTooltip "Research a way to learn apes to be a worker ( not yet implemented )";
										};
									};

									_owr_action5 ctrlSetText "\owr\ui\data\research\icon_res_msol_ca.paa";
									_owr_action5 ctrlSetTooltip "Research battery powered motor";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 7, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action5 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action5 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									} else {
										if (["basic", 7, bis_curator_west] call owr_fn_isAllowedToResearch) then {
											_owr_action5 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action5 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action5 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 7, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										};
									};

									_owr_action4 ctrlSetText "\owr\ui\data\research\icon_res_psol_ca.paa";
									_owr_action4 ctrlSetTooltip "Research solar power plant";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 6, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action4 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action4 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									} else {
										_owr_action4 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action4 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action4 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 6, true];
											playSound "owr_ui_button_confirm";
										}];	
									};


									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_opo_psych_ca.paa";
									_owr_action3 ctrlSetTooltip "Research a way to understand apes";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 8, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action3 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action3 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (false) then {
											_owr_action3 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action3 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 8, true];
												playSound "owr_ui_button_confirm";
											}];
										} else {
											_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action3 ctrlSetTooltip "Research a way to understand apes ( not yet implemented )";
										};
									};

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_moil_ca.paa";
									_owr_action2 ctrlSetTooltip "Research combustion engine";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 4, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action2 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action2 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (["basic", 4, bis_curator_west] call owr_fn_isAllowedToResearch) then {
											_owr_action2 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action2 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 4, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
										};
									};

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_poil_ca.paa";
									_owr_action1 ctrlSetTooltip "Research diesel power plant";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 3, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action1 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action1 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										_owr_action1 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action1 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 3, true];
											playSound "owr_ui_button_confirm";
										}];	
									};
								};


								case 4: {
									// COMP RESEARCH
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	


									if (["comp", 0, bis_curator_west] call owr_fn_isResearchComplete) then {
										if (!(["comp", 1, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_comp_t2_ca.paa";
											_owr_action8 ctrlSetTooltip "Research computer tech tier II upgrade";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "comp", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 1, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											if (!(["comp", 2, bis_curator_west] call owr_fn_isResearchComplete)) then {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_comp_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research computer tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
												_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
												_owr_action8 ctrladdeventhandler ["buttonclick", {
													_labToUpgrade = (curatorSelected select 0) select 0;
													_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
													_labToUpgrade setVariable ["ow_curr_res_cat", "comp", true];
													_labToUpgrade setVariable ["ow_curr_res_index", 2, true];
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_comp_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research computer tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
												_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
											};
										};
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_comp_t1_ca.paa";
										_owr_action8 ctrlSetTooltip "Research computer tech tier I upgrade";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "comp", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 0, true];
											playSound "owr_ui_button_confirm";
										}];	
									};

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_morhp_ca.paa";
									_owr_action3 ctrlSetTooltip "Research adaptive chassis";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (["comp", 5, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action3 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action3 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (false) then {	// ["comp", 5, bis_curator_west] call owr_fn_isAllowedToResearch
											_owr_action3 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action3 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "comp", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 5, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action3 ctrlSetTooltip "Research adaptive chassis ( not yet implemented )";
										};
									};

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_adv_ai_ca.paa";
									_owr_action2 ctrlSetTooltip "Research advanced AI";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["comp", 4, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action2 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action2 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (["comp", 4, bis_curator_west] call owr_fn_isAllowedToResearch) then {
											_owr_action2 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action2 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "comp", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 4, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
										};
									};

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_ai_ca.paa";
									_owr_action1 ctrlSetTooltip "Research AI";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (["comp", 3, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action1 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action1 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										_owr_action1 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action1 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "comp", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 3, true];
											playSound "owr_ui_button_confirm";
										}];	
									};
								};

								case 5: {
									// OPTO RESEARCH
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									if (["opto", 0, bis_curator_west] call owr_fn_isResearchComplete) then {
										if (!(["opto", 1, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_opto_t2_ca.paa";
											_owr_action8 ctrlSetTooltip "Research opto-electronics tech tier II upgrade";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "opto", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 1, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											if (!(["opto", 2, bis_curator_west] call owr_fn_isResearchComplete)) then {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_opto_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research opto-electronics tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
												_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
												_owr_action8 ctrladdeventhandler ["buttonclick", {
													_labToUpgrade = (curatorSelected select 0) select 0;
													_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
													_labToUpgrade setVariable ["ow_curr_res_cat", "opto", true];
													_labToUpgrade setVariable ["ow_curr_res_index", 2, true];
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_opto_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research opto-electronics tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
												_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
											};
										};
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_opto_t1_ca.paa";
										_owr_action8 ctrlSetTooltip "Research opto-electronics tech tier I upgrade";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "opto", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 0, true];
											playSound "owr_ui_button_confirm";
										}];	
									};

									_owr_action7 ctrlSetText "\owr\ui\data\research\icon_res_part_invis_ca.paa";
									_owr_action7 ctrlSetTooltip "Research partial invisibility";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									if (["opto", 6, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action7 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action7 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (false) then {	// ["opto", 6, bis_curator_west] call owr_fn_isAllowedToResearch
											_owr_action7 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action7 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action7 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "opto", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 6, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action7 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action7 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action7 ctrlSetTooltip "Research partial invisibility ( not yet implemented )";
										};
									};

									_owr_action6 ctrlSetText "\owr\ui\data\research\icon_res_dlaser_ca.paa";
									_owr_action6 ctrlSetTooltip "Research synchronized laser weapon system";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									if (["opto", 8, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action6 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action6 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (false) then {	// ["opto", 8] call owr_fn_isAllowedToResearch
											_owr_action6 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action6 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action6 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "opto", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 8, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action6 ctrlSetTooltip "Research synchronized laser weapon system ( not yet implemented )";
										};
									};

									_owr_action5 ctrlSetText "\owr\ui\data\research\icon_res_laser_ca.paa";
									_owr_action5 ctrlSetTooltip "Research laser weapon system";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									if (["opto", 7, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action5 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action5 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (["opto", 7, bis_curator_west] call owr_fn_isAllowedToResearch) then {
											_owr_action5 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action5 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action5 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "opto", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 7, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
										};
									};

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_mat_detect_ca.paa";
									_owr_action3 ctrlSetTooltip "Research precise detection of materialization";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (["opto", 5, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action3 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action3 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (["opto", 5, bis_curator_west] call owr_fn_isAllowedToResearch) then {
											_owr_action3 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action3 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "opto", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 5, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
										};
									};

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_remote_control_ca.paa";
									_owr_action2 ctrlSetTooltip "Research remote control of vehicles";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["opto", 4, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action2 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action2 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (false) then {	// ["opto", 4, bis_curator_west] call owr_fn_isAllowedToResearch
											_owr_action2 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action2 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "opto", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 4, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action2 ctrlSetTooltip "Research remote control of vehicles ( not yet implemented )";
										};
									};

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_radar_ca.paa";
									_owr_action1 ctrlSetTooltip "Research radar technology";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (["opto", 3, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action1 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action1 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										_owr_action1 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action1 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "opto", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 3, true];
											playSound "owr_ui_button_confirm";
										}];	
									};
								};

								case 6: {
									// SIBERITE RESEARCH
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									if (["siberite", 0, bis_curator_west] call owr_fn_isResearchComplete) then {
										if (!(["siberite", 1, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_sib_t2_ca.paa";
											_owr_action8 ctrlSetTooltip "Research siberite tech tier II upgrade";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "siberite", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 1, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											if (!(["siberite", 2, bis_curator_west] call owr_fn_isResearchComplete)) then {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_sib_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research siberite tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
												_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
												_owr_action8 ctrladdeventhandler ["buttonclick", {
													_labToUpgrade = (curatorSelected select 0) select 0;
													_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
													_labToUpgrade setVariable ["ow_curr_res_cat", "siberite", true];
													_labToUpgrade setVariable ["ow_curr_res_index", 2, true];
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_sib_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research siberite tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
												_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
											};
										};
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_sib_t1_ca.paa";
										_owr_action8 ctrlSetTooltip "Research siberite tech tier I upgrade";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "siberite", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 0, true];
											playSound "owr_ui_button_confirm";
										}];	
									};

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_sib_motor_ca.paa";
									_owr_action2 ctrlSetTooltip "Research siberite powered motor";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["siberite", 4, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action2 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action2 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (["siberite", 4, bis_curator_west] call owr_fn_isAllowedToResearch) then {
											_owr_action2 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action2 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "siberite", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 4, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
										};
									};

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_sib_power_ca.paa";
									_owr_action1 ctrlSetTooltip "Research power of siberite";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (["siberite", 3, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action1 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action1 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										_owr_action1 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action1 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "siberite", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 3, true];
											playSound "owr_ui_button_confirm";
										}];	
									};
								};

								case 7: {
									// WEAPON RESEARCH
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									if (["weap", 0, bis_curator_west] call owr_fn_isResearchComplete) then {
										if (!(["weap", 1, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_weap_t2_ca.paa";
											_owr_action8 ctrlSetTooltip "Research weapon tech tier II upgrade";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 1, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											if (!(["weap", 2, bis_curator_west] call owr_fn_isResearchComplete)) then {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_weap_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research weapon tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
												_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
												_owr_action8 ctrladdeventhandler ["buttonclick", {
													_labToUpgrade = (curatorSelected select 0) select 0;
													_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
													_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
													_labToUpgrade setVariable ["ow_curr_res_index", 2, true];
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_weap_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research weapon tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
												_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
											};
										};
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_weap_t1_ca.paa";
										_owr_action8 ctrlSetTooltip "Research weapon tech tier I upgrade";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 0, true];
											playSound "owr_ui_button_confirm";
										}];	
									};


									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "\owr\ui\data\research\icon_res_rocket_launcher_ca.paa";
									_owr_action5 ctrlSetTooltip "Research vehicle rocket launcher";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 5, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action5 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action5 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (["weap", 5, bis_curator_west] call owr_fn_isAllowedToResearch) then {
											_owr_action5 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action5 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action5 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 5, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
										};
									};

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_heavy_gun_ca.paa";
									_owr_action3 ctrlSetTooltip "Research cannon improvements";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 6, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action3 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action3 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (["weap", 6, bis_curator_west] call owr_fn_isAllowedToResearch) then {
											_owr_action3 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action3 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 6, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
										};
									};

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_gun_ca.paa";
									_owr_action2 ctrlSetTooltip "Research cannon";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 4, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action2 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action2 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (["weap", 4, bis_curator_west] call owr_fn_isAllowedToResearch) then {
											_owr_action2 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action2 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 4, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
										};
									};

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_rot_mgun_ca.paa";
									_owr_action1 ctrlSetTooltip "Research minigun";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 3, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action1 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action1 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										_owr_action1 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action1 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 3, true];
											playSound "owr_ui_button_confirm";
										}];	
									};
								};

								case 8: {
									// RESEARCH IN PROGRESS
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										_labToUpgrade setVariable ["ow_curr_res_cat", "", true];
										playSound "owr_ui_button_cancel";
									}];	

									if (isNull (_labka getVariable "ow_build_wrhs")) then {
										_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
										_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_objectToSearchAround = (curatorSelected select 0) select 0;
											_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_am"], 150];
											if ((count _warehousesAvailable) > 0) then {
												_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
											};
										}];
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
										_owr_action8 ctrlSetTooltip "Warehouse connected";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									};

									_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
									_owr_action7 ctrlSetTooltip "Lights On/Off";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_labToUse = (curatorSelected select 0) select 0;
										_lightState = _labToUse getVariable "ow_build_light";
										if (_lightState) then {
											_labToUse setVariable ["ow_build_light", false, true];
										} else {
											_labToUse setVariable ["ow_build_light", true, true];
										};
										playSound "owr_ui_button_confirm";
									}];

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
									_someoneNotAScientist = false;
									{
										if (_x getVariable "ow_class" != 3) then {
											_someoneNotAScientist = true;
										};
									} forEach (crew _labka);

									if (_someoneNotAScientist) then {
										_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makescientist_ca.paa";
										_owr_action3 ctrlSetTooltip "Change class to scientist";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_labToChange = (curatorSelected select 0) select 0;
											{
												_x setVariable ["ow_class", 3, true];
												//[_x, 3] call owr_fn_changeClassGear;
												[_x, 3] remoteExec ["owr_fn_changeClassGear", owner _owman];
											} forEach (crew _labToChange);
											playSound "owr_ui_button_confirm";
										}];
									} else {
										_owr_action3 ctrlSetText "";
										_owr_action3 ctrlSetTooltip "";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									};

									_owr_action2 ctrlSetText "";
									_owr_action2 ctrlSetTooltip "";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};
							};
						} else {
							_owr_action9 ctrlSetText "";
							_owr_action9 ctrlSetTooltip "";
							_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

							if (isNull (_labka getVariable "ow_build_wrhs")) then {
								_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
								_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action8 ctrladdeventhandler ["buttonclick", {
									_objectToSearchAround = (curatorSelected select 0) select 0;
									_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_am"], 150];
									if ((count _warehousesAvailable) > 0) then {
										_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
									};
								}];
							} else {
								_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
								_owr_action8 ctrlSetTooltip "Warehouse connected";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
								_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
							};

							_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
							_owr_action7 ctrlSetTooltip "Lights On/Off";
							_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action7 ctrladdeventhandler ["buttonclick", {
								_labToUse = (curatorSelected select 0) select 0;
								_lightState = _labToUse getVariable "ow_build_light";
								if (_lightState) then {
									_labToUse setVariable ["ow_build_light", false, true];
								} else {
									_labToUse setVariable ["ow_build_light", true, true];
								};
								playSound "owr_ui_button_confirm";
							}];

							_owr_action6 ctrlSetText "";
							_owr_action6 ctrlSetTooltip "";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action5 ctrlSetText "";
							_owr_action5 ctrlSetTooltip "";
							_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action4 ctrlSetText "";
							_owr_action4 ctrlSetTooltip "";
							_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action3 ctrlSetText "";
							_owr_action3 ctrlSetTooltip "";
							_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action2 ctrlSetText "";
							_owr_action2 ctrlSetTooltip "";
							_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action1 ctrlSetText "";
							_owr_action1 ctrlSetTooltip "";
							_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
						};
					};
					// RU - LAB
					if ((_selected select 0) isKindOf "lab_ru") then {
						_labka = (_selected select 0);
						{
							_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
							_x ctrlSetActiveColor [1, 1, 1, 1];
						} forEach _actionButtons;

						if (_labka getVariable "ow_build_ready") then {
							// 4 - basic, 5 - left, 6 - right
							switch (_labka getVariable "ow_lab_buildmode") do {
								case 0: {

									if (count (crew _labka) > 0) then {
										_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
										_owr_action1 ctrlSetTooltip "Order all to exit building (G)";
										_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_labkaToUse = (curatorSelected select 0) select 0;
											{
												[_x] call owr_fn_getOutOfVehicle;
											} forEach (crew _labkaToUse);
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action1 ctrlSetText "";
										_owr_action1 ctrlSetTooltip "";
										_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									};

									_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
									_owr_action2 ctrlSetTooltip "Deconstruct building";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_labToUse = (curatorSelected select 0) select 0;
										_labToUse setVariable ["ow_build_deconstruct", true, true];
										_labToUse setVariable ["ow_build_ready", false, true];
										playSound "owr_ui_button_confirm";
									}];

									// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
									_someoneNotAScientist = false;
									{
										if (_x getVariable "ow_class" != 3) then {
											_someoneNotAScientist = true;
										};
									} forEach (crew _labka);

									if (_someoneNotAScientist) then {
										_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makescientist_ca.paa";
										_owr_action3 ctrlSetTooltip "Change class to scientist";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_labToChange = (curatorSelected select 0) select 0;
											{
												_x setVariable ["ow_class", 3, true];
												//[_x, 3] call owr_fn_changeClassGear;
												[_x, 3] remoteExec ["owr_fn_changeClassGear", owner _owman];
											} forEach (crew _labToChange);
											playSound "owr_ui_button_confirm";
										}];
									} else {
										_owr_action3 ctrlSetText "";
										_owr_action3 ctrlSetTooltip "";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									};

									_owr_action9 ctrlSetText "";
									_owr_action9 ctrlSetTooltip "";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

									if (isNull (_labka getVariable "ow_build_wrhs")) then {
										_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
										_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_objectToSearchAround = (curatorSelected select 0) select 0;
											_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ru"], 150];
											if ((count _warehousesAvailable) > 0) then {
												_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
											};
										}];
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
										_owr_action8 ctrlSetTooltip "Warehouse connected";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									};

									_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
									_owr_action7 ctrlSetTooltip "Lights On/Off";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_labToUse = (curatorSelected select 0) select 0;
										_lightState = _labToUse getVariable "ow_build_light";
										if (_lightState) then {
											_labToUse setVariable ["ow_build_light", false, true];
										} else {
											_labToUse setVariable ["ow_build_light", true, true];
										};
										playSound "owr_ui_button_confirm";
									}];

									if (!(isNull (_labka getVariable "ow_build_wrhs"))) then {
										_owr_action4 ctrlSetText "\owr\ui\data\research\icon_rescat_basic_ca.paa";
										_owr_action4 ctrlSetTooltip "Basic research";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action4 ctrladdeventhandler ["buttonclick", {
											_labToUse = (curatorSelected select 0) select 0;
											_labToUse setVariable ["ow_lab_buildmode", 3, true];
											playSound "owr_ui_button_confirm";
										}];
									} else {
										_owr_action4 ctrlSetText "\owr\ui\data\research\icon_rescat_basic_ca.paa";
										_owr_action4 ctrlSetTooltip "Basic research ( connect warehouse )";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									};

									if (!(isNull (_labka getVariable "ow_build_wrhs"))) then {
										if ((_labka getVariable "ow_lab_left") == "") then {
											_owr_action5 ctrlSetText "\owr\ui\data\research\icon_labupgrade_left_ca.paa";
											_owr_action5 ctrlSetTooltip "Upgrade left";
											_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action5 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 1, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											switch (_labka getVariable "ow_lab_left") do {
												case "comp": {
													_owr_action5 ctrlSetText "\owr\ui\data\research\icon_rescat_comp_ca.paa";
													_owr_action5 ctrlSetTooltip "Computer research";
													_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
													_owr_action5 ctrladdeventhandler ["buttonclick", {
														_labToUpgrade = (curatorSelected select 0) select 0;
														_labToUpgrade setVariable ["ow_lab_buildmode", 4, true];
														playSound "owr_ui_button_confirm";
													}];	
												};
												case "siberite": {
													_owr_action5 ctrlSetText "\owr\ui\data\research\icon_rescat_siberite_ca.paa";
													_owr_action5 ctrlSetTooltip "Alaskite research";
													_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
													_owr_action5 ctrladdeventhandler ["buttonclick", {
														_labToUpgrade = (curatorSelected select 0) select 0;
														_labToUpgrade setVariable ["ow_lab_buildmode", 6, true];
														playSound "owr_ui_button_confirm";
													}];	
												};
											};
										};
									} else {
										_owr_action5 ctrlSetText "\owr\ui\data\research\icon_labupgrade_left_ca.paa";
										_owr_action5 ctrlSetTooltip "Upgrade left ( connect warehouse )";
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									};

									if (!(isNull (_labka getVariable "ow_build_wrhs"))) then {
										if ((_labka getVariable "ow_lab_right") == "") then {
											_owr_action6 ctrlSetText "\owr\ui\data\research\icon_labupgrade_right_ca.paa";
											_owr_action6 ctrlSetTooltip "Upgrade right";
											_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action6 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											switch (_labka getVariable "ow_lab_right") do {
												case "weap": {
													_owr_action6 ctrlSetText "\owr\ui\data\research\icon_rescat_weap_ca.paa";
													_owr_action6 ctrlSetTooltip "Weapon research";
													_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
													_owr_action6 ctrladdeventhandler ["buttonclick", {
														_labToUpgrade = (curatorSelected select 0) select 0;
														_labToUpgrade setVariable ["ow_lab_buildmode", 7, true];
														playSound "owr_ui_button_confirm";
													}];	
												};
												case "time": {
													_owr_action6 ctrlSetText "\owr\ui\data\research\icon_rescat_timespace_ca.paa";
													_owr_action6 ctrlSetTooltip "Space-time research";
													_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
													_owr_action6 ctrladdeventhandler ["buttonclick", {
														_labToUpgrade = (curatorSelected select 0) select 0;
														_labToUpgrade setVariable ["ow_lab_buildmode", 5, true];
														playSound "owr_ui_button_confirm";
													}];	
												};
											};
										};
									} else {
										_owr_action6 ctrlSetText "\owr\ui\data\research\icon_labupgrade_left_ca.paa";
										_owr_action6 ctrlSetTooltip "Upgrade right ( connect warehouse )";
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									};

								};

								case 1: {
									// upgrade left
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
									_owr_action7 ctrlSetTooltip "Lights On/Off";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_labToUse = (curatorSelected select 0) select 0;
										_lightState = _labToUse getVariable "ow_build_light";
										if (_lightState) then {
											_labToUse setVariable ["ow_build_light", false, true];
										} else {
											_labToUse setVariable ["ow_build_light", true, true];
										};
										playSound "owr_ui_button_confirm";
									}];

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_rescat_siberite_ca.paa";
									_resourceArray = ["lab_siberite"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action3 ctrlSetTooltip format["Alaskite lab upgrade %1", _costString];
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										// get the resources needed
										_resourceArray = ["lab_siberite"] call owr_fn_getUpgradeCostStr;
										if ([_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
											// we have enough resource in warehouse, take them out
											[_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
											// let the upgrade begin
											_labToUpgrade setVariable ["ow_lab_left", "siberite", true];
											playSound "owr_ui_button_confirm";
										} else {
											playSound "owr_ui_button_cancel";
										};
									}];	

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_rescat_comp_ca.paa";
									_resourceArray = ["lab_comp"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action2 ctrlSetTooltip format["Computer lab upgrade %1", _costString];
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										// get the resources needed
										_resourceArray = ["lab_comp"] call owr_fn_getUpgradeCostStr;
										if ([_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
											// we have enough resource in warehouse, take them out
											[_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
											// let the upgrade begin
											_labToUpgrade setVariable ["ow_lab_left", "comp", true];
											playSound "owr_ui_button_confirm";
										} else {
											playSound "owr_ui_button_cancel";
										};
									}];	

									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};

								case 2: {
									// upgrade right
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
									_owr_action7 ctrlSetTooltip "Lights On/Off";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_labToUse = (curatorSelected select 0) select 0;
										_lightState = _labToUse getVariable "ow_build_light";
										if (_lightState) then {
											_labToUse setVariable ["ow_build_light", false, true];
										} else {
											_labToUse setVariable ["ow_build_light", true, true];
										};
										playSound "owr_ui_button_confirm";
									}];

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "\owr\ui\data\research\icon_rescat_timespace_ca.paa";
									_resourceArray = ["lab_time"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action4 ctrlSetTooltip format["Space-time lab upgrade %1", _costString];
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										// get the resources needed
										_resourceArray = ["lab_time"] call owr_fn_getUpgradeCostStr;
										if ([_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
											// we have enough resource in warehouse, take them out
											[_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
											// let the upgrade begin
											_labToUpgrade setVariable ["ow_lab_right", "time", true];
											playSound "owr_ui_button_confirm";
										} else {
											playSound "owr_ui_button_cancel";
										};
									}];	

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "";
									_owr_action2 ctrlSetTooltip "";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_rescat_weap_ca.paa";
									_resourceArray = ["lab_weap"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action1 ctrlSetTooltip format["Weapon lab upgrade %1", _costString];
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										// get the resources needed
										_resourceArray = ["lab_weap"] call owr_fn_getUpgradeCostStr;
										if ([_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
											// we have enough resource in warehouse, take them out
											[_resourceArray, _labToUpgrade getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
											// let the upgrade begin
											_labToUpgrade setVariable ["ow_lab_right", "weap", true];
											playSound "owr_ui_button_confirm";
										} else {
											playSound "owr_ui_button_cancel";
										};
									}];	
								};

								case 3: {
									// BASIC RESEARCH
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	


									if (["basic", 0, bis_curator_east] call owr_fn_isResearchComplete) then {
										if (!(["basic", 1, bis_curator_east] call owr_fn_isResearchComplete)) then {
											_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_basic_t2_ca.paa";
											_owr_action8 ctrlSetTooltip "Research basic tech tier II upgrade";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 1, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											if (!(["basic", 2, bis_curator_east] call owr_fn_isResearchComplete)) then {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_basic_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research basic tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
												_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
												_owr_action8 ctrladdeventhandler ["buttonclick", {
													_labToUpgrade = (curatorSelected select 0) select 0;
													_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
													_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
													_labToUpgrade setVariable ["ow_curr_res_index", 2, true];
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_basic_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research basic tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
												_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
											};
										};
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_basic_t1_ca.paa";
										_owr_action8 ctrlSetTooltip "Research basic tech tier I upgrade";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 0, true];
											playSound "owr_ui_button_confirm";
										}];	
									};

									_owr_action7 ctrlSetText "\owr\ui\data\research\icon_res_sib_detect_ca.paa";
									_owr_action7 ctrlSetTooltip "Research a way to detect alaskite deposits";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 5, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action7 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action7 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										_owr_action7 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action7 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action7 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 5, true];
											playSound "owr_ui_button_confirm";
										}];	
									};

									_owr_action6 ctrlSetText "\owr\ui\data\research\icon_res_opo_help_ca.paa";
									_owr_action6 ctrlSetTooltip "Research a way to learn apes to be a worker";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 9, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action6 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action6 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (false) then {	// ["basic", 9, bis_curator_east] call owr_fn_isAllowedToResearch
											_owr_action6 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action6 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action6 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 9, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action6 ctrlSetTooltip "Research a way to learn apes to be a worker ( not yet implemented )";
										};
									};

									_owr_action5 ctrlSetText "\owr\ui\data\research\icon_res_opo_fight_ca.paa";
									_owr_action5 ctrlSetTooltip "Research a way to learn apes to be a soldier";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 9, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action5 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action5 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (false) then {	// ["basic", 9, bis_curator_east] call owr_fn_isAllowedToResearch
											_owr_action5 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action5 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action5 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 7, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action5 ctrlSetTooltip "Research a way to learn apes to be a soldier ( not yet implemented )";
										};
									};

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_opo_psych_ca.paa";
									_owr_action3 ctrlSetTooltip "Research a way to understand apes";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 8, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action3 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action3 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (false) then {
											_owr_action3 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action3 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 8, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action3 ctrlSetTooltip "Research a way to understand apes ( not yet implemented )";
										};
									};

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_moil_ca.paa";
									_owr_action2 ctrlSetTooltip "Research combustion engine";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 4, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action2 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action2 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (["basic", 4, bis_curator_east] call owr_fn_isAllowedToResearch) then {
											_owr_action2 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action2 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 4, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
										};
									};

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_poil_ca.paa";
									_owr_action1 ctrlSetTooltip "Research diesel power plant";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 3, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action1 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action1 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										_owr_action1 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action1 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "basic", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 3, true];
											playSound "owr_ui_button_confirm";
										}];	
									};
								};


								case 4: {
									// COMP RESEARCH
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	


									if (["comp", 0, bis_curator_east] call owr_fn_isResearchComplete) then {
										if (!(["comp", 1, bis_curator_east] call owr_fn_isResearchComplete)) then {
											_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_comp_t2_ca.paa";
											_owr_action8 ctrlSetTooltip "Research computer tech tier II upgrade";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "comp", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 1, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											if (!(["comp", 2, bis_curator_east] call owr_fn_isResearchComplete)) then {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_comp_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research computer tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
												_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
												_owr_action8 ctrladdeventhandler ["buttonclick", {
													_labToUpgrade = (curatorSelected select 0) select 0;
													_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
													_labToUpgrade setVariable ["ow_curr_res_cat", "comp", true];
													_labToUpgrade setVariable ["ow_curr_res_index", 2, true];
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_comp_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research computer tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
												_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
											};
										};
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_comp_t1_ca.paa";
										_owr_action8 ctrlSetTooltip "Research computer tech tier I upgrade";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "comp", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 0, true];
											playSound "owr_ui_button_confirm";
										}];	
									};

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "\owr\ui\data\research\icon_res_comp_teleport_ca.paa";
									_owr_action5 ctrlSetTooltip "Research precise teleport";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									if (["comp", 7, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action5 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action5 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (false) then {	// ["comp", 7, bis_curator_east] call owr_fn_isAllowedToResearch
											_owr_action5 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action5 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action5 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "comp", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 7, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action5 ctrlSetTooltip "Research precise teleport ( not yet implemented )";
										};
									};

									_owr_action4 ctrlSetText "\owr\ui\data\research\icon_res_comp_mat_for_ca.paa";
									_owr_action4 ctrlSetTooltip "Research materialization forecast";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									if (["comp", 6, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action4 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action4 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if ((["comp", 6, bis_curator_east] call owr_fn_isAllowedToResearch)) then {
											_owr_action4 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action4 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action4 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "comp", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 6, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action4 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action4 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
										};
									};

									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_comp_hack_ca.paa";
									_owr_action3 ctrlSetTooltip "Research hacking";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (["comp", 5, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action3 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action3 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (false) then {	// ["comp", 5, bis_curator_east] call owr_fn_isAllowedToResearch
											_owr_action3 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action3 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "comp", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 5, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action3 ctrlSetTooltip "Research hacking ( not yet implemented )";
										};
									};

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_adv_ai_ca.paa";
									_owr_action2 ctrlSetTooltip "Research advanced AI";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["comp", 4, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action2 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action2 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (["comp", 4, bis_curator_east] call owr_fn_isAllowedToResearch) then {
											_owr_action2 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action2 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "comp", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 4, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
										};
									};

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_ai_ca.paa";
									_owr_action1 ctrlSetTooltip "Research AI";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (["comp", 3, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action1 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action1 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										_owr_action1 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action1 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "comp", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 3, true];
											playSound "owr_ui_button_confirm";
										}];	
									};
								};

								case 5: {
									// TIME RESEARCH
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									if (["time", 0, bis_curator_east] call owr_fn_isResearchComplete) then {
										if (!(["time", 1, bis_curator_east] call owr_fn_isResearchComplete)) then {
											_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_time_t2_ca.paa";
											_owr_action8 ctrlSetTooltip "Research space-time tech tier II upgrade";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "time", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 1, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											if (!(["time", 2, bis_curator_east] call owr_fn_isResearchComplete)) then {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_time_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research space-time tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
												_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
												_owr_action8 ctrladdeventhandler ["buttonclick", {
													_labToUpgrade = (curatorSelected select 0) select 0;
													_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
													_labToUpgrade setVariable ["ow_curr_res_cat", "time", true];
													_labToUpgrade setVariable ["ow_curr_res_index", 2, true];
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_time_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research space-time tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
												_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
											};
										};
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_time_t1_ca.paa";
										_owr_action8 ctrlSetTooltip "Research space-time tech tier I upgrade";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "time", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 0, true];
											playSound "owr_ui_button_confirm";
										}];	
									};

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "\owr\ui\data\research\icon_res_time_tel_ca.paa";
									_owr_action5 ctrlSetTooltip "Limited spontaneous teleportation";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									if (["time", 7, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action5 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action5 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									} else {
										if (false) then {	// ["time", 7, bis_curator_east] call owr_fn_isAllowedToResearch
											_owr_action5 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action5 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action5 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "time", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 7, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action5 ctrlSetTooltip "Limited spontaneous teleportation ( not yet implemented )";
										};
									};

									_owr_action4 ctrlSetText "\owr\ui\data\research\icon_res_time_spon_tel_ca.paa";
									_owr_action4 ctrlSetTooltip "Homogenic Tau-field";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									if (["time", 6, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action4 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action4 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									} else {
										if (false) then {	// ["time", 6, bis_curator_east] call owr_fn_isAllowedToResearch
											_owr_action4 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action4 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action4 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "time", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 5, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action4 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action4 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	
											_owr_action4 ctrlSetTooltip "Homogenic Tau-field ( not yet implemented )";
										};
									};

									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_time_tau_ca.paa";
									_owr_action3 ctrlSetTooltip "Local Tau-field";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (["time", 5, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action3 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action3 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									} else {
										if (false) then {	// ["basic", 5, bis_curator_east] call owr_fn_isResearchComplete
											_owr_action3 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action3 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "time", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 5, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action3 ctrlSetTooltip "Local Tau-field ( not yet implemented )";
										};
									};

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_time_tel_shot_ca.paa";
									_owr_action2 ctrlSetTooltip "Space anomalies";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["time", 4, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action2 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action2 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									} else {
										if (["basic", 5, bis_curator_east] call owr_fn_isResearchComplete) then {
											_owr_action2 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action2 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "time", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 4, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action2 ctrlSetTooltip "Space anomalies ( not yet implemented )";
										};
									};

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_time_slow_shot_ca.paa";
									_owr_action1 ctrlSetTooltip "Tau radiation";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (["time", 3, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action1 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action1 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									} else {
										if (["basic", 5, bis_curator_east] call owr_fn_isResearchComplete) then {
											_owr_action1 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action1 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action1 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "time", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 3, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action1 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action1 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action1 ctrlSetTooltip "Tau radiation ( not yet implemented )";
										};
									};
								};

								case 6: {
									// SIBERITE RESEARCH
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									if (["siberite", 0, bis_curator_east] call owr_fn_isResearchComplete) then {
										if (!(["siberite", 1, bis_curator_east] call owr_fn_isResearchComplete)) then {
											_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_sib_t2_ca.paa";
											_owr_action8 ctrlSetTooltip "Research alaskite tech tier II upgrade";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "siberite", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 1, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											if (!(["siberite", 2, bis_curator_east] call owr_fn_isResearchComplete)) then {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_sib_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research alaskite tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
												_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
												_owr_action8 ctrladdeventhandler ["buttonclick", {
													_labToUpgrade = (curatorSelected select 0) select 0;
													_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
													_labToUpgrade setVariable ["ow_curr_res_cat", "siberite", true];
													_labToUpgrade setVariable ["ow_curr_res_index", 2, true];
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_sib_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research alaskite tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
												_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
											};
										};
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_sib_t1_ca.paa";
										_owr_action8 ctrlSetTooltip "Research alaskite tech tier I upgrade";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "siberite", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 0, true];
											playSound "owr_ui_button_confirm";
										}];	
									};

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "\owr\ui\data\research\icon_res_sib_detect_ca.paa";
									_owr_action5 ctrlSetTooltip "Research alaskite targeting";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									if (["siberite", 5, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action5 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 
										_owr_action5 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									} else {
										if (["siberite", 5, bis_curator_east] call owr_fn_isAllowedToResearch && (["basic", 5, bis_curator_east] call owr_fn_isResearchComplete)) then {
											_owr_action5 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action5 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action5 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "siberite", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 5, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										};
									};

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_sib_motor_ca.paa";
									_owr_action2 ctrlSetTooltip "Research alaskite powered motor";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["siberite", 4, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action2 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action2 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									} else {
										if (["siberite", 4, bis_curator_east] call owr_fn_isAllowedToResearch) then {
											_owr_action2 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action2 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "siberite", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 4, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	
										};
									};

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_sib_power_ca.paa";
									_owr_action1 ctrlSetTooltip "Research power of alaskite";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (["siberite", 3, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action1 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 
										_owr_action1 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									} else {
										_owr_action1 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action1 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "siberite", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 3, true];
											playSound "owr_ui_button_confirm";
										}];	
									};
								};

								case 7: {
									// WEAPON RESEARCH
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									if (["weap", 0, bis_curator_east] call owr_fn_isResearchComplete) then {
										if (!(["weap", 1, bis_curator_east] call owr_fn_isResearchComplete)) then {
											_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_weap_t2_ca.paa";
											_owr_action8 ctrlSetTooltip "Research weapon tech tier II upgrade";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 1, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											if (!(["weap", 2, bis_curator_east] call owr_fn_isResearchComplete)) then {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_weap_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research weapon tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
												_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
												_owr_action8 ctrladdeventhandler ["buttonclick", {
													_labToUpgrade = (curatorSelected select 0) select 0;
													_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
													_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
													_labToUpgrade setVariable ["ow_curr_res_index", 2, true];
													playSound "owr_ui_button_confirm";
												}];
											} else {
												_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_weap_t3_ca.paa";
												_owr_action8 ctrlSetTooltip "Research weapon tech tier III upgrade";
												_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
												_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
												_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
											};
										};
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_weap_t1_ca.paa";
										_owr_action8 ctrlSetTooltip "Research weapon tech tier I upgrade";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action8 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 0, true];
											playSound "owr_ui_button_confirm";
										}];	
									};


									_owr_action7 ctrlSetText "\owr\ui\data\research\icon_res_weap_behemoth_ca.paa";
									_owr_action7 ctrlSetTooltip "Research behemoth";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									if ((["weap", 5, bis_curator_east] call owr_fn_isResearchComplete) && (["weap", 6, bis_curator_east] call owr_fn_isResearchComplete) && (["weap", 7, bis_curator_east] call owr_fn_isResearchComplete) && (["comp", 4, bis_curator_east] call owr_fn_isResearchComplete)) then { 
										_owr_action7 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action7 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (false) then { // ((["weap", 5, bis_curator_east] call owr_fn_isResearchComplete) && (["weap", 6, bis_curator_east] call owr_fn_isResearchComplete) && (["weap", 7, bis_curator_east] call owr_fn_isResearchComplete) && (["comp", 4, bis_curator_east] call owr_fn_isResearchComplete))
											_owr_action7 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action7 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action7 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 8, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action7 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action7 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action7 ctrlSetTooltip "Research behemoth ( not yet implemented )";
										};
									};


									_owr_action6 ctrlSetText "\owr\ui\data\research\icon_res_weap_rocket_ca.paa";
									_owr_action6 ctrlSetTooltip "Research rocket";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 7, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action6 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action6 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (["weap", 5, bis_curator_east] call owr_fn_isResearchComplete) then {
											_owr_action6 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action6 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action6 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 7, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
										};
									};

									_owr_action5 ctrlSetText "\owr\ui\data\research\icon_res_rocket_launcher_ca.paa";
									_owr_action5 ctrlSetTooltip "Research vehicle rocket launcher";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 5, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action5 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action5 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (["weap", 5, bis_curator_east] call owr_fn_isAllowedToResearch) then {
											_owr_action5 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action5 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action5 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 5, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
										};
									};

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_heavy_gun_ca.paa";
									_owr_action3 ctrlSetTooltip "Research cannon improvements";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 6, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action3 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action3 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (["weap", 6, bis_curator_east] call owr_fn_isAllowedToResearch) then {
											_owr_action3 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action3 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 6, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
										};
									};

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_gun_ca.paa";
									_owr_action2 ctrlSetTooltip "Research cannon";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 4, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action2 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action2 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										if (["weap", 4, bis_curator_east] call owr_fn_isAllowedToResearch) then {
											_owr_action2 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action2 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_labToUpgrade = (curatorSelected select 0) select 0;
												_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
												_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
												_labToUpgrade setVariable ["ow_curr_res_index", 4, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];	// not yet available
											_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];	// not yet available
										};
									};

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_rot_mgun_ca.paa";
									_owr_action1 ctrlSetTooltip "Research minigun";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 3, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action1 ctrlSetTextColor [0.0, 0.75, 0.0, 1]; 		// done
										_owr_action1 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];	// done
									} else {
										_owr_action1 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
										_owr_action1 ctrlSetActiveColor [1, 1, 1, 1];
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_labToUpgrade = (curatorSelected select 0) select 0;
											_labToUpgrade setVariable ["ow_lab_buildmode", 8, true];
											_labToUpgrade setVariable ["ow_curr_res_cat", "weap", true];
											_labToUpgrade setVariable ["ow_curr_res_index", 3, true];
											playSound "owr_ui_button_confirm";
										}];	
									};
								};

								case 8: {
									// RESEARCH IN PROGRESS
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel research";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_labToUpgrade = (curatorSelected select 0) select 0;
										_labToUpgrade setVariable ["ow_lab_buildmode", 0, true];
										_labToUpgrade setVariable ["ow_curr_res_cat", "", true];
										playSound "owr_ui_button_cancel";
									}];	

									if (isNull (_labka getVariable "ow_build_wrhs")) then {
										_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
										_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_objectToSearchAround = (curatorSelected select 0) select 0;
											_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ru"], 150];
											if ((count _warehousesAvailable) > 0) then {
												_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
											};
										}];
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
										_owr_action8 ctrlSetTooltip "Warehouse connected";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									};

									_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
									_owr_action7 ctrlSetTooltip "Lights On/Off";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_labToUse = (curatorSelected select 0) select 0;
										_lightState = _labToUse getVariable "ow_build_light";
										if (_lightState) then {
											_labToUse setVariable ["ow_build_light", false, true];
										} else {
											_labToUse setVariable ["ow_build_light", true, true];
										};
										playSound "owr_ui_button_confirm";
									}];

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
									_someoneNotAScientist = false;
									{
										if (_x getVariable "ow_class" != 3) then {
											_someoneNotAScientist = true;
										};
									} forEach (crew _labka);

									if (_someoneNotAScientist) then {
										_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makescientist_ca.paa";
										_owr_action3 ctrlSetTooltip "Change class to scientist";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_labToChange = (curatorSelected select 0) select 0;
											{
												_x setVariable ["ow_class", 3, true];
												//[_x, 3] call owr_fn_changeClassGear;
												[_x, 3] remoteExec ["owr_fn_changeClassGear", owner _owman];
											} forEach (crew _labToChange);
											playSound "owr_ui_button_confirm";
										}];
									} else {
										_owr_action3 ctrlSetText "";
										_owr_action3 ctrlSetTooltip "";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									};

									_owr_action2 ctrlSetText "";
									_owr_action2 ctrlSetTooltip "";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};
							};
						} else {
							_owr_action9 ctrlSetText "";
							_owr_action9 ctrlSetTooltip "";
							_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

							if (isNull (_labka getVariable "ow_build_wrhs")) then {
								_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
								_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action8 ctrladdeventhandler ["buttonclick", {
									_objectToSearchAround = (curatorSelected select 0) select 0;
									_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ru"], 150];
									if ((count _warehousesAvailable) > 0) then {
										_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
									};
								}];
							} else {
								_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
								_owr_action8 ctrlSetTooltip "Warehouse connected";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
								_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
							};

							_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
							_owr_action7 ctrlSetTooltip "Lights On/Off";
							_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action7 ctrladdeventhandler ["buttonclick", {
								_labToUse = (curatorSelected select 0) select 0;
								_lightState = _labToUse getVariable "ow_build_light";
								if (_lightState) then {
									_labToUse setVariable ["ow_build_light", false, true];
								} else {
									_labToUse setVariable ["ow_build_light", true, true];
								};
								playSound "owr_ui_button_confirm";
							}];

							_owr_action6 ctrlSetText "";
							_owr_action6 ctrlSetTooltip "";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action5 ctrlSetText "";
							_owr_action5 ctrlSetTooltip "";
							_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action4 ctrlSetText "";
							_owr_action4 ctrlSetTooltip "";
							_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action3 ctrlSetText "";
							_owr_action3 ctrlSetTooltip "";
							_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action2 ctrlSetText "";
							_owr_action2 ctrlSetTooltip "";
							_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action1 ctrlSetText "";
							_owr_action1 ctrlSetTooltip "";
							_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
						};
					};
					// AR - LAB
					if ((_selected select 0) isKindOf "lab_ar") then {
						_labka = (_selected select 0);
						{
							_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
							_x ctrlSetActiveColor [1, 1, 1, 1];
						} forEach _actionButtons;
					};



					if (((_selected select 0) isKindOf "warehouse_ru") || ((_selected select 0) isKindOf "warehouse_am") || ((_selected select 0) isKindOf "warehouse_ar")) then {
						_wrhs = (_selected select 0);
						{
							_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
							_x ctrlSetActiveColor [1, 1, 1, 1];
						} forEach _actionButtons;

						if (_wrhs getVariable "ow_build_ready") then {
							if (!(_wrhs getVariable "ow_build_upgrade")) then {
								_owr_action9 ctrlSetText "";
								_owr_action9 ctrlSetTooltip "";
								_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action8 ctrlSetText "";
								_owr_action8 ctrlSetTooltip "";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action7 ctrlSetText "";
								_owr_action7 ctrlSetTooltip "";
								_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
								_owr_action6 ctrlSetTooltip "Deconstruct building";
								_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action6 ctrladdeventhandler ["buttonclick", {
									_warehouseToUse = (curatorSelected select 0) select 0;
									_warehouseToUse setVariable ["ow_build_deconstruct", true, true];
									_warehouseToUse setVariable ["ow_build_ready", false, true];
									playSound "owr_ui_button_confirm";
								}];

								_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
								_owr_action5 ctrlSetTooltip "Lights On/Off";
								_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action5 ctrladdeventhandler ["buttonclick", {
									_wrhsToWorkWith = (curatorSelected select 0) select 0;
									_lightState = _wrhsToWorkWith getVariable "ow_build_light";
									if (_lightState) then {
										_wrhsToWorkWith setVariable ["ow_build_light", false, true];
									} else {
										_wrhsToWorkWith setVariable ["ow_build_light", true, true];
									};
									playSound "owr_ui_button_confirm";
								}];

								_owr_action4 ctrlSetText "";
								_owr_action4 ctrlSetTooltip "";
								_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

								// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
								_someoneNotAWorker = false;
								{
									if (_x getVariable "ow_class" != 1) then {
										_someoneNotAWorker = true;
									};
								} forEach (crew _wrhs);

								if (_someoneNotAWorker) then {
									_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makeworker_ca.paa";
									_owr_action3 ctrlSetTooltip "Change class to worker";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_wrhsToWorkWith = (curatorSelected select 0) select 0;
										{
											_x setVariable ["ow_class", 1, true];
											//[_x, 1] call owr_fn_changeClassGear;
											[_x, 1] remoteExec ["owr_fn_changeClassGear", owner _owman];
										} forEach (crew _wrhsToWorkWith);
										playSound "owr_ui_button_confirm";
									}];
								} else {
									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
								};



								_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_bupgrade_ca.paa";

								_resourceArray = [typeOf _wrhs] call owr_fn_getUpgradeCostStr;
								_costString = [_resourceArray] call owr_fn_getCostStr;
								_owr_action2 ctrlSetTooltip format["Upgrade to advanced warehouse %1", _costString];

								_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action2 ctrladdeventhandler ["buttonclick", {
									_warehouseToUse = (curatorSelected select 0) select 0;

									// get the resources needed
									_resourceArray = [typeOf _warehouseToUse] call owr_fn_getUpgradeCostStr;
									if ([_resourceArray, _warehouseToUse] call owr_fn_wrhsCostCheck) then {
										// we have enough resource in warehouse, take them out
										[_resourceArray, _warehouseToUse] call owr_fn_wrhsResourceTake;
										// let the upgrade begin
										_warehouseToUse setVariable ["ow_build_upgrade", true, true];
										playSound "owr_ui_button_confirm";
									} else {
										playSound "owr_ui_button_cancel";
									};
								}];	



								if (count (crew _wrhs) > 0) then {
									_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
									_owr_action1 ctrlSetTooltip "Order all to exit building (G)";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_warehouseToUse = (curatorSelected select 0) select 0;
										{
											[_x] call owr_fn_getOutOfVehicle;
										} forEach (crew _warehouseToUse);
										playSound "owr_ui_button_confirm";
									}];	
								} else {
									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};
							} else {
								_owr_action9 ctrlSetText "";
								_owr_action9 ctrlSetTooltip "";
								_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action8 ctrlSetText "";
								_owr_action8 ctrlSetTooltip "";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action7 ctrlSetText "";
								_owr_action7 ctrlSetTooltip "";
								_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
								_owr_action6 ctrlSetTooltip "Deconstruct building";
								_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action6 ctrladdeventhandler ["buttonclick", {
									_warehouseToUse = (curatorSelected select 0) select 0;
									_warehouseToUse setVariable ["ow_build_deconstruct", true, true];
									_warehouseToUse setVariable ["ow_build_ready", false, true];
									playSound "owr_ui_button_confirm";
								}];

								_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
								_owr_action5 ctrlSetTooltip "Lights On/Off";
								_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action5 ctrladdeventhandler ["buttonclick", {
									_wrhsToWorkWith = (curatorSelected select 0) select 0;
									_lightState = _wrhsToWorkWith getVariable "ow_build_light";
									if (_lightState) then {
										_wrhsToWorkWith setVariable ["ow_build_light", false, true];
									} else {
										_wrhsToWorkWith setVariable ["ow_build_light", true, true];
									};
									playSound "owr_ui_button_confirm";
								}];

								_owr_action4 ctrlSetText "";
								_owr_action4 ctrlSetTooltip "";
								_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

								// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
								_someoneNotAWorker = false;
								{
									if (_x getVariable "ow_class" != 1) then {
										_someoneNotAWorker = true;
									};
								} forEach (crew _wrhs);

								if (_someoneNotAWorker) then {
									_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makeworker_ca.paa";
									_owr_action3 ctrlSetTooltip "Change class to worker";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_wrhsToWorkWith = (curatorSelected select 0) select 0;
										{
											_x setVariable ["ow_class", 1, true];
											//[_x, 1] call owr_fn_changeClassGear;
											[_x, 1] remoteExec ["owr_fn_changeClassGear", owner _owman];
										} forEach (crew _wrhsToWorkWith);
										playSound "owr_ui_button_confirm";
									}];
								} else {
									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
								};

								_owr_action2 ctrlSetText "";
								_owr_action2 ctrlSetTooltip "";
								_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

								if (count (crew _wrhs) > 0) then {
									_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
									_owr_action1 ctrlSetTooltip "Order all to exit building (G)";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_warehouseToUse = (curatorSelected select 0) select 0;
										{
											[_x] call owr_fn_getOutOfVehicle;
										} forEach (crew _warehouseToUse);
										playSound "owr_ui_button_confirm";
									}];	
								} else {
									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};
							};
						} else {
							_owr_action9 ctrlSetText "";
							_owr_action9 ctrlSetTooltip "";
							_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action8 ctrlSetText "";
							_owr_action8 ctrlSetTooltip "";
							_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action7 ctrlSetText "";
							_owr_action7 ctrlSetTooltip "";
							_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action6 ctrlSetText "";
							_owr_action6 ctrlSetTooltip "";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
							_owr_action5 ctrlSetTooltip "Lights On/Off";
							_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action5 ctrladdeventhandler ["buttonclick", {
								_wrhsToWorkWith = (curatorSelected select 0) select 0;
								_lightState = _wrhsToWorkWith getVariable "ow_build_light";
								if (_lightState) then {
									_wrhsToWorkWith setVariable ["ow_build_light", false, true];
								} else {
									_wrhsToWorkWith setVariable ["ow_build_light", true, true];
								};
								playSound "owr_ui_button_confirm";
							}];

							_owr_action4 ctrlSetText "";
							_owr_action4 ctrlSetTooltip "";
							_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action3 ctrlSetText "";
							_owr_action3 ctrlSetTooltip "";
							_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action2 ctrlSetText "";
							_owr_action2 ctrlSetTooltip "";
							_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action1 ctrlSetText "";
							_owr_action1 ctrlSetTooltip "";
							_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
						};
					};



					// AM - FACTORY
					if ((_selected select 0) isKindOf "factory_am") then {
						_factory = (_selected select 0);
						{
							_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
							_x ctrlSetActiveColor [1, 1, 1, 1];
						} forEach _actionButtons;

						if (_factory getVariable "ow_build_ready") then {
							switch (_factory getVariable "ow_factory_buildmode") do {
								case 0: {
									// default state
									if (!(_factory getVariable "ow_build_upgrade")) then {
										_owr_action9 ctrlSetText "";
										_owr_action9 ctrlSetTooltip "";
										_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

										if (isNull (_factory getVariable "ow_build_wrhs")) then {
											_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
											_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_objectToSearchAround = (curatorSelected select 0) select 0;
												_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_am"], 150];
												if ((count _warehousesAvailable) > 0) then {
													_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
												};
											}];
										} else {
											_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
											_owr_action8 ctrlSetTooltip "Warehouse connected";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
											_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
										};

										_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
										_owr_action7 ctrlSetTooltip "Lights On/Off";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action7 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_lightState = _factoryToUse getVariable "ow_build_light";
											if (_lightState) then {
												_factoryToUse setVariable ["ow_build_light", false, true];
											} else {
												_factoryToUse setVariable ["ow_build_light", true, true];
											};
											playSound "owr_ui_button_confirm";
										}];

										_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_man_start_ca";
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
										if (((_factory getVariable "ow_factory_lasttemplate") select 0) != -1) then {
											_resourceArray = [(_factory getVariable "ow_factory_lasttemplate")] call owr_fn_getAMVehicleCost;
											_costString = [_resourceArray] call owr_fn_getCostStr;
											_owr_action6 ctrlSetTooltip format ["Manufacture last built vehicle type %1", _costString];	

											_owr_action6 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												// set last piece of vehicle template
												_tempTemplateArray = _factoryToUse getVariable "ow_factory_lasttemplate";

												// start manufacturing / do nothing if there is not enough resources
												_resourceArray = [_tempTemplateArray] call owr_fn_getAMVehicleCost;
												if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// this will trigger manufacturing process
													_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
													// switch gui
													_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];
										} else {
											_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action6 ctrlSetTooltip "Manufacture last built vehicle type ( no template available )";
										};

										_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_man_start_ca";
										_owr_action5 ctrlSetTooltip "Manufacture vehicle";
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action5 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 9, true];
											playSound "owr_ui_button_confirm";
										}];

										_owr_action4 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
										_owr_action4 ctrlSetTooltip "Deconstruct building";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action4 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_build_deconstruct", true, true];
											_factoryToUse setVariable ["ow_build_ready", false, true];
											playSound "owr_ui_button_confirm";
										}];

										// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
										_someoneNotAMechanic = false;
										{
											if (_x getVariable "ow_class" != 2) then {
												_someoneNotAMechanic = true;
											};
										} forEach (crew _factory);

										if (_someoneNotAMechanic) then {
											_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makemechanic_ca.paa";
											_owr_action3 ctrlSetTooltip "Change class to mechanic";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_factoryToWorkWith = (curatorSelected select 0) select 0;
												{
													_x setVariable ["ow_class", 2, true];
													//[_x, 2] call owr_fn_changeClassGear;
													[_x, 2] remoteExec ["owr_fn_changeClassGear", owner _owman];
												} forEach (crew _factoryToWorkWith);
												playSound "owr_ui_button_confirm";
											}];
										} else {
											_owr_action3 ctrlSetText "";
											_owr_action3 ctrlSetTooltip "";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										};


										_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_bupgrade_ca.paa";

										_resourceArray = ["factory_am"] call owr_fn_getUpgradeCostStr;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action2 ctrlSetTooltip format["Upgrade to advanced factory %1", _costString];

										_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// get the resources needed
											_resourceArray = ["factory_am"] call owr_fn_getUpgradeCostStr;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// let the upgrade begin
												_factoryToUse setVariable ["ow_build_upgrade", true, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	


										if (count (crew _factory) > 0) then {
											_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
											_owr_action1 ctrlSetTooltip "Order all to exit building (G)";
											_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action1 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												{
													[_x] call owr_fn_getOutOfVehicle;
												} forEach (crew _factoryToUse);
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action1 ctrlSetText "";
											_owr_action1 ctrlSetTooltip "";
											_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										};
									} else {
										_owr_action9 ctrlSetText "";
										_owr_action9 ctrlSetTooltip "";
										_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

										if (isNull (_factory getVariable "ow_build_wrhs")) then {
											_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
											_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_objectToSearchAround = (curatorSelected select 0) select 0;
												_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_am"], 150];
												if ((count _warehousesAvailable) > 0) then {
													_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
												};
											}];
										} else {
											_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
											_owr_action8 ctrlSetTooltip "Warehouse connected";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
											_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
										};

										_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
										_owr_action7 ctrlSetTooltip "Lights On/Off";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action7 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_lightState = _factoryToUse getVariable "ow_build_light";
											if (_lightState) then {
												_factoryToUse setVariable ["ow_build_light", false, true];
											} else {
												_factoryToUse setVariable ["ow_build_light", true, true];
											};
											playSound "owr_ui_button_confirm";
										}];

										_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_man_start_ca";
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
										if (((_factory getVariable "ow_factory_lasttemplate") select 0) != -1) then {
											_resourceArray = [(_factory getVariable "ow_factory_lasttemplate")] call owr_fn_getAMVehicleCost;
											_costString = [_resourceArray] call owr_fn_getCostStr;
											_owr_action6 ctrlSetTooltip format ["Manufacture last built vehicle type %1", _costString];	

											_owr_action6 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												// set last piece of vehicle template
												_tempTemplateArray = _factoryToUse getVariable "ow_factory_lasttemplate";

												// start manufacturing / do nothing if there is not enough resources
												_resourceArray = [_tempTemplateArray] call owr_fn_getAMVehicleCost;
												if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// this will trigger manufacturing process
													_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
													// switch gui
													_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];
										} else {
											_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action6 ctrlSetTooltip "Manufacture last built vehicle type ( no template available )";
										};

										_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_man_start_ca";
										_owr_action5 ctrlSetTooltip "Manufacture vehicle";
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action5 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 3, true];
											playSound "owr_ui_button_confirm";
										}];	

										_owr_action4 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
										_owr_action4 ctrlSetTooltip "Deconstruct building";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action4 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_build_deconstruct", true, true];
											_factoryToUse setVariable ["ow_build_ready", false, true];
											playSound "owr_ui_button_confirm";
										}];

										// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
										_someoneNotAMechanic = false;
										{
											if (_x getVariable "ow_class" != 2) then {
												_someoneNotAMechanic = true;
											};
										} forEach (crew _factory);

										if (_someoneNotAMechanic) then {
											_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makemechanic_ca.paa";
											_owr_action3 ctrlSetTooltip "Change class to mechanic";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_factoryToWorkWith = (curatorSelected select 0) select 0;
												{
													_x setVariable ["ow_class", 2, true];
													//[_x, 2] call owr_fn_changeClassGear;
													[_x, 2] remoteExec ["owr_fn_changeClassGear", owner _owman];
												} forEach (crew _factoryToWorkWith);
												playSound "owr_ui_button_confirm";
											}];
										} else {
											_owr_action3 ctrlSetText "";
											_owr_action3 ctrlSetTooltip "";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										};

										_owr_action2 ctrlSetText "\owr\ui\data\buildings\icon_sideupg_ca";
										_owr_action2 ctrlSetTooltip "Side upgrades";
										_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 1, true];
											playSound "owr_ui_button_confirm";
										}];	

										if (count (crew _factory) > 0) then {
											_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
											_owr_action1 ctrlSetTooltip "Order all to exit building (G)";
											_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action1 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												{
													[_x] call owr_fn_getOutOfVehicle;
												} forEach (crew _factoryToUse);
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action1 ctrlSetText "";
											_owr_action1 ctrlSetTooltip "";
											_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										};
									};
								};

								case 1: {
									// side upgrade state
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUpgrade = (curatorSelected select 0) select 0;
										_factoryToUpgrade setVariable ["ow_factory_buildmode", 0, true];
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";



									_owr_action7 ctrlSetText "\owr\ui\data\buildings\icon_fext_comp_ca.paa";

									_resourceArray = ["factory_ai"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action7 ctrlSetTooltip format["Add advanced ai processors %1", _costString];

									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									if (["comp", 4, bis_curator_west] call owr_fn_isResearchComplete) then {
										if (!((_factory getVariable "ow_factory_upgrades") select 4)) then {
											_owr_action7 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = ["factory_ai"] call owr_fn_getUpgradeCostStr;
												if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
													_factoryToUse setVariable ["ow_factory_side_upg", 4, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];	
										} else {
											_owr_action7 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
											_owr_action7 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
										};
									} else {
										_owr_action7 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action7 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action7 ctrlSetTooltip "Add advanced ai processors (missing tech)";
									};



									_owr_action6 ctrlSetText "\owr\ui\data\buildings\icon_fext_siberite_ca.paa";
									_owr_action6 ctrlSetTooltip "";

									_resourceArray = ["factory_sib"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action6 ctrlSetTooltip format["Add alaskite motor parts storage %1", _costString];

									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									if (["siberite", 4, bis_curator_west] call owr_fn_isResearchComplete) then {
										if (!((_factory getVariable "ow_factory_upgrades") select 3)) then {
											_owr_action6 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = ["factory_sib"] call owr_fn_getUpgradeCostStr;
												if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
													_factoryToUse setVariable ["ow_factory_side_upg", 3, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];
										} else {
											_owr_action6 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
											_owr_action6 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
										};
									} else {
										_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action6 ctrlSetTooltip "Add alaskite motor parts storage (missing tech)";
									};



									_owr_action5 ctrlSetText "";	// \owr\ui\data\buildings\icon_fext_radar_ca.paa
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";



									_owr_action4 ctrlSetText "";	// \owr\ui\data\buildings\icon_fext_ncom_ca.paa
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";



									_owr_action3 ctrlSetText "\owr\ui\data\buildings\icon_fext_rocket_ca.paa";

									_resourceArray = ["factory_rocket"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action3 ctrlSetTooltip format["Add rocket launcher parts storage %1", _costString];

									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 5, bis_curator_west] call owr_fn_isResearchComplete) then {
										if (!((_factory getVariable "ow_factory_upgrades") select 2)) then {
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = ["factory_rocket"] call owr_fn_getUpgradeCostStr;
												if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
													_factoryToUse setVariable ["ow_factory_side_upg", 2, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];
										} else {
											_owr_action3 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
											_owr_action3 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
										};
									} else {
										_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action3 ctrlSetTooltip "Add rocket launcher parts storage (missing tech)";
									};




									_owr_action2 ctrlSetText "\owr\ui\data\buildings\icon_fext_gun_ca.paa";

									_resourceArray = ["factory_cannon"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action2 ctrlSetTooltip format["Add cannon parts storage %1", _costString];

									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 4, bis_curator_west] call owr_fn_isResearchComplete) then {
										if (!((_factory getVariable "ow_factory_upgrades") select 1)) then {
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = ["factory_cannon"] call owr_fn_getUpgradeCostStr;
												if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
													_factoryToUse setVariable ["ow_factory_side_upg", 1, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];	
										} else {
											_owr_action2 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
											_owr_action2 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
										};
									} else {
										_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetTooltip "Add cannon parts storage (missing tech)";
									};



									_owr_action1 ctrlSetText "\owr\ui\data\buildings\icon_fext_tracked_ca.paa";

									_resourceArray = ["factory_track"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action1 ctrlSetTooltip format["Add tracked chassis parts storage %1", _costString];

									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (!((_factory getVariable "ow_factory_upgrades") select 0)) then {
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// get the resources needed
											_resourceArray = ["factory_track"] call owr_fn_getUpgradeCostStr;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// let the upgrade begin
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												_factoryToUse setVariable ["ow_factory_side_upg", 0, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	
									} else {
										_owr_action1 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action1 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									};
								};

								case 2: {
									// progress state
									_owr_action9 ctrlSetText "";
									_owr_action9 ctrlSetTooltip "";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

									if (isNull (_factory getVariable "ow_build_wrhs")) then {
										_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
										_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_objectToSearchAround = (curatorSelected select 0) select 0;
											_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_am"], 150];
											if ((count _warehousesAvailable) > 0) then {
												_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
											};
										}];
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
										_owr_action8 ctrlSetTooltip "Warehouse connected";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									};

									_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
									_owr_action7 ctrlSetTooltip "Lights On/Off";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_lightState = _factoryToUse getVariable "ow_build_light";
										if (_lightState) then {
											_factoryToUse setVariable ["ow_build_light", false, true];
										} else {
											_factoryToUse setVariable ["ow_build_light", true, true];
										};
										playSound "owr_ui_button_confirm";
									}];

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
									_someoneNotAMechanic = false;
									{
										if (_x getVariable "ow_class" != 2) then {
											_someoneNotAMechanic = true;
										};
									} forEach (crew _factory);

									if (_someoneNotAMechanic) then {
										_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makemechanic_ca.paa";
										_owr_action3 ctrlSetTooltip "Change class to mechanic";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_factoryToWorkWith = (curatorSelected select 0) select 0;
											{
												_x setVariable ["ow_class", 2, true];
												//[_x, 2] call owr_fn_changeClassGear;
												[_x, 2] remoteExec ["owr_fn_changeClassGear", owner _owman];
											} forEach (crew _factoryToWorkWith);
											playSound "owr_ui_button_confirm";
										}];
									} else {
										_owr_action3 ctrlSetText "";
										_owr_action3 ctrlSetTooltip "";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									};

									_owr_action2 ctrlSetText "";
									_owr_action2 ctrlSetTooltip "";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};

								case 3: {
									// VEHICLE MANUFACTURING
									// chassis
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "\owr\ui\data\buildings\icon_fext_tracked_ca.paa";
									_owr_action5 ctrlSetTooltip "Tracked chassis (heavy)";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									if (((_factory getVariable "ow_factory_upgrades") select 0)) then {
										_owr_action5 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 4, true];
											_factoryToUse setVariable ["ow_factory_template", [3,-1,-1,-1], true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!((_factory getVariable "ow_factory_upgrades") select 0)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										_owr_action5 ctrlSetTooltip format["Tracked chassis (heavy) (%1)", _reasons];
									};

									_owr_action4 ctrlSetText "\owr\ui\data\actions\icon_man_start_ca.paa";
									_owr_action4 ctrlSetTooltip "Wheeled chassis (medium)";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 4, true];
										_factoryToUse setVariable ["ow_factory_template", [1,-1,-1,-1], true];
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_morhp_ca.paa";
									_owr_action3 ctrlSetTooltip "Morphling chassis";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (["comp", 5, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 4, true];
											_factoryToUse setVariable ["ow_factory_template", [4,-1,-1,-1], true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action3 ctrlSetTooltip "Morphling chassis (missing tech)";
									};

									_owr_action2 ctrlSetText "\owr\ui\data\buildings\icon_fext_tracked_ca.paa";
									_owr_action2 ctrlSetTooltip "Tracked chassis (medium)";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (((_factory getVariable "ow_factory_upgrades") select 0)) then {
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 4, true];
											_factoryToUse setVariable ["ow_factory_template", [2,-1,-1,-1], true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!((_factory getVariable "ow_factory_upgrades") select 0)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										_owr_action2 ctrlSetTooltip format["Tracked chassis (medium) (%1)", _reasons];
									};

									_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_man_start_ca.paa";
									_owr_action1 ctrlSetTooltip "Wheeled chassis (light)";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 4, true];
										_factoryToUse setVariable ["ow_factory_template", [0,-1,-1,-1], true];
										playSound "owr_ui_button_confirm";
									}];	
								};

								case 4: {
									// VEHICLE MANUFACTURING
									// engine
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 3, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_rescat_siberite_ca.paa";
									_owr_action3 ctrlSetTooltip "Siberite motor";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (["siberite", 4, bis_curator_west] call owr_fn_isResearchComplete && (((_factory getVariable "ow_factory_template") select 0) != 0) && ((_factory getVariable "ow_factory_upgrades") select 3)) then {
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 5, true];
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";
											_tempTemplateArray set [1, 1];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_reasons = "";
										if (!(["siberite", 4, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if ((((_factory getVariable "ow_factory_template") select 0) == 0)) then {
											_reasons = _reasons + " chassis too light ";
										};
										if (!((_factory getVariable "ow_factory_upgrades") select 3)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										_owr_action3 ctrlSetTooltip format["Siberite motor (%1)", _reasons];
									};

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_moil_ca.paa";
									_owr_action2 ctrlSetTooltip "Combustion motor";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 4, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 5, true];
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";
											_tempTemplateArray set [1, 0];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetTooltip "Combustion motor (missing tech)";
									};

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_msol_ca.paa";
									_owr_action1 ctrlSetTooltip "Electric motor";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 7, bis_curator_west] call owr_fn_isResearchComplete && ((((_factory getVariable "ow_factory_template") select 0) != 3) && (((_factory getVariable "ow_factory_template") select 0) != 4) && (((_factory getVariable "ow_factory_template") select 0) != 2))) then {
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 5, true];
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";
											_tempTemplateArray set [1, 2];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action1 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!(["basic", 7, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (((((_factory getVariable "ow_factory_template") select 0) == 3) || (((_factory getVariable "ow_factory_template") select 0) == 4) || (((_factory getVariable "ow_factory_template") select 0) == 2))) then {
											_reasons = _reasons + " chassis too heavy ";
										};
										_owr_action1 ctrlSetTooltip format["Electric motor (%1)", _reasons];
									};
								};

								case 5: {
									// VEHICLE MANUFACTURING
									// control
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 4, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_adv_ai_ca.paa";
									_owr_action3 ctrlSetTooltip "AI controlled";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (["comp", 4, bis_curator_west] call owr_fn_isResearchComplete && ((_factory getVariable "ow_factory_upgrades") select 4)) then {
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 6, true];
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";
											_tempTemplateArray set [2, 1];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!(["comp", 4, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (!((_factory getVariable "ow_factory_upgrades") select 4)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										_owr_action3 ctrlSetTooltip format["AI controlled (%1)", _reasons];
									};

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_remote_control_ca.paa";
									_owr_action2 ctrlSetTooltip "Remote control";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (false) then { // ["opto", 4, bis_curator_west] call owr_fn_isResearchComplete
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 6, true];
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";
											_tempTemplateArray set [2, 2];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetTooltip "Remote control ( not yet implemented )";
									};

									_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_free_ca.paa";
									_owr_action1 ctrlSetTooltip "Manual control";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 6, true];
										_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";
										_tempTemplateArray set [2, 0];
										_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
										playSound "owr_ui_button_confirm";
									}];
								};

								case 6: {
									// VEHICLE MANUFACTURING
									// function
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUpgrade = (curatorSelected select 0) select 0;
										_factoryToUpgrade setVariable ["ow_factory_buildmode", 5, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "\owr\ui\data\buildings\icon_fext_ncom_ca.paa";
									_owr_action2 ctrlSetTooltip "Engineer system";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 8, true];
										playSound "owr_ui_button_confirm";
									}];

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_rescat_weap_ca.paa";
									_owr_action1 ctrlSetTooltip "Weapon system";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 7, true];
										playSound "owr_ui_button_confirm";
									}];	
								};

								case 7: {
									// VEHICLE MANUFACTURING
									// weapons
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_dlaser_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 7]] call owr_fn_getAMVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action8 ctrlSetTooltip format ["Synchronized laser %1", _costString];

									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									if (false) then { // ["opto", 8, bis_curator_west] call owr_fn_isResearchComplete && ((((_factory getVariable "ow_factory_template") select 0) == 3) || (((_factory getVariable "ow_factory_template") select 0) == 4))
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 7]] call owr_fn_getAMVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 7];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	
									} else {
										_owr_action8 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action8 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = " not implemented yet ";
										if (!(["opto", 8, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (((((_factory getVariable "ow_factory_template") select 0) != 3) && (((_factory getVariable "ow_factory_template") select 0) != 4))) then {
											_reasons = _reasons + " chassis too light ";
										};
										_owr_action8 ctrlSetTooltip format["Synchronized laser (%1)", _reasons];
									};



									_owr_action7 ctrlSetText "\owr\ui\data\research\icon_res_laser_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 6]] call owr_fn_getAMVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action7 ctrlSetTooltip format ["Laser %1", _costString];

									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									if (["opto", 7, bis_curator_west] call owr_fn_isResearchComplete && (((_factory getVariable "ow_factory_template") select 0) != 0)) then {
										_owr_action7 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 6]] call owr_fn_getAMVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 6];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];
									} else {
										_owr_action7 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action7 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!(["weap", 7, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (((_factory getVariable "ow_factory_template") select 0) == 0) then {
											_reasons = _reasons + " chassis too light ";
										};
										_owr_action7 ctrlSetTooltip format["Laser (%1)", _reasons];
									};



									_owr_action6 ctrlSetText "\owr\ui\data\research\icon_res_heavy_gun_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 5]] call owr_fn_getAMVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action6 ctrlSetTooltip format ["Heavy cannon %1", _costString];

									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 6, bis_curator_west] call owr_fn_isResearchComplete && ((_factory getVariable "ow_factory_upgrades") select 1) && ((((_factory getVariable "ow_factory_template") select 0) == 3) || (((_factory getVariable "ow_factory_template") select 0) == 4))) then {
										_owr_action6 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 5]] call owr_fn_getAMVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 5];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	
									} else {
										_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!(["weap", 6, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (!((_factory getVariable "ow_factory_upgrades") select 1)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										if (((((_factory getVariable "ow_factory_template") select 0) != 3) && (((_factory getVariable "ow_factory_template") select 0) != 4))) then {
											_reasons = _reasons + " chassis too light ";
										};
										_owr_action6 ctrlSetTooltip format["Heavy cannon (%1)", _reasons];
									};



									_owr_action5 ctrlSetText "\owr\ui\data\research\icon_res_rocket_launcher_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 4]] call owr_fn_getAMVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action5 ctrlSetTooltip format ["Vehicle rocket launcher %1", _costString];

									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 5, bis_curator_west] call owr_fn_isResearchComplete && ((_factory getVariable "ow_factory_upgrades") select 2) && (((_factory getVariable "ow_factory_template") select 0) != 0)) then {
										_owr_action5 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 4]] call owr_fn_getAMVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 4];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	
									} else {
										_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!(["weap", 5, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (!((_factory getVariable "ow_factory_upgrades") select 2)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										if (((_factory getVariable "ow_factory_template") select 0) == 0) then {
											_reasons = _reasons + " chassis too light ";
										};
										_owr_action5 ctrlSetTooltip format["Vehicle rocket launcher (%1)", _reasons];
									};



									_owr_action4 ctrlSetText "\owr\ui\data\research\icon_res_heavy_gun_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 3]] call owr_fn_getAMVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action4 ctrlSetTooltip format ["Dual cannon %1", _costString];

									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 4, bis_curator_west] call owr_fn_isResearchComplete && ((_factory getVariable "ow_factory_upgrades") select 1) && (((_factory getVariable "ow_factory_template") select 0) != 0)) then {
										_owr_action4 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 3]] call owr_fn_getAMVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 3];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	
									} else {
										_owr_action4 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action4 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!(["weap", 4, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (!((_factory getVariable "ow_factory_upgrades") select 1)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										if (((_factory getVariable "ow_factory_template") select 0) == 0) then {
											_reasons = _reasons + " chassis too light ";
										};
										_owr_action4 ctrlSetTooltip format["Dual cannon (%1)", _reasons];
									};



									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_rot_mgun_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 2]] call owr_fn_getAMVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action3 ctrlSetTooltip format ["Minigun %1", _costString];

									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 3, bis_curator_west] call owr_fn_isResearchComplete && (((_factory getVariable "ow_factory_template") select 0) != 0) && (((_factory getVariable "ow_factory_template") select 0) != 3) && (((_factory getVariable "ow_factory_template") select 0) != 4)) then {
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 2]] call owr_fn_getAMVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 2];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	
									} else {
										_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!(["weap", 3, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (((_factory getVariable "ow_factory_template") select 0) == 0) then {
											_reasons = _reasons + " chassis too small ";
										};
										if (((_factory getVariable "ow_factory_template") select 0) == 3) then {
											_reasons = _reasons + " weapon too small for chassis ";
										};
										if (((_factory getVariable "ow_factory_template") select 0) == 4) then {
											_reasons = _reasons + " weapon too small for chassis ";
										};
										_owr_action3 ctrlSetTooltip format["Minigun (%1)", _reasons];
									};



									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_gun_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 1]] call owr_fn_getAMVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action2 ctrlSetTooltip format ["Light cannon %1", _costString];

									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 4, bis_curator_west] call owr_fn_isResearchComplete && ((_factory getVariable "ow_factory_upgrades") select 1) && (((_factory getVariable "ow_factory_template") select 0) != 3) && (((_factory getVariable "ow_factory_template") select 0) != 4)) then {
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 1]] call owr_fn_getAMVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 1];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	
									} else {
										_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!(["weap", 4, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (!((_factory getVariable "ow_factory_upgrades") select 1)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										if (((_factory getVariable "ow_factory_template") select 0) == 3) then {
											_reasons = _reasons + " weapon too small for chassis ";
										};
										if (((_factory getVariable "ow_factory_template") select 0) == 4) then {
											_reasons = _reasons + " weapon too small for chassis ";
										};
										_owr_action2 ctrlSetTooltip format["Light cannon (%1)", _reasons];
									};



									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_gun_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 0]] call owr_fn_getAMVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action1 ctrlSetTooltip format ["Machine gun %1", _costString];

									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if ((((_factory getVariable "ow_factory_template") select 0) != 3) && (((_factory getVariable "ow_factory_template") select 0) != 4)) then {
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 0]] call owr_fn_getAMVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 0];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];
									} else {
										_owr_action1 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (((_factory getVariable "ow_factory_template") select 0) == 3) then {
											_reasons = _reasons + " weapon too small for chassis ";
										};
										if (((_factory getVariable "ow_factory_template") select 0) == 4) then {
											_reasons = _reasons + " weapon too small for chassis ";
										};
										_owr_action1 ctrlSetTooltip format["Machine gun (%1)", _reasons];
									};
								};

								case 8: {
									// VEHICLE MANUFACTURING
									// engineer stuff
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUpgrade = (curatorSelected select 0) select 0;
										_factoryToUpgrade setVariable ["ow_factory_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";


									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_ai_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 10]] call owr_fn_getAMVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action3 ctrlSetTooltip format ["Crane %1", _costString];

									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (false) then { // ((_factory getVariable "ow_factory_template") select 0) != 0
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 10]] call owr_fn_getAMVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 10];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];
									} else {
										_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = " not implemented yet ";
										if (((_factory getVariable "ow_factory_template") select 0) == 0) then {
											_reasons = _reasons + " chassis too light ";
										};

										_owr_action3 ctrlSetTooltip format["Crane (%1)", _reasons];
									};



									_owr_action2 ctrlSetText "\owr\ui\data\buildings\icon_fext_radar_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 9]] call owr_fn_getAMVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action2 ctrlSetTooltip format ["Radar %1", _costString];

									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["opto", 3, bis_curator_west] call owr_fn_isResearchComplete && (((_factory getVariable "ow_factory_template") select 0) != 3) && (((_factory getVariable "ow_factory_template") select 0) != 4)) then {
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 9]] call owr_fn_getAMVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 9];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	
									} else {
										_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!(["opto", 3, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (((_factory getVariable "ow_factory_template") select 0) == 3) then {
											_reasons = _reasons + " utility too small for chassis ";
										};
										if (((_factory getVariable "ow_factory_template") select 0) == 4) then {
											_reasons = _reasons + " utility too small for chassis ";
										};
										_owr_action2 ctrlSetTooltip format["Radar (%1)", _reasons];
									};



									_owr_action1 ctrlSetText "\owr\ui\data\buildings\icon_fext_ncom_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 8]] call owr_fn_getAMVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action1 ctrlSetTooltip format ["Resource storage %1", _costString];

									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (((_factory getVariable "ow_factory_template") select 0) != 0) then {
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 8]] call owr_fn_getAMVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 8];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];
									} else {
										_owr_action1 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (((_factory getVariable "ow_factory_template") select 0) == 0) then {
											_reasons = _reasons + " chassis too light ";
										};

										_owr_action1 ctrlSetTooltip format["Resource storage (%1)", _reasons];
									};							
								};

								case 9: {
									// not upgraded factory - manufacturing
									// chassis
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "\owr\ui\data\actions\icon_man_start_ca.paa";
									_owr_action4 ctrlSetTooltip "Wheeled chassis (medium)";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action4 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 10, true];
										_factoryToUse setVariable ["ow_factory_template", [1,-1,-1,-1], true];
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "";
									_owr_action2 ctrlSetTooltip "";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_man_start_ca.paa";
									_owr_action1 ctrlSetTooltip "Wheeled chassis (light)";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 10, true];
										_factoryToUse setVariable ["ow_factory_template", [0,-1,-1,-1], true];
										playSound "owr_ui_button_confirm";
									}];	
								};
								case 10: {
									// engine
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 9, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_moil_ca.paa";
									_owr_action2 ctrlSetTooltip "Combustion motor";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 4, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 11, true];
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";
											_tempTemplateArray set [1, 0];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetTooltip "Combustion motor (missing tech)";
									};

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_msol_ca.paa";
									_owr_action1 ctrlSetTooltip "Electric motor";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 7, bis_curator_west] call owr_fn_isResearchComplete && ((((_factory getVariable "ow_factory_template") select 0) != 3) && (((_factory getVariable "ow_factory_template") select 0) != 4))) then {
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 11, true];
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";
											_tempTemplateArray set [1, 2];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action1 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!(["basic", 7, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (((((_factory getVariable "ow_factory_template") select 0) == 3) || (((_factory getVariable "ow_factory_template") select 0) == 4))) then {
											_reasons = _reasons + " chassis too heavy ";
										};
										_owr_action1 ctrlSetTooltip format["Electric motor (%1)", _reasons];
									};
								};
								case 11: {
									// control
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 10, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "";
									_owr_action2 ctrlSetTooltip "";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_free_ca.paa";
									_owr_action1 ctrlSetTooltip "Manual control";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 12, true];
										_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";
										_tempTemplateArray set [2, 0];
										_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
										playSound "owr_ui_button_confirm";
									}];
								};
								case 12: {
									// mounted stuff
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUpgrade = (curatorSelected select 0) select 0;
										_factoryToUpgrade setVariable ["ow_factory_buildmode", 11, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "\owr\ui\data\buildings\icon_fext_ncom_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 8]] call owr_fn_getAMVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action3 ctrlSetTooltip format ["Resource storage %1", _costString];

									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (((_factory getVariable "ow_factory_template") select 0) != 0) then {
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 8]] call owr_fn_getAMVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 8];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];
									} else {
										_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (((_factory getVariable "ow_factory_template") select 0) == 0) then {
											_reasons = _reasons + " chassis too light ";
										};

										_owr_action3 ctrlSetTooltip format["Resource storage (%1)", _reasons];
									};	




									_owr_action2 ctrlSetText "\owr\ui\data\buildings\icon_fext_radar_ca.paa";
									_owr_action2 ctrlSetTooltip "";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 9]] call owr_fn_getAMVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action2 ctrlSetTooltip format ["Radar %1", _costString];

									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["opto", 3, bis_curator_west] call owr_fn_isResearchComplete) then {
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 9]] call owr_fn_getAMVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 9];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	
									} else {
										_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetTooltip "Radar (missing tech)";
									};



									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_gun_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 0]] call owr_fn_getAMVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action1 ctrlSetTooltip format ["Machine gun %1", _costString];

									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										// set last piece of vehicle template
										_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

										// start manufacturing / do nothing if there is not enough resources
										_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 0]] call owr_fn_getAMVehicleCost;
										if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
											// we have enough resource in warehouse, take them out
											[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
											// this will trigger manufacturing process
											_tempTemplateArray set [3, 0];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											// switch gui
											_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
											playSound "owr_ui_button_confirm";
										} else {
											playSound "owr_ui_button_cancel";
										};
									}];
								};
							};
						} else {
							_owr_action9 ctrlSetText "";
							_owr_action9 ctrlSetTooltip "";
							_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

							if (isNull (_factory getVariable "ow_build_wrhs")) then {
								_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
								_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action8 ctrladdeventhandler ["buttonclick", {
									_objectToSearchAround = (curatorSelected select 0) select 0;
									_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_am"], 150];
									if ((count _warehousesAvailable) > 0) then {
										_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
									};
								}];
							} else {
								_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
								_owr_action8 ctrlSetTooltip "Warehouse connected";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
								_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
							};

							_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
							_owr_action7 ctrlSetTooltip "Lights On/Off";
							_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action7 ctrladdeventhandler ["buttonclick", {
								_factoryToUse = (curatorSelected select 0) select 0;
								_lightState = _factoryToUse getVariable "ow_build_light";
								if (_lightState) then {
									_factoryToUse setVariable ["ow_build_light", false, true];
								} else {
									_factoryToUse setVariable ["ow_build_light", true, true];
								};
								playSound "owr_ui_button_confirm";
							}];

							_owr_action6 ctrlSetText "";
							_owr_action6 ctrlSetTooltip "";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action5 ctrlSetText "";
							_owr_action5 ctrlSetTooltip "";
							_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action4 ctrlSetText "";
							_owr_action4 ctrlSetTooltip "";
							_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action3 ctrlSetText "";
							_owr_action3 ctrlSetTooltip "";
							_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action2 ctrlSetText "";
							_owr_action2 ctrlSetTooltip "";
							_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action1 ctrlSetText "";
							_owr_action1 ctrlSetTooltip "";
							_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
						};
					};
					// RU - FACTORY
					if ((_selected select 0) isKindOf "factory_ru") then {
						_factory = (_selected select 0);
						{
							_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
							_x ctrlSetActiveColor [1, 1, 1, 1];
						} forEach _actionButtons;

						if (_factory getVariable "ow_build_ready") then {
							switch (_factory getVariable "ow_factory_buildmode") do {
								case 0: {
									// default state
									if (!(_factory getVariable "ow_build_upgrade")) then {
										_owr_action9 ctrlSetText "";
										_owr_action9 ctrlSetTooltip "";
										_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

										if (isNull (_factory getVariable "ow_build_wrhs")) then {
											_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
											_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_objectToSearchAround = (curatorSelected select 0) select 0;
												_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ru"], 150];
												if ((count _warehousesAvailable) > 0) then {
													_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
												};
											}];
										} else {
											_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
											_owr_action8 ctrlSetTooltip "Warehouse connected";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
											_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
										};

										_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
										_owr_action7 ctrlSetTooltip "Lights On/Off";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action7 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_lightState = _factoryToUse getVariable "ow_build_light";
											if (_lightState) then {
												_factoryToUse setVariable ["ow_build_light", false, true];
											} else {
												_factoryToUse setVariable ["ow_build_light", true, true];
											};
											playSound "owr_ui_button_confirm";
										}];

										_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_man_start_ca";
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
										if (((_factory getVariable "ow_factory_lasttemplate") select 0) != -1) then {
											_resourceArray = [(_factory getVariable "ow_factory_lasttemplate")] call owr_fn_getRUVehicleCost;
											_costString = [_resourceArray] call owr_fn_getCostStr;
											_owr_action6 ctrlSetTooltip format ["Manufacture last built vehicle type %1", _costString];	

											_owr_action6 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												// set last piece of vehicle template
												_tempTemplateArray = _factoryToUse getVariable "ow_factory_lasttemplate";

												// start manufacturing / do nothing if there is not enough resources
												_resourceArray = [_tempTemplateArray] call owr_fn_getRUVehicleCost;
												if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// this will trigger manufacturing process
													_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
													// switch gui
													_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];
										} else {
											_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action6 ctrlSetTooltip "Manufacture last built vehicle type ( no template available )";
										};

										_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_man_start_ca";
										_owr_action5 ctrlSetTooltip "Manufacture vehicle";
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action5 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 9, true];
											playSound "owr_ui_button_confirm";
										}];

										_owr_action4 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
										_owr_action4 ctrlSetTooltip "Deconstruct building";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action4 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_build_deconstruct", true, true];
											_factoryToUse setVariable ["ow_build_ready", false, true];
											playSound "owr_ui_button_confirm";
										}];

										// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
										_someoneNotAMechanic = false;
										{
											if (_x getVariable "ow_class" != 2) then {
												_someoneNotAMechanic = true;
											};
										} forEach (crew _factory);

										if (_someoneNotAMechanic) then {
											_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makemechanic_ca.paa";
											_owr_action3 ctrlSetTooltip "Change class to mechanic";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_factoryToWorkWith = (curatorSelected select 0) select 0;
												{
													_x setVariable ["ow_class", 2, true];
													//[_x, 2] call owr_fn_changeClassGear;
													[_x, 2] remoteExec ["owr_fn_changeClassGear", owner _owman];
												} forEach (crew _factoryToWorkWith);
												playSound "owr_ui_button_confirm";
											}];
										} else {
											_owr_action3 ctrlSetText "";
											_owr_action3 ctrlSetTooltip "";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										};


										_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_bupgrade_ca.paa";

										_resourceArray = ["factory_ru"] call owr_fn_getUpgradeCostStr;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action2 ctrlSetTooltip format["Upgrade to advanced factory %1", _costString];

										_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// get the resources needed
											_resourceArray = ["factory_ru"] call owr_fn_getUpgradeCostStr;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// let the upgrade begin
												_factoryToUse setVariable ["ow_build_upgrade", true, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	


										if (count (crew _factory) > 0) then {
											_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
											_owr_action1 ctrlSetTooltip "Order all to exit building (G)";
											_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action1 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												{
													[_x] call owr_fn_getOutOfVehicle;
												} forEach (crew _factoryToUse);
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action1 ctrlSetText "";
											_owr_action1 ctrlSetTooltip "";
											_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										};
									} else {
										_owr_action9 ctrlSetText "";
										_owr_action9 ctrlSetTooltip "";
										_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

										if (isNull (_factory getVariable "ow_build_wrhs")) then {
											_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
											_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_objectToSearchAround = (curatorSelected select 0) select 0;
												_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ru"], 150];
												if ((count _warehousesAvailable) > 0) then {
													_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
												};
											}];
										} else {
											_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
											_owr_action8 ctrlSetTooltip "Warehouse connected";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
											_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
										};

										_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
										_owr_action7 ctrlSetTooltip "Lights On/Off";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action7 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_lightState = _factoryToUse getVariable "ow_build_light";
											if (_lightState) then {
												_factoryToUse setVariable ["ow_build_light", false, true];
											} else {
												_factoryToUse setVariable ["ow_build_light", true, true];
											};
											playSound "owr_ui_button_confirm";
										}];

										_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_man_start_ca";
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
										if (((_factory getVariable "ow_factory_lasttemplate") select 0) != -1) then {
											_resourceArray = [(_factory getVariable "ow_factory_lasttemplate")] call owr_fn_getRUVehicleCost;
											_costString = [_resourceArray] call owr_fn_getCostStr;
											_owr_action6 ctrlSetTooltip format ["Manufacture last built vehicle type %1", _costString];	

											_owr_action6 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												// set last piece of vehicle template
												_tempTemplateArray = _factoryToUse getVariable "ow_factory_lasttemplate";

												// start manufacturing / do nothing if there is not enough resources
												_resourceArray = [_tempTemplateArray] call owr_fn_getRUVehicleCost;
												if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// this will trigger manufacturing process
													_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
													// switch gui
													_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];
										} else {
											_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action6 ctrlSetTooltip "Manufacture last built vehicle type ( no template available )";
										};

										_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_man_start_ca";
										_owr_action5 ctrlSetTooltip "Manufacture vehicle";
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action5 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 3, true];
											playSound "owr_ui_button_confirm";
										}];	

										_owr_action4 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
										_owr_action4 ctrlSetTooltip "Deconstruct building";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action4 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_build_deconstruct", true, true];
											_factoryToUse setVariable ["ow_build_ready", false, true];
											playSound "owr_ui_button_confirm";
										}];

										// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
										_someoneNotAMechanic = false;
										{
											if (_x getVariable "ow_class" != 2) then {
												_someoneNotAMechanic = true;
											};
										} forEach (crew _factory);

										if (_someoneNotAMechanic) then {
											_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makemechanic_ca.paa";
											_owr_action3 ctrlSetTooltip "Change class to mechanic";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_factoryToWorkWith = (curatorSelected select 0) select 0;
												{
													_x setVariable ["ow_class", 2, true];
													//[_x, 2] call owr_fn_changeClassGear;
													[_x, 2] remoteExec ["owr_fn_changeClassGear", owner _owman];
												} forEach (crew _factoryToWorkWith);
												playSound "owr_ui_button_confirm";
											}];
										} else {
											_owr_action3 ctrlSetText "";
											_owr_action3 ctrlSetTooltip "";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										};

										_owr_action2 ctrlSetText "\owr\ui\data\buildings\icon_sideupg_ca";
										_owr_action2 ctrlSetTooltip "Side upgrades";
										_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 1, true];
											playSound "owr_ui_button_confirm";
										}];	

										if (count (crew _factory) > 0) then {
											_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
											_owr_action1 ctrlSetTooltip "Order all to exit building (G)";
											_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action1 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												{
													[_x] call owr_fn_getOutOfVehicle;
												} forEach (crew _factoryToUse);
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action1 ctrlSetText "";
											_owr_action1 ctrlSetTooltip "";
											_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										};
									};
								};

								case 1: {
									// side upgrade state
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUpgrade = (curatorSelected select 0) select 0;
										_factoryToUpgrade setVariable ["ow_factory_buildmode", 0, true];
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";



									_owr_action7 ctrlSetText "\owr\ui\data\buildings\icon_fext_comp_ca.paa";

									_resourceArray = ["factory_ai"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action7 ctrlSetTooltip format["Add advanced ai processors %1", _costString];

									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									if (["comp", 4, bis_curator_east] call owr_fn_isResearchComplete) then {
										if (!((_factory getVariable "ow_factory_upgrades") select 4)) then {
											_owr_action7 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = ["factory_ai"] call owr_fn_getUpgradeCostStr;
												if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
													_factoryToUse setVariable ["ow_factory_side_upg", 4, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];	
										} else {
											_owr_action7 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
											_owr_action7 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
										};
									} else {
										_owr_action7 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action7 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action7 ctrlSetTooltip "Add advanced ai processors (missing tech)";
									};



									_owr_action6 ctrlSetText "\owr\ui\data\buildings\icon_fext_siberite_ca.paa";
									_owr_action6 ctrlSetTooltip "";

									_resourceArray = ["factory_sib"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action6 ctrlSetTooltip format["Add alaskite motor parts storage %1", _costString];

									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									if (["siberite", 4, bis_curator_east] call owr_fn_isResearchComplete) then {
										if (!((_factory getVariable "ow_factory_upgrades") select 3)) then {
											_owr_action6 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = ["factory_sib"] call owr_fn_getUpgradeCostStr;
												if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
													_factoryToUse setVariable ["ow_factory_side_upg", 3, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];
										} else {
											_owr_action6 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
											_owr_action6 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
										};
									} else {
										_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action6 ctrlSetTooltip "Add alaskite motor parts storage (missing tech)";
									};



									_owr_action5 ctrlSetText "";	// \owr\ui\data\buildings\icon_fext_radar_ca.paa
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";



									_owr_action4 ctrlSetText "";	// \owr\ui\data\buildings\icon_fext_ncom_ca.paa
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";



									_owr_action3 ctrlSetText "\owr\ui\data\buildings\icon_fext_rocket_ca.paa";

									_resourceArray = ["factory_rocket"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action3 ctrlSetTooltip format["Add rocket launcher parts storage %1", _costString];

									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 5, bis_curator_east] call owr_fn_isResearchComplete) then {
										if (!((_factory getVariable "ow_factory_upgrades") select 2)) then {
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = ["factory_rocket"] call owr_fn_getUpgradeCostStr;
												if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
													_factoryToUse setVariable ["ow_factory_side_upg", 2, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];
										} else {
											_owr_action3 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
											_owr_action3 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
										};
									} else {
										_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action3 ctrlSetTooltip "Add rocket launcher parts storage (missing tech)";
									};




									_owr_action2 ctrlSetText "\owr\ui\data\buildings\icon_fext_gun_ca.paa";

									_resourceArray = ["factory_cannon"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action2 ctrlSetTooltip format["Add cannon parts storage %1", _costString];

									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 4, bis_curator_east] call owr_fn_isResearchComplete) then {
										if (!((_factory getVariable "ow_factory_upgrades") select 1)) then {
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_factoryToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = ["factory_cannon"] call owr_fn_getUpgradeCostStr;
												if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
													_factoryToUse setVariable ["ow_factory_side_upg", 1, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];	
										} else {
											_owr_action2 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
											_owr_action2 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
										};
									} else {
										_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetTooltip "Add cannon parts storage (missing tech)";
									};



									_owr_action1 ctrlSetText "\owr\ui\data\buildings\icon_fext_tracked_ca.paa";

									_resourceArray = ["factory_track"] call owr_fn_getUpgradeCostStr;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action1 ctrlSetTooltip format["Add tracked chassis parts storage %1", _costString];

									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (!((_factory getVariable "ow_factory_upgrades") select 0)) then {
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// get the resources needed
											_resourceArray = ["factory_track"] call owr_fn_getUpgradeCostStr;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// let the upgrade begin
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												_factoryToUse setVariable ["ow_factory_side_upg", 0, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	
									} else {
										_owr_action1 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action1 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									};

								};

								case 2: {
									// progress state
									_owr_action9 ctrlSetText "";
									_owr_action9 ctrlSetTooltip "";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

									if (isNull (_factory getVariable "ow_build_wrhs")) then {
										_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
										_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_objectToSearchAround = (curatorSelected select 0) select 0;
											_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ru"], 150];
											if ((count _warehousesAvailable) > 0) then {
												_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
											};
										}];
									} else {
										_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
										_owr_action8 ctrlSetTooltip "Warehouse connected";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
										_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
									};

									_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
									_owr_action7 ctrlSetTooltip "Lights On/Off";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_lightState = _factoryToUse getVariable "ow_build_light";
										if (_lightState) then {
											_factoryToUse setVariable ["ow_build_light", false, true];
										} else {
											_factoryToUse setVariable ["ow_build_light", true, true];
										};
										playSound "owr_ui_button_confirm";
									}];

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
									_someoneNotAMechanic = false;
									{
										if (_x getVariable "ow_class" != 2) then {
											_someoneNotAMechanic = true;
										};
									} forEach (crew _factory);

									if (_someoneNotAMechanic) then {
										_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makemechanic_ca.paa";
										_owr_action3 ctrlSetTooltip "Change class to mechanic";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_factoryToWorkWith = (curatorSelected select 0) select 0;
											{
												_x setVariable ["ow_class", 2, true];
												//[_x, 2] call owr_fn_changeClassGear;
												[_x, 2] remoteExec ["owr_fn_changeClassGear", owner _owman];
											} forEach (crew _factoryToWorkWith);
											playSound "owr_ui_button_confirm";
										}];
									} else {
										_owr_action3 ctrlSetText "";
										_owr_action3 ctrlSetTooltip "";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									};

									_owr_action2 ctrlSetText "";
									_owr_action2 ctrlSetTooltip "";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};

								case 3: {
									// VEHICLE MANUFACTURING
									// chassis
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "\owr\ui\data\buildings\icon_fext_tracked_ca.paa";
									_owr_action5 ctrlSetTooltip "Tracked chassis (heavy)";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									if (((_factory getVariable "ow_factory_upgrades") select 0)) then {
										_owr_action5 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 4, true];
											_factoryToUse setVariable ["ow_factory_template", [3,-1,-1,-1], true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!((_factory getVariable "ow_factory_upgrades") select 0)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										_owr_action5 ctrlSetTooltip format["Tracked chassis (heavy) (%1)", _reasons];
									};

									_owr_action4 ctrlSetText "\owr\ui\data\buildings\icon_fext_tracked_ca.paa";
									_owr_action4 ctrlSetTooltip "Tracked chassis (medium)";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									if (((_factory getVariable "ow_factory_upgrades") select 0)) then {
										_owr_action4 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 4, true];
											_factoryToUse setVariable ["ow_factory_template", [1,-1,-1,-1], true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action4 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action4 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!((_factory getVariable "ow_factory_upgrades") select 0)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										_owr_action4 ctrlSetTooltip format["Tracked chassis (medium) (%1)", _reasons];
									};

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_man_start_ca.paa";
									_owr_action2 ctrlSetTooltip "Wheeled chassis (heavy)";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 4, true];
										_factoryToUse setVariable ["ow_factory_template", [2,-1,-1,-1], true];
										playSound "owr_ui_button_confirm";
									}];	

									_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_man_start_ca.paa";
									_owr_action1 ctrlSetTooltip "Wheeled chassis (medium)";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 4, true];
										_factoryToUse setVariable ["ow_factory_template", [0,-1,-1,-1], true];
										playSound "owr_ui_button_confirm";
									}];	
								};

								case 4: {
									// VEHICLE MANUFACTURING
									// engine
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 3, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_rescat_siberite_ca.paa";
									_owr_action2 ctrlSetTooltip "Alaskite motor";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["siberite", 4, bis_curator_east] call owr_fn_isResearchComplete && ((_factory getVariable "ow_factory_upgrades") select 3)) then {
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 5, true];
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";
											_tempTemplateArray set [1, 1];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_reasons = "";
										if (!(["siberite", 4, bis_curator_east] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (!((_factory getVariable "ow_factory_upgrades") select 3)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										_owr_action2 ctrlSetTooltip format["Alaskite motor (%1)", _reasons];
									};

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_moil_ca.paa";
									_owr_action1 ctrlSetTooltip "Combustion motor";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 4, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 5, true];
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";
											_tempTemplateArray set [1, 0];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action1 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetTooltip "Combustion motor (missing tech)";
									};
								};

								case 5: {
									// VEHICLE MANUFACTURING
									// control
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 4, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_adv_ai_ca.paa";
									_owr_action2 ctrlSetTooltip "AI controlled";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["comp", 4, bis_curator_east] call owr_fn_isResearchComplete && ((_factory getVariable "ow_factory_upgrades") select 4)) then {
										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 6, true];
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";
											_tempTemplateArray set [2, 1];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!(["comp", 4, bis_curator_east] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (!((_factory getVariable "ow_factory_upgrades") select 4)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										_owr_action2 ctrlSetTooltip format["AI controlled (%1)", _reasons];
									};

									_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_free_ca.paa";
									_owr_action1 ctrlSetTooltip "Manual control";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 6, true];
										_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";
										_tempTemplateArray set [2, 0];
										_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
										playSound "owr_ui_button_confirm";
									}];
								};

								case 6: {
									// VEHICLE MANUFACTURING
									// function
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUpgrade = (curatorSelected select 0) select 0;
										_factoryToUpgrade setVariable ["ow_factory_buildmode", 5, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "\owr\ui\data\buildings\icon_fext_ncom_ca.paa";
									_owr_action2 ctrlSetTooltip "Engineer system";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 8, true];
										playSound "owr_ui_button_confirm";
									}];

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_rescat_weap_ca.paa";
									_owr_action1 ctrlSetTooltip "Weapon system";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 7, true];
										playSound "owr_ui_button_confirm";
									}];	
								};

								case 7: {
									// VEHICLE MANUFACTURING
									// weapons
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "";


									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";


									_owr_action6 ctrlSetText "\owr\ui\data\research\icon_res_weap_rocket_ca.paa";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 7, bis_curator_east] call owr_fn_isResearchComplete && ((_factory getVariable "ow_factory_upgrades") select 2) && ((((_factory getVariable "ow_factory_template") select 0) == 2) || (((_factory getVariable "ow_factory_template") select 0) == 3))) then {
										
										_tempTemplateArray = _factory getVariable "ow_factory_template";
										_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 5]] call owr_fn_getRUVehicleCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action6 ctrlSetTooltip format ["Rocket %1", _costString];

										_owr_action6 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 5]] call owr_fn_getRUVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 5];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	
									} else {
										_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!(["weap", 7, bis_curator_east] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (!((_factory getVariable "ow_factory_upgrades") select 2)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										if (((((_factory getVariable "ow_factory_template") select 0) != 2) && (((_factory getVariable "ow_factory_template") select 0) != 3))) then {
											_reasons = _reasons + " chassis too light ";
										};
										_owr_action6 ctrlSetTooltip format["Rocket (%1)", _reasons];
									};



									_owr_action5 ctrlSetText "\owr\ui\data\research\icon_res_rocket_launcher_ca.paa";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 5, bis_curator_east] call owr_fn_isResearchComplete && ((_factory getVariable "ow_factory_upgrades") select 2)) then {

										_tempTemplateArray = _factory getVariable "ow_factory_template";
										_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 4]] call owr_fn_getRUVehicleCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action5 ctrlSetTooltip format ["Vehicle rocket launcher %1", _costString];

										_owr_action5 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 4]] call owr_fn_getRUVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 4];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	
									} else {
										_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!(["weap", 5, bis_curator_east] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (!((_factory getVariable "ow_factory_upgrades") select 2)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										_owr_action5 ctrlSetTooltip format["Vehicle rocket launcher (%1)", _reasons];
									};



									_owr_action4 ctrlSetText "\owr\ui\data\research\icon_res_heavy_gun_ca.paa";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 6, bis_curator_east] call owr_fn_isResearchComplete && ((_factory getVariable "ow_factory_upgrades") select 1) && (((_factory getVariable "ow_factory_template") select 0) != 0) && (((_factory getVariable "ow_factory_template") select 0) != 1)) then {
										
										_tempTemplateArray = _factory getVariable "ow_factory_template";
										_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 3]] call owr_fn_getRUVehicleCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action4 ctrlSetTooltip format ["Heavy cannon %1", _costString];

										_owr_action4 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 3]] call owr_fn_getRUVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 3];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	
									} else {
										_owr_action4 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action4 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!(["weap", 6, bis_curator_east] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (!((_factory getVariable "ow_factory_upgrades") select 1)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										if ((((_factory getVariable "ow_factory_template") select 0) == 0) || (((_factory getVariable "ow_factory_template") select 0) == 1)) then {
											_reasons = _reasons + " chassis too light ";
										};
										_owr_action4 ctrlSetTooltip format["Heavy cannon (%1)", _reasons];
									};



									_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_gun_ca.paa";
									_owr_action3 ctrlSetTooltip "Cannon";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 4, bis_curator_east] call owr_fn_isResearchComplete && ((_factory getVariable "ow_factory_upgrades") select 1)) then {

										_tempTemplateArray = _factory getVariable "ow_factory_template";
										_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 2]] call owr_fn_getRUVehicleCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action3 ctrlSetTooltip format ["Cannon %1", _costString];

										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 2]] call owr_fn_getRUVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 2];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	
									} else {
										_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = "";
										if (!(["weap", 4, bis_curator_east] call owr_fn_isResearchComplete)) then {
											_reasons = _reasons + " missing tech ";
										};
										if (!((_factory getVariable "ow_factory_upgrades") select 1)) then {
											_reasons = _reasons + " missing side upgrade ";
										};
										_owr_action3 ctrlSetTooltip format["Cannon (%1)", _reasons];
									};


									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_rot_mgun_ca.paa";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (["weap", 3, bis_curator_east] call owr_fn_isResearchComplete) then {

										_tempTemplateArray = _factory getVariable "ow_factory_template";
										_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 1]] call owr_fn_getRUVehicleCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action2 ctrlSetTooltip format ["Minigun %1", _costString];

										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 1]] call owr_fn_getRUVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 1];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];	
									} else {
										_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetTooltip "Minigun ( missing tech )";
									};


									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_gun_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 0]] call owr_fn_getRUVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action1 ctrlSetTooltip format ["Heavy machine gun %1", _costString];

									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										// set last piece of vehicle template
										_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

										// start manufacturing / do nothing if there is not enough resources
										_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 0]] call owr_fn_getRUVehicleCost;
										if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
											// we have enough resource in warehouse, take them out
											[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
											// this will trigger manufacturing process
											_tempTemplateArray set [3, 0];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											// switch gui
											_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
											playSound "owr_ui_button_confirm";
										} else {
											playSound "owr_ui_button_cancel";
										};
									}];
								};

								case 8: {
									// VEHICLE MANUFACTURING
									// engineer stuff
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUpgrade = (curatorSelected select 0) select 0;
										_factoryToUpgrade setVariable ["ow_factory_buildmode", 6, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_ai_ca.paa";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									if (false) then {
										_tempTemplateArray = _factory getVariable "ow_factory_template";
										_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 7]] call owr_fn_getRUVehicleCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action2 ctrlSetTooltip format ["Crane %1", _costString];	

										_owr_action2 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											// set last piece of vehicle template
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

											// start manufacturing / do nothing if there is not enough resources
											_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 7]] call owr_fn_getRUVehicleCost;
											if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// this will trigger manufacturing process
												_tempTemplateArray set [3, 7];
												_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
												// switch gui
												_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];
									} else {
										_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

										_reasons = " not implemented yet ";

										_owr_action2 ctrlSetTooltip format["Crane (%1)", _reasons];
									};


									_owr_action1 ctrlSetText "\owr\ui\data\buildings\icon_fext_ncom_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 6]] call owr_fn_getRUVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action1 ctrlSetTooltip format ["Resource storage %1", _costString];

									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										// set last piece of vehicle template
										_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

										// start manufacturing / do nothing if there is not enough resources
										_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 6]] call owr_fn_getRUVehicleCost;
										if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
											// we have enough resource in warehouse, take them out
											[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
											// this will trigger manufacturing process
											_tempTemplateArray set [3, 6];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											// switch gui
											_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
											playSound "owr_ui_button_confirm";
										} else {
											playSound "owr_ui_button_cancel";
										};
									}];						
								};

								case 9: {
									// not upgraded factory - manufacturing
									// chassis
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 0, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "";
									_owr_action2 ctrlSetTooltip "";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_man_start_ca.paa";
									_owr_action1 ctrlSetTooltip "Wheeled chassis (medium)";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 10, true];
										_factoryToUse setVariable ["ow_factory_template", [0,-1,-1,-1], true];
										playSound "owr_ui_button_confirm";
									}];	
								};
								case 10: {
									// engine
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 9, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "";
									_owr_action2 ctrlSetTooltip "";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_moil_ca.paa";
									_owr_action1 ctrlSetTooltip "Combustion motor";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									if (["basic", 4, bis_curator_east] call owr_fn_isResearchComplete) then {
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_factoryToUse = (curatorSelected select 0) select 0;
											_factoryToUse setVariable ["ow_factory_buildmode", 11, true];
											_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";
											_tempTemplateArray set [1, 0];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											playSound "owr_ui_button_confirm";
										}];	
									} else {
										_owr_action1 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetTooltip "Combustion motor (missing tech)";
									};
								};
								case 11: {
									// control
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Back";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 10, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "";
									_owr_action2 ctrlSetTooltip "";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_free_ca.paa";
									_owr_action1 ctrlSetTooltip "Manual control";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										_factoryToUse setVariable ["ow_factory_buildmode", 12, true];
										_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";
										_tempTemplateArray set [2, 0];
										_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
										playSound "owr_ui_button_confirm";
									}];
								};
								case 12: {
									// mounted stuff
									_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
									_owr_action9 ctrlSetTooltip "Cancel";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action9 ctrladdeventhandler ["buttonclick", {
										_factoryToUpgrade = (curatorSelected select 0) select 0;
										_factoryToUpgrade setVariable ["ow_factory_buildmode", 11, true];
										playSound "owr_ui_button_cancel";
									}];	

									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "\owr\ui\data\buildings\icon_fext_ncom_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 6]] call owr_fn_getRUVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action2 ctrlSetTooltip format ["Resource storage %1", _costString];

									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action2 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										// set last piece of vehicle template
										_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

										// start manufacturing / do nothing if there is not enough resources
										_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 6]] call owr_fn_getRUVehicleCost;
										if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
											// we have enough resource in warehouse, take them out
											[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
											// this will trigger manufacturing process
											_tempTemplateArray set [3, 6];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											// switch gui
											_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
											playSound "owr_ui_button_confirm";
										} else {
											playSound "owr_ui_button_cancel";
										};
									}];

									_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_gun_ca.paa";

									_tempTemplateArray = _factory getVariable "ow_factory_template";
									_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 0]] call owr_fn_getRUVehicleCost;
									_costString = [_resourceArray] call owr_fn_getCostStr;
									_owr_action1 ctrlSetTooltip format ["Heavy machine gun %1", _costString];

									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_factoryToUse = (curatorSelected select 0) select 0;
										// set last piece of vehicle template
										_tempTemplateArray = _factoryToUse getVariable "ow_factory_template";

										// start manufacturing / do nothing if there is not enough resources
										_resourceArray = [[_tempTemplateArray select 0, _tempTemplateArray select 1, _tempTemplateArray select 2, 0]] call owr_fn_getRUVehicleCost;
										if ([_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
											// we have enough resource in warehouse, take them out
											[_resourceArray, _factoryToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
											// this will trigger manufacturing process
											_tempTemplateArray set [3, 0];
											_factoryToUse setVariable ["ow_factory_template", _tempTemplateArray, true];
											// switch gui
											_factoryToUse setVariable ["ow_factory_buildmode", 2, true];
											playSound "owr_ui_button_confirm";
										} else {
											playSound "owr_ui_button_cancel";
										};
									}];
								};
							};
						} else {
							_owr_action9 ctrlSetText "";
							_owr_action9 ctrlSetTooltip "";
							_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

							if (isNull (_factory getVariable "ow_build_wrhs")) then {
								_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
								_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action8 ctrladdeventhandler ["buttonclick", {
									_objectToSearchAround = (curatorSelected select 0) select 0;
									_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ru"], 150];
									if ((count _warehousesAvailable) > 0) then {
										_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
									};
								}];
							} else {
								_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
								_owr_action8 ctrlSetTooltip "Warehouse connected";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
								_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
							};

							_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
							_owr_action7 ctrlSetTooltip "Lights On/Off";
							_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action7 ctrladdeventhandler ["buttonclick", {
								_factoryToUse = (curatorSelected select 0) select 0;
								_lightState = _factoryToUse getVariable "ow_build_light";
								if (_lightState) then {
									_factoryToUse setVariable ["ow_build_light", false, true];
								} else {
									_factoryToUse setVariable ["ow_build_light", true, true];
								};
								playSound "owr_ui_button_confirm";
							}];

							_owr_action6 ctrlSetText "";
							_owr_action6 ctrlSetTooltip "";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action5 ctrlSetText "";
							_owr_action5 ctrlSetTooltip "";
							_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action4 ctrlSetText "";
							_owr_action4 ctrlSetTooltip "";
							_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action3 ctrlSetText "";
							_owr_action3 ctrlSetTooltip "";
							_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action2 ctrlSetText "";
							_owr_action2 ctrlSetTooltip "";
							_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action1 ctrlSetText "";
							_owr_action1 ctrlSetTooltip "";
							_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
						};
					};
					// AR - FACTORY
					if ((_selected select 0) isKindOf "factory_ar") then {
						_factory = (_selected select 0);
						{
							_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
							_x ctrlSetActiveColor [1, 1, 1, 1];
						} forEach _actionButtons;
					};




					if (((_selected select 0) isKindOf "barracks_ru") || ((_selected select 0) isKindOf "barracks_am") || ((_selected select 0) isKindOf "barracks_ar")) then {
						_barr = (_selected select 0);
						{
							_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
							_x ctrlSetActiveColor [1, 1, 1, 1];
						} forEach _actionButtons;

						if (_barr getVariable "ow_build_ready") then {
							if (!(_barr getVariable "ow_build_upgrade")) then {
								_owr_action9 ctrlSetText "";
								_owr_action9 ctrlSetTooltip "";
								_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

								if (isNull (_barr getVariable "ow_build_wrhs")) then {
									_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
									_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrladdeventhandler ["buttonclick", {
										_objectToSearchAround = (curatorSelected select 0) select 0;
										_warehouse_type = "";
										switch (typeOf _objectToSearchAround) do {
											case "barracks_am": {
												_warehouse_type = "warehouse_am";
											};
											case "barracks_ru": {
												_warehouse_type = "warehouse_ru";
											};
											case "barracks_ar": {
												_warehouse_type = "warehouse_ar";
											};
										};
										_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, [_warehouse_type], 150];
										if ((count _warehousesAvailable) > 0) then {
											_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
										};
									}];
								} else {
									_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
									_owr_action8 ctrlSetTooltip "Warehouse connected";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
									_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
								};

								_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
								_owr_action7 ctrlSetTooltip "Lights On/Off";
								_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action7 ctrladdeventhandler ["buttonclick", {
									_barrToUse = (curatorSelected select 0) select 0;
									_lightState = _barrToUse getVariable "ow_build_light";
									if (_lightState) then {
										_barrToUse setVariable ["ow_build_light", false, true];
									} else {
										_barrToUse setVariable ["ow_build_light", true, true];
									};
									playSound "owr_ui_button_confirm";
								}];

								_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
								_owr_action6 ctrlSetTooltip "Deconstruct building";
								_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action6 ctrladdeventhandler ["buttonclick", {
									_barrToUse = (curatorSelected select 0) select 0;
									_barrToUse setVariable ["ow_build_deconstruct", true, true];
									_barrToUse setVariable ["ow_build_ready", false, true];
									playSound "owr_ui_button_confirm";
								}];

								_owr_action5 ctrlSetText "";
								_owr_action5 ctrlSetTooltip "";
								_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action4 ctrlSetText "";
								_owr_action4 ctrlSetTooltip "";
								_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

								// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
								_someoneNotASoldier = false;
								{
									if (_x getVariable "ow_class" != 0) then {
										_someoneNotASoldier = true;
									};
								} forEach (crew _barr);

								if (_someoneNotASoldier) then {
									_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makesoldier_ca.paa";
									_owr_action3 ctrlSetTooltip "Change class to soldier";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_barracksToWorkWith = (curatorSelected select 0) select 0;
										{
											_x setVariable ["ow_class", 0, true];
											//[_x, 0] call owr_fn_changeClassGear;
											[_x, 0] remoteExec ["owr_fn_changeClassGear", owner _owman];
										} forEach (crew _barracksToWorkWith);
										playSound "owr_ui_button_confirm";
									}];
								} else {
									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
								};




								_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_bupgrade_ca.paa";

								_resourceArray = [typeOf _barr] call owr_fn_getUpgradeCostStr;
								_costString = [_resourceArray] call owr_fn_getCostStr;
								_owr_action2 ctrlSetTooltip format["Upgrade to advanced barracks %1", _costString];

								_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action2 ctrladdeventhandler ["buttonclick", {
									_barrToUse = (curatorSelected select 0) select 0;
									// get the resources needed
									_resourceArray = [typeOf _barrToUse] call owr_fn_getUpgradeCostStr;
									if ([_resourceArray, _barrToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
										// we have enough resource in warehouse, take them out
										[_resourceArray, _barrToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
										// let the upgrade begin
										_barrToUse setVariable ["ow_build_upgrade", true, true];
										playSound "owr_ui_button_confirm";
									} else {
										playSound "owr_ui_button_cancel";
									};
								}];	



								if (count (crew _barr) > 0) then {
									_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
									_owr_action1 ctrlSetTooltip "Order all to exit building (G)";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_barracksToUse = (curatorSelected select 0) select 0;
										{
											[_x] call owr_fn_getOutOfVehicle;
										} forEach (crew _barracksToUse);
										playSound "owr_ui_button_confirm";
									}];	
								} else {
									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};
							} else {
								_owr_action9 ctrlSetText "";
								_owr_action9 ctrlSetTooltip "";
								_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

								if (isNull (_barr getVariable "ow_build_wrhs")) then {
									_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
									_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrladdeventhandler ["buttonclick", {
										_objectToSearchAround = (curatorSelected select 0) select 0;
										_warehouse_type = "";
										switch (typeOf _objectToSearchAround) do {
											case "barracks_am": {
												_warehouse_type = "warehouse_am";
											};
											case "barracks_ru": {
												_warehouse_type = "warehouse_ru";
											};
											case "barracks_ar": {
												_warehouse_type = "warehouse_ar";
											};
										};
										_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, [_warehouse_type], 150];
										if ((count _warehousesAvailable) > 0) then {
											_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
										};
									}];
								} else {
									_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
									_owr_action8 ctrlSetTooltip "Warehouse connected";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
									_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
								};

								_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
								_owr_action7 ctrlSetTooltip "Lights On/Off";
								_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action7 ctrladdeventhandler ["buttonclick", {
									_barrToUse = (curatorSelected select 0) select 0;
									_lightState = _barrToUse getVariable "ow_build_light";
									if (_lightState) then {
										_barrToUse setVariable ["ow_build_light", false, true];
									} else {
										_barrToUse setVariable ["ow_build_light", true, true];
									};
									playSound "owr_ui_button_confirm";
								}];

								_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
								_owr_action6 ctrlSetTooltip "Deconstruct building";
								_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action6 ctrladdeventhandler ["buttonclick", {
									_barrToUse = (curatorSelected select 0) select 0;
									_barrToUse setVariable ["ow_build_deconstruct", true, true];
									_barrToUse setVariable ["ow_build_ready", false, true];
									playSound "owr_ui_button_confirm";
								}];

								_owr_action5 ctrlSetText "";
								_owr_action5 ctrlSetTooltip "";
								_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action4 ctrlSetText "";
								_owr_action4 ctrlSetTooltip "";
								_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

								// 0 = soldier, 1 = worker, 2 = mechanic, 3 = scientist
								_someoneNotASoldier = false;
								{
									if (_x getVariable "ow_class" != 0) then {
										_someoneNotASoldier = true;
									};
								} forEach (crew _barr);

								if (_someoneNotASoldier) then {
									_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_makesoldier_ca.paa";
									_owr_action3 ctrlSetTooltip "Change class to soldier";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_barracksToWorkWith = (curatorSelected select 0) select 0;
										{
											_x setVariable ["ow_class", 0, true];
											//[_x, 0] call owr_fn_changeClassGear;
											[_x, 0] remoteExec ["owr_fn_changeClassGear", owner _owman];
										} forEach (crew _barracksToWorkWith);
										playSound "owr_ui_button_confirm";
									}];
								} else {
									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
								};

								_owr_action2 ctrlSetText "";
								_owr_action2 ctrlSetTooltip "";
								_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

								if (count (crew _barr) > 0) then {
									_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_beject_ca.paa";
									_owr_action1 ctrlSetTooltip "Order all to exit building (G)";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_barracksToUse = (curatorSelected select 0) select 0;
										{
											[_x] call owr_fn_getOutOfVehicle;
										} forEach (crew _barracksToUse);
										playSound "owr_ui_button_confirm";
									}];	
								} else {
									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};
							};
						} else {
							_owr_action9 ctrlSetText "";
							_owr_action9 ctrlSetTooltip "";
							_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

							if (isNull (_barr getVariable "ow_build_wrhs")) then {
								_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
								_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action8 ctrladdeventhandler ["buttonclick", {
									_objectToSearchAround = (curatorSelected select 0) select 0;
									_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_am"], 150];
									if ((count _warehousesAvailable) > 0) then {
										_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
									};
								}];
							} else {
								_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
								_owr_action8 ctrlSetTooltip "Warehouse connected";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
								_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
							};

							_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_lights.paa";
							_owr_action7 ctrlSetTooltip "Lights On/Off";
							_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action7 ctrladdeventhandler ["buttonclick", {
								_barrToUse = (curatorSelected select 0) select 0;
								_lightState = _barrToUse getVariable "ow_build_light";
								if (_lightState) then {
									_barrToUse setVariable ["ow_build_light", false, true];
								} else {
									_barrToUse setVariable ["ow_build_light", true, true];
								};
								playSound "owr_ui_button_confirm";
							}];

							_owr_action6 ctrlSetText "";
							_owr_action6 ctrlSetTooltip "";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action5 ctrlSetText "";
							_owr_action5 ctrlSetTooltip "";
							_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action4 ctrlSetText "";
							_owr_action4 ctrlSetTooltip "";
							_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action3 ctrlSetText "";
							_owr_action3 ctrlSetTooltip "";
							_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action2 ctrlSetText "";
							_owr_action2 ctrlSetTooltip "";
							_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action1 ctrlSetText "";
							_owr_action1 ctrlSetTooltip "";
							_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
						};
					};
				};
				case 3: {
					// vehicle selected
					_vehicle = (_selected select 0);
					{
						_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
						_x ctrlSetActiveColor [1, 1, 1, 1];
					} forEach _actionButtons;

					// checking even for selected empty vehicles!
					_cargoValue = 8;		// default for AM
					_cargoWarehouse = "warehouse_am";
					if (_vehicle isKindOf "owr_car_ru") then {
						_cargoValue = 6;	// value for RU
						_cargoWarehouse = "warehouse_ru";
					};
					/*if (_vehicle isKindOf "owr_car_ar") then {
						_cargoValue = 5;	// value for AR
						_cargoWarehouse = "warehouse_ar";
					};*/

					

					// does it have cargo upgrade?
					if ((((_vehicle getVariable "ow_vehicle_template") select 3) == _cargoValue)) then {
						_nearestWarehouses = nearestObjects [_vehicle, [_cargoWarehouse], 15];
						if (((count _nearestWarehouses) > 0) && ((_vehicle getVariable "ow_vehicle_cargo") > 0)) then {
							_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_pickup_drop_ca.paa";
							_owr_action9 ctrlSetTooltip "Empty cargo";
							_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action9 ctrladdeventhandler ["buttonclick", {
								_vehicleToUse = (curatorSelected select 0) select 0;
								_cargoWarehouse = "warehouse_am";
								if (_vehicleToUse isKindOf "owr_car_ru") then {
									_cargoWarehouse = "warehouse_ru";
								};
								_nearestSources = nearestObjects [_vehicleToUse, [_cargoWarehouse], 15];
								_resType = "ow_wrhs_crates";
								switch (_vehicleToUse getVariable "ow_vehicle_cargo_type") do {
									case 1: {_resType = "ow_wrhs_oil";};
									case 2: {_resType = "ow_wrhs_siberite";};
								};
								[_resType, (_nearestSources select 0), _vehicleToUse] spawn owr_fn_resourceDrop;
								playSound "owr_ui_button_confirm";
							}];
						} else {
							_owr_action9 ctrlSetText "\owr\ui\data\actions\icon_action_pickup_drop_ca.paa";
							_owr_action9 ctrlSetTooltip "Empty cargo (not available)";
							_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action9 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
							_owr_action9 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
						};
					} else {
						// nope
						_owr_action9 ctrlSetText "";
						_owr_action9 ctrlSetTooltip "";
						_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
					};

					// if _vehicle has cargo upgrade
					if ((((_vehicle getVariable "ow_vehicle_template") select 3) == _cargoValue)) then {
						// is it empty or not?
						if ((_vehicle getVariable "ow_vehicle_cargo") == 0) then {
							_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_pickup_type_ca.paa";
							_owr_action8 ctrlSetTooltip "Change resource type";
							_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action8 ctrladdeventhandler ["buttonclick", {
								_vehicleToUse = (curatorSelected select 0) select 0;
								_prevType = (_vehicleToUse getVariable "ow_vehicle_cargo_type") + 1;
								if (_prevType > 2) then {
									_prevType = 0;
								};
								_vehicleToUse setVariable ["ow_vehicle_cargo_type", _prevType];
								playSound "owr_ui_button_confirm";
							}];
						} else {
							_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_pickup_type_ca.paa";
							_owr_action8 ctrlSetTooltip "Change resource type (cargo is not empty)";
							_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action8 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
							_owr_action8 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
						};
					} else {
						_owr_action8 ctrlSetText "";
						_owr_action8 ctrlSetTooltip "";
						_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
					};

					// if _vehicle has cargo upgrade
					if ((((_vehicle getVariable "ow_vehicle_template") select 3) == _cargoValue)) then {
						// vehicle has cargo modification
						switch (_vehicle getVariable "ow_vehicle_cargo_type") do {
							case 0: {
								// check how it is full
								if ((_vehicle getVariable "ow_vehicle_cargo") < (_vehicle getVariable "ow_vehicle_cargo_cap")) then {
									// CRATE CASE
									// good, search for crates
									_nearestCrates = nearestObjects [_vehicle, ["owr_crates_pile_1","owr_crates_pile_2","owr_crates_pile_3","owr_crates_pile_4","owr_crates_pile_5"], 15];
									if ((count _nearestCrates) > 0) then {
										// found some
										_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_pickup_crates_ca.paa";
										_owr_action7 ctrlSetTooltip "Pickup crates";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action7 ctrladdeventhandler ["buttonclick", {
											_vehicleToUse = (curatorSelected select 0) select 0;
											_nearestCrates = nearestObjects [_vehicleToUse, ["owr_crates_pile_1","owr_crates_pile_2","owr_crates_pile_3","owr_crates_pile_4","owr_crates_pile_5"], 15];
											[(_nearestCrates select 0), _vehicleToUse] spawn owr_fn_cargoCratePickUp;
											playSound "owr_ui_button_confirm";
										}];
									} else {
										// nothing found
										// LETS TRY WAREHOUSES THEN
										_nearestWarehouses = nearestObjects [_vehicle, [_cargoWarehouse], 15];
										if ((count _nearestWarehouses) > 0) then {
											// found some
											_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_pickup_crates_ca.paa";
											_owr_action7 ctrlSetTooltip "Pickup crates";
											_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action7 ctrladdeventhandler ["buttonclick", {
												_vehicleToUse = (curatorSelected select 0) select 0;
												_cargoWarehouse = "warehouse_am";
												if (_vehicleToUse isKindOf "owr_car_ru") then {
													_cargoWarehouse = "warehouse_ru";
												};
												/*if (_vehicleToUse isKindOf "owr_car_ar") then {
													_cargoWarehouse = "warehouse_ar";
												};*/
												_nearestSources = nearestObjects [_vehicleToUse, [_cargoWarehouse], 15];
												["ow_wrhs_crates", (_nearestSources select 0), _vehicleToUse] spawn owr_fn_resourcePickUp;
												playSound "owr_ui_button_confirm";
											}];
										} else {
											_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_pickup_crates_ca.paa";
											_owr_action7 ctrlSetTooltip "No resources found around vehicle";
											_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action7 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action7 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										};
									};
								} else {
									// cargo full
									_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_pickup_crates_ca.paa";
									_owr_action7 ctrlSetTooltip "Cargo at maximum capacity";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
									_owr_action7 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
								};
							};

							case 1: {
								// check how it is full
								if ((_vehicle getVariable "ow_vehicle_cargo") < 100) then {
									// OIL CASE
									// good, search for source
									_nearestSources = nearestObjects [_vehicle, [_cargoWarehouse], 15];
									if ((count _nearestSources) > 0) then {
										// found some
										_owr_action7 ctrlSetText "\owr\ui\data\research\icon_res_moil_ca.paa";
										_owr_action7 ctrlSetTooltip "Pickup oil";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action7 ctrladdeventhandler ["buttonclick", {
											_vehicleToUse = (curatorSelected select 0) select 0;
											_cargoWarehouse = "warehouse_am";
											if (_vehicleToUse isKindOf "owr_car_ru") then {
												_cargoWarehouse = "warehouse_ru";
											};
											/*if (_vehicleToUse isKindOf "owr_car_ar") then {
												_cargoWarehouse = "warehouse_ar";
											};*/
											_nearestSources = nearestObjects [_vehicleToUse, [_cargoWarehouse], 15];
											["ow_wrhs_oil", (_nearestSources select 0), _vehicleToUse] spawn owr_fn_resourcePickUp;
											playSound "owr_ui_button_confirm";
										}];
									} else {
										// nothing found
										_owr_action7 ctrlSetText "\owr\ui\data\research\icon_res_moil_ca.paa";
										_owr_action7 ctrlSetTooltip "No source found around vehicle";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action7 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action7 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
									};
								} else {
									// cargo full
									_owr_action7 ctrlSetText "\owr\ui\data\research\icon_res_moil_ca.paa";
									_owr_action7 ctrlSetTooltip "Cargo at maximum capacity";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
									_owr_action7 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
								};
							};

							case 2: {
								// check how it is full
								if ((_vehicle getVariable "ow_vehicle_cargo") < 100) then {
									// SIBERITE CASE
									// good, search for source
									_nearestSources = nearestObjects [_vehicle, [_cargoWarehouse], 15];
									if ((count _nearestSources) > 0) then {
										// found some
										_owr_action7 ctrlSetText "\owr\ui\data\research\icon_rescat_siberite_ca.paa";
										_owr_action7 ctrlSetTooltip "Pickup siberite";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action7 ctrladdeventhandler ["buttonclick", {
											_vehicleToUse = (curatorSelected select 0) select 0;
											_cargoWarehouse = "warehouse_am";
											if (_vehicleToUse isKindOf "owr_car_ru") then {
												_cargoWarehouse = "warehouse_ru";
											};
											/*if (_vehicleToUse isKindOf "owr_car_ar") then {
												_cargoWarehouse = "warehouse_ar";
											};*/
											_nearestSources = nearestObjects [_vehicleToUse, [_cargoWarehouse], 15];
											["ow_wrhs_siberite", (_nearestSources select 0), _vehicleToUse] spawn owr_fn_resourcePickUp;
											playSound "owr_ui_button_confirm";
										}];
									} else {
										// nothing found
										_owr_action7 ctrlSetText "\owr\ui\data\research\icon_rescat_siberite_ca.paa";
										_owr_action7 ctrlSetTooltip "No source found around vehicle";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action7 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action7 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
									};
								} else {
									// cargo full
									_owr_action7 ctrlSetText "\owr\ui\data\research\icon_rescat_siberite_ca.paa";
									_owr_action7 ctrlSetTooltip "Cargo at maximum capacity";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action7 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
									_owr_action7 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
								};
							};
						};
					} else {
						_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_vehicle_flip_ca";
						_owr_action7 ctrlSetTooltip "Put vehicle back to normal state";
						_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action7 ctrladdeventhandler ["buttonclick", {
							_vehicleToFlip = (curatorSelected select 0) select 0;
							[_vehicleToFlip, [0,0,1]] remoteExec ["setVectorUp", owner _vehicleToFlip];
							[_vehicleToFlip, [(getPos _vehicleToFlip) select 0, (getPos _vehicleToFlip) select 1, 10]] remoteExec ["setPos", owner _vehicleToFlip];

							if (((_vehicleToFlip getVariable "ow_vehicle_template") select 2) == 1) then {
								// if ai controlled - cleanup of the crew to prevent being stuck when flipped (vehicle is fine, but they are unable to drive at all)

								{
									_vehicleToFlip deleteVehicleCrew _x
								} forEach (crew _vehicleToFlip);

								_crewSide = "";
								_tempCommander = objNull;
								_curator = objNull;
								if (_vehicleToFlip isKindOf "owr_car_ar") then {
									_crewSide = "I_UAV_AI";
									_tempCommander = guy_from_resistance;
									_curator = bis_curator_arab;
								} else {
									if (_vehicleToFlip isKindOf "owr_car_ru") then {
										_crewSide = "O_UAV_AI";
										_tempCommander = guy_from_east;
										_curator = bis_curator_east;
									} else {
										_crewSide = "B_UAV_AI";
										_tempCommander = guy_from_west;
										_curator = bis_curator_west;
									};
								};

								_ai_driver = (group _tempCommander) createUnit [_crewSide, getPos _tempCommander, [], 0, "FORM"];
								_ai_gunner = (group _tempCommander) createUnit [_crewSide, getPos _tempCommander, [], 0, "FORM"];
								[_ai_driver, _ai_gunner] join grpNull;
								[_ai_gunner] join _ai_driver;

								_ai_driver moveInAny _vehicleToFlip;
								_ai_gunner moveInAny _vehicleToFlip;

								//hintSilent format ["%1 %2 (%3)", _ai_driver, _ai_gunner, vehicle _ai_driver];
								//hintSilent format ["%1 %2 %3", _crewSide, _tempCommander, _curator];

								// set skills based on CPU research
								if (["comp", 0, _curator] call owr_fn_isResearchComplete) then {
									if ((["comp", 1, _curator] call owr_fn_isResearchComplete)) then {
										if ((["comp", 2, _curator] call owr_fn_isResearchComplete)) then {
											{
												//_x setSkill 0.5;
												[_x, 1.0] remoteExec ["setSkill", owner _x];
											} forEach (crew _vehicleToFlip);
										} else {
											{
												//_x setSkill 0.37;
												[_x, 0.85] remoteExec ["setSkill", owner _x];
											} forEach (crew _vehicleToFlip);
										};
									} else {
										{
											//_x setSkill 0.25;
											[_x, 0.75] remoteExec ["setSkill", owner _x];
										} forEach (crew _vehicleToFlip);
									};
								} else {
									// no cpu research at all - ai dumb
									{
										//_x setSkill 0.15;
										[_x, 0.60] remoteExec ["setSkill", owner _x];
									} forEach (crew _vehicleToFlip);
								};
							};

						}];
					};

					// recycle - available when close to factory - automatic eject of cargo if manned
					_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_action_vrecycle_ca.paa";
					_owr_action6 ctrlSetTooltip "Recycle vehicle";
					_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
					_nearestFactories = nearestObjects [_vehicle, ["factory_am", "factory_ru"], 15];
					if ((count (_nearestFactories)) > 0) then {
						_factory = _nearestFactories select 0;
						// !! ALIVE !!
						if ((_factory getVariable "ow_build_ready") && ((_factory getVariable "ow_wip_progress") >= 1.0))	 then {
							_owr_action6 ctrladdeventhandler ["buttonclick", {
								_vehicleToRecycle = (curatorSelected select 0) select 0;
								_nearestFactories = nearestObjects [_vehicleToRecycle, ["factory_am", "factory_ru"], 15];
								(_nearestFactories select 0) setVariable ["ow_factory_recycle", _vehicleToRecycle getVariable "ow_vehicle_template", true];
								(_nearestFactories select 0) setVariable ["ow_factory_buildmode", 2, true];
								if ((((_vehicleToRecycle getVariable "ow_vehicle_template") select 2) == 1) || (((_vehicleToRecycle getVariable "ow_vehicle_template") select 2) == 1)) then {
									// ai / remote, delete crew and then vehicle
									{
										_vehicleToRecycle deleteVehicleCrew _x
									} forEach (crew _vehicleToRecycle);
									deleteVehicle _vehicleToRecycle;
								} else {
									// manned, eject and delete
									{
										if ((_x isKindOf "B_UAV_AI") || (_x isKindOf "O_UAV_AI")) then {
											_vehicleToRecycle deleteVehicleCrew _x;
										} else {
											[_x] call owr_fn_getOutOfVehicle;
										};
									} forEach (crew _vehicleToRecycle);
									deleteVehicle _vehicleToRecycle;
								};
								playSound "owr_ui_button_confirm";
							}];	
						} else {
							_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
							_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
							_owr_action6 ctrlSetTooltip "Recycle vehicle (factory found, not available)";
						};
					} else {
						_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
						_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
						_owr_action6 ctrlSetTooltip "Recycle vehicle (no factory found)";
					};

					_owr_action5 ctrlSetText "";
					_owr_action5 ctrlSetTooltip "";
					_owr_action5 ctrlRemoveAllEventHandlers "";

					// eject from vehicle - available for manned control
					_owr_action4 ctrlSetText "\owr\ui\data\actions\icon_action_veject_ca.paa";
					_owr_action4 ctrlSetTooltip "Eject from vehicle";
					_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
					if ((((_vehicle getVariable "ow_vehicle_template") select 2) == 0) && ((count (crew _vehicle)) > 0)) then {
						_owr_action4 ctrladdeventhandler ["buttonclick", {
							_unitToChange = (curatorSelected select 0) select 0;
							{
								[_x] call owr_fn_getOutOfVehicle;
							} forEach (crew _unitToChange);
							playSound "owr_ui_button_confirm";
						}];	
					} else {
						_owr_action4 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
						_owr_action4 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
						_owr_action4 ctrlSetTooltip "Eject from vehicle (not available)";
					};

					// fueling
					if ((((_vehicle getVariable "ow_vehicle_template") select 1) == 0)) then {
						// combustion case - can be loaded from building or cargo car!
						_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_moil_ca.paa";
						if ((fuel _vehicle) < 0.95) then {
							// prioritize buildings first!
							_sourceFound = false;
							_nearestFueldepos = nearestObjects [_vehicle, ["factory_am","warehouse_am", "source_oil_am","factory_ru","warehouse_ru", "source_oil_ru","factory_ar","warehouse_ar", "source_oil_ar"], 15];
							if ((count _nearestFueldepos) > 0) then {
								_warehouseFuelStorage = 0;
								_sourceFound = true;
								if (((_nearestFueldepos select 0) isKindOf "warehouse_am") || ((_nearestFueldepos select 0) isKindOf "warehouse_ru") || ((_nearestFueldepos select 0) isKindOf "warehouse_ar")) then {
									_warehouseFuelStorage = (_nearestFueldepos select 0) getVariable "ow_wrhs_oil";
								} else {
									_warehouseToCheckForFuel = (_nearestFueldepos select 0) getVariable "ow_build_wrhs";
									_warehouseFuelStorage = (_warehouseToCheckForFuel getVariable "ow_wrhs_oil");
								};
								if (_warehouseFuelStorage > 10) then {
									_owr_action3 ctrlSetTooltip "Refuel vehicle";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action3 ctrladdeventhandler ["buttonclick", {
										_unitToRefuel = (curatorSelected select 0) select 0;
										_nearestFueldepos = nearestObjects [_unitToRefuel, ["factory_am","warehouse_am", "source_oil_am","factory_ru","warehouse_ru", "source_oil_ru","factory_ar","warehouse_ar", "source_oil_ar"], 15];
										_warehouseFuelStorage = 0;
										if (((_nearestFueldepos select 0) isKindOf "warehouse_am") || ((_nearestFueldepos select 0) isKindOf "warehouse_ru") || ((_nearestFueldepos select 0) isKindOf "warehouse_ar")) then {
											_warehouseFuelStorage = (_nearestFueldepos select 0) getVariable "ow_wrhs_oil";
											(_nearestFueldepos select 0) setVariable ["ow_wrhs_oil", _warehouseFuelStorage - 10, true];
										} else {
											_warehouseToCheckForFuel = (_nearestFueldepos select 0) getVariable "ow_build_wrhs";
											_warehouseFuelStorage = (_warehouseToCheckForFuel getVariable "ow_wrhs_oil");
											_warehouseToCheckForFuel setVariable ["ow_wrhs_oil", _warehouseFuelStorage - 10, true];
										};
										[_unitToRefuel, 1.0] remoteExec ["setFuel", owner _unitToRefuel];
										playSound "owr_ui_button_confirm";
									}];
								} else {
									_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
									_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
									_owr_action3 ctrlSetTooltip "Refuel ( not enough oil in warehouse )";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
								};
							} else {
								_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
								_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
								_owr_action3 ctrlSetTooltip "Refuel ( no fuel connection around vehicle )";
								_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
							};

							if (!_sourceFound) then {
								// try to search for vehicles with cargo upgrade and fuel in it!
								_nearestFuelcargo = nearestObjects [_vehicle, ["owr_ru_hv_tr_mn_cb_cargo","owr_ru_hv_tr_mn_sb_cargo","owr_ru_hv_tr_ai_cb_cargo","owr_ru_hv_tr_ai_sb_cargo","owr_ru_hv_wh_mn_cb_cargo","owr_ru_hv_wh_mn_sb_cargo","owr_ru_hv_wh_ai_cb_cargo","owr_ru_hv_wh_ai_sb_cargo","owr_ru_me_tr_mn_cb_cargo","owr_ru_me_tr_mn_sb_cargo","owr_ru_me_tr_ai_cb_cargo","owr_ru_me_tr_ai_sb_cargo","owr_ru_me_wh_mn_cb_cargo","owr_ru_me_wh_mn_sb_cargo","owr_ru_me_wh_ai_cb_cargo","owr_ru_me_wh_ai_sb_cargo","owr_am_hv_tr_mn_cb_cargo","owr_am_hv_tr_mn_sb_cargo","owr_am_hv_tr_ai_cb_cargo","owr_am_hv_tr_ai_sb_cargo","owr_am_me_tr_mn_cb_cargo","owr_am_me_tr_mn_sb_cargo","owr_am_me_tr_ai_cb_cargo","owr_am_me_tr_ai_sb_cargo","owr_am_me_wh_mn_cb_cargo","owr_am_me_wh_mn_el_cargo","owr_am_me_wh_mn_sb_cargo","owr_am_me_wh_ai_cb_cargo","owr_am_me_wh_ai_el_cargo","owr_am_me_wh_ai_sb_cargo"], 15];
								if ((count _nearestFuelcargo) > 0) then {
									// cargo vehicle found / cargo vehicle itself (in case vehicle is cargo already), check contents
									_cargoVehicle = (_nearestFuelcargo select 0);
									if ((_cargoVehicle getVariable "ow_vehicle_cargo_type") == 1) then {
										// content is oil
										if ((_cargoVehicle getVariable "ow_vehicle_cargo") >= 10) then {
											_owr_action3 ctrlSetTooltip "Refuel vehicle";
											_owr_action3 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
											_owr_action3 ctrlSetActiveColor [1, 1, 1, 1];
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_unitToRefuel = (curatorSelected select 0) select 0;
												_nearestFuelcargo = nearestObjects [_unitToRefuel, ["owr_ru_hv_tr_mn_cb_cargo","owr_ru_hv_tr_mn_sb_cargo","owr_ru_hv_tr_ai_cb_cargo","owr_ru_hv_tr_ai_sb_cargo","owr_ru_hv_wh_mn_cb_cargo","owr_ru_hv_wh_mn_sb_cargo","owr_ru_hv_wh_ai_cb_cargo","owr_ru_hv_wh_ai_sb_cargo","owr_ru_me_tr_mn_cb_cargo","owr_ru_me_tr_mn_sb_cargo","owr_ru_me_tr_ai_cb_cargo","owr_ru_me_tr_ai_sb_cargo","owr_ru_me_wh_mn_cb_cargo","owr_ru_me_wh_mn_sb_cargo","owr_ru_me_wh_ai_cb_cargo","owr_ru_me_wh_ai_sb_cargo","owr_am_hv_tr_mn_cb_cargo","owr_am_hv_tr_mn_sb_cargo","owr_am_hv_tr_ai_cb_cargo","owr_am_hv_tr_ai_sb_cargo","owr_am_me_tr_mn_cb_cargo","owr_am_me_tr_mn_sb_cargo","owr_am_me_tr_ai_cb_cargo","owr_am_me_tr_ai_sb_cargo","owr_am_me_wh_mn_cb_cargo","owr_am_me_wh_mn_el_cargo","owr_am_me_wh_mn_sb_cargo","owr_am_me_wh_ai_cb_cargo","owr_am_me_wh_ai_el_cargo","owr_am_me_wh_ai_sb_cargo"], 15];
												_oilAmount = (_nearestFuelcargo select 0) getVariable "ow_vehicle_cargo";
												(_nearestFuelcargo select 0) setVariable ["ow_vehicle_cargo", _oilAmount - 10, true];
												[_unitToRefuel, 1.0] remoteExec ["setFuel", owner _unitToRefuel];
											}];
										} else {
											_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action3 ctrlSetTooltip "Refuel ( cargo vehicle does not have enough fuel in cargo to refuel )";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										};
									} else {
										if (_cargoVehicle == _vehicle) then {
											// do not search for the fuel in the same cargo vehicle
											if ((count _nearestFuelcargo) > 1) then {
												// try other (if exist)
												_otherCargoVehicle = (_nearestFuelcargo select 1);
												if ((_otherCargoVehicle getVariable "ow_vehicle_cargo_type") == 1) then {
													// content is oil
													if ((_otherCargoVehicle getVariable "ow_vehicle_cargo") >= 10) then {
														_owr_action3 ctrlSetTooltip "Refuel vehicle";
														_owr_action3 ctrlSetTextColor [0.75, 0.75, 0.75, 1];
														_owr_action3 ctrlSetActiveColor [1, 1, 1, 1];
														_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
														_owr_action3 ctrladdeventhandler ["buttonclick", {
															_unitToRefuel = (curatorSelected select 0) select 0;
															_nearestFuelcargo = nearestObjects [_unitToRefuel, ["owr_ru_hv_tr_mn_cb_cargo","owr_ru_hv_tr_mn_sb_cargo","owr_ru_hv_tr_ai_cb_cargo","owr_ru_hv_tr_ai_sb_cargo","owr_ru_hv_wh_mn_cb_cargo","owr_ru_hv_wh_mn_sb_cargo","owr_ru_hv_wh_ai_cb_cargo","owr_ru_hv_wh_ai_sb_cargo","owr_ru_me_tr_mn_cb_cargo","owr_ru_me_tr_mn_sb_cargo","owr_ru_me_tr_ai_cb_cargo","owr_ru_me_tr_ai_sb_cargo","owr_ru_me_wh_mn_cb_cargo","owr_ru_me_wh_mn_sb_cargo","owr_ru_me_wh_ai_cb_cargo","owr_ru_me_wh_ai_sb_cargo","owr_am_hv_tr_mn_cb_cargo","owr_am_hv_tr_mn_sb_cargo","owr_am_hv_tr_ai_cb_cargo","owr_am_hv_tr_ai_sb_cargo","owr_am_me_tr_mn_cb_cargo","owr_am_me_tr_mn_sb_cargo","owr_am_me_tr_ai_cb_cargo","owr_am_me_tr_ai_sb_cargo","owr_am_me_wh_mn_cb_cargo","owr_am_me_wh_mn_el_cargo","owr_am_me_wh_mn_sb_cargo","owr_am_me_wh_ai_cb_cargo","owr_am_me_wh_ai_el_cargo","owr_am_me_wh_ai_sb_cargo"], 15];
															_oilAmount = (_nearestFuelcargo select 1) getVariable "ow_vehicle_cargo";
															(_nearestFuelcargo select 1) setVariable ["ow_vehicle_cargo", _oilAmount - 10, true];
															[_unitToRefuel, 1.0] remoteExec ["setFuel", owner _unitToRefuel];
														}];
													} else {
														_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
														_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
														_owr_action3 ctrlSetTooltip "Refuel ( cargo vehicle does not have enough fuel in cargo to refuel )";
														_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
													};
												} else {
													//hintSilent format ["fail 2 \n %1 \n %2", _otherCargoVehicle, _vehicle];
													_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
													_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
													_owr_action3 ctrlSetTooltip "Refuel ( cargo vehicle does not contain oil )";
													_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
												};
											} else {
												//hintSilent format ["fail 1 \n %1 \n %2", _cargoVehicle, _vehicle];
												_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
												_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
												_owr_action3 ctrlSetTooltip "Refuel ( no fuel connection around vehicle )";
												_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
											};
										} else {
											_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action3 ctrlSetTooltip "Refuel ( cargo vehicle does not contain oil )";
											_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										};
									};
								} else {
									_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
									_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
									_owr_action3 ctrlSetTooltip "Refuel ( no fuel connection around vehicle )";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
								};
							};
						} else {
							_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
							_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
							_owr_action3 ctrlSetTooltip "Refuel ( fuel tank is full )";
							_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
						};
					} else {
						if ((((_vehicle getVariable "ow_vehicle_template") select 1) == 2)) then {
							// electric case
							_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_psol_ca.paa";
							if ((fuel _vehicle) < 0.95) then {
								_nearestFueldepos = nearestObjects [_vehicle, ["factory_am","warehouse_am","power_oil_am","power_sib_am","power_sol_am","factory_ru","warehouse_ru","power_oil_ru","power_sib_ru","factory_ar","warehouse_ar","power_sol_ar","power_oil_ar","power_sib_ar"], 15];
								if ((count _nearestFueldepos) > 0) then {
									_warehouseToCheckForPower = objNull;
									if (((_nearestFueldepos select 0) isKindOf "warehouse_am") || ((_nearestFueldepos select 0) isKindOf "warehouse_ru") || ((_nearestFueldepos select 0) isKindOf "warehouse_ar")) then {
										// warehouse itself
										_warehouseToCheckForPower = (_nearestFueldepos select 0);
									} else {
										// something else than warehouse
										_warehouseToCheckForPower = (_nearestFueldepos select 0) getVariable "ow_build_wrhs";
									};
									if ((_warehouseToCheckForPower getVariable "ow_wrhs_power_avl") > (_warehouseToCheckForPower getVariable "ow_wrhs_power_req")) then {
										_owr_action3 ctrlSetTooltip "Recharge vehicle";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action3 ctrladdeventhandler ["buttonclick", {
											_unitToRefuel = (curatorSelected select 0) select 0;
											[_unitToRefuel, 1.0] remoteExec ["setFuel", owner _unitToRefuel];
											playSound "owr_ui_button_confirm";
										}];
									} else {
										_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action3 ctrlSetTooltip "Recharge ( not enough power to support charge )";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
									};
								} else {
									_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
									_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
									_owr_action3 ctrlSetTooltip "Recharge ( no electric sources around vehicle )";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
								};
							} else {
								_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
								_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
								_owr_action3 ctrlSetTooltip "Recharge ( battery is fully charged )";
								_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
							};
						} else {
							// siberite case
							_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
							_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
							_owr_action3 ctrlSetTooltip "";
							_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
						};
					};

					if ((((_vehicle getVariable "ow_vehicle_template") select 3) == _cargoValue)) then {
						_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_vehicle_flip_ca";
						_owr_action2 ctrlSetTooltip "Put vehicle back to normal state";
						_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action2 ctrladdeventhandler ["buttonclick", {
							_vehicleToFlip = (curatorSelected select 0) select 0;
							[_vehicleToFlip, [0,0,1]] remoteExec ["setVectorUp", owner _vehicleToFlip];
							[_vehicleToFlip, [(getPos _vehicleToFlip) select 0, (getPos _vehicleToFlip) select 1, 10]] remoteExec ["setPos", owner _vehicleToFlip];

							if (((_vehicleToFlip getVariable "ow_vehicle_template") select 2) == 1) then {
								// if ai controlled - cleanup of the crew to prevent being stuck when flipped (vehicle is fine, but they are unable to drive at all)

								{
									_vehicleToFlip deleteVehicleCrew _x
								} forEach (crew _vehicleToFlip);

								_crewSide = "";
								_tempCommander = objNull;
								_curator = objNull;
								if (_vehicleToFlip isKindOf "owr_car_ar") then {
									_crewSide = "I_UAV_AI";
									_tempCommander = guy_from_resistance;
									_curator = bis_curator_arab;
								} else {
									if (_vehicleToFlip isKindOf "owr_car_ru") then {
										_crewSide = "O_UAV_AI";
										_tempCommander = guy_from_east;
										_curator = bis_curator_east;
									} else {
										_crewSide = "B_UAV_AI";
										_tempCommander = guy_from_west;
										_curator = bis_curator_west;
									};
								};

								_ai_driver = (group _tempCommander) createUnit [_crewSide, getPos _tempCommander, [], 0, "FORM"];
								_ai_gunner = (group _tempCommander) createUnit [_crewSide, getPos _tempCommander, [], 0, "FORM"];
								[_ai_driver, _ai_gunner] join grpNull;
								[_ai_gunner] join _ai_driver;

								_ai_driver moveInAny _vehicleToFlip;
								_ai_gunner moveInAny _vehicleToFlip;

								//hintSilent format ["%1 %2 (%3)", _ai_driver, _ai_gunner, vehicle _ai_driver];
								//hintSilent format ["%1 %2 %3", _crewSide, _tempCommander, _curator];

								// set skills based on CPU research
								if (["comp", 0, _curator] call owr_fn_isResearchComplete) then {
									if ((["comp", 1, _curator] call owr_fn_isResearchComplete)) then {
										if ((["comp", 2, _curator] call owr_fn_isResearchComplete)) then {
											{
												//_x setSkill 0.5;
												[_x, 1.0] remoteExec ["setSkill", owner _x];
											} forEach (crew _vehicleToFlip);
										} else {
											{
												//_x setSkill 0.37;
												[_x, 0.85] remoteExec ["setSkill", owner _x];
											} forEach (crew _vehicleToFlip);
										};
									} else {
										{
											//_x setSkill 0.25;
											[_x, 0.75] remoteExec ["setSkill", owner _x];
										} forEach (crew _vehicleToFlip);
									};
								} else {
									// no cpu research at all - ai dumb
									{
										//_x setSkill 0.15;
										[_x, 0.60] remoteExec ["setSkill", owner _x];
									} forEach (crew _vehicleToFlip);
								};
							};
						}];
					} else {
						_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_attack_ca.paa";
						_owr_action2 ctrlSetTooltip "Attack";
						_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action2 ctrladdeventhandler ["buttonclick", {
							_unitToChange = gunner ((curatorSelected select 0) select 0);
							playSound "owr_ui_button_confirm";
							[_unitToChange] spawn owr_fn_attackSomething;
						}];
					};

					/*
					if ((count (crew _vehicle)) > 0) then {
						_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_move_ca.paa";
						_owr_action1 ctrlSetTooltip format ["Change behaviour to %1", [leader ((curatorSelected select 0) select 0)] call owr_fn_unitGetNextBehaviour];
						_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action1 ctrladdeventhandler ["buttonclick", {
							_unitToChange = (curatorSelected select 0) select 0;
							[(leader _unitToChange), ([(leader _unitToChange)] call owr_fn_unitGetNextBehaviour)] remoteExec ["setBehaviour", owner _unitToChange];
							playSound "owr_ui_button_confirm";
						}];
					} else {
						_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_move_ca.paa";
						_owr_action1 ctrlSetTooltip format ["Change behaviour to %1", "( no vehicle crew )"];
						_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action1 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
						_owr_action1 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
					}; 
					*/

					if ((count (crew _vehicle)) > 0) then {
						_owr_action1 ctrlSetText "\A3\ui_f_curator\Data\Logos\arma3_curator_logo_ca.paa";
						_owr_action1 ctrlSetTooltip "Take control";
						_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action1 ctrladdeventhandler ["buttonclick", {
							_unitToTakeControl = (curatorSelected select 0) select 0;
							[driver _unitToTakeControl] spawn owr_fn_remoteControl;
							playSound "owr_ui_button_confirm";
						}];
					} else {
						_owr_action1 ctrlSetText "\A3\ui_f_curator\Data\Logos\arma3_curator_logo_ca.paa";
						_owr_action1 ctrlSetTooltip "Take control ( no crew inside )";
						_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action1 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
						_owr_action1 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
					};
				};
				case 4: {
					// simple building selected (plant, mine..)
					_simpleb = (_selected select 0);
					{
						_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
						_x ctrlSetActiveColor [1, 1, 1, 1];
					} forEach _actionButtons;

					_somethingKnown = false;

					// AM TURRETS
					if ((_simpleb isKindOf "aturret_am") || (_simpleb isKindOf "mturret_am") || (_simpleb isKindOf "owr_base1c_am")) then {
						_somethingKnown = true;
						_turret = _simpleb;
						if (_turret isKindOf "owr_base1c_am") then {
							// manual turret with WEAPON
							// assign _turret to its stand
							_turret = _turret getVariable "ow_turret_stand";
						};

						// has weapon or not?
						if ((_turret getVariable "ow_turret_weapon") != _turret) then {
							_owr_action9 ctrlSetText "";
							_owr_action9 ctrlSetTooltip "";
							_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

							if (isNull (_turret getVariable "ow_build_wrhs")) then {
								_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
								_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action8 ctrladdeventhandler ["buttonclick", {
									_objectToSearchAround = (curatorSelected select 0) select 0;
									if (_objectToSearchAround isKindOf "owr_base1c_am") then {
										_objectToSearchAround = _objectToSearchAround getVariable "ow_turret_stand";
									};
									_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_am"], 150];
									if ((count _warehousesAvailable) > 0) then {
										_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
									};
								}];
							} else {
								_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
								_owr_action8 ctrlSetTooltip "Warehouse connected";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
								_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
							};

							_owr_action7 ctrlSetText "";
							_owr_action7 ctrlSetTooltip "";
							_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

							if (_turret getVariable "ow_build_ready") then {
								_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
								_owr_action6 ctrlSetTooltip "Deconstruct building";
								_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action6 ctrladdeventhandler ["buttonclick", {
									_simplebToUse = (curatorSelected select 0) select 0;
									if (_simplebToUse isKindOf "owr_base1c_am") then {
										_simplebToUse = _simplebToUse getVariable "ow_turret_stand";
									};
									_simplebToUse setVariable ["ow_build_deconstruct", true, true];
									_simplebToUse setVariable ["ow_build_ready", false, true];
									playSound "owr_ui_button_confirm";
								}];
							} else {
								_owr_action6 ctrlSetText "";
								_owr_action6 ctrlSetTooltip "";
								_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
							};

							if (!(_turret getVariable "ow_build_pause")) then {
								_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_pause_ca.paa";
								_owr_action5 ctrlSetTooltip "Switch off";
								_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action5 ctrladdeventhandler ["buttonclick", {
									_turretToUse = (curatorSelected select 0) select 0;
									if (_turretToUse isKindOf "owr_base1c_am") then {
										_turretToUse = _turretToUse getVariable "ow_turret_stand";
									};
									_turretToUse setVariable ["ow_build_pause", true, true];
								}];
							} else {
								_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_start_ca.paa";
								_owr_action5 ctrlSetTooltip "Switch on";
								_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action5 ctrladdeventhandler ["buttonclick", {
									_turretToUse = (curatorSelected select 0) select 0;
									if (_turretToUse isKindOf "owr_base1c_am") then {
										_turretToUse = _turretToUse getVariable "ow_turret_stand";
									};
									_turretToUse setVariable ["ow_build_pause", false, true];
								}];
							};

							_owr_action4 ctrlSetText "";
							_owr_action4 ctrlSetTooltip "";
							_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action3 ctrlSetText "";
							_owr_action3 ctrlSetTooltip "";
							_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_attack_ca.paa";
							_owr_action2 ctrlSetTooltip "Attack";
							_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action2 ctrladdeventhandler ["buttonclick", {
								_actualTurret = objNull;
								if (((curatorSelected select 0) select 0) isKindOf "owr_base1c_am") then {
									_actualTurret = ((curatorSelected select 0) select 0);
								} else {
									_actualTurret = ((curatorSelected select 0) select 0) getVariable "ow_turret_weapon";
								};
								playSound "owr_ui_button_confirm";
								[_actualTurret] spawn owr_fn_attackSomething;
							}];

							if (_turret isKindOf "aturret_am") then {
								_currentSkill = 0.60;
								if ((count (crew (_turret getVariable "ow_turret_weapon"))) > 0) then {
									_currentSkill = (skill (gunner (_turret getVariable "ow_turret_weapon")));
								} else {
									// should not happen, but it does, lets put _currentSkill to zero
									_currentSkill = 0.0;
									// so user can force creating ai gunner manualy by clicking the upgrade buttan
								};
								_currentPossibleSkill = 0.60;
								_techLevel = "0";
								if (["comp", 0, bis_curator_west] call owr_fn_isResearchComplete) then {
									if ((["comp", 1, bis_curator_west] call owr_fn_isResearchComplete)) then {
										if ((["comp", 2, bis_curator_west] call owr_fn_isResearchComplete)) then {
											_currentPossibleSkill = 1.0;
											_techLevel = "3";
										} else {
											_currentPossibleSkill = 0.85;
											_techLevel = "2";
										};
									} else {
										_currentPossibleSkill = 0.75;
										_techLevel = "1";
									};
								};

								_owr_action1 ctrlSetText "\owr\ui\data\research\icon_rescat_comp_ca.paa";
								_owr_action1 ctrlSetTooltip format ["Upgrade AI to tech %1 (current skill is %2, possible skill is %3)", _techLevel, _currentSkill, _currentPossibleSkill];
								_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								if (_currentSkill < _currentPossibleSkill) then {
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_turretToUse = ((curatorSelected select 0) select 0) getVariable "ow_turret_weapon";
										_gunnerAI = objNull;
										if ((count (crew _turretToUse)) > 0) then {
											_gunnerAI = (gunner _turretToUse);
										} else {
											// no crew in the weapon turret? how? hmmm, nvm, lets create it here (again)
											_ai_grp = createGroup west;
											_gunnerAI = _ai_grp createUnit ["B_UAV_AI", getPos _turretToUse, [], 0, "FORM"];
											_gunnerAI moveInAny _turretToUse;
										};
										_currentPossibleSkill = 0.60;
										if (["comp", 0, bis_curator_west] call owr_fn_isResearchComplete) then {
											if ((["comp", 1, bis_curator_west] call owr_fn_isResearchComplete)) then {
												if ((["comp", 2, bis_curator_west] call owr_fn_isResearchComplete)) then {
													_currentPossibleSkill = 1.00;
												} else {
													_currentPossibleSkill = 0.85;
												};
											} else {
												_currentPossibleSkill = 0.75;
											};
										};
										[_gunnerAI, _currentPossibleSkill] remoteExec ["setSkill", owner _turretToUse];
										playSound "owr_ui_button_confirm";
									}];
								} else {
									if ((["comp", 2, bis_curator_west] call owr_fn_isResearchComplete)) then {
										_owr_action1 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetTooltip "Upgrade AI ( cannot be upgraded more )";
									} else {
										_owr_action1 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetTooltip "Upgrade AI ( research computer tech to upgrade )";
									};
								};

							} else {
								_owr_action1 ctrlSetText "";
								_owr_action1 ctrlSetTooltip "";
								_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
							};

							//hintSilent format ["%1", (_turret getVariable "ow_turret_weapon")];
						} else {
							// show available options for weapon manufacturing - when factory is present and ready
							_facReady = false;
							_facUpgraded = false;
							_fac = (_turret getVariable "ow_turret_fac");
							if (_fac != objNull) then {
								if ((_fac getVariable "ow_build_ready") && ((_fac getVariable "ow_wip_progress") >= 1.0)) then {
									_facReady = true;
								};
								if (_fac getVariable "ow_build_upgrade") then {
									_facUpgraded = true;
								};

								if (_facReady) then {
									if (_facUpgraded) then {
										_owr_action9 ctrlSetText "";
										_owr_action9 ctrlSetTooltip "";
										_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

										/*_owr_action8 ctrlSetText "\owr\ui\data\research\icon_res_dlaser_ca.paa";
										_owr_action8 ctrlSetTooltip "Synchronized laser";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										if (false) then {		// ["opto", 8, bis_curator_west] call owr_fn_isResearchComplete
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_turretToUse = (curatorSelected select 0) select 0;
												_turretToUse setVariable ["ow_turret_weaponassign", true, true];
												_factoryToUse = _turretToUse getVariable "ow_turret_fac";
												_factoryToUse setVariable ["ow_factory_wtemplate", 7, true];
												playSound "owr_ui_button_confirm";
											}];	
										} else {
											_owr_action8 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action8 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action8 ctrlSetTooltip "Synchronized laser ( not yet implemented )";
										};*/

										if (_simpleb getVariable "ow_build_ready") then {
											_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
											_owr_action8 ctrlSetTooltip "Deconstruct building";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_simplebToUse = (curatorSelected select 0) select 0;
												_simplebToUse setVariable ["ow_build_deconstruct", true, true];
												_simplebToUse setVariable ["ow_build_ready", false, true];
												playSound "owr_ui_button_confirm";
											}];
										} else {
											_owr_action8 ctrlSetText "";
											_owr_action8 ctrlSetTooltip "";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										};

										_owr_action7 ctrlSetText "\owr\ui\data\research\icon_res_laser_ca.paa";
										_resourceArray = [6] call owr_fn_getAMTurretCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action7 ctrlSetTooltip format ["Laser %1", _costString];
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
										if (["opto", 7, bis_curator_west] call owr_fn_isResearchComplete) then {
											_owr_action7 ctrladdeventhandler ["buttonclick", {
												_turretToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = [6] call owr_fn_getAMTurretCost;
												if ([_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_turretToUse setVariable ["ow_turret_weaponassign", true, true];
													_factoryToUse = _turretToUse getVariable "ow_turret_fac";
													_factoryToUse setVariable ["ow_factory_wtemplate", 6, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];
										} else {
											_owr_action7 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action7 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action7 ctrlSetTooltip "Laser ( missing tech )";
										};

										_owr_action6 ctrlSetText "\owr\ui\data\research\icon_res_heavy_gun_ca.paa";
										_resourceArray = [5] call owr_fn_getAMTurretCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action6 ctrlSetTooltip format ["Heavy cannon %1", _costString];
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
										if (["weap", 6, bis_curator_west] call owr_fn_isResearchComplete && ((_fac getVariable "ow_factory_upgrades") select 1)) then {
											_owr_action6 ctrladdeventhandler ["buttonclick", {
												_turretToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = [5] call owr_fn_getAMTurretCost;
												if ([_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_turretToUse setVariable ["ow_turret_weaponassign", true, true];
													_factoryToUse = _turretToUse getVariable "ow_turret_fac";
													_factoryToUse setVariable ["ow_factory_wtemplate", 5, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];	
										} else {
											_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

											_reasons = "";
											if (!(["weap", 6, bis_curator_west] call owr_fn_isResearchComplete)) then {
												_reasons = _reasons + " missing tech ";
											};
											if (!((_fac getVariable "ow_factory_upgrades") select 1)) then {
												_reasons = _reasons + " missing side upgrade ";
											};
											_owr_action6 ctrlSetTooltip format["Heavy cannon (%1)", _reasons];
										};

										_owr_action5 ctrlSetText "\owr\ui\data\research\icon_res_rocket_launcher_ca.paa";
										_resourceArray = [4] call owr_fn_getAMTurretCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action5 ctrlSetTooltip format ["Vehicle rocket launcher %1", _costString];
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
										if (["weap", 5, bis_curator_west] call owr_fn_isResearchComplete && ((_fac getVariable "ow_factory_upgrades") select 2)) then {
											_owr_action5 ctrladdeventhandler ["buttonclick", {
												_turretToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = [4] call owr_fn_getAMTurretCost;
												if ([_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_turretToUse setVariable ["ow_turret_weaponassign", true, true];
													_factoryToUse = _turretToUse getVariable "ow_turret_fac";
													_factoryToUse setVariable ["ow_factory_wtemplate", 4, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];	
										} else {
											_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

											_reasons = "";
											if (!(["weap", 5, bis_curator_west] call owr_fn_isResearchComplete)) then {
												_reasons = _reasons + " missing tech ";
											};
											if (!((_fac getVariable "ow_factory_upgrades") select 2)) then {
												_reasons = _reasons + " missing side upgrade ";
											};
											_owr_action5 ctrlSetTooltip format["Vehicle rocket launcher (%1)", _reasons];
										};

										_owr_action4 ctrlSetText "\owr\ui\data\research\icon_res_heavy_gun_ca.paa";
										_resourceArray = [3] call owr_fn_getAMTurretCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action4 ctrlSetTooltip format ["Dual cannon %1", _costString];
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
										if (["weap", 4, bis_curator_west] call owr_fn_isResearchComplete && ((_fac getVariable "ow_factory_upgrades") select 1)) then {
											_owr_action4 ctrladdeventhandler ["buttonclick", {
												_turretToUse = (curatorSelected select 0) select 0;
												// get the resources needed
													_resourceArray = [3] call owr_fn_getAMTurretCost;
													if ([_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
														// we have enough resource in warehouse, take them out
														[_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
														// let the upgrade begin
														_turretToUse setVariable ["ow_turret_weaponassign", true, true];
														_factoryToUse = _turretToUse getVariable "ow_turret_fac";
														_factoryToUse setVariable ["ow_factory_wtemplate", 3, true];
														playSound "owr_ui_button_confirm";
													} else {
														playSound "owr_ui_button_cancel";
													};
											}];	
										} else {
											_owr_action4 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action4 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

											_reasons = "";
											if (!(["weap", 4, bis_curator_west] call owr_fn_isResearchComplete)) then {
												_reasons = _reasons + " missing tech ";
											};
											if (!((_fac getVariable "ow_factory_upgrades") select 1)) then {
												_reasons = _reasons + " missing side upgrade ";
											};
											_owr_action4 ctrlSetTooltip format["Dual cannon (%1)", _reasons];
										};

										_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_rot_mgun_ca.paa";
										_resourceArray = [2] call owr_fn_getAMTurretCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action3 ctrlSetTooltip format ["Minigun %1", _costString];
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										if (["weap", 3, bis_curator_west] call owr_fn_isResearchComplete) then {
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_turretToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = [2] call owr_fn_getAMTurretCost;
												if ([_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_turretToUse setVariable ["ow_turret_weaponassign", true, true];
													_factoryToUse = _turretToUse getVariable "ow_turret_fac";
													_factoryToUse setVariable ["ow_factory_wtemplate", 2, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];	
										} else {
											_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action3 ctrlSetTooltip "Minigun (missing tech)";
										};

										_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_gun_ca.paa";
										_resourceArray = [1] call owr_fn_getAMTurretCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action2 ctrlSetTooltip format ["Light cannon %1", _costString];
										_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
										if (["weap", 4, bis_curator_west] call owr_fn_isResearchComplete && ((_fac getVariable "ow_factory_upgrades") select 1)) then {
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_turretToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = [1] call owr_fn_getAMTurretCost;
												if ([_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_turretToUse setVariable ["ow_turret_weaponassign", true, true];
													_factoryToUse = _turretToUse getVariable "ow_turret_fac";
													_factoryToUse setVariable ["ow_factory_wtemplate", 1, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];	
										} else {
											_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

											_reasons = "";
											if (!(["weap", 4, bis_curator_west] call owr_fn_isResearchComplete)) then {
												_reasons = _reasons + " missing tech ";
											};
											if (!((_fac getVariable "ow_factory_upgrades") select 1)) then {
												_reasons = _reasons + " missing side upgrade ";
											};
											_owr_action2 ctrlSetTooltip format["Light cannon (%1)", _reasons];
										};

										_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_gun_ca.paa";
										_resourceArray = [0] call owr_fn_getAMTurretCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action1 ctrlSetTooltip format ["Machine gun %1", _costString];
										_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_turretToUse = (curatorSelected select 0) select 0;
											// get the resources needed
											_resourceArray = [0] call owr_fn_getAMTurretCost;
											if ([_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// let the upgrade begin
												_turretToUse setVariable ["ow_turret_weaponassign", true, true];
												_factoryToUse = _turretToUse getVariable "ow_turret_fac";
												_factoryToUse setVariable ["ow_factory_wtemplate", 0, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];
									} else {
										_owr_action9 ctrlSetText "";
										_owr_action9 ctrlSetTooltip "";
										_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

										if (_simpleb getVariable "ow_build_ready") then {
											_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
											_owr_action8 ctrlSetTooltip "Deconstruct building";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_simplebToUse = (curatorSelected select 0) select 0;
												_simplebToUse setVariable ["ow_build_deconstruct", true, true];
												_simplebToUse setVariable ["ow_build_ready", false, true];
												playSound "owr_ui_button_confirm";
											}];
										} else {
											_owr_action8 ctrlSetText "";
											_owr_action8 ctrlSetTooltip "";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										};

										_owr_action7 ctrlSetText "";
										_owr_action7 ctrlSetTooltip "";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action6 ctrlSetText "";
										_owr_action6 ctrlSetTooltip "";
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action5 ctrlSetText "";
										_owr_action5 ctrlSetTooltip "";
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action4 ctrlSetText "";
										_owr_action4 ctrlSetTooltip "";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action3 ctrlSetText "";
										_owr_action3 ctrlSetTooltip "";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action2 ctrlSetText "";
										_owr_action2 ctrlSetTooltip "";
										_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_gun_ca.paa";
										_resourceArray = [0] call owr_fn_getAMTurretCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action1 ctrlSetTooltip format ["Machine gun %1", _costString];
										_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_turretToUse = (curatorSelected select 0) select 0;
											// get the resources needed
											_resourceArray = [0] call owr_fn_getAMTurretCost;
											if ([_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// let the upgrade begin
												_turretToUse setVariable ["ow_turret_weaponassign", true, true];
												_factoryToUse = _turretToUse getVariable "ow_turret_fac";
												_factoryToUse setVariable ["ow_factory_wtemplate", 0, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];
									};
								} else {
									_owr_action9 ctrlSetText "";
									_owr_action9 ctrlSetTooltip "";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

									if (_simpleb getVariable "ow_build_ready") then {
										_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
										_owr_action8 ctrlSetTooltip "Deconstruct building";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_simplebToUse = (curatorSelected select 0) select 0;
											_simplebToUse setVariable ["ow_build_deconstruct", true, true];
											_simplebToUse setVariable ["ow_build_ready", false, true];
											playSound "owr_ui_button_confirm";
										}];
									} else {
										_owr_action8 ctrlSetText "";
										_owr_action8 ctrlSetTooltip "";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									};

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "";
									_owr_action2 ctrlSetTooltip "";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};
							} else {
								_owr_action9 ctrlSetText "";
								_owr_action9 ctrlSetTooltip "";
								_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

								if (_simpleb getVariable "ow_build_ready") then {
									_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
									_owr_action8 ctrlSetTooltip "Deconstruct building";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrladdeventhandler ["buttonclick", {
										_simplebToUse = (curatorSelected select 0) select 0;
										_simplebToUse setVariable ["ow_build_deconstruct", true, true];
										_simplebToUse setVariable ["ow_build_ready", false, true];
										playSound "owr_ui_button_confirm";
									}];
								} else {
									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								};

								_owr_action7 ctrlSetText "";
								_owr_action7 ctrlSetTooltip "";
								_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action6 ctrlSetText "";
								_owr_action6 ctrlSetTooltip "";
								_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action5 ctrlSetText "";
								_owr_action5 ctrlSetTooltip "";
								_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action4 ctrlSetText "";
								_owr_action4 ctrlSetTooltip "";
								_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action3 ctrlSetText "";
								_owr_action3 ctrlSetTooltip "";
								_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action2 ctrlSetText "";
								_owr_action2 ctrlSetTooltip "";
								_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action1 ctrlSetText "";
								_owr_action1 ctrlSetTooltip "";
								_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
							};
						};
					};


					// RU TURRETS
					if ((_simpleb isKindOf "aturret_ru") || (_simpleb isKIndOf "mturret_ru") || (_simpleb isKindOf "owr_base1c_ru")) then {
						_somethingKnown = true;
						_turret = _simpleb;
						if (_turret isKindOf "owr_base1c_ru") then {
							// manual turret with WEAPON
							// assign _turret to its stand
							_turret = _turret getVariable "ow_turret_stand";
						};

						// has weapon or not?
						if ((_turret getVariable "ow_turret_weapon") != _turret) then {
							_owr_action9 ctrlSetText "";
							_owr_action9 ctrlSetTooltip "";
							_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

							if (isNull (_turret getVariable "ow_build_wrhs")) then {
								_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
								_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action8 ctrladdeventhandler ["buttonclick", {
									_objectToSearchAround = (curatorSelected select 0) select 0;
									if (_objectToSearchAround isKindOf "owr_base1c_ru") then {
										_objectToSearchAround = _objectToSearchAround getVariable "ow_turret_stand";
									};
									_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ru"], 150];
									if ((count _warehousesAvailable) > 0) then {
										_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
									};
								}];
							} else {
								_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
								_owr_action8 ctrlSetTooltip "Warehouse connected";
								_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
								_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
							};

							_owr_action7 ctrlSetText "";
							_owr_action7 ctrlSetTooltip "";
							_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

							if (_turret getVariable "ow_build_ready") then {
								_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
								_owr_action6 ctrlSetTooltip "Deconstruct building";
								_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action6 ctrladdeventhandler ["buttonclick", {
									_simplebToUse = (curatorSelected select 0) select 0;
									if (_simplebToUse isKindOf "owr_base1c_ru") then {
										_simplebToUse = _simplebToUse getVariable "ow_turret_stand";
									};
									_simplebToUse setVariable ["ow_build_deconstruct", true, true];
									_simplebToUse setVariable ["ow_build_ready", false, true];
									playSound "owr_ui_button_confirm";
								}];
							} else {
								_owr_action6 ctrlSetText "";
								_owr_action6 ctrlSetTooltip "";
								_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
							};

							if (!(_turret getVariable "ow_build_pause")) then {
								_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_pause_ca.paa";
								_owr_action5 ctrlSetTooltip "Switch off";
								_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action5 ctrladdeventhandler ["buttonclick", {
									_turretToUse = (curatorSelected select 0) select 0;
									if (_turretToUse isKindOf "owr_base1c_ru") then {
										_turretToUse = _turretToUse getVariable "ow_turret_stand";
									};
									_turretToUse setVariable ["ow_build_pause", true, true];
								}];
							} else {
								_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_start_ca.paa";
								_owr_action5 ctrlSetTooltip "Switch on";
								_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action5 ctrladdeventhandler ["buttonclick", {
									_turretToUse = (curatorSelected select 0) select 0;
									if (_turretToUse isKindOf "owr_base1c_ru") then {
										_turretToUse = _turretToUse getVariable "ow_turret_stand";
									};
									_turretToUse setVariable ["ow_build_pause", false, true];
								}];
							};

							_owr_action4 ctrlSetText "";
							_owr_action4 ctrlSetTooltip "";
							_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action3 ctrlSetText "";
							_owr_action3 ctrlSetTooltip "";
							_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

							_owr_action2 ctrlSetText "\owr\ui\data\actions\icon_action_attack_ca.paa";
							_owr_action2 ctrlSetTooltip "Attack";
							_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action2 ctrladdeventhandler ["buttonclick", {
								_actualTurret = objNull;
								if (((curatorSelected select 0) select 0) isKindOf "owr_base1c_ru") then {
									_actualTurret = ((curatorSelected select 0) select 0);
								} else {
									_actualTurret = ((curatorSelected select 0) select 0) getVariable "ow_turret_weapon";
								};
								playSound "owr_ui_button_confirm";
								[_actualTurret] spawn owr_fn_attackSomething;
							}];

							if (_turret isKindOf "aturret_ru") then {
								_currentSkill = 0.60;
								if ((count (crew (_turret getVariable "ow_turret_weapon"))) > 0) then {
									_currentSkill = (skill (gunner (_turret getVariable "ow_turret_weapon")));
								} else {
									// should not happen, but it does, lets put _currentSkill to zero
									_currentSkill = 0.0;
									// so user can force creating ai gunner manualy by clicking the upgrade buttan
								};
								_currentPossibleSkill = 0.60;
								_techLevel = "0";
								if (["comp", 0, bis_curator_east] call owr_fn_isResearchComplete) then {
									if ((["comp", 1, bis_curator_east] call owr_fn_isResearchComplete)) then {
										if ((["comp", 2, bis_curator_east] call owr_fn_isResearchComplete)) then {
											_currentPossibleSkill = 1.0;
											_techLevel = "3";
										} else {
											_currentPossibleSkill = 0.85;
											_techLevel = "2";
										};
									} else {
										_currentPossibleSkill = 0.75;
										_techLevel = "1";
									};
								};

								_owr_action1 ctrlSetText "\owr\ui\data\research\icon_rescat_comp_ca.paa";
								_owr_action1 ctrlSetTooltip format ["Upgrade AI to tech %1 (current skill is %2, possible skill is %3)", _techLevel, _currentSkill, _currentPossibleSkill];
								_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								if (_currentSkill < _currentPossibleSkill) then {
									_owr_action1 ctrladdeventhandler ["buttonclick", {
										_turretToUse = ((curatorSelected select 0) select 0) getVariable "ow_turret_weapon";
										_gunnerAI = objNull;
										if ((count (crew _turretToUse)) > 0) then {
											_gunnerAI = (gunner _turretToUse);
										} else {
											// no crew in the weapon turret? how? hmmm, nvm, lets create it here (again)
											_ai_grp = createGroup east;
											_gunnerAI = _ai_grp createUnit ["O_UAV_AI", getPos _turretToUse, [], 0, "FORM"];
											[_gunnerAI] join grpNull;
											_gunnerAI moveInAny _turretToUse;
										};
										_currentPossibleSkill = 0.60;
										if (["comp", 0, bis_curator_east] call owr_fn_isResearchComplete) then {
											if ((["comp", 1, bis_curator_east] call owr_fn_isResearchComplete)) then {
												if ((["comp", 2, bis_curator_east] call owr_fn_isResearchComplete)) then {
													_currentPossibleSkill = 1.00;
												} else {
													_currentPossibleSkill = 0.85;
												};
											} else {
												_currentPossibleSkill = 0.75;
											};
										};
										[_gunnerAI, _currentPossibleSkill] remoteExec ["setSkill", owner _turretToUse];
										playSound "owr_ui_button_confirm";
									}];
								} else {
									if ((["comp", 2, bis_curator_east] call owr_fn_isResearchComplete)) then {
										_owr_action1 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetTooltip "Upgrade AI ( cannot be upgraded more )";
									} else {
										_owr_action1 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
										_owr_action1 ctrlSetTooltip "Upgrade AI ( research computer tech to upgrade )";
									};
								};

							} else {
								_owr_action1 ctrlSetText "";
								_owr_action1 ctrlSetTooltip "";
								_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
							};
						} else {
							// show available options for weapon manufacturing - when factory is present and ready
							_facReady = false;
							_facUpgraded = false;
							_fac = (_turret getVariable "ow_turret_fac");
							if (_fac != objNull) then {
								if ((_fac getVariable "ow_build_ready") && ((_fac getVariable "ow_wip_progress") >= 1.0)) then {
									_facReady = true;
								};
								if (_fac getVariable "ow_build_upgrade") then {
									_facUpgraded = true;
								};

								if (_facReady) then {
									if (_facUpgraded) then {
										_owr_action9 ctrlSetText "";
										_owr_action9 ctrlSetTooltip "";
										_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

										if (_simpleb getVariable "ow_build_ready") then {
											_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
											_owr_action8 ctrlSetTooltip "Deconstruct building";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_simplebToUse = (curatorSelected select 0) select 0;
												_simplebToUse setVariable ["ow_build_deconstruct", true, true];
												_simplebToUse setVariable ["ow_build_ready", false, true];
												playSound "owr_ui_button_confirm";
											}];
										} else {
											_owr_action8 ctrlSetText "";
											_owr_action8 ctrlSetTooltip "";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										};

										_owr_action7 ctrlSetText "";
										_owr_action7 ctrlSetTooltip "";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";


										_owr_action6 ctrlSetText "\owr\ui\data\research\icon_res_weap_rocket_ca.paa";
										_owr_action6 ctrlSetTooltip "Rocket";
										_resourceArray = [5] call owr_fn_getRUTurretCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action6 ctrlSetTooltip format ["Rocket %1", _costString];
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
										if (["weap", 7, bis_curator_east] call owr_fn_isResearchComplete && ((_fac getVariable "ow_factory_upgrades") select 2) && ((((_fac getVariable "ow_factory_template") select 0) == 2) || (((_fac getVariable "ow_factory_template") select 0) == 3))) then {
											_owr_action6 ctrladdeventhandler ["buttonclick", {
												_turretToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = [5] call owr_fn_getRUTurretCost;
												if ([_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_turretToUse setVariable ["ow_turret_weaponassign", true, true];
													_factoryToUse = _turretToUse getVariable "ow_turret_fac";
													_factoryToUse setVariable ["ow_factory_wtemplate", 5, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];	
										} else {
											_owr_action6 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action6 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

											_reasons = "";
											if (!(["weap", 7, bis_curator_east] call owr_fn_isResearchComplete)) then {
												_reasons = _reasons + " missing tech ";
											};
											if (!((_fac getVariable "ow_factory_upgrades") select 2)) then {
												_reasons = _reasons + " missing side upgrade ";
											};
											_owr_action6 ctrlSetTooltip format["Rocket (%1)", _reasons];
										};


										_owr_action5 ctrlSetText "\owr\ui\data\research\icon_res_rocket_launcher_ca.paa";
										_resourceArray = [4] call owr_fn_getRUTurretCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action5 ctrlSetTooltip format ["Vehicle rocket launcher %1", _costString];
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
										if (["weap", 5, bis_curator_east] call owr_fn_isResearchComplete && ((_fac getVariable "ow_factory_upgrades") select 2)) then {
											_owr_action5 ctrladdeventhandler ["buttonclick", {
												_turretToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = [4] call owr_fn_getRUTurretCost;
												if ([_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_turretToUse setVariable ["ow_turret_weaponassign", true, true];
													_factoryToUse = _turretToUse getVariable "ow_turret_fac";
													_factoryToUse setVariable ["ow_factory_wtemplate", 4, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];	
										} else {
											_owr_action5 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action5 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

											_reasons = "";
											if (!(["weap", 5, bis_curator_east] call owr_fn_isResearchComplete)) then {
												_reasons = _reasons + " missing tech ";
											};
											if (!((_fac getVariable "ow_factory_upgrades") select 2)) then {
												_reasons = _reasons + " missing side upgrade ";
											};
											_owr_action5 ctrlSetTooltip format["Vehicle rocket launcher (%1)", _reasons];
										};


										_owr_action4 ctrlSetText "\owr\ui\data\research\icon_res_heavy_gun_ca.paa";
										_resourceArray = [3] call owr_fn_getRUTurretCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action4 ctrlSetTooltip format ["Heavy cannon %1", _costString];
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
										if (["weap", 6, bis_curator_east] call owr_fn_isResearchComplete && ((_fac getVariable "ow_factory_upgrades") select 1) && (((_fac getVariable "ow_factory_template") select 0) != 0) && (((_fac getVariable "ow_factory_template") select 0) != 1)) then {
											_owr_action4 ctrladdeventhandler ["buttonclick", {
												_turretToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = [3] call owr_fn_getRUTurretCost;
												if ([_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_turretToUse setVariable ["ow_turret_weaponassign", true, true];
													_factoryToUse = _turretToUse getVariable "ow_turret_fac";
													_factoryToUse setVariable ["ow_factory_wtemplate", 3, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];	
										} else {
											_owr_action4 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action4 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

											_reasons = "";
											if (!(["weap", 6, bis_curator_east] call owr_fn_isResearchComplete)) then {
												_reasons = _reasons + " missing tech ";
											};
											if (!((_fac getVariable "ow_factory_upgrades") select 1)) then {
												_reasons = _reasons + " missing side upgrade ";
											};
											_owr_action4 ctrlSetTooltip format["Heavy cannon (%1)", _reasons];
										};


										_owr_action3 ctrlSetText "\owr\ui\data\research\icon_res_gun_ca.paa";
										_resourceArray = [2] call owr_fn_getRUTurretCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action3 ctrlSetTooltip format ["Cannon %1", _costString];
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
										if (["weap", 4, bis_curator_east] call owr_fn_isResearchComplete && ((_fac getVariable "ow_factory_upgrades") select 1)) then {
											_owr_action3 ctrladdeventhandler ["buttonclick", {
												_turretToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = [2] call owr_fn_getRUTurretCost;
												if ([_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_turretToUse setVariable ["ow_turret_weaponassign", true, true];
													_factoryToUse = _turretToUse getVariable "ow_turret_fac";
													_factoryToUse setVariable ["ow_factory_wtemplate", 2, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];	
										} else {
											_owr_action3 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action3 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];

											_reasons = "";
											if (!(["weap", 4, bis_curator_east] call owr_fn_isResearchComplete)) then {
												_reasons = _reasons + " missing tech ";
											};
											if (!((_fac getVariable "ow_factory_upgrades") select 1)) then {
												_reasons = _reasons + " missing side upgrade ";
											};
											_owr_action3 ctrlSetTooltip format["Cannon (%1)", _reasons];
										};


										_owr_action2 ctrlSetText "\owr\ui\data\research\icon_res_rot_mgun_ca.paa";
										_resourceArray = [1] call owr_fn_getRUTurretCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action2 ctrlSetTooltip format ["Minigun %1", _costString];
										_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
										if (["weap", 3, bis_curator_east] call owr_fn_isResearchComplete) then {
											_owr_action2 ctrladdeventhandler ["buttonclick", {
												_turretToUse = (curatorSelected select 0) select 0;
												// get the resources needed
												_resourceArray = [1] call owr_fn_getRUTurretCost;
												if ([_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
													// we have enough resource in warehouse, take them out
													[_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
													// let the upgrade begin
													_turretToUse setVariable ["ow_turret_weaponassign", true, true];
													_factoryToUse = _turretToUse getVariable "ow_turret_fac";
													_factoryToUse setVariable ["ow_factory_wtemplate", 1, true];
													playSound "owr_ui_button_confirm";
												} else {
													playSound "owr_ui_button_cancel";
												};
											}];	
										} else {
											_owr_action2 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
											_owr_action2 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
											_owr_action2 ctrlSetTooltip "Minigun ( missing tech )";
										};


										_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_gun_ca.paa";
										_resourceArray = [0] call owr_fn_getRUTurretCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action1 ctrlSetTooltip format ["Heavy machine gun %1", _costString];
										_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_turretToUse = (curatorSelected select 0) select 0;
											// get the resources needed
											_resourceArray = [0] call owr_fn_getRUTurretCost;
											if ([_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// let the upgrade begin
												_turretToUse setVariable ["ow_turret_weaponassign", true, true];
												_factoryToUse = _turretToUse getVariable "ow_turret_fac";
												_factoryToUse setVariable ["ow_factory_wtemplate", 0, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];

									} else {
										_owr_action9 ctrlSetText "";
										_owr_action9 ctrlSetTooltip "";
										_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

										if (_simpleb getVariable "ow_build_ready") then {
											_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
											_owr_action8 ctrlSetTooltip "Deconstruct building";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
											_owr_action8 ctrladdeventhandler ["buttonclick", {
												_simplebToUse = (curatorSelected select 0) select 0;
												_simplebToUse setVariable ["ow_build_deconstruct", true, true];
												_simplebToUse setVariable ["ow_build_ready", false, true];
												playSound "owr_ui_button_confirm";
											}];
										} else {
											_owr_action8 ctrlSetText "";
											_owr_action8 ctrlSetTooltip "";
											_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										};

										_owr_action7 ctrlSetText "";
										_owr_action7 ctrlSetTooltip "";
										_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action6 ctrlSetText "";
										_owr_action6 ctrlSetTooltip "";
										_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action5 ctrlSetText "";
										_owr_action5 ctrlSetTooltip "";
										_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action4 ctrlSetText "";
										_owr_action4 ctrlSetTooltip "";
										_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action3 ctrlSetText "";
										_owr_action3 ctrlSetTooltip "";
										_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action2 ctrlSetText "";
										_owr_action2 ctrlSetTooltip "";
										_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

										_owr_action1 ctrlSetText "\owr\ui\data\research\icon_res_gun_ca.paa";
										_resourceArray = [0] call owr_fn_getRUTurretCost;
										_costString = [_resourceArray] call owr_fn_getCostStr;
										_owr_action1 ctrlSetTooltip format ["Heavy machine gun %1", _costString];
										_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action1 ctrladdeventhandler ["buttonclick", {
											_turretToUse = (curatorSelected select 0) select 0;
											// get the resources needed
											_resourceArray = [0] call owr_fn_getRUTurretCost;
											if ([_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsCostCheck) then {
												// we have enough resource in warehouse, take them out
												[_resourceArray, _turretToUse getVariable "ow_build_wrhs"] call owr_fn_wrhsResourceTake;
												// let the upgrade begin
												_turretToUse setVariable ["ow_turret_weaponassign", true, true];
												_factoryToUse = _turretToUse getVariable "ow_turret_fac";
												_factoryToUse setVariable ["ow_factory_wtemplate", 0, true];
												playSound "owr_ui_button_confirm";
											} else {
												playSound "owr_ui_button_cancel";
											};
										}];
									};
								} else {
									_owr_action9 ctrlSetText "";
									_owr_action9 ctrlSetTooltip "";
									_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

									if (_simpleb getVariable "ow_build_ready") then {
										_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
										_owr_action8 ctrlSetTooltip "Deconstruct building";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
										_owr_action8 ctrladdeventhandler ["buttonclick", {
											_simplebToUse = (curatorSelected select 0) select 0;
											_simplebToUse setVariable ["ow_build_deconstruct", true, true];
											_simplebToUse setVariable ["ow_build_ready", false, true];
											playSound "owr_ui_button_confirm";
										}];
									} else {
										_owr_action8 ctrlSetText "";
										_owr_action8 ctrlSetTooltip "";
										_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									};

									_owr_action7 ctrlSetText "";
									_owr_action7 ctrlSetTooltip "";
									_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action6 ctrlSetText "";
									_owr_action6 ctrlSetTooltip "";
									_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action5 ctrlSetText "";
									_owr_action5 ctrlSetTooltip "";
									_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action4 ctrlSetText "";
									_owr_action4 ctrlSetTooltip "";
									_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action3 ctrlSetText "";
									_owr_action3 ctrlSetTooltip "";
									_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action2 ctrlSetText "";
									_owr_action2 ctrlSetTooltip "";
									_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

									_owr_action1 ctrlSetText "";
									_owr_action1 ctrlSetTooltip "";
									_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
								};
							} else {
								_owr_action9 ctrlSetText "";
								_owr_action9 ctrlSetTooltip "";
								_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

								if (_simpleb getVariable "ow_build_ready") then {
									_owr_action8 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
									_owr_action8 ctrlSetTooltip "Deconstruct building";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
									_owr_action8 ctrladdeventhandler ["buttonclick", {
										_simplebToUse = (curatorSelected select 0) select 0;
										_simplebToUse setVariable ["ow_build_deconstruct", true, true];
										_simplebToUse setVariable ["ow_build_ready", false, true];
										playSound "owr_ui_button_confirm";
									}];
								} else {
									_owr_action8 ctrlSetText "";
									_owr_action8 ctrlSetTooltip "";
									_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
								};

								_owr_action7 ctrlSetText "";
								_owr_action7 ctrlSetTooltip "";
								_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action6 ctrlSetText "";
								_owr_action6 ctrlSetTooltip "";
								_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action5 ctrlSetText "";
								_owr_action5 ctrlSetTooltip "";
								_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action4 ctrlSetText "";
								_owr_action4 ctrlSetTooltip "";
								_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action3 ctrlSetText "";
								_owr_action3 ctrlSetTooltip "";
								_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action2 ctrlSetText "";
								_owr_action2 ctrlSetTooltip "";
								_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

								_owr_action1 ctrlSetText "";
								_owr_action1 ctrlSetTooltip "";
								_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
							};
						};
					};


					// OIL MINES
					if ((_simpleb isKindOf "source_oil_am") || (_simpleb isKIndOf "source_oil_ru") || (_simpleb isKIndOf "source_oil_ar")) then {
						_somethingKnown = true;

						_owr_action9 ctrlSetText "";
						_owr_action9 ctrlSetTooltip "";
						_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

						if (isNull (_simpleb getVariable "ow_build_wrhs")) then {
							_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
							_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
							_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action8 ctrladdeventhandler ["buttonclick", {
								_objectToSearchAround = (curatorSelected select 0) select 0;
								switch (typeOf _objectToSearchAround) do {
									case "source_oil_am": {
										_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_am"], 150];
										if ((count _warehousesAvailable) > 0) then {
											_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
										};
									};
									case "source_oil_ru": {
										_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ru"], 150];
										if ((count _warehousesAvailable) > 0) then {
											_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
										};
									};
									case "source_oil_ar": {
										_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ar"], 150];
										if ((count _warehousesAvailable) > 0) then {
											_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
										};
									};
								};
							}];
						} else {
							_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
							_owr_action8 ctrlSetTooltip "Warehouse connected";
							_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
							_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
						};

						_currBasicLevel = 0;
						_curatorToCheck = bis_curator_west;
						if (_simpleb isKindOf "source_oil_ru") then {
							_curatorToCheck = bis_curator_east;
						} else {
							if (_simpleb isKindOf "source_oil_ar") then {
								//_curatorToCheck = bis_curator_arab;
							};
						};

						if (["basic", 0, _curatorToCheck] call owr_fn_isResearchComplete) then {
							if (["basic", 1, _curatorToCheck] call owr_fn_isResearchComplete) then {
								if (["basic", 2, _curatorToCheck] call owr_fn_isResearchComplete) then {
									_currBasicLevel = 3;
								} else {
									_currBasicLevel = 2;
								};
							} else {
								_currBasicLevel = 1;
							};
						};

						if ((_simpleb getVariable "ow_resourcemine_level") != _currBasicLevel) then {
							_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_bupgrade_ca.paa";
							_owr_action7 ctrlSetTooltip format ["Upgrade drilling frequency to level %1", _currBasicLevel];
							_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action7 ctrladdeventhandler ["buttonclick", {
								_objectToUpgrade = (curatorSelected select 0) select 0;
								_curatorToCheck = bis_curator_west;
								switch (typeOf _objectToUpgrade) do {
									case "source_oil_am": {
										_curatorToCheck = bis_curator_west;
									};
									case "source_oil_ru": {
										_curatorToCheck = bis_curator_east;
									};
									case "source_oil_ar": {
										//_curatorToCheck = bis_curator_arab;
									};
								};
								_currBasicLevel = 0;
								if (["basic", 0, _curatorToCheck] call owr_fn_isResearchComplete) then {
									if (["basic", 1, _curatorToCheck] call owr_fn_isResearchComplete) then {
										if (["basic", 2, _curatorToCheck] call owr_fn_isResearchComplete) then {
											_currBasicLevel = 3;
										} else {
											_currBasicLevel = 2;
										};
									} else {
										_currBasicLevel = 1;
									};
								};
								_objectToUpgrade setVariable ["ow_resourcemine_level", _currBasicLevel, true];
								_objectToUpgrade setVariable ["ow_resourcemine_refresh", true, true];
							}];
						} else {
							if ((_simpleb getVariable "ow_resourcemine_level") != 3) then {
								_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_bupgrade_ca.paa";
								_owr_action7 ctrlSetTooltip format ["Basic tech level %1 needed to upgrade this drill", (_simpleb getVariable "ow_resourcemine_level") + 1];
								_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action7 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
								_owr_action7 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
							} else {
								_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_bupgrade_ca.paa";
								_owr_action7 ctrlSetTooltip "Cannot be upgraded more";
								_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action7 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
								_owr_action7 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
							};
						};

						if (_simpleb getVariable "ow_build_ready") then {
							_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
							_owr_action6 ctrlSetTooltip "Deconstruct building";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action6 ctrladdeventhandler ["buttonclick", {
								_simplebToUse = (curatorSelected select 0) select 0;
								_simplebToUse setVariable ["ow_build_deconstruct", true, true];
								_simplebToUse setVariable ["ow_build_ready", false, true];
								playSound "owr_ui_button_confirm";
							}];
						} else {
							_owr_action6 ctrlSetText "";
							_owr_action6 ctrlSetTooltip "";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
						};

						_owr_action5 ctrlSetText "";
						_owr_action5 ctrlSetTooltip "";
						_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action4 ctrlSetText "";
						_owr_action4 ctrlSetTooltip "";
						_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action3 ctrlSetText "";
						_owr_action3 ctrlSetTooltip "";
						_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action2 ctrlSetText "";
						_owr_action2 ctrlSetTooltip "";
						_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action1 ctrlSetText "";
						_owr_action1 ctrlSetTooltip "";
						_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
					};
					// SIBERITE MINES
					if ((_simpleb isKindOf "source_sib_am") || (_simpleb isKIndOf "source_sib_ru") || (_simpleb isKIndOf "source_sib_ar")) then {
						_somethingKnown = true;

						_owr_action9 ctrlSetText "";
						_owr_action9 ctrlSetTooltip "";
						_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

						if (isNull (_simpleb getVariable "ow_build_wrhs")) then {
							_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
							_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
							_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action8 ctrladdeventhandler ["buttonclick", {
								_objectToSearchAround = (curatorSelected select 0) select 0;
								switch (typeOf _objectToSearchAround) do {
									case "source_sib_am": {
										_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_am"], 150];
										if ((count _warehousesAvailable) > 0) then {
											_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
										};
									};
									case "source_sib_ru": {
										_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ru"], 150];
										if ((count _warehousesAvailable) > 0) then {
											_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
										};
									};
									case "source_sib_ar": {
										_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ar"], 150];
										if ((count _warehousesAvailable) > 0) then {
											_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
										};
									};
								};
							}];
						} else {
							_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
							_owr_action8 ctrlSetTooltip "Warehouse connected";
							_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
							_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
						};

						_currSibLevel = 0;
						_curatorToCheck = bis_curator_west;
						_wordForSiberite = "Siberite";
						if (_simpleb isKindOf "source_sib_ru") then {
							_curatorToCheck = bis_curator_east;
							_wordForSiberite = "Alaskite";
						} else {
							if (_simpleb isKindOf "source_sib_ar") then {
								//_curatorToCheck = bis_curator_arab;
							};
						};

						if (["siberite", 0, _curatorToCheck] call owr_fn_isResearchComplete) then {
							if (["siberite", 1, _curatorToCheck] call owr_fn_isResearchComplete) then {
								if (["siberite", 2, _curatorToCheck] call owr_fn_isResearchComplete) then {
									_currSibLevel = 3;
								} else {
									_currSibLevel = 2;
								};
							} else {
								_currSibLevel = 1;
							};
						};
						// 

						if ((_simpleb getVariable "ow_resourcemine_level") != _currSibLevel) then {
							_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_bupgrade_ca.paa";
							_owr_action7 ctrlSetTooltip format ["Upgrade mine frequency to level %1", _currSibLevel];
							_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action7 ctrladdeventhandler ["buttonclick", {
								_objectToUpgrade = (curatorSelected select 0) select 0;
								_curatorToCheck = bis_curator_west;
								switch (typeOf _objectToUpgrade) do {
									case "source_sib_am": {
										_curatorToCheck = bis_curator_west;
									};
									case "source_sib_ru": {
										_curatorToCheck = bis_curator_east;
									};
									case "source_sib_ar": {
										//_curatorToCheck = bis_curator_arab;
									};
								};
								_currSibLevel = 0;
								if (["siberite", 0, _curatorToCheck] call owr_fn_isResearchComplete) then {
									if (["siberite", 1, _curatorToCheck] call owr_fn_isResearchComplete) then {
										if (["siberite", 2, _curatorToCheck] call owr_fn_isResearchComplete) then {
											_currSibLevel = 3;
										} else {
											_currSibLevel = 2;
										};
									} else {
										_currSibLevel = 1;
									};
								};
								_objectToUpgrade setVariable ["ow_resourcemine_level", _currSibLevel, true];
								_objectToUpgrade setVariable ["ow_resourcemine_refresh", true, true];
							}];
						} else {
							if ((_simpleb getVariable "ow_resourcemine_level") != 3) then {
								_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_bupgrade_ca.paa";
								_owr_action7 ctrlSetTooltip format ["%1 tech level %2 needed to upgrade this mine", _wordForSiberite, (_simpleb getVariable "ow_resourcemine_level") + 1];
								_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action7 ctrlSetTextColor [0.5, 0.5, 0.5, 1];
								_owr_action7 ctrlSetActiveColor [0.5, 0.5, 0.5, 1];
							} else {
								_owr_action7 ctrlSetText "\owr\ui\data\actions\icon_action_bupgrade_ca.paa";
								_owr_action7 ctrlSetTooltip "Cannot be upgraded more";
								_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
								_owr_action7 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
								_owr_action7 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
							};
						};

						if (_simpleb getVariable "ow_build_ready") then {
							_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
							_owr_action6 ctrlSetTooltip "Deconstruct building";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action6 ctrladdeventhandler ["buttonclick", {
								_simplebToUse = (curatorSelected select 0) select 0;
								_simplebToUse setVariable ["ow_build_deconstruct", true, true];
								_simplebToUse setVariable ["ow_build_ready", false, true];
								playSound "owr_ui_button_confirm";
							}];
						} else {
							_owr_action6 ctrlSetText "";
							_owr_action6 ctrlSetTooltip "";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
						};

						_owr_action5 ctrlSetText "";
						_owr_action5 ctrlSetTooltip "";
						_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action4 ctrlSetText "";
						_owr_action4 ctrlSetTooltip "";
						_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action3 ctrlSetText "";
						_owr_action3 ctrlSetTooltip "";
						_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action2 ctrlSetText "";
						_owr_action2 ctrlSetTooltip "";
						_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action1 ctrlSetText "";
						_owr_action1 ctrlSetTooltip "";
						_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
					};

					// OIL POWER PLANTS
					if ((_simpleb isKindOf "power_oil_am") || (_simpleb isKindOf "power_oil_ru") || (_simpleb isKindOf "power_oil_ar")) then {
						_somethingKnown = true;

						_owr_action9 ctrlSetText "";
						_owr_action9 ctrlSetTooltip "";
						_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

						if (isNull (_simpleb getVariable "ow_build_wrhs")) then {
							_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
							_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
							_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action8 ctrladdeventhandler ["buttonclick", {
								_objectToSearchAround = (curatorSelected select 0) select 0;
								switch (typeOf _objectToSearchAround) do {
									case "power_oil_am": {
										_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_am"], 150];
										if ((count _warehousesAvailable) > 0) then {
											_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
											_objectToSearchAround setVariable ["ow_powerplant_refresh", true, true];
										};
									};
									case "power_oil_ru": {
										_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ru"], 150];
										if ((count _warehousesAvailable) > 0) then {
											_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
											_objectToSearchAround setVariable ["ow_powerplant_refresh", true, true];
										};
									};
									/*case "power_oil_ar": {
										_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ar"], 150];
										if ((count _warehousesAvailable) > 0) then {
											_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
											_objectToSearchAround setVariable ["ow_powerplant_refresh", true, true];
										};
									};*/
								};
							}];
						} else {
							_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
							_owr_action8 ctrlSetTooltip "Warehouse connected";
							_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
							_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
						};

						_owr_action7 ctrlSetText "";
						_owr_action7 ctrlSetTooltip "";
						_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

						if (_simpleb getVariable "ow_build_ready") then {
							_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
							_owr_action6 ctrlSetTooltip "Deconstruct building";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action6 ctrladdeventhandler ["buttonclick", {
								_simplebToUse = (curatorSelected select 0) select 0;
								_simplebToUse setVariable ["ow_build_deconstruct", true, true];
								_simplebToUse setVariable ["ow_build_ready", false, true];
								playSound "owr_ui_button_confirm";
							}];
						} else {
							_owr_action6 ctrlSetText "";
							_owr_action6 ctrlSetTooltip "";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
						};

						if (!(_simpleb getVariable "ow_build_pause")) then {
							_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_pause_ca.paa";
							_owr_action5 ctrlSetTooltip "Switch off";
							_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action5 ctrladdeventhandler ["buttonclick", {
								_plantToUse = (curatorSelected select 0) select 0;
								_plantToUse setVariable ["ow_build_pause", true, true];
							}];
						} else {
							_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_start_ca.paa";
							_owr_action5 ctrlSetTooltip "Switch on";
							_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action5 ctrladdeventhandler ["buttonclick", {
								_plantToUse = (curatorSelected select 0) select 0;
								_plantToUse setVariable ["ow_build_pause", false, true];
							}];
						};

						_owr_action4 ctrlSetText "";
						_owr_action4 ctrlSetTooltip "";
						_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action3 ctrlSetText "";
						_owr_action3 ctrlSetTooltip "";
						_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action2 ctrlSetText "";
						_owr_action2 ctrlSetTooltip "";
						_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action1 ctrlSetText "";
						_owr_action1 ctrlSetTooltip "";
						_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
					};

					// SIBERITE POWER PLANTS
					if ((_simpleb isKindOf "power_sib_am") || (_simpleb isKindOf "power_sib_ru") || (_simpleb isKindOf "power_sib_ar")) then {
						_somethingKnown = true;

						_owr_action9 ctrlSetText "";
						_owr_action9 ctrlSetTooltip "";
						_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

						if (isNull (_simpleb getVariable "ow_build_wrhs")) then {
							_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
							_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
							_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action8 ctrladdeventhandler ["buttonclick", {
								_objectToSearchAround = (curatorSelected select 0) select 0;
								switch (typeOf _objectToSearchAround) do {
									case "power_sib_am": {
										_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_am"], 150];
										if ((count _warehousesAvailable) > 0) then {
											_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
											_objectToSearchAround setVariable ["ow_powerplant_refresh", true, true];
										};
									};
									case "power_sib_ru": {
										_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ru"], 150];
										if ((count _warehousesAvailable) > 0) then {
											_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
											_objectToSearchAround setVariable ["ow_powerplant_refresh", true, true];
										};
									};
									/*case "power_oil_ar": {
										_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_ar"], 150];
										if ((count _warehousesAvailable) > 0) then {
											_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
											_objectToSearchAround setVariable ["ow_powerplant_refresh", true, true];
										};
									};*/
								};
							}];
						} else {
							_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
							_owr_action8 ctrlSetTooltip "Warehouse connected";
							_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
							_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
						};

						_owr_action7 ctrlSetText "";
						_owr_action7 ctrlSetTooltip "";
						_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

						if (_simpleb getVariable "ow_build_ready") then {
							_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
							_owr_action6 ctrlSetTooltip "Deconstruct building";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action6 ctrladdeventhandler ["buttonclick", {
								_simplebToUse = (curatorSelected select 0) select 0;
								_simplebToUse setVariable ["ow_build_deconstruct", true, true];
								_simplebToUse setVariable ["ow_build_ready", false, true];
								playSound "owr_ui_button_confirm";
							}];
						} else {
							_owr_action6 ctrlSetText "";
							_owr_action6 ctrlSetTooltip "";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
						};

						if (!(_simpleb getVariable "ow_build_pause")) then {
							_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_pause_ca.paa";
							_owr_action5 ctrlSetTooltip "Switch off";
							_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action5 ctrladdeventhandler ["buttonclick", {
								_plantToUse = (curatorSelected select 0) select 0;
								_plantToUse setVariable ["ow_build_pause", true, true];
							}];
						} else {
							_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_start_ca.paa";
							_owr_action5 ctrlSetTooltip "Switch on";
							_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action5 ctrladdeventhandler ["buttonclick", {
								_plantToUse = (curatorSelected select 0) select 0;
								_plantToUse setVariable ["ow_build_pause", false, true];
							}];
						};

						_owr_action4 ctrlSetText "";
						_owr_action4 ctrlSetTooltip "";
						_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action3 ctrlSetText "";
						_owr_action3 ctrlSetTooltip "";
						_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action2 ctrlSetText "";
						_owr_action2 ctrlSetTooltip "";
						_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action1 ctrlSetText "";
						_owr_action1 ctrlSetTooltip "";
						_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
					};

					// SOLAR POWER PLANTS
					if ((_simpleb isKindOf "power_sol_am") || (_simpleb isKindOf "power_sol_ar")) then {
						_somethingKnown = true;

						_owr_action9 ctrlSetText "";
						_owr_action9 ctrlSetTooltip "";
						_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";

						if (isNull (_simpleb getVariable "ow_build_wrhs")) then {
							_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
							_owr_action8 ctrlSetTooltip "Reconnect to closest warehouse";
							_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action8 ctrladdeventhandler ["buttonclick", {
								_objectToSearchAround = (curatorSelected select 0) select 0;
								_warehousesAvailable = nearestObjects [getPos _objectToSearchAround, ["warehouse_am"], 150];
								if ((count _warehousesAvailable) > 0) then {
									_objectToSearchAround setVariable ["ow_build_wrhs", (_warehousesAvailable select 0), true];
									_objectToSearchAround setVariable ["ow_powerplant_refresh", true, true];
								};
							}];
						} else {
							_owr_action8 ctrlSetText "\owr\ui\data\buildings\icon_warehouse_ca.paa";
							_owr_action8 ctrlSetTooltip "Warehouse connected";
							_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action8 ctrlSetTextColor [0.0, 0.75, 0.0, 1];
							_owr_action8 ctrlSetActiveColor [0.0, 0.75, 0.0, 1];
						};

						_owr_action7 ctrlSetText "";
						_owr_action7 ctrlSetTooltip "";
						_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";

						if (_simpleb getVariable "ow_build_ready") then {
							_owr_action6 ctrlSetText "\owr\ui\data\actions\icon_action_recycle_ca.paa";
							_owr_action6 ctrlSetTooltip "Deconstruct building";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action6 ctrladdeventhandler ["buttonclick", {
								_simplebToUse = (curatorSelected select 0) select 0;
								_simplebToUse setVariable ["ow_build_deconstruct", true, true];
								_simplebToUse setVariable ["ow_build_ready", false, true];
								playSound "owr_ui_button_confirm";
							}];
						} else {
							_owr_action6 ctrlSetText "";
							_owr_action6 ctrlSetTooltip "";
							_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
						};

						if (!(_simpleb getVariable "ow_build_pause")) then {
							_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_pause_ca.paa";
							_owr_action5 ctrlSetTooltip "Switch off";
							_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action5 ctrladdeventhandler ["buttonclick", {
								_plantToUse = (curatorSelected select 0) select 0;
								_plantToUse setVariable ["ow_build_pause", true, true];
							}];
						} else {
							_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_start_ca.paa";
							_owr_action5 ctrlSetTooltip "Switch on";
							_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
							_owr_action5 ctrladdeventhandler ["buttonclick", {
								_plantToUse = (curatorSelected select 0) select 0;
								_plantToUse setVariable ["ow_build_pause", false, true];
							}];
						};

						_owr_action4 ctrlSetText "";
						_owr_action4 ctrlSetTooltip "";
						_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action3 ctrlSetText "";
						_owr_action3 ctrlSetTooltip "";
						_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action2 ctrlSetText "";
						_owr_action2 ctrlSetTooltip "";
						_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action1 ctrlSetText "";
						_owr_action1 ctrlSetTooltip "";
						_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
					};

					// case for other objects (such as sources - we do not want to handle those in here)
					if (!_somethingKnown) then {
						{
							_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
							_x ctrlSetActiveColor [1, 1, 1, 1];
						} forEach _actionButtons;

						_owr_action9 ctrlSetText "";
						_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action8 ctrlSetText "";
						_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action7 ctrlSetText "";
						_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action6 ctrlSetText "";
						_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action5 ctrlSetText "";
						_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action4 ctrlSetText "";
						_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action3 ctrlSetText "";
						_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action2 ctrlSetText "";
						_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action1 ctrlSetText "";
						_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
					};
				};


				case 5: {
					// SOMETHING ELSE SELECTED!
					{
						_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
						_x ctrlSetActiveColor [1, 1, 1, 1];
					} forEach _actionButtons;

					_whatIsIt = (_selected select 0);

					if (_whatIsIt getVariable "ow_misc_object") then {
						// oh, its misc object placed by curator, offer delete action then!
						_owr_action9 ctrlSetText "";
						_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action8 ctrlSetText "";
						_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action7 ctrlSetText "";
						_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action6 ctrlSetText "";
						_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

						_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
						_owr_action5 ctrlSetTooltip "Delete object";
						_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action5 ctrladdeventhandler ["buttonclick", {
							_objectToDelete = (curatorSelected select 0) select 0;
							deleteVehicle _objectToDelete;
							playSound "owr_ui_button_cancel";
						}];	

						_owr_action4 ctrlSetText "";
						_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action3 ctrlSetText "";
						_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action2 ctrlSetText "";
						_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action1 ctrlSetText "";
						_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
					} else {
						_owr_action9 ctrlSetText "";
						_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action8 ctrlSetText "";
						_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action7 ctrlSetText "";
						_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action6 ctrlSetText "";
						_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action5 ctrlSetText "";
						_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action4 ctrlSetText "";
						_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action3 ctrlSetText "";
						_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action2 ctrlSetText "";
						_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action1 ctrlSetText "";
						_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
					};
					// ow_misc_object
				};

				case 6: {
					// dead personnel
					// clear all actions - nothing selected
					{
						_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
						_x ctrlSetActiveColor [1, 1, 1, 1];
					} forEach _actionButtons;

					_owr_action9 ctrlSetText "";
					_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action8 ctrlSetText "";
					_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action7 ctrlSetText "";
					_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action6 ctrlSetText "";
					_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

					_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_rip_ca.paa";
					_owr_action5 ctrlSetTooltip "R.I.P.";
					_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";

					_owr_action4 ctrlSetText "";
					_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action3 ctrlSetText "";
					_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action2 ctrlSetText "";
					_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action1 ctrlSetText "";
					_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
				};

				case 7: {
					// destroyed vehicle
					// clear all actions - nothing selected
					{
						_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
						_x ctrlSetActiveColor [1, 1, 1, 1];
					} forEach _actionButtons;

					_owr_action9 ctrlSetText "";
					_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action8 ctrlSetText "";
					_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action7 ctrlSetText "";
					_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action6 ctrlSetText "";
					_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";

					_owr_action5 ctrlSetText "\owr\ui\data\actions\icon_action_cancel_ca.paa";
					_owr_action5 ctrlSetTooltip "Delete vehicle";
					_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action5 ctrladdeventhandler ["buttonclick", {
						_objectToDelete = (curatorSelected select 0) select 0;
						if ((_objectToDelete isKindOf "aturret_am") || (_objectToDelete isKindOf "aturret_ru")) then {
							if (_objectToDelete != (_objectToDelete getVariable "ow_turret_weapon")) then {
								deleteVehicle (_objectToDelete getVariable "ow_turret_weapon");
								deleteVehicle _objectToDelete;
							} else {
								deleteVehicle _objectToDelete;
							};
						} else {
							if ((_objectToDelete isKindOf "owr_base1c")) then {
								deleteVehicle (_objectToDelete getVariable "ow_turret_stand");
								deleteVehicle _objectToDelete;
							} else {
								deleteVehicle _objectToDelete;
							};
						};
						playSound "owr_ui_button_cancel";
					}];	

					_owr_action4 ctrlSetText "";
					_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action3 ctrlSetText "";
					_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action2 ctrlSetText "";
					_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action1 ctrlSetText "";
					_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
				};

				case 8: {
					// multi selection of ow_manbase
					// clear all actions - nothing selected
					{
						_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
						_x ctrlSetActiveColor [1, 1, 1, 1];
					} forEach _actionButtons;

					_owr_action9 ctrlSetText "";
					_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action8 ctrlSetText "";
					_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action7 ctrlSetText "";
					_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action6 ctrlSetText "";
					_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action5 ctrlSetText "";
					_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action4 ctrlSetText "";
					_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";

					// first in selection to get active or passive mode so we can start changing it to something else
					_owman = (_selected select 0);
					if ((_owman getVariable "ow_aitype") == 0) then {
						_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_standstill_ca.paa";
						_owr_action3 ctrlSetTooltip "Stationary mode";
						_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action3 ctrladdeventhandler ["buttonclick", {
							_unitsToChange = (curatorSelected select 0);
							{
								_x setVariable ["ow_aitype", 1, true];
							} foreach _unitsToChange;
							playSound "owr_ui_button_confirm";
						}];
					} else {
						_owr_action3 ctrlSetText "\owr\ui\data\actions\icon_action_free_ca.paa";
						_owr_action3 ctrlSetTooltip "Active mode";
						_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
						_owr_action3 ctrladdeventhandler ["buttonclick", {
							_unitsToChange = (curatorSelected select 0);
							{
								_x setVariable ["ow_aitype", 0, true];
								[_x] call owr_fn_stopUnit;
							} foreach _unitsToChange;
							playSound "owr_ui_button_confirm";
						}];
					};

					_owr_action2 ctrlSetText "";
					_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";

					// changing behaviour to several units at once based on the behaviour of first in selection
					_owr_action1 ctrlSetText "\owr\ui\data\actions\icon_action_move_ca.paa";
					_owr_action1 ctrlSetTooltip format ["Change behaviour to %1", [(curatorSelected select 0) select 0] call owr_fn_unitGetNextBehaviour];
					_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action1 ctrladdeventhandler ["buttonclick", {
						_unitsToChange = (curatorSelected select 0);
						_nextBehaviour = [_unitsToChange select 0] call owr_fn_unitGetNextBehaviour;
						{
							[_x, _nextBehaviour] remoteExec ["setBehaviour", owner _x];
						} foreach _unitsToChange;
						playSound "owr_ui_button_confirm";
					}];
				};

				case 0: {
					// clear all actions - nothing selected
					{
						_x ctrlSetTextColor [0.75, 0.75, 0.75, 1];
						_x ctrlSetActiveColor [1, 1, 1, 1];
					} forEach _actionButtons;

					_owr_action9 ctrlSetText "";
					_owr_action9 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action8 ctrlSetText "";
					_owr_action8 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action7 ctrlSetText "";
					_owr_action7 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action6 ctrlSetText "";
					_owr_action6 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action5 ctrlSetText "";
					_owr_action5 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action4 ctrlSetText "";
					_owr_action4 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action3 ctrlSetText "";
					_owr_action3 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action2 ctrlSetText "";
					_owr_action2 ctrlRemoveAllEventHandlers "buttonclick";
					_owr_action1 ctrlSetText "";
					_owr_action1 ctrlRemoveAllEventHandlers "buttonclick";
				};
				default {};
			};

			sleep 0.1;
		};
	};
};