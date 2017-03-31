/*
	Author: Karel Moricky

	Description:
	Code executed when curator waypoint is placed.

	Parameter(s):
		0: OBJECT - curator module
		1: ARRAY - edited waypoint

	Returns:
	BOOL
*/

//--- Simplified argument loading to save performance
_group = _this select 1;
_wpID = _this select 2;

[
	leader _group,
	if (waypointtype [_group,_wpID] == "DESTROY") then {"CuratorWaypointPlacedAttack"} else {"CuratorWaypointPlaced"}
] call bis_fnc_curatorSayMessage;