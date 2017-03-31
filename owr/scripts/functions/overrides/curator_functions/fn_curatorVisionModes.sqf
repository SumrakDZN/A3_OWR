/*
	Author: Karel Moricky

	Description:
	Return allowed curator vision modes

	Parameter(s):
		0: OBJECT - curator

	Returns:
	ARRAY of NUMBERs
*/

private ["_curator"];
_curator = _this param [0,objnull,[objnull]];
_curator getvariable ["bis_fnc_curatorVisionModes_modes",[-1,-2]];