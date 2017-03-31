/*
	Author: Karel Moricky

	Description:
	Remove icon displayed in curator interface

	Parameter(s):
		0: OBJECT - curator module
		1: NUMBER - icon ID returned by BIS_fnc_addCuratorIcon function

	Returns:
	BOOL - true if removed
*/

private ["_curator","_iconID","_icons"];
_curator = _this param [0,objnull,[objnull]];
_iconID = _this param [1,-1,[0]];

_icons = _curator getvariable ["bis_fnc_addcuratoricon",[]];
if (_iconID >= 0 && _iconID < count _icons) then {
	_icons set [_iconID,[]];
	_curator setvariable ["bis_fnc_addcuratoricon",_icons];
	true
} else {
	false
};