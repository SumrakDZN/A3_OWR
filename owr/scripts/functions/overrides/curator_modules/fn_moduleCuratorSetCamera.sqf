_logic = _this select 0;
_units = _this select 1;
_activated = _this select 2;

if (_activated) then {
	
	_curatorVar = _logic getvariable ["curator",""];
	_curator = missionnamespace getvariable [_curatorVar,objnull];
	_curators = if (isnull _curator) then {[]} else {[_curator]};
	{
		if (_x call bis_fnc_isCurator && !(_x in _curators)) then {_curators set [count _curators,_x];};
	} foreach (synchronizedobjects _logic);

	if (count _curators == 0) exitwith {["No curator synchronized to %1",_logic] call bis_fnc_error;};

	_commit = _logic getvariable ["commit",0];
	_pitch = _logic getvariable ["pitch",0];
	_default = _logic getvariable ["useAsDefault",false];

	[_logic,_pitch,0] call bis_fnc_setpitchbank;

	{
		_curator = _x;
		if (_default) then {
			if (isserver) then {
				_curator setvariable ["bis_fnc_modulecuratorsetcamera_params",[getposatl _logic,vectordir _logic,_commit],true];
			};
		} else {
			if (local _curator) then {
				[getposatl _logic,vectordir _logic,_commit] spawn bis_fnc_setcuratorcamera;
			};
		};
	} foreach _curators;
};