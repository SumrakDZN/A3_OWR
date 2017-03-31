_speaker = _this param [0,objnull,[objnull]];
_sentence = _this param [1,"",[""]];
_var = "bis_fnc_curatorSayMessage_time";

if (time > (missionnamespace getvariable [_var,0])) then {
	missionnamespace setvariable [_var,time + 1];
	if (_speaker == vehicle _speaker) then {_speaker = effectivecommander _speaker;};
	_curator = getassignedcuratorlogic player;
	_curator setspeaker speaker _speaker;
	_curator setpitch 1;
};