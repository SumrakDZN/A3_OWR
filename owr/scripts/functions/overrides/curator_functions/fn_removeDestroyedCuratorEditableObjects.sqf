/*
	Author: Karel Moricky

	Description:
	Make destroyed curator objects non-editable

	Parameter(s):
		0:  OBJECT - curator or object to be removed after death
		1: ARRAY of STRINGS - parent classes of objects to be removed (e.g., "Man")

	Returns:
	BOOL
*/

private ["_curator"];
_curator = _this param [0,objnull,[objnull]];
if (_curator call bis_fnc_iscurator) then {

	if (isserver) then {
		private ["_classes"];
		_classes = _this param [1,["All"],[[],""]];
		if (typename _classes != typename []) then {_classes = [_classes];};
		_curator setvariable ["bis_fnc_removeDestroyedCuratorEditableObjects_classes",_classes];
		{
			[_x] call bis_fnc_removeDestroyedCuratorEditableObjects;
		} foreach (curatoreditableobjects _curator);
	};

	_curator addeventhandler [
		"curatorObjectPlaced",
		{
			[_this select 1] call bis_fnc_removeDestroyedCuratorEditableObjects;
		}
	];
} else {
	_curator addmpeventhandler [
		"mpkilled",
		{
			if (isserver && !isplayer _object) then {
				_object = _this select 0;
				{
					_classes = _x getvariable ["bis_fnc_removeDestroyedCuratorEditableObjects_classes",[]];
					if ({_object iskindof _x} count _classes > 0) then {
						//--- Wait so other systems can process the death as well
						[_x,_object] spawn {
							sleep 1;
							(_this select 0) removecuratoreditableobjects [[(_this select 1)],true];
						};
					};
				} foreach (objectcurators _object);
			};
		}
	];
};
true