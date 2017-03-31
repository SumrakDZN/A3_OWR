/*
	Author: Karel Moricky

	Description:
	Show skull unit for curator when the unit dies.

	Parameter(s):
		0: OBJECT - unit

	Returns:
	BOOL
*/

_unit = _this param [0,objnull,[objnull]];
_curator = _this param [1,objnull,[objnull]];

if (isnull _curator) then {
	_unit addeventhandler [
		"killed",
		{
			_unit = _this select 0;
			{
				[[_unit,_x],"bis_fnc_drawcuratordeaths",_x] call bis_fnc_mp;
			} foreach (objectcurators _unit)
		}
	];
} else {
	_side = side group _unit;
	_color = _side call bis_fnc_sidecolor;
	_color set [3,0.5];
	_iconID = [
		_curator,
		[
			"kia" call bis_fnc_texturemarker,
			_color,
			getposatl _unit,
			1,
			1,
			0,
			"",
			1
		]
	] call bis_fnc_addcuratoricon;

	//--- Register the icon
	_deathIcons = _curator getvariable ["bis_fnc_drawcuratordeaths_icons",[]];
	_deathIcons set [count _deathIcons,_iconID];
	_maxIconCount = 0;
	{_maxIconCount = _maxIconCount + playableslotsnumber _x;} foreach [east,west,resistance,civilian];

	//--- Limit number of available icons to max player count
	while {count _deathIcons > _maxIconCount} do {
		[_curator,_deathIcons select 0] call bis_fnc_removecuratoricon;
		_deathIcons set [0,-1];
		_deathIcons = _deathIcons - [-1];
	};
	_curator setvariable ["bis_fnc_drawcuratordeaths_icons",_deathIcons];
};

true