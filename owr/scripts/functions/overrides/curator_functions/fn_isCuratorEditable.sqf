/*
	Author: Karel Moricky

	Description:
	Return if given object is editable by player (when he's curator)

	Parameter(s):
		0: OBJECT

	Returns:
	BOOL
*/

private ["_object"];
_object = _this param [0,objnull];
count (objectcurators _object) > 0 || (_object getvariable ["bis_fnc_moduleInit_isCuratorPlaced",false])
//_object in (curatoreditableobjects (getassignedcuratorlogic player))