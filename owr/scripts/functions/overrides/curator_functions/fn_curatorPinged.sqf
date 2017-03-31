/*
	Author: Karel Moricky

	Description:
	Show effects when player pings curator.
	Icon and entity list highlighting is handled by engine.

	Parameter(s):
		0: OBJECT - curator module
		1: OBJECT - player

	Returns:
	BOOL
*/

//--- Terminate when not enough thime passed since the last ping
private ["_time"];
_time = missionnamespace getvariable ["bis_fnc_curatorPinged_time",0];
if (time - _time < 0.1) exitwith {};
missionnamespace setvariable ["bis_fnc_curatorPinged_time",time];

//--- Get arguments
private ["_curator","_player","_pitch","_source","_soundPing","_sound","_volume","_pitchBase"];
_curator = _this param [0,objnull,[objnull]];
_player = _this param [1,objnull,[objnull]];
_isCurator = getassignedcuratorunit _curator == player;

//--- Mark position of the last ping (for external use)
missionnamespace setvariable ["bis_fnc_curatorPinged_player",_player];

//--- Play pinging sound
_soundsPing = getarray (configfile >> "cfgCurator" >> "soundsPing");
if (count _soundsPing > 0 || !_isCurator) then {
	_sound = "";
	if (_isCurator) then {
		//--- Curator - assign unique sound to each player
		_n = 0;
		{_n = _n + _x;} foreach (toarray name _player);
		_sound = _soundsPing select (_n % (count _soundsPing))
	} else {
		//--- Store that player already pinged, so hint is not displayed anymore
		if !(isnil {missionnamespace getvariable "bis_fnc_curatorPinged_index"}) then {
			profilenamespace setvariable ["bis_fnc_curatorPinged_done",true];
			saveprofilenamespace;
		};

		//--- Player - pick random sound to create a melody (ever played Joruney? :)
		_soundsPingCount = count _soundsPing;
		_index = missionnamespace getvariable ["bis_fnc_curatorPinged_index",floor random _soundsPingCount];
		_index = round ((_index - 2 + random 4) + _soundsPingCount) % _soundsPingCount;
		_sound = _soundsPing select _index;
		missionnamespace setvariable ["bis_fnc_curatorPinged_index",_index];
	};
	playsound [_sound,true];
};

//--- Show animated icon in the middle of the screen for player
if !(_isCurator) then {
	([] call bis_fnc_rscLayer) cutrsc ["RscCuratorPing","plain"];
};

true