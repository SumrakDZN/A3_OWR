_logic = _this select 0;
_units = _this select 1;
_activated = _this select 2;

_curatorVar = _logic getvariable ["curator",""];
_curator = missionnamespace getvariable [_curatorVar,objnull];
_curators = if (isnull _curator) then {[]} else {[_curator]};
_areas = [];
_logicArea = _logic getvariable "objectArea";
if !(isnil "_logicArea") then {
	_areas = [[str _logic,position _logic,_logicArea]];
};
{
	switch true do {
		case (_x  iskindof "LocationArea_F"): {
			{
				_areas append [[str _x,position _x,triggerarea _x]];
			} foreach (_x call bis_fnc_moduleTriggers);
		};
		case (_x call bis_fnc_isCurator && !(_x in _curators)): {_curators set [count _curators,_x];};
	};
} foreach (synchronizedobjects _logic);

if (count _curators == 0) exitwith {["No curator synchronized to %1",_logic] call bis_fnc_error;};

{
	_curator = _x;
	{
		//--- Add
		_id = _logic getvariable [_x select 0,round ((position _logic select 0) + (position _logic select 1))]; //--- Unique ID based on position
		_logic setvariable [_x select 0,_id];
		_radius = ((_x select 2) select 0) max ((_x select 2) select 1);
		_pos = _x select 1;

		if (_activated) then {
			_curator addcuratorcameraarea [_id,_pos,_radius];
		} else {
			_curator removecuratorcameraarea _id;

		};
	} foreach _areas;
} foreach _curators;

//--- Set camera ceiling
if (_activated) then {
	_ceiling = _logic getvariable ["ceiling",0];
	if (_ceiling > 0) then {
		{_x setCuratorCameraAreaCeiling _ceiling;} foreach _curators;
	};
};