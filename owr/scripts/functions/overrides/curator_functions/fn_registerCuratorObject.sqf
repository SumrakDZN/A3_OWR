/*
	Author: Karel Moricky

	Description:
	Get individual cost of an object.
	Obsolete.

	Parameter(s):
		0: STRING - object class
		1: BOOL - default show status
		2: NUMBER - default cost

	Returns:
	ARRAY in format [<show>,<cost>,<cost>]
*/

private ["_class","_show","_cost","_return"];

_class = _this select 0;
_show = _this select 1;
_cost = _this select 2;

_return = [_show,_cost,_cost];
_return = missionnamespace getvariable ["BIS_fnc_registerCuratorObject_" + _class,_return];
_return