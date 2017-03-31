private ["_logic"];
_logic = _this param [0,objnull,[objnull]];

//--- Module init
private ["_units","_activated"];
_units = _this select 1;
_activated = _this select 2;

if (_activated) then {
	
	_curatorVar = _logic getvariable ["curator",""];
	_curator = missionnamespace getvariable [_curatorVar,objnull];
	_curators = if (isnull _curator) then {[]} else {[_curator]};
	{
		if (_x call bis_fnc_isCurator && !(_x in _curators)) then {_curators set [count _curators,_x];};
	} foreach (synchronizedobjects _logic);

	if (count _curators == 0) exitwith {["No curator synchronized to %1",_logic] call bis_fnc_error;};

	//--- Get attributes
	_sideClasses = [];
	{
		_sideClass = configname _x;
		if (_sideClass != "Curator") then {
			_cost = _logic getvariable [_sideClass,1];
			_costArray = if (abs _cost < 10000) then {[true,_cost]} else {[false,0]};
			_sideClasses set [count _sideClasses,[_sideClass,_costArray]];
		};
	} foreach ((configfile >> "cfgvehicles" >> typeof _logic >> "Arguments") call bis_fnc_returnchildren);
	{
		_curator = _x;

		//--- Store attributes into curator logic
		{_curator setvariable _x} foreach _sideClasses;

		if !(_curator getvariable ["BIS_fnc_moduleCuratorSetCostsSide_added",false]) then {
			//--- Add event handler (only once)
			[
				_curator,
				{
					private ["_logic","_classes","_logic","_costs","_side"];
					_curator = _this param [0,objnull,[objnull]];
					_classes = _this param [1,[],[[]]];
					_costs = [];
					{
						_side = getnumber (configfile >> "cfgvehicles" >> _x >> "side");
						if (_side != 7 && !(_x iskindof "allvehicles")) then {_side = -1;};
						_sideClass = switch _side do {
							case 0: {"east"};
							case 1: {"west"};
							case 2: {"guer"};
							case 3: {"civ"};
							case 7: {"logic"};
							default {"empty"};
						};
						_cost = _curator getvariable ["costSide_" + _sideClass,[false,0]];
						_costs set [count _costs,if (isnil "_cost") then {nil} else {_cost}];
					} foreach _classes;
					_costs
				}
			] call bis_fnc_curatorObjectRegistered;
			_curator setvariable ["BIS_fnc_moduleCuratorSetCostsSide_added",true];
		};
	} foreach _curators;
};