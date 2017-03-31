/*
	Author: Karel Moricky

	Description:
	Move curator camera to a position and direction.
	Has to be tun in scheduled environment. Finished when animation ends.

	Parameter(s):
		0 - positon, for supported types see BIS_fnc_position
		1: ARRAY - vector dir or target object / position
		2: NUMBER - commit time

	Returns:
	BOOL
*/

if (isnull curatorcamera) exitwith {false};

_pos = _this param [0,getposatl curatorcamera];
_pos = _pos call bis_fnc_position;
_vectordir = (_this param [1,vectordir curatorcamera,[[],objnull],3]);
_commit = _this param [2,0,[0,true]];

//--- Check if the position is in camera area
_cameraArea = curatorcameraarea (getassignedcuratorlogic player);
_inArea = if (count _cameraArea > 0) then {
	{
		_areaPos = _x select 1;
		_areaRadius = _x select 2;
		([_areaPos,_pos] call bis_fnc_distance2D) < _areaRadius
	} count _cameraArea > 0
} else {
	true //--- No area defined
};
if !(_inArea) exitwith {false};

//--- Calculate the speed automatically
if (typename _commit == typename true) then {
	_commit = if (_commit) then {(_pos distance (getposatl curatorcamera)) * 0.0024} else {0};
};

_curatorCameraPos = getposatl curatorcamera;

_cam = "camera" camcreate getposatl curatorcamera;
_cam cameraeffect ["internal","back"];
cameraEffectEnableHUD true;
_cam campreparefocus [-1,-1];
_cam campreparepos _curatorCameraPos;
_cam campreparetarget screentoworld [0.5,0.5];
_cam camcommitprepared 0;

//--- Use unit vector, or specific target?
_target = if (_vectordir distance [0,0,0] < 10) then {
	_vectordir = +([_vectordir,10000] call bis_fnc_vectormultiply);
	[_pos,_vectordir] call bis_fnc_vectoradd;
} else {
	_vectordir
};

_cam campreparetarget _target;
_cam campreparepos _pos;
_cam camcommitprepared _commit;

_time = time;
waituntil {camcommitted _cam && time > _time};
//if (_curatorCameraPos distance (getposatl curatorcamera) > 0) exitwith {};

curatorcamera setpos _pos;
curatorcamera setvectordir vectordir _cam;
curatorcamera setvectorup vectorup _cam;
/*
if (typename _target == typename objnull) then {
	curatorcamera campreparetarget _target;
	curatorcamera camcommitprepared 0;
};
*/

_cam cameraeffect ["terminate","back"];
camdestroy _cam;
curatorcamera cameraeffect ["internal","back"];
cameraEffectEnableHUD true;

true