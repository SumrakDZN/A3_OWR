/*
	Author: Karel Moricky

	Description:
	Make addons available to curators when provided condition is true.

	Parameter(s):
		0: OBJECT or ARRAY of OBJECTs - curator(s)
		1: STRING or ARRAY of STRINGs - CfgPatches classes
		2: CODE - unlock condition
		3: STRING - notification text

	Returns:
	BOOL
*/

_curators = _this param [0,[],[objnull,[]]];
_addons = _this param [1,[],["",[]]];
_condition = _this param [2,{true},[{}]];
_text = _this param [3,"",[""]];

if (typename _addons != typename []) then {_addons = [_addons];};
if (typename _curators != typename []) then {_curators = [_curators];};

_list = missionnamespace getvariable ["bis_fnc_manageCuratorAddons_addons",[]];
_list set [count _list,[_curators,_addons,_condition,_text]];
missionnamespace setvariable ["bis_fnc_manageCuratorAddons_addons",_list];

if (isnil "bis_fnc_manageCuratorAddons_loop") then {
	bis_fnc_manageCuratorAddons_loop = [] spawn {
		scopename "BIS_fnc_manageCuratorAddons: Loop";
		_listResults = [];
		_listTexts = [];

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

		while {true} do {
			_list = missionnamespace getvariable ["bis_fnc_manageCuratorAddons_addons",[]];
			_delay = 1 / (count _list + 1);

			{
				_curators = _x select 0;
				_addons = _x select 1;
				_condition = _x select 2;
				_text = _x select 3;

				_added = _listResults select _foreachindex;
				if (isnil "_added") then {
					_added = false;
					_listResults set [_foreachindex,_added];
				};

				if (
					//--- Check for the condition in a safe environment
					_condition call {
						private ["_list","_delay","_curators","_addons","_condition"];
						[] call _this
					}
				) then {
					if !(_added) then {
						{
							_x addcuratoraddons _addons;
							if (_text != "") then {
								[
									["CuratorAddAddons",[_text]],
									"bis_fnc_showNotification",
									getassignedcuratorunit _x
								] call bis_fnc_mp;
							};
						} foreach _curators;
						_listResults set [_foreachindex,true];
					};
				} else {
					if (_added) then {
						{
							_x removecuratoraddons _addons;
						} foreach _curators;
						_listResults set [_foreachindex,false];
					};
				};
				sleep _delay;
			} foreach _list;
		};
	};
};
TRUE