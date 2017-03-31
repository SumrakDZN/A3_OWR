/*
	Author: Karel Moricky

	Description:
	Set which vision modes curator can access
	Supported modes are:
		-2: NVG
		-1: Normal
		0,1,...: Thermal (number represents type, see SetCamUseTi scripting command)

	Parameter(s):
		0: OBJECT - curator
		1: ARRAY of NUMBERs

	Returns:
	BOOL
*/

private ["_curator","_modes","_modesFiltered"];
_curator = _this param [0,objnull,[objnull]];
_modes = _this param [1,[-1],[[]]];

//--- Filter modes (make sure they are numbers)
_modesFiltered = [];
{
	_mode = _modes param [_foreachindex,-3,[0]];
	_mode = round _mode;
	if (_mode > -3 && _mode < 8 && !(_mode in _modesFiltered)) then {_modesFiltered set [count _modesFiltered,_mode];};
} foreach _modes;
if (count _modesFiltered == 0) then {_modesFiltered = [-1];};

//--- Save
_curator setvariable ["bis_fnc_curatorVisionModes_modes",_modesFiltered,true];

//--- Refresh current mode if it's no longer supported
if !(isnull curatorcamera) then {
	[_curator,0] call bis_fnc_toggleCuratorVisionMode;
};

true