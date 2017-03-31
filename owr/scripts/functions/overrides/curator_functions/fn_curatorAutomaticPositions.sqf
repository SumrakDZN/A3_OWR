private ["_id","_var"];
_id = _this param [0,-1,[0]];
_var = "bis_fnc_curatorAutomaticPositions" + str _id;

if (isnil _var) then {
	private ["_pos","_size","_findPos","_positionsInfantry","_positionsGround","_positionsAir","_positionsWater"];
	_pos = _this param [1,[0,0,0],[[]]];
	_size = _this param [2,0,[0]];

	_findPos = {
		private ["_array","_isWater","_pos","_xIsWater"];
		_array = _this select 0;
		_isWater = _this select 1;
		{
			_pos = _x select 0;
			_xIsWater = surfaceiswater _pos;
			if (_isWater) then {_xIsWater = !_xIsWater};
			if (_xIsWater) then {_pos = -1;};
			_array set [_foreachindex,_pos];	
		} foreach _array;
		_array = _array - [-1];
		_array
	};

	_positionsInfantry = selectbestplaces [_pos,_size,"forest",1,10];
	_positionsInfantry = [_positionsInfantry,false] call _findPos;
	_positionsGround = _pos nearroads _size;
	_positionsAir = selectbestplaces [_pos,_size,"1",1,10];
	_positionsWater = selectbestplaces [_pos,_size,"sea",1,10];
	_positionsWater = [_positionsWater,true] call _findPos;
	missionnamespace setvariable [_var,[_positionsInfantry,_positionsGround,_positionsAir,_positionsWater]];
};
missionnamespace getvariable _var