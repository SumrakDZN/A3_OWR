/*
_logic = _this select 0;
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

	_type = _logic getvariable ["type",false];
	{_x setcuratorcameraareatype _type;} foreach _curators;
};
*/