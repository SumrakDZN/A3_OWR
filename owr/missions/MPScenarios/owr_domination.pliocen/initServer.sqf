_debugModeParam = ["CheatMode"] call BIS_fnc_getParamValue;

owr_devhax = false;

if (_debugModeParam == 1) then {
	owr_devhax = true;
};


//////////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION INIT
//////////////////////////////////////////////////////////////////////////////////////////////
// main function init (client-side functions)
call compile preprocessFileLineNumbers "\owr\scripts\functions\initFnServer.sqf";

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
	_x setVariable ["ow_aitype", 0, true];
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
	_x setVariable ["ow_aitype", 0, true];
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
	_x setVariable ["ow_aitype", 0, true];
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

owr_gameSpeed = ["GameSpeed"] call BIS_fnc_getParamValue;						// higher = higher game
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
// spawn first wave of crates - spawned around starting locations of both sides
[owr_startpos_ar] call owr_fn_cratesInitSpawn;
[owr_startpos_am] call owr_fn_cratesInitSpawn;
[owr_startpos_ru] call owr_fn_cratesInitSpawn;

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


// ENVIRONMENT - TIME
// but check first mission params!
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
		_tempUnit setVariable ["ow_aitype", 0, true];
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
		_tempUnit setVariable ["ow_aitype", 0, true];
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
		_tempUnit setVariable ["ow_aitype", 0, true];
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
_domiSwitch = ["DominationVictory"] call BIS_fnc_getParamValue;	// check if it is enabled
if (_domiSwitch == 1) then {
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
};