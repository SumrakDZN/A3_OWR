_logic = _this select 0;
_units = _this select 1;
_activated = _this select 2;

if (_activated) then {
	_cost = _logic getvariable ["Cost",0];
	_show = _logic getvariable ["Show",true];
	{
		if (_x iskindof "All") then {
			missionnamespace setvariable ["BIS_fnc_registerCuratorObject_" + typeof _x,[_show,_cost,_cost]];
		};
	} foreach (synchronizedobjects _logic);
};