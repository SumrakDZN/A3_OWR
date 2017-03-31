/*
	Author: Karel Moricky

	Description:
	Register "curatorObjectRegistered" handler.
	Cost of vehicles with crews will be automatically calculated based on vehicle + crew cost.

	Parameter(s):
		0: OBJECT - curator module
		1: CODE - handler code, passed arguments are [<curator:Object>,<classes:Array>]

	Returns:
	BOOL
*/

private ["_curator","_input","_var","_varHandler"];
_curator = _this param [0,objnull,[objnull]];
_input = _this param [1,[],[[],{}]];

_var = _fnc_scriptName;
_varHandler = _var + "handler";

if (typename _input == typename {}) then {

	//--- Register
	private ["_codes"];
	_codes = _curator getvariable [_var,[]];
	_codes set [count _codes,_input];
	_curator setvariable [_var,_codes];

	if (isnil {_curator getvariable _varHandler}) then {
		private ["_handler"];
		_handler = _curator addEventHandler ["curatorObjectRegistered",{_this call bis_fnc_curatorObjectRegistered}];
		_curator setvariable [_varHandler,_handler];
	};
	true
} else {

	//--- Execute (executed from within "curatorObjectRegistered" handler)
	_classes = _input;
	{
		_classes set [_foreachindex,tolower _x];
	} foreach _classes;
	_codes = _curator getvariable [_var,[]];
	_costArrays = [];
	{
		_xCosts = [[_curator,_classes],_x] call {
			private ["_curator","_input","_var","_varHandler","_classes"];
			(_this select 0) call (_this select 1)
		};
		_xCosts = [_xCosts] param [0,[],[[]],count _classes];
		_costArrays set [count _costArrays,_xCosts];
	} foreach _codes;

	//--- Calculcate costs from all arrays (values are multiplied together)
	_costs = [];
	{
		_class = _x;
		_classID = _foreachindex;
		_nil = true;
		_show = true;
		_cost = 1;
		{
			_xCosts = _x select _classID;
			if !(isnil "_xCosts") then {
				_nil = false;
				_show = _show && (_xCosts select 0);
				_cost = _cost * (_xCosts select 1);
			};
			//[_class,_xCosts,_show,_cost] call bis_fnc_log;
		} foreach _costArrays;
		_costArray = if (_nil) then {[false,0]} else {[_show,_cost]};
		_costs set [_foreachindex,_costArray];
	} foreach _classes;

	//--- Calculate crew cost
	_crewDefault = gettext (configfile >> "CfgVehicles" >> "All" >> "crew");
	{
		if (count _x == 2) then {
			_class = _classes select _foreachindex;
			_crewClass = tolower gettext (configfile >> "CfgVehicles" >> _class >> "crew");
			if (_crewClass != _crewDefault && _crewClass != "") then {
				_crewIndex = _classes find _crewClass;
				if (_crewIndex < 0) then {
					_x set [0,false];
					_x resize 1;
				} else {
					_crewCount = _class call bis_fnc_crewCount;
					_crewCostArray = _costs select _crewIndex;
					_crewCost = _crewCostArray param [1,0,[0]];
					_x set [2,(_x select 1) + _crewCost * _crewCount];
				};
			};
		};
	} foreach _costs;
	_costs
};