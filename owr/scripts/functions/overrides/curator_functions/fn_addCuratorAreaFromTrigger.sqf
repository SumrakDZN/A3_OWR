/*
	Author: Karel Moricky

	Description:
	Add curator editing / camera area based on triggers

	Parameter(s):
		0: OBJECT - curator logic
		1: ARRAY - list of triggers
		2: checked position (for supported data types, see BIS_fnc_position)
		3: BOOL - true to use a trigger nearest to the position, false to use all triggers which the position is in
		4: BOOL - true to add editing area
		4: BOOL - true to add camera area

	Returns:
	BOOL
*/

_curator = _this param [0,objnull,[objnull]];
_triggers = _this param [1,[],[[]]];
_pos = _this param [2,objnull];
_useNearest = _this param [3,true,[true]];
_addEditing = _this param [4,true,[false]];
_addCamera = _this param [5,true,[false]];

_varEditing = _fnc_scriptName + "editing";
_varCamera = _fnc_scriptName + "editing";

if (!_addEditing && !_addCamera) exitwith {"At least one area type has to be enabled" call bis_fnc_error; false};

//--- Use default trigger list - all triggers
if (count _triggers == 0) then {
	_triggers = allmissionobjects "EmptyDetector";
};

//--- Use default position - center of all curator players
_pos = _pos call bis_fnc_position;
if (_pos distance [0,0,0] == 0) then {
	_playableunits = playableunits + switchableunits;
	_units = curatoreditableobjects _curator;
	_avgPosX = 0;
	_avgPosY = 0;
	_unitsCount = 0;
	{
		if (_x in _playableunits) then {
			_xPos = position _x;
			_avgPosX = _avgPosX + (_xPos select 0);
			_avgPosY = _avgPosY + (_xPos select 1);
			_unitsCount = _unitsCount + 1;
		};
	} foreach _units;
	if (_unitsCount > 0) then {
		_avgPosX = _avgPosX / _unitsCount;
		_avgPosY = _avgPosY / _unitsCount;
		_pos = [_avgPosX,_avgPosY,0];
	} else {
		_mapSize = [] call bis_fnc_mapSize;
		_pos = [_mapSize * 0.5,_mapSize * 0.5,0];
	};
};

//--- Find suitable triggers
_minDis = 1e10;
_activeTriggers = [];
{
	if ((_addEditing && isnil {_x getvariable _varEditing}) || (_addCamera && isnil {_x getvariable _varCamera})) then {
		if (_useNearest) then {

			//--- Only nearest trigger
			_dis = _x distance _pos;
			if (_dis < _minDis) then {
				_minDis = _dis;
				_activeTriggers = [_x];
			};
		} else {

			//--- All triggers the position is in
			if ([_x,_pos] call bis_fnc_inTrigger) then {
				_activeTriggers set [count _activeTriggers,_x];
			};
		};
	};
} foreach _triggers;

//--- Unlock triggers
{
	_sizeArray = triggerarea _x;
	_size = (_sizeArray select 0) max (_sizeArray select 1);
	if (_addEditing) then {
		_curator addcuratoreditingarea [count (curatoreditingarea _curator),position _x,_size];
		_x setvariable [_varEditing,true];
	};
	if (_addCamera) then {
		_curator addcuratorcameraarea [count (curatoreditingarea _curator),position _x,_size];
		_x setvariable [_varCamera,true];
	};
} foreach _activeTriggers;

true