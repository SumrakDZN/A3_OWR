/*
	Author: Karel Moricky

	Description:
	Attach an object on another one under cursor

	Parameter(s):
		0: OBJECT - object

	Returns:
	BOOL
*/


#define HEIGHT	2

private ["_object"];
_object = _this param [0,objnull,[objnull]];

if (getnumber (configfile >> "cfgvehicles" >> typeof _object >> "curatorCanAttach") > 0) then {

	private ["_new","_current"];
	_new = if ((curatormouseover select 0) == "object") then {curatormouseover select 1} else {objnull};
	_current = _object getvariable ["bis_fnc_curatorAttachObject_object",objnull];
	if (_current in (curatorselected select 0)) then {_new = _current;};
	if (_current != _new && (!isnull _new || !isnull _current)) then {
		_object setvariable ["bis_fnc_curatorAttachObject_object",if (isnull _new) then {nil} else {_new},true];

		//--- Adjust object attached to currently attached object
		private ["_currentObjects"];
		_currentObjects = _current getvariable ["bis_fnc_curatorAttachObject_objects",[]];
		_currentObjects = _currentObjects - [objnull,_object];
		_current setvariable ["bis_fnc_curatorAttachObject_objects",_currentObjects,true];
		{
			_x attachto [_current,[0,0,HEIGHT + _foreachindex]];
		} foreach _currentObjects;

		if (isnull _new) then {
			detach _object;
			[_object,0] call bis_fnc_setheight;
		} else {
			//--- Attach to the new object
			private ["_newObjects"];
			_newObjects = _new getvariable ["bis_fnc_curatorAttachObject_objects",[]];
			_object attachto [_new,[0,0,HEIGHT + (count _newObjects)]];
			_newObjects = _newObjects - [objnull] + [_object];
			_new setvariable ["bis_fnc_curatorAttachObject_objects",_newObjects,true];
		};
	};
};
true