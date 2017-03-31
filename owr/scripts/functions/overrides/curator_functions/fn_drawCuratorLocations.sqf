/*
	Author: Karel Moricky

	Description:
	Label every vilage, town and city in curator interface

	Parameter(s):
		0: OBJECT - curator module

	Returns:
	BOOL
*/

private ["_curator"];
_curator = _this param [0,objnull,[objnull]];
{
	_pos = locationposition _x;
	_pos set [2,0];
	[
		_curator,
		[
			"#(argb,8,8,3)color(0,0,0,0)",
			[1,1,1,1],
			_pos,
			0,
			0,
			0,
			text _x,
			2,
			0.05
		],
		false,
		true
	] call bis_fnc_addcuratoricon;
} foreach (nearestlocations [position player,["nameVillage","nameCity","nameCityCapital"],100000]);
true