/*
	Author: Karel Moricky

	Description:
	Create a curator icon on every respawn marker

	Parameter(s):
		0: OBJECT - curator module
		1: ARRAY of SIDEs 

	Returns:
	BOOL
*/

private ["_curator","_sides","_icon"];
_curator = _this param [0,objnull,[objnull]];
_sides = _this param [1,[east,west,resistance,civilian],[[]]];
_icon = "respawn_inf" call bis_fnc_textureMarker;
{
	_color = _x call bis_fnc_sideColor;
	{
		_pos = markerpos _x;
		if ((nearestobject [_pos,"ModuleRespawnPositionWest_F"]) distance _pos > 1) then {
			[
				_curator,
				[
					_icon,
					_color,
					_pos,
					1,
					1,
					0,
					markertext _x,
					0,
					0.05
				],
				false,
				true
			] call bis_fnc_addcuratoricon;
		};
	} foreach (_x call bis_fnc_getRespawnMarkers);
} foreach _sides;
true