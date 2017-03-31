/*
	Author: Karel Moricky

	Description:
	Set which attributes are available for given entity  or entity type.

	Parameter(s):
		0: OBJECT - curator
		1:
			STRING - general setting for all entities of the given type, can be  "object", "player", "group', "waypoint" or "marker"
			OBJECT - setting for specific object, overrides general settings
			GROUP - setting for specific group, overrides general settings
		2: ARRAY of STRINGs - attributes
			object:
				Skill
				UnitPos
				Rank
				Damage
				Fuel
				Lock
				RespawnVehicle
				RespawnPosition
				Exec
			group:
				GroupID
				Behaviour
				Formation
			waypoint:
				Behaviour
				Formation
			marker:
				MarkerText
				MarkerColor

	Returns:
	BOOL
*/

private ["_curator","_target","_attributes","_varName"];

_curator = _this param [0,objnull,[objnull]];
_target = _this param [1,objnull,[objnull,grpnull,""]];
_attributes = _this param [2,[],[[],true]];

if !(_curator call bis_fnc_iscurator) exitwith {["%1 is not a curator",_curator] call bis_fnc_error; false}; //--- ToDO: Replace by 'isCurator'

if (typename _attributes == typename true) then {_attributes = "%ALL";};

_varName = "BIS_fnc_curatorAttributes";
if (typename _target == typename "") then {
	switch (tolower _target) do {
		case ("object");
		case ("player");
		case ("group");
		case ("waypoint");
		case ("marker"): {
			_varName = _varName + _target;
			_target = _curator;
		};
		default {
			["Target is '%1' must be 'object', 'player', 'group', 'waypoint' or 'marker'",_target] call bis_fnc_error;
			_target = objnull
		};
	};
};
if !(isnull _target) then {
	_target setvariable [_varName,_attributes,true];
	true
} else {
	false
};