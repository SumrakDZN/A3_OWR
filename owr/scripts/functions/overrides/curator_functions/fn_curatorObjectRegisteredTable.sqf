/*
	Author: Karel Moricky

	Description:
	Register objects costs from table.
	Export a table into spreadsheet using BIS_fnc_exportCuratorCostTable and use the result as param for this function.

	Parameter(s):
		0: OBJECT - curator
		1: ARRAY of ARRAYs in format [<cost:Number>,<show:Bool>]

	Returns:
	BOOL
*/

_curator = _this param [0,objnull,[objnull]];
_data = +(_this param [1,[],[[]]]);

{
	if (typename _x == typename "") then {_data set [_foreachindex,tolower _x];};
} foreach _data;

_curator setvariable ["bis_fnc_curatorObjectRegisteredTable_data",_data];
[
	_curator,
	{
		private ["_curator","_classes","_data","_return"];
		_curator = _this param [0,objnull,[objnull]];
		_classes = _this param [1,[],[[]]];
		_data = _curator getvariable ["bis_fnc_curatorObjectRegisteredTable_data",[]];
		_return = [];
		{
			private ["_class","_index","_classReturn"];
			_class = tolower _x;
			_index = _data find _class;
			_classReturn = if (_index < 0) then {
				[false,0]
			} else {
				_classData = _data select (_index + 1);
				_cost = _classData param [0,0,[0]];
				_show = _classData param [1,true,[true]];
				[_show,_cost]
			};
			_return set [count _return,_classReturn];
		} foreach _classes;
		_return
	}
] call bis_fnc_curatorObjectRegistered;