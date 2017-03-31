/*
	Author: Karel Moricky

	Description:
	Shake curator camera.
	Must be executed in scheduled environment.

	Parameter(s):
		0: NUMBER - shaking strength
		1: NUMBER - duration
		2: ARRAY in format [<center>,<radius>] - shake only when camera is in given distance from center

	Returns:
	BOOL
*/
if (isnull curatorcamera) exitwith {};

private ["_strength","_duration","_timeStart","_time","_center","_radius"];
_strength = _this param [0,0.01,[0]];
_duration = _this param [1,0.7,[0]];
_pos = _this param [2,[],[[]]];

_center = _pos param [0,position curatorcamera];
_center = _center call bis_fnc_position;
_radius = _pos param [1,0,[0]];

if (curatorcamera distance _center > _radius) exitwith {false};

_timeStart = time;
_time = time + _duration;
_strengthLocalOld = 0;
while {time < _time && !isnull curatorcamera} do {
	private ["_strengthLocal","_vectorDir"];
	_strengthLocal = linearconversion [0,_duration,time - _timeStart,_strength,0];
	if (_radius > 0) then {
		_strengthLocal = _strengthLocal * linearconversion [0,_radius,curatorcamera distance _center,1,0];
	};
	if (_strengthLocalOld > 0) then {_strengthLocal = -_strengthLocal;};
	_vectorDir = vectordir curatorcamera;
	_vectorDir set [2,(_vectorDir select 2) - _strengthLocalOld + _strengthLocal];
	curatorcamera setvectordirandup [_vectorDir,vectorup curatorcamera];
	_strengthLocalOld = _strengthLocal;
	sleep 0.05;
};
true