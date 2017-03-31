/*
	Author: Karel Moricky

	Description:
	Return if given object is curator logic

	Parameter(s):
		0: OBJECT

	Returns:
	BOOL
*/

private ["_curator"];
_curator = _this param [0,objnull,[objnull]];
gettext (configfile >> "cfgvehicles" >> typeof _curator >> "simulation") == "curator"