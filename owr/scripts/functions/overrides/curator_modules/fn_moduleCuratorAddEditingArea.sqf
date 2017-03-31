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

_name = _logic getvariable ["name",""];
_name = _name call bis_fnc_localize;
{
	_curator = _x;
	{
		//--- Add
		_id = _logic getvariable [_x select 0,round ((position _logic select 0) + (position _logic select 1))]; //--- Unique ID based on position
		_logic setvariable [_x select 0,_id];
		_pos = _x select 1;
		_radius = ((_x select 2) select 0) max ((_x select 2) select 1);
		if (_name == "") then {
			_name = _pos call bis_fnc_locationDescription;
			_nameArray = toarray _name;
			_nameArray set [0,(toarray toupper tostring [_nameArray select 0]) select 0];
			_name = tostring _nameArray;
		};

		if (_activated) then {

			//--- Announce
			[
				["CuratorAddArea",[_name]],
				"bis_fnc_showNotification",
				getassignedcuratorunit _curator
			] call bis_fnc_mp;

			if (count _units > 0) then {

				//--- Attach the area to synced object
				[_curator,_id,_units select 0,_radius] spawn {
					scriptname "BIS_fnc_moduleCuratorAddEditingArea: Attach";
					_curator = _this select 0;
					_id = _this select 1;
					_unit = _this select 2;
					_radius = _this select 3;
					waituntil {
						_curator addcuratoreditingarea [_id,position _unit,_radius];
						sleep 0.1;
						{(_x select 0) == _id} count (curatoreditingarea _curator) == 0
					};
				};
			} else {
				//--- Static position
				_curator addcuratoreditingarea [_id,_pos,_radius];
			};
		} else {
			_curator removecuratoreditingarea _id;

		};
	} foreach _areas;
} foreach _curators;