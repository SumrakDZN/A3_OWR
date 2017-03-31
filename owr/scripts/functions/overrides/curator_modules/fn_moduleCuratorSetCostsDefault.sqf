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
	{
		_curator = _x;

		if !(_curator getvariable ["BIS_fnc_moduleCuratorSetCostsDefault_added",false]) then {
			//--- Add event handler (only once)
			[
				_curator,
				{
					private ["_curator","_classes","_costs"];
					_curator = _this param [0,objnull,[objnull]];
					_classes = _this param [1,[],[[]]];
					_costs = [];
					{
						private ["_cfg"];
						_cfg = configfile >> "cfgvehicles" >> _x;
						_cost = 1;
						switch true do {
							case (isnumber (_cfg >> "curatorCost")): {
								_cost = getnumber (_cfg >> "curatorCost");
							};
							case (istext (_cfg >> "curatorCost")): {
								_cost = call {
									private ["_curator","_classes","_costs"];
									call compile gettext (_cfg >> "curatorCost")
								};
								_cost = _cost param [0,1,[0]];
							};
							case (count getarray (_cfg >> "threat") == 3): {
								//--- Gauss mean of threat values (infantry * vehicles * air)
								private ["_threat"];
								_threat = getarray (_cfg >> "threat");
								_cost = ((sqrt ((_threat select 0) * (_threat select 1) * (_threat select 2))) max 0.1) * 10;
							};
						};
						_costs set [count _costs,if (abs _cost < 10000) then {[true,_cost]} else {[false,0]}];
					} foreach _classes;
					_costs
				}
			] call bis_fnc_curatorObjectRegistered;
			_curator setvariable ["BIS_fnc_moduleCuratorSetCostsDefault_added",true];
		};
	} foreach _curators;
};