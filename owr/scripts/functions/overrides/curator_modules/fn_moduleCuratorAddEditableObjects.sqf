_logic = _this select 0;
_units = _this select 1;
_activated = _this select 2;

if (_activated) then {

	_curatorVar = _logic getvariable ["curator",""];
	_curator = missionnamespace getvariable [_curatorVar,objnull];
	_curators = if (isnull _curator) then {[]} else {[_curator]};
	_objects = [];
	{
		if (_x call bis_fnc_isCurator) then {
			if !(_x in _curators) then {
			_curators set [count _curators,_x];
			};
		} else {
			if (_x iskindof "All") then {
				_objects set [count _objects,_x];
			};
		};
		_x synchronizeobjectsremove [_logic];
	} foreach (synchronizedobjects _logic);

	_addCrew = _logic getvariable ["addCrew",true];
	{
		_x addcuratoreditableobjects [_objects,_addCrew];
	} foreach _curators;
};