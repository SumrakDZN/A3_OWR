/*
	Author: Karel Moricky

	Description:
	Add an icon displayed in curator interface

	Parameter(s):
		0: OBJECT - curator module
		1: ARRAY - icon params (see drawIcon3D scripting command for its format)
		2 (Optional) - true to show the icon in the map
		2 (Optional) - true to show the icon in 3D scene

	Returns:
	NUMBER - icon ID, used in BIS_fnc_removeCuratorIcon
*/

private ["_curator","_icon","_iconID","_icons"];
_curator = _this param [0,objnull,[objnull]];
_icon = _this param [1,[],[[]]];
_show2D = _this param [2,true,[true]];
_show3D = _this param [3,true,[true]];

if (_show2D || _show3D) then {
	_icons = _curator getvariable ["bis_fnc_addcuratoricon",[]];
	_iconID = count _icons;
	_icons set [count _icons,[_icon,_show2D,_show3D]];
	_curator setvariable ["bis_fnc_addcuratoricon",_icons];
	_iconID
} else {
	-1
};