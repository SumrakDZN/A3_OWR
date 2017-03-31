/*
	Author: Karel Moricky

	Description:
	Mirror settings from once curator to another

	Parameter(s):
		0: OBJECT or ARRAY of OBJECTs - curators(s) from which settings are taken from
		1: OBJECT or ARRAY of OBJECTs - curators(s) to which settings are applied to
		2: ARRAY of STRINGs - copied modes, can be "addons", "objects" and/or "coefs"
		3: BOOL - true to share settings both ways, false to make second curator slave to the first one

	Returns:
	BOOL
*/


if !(isserver) exitwith {["%1 can run only on server",_fnc_scriptname] call bis_fnc_error; false};

_from = _this param [0,objnull,[objnull,[]]];
_to = _this param [1,objnull,[objnull,[]]];
_modes = _this param [2,["addons","objects"],[[]]];
_combine = _this param [3,false,[false]];

if (count _modes == 0) exitwith {false};

if (typename _from != typename []) then {_from = [_from];};
if (typename _to != typename []) then {_to = [_to];};

if (count _from == 0) exitwith {"No curators to copy settings from defined" call bis_fnc_error; false};
if (count _to == 0) exitwith {"No curators to copy settings to defined" call bis_fnc_error; false};

_mirrorAddons = {_x == "addons"} count _modes > 0;
_mirrorObjects = {_x == "objects"} count _modes > 0;
_mirrorCoefs = {_x == "coefs"} count _modes > 0;

_delay = 1 / (count _modes);

while {true} do {

	//--- Addons
	if (_mirrorAddons) then {
		_addonsFrom = [];
		{_addonsFrom = _addonsFrom + curatoraddons _x;} foreach _from;

		_addonsTo = [];
		{_addonsTo = _addonsTo + curatoraddons _x;} foreach _to;

		_addonsAdd = _addonsFrom - _addonsTo;
		if (count _addonsAdd > 0) then {
			{_x addcuratoraddons _addonsAdd;} foreach _to;
		};
		_addonsRemove = _addonsTo - _addonsFrom;
		if (count _addonsRemove > 0) then {
			if (_combine) then {
				{_x addcuratoraddons _addonsRemove;} foreach _from;
			} else {
				{_x removecuratoraddons _addonsRemove;} foreach _to;
			};
		};
		sleep _delay;
	};

	//--- Objects
	if (_mirrorObjects) then {
		_objectsFrom = [];
		{_objectsFrom = _objectsFrom + curatoreditableobjects _x;} foreach _from;

		_objectsTo = [];
		{_objectsTo = _objectsTo + curatoreditableobjects _x;} foreach _to;

		_objectsAdd = _objectsFrom - _objectsTo;
		if (count _objectsAdd > 0) then {
			{_x addcuratoreditableobjects [_objectsAdd];} foreach _to;
		};
		_objectsRemove = _objectsTo - _objectsFrom;
		if (count _objectsRemove > 0) then {
			if (_combine) then {
				{_x addcuratoreditableobjects [_objectsRemove];} foreach _from;
			} else {
				{_x removecuratoreditableobjects [_objectsRemove];} foreach _to;
			};
		};
		sleep _delay;
	};

	//--- Coefs
	if (_mirrorCoefs) then {
		{
			_type = _x;
			_value = (_from select 0) curatorcoef _type;
			{
				_x setcuratorcoef [_type,_value];
			} foreach _to;
		} foreach ["place","edit","delete","destroy","group","synchronize"];
	};
};