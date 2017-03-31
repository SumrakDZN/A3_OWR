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
	_vehicleClasses = [];
	{
		_vehicleClass = configname _x;
		if (_vehicleClass != "Curator") then {
			_cost = _logic getvariable [_vehicleClass,0];
			_costArray = if (abs _cost < 10000) then {[true,_cost]} else {[false,0]};
			_vehicleClasses set [count _vehicleClasses,[_vehicleClass,_costArray]];
		};
	} foreach ((configfile >> "cfgvehicles" >> typeof _logic >> "Arguments") call bis_fnc_returnchildren);

	{
		_curator = _x;

		//--- Store attributes into curator logic
		{_curator setvariable _x} foreach _vehicleClasses;

		if !(_curator getvariable ["BIS_fnc_moduleCuratorSetCosts_added",false]) then {
			//--- Add event handler (only once)
			[
				_curator,
				{
					private ["_logic","_classes","_logic","_costs","_side"];
					_curator = _this param [0,objnull,[objnull]];
					_classes = _this param [1,[],[[]]];
					_costs = [];
					{
						_vehicleClass = gettext (configfile >> "cfgvehicles" >> _x >> "category");
						if (_vehicleClass == "") then {_vehicleClass = gettext (configfile >> "cfgvehicles" >> _x >> "vehicleClass")};
						_cost = _curator getvariable ["cost_" + _vehicleClass,[false,0]];
						_costs set [count _costs,if (isnil "_cost") then {nil} else {_cost}];
					} foreach _classes;
					_costs
				}
			] call bis_fnc_curatorObjectRegistered;
			_curator setvariable ["BIS_fnc_moduleCuratorSetCosts_added",true];
		};
	} foreach _curators;
};