_debugModeParam = ["CheatMode"] call BIS_fnc_getParamValue;

owr_devhax = false;

if (_debugModeParam == 1) then {
	owr_devhax = true;
};


//////////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION INIT
//////////////////////////////////////////////////////////////////////////////////////////////
// main function init (server-side functions)
call compile preprocessFileLineNumbers "\owr\scripts\functions\initFnServer.sqf";

//////////////////////////////////////////////////////////////////////////////////////////////
// VARIABLE INIT
//////////////////////////////////////////////////////////////////////////////////////////////

// WEST - AM side, adding characters
owr_am_characters = [am01,am02,am03,am04,am05,am06];
bis_curator_west setVariable ["owr_am_characters", owr_am_characters, true];
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
	_x setvariable ["ow_scriptedDmgEHID", -1, true];
	//if (local _x) then {
		[_x, _x getVariable "ow_class", "am"] call owr_fn_assignClassGear;
		_damageIgnoreSet = _x addEventHandler ["GetInMan", {[(_this select 0), false] remoteExec ["allowDamage", 0];}];
		_damageIgnoreOff = _x addEventHandler ["GetOutMan", {[(_this select 0), true] remoteExec ["allowDamage", 0];}];
		_x addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 12;

			//hintSilent format ["unit got hit %1", _revDamage];

			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	/*} else {
		//[_x, [_x, _x getVariable "ow_class", "am"]] remoteExec ["owr_fn_assignClassGear", 0];	// done in init.sqf
		[_x, ["GetOutMan", {[(_this select 0), true] remoteExec ["allowDamage", 0];}]] remoteExec ["addEventHandler", owner _x];
		[_x, ["GetInMan", {[(_this select 0), false] remoteExec ["allowDamage", 0];}]] remoteExec ["addEventHandler", owner _x];
		[_x, ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 12;

			//hintSilent format ["unit got hit (remote) %1", _revDamage];

			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}]] remoteExec ["addEventHandler", owner _x];
	};*/
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


// EAST - RU side, adding characters
owr_ru_characters = [ru01,ru02,ru03,ru04,ru05,ru06];
bis_curator_east setVariable ["owr_ru_characters", owr_ru_characters, true];
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
	_x setvariable ["ow_scriptedDmgEHID", -1, true];
	//if (local _x) then {
		[_x, _x getVariable "ow_class", "ru"] call owr_fn_assignClassGear;
		_damageIgnoreSet = _x addEventHandler ["GetInMan", {[(_this select 0), false] remoteExec ["allowDamage", 0];}];
		_damageIgnoreOff = _x addEventHandler ["GetOutMan", {[(_this select 0), true] remoteExec ["allowDamage", 0];}];
		_x addEventHandler ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 12;

			//hintSilent format ["unit got hit %1", _revDamage];

			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}];
	/*} else {
		//[_x, [_x, _x getVariable "ow_class", "ru"]] remoteExec ["owr_fn_assignClassGear", 0];	// done in init.sqf
		[_x, ["GetOutMan", {[(_this select 0), true] remoteExec ["allowDamage", 0];}]] remoteExec ["addEventHandler", owner _x];
		[_x, ["GetInMan", {[(_this select 0), false] remoteExec ["allowDamage", 0];}]] remoteExec ["addEventHandler", owner _x];
		[_x, ["HandleDamage", {
			_victim = (_this select 0);
			_revDamage = (_this select 2) - (damage _victim);
			_damageDivisor = 12;

			//hintSilent format ["unit got hit (remote) %1", _revDamage];

			_newDamage = (damage _victim) + (_revDamage / _damageDivisor);
			_newDamage
		}]] remoteExec ["addEventHandler", owner _x];
	};*/
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
owr_am_characters_d = [objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull];
owr_ru_characters_d = [objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull,objNull];
bis_curator_west setVariable ["owr_am_characters_d", owr_am_characters_d, true];
bis_curator_east setVariable ["owr_ru_characters_d", owr_ru_characters_d, true];

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

// update _di array for curators - so client with curator now knows who the dynamic characters are in this game
bis_curator_west setVariable ["owr_am_characters_di", owr_am_characters_di, true];
bis_curator_east setVariable ["owr_ru_characters_di", owr_ru_characters_di, true];

// now to the actual spawning
// setting up limits of dynamic characters
owr_dyn_char_frequency = (["DynCharsFreq"] call BIS_fnc_getParamValue) / 100;
owr_dyn_char_cap = ["DynChars"] call BIS_fnc_getParamValue;		// this is the limit (for both side the same), 14 is maximum!
owr_dyn_char_am_cur = 0;	// this will increment
owr_dyn_char_ru_cur = 0;	// this will increment


//////////////////////////////////////////////////////////////////////////////////////////////
// ENVIRONMENT INIT
//////////////////////////////////////////////////////////////////////////////////////////////

setViewDistance 1000;

owr_gameSpeed = ["GameSpeed"] call BIS_fnc_getParamValue;

owr_skirmishLocID = ["LocationID"] call BIS_fnc_getParamValue;

owr_skirmish_start_am = [0,0];
owr_skirmish_start_ru = [0,0];
owr_res_oil = [];
owr_res_siberite = [];

switch (owr_skirmishLocID) do {
	case 0: {
		owr_skirmish_start_am = [2419.609375,2396.305908];
		owr_skirmish_start_ru = [3506.795654,2263.697021];
		owr_res_oil = [[2228.79,2321.37],[2615.93,2471.09],[2552.24,2335.13],[2639.38,2464.15],[3141.53,2455.1],[2935.19,2607.53],[2795.22,2565.11],[2698.55,2487.55],[2597.3,2385.72],[3273.88,2343.1],[3006.1,2129.17],[3545.31,2345.21],[3192.07,2439.38],[3463.51,2389.16],[2794.74,2349.67],[3341.65,2199.45],[2202.76,2579.44],[3523.61,2307.82],[2170.89,2363.58],[2856.52,2604.13],[2312.69,2656.7],[2144.44,2282.76],[2534.32,2196.13],[2480.94,2569.93],[2405.74,2430.8],[2388.16,2378.76],[2446.73,2280.01],[2710.66,2317.08],[2311.67,2474.08]];
		owr_res_siberite = [[3167.9,2477.07],[2830.66,1928.06],[2861.13,2423.08],[2859.55,2391.12],[2862.53,2471.42],[2816.97,2309.17],[2820.94,2345.01],[2852.86,2580.03],[2935.99,2511],[2979.98,2255.36],[3033.58,2303.76],[2772.56,2001.68],[3168.48,2512.51],[2891.09,2229.37],[2915.66,2198.23],[3264.86,2590.08],[2852.1,2101.18],[3015.58,2231.92],[3054.93,2405.02],[3074.48,2381.99],[3516.39,2212.26],[2998.85,2292.94],[2992.27,2254.73],[3066.02,2450.02],[3094.14,2215.81],[2875.43,2326.69],[3086.28,2133.12],[2989.34,2290.55],[2785.09,2478.19],[2495.13,2040.65],[2705.27,2276.69],[3108.76,2141.43],[3025.95,2121.02],[2811.5,2445.48],[3096.12,2278.59],[3073.81,2132.77],[2787.13,2414.98],[2645.56,2194.79],[2677.8,2122.99]];
	};
	case 1: {
		owr_skirmish_start_am = [3857.380316,2777.475690];
		owr_skirmish_start_ru = [4858.396973,1153.568726];
		owr_res_oil = [[3939.51,2760.45],[4763.33,1187.95],[4085.56,1491.08],[4771.03,1883.36],[4714.28,1373.02],[4085.94,1678.92],[4505.47,2369.61],[4873.42,1755.84],[4850.12,979.62],[4843.45,1534.33],[3948.76,2634.56],[4853.55,1379.35],[4728.66,846.87],[4857.55,1725.94],[4897.89,1467.29],[4935.28,1144.43],[4542.52,1014.48],[4350.28,999.88],[4291.09,1231.47],[4119.59,1344.43],[4022.91,2037.52],[4494.76,2344.41],[3739.54,2722.92],[4122.31,2488.45],[4324.66,2329.47],[3930.67,2784.42],[4729.31,2142.74],[4875.64,2114.86],[4115.02,2538.55],[4509.16,2132.91],[4011.44,2271.94],[3979.09,2939.06],[3807.44,2998.48],[4425.81,2138.69]];
		owr_res_siberite = [[3811.2,2226.94],[4635.75,1552.19],[4331.81,1807.69],[5060.65,1410.34],[4188.33,2154.86],[4681.45,1827.86],[4730.02,1516.84],[3810.65,2264.68],[4447.16,1242.79],[4379.95,1706.72],[3793.91,2784.87],[4452.99,2441.99],[4377.55,2288.7],[4178.51,2011.2],[3786.22,2244.88],[4228.8,1203.42],[4436.69,2460.82],[4861.19,1673.92],[4508.06,1826.18],[4293.43,1639.3],[4007.31,2124],[3845.62,2037.07],[4629.39,1744.22],[4314.27,2191.96],[5008.96,1356.01],[4575.9,2178.23],[4835.79,2447.98],[4438.92,1424.77],[4790.7,1098.76]];
	};
	case 2: {
		owr_skirmish_start_am = [3115.597692,3168.811739];
		owr_skirmish_start_ru = [2417.659177,2400.071206];
		owr_res_oil = [[3105.18,3133.77],[2572.49,3091.01],[2988.46,3374.56],[3341.71,3180.5],[2818.89,2936.2],[2993.73,2580.87],[2804.66,2817.5],[2416.26,2276.06],[2839.69,3344.2],[2694.42,3161.14],[2767.1,2925.48],[2466.53,2557.06],[2340.18,3013.8],[2435.24,3154.33],[3065.05,3159.25],[3507.74,2893.64],[2563.19,2634.23],[2680.09,2300.55],[2944.16,3165.01],[2764.09,2587.12],[2545.44,2784.98],[2898.97,2841.51],[3218.19,2837.8],[2923.19,2644.31],[2637.94,2460.43],[2403.99,2424.87],[2812.07,3025.61],[2291.01,2511.16],[2877.85,3231.4],[3380.53,3068.81],[3327,3198.49],[2386.62,2382.45],[2557.45,2138.79],[2424.71,2687.19]];
		owr_res_siberite = [[3284.72,2860.47],[2853.64,2500.86],[2454.75,2844.24],[2218.55,2320.37],[2965,2839.97],[2664.39,2427.31],[3399.65,2851.91],[3218.23,3435.43],[2389.56,2675.11],[2799.58,2892.36],[2879.68,2432.04],[2942.63,2724.67],[3135.18,3201.68],[2921.66,3082.02],[2432.68,2375.91],[3191.01,3089.45],[2224.37,2200.73],[3075.01,2895.36],[2744.73,3161.72],[2235.51,2200],[2261.79,2585.51],[2615.81,2653.52],[2171.09,2377.48],[2694.92,3025.61],[3186.71,3417.64],[2081.05,2302.21],[2824.8,2405.26],[2969.9,3060.11],[2994.2,2621.88],[2568.28,2805.56],[3349.45,2930.22],[3143.38,2978.56],[2285.42,2303.74],[2460.58,2768.09]];
	};
	case 3: {
		owr_skirmish_start_am = [1180.535767,2928.114502];
		owr_skirmish_start_ru = [346.087616,2322.080078];
		owr_res_oil = [[193.45,2549.66],[134.1,2494.58],[514.28,2588.51],[1031.04,2479.49],[1053.19,2569.3],[1069.92,2676.31],[1129.05,2799.33],[1143.39,2974.96],[432.33,2465.36],[964.03,2895.8],[1154.62,2677.13],[569.24,2563.14],[101.26,2367.9],[324.48,2208.13],[560.5,2760.73],[806.78,2566.5],[663.89,2748],[276.51,2320.89],[101.72,2100.79],[329.75,2368.14],[787.61,2756.74],[809.8,2895.13],[995.97,2632.68],[758.55,2579.85],[865.05,2841.39],[834.36,2889.16],[651.66,2472.95],[92.79,2241.68],[762.66,2501.66],[716.08,2410.39],[1066.16,2355.65],[1118.13,2668.51],[881.34,2287.58],[558.61,2378.83],[549.2,2138.04],[388.03,1954.56],[1200.92,2984.2],[865.61,2294.87],[953.69,2415.39],[842.11,2532.41],[110.22,2099.59]];
		owr_res_siberite = [[544.21,2547.48],[883.5,3105.13],[403.28,2303.31],[267.24,2592.48],[597.34,2360.99],[1230.51,2550.66],[480.92,2662.82],[1232.42,2643.57],[1227.72,2836.18],[617.81,2883.56],[602.75,2901.54],[813.96,2961.69],[562.92,2555.45],[241.19,1992.02],[923.73,2619.15],[753.23,2295.04],[887.53,2569.39],[624.11,2902.72],[1163.28,2771.34],[241.57,2002.95],[896.01,2581.04]];
	};
	case 4: {
		owr_skirmish_start_am = [2440.049805,4342.964844];
		owr_skirmish_start_ru = [3192.310547,3729.090332];
		owr_res_oil = [[2460.95,3892.74],[2264.73,3898.51],[3234.33,4007.71],[3165.28,3669.94],[3326.59,3720.71],[2242.45,3822.26],[2639.92,3676.99],[3250.86,3897.17],[3095.02,3888.45],[3227.92,4016.91],[3050.36,3764.29],[2996.52,3674.23],[2418.09,3851.05],[3179.27,3687.54],[2222.77,3855.09],[2418.66,3846.46],[2837.2,3716.73],[2234.88,3824.44],[2770.64,4162.8],[2299.5,4079.22],[2784.42,3986.06],[2776.78,4173.97],[2662.73,4162.63],[2253.95,4323.39],[2559.69,4152.67],[2435.81,4135.97],[2648.28,4031.36],[2904.27,4039.04],[2364.56,3948.11],[2907.45,4184.93],[2454.61,3953.75],[2801.77,4042],[2533.72,4272.23],[2536.16,3953.83],[2510.38,4092.67],[2956.98,3954.09],[2945.12,3972.64],[2621.38,3931.01],[2318.79,4185.52],[2194.83,3862.64],[2192.45,4173.57],[2222.2,3918.89],[2200.72,4056.45],[2426.37,4368.21],[2626.27,3928.8],[2722.08,3894.26],[2818.45,3914.57]];
		owr_res_siberite = [[2259.48,3678.25],[2764.31,3609.07],[3019.05,4100.74],[2746.83,3775.85],[2879.84,3908.61],[2825.71,3802.41],[2917.18,4072.6],[2258.32,3976.63],[2785.96,4089.18],[3231.19,3695.17],[2701.17,3816.06],[3155.01,3997.7],[2867.4,3702.15],[2583.48,3893.74],[2851.81,3930.76],[2312.44,4012.64],[2412.21,4268.57],[2494.67,3886.54],[2377.3,3743.52],[2740.26,4163.78],[2653.91,4356]];
	};
	case 5: {
		owr_skirmish_start_am = [4812.231934,4028.309326];
		owr_skirmish_start_ru = [4191.526367,3278.087646];
		owr_res_oil = [[4840.25,3739.65],[4492.89,3230.37],[4464.8,3538.57],[4685.95,3462.14],[4573.59,3379.75],[4397.83,3254.44],[4611.72,3494.97],[4146.41,3381.09],[4804.53,3802.74],[4930.03,3930.36],[4172.2,3318.5],[4095.66,3621.12],[4106.84,3526.75],[4325.1,3976.52],[4843.45,4003.01],[5011.45,4097.32],[4715.31,4112.5],[4222.66,3735.79],[4636.94,4131.28],[4812.39,3971.97],[4411.86,4052.52],[5097.41,4087.82],[4356.52,3824.7],[4871.14,4113.27],[5054.03,4262.31],[4547.3,4094.97],[4744.8,3817.02],[4147.73,3263.72],[3864.7,3185.73],[3755.02,3727.8],[3919.09,3079.41],[3937.11,3772.92],[3790.62,3414.03],[3815.95,3535.47],[4709.58,3722.23],[3920.28,3085.34],[3895.3,3297.82],[4010.28,3938.86],[4064.67,3826.83],[4664.19,3706.74],[4098.52,3025.01],[4249.53,3057.08],[4664.39,3125.29]];
		owr_res_siberite = [[4256.94,3666.2],[4299.61,3778.99],[4299.4,3896.5],[4416.76,3943.2],[4587.11,3190.67],[4365.21,3624.58],[4351.78,3641.5],[3930.15,3507.02],[3943.16,3308.33],[4495.52,3525.93],[4802.97,2944.46],[4567.75,4063.87],[4412.46,3192.04],[4583.67,3208.54],[4486.31,3684.66],[4807.27,4062.44],[4554.04,3980.74],[4444.33,3762.68],[4563.73,3915.18],[4278.39,3905.14],[4494.77,3300.98],[4302.15,2915.58],[4061.09,3420.03],[4136.65,3293.73],[4740.65,2999.12],[4296.56,2907.66]];
	};
};

if (owr_devhax) then {
	createMarkerLocal ["owr_skirmish_start_am", owr_skirmish_start_am];
	"owr_skirmish_start_am" setMarkerTypeLocal "hd_destroy";
	"owr_skirmish_start_am" setMarkerColorLocal "ColorBlue";
	createMarkerLocal ["owr_skirmish_start_ru", owr_skirmish_start_ru];
	"owr_skirmish_start_ru" setMarkerTypeLocal "hd_destroy";
	"owr_skirmish_start_ru" setMarkerColorLocal "ColorRed";
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

// ENVIRONMENT - SIDE MOVER
// am
{
	if (local _x) then {
		_x setPos [(owr_skirmish_start_am select 0) + random [0, 5, 10], (owr_skirmish_start_am select 1) + random [0, 5, 10]];
	} else {
		[_x, [(owr_skirmish_start_am select 0) + random [0, 5, 10], (owr_skirmish_start_am select 1) + random [0, 5, 10]]] remoteExec ["setPos", 0];
	};
} foreach owr_am_characters;
bis_curator_west setPos owr_skirmish_start_am;
bis_curatorUnit_west setPos owr_skirmish_start_am;
// ru
{
	if (local _x) then {
		_x setPos [(owr_skirmish_start_ru select 0) + random [0, 5, 10], (owr_skirmish_start_ru select 1) + random [0, 5, 10]];
	} else {
		[_x, [(owr_skirmish_start_ru select 0) + random [0, 5, 10], (owr_skirmish_start_ru select 1) + random [0, 5, 10]]] remoteExec ["setPos", 0];
	};
} foreach owr_ru_characters;
bis_curator_east setPos owr_skirmish_start_ru;
bis_curatorUnit_east setPos owr_skirmish_start_ru;


// ENVIRONMENT - CRATE SPAWNER
// spawn first wave of crates - spawned around starting locations of both sides
[owr_skirmish_start_am] call owr_fn_cratesInitSpawn;
[owr_skirmish_start_ru] call owr_fn_cratesInitSpawn;

// dynamic crate spawner
owr_res_dynamicspawners = [false, false, false, false, false, false, false, false, false];
// allow spawn of crates at starting positions
_startTileAM = (3 * floor ((owr_skirmish_start_am select 1) / 1706)) + floor ((owr_skirmish_start_am select 0) / 1706);
_startTileRU = (3 * floor ((owr_skirmish_start_ru select 1) / 1706)) + floor ((owr_skirmish_start_ru select 0) / 1706);
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
// SIBERITE
_i = 0;
_actualSibPoses = [];
_siberiteEnabled = ["SibAllowed"] call BIS_fnc_getParamValue;
if (_siberiteEnabled == 1) then {
	for "_i" from 0 to ((count owr_res_siberite) - 1) do {
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
		_tempUnit setPos (selectRandom ([format ["owr_res_crates_%1", (3 * floor ((owr_skirmish_start_am select 1) / 1706)) + floor ((owr_skirmish_start_am select 0) / 1706)]] call owr_fn_getCrateArray));

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
		_tempUnit setPos (selectRandom ([format ["owr_res_crates_%1", (3 * floor ((owr_skirmish_start_ru select 1) / 1706)) + floor ((owr_skirmish_start_ru select 0) / 1706)]] call owr_fn_getCrateArray));

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

			//hintSilent format ["unit got hit %1", _revDamage];

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

// SKIRMISH WIN CONDITION
// main win condition loop
[] spawn {
	_someOneDidIt = false;
	while {!_someOneDidIt} do {
		// check for alive units of AM and RU
		_amCharsNotAlive = true;
		{
			if (alive _x) then {
				_amCharsNotAlive = false;
			};
		} foreach owr_am_characters;
		{
			if ((_x != objNull) && (alive _x)) then {
				_amCharsNotAlive = false;
			};
		} foreach owr_am_characters_d;

		_ruCharsNotAlive = true;
		{
			if (alive _x) then {
				_ruCharsNotAlive = false;
			};
		} foreach owr_ru_characters;
		{
			if ((_x != objNull) && (alive _x)) then {
				_ruCharsNotAlive = false;
			};
		} foreach owr_ru_characters_d;

		if (_amCharsNotAlive || _ruCharsNotAlive) then {
			_someOneDidIt = true;
		};
		sleep 10;
	};

	sleep 30;

	"SideScore" call BIS_fnc_endMissionServer;
};