if (!(isServer)) then {
	// view dist
	setViewDistance 1000;
	// time stuff
	_timeSelected = ["DynTime"] call BIS_fnc_getParamValue;
	switch (_timeSelected) do {
		case 0: {
			// morning
			setDate [2016,7,26,4,38];
		};
		case 1: {
			// noon
			setDate [2016,7,26,12,0];
		};
		case 2: {
			// afternoon
			setDate [2016,7,26,15,38];
		};
		case 3: {
			// midnight
			setDate [2016,7,26,0,0];
		};
		case 4: {
			// faster time - can create significant client lag when in environment with higher latencies
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
		};
	};
};

_debugModeParam = ["CheatMode"] call BIS_fnc_getParamValue;

owr_devhax = false;

if (_debugModeParam == 1) then {
	owr_devhax = true;
};

// addon functions
// main function init (client-side functions)
call compile preprocessFileLineNumbers "\owr\scripts\functions\initFnClient.sqf";

// in-line functions (some of them can override what is inside initFnClient.sqf)
owr_fn_taskManagerSide = {
	_playerSide = _this select 0;
	_enemyPosition = _this select 1;
	_unitToInform = _this select 2;

	_destroyEnemy = _unitToInform createSimpleTask ["Destroy enemy forces"];
	_destroyEnemy setSimpleTaskDestination _enemyPosition;
	_destroyEnemy setSimpleTaskDescription [
	   "Killing all enemy personnel will secure win in this scenario.",
	   "Destroy enemy forces",
	   "Destroy enemy forces"
	];

	// announce change
	_destroyEnemy setTaskState "Assigned";
	["TaskAssigned",["","Destroy enemy forces"]] call BIS_fnc_showNotification;

	_charArrayStatic = [];
	_charArrayDynamic = [];
	switch (_playerSide) do {
		case west: {
			_charArrayStatic = bis_curator_east getVariable "owr_ru_characters";
			_charArrayDynamic = bis_curator_east getVariable "owr_ru_characters_d";
		};
		case east: {
			_charArrayStatic = bis_curator_west getVariable "owr_am_characters";
			_charArrayDynamic = bis_curator_west getVariable "owr_am_characters_d";
		};
		case resistance: {
			// todo
		};
	};

	_enemyCharsNotAlive = false;
	while {!_enemyCharsNotAlive} do {
		_enemyCharsNotAlive = true;
		{
			if (alive _x) then {
				_enemyCharsNotAlive = false;
			};
		} foreach _charArrayStatic;
		{
			if ((_x != objNull) && (alive _x)) then {
				_enemyCharsNotAlive = false;
			};
		} foreach _charArrayDynamic;
		sleep 1;
	};

	_destroyEnemy setTaskState "Succeeded";
	["Tasksucceeded",["","Destroy enemy forces"]] call BIS_fnc_showNotification;

	switch (_playerSide) do {
		case west: {
			owr_stopmusic = true;
			"EventTrack02_F_Curator" remoteExec ["playMusic", 0];
			playMusic "owr_am_vic";
		};
		case east: {
			owr_stopmusic = true;
			"EventTrack02_F_Curator" remoteExec ["playMusic", 0];
			playMusic "owr_ru_vic";
		};
		case resistance: {
			owr_stopmusic = true;
			"EventTrack02_F_Curator" remoteExec ["playMusic", 0];
			playMusic "owr_ar_vic";
		};
		default {};
	};
};

// addon state machines
owr_fn_barracks = compile preprocessFileLineNumbers "\owr\scripts\statemachines\buildings\barracks\barracks.sqf";
owr_fn_factory = compile preprocessFileLineNumbers "\owr\scripts\statemachines\buildings\factory\factory.sqf";
owr_fn_aturret = compile preprocessFileLineNumbers "\owr\scripts\statemachines\buildings\aturret\aturret.sqf";
owr_fn_mturret = compile preprocessFileLineNumbers "\owr\scripts\statemachines\buildings\mturret\mturret.sqf";
owr_fn_laboratory_am = compile preprocessFileLineNumbers "\owr\scripts\statemachines\buildings\laboratory\laboratory_am.sqf";
owr_fn_laboratory_ru = compile preprocessFileLineNumbers "\owr\scripts\statemachines\buildings\laboratory\laboratory_ru.sqf";
owr_fn_powerPlant = compile preprocessFileLineNumbers "\owr\scripts\statemachines\buildings\powerplant\powerplant.sqf";
owr_fn_resourceMine = compile preprocessFileLineNumbers "\owr\scripts\statemachines\buildings\resourcemine\resourcemine.sqf";
owr_fn_combat_vehicle = compile preprocessFileLineNumbers "\owr\scripts\statemachines\vehicles\combat_vehicle.sqf";
owr_fn_ncombat_vehicle = compile preprocessFileLineNumbers "\owr\scripts\statemachines\vehicles\noncombat_vehicle.sqf";

// other variables
owr_stopmusic = false;
owr_gameSpeed = ["GameSpeed"] call BIS_fnc_getParamValue;
owr_positions_nodes = [[3278.44,1419.39],[1965.64,2628],[3127.1,2960.5],[3808.36,2976.56],[3838.7,2032.59],[3076.5,2276.03],[2486.46,2023.94]];

sleep 1;

// specific init for entities
switch (player) do {
	case bis_curatorUnit_west: {
		// west curator

		// cheat to prevent WEST units getting into COMBAT mode in GET IN waypoint
		_WestAntiCombatEH = bis_curator_west addEventHandler ["CuratorWaypointPlaced", {[(leader (_this select 1))] spawn owr_fn_stopCombatWaypoint}];

		// static character list (max. amount of characters, can be reduced - todo)
		owr_am_characters = [am01,am02,am03,am04,am05,am06];

		// update cam pos
		curatorCamera setPos [(getPos (am01) select 0), (getPos (am01) select 1) - 50,25];
		curatorCamera setVectorDirAndUp [[0,1,-0.5],[0,0,1]];

		// gui stuff (related only to curators, dont waste resources anywhere else)
		player setVariable ["owr_confirm", false, true];
		player setVariable ["owr_cancel", false, true];
		[owr_am_characters, bis_curator_west getVariable "owr_am_characters_d"] spawn owr_fn_GUIActiveCharacterList;
		[] spawn owr_fn_GUIActiveInfoBox;
		["warehouse_am"] spawn owr_fn_GUIActiveResourceBar;
		[] spawn owr_fn_GUIActiveActionButtons;
		[] call owr_fn_messageBoxInit;

		// background music
		["am"] spawn owr_fn_backgroundMusic;

		// characters init
		{
			_x setIdentity format["ow_%1", _x];
		} foreach owr_am_characters;

		// mat. detection position fifo - SERVER?
		bis_curator_west setVariable ["ow_am_mat_detect_poses", [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]], true];

		// mat. detection markers
		_i = 0;
		for "_i" from 0 to 39 do {
			createMarkerLocal [format ["crate_detect_%1", _i], [0,0]];
			format ["crate_detect_%1", _i] setMarkerTypeLocal "hd_destroy";
			format ["crate_detect_%1", _i] setMarkerColorLocal "ColorOrange";
		};

		// unit scanner
		[bis_curator_west] spawn owr_fn_unitScanner;
		[] spawn owr_fn_am_fov;

		sleep 4;

		// task manager
		[west, getPos bis_curator_east, bis_curatorUnit_west] spawn owr_fn_taskManagerSide;
	};

	case bis_curatorUnit_east: {
		// east curator

		// cheat to prevent EAST units getting into COMBAT mode in GET IN waypoint
		_EastAntiCombatEH = bis_curator_east addEventHandler ["CuratorWaypointPlaced", {[(leader (_this select 1))] spawn owr_fn_stopCombatWaypoint}];

		// static character list (max. amount of characters, can be reduced - todo)
		owr_ru_characters = [ru01,ru02,ru03,ru04,ru05,ru06];

		// update cam pos
		curatorCamera setPos [(getPos (ru01) select 0), (getPos (ru01) select 1) - 50,25];
		curatorCamera setVectorDirAndUp [[0,1,-0.5],[0,0,1]];

		// gui stuff (related only to curators, dont waste resources anywhere else)
		player setVariable ["owr_confirm", false, true];
		player setVariable ["owr_cancel", false, true];
		[owr_ru_characters, bis_curator_east getVariable "owr_ru_characters_d"] spawn owr_fn_GUIActiveCharacterList;
		[] spawn owr_fn_GUIActiveInfoBox;
		["warehouse_ru"] spawn owr_fn_GUIActiveResourceBar;
		[] spawn owr_fn_GUIActiveActionButtons;
		[] call owr_fn_messageBoxInit;

		// background music
		["ru"] spawn owr_fn_backgroundMusic;

		// characters init
		{
			_x setIdentity format["ow_%1", _x];
		} foreach owr_ru_characters;

		// mat. forecast marker
		_i = 0;
		for "_i" from 0 to 3 do {
			createMarkerLocal [format ["crate_predict_%1", _i], [0,0]];
			format ["crate_predict_%1", _i] setMarkerTypeLocal "mil_circle";
			format ["crate_predict_%1", _i] setMarkerColorLocal "ColorPink";
		};

		// unit scanner
		[bis_curator_east] spawn owr_fn_unitScanner;
		[] spawn owr_fn_ru_fov;

		sleep 4;

		// task manager
		[east, getPos bis_curator_west, bis_curatorUnit_east] spawn owr_fn_taskManagerSide;

		// wait loop for siberite detection research
		while {!(["siberite", 5, bis_curator_east] call owr_fn_isResearchComplete)} do {
			sleep 2;
		};
		[] spawn owr_fn_siberite_detect;
	};

	default {
		// generic soldier, do necessary initialization (if any)
		//player addeventhandler ["Killed", {[] call bis_fnc_respawnspectator}]; 
		
		action_cargo_load = objNull;
		action_cargo_unload = objNull;
		action_cargo_type_change = objNull;

		switch (typeOf player) do {
			case "owr_man_am": {

				// init gear
				[player, player getVariable "ow_class", "am"] call owr_fn_assignClassGear;

				// background music
				["am"] spawn owr_fn_backgroundMusic;

				// mat. detection markers
				_i = 0;
				for "_i" from 0 to 39 do {
					createMarkerLocal [format ["crate_detect_%1", _i], [0,0]];
					format ["crate_detect_%1", _i] setMarkerTypeLocal "hd_destroy";
					format ["crate_detect_%1", _i] setMarkerColorLocal "ColorOrange";
				};

				// 
				player addeventhandler ["Killed", {
					[] call bis_fnc_respawnspectator;
					[bis_curator_west, [[_this select 0], false]] remoteExec ["removeCuratorEditableObjects", 0];
				}];

				// add eventhandlers for actions related to cargo vehicle
				player addeventhandler ["GetInMan", {
					_unit = (_this select 0);
					_vehicle = (_this select 2);
					if (((_vehicle getVariable "ow_vehicle_template") select 3) == 8) then {
						// LOAD CARGO ACTION
						action_cargo_load = player addAction ["<t color='#FF0000'>Load cargo</t>", {
							_vehicleToUse = vehicle player;
							_nearestCrates = nearestObjects [_vehicleToUse, ["owr_crates_pile_1","owr_crates_pile_2","owr_crates_pile_3","owr_crates_pile_4","owr_crates_pile_5"], 15];
							if (((count _nearestCrates) > 0) && ((_vehicleToUse getVariable "ow_vehicle_cargo_type") == 0))  then {
								[(_nearestCrates select 0), _vehicleToUse] spawn owr_fn_cargoCratePickUp;
							} else {
								// lets try to search for warehouses around
								_nearestSources = nearestObjects [_vehicleToUse, ["warehouse_am"], 15];
								if ((count _nearestSources) > 0) then {
									_resType = _vehicleToUse getVariable "ow_vehicle_cargo_type";
									_resTypeStr = "";
									switch (_resType) do {
										case 0: {_resTypeStr = "ow_wrhs_crates";};
										case 1: {_resTypeStr = "ow_wrhs_oil";};
										case 2: {_resTypeStr = "ow_wrhs_siberite";};
									};
									[_resTypeStr, (_nearestSources select 0), _vehicleToUse] spawn owr_fn_resourcePickUp;
								};
							};
						}];


						// UNLOAD CARGO ACTION
						action_cargo_unload = player addAction ["<t color='#FF0000'>Unload cargo</t>", {
							_vehicleToUse = vehicle player;
							_nearestSources = nearestObjects [_vehicleToUse, ["warehouse_am"], 15];

							if ((count _nearestSources) > 0) then {
								_resType = "ow_wrhs_crates";
								switch (_vehicleToUse getVariable "ow_vehicle_cargo_type") do {
									case 1: {_resType = "ow_wrhs_oil";};
									case 2: {_resType = "ow_wrhs_siberite";};
								};
								[_resType, (_nearestSources select 0), _vehicleToUse] spawn owr_fn_resourceDrop;
							};
						}];


						action_cargo_type_change = player addAction ["<t color='#FF0000'>Change cargo type</t>", {
							_vehicleToUse = vehicle player;

							if ((_vehicleToUse getVariable "ow_vehicle_cargo") == 0) then {
								_resType = _vehicleToUse getVariable "ow_vehicle_cargo_type";
								_resType = _resType + 1;
								if (_resType == 3) then {
									_resType = 0;
								};
								_vehicleToUse setVariable ["ow_vehicle_cargo_type", _resType, true];

								_resTypeStr = "";
								switch (_resType) do {
									case 0: {_resTypeStr = "crates";};
									case 1: {_resTypeStr = "oil";};
									case 2: {_resTypeStr = "siberite";};
								};
								hintSilent format["cargo type changed to %1", _resTypeStr];
							} else {
								hintSilent "empty your cargo first!";
							};
						}];
					};
				}];
				player addeventhandler ["GetOutMan", {
					_vehicle = (_this select 2);
					if (((_vehicle getVariable "ow_vehicle_template") select 3) == 8) then {
						player removeAction action_cargo_load;
						player removeAction action_cargo_type_change;
						player removeAction action_cargo_unload;
					};
				}];

				sleep 4;

				// task manager
				[west, getPos bis_curator_east, bis_curatorUnit_west] spawn owr_fn_taskManagerSide;
			};
			case "owr_man_ru": {

				// init gear
				[player, player getVariable "ow_class", "ru"] call owr_fn_assignClassGear;

				// background music
				["ru"] spawn owr_fn_backgroundMusic;

				// mat. forecast marker
				_i = 0;
				for "_i" from 0 to 3 do {
					createMarkerLocal [format ["crate_predict_%1", _i], [0,0]];
					format ["crate_predict_%1", _i] setMarkerTypeLocal "mil_circle";
					format ["crate_predict_%1", _i] setMarkerColorLocal "ColorPink";
				};

				// 
				player addeventhandler ["Killed", {
					[] call bis_fnc_respawnspectator;
					[bis_curator_east, [[_this select 0], false]] remoteExec ["removeCuratorEditableObjects", 0];
				}];

				// add eventhandlers for actions related to cargo vehicle
				player addeventhandler ["GetInMan", {
					_unit = (_this select 0);
					_vehicle = (_this select 2);
					if (((_vehicle getVariable "ow_vehicle_template") select 3) == 6) then {
						// LOAD CARGO ACTION
						action_cargo_load = player addAction ["<t color='#FF0000'>Load cargo</t>", {
							_vehicleToUse = vehicle player;
							_nearestCrates = nearestObjects [_vehicleToUse, ["owr_crates_pile_1","owr_crates_pile_2","owr_crates_pile_3","owr_crates_pile_4","owr_crates_pile_5"], 15];
							if (((count _nearestCrates) > 0) && ((_vehicleToUse getVariable "ow_vehicle_cargo_type") == 0))  then {
								[(_nearestCrates select 0), _vehicleToUse] spawn owr_fn_cargoCratePickUp;
							} else {
								// lets try to search for warehouses around
								_nearestSources = nearestObjects [_vehicleToUse, ["warehouse_ru"], 15];
								if ((count _nearestSources) > 0) then {
									_resType = _vehicleToUse getVariable "ow_vehicle_cargo_type";
									_resTypeStr = "";
									switch (_resType) do {
										case 0: {_resTypeStr = "ow_wrhs_crates";};
										case 1: {_resTypeStr = "ow_wrhs_oil";};
										case 2: {_resTypeStr = "ow_wrhs_siberite";};
									};
									[_resTypeStr, (_nearestSources select 0), _vehicleToUse] spawn owr_fn_resourcePickUp;
								};
							};
						}];

						// UNLOAD CARGO ACTION
						action_cargo_unload = player addAction ["<t color='#FF0000'>Unload cargo</t>", {
							_vehicleToUse = vehicle player;
							_nearestSources = nearestObjects [_vehicleToUse, ["warehouse_ru"], 15];

							if ((count _nearestSources) > 0) then {
								_resType = "ow_wrhs_crates";
								switch (_vehicleToUse getVariable "ow_vehicle_cargo_type") do {
									case 1: {_resType = "ow_wrhs_oil";};
									case 2: {_resType = "ow_wrhs_siberite";};
								};
								[_resType, (_nearestSources select 0), _vehicleToUse] spawn owr_fn_resourceDrop;
							};
						}];


						// CHANGE CARGO TYPE ACTION
						action_cargo_type_change = player addAction ["<t color='#FF0000'>Change cargo type</t>", {
							_vehicleToUse = vehicle player;

							if ((_vehicleToUse getVariable "ow_vehicle_cargo") == 0) then {
								_resType = _vehicleToUse getVariable "ow_vehicle_cargo_type";
								_resType = _resType + 1;
								if (_resType == 3) then {
									_resType = 0;
								};
								_vehicleToUse setVariable ["ow_vehicle_cargo_type", _resType, true];

								_resTypeStr = "";
								switch (_resType) do {
									case 0: {_resTypeStr = "crates";};
									case 1: {_resTypeStr = "oil";};
									case 2: {_resTypeStr = "alaskite";};
								};
								hintSilent format["cargo type changed to %1", _resTypeStr];
							} else {
								hintSilent "empty your cargo first!";
							};
						}];
					};
				}];
				player addeventhandler ["GetOutMan", {
					_vehicle = (_this select 2);
					if (((_vehicle getVariable "ow_vehicle_template") select 3) == 6) then {
						player removeAction action_cargo_load;
						player removeAction action_cargo_type_change;
						player removeAction action_cargo_unload;
					};
				}];

				sleep 4;

				// task manager
				[east, getPos bis_curator_west, bis_curatorUnit_east] spawn owr_fn_taskManagerSide;
			};
		};
	};
};