_logic = _this select 0;
_units = _this select 1;
_activated = _this select 2;

if (_activated) then {

	if !(isnil "bis_fnc_moduleCuratorAddEditingAreaPlayers_script") exitwith {};

	_curatorVar = _logic getvariable ["curator",""];
	_curator = missionnamespace getvariable [_curatorVar,objnull];
	_curators = if (isnull _curator) then {[]} else {[_curator]};
	{
		if (_x call bis_fnc_isCurator && !(_x in _curators)) then {_curators set [count _curators,_x];};
	} foreach (synchronizedobjects _logic);

	if (count _curators == 0) exitwith {["No curator synchronized to %1",_logic] call bis_fnc_error;};


	bis_fnc_moduleCuratorAddEditingAreaPlayers_script = [_logic,_curators] spawn {
		scriptname "bis_fnc_moduleCuratorAddEditingAreaPlayers: Loop";
		_logic = _This select 0;
		_curators = _this select 1;
		_size = _logic getvariable ["size",100];
		_type = _logic getvariable ["type",0];

		//--- Load size from mission params
		_sizeParam = ["PlayerEditingAreaSize",-1] call bis_fnc_getparamvalue;
		if (_sizeParam >= 0) then {_size = _sizeParam;};

		if (_size == 0) exitwith {};

		_groupsOnly = _type > 0;
		_idMax = 0;

		//--- Set area type to be blacklist
		waituntil {time > 0};
		{_x setcuratoreditingareatype false;} foreach _curators;

		waituntil {
			_allPlayers = playableunits + switchableunits;
			_id = -1;
			if (count _allPlayers > 0) then {
				waituntil {
					_unit = _allPlayers select 0;
					if (_groupsOnly) then {
						_unit = leader _unit;
						_allPlayers = _allPlayers - [_unit] - units _unit;
					} else {
						_allPlayers = _allPlayers - [_unit];
					};
					if !(_unit call bis_fnc_isunitvirtual) then {
						_id = _id + 1;
						{_x addcuratoreditingarea [100 + _id,position _unit,_size];} foreach _curators;
					};
					count _allPlayers == 0
				};
				sleep 0.1;
			} else {
				sleep 1;
			};

			//--- Remove unused areas
			if (_id < _idMax) then {
				for "_i" from (_id + 1) to _idMax do {
					{_x removecuratoreditingarea (100 + _i);} foreach _curators;
				};
				_idMax = 0;
			};
			_idMax = _idMax max _id;

			false
		};
	};
} else {
	if !(isnil "bis_fnc_moduleCuratorAddEditingAreaPlayers_script") then {terminate bis_fnc_moduleCuratorAddEditingAreaPlayers_script;};
};