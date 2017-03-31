_logic = _this select 0;
_units = _this select 1;
_activated = _this select 2;

//--- Sort synced objects
_curatorVar = _logic getvariable ["curator",""];
_curator = missionnamespace getvariable [_curatorVar,objnull];
_curators = if (isnull _curator) then {[]} else {[_curator]};
_addons = [];
_errorObjects = [];
{
	if (_x call bis_fnc_isCurator) then {
		_curators set [count _curators,_x];
	} else {
		_xType = typeof vehicle _x;
		_xAddons = unitaddons _xType;
		if (count _xAddons > 0) then {
			_addons = _addons + _xAddons;
		} else {
			if !(_x in _errorObjects) then {_errorObjects set [count _errorObjects,_xType];};
		};
	};
} foreach (synchronizedobjects _logic);

//--- Show error when some addons are misconfigured
if (count _errorObjects > 0) then {
	_errorObjects spawn {
		sleep 0.1;
		_objects = "";
		_authorsArray = [];
		{
			if (_objects != "") then {_objects = _objects + ", "};
			_objects = _objects + _x;
			_author = gettext (configfile >> "cfgvehicles" >> _x >> "author");
			if !(_author in _authorsArray) then {_authorsArray set [count _authorsArray,_author];};
		} foreach _this;
		_authors = "";
		{
			if (_authors != "") then {_authors = _authors + ", "};
			_authors = _authors + _x;
		} foreach _authorsArray;
		["Some objects (%1) are misconfigured and cannot be used by Zeus as a result.<br /><br />Addon authors (%2) must correctly define all objects in CfgPatches.",_objects,_authors] call bis_fnc_errorMsg;
	};
};

if (count _curators == 0) exitwith {["No curator synchronized to %1",_logic] call bis_fnc_error;};

//--- Sort custom classes
_paramAddons = call compile ("[" + (_logic getvariable ["addons",""]) + "]");
{
	if !(_x in _addons) then {_addons set [count _addons,_x];};
	{
		if !(_x in _addons) then {_addons set [count _addons,_x];};
	} foreach (unitaddons _x);
} foreach _paramAddons;

_mode = _logic getvariable ["mode",true];

if (_activated) then {
	if (_mode) then {
		{_x addcuratoraddons _addons;} foreach _curators;

		//--- Show notification
		_text = _logic getvariable ["text",""];
		if (_text != "") then {
			{
				[
					["CuratorAddAddons",[_text]],
					"bis_fnc_showNotification",
					getassignedcuratorunit _x
				] call bis_fnc_mp;
			} foreach _curators;
		} else {

			_fnc_countItems = {
				_array = _this select 0;
				_item = _this select 1;

				_index = _array find _item;
				if (_index < 0) then {
					_index = count _array;
					_array set [_index,_item];
					_array set [_index + 1,0];
				};
				_arraCount = _array select (_index + 1);
				_array set [_index + 1,_arraCount + 1];
			};

			{
				_classes = [];
				_units = getarray (configfile >> "cfgpatches" >> _x >> "units");
				{
					_cfg = configfile >> "cfgvehicles" >> _x;
					_side = getnumber (_cfg >> "side");
					_factionText = "";
					_vehicleClass = gettext (_cfg >> "vehicleClass");
					_vehicleClassText = if (_vehicleClass == "Modules") then {
						_category = gettext (_cfg >> "category");
						gettext (configfile >> "cfgfactionclasses" >> _category >> "displayname");
					} else {
						_faction = gettext (_cfg >> "faction");
						_factionText = gettext (configfile >> "cfgfactionclasses" >> _faction >> "displayname");
						gettext (configfile >> "cfgvehicleclasses" >> _vehicleClass >> "displayname");
					};
					_class = if (_side in [0,1,2]) then {format ["%1 %2",_factionText,_vehicleClassText]} else {_vehicleClassText};
					[_classes,_class] call _fnc_countItems;
				} foreach _units;

				_text = "";
				_maxCount = 0;
				for "_i" from 0 to (count _classes - 1) step 2 do {
					_class = _classes select _i;
					_count = _classes select (_i + 1);
					if (_count > _maxCount) then {
						_maxCount = _count;
						_text = _class;
					};
				};
				{
					[
						["CuratorAddAddons",[_text]],
						"bis_fnc_showNotification",
						getassignedcuratorunit _x
					] call bis_fnc_mp;
				} foreach _curators;
			} foreach _addons;
		};
	} else {
		{_x removecuratoraddons _addons;} foreach _curators;
	};
} else {
	if (_mode) then {
		{_x removecuratoraddons _addons;} foreach _curators;
	} else {
		{_x addcuratoraddons _addons;} foreach _curators;
	};
};