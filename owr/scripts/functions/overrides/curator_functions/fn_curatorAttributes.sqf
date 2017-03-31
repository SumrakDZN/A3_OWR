/*
	Author: Karel Moricky

	Description:
	Return attributes available for given entity

	Parameter(s):
		0: OBJECT - curator
		1: OBJECT or GROUp or ARRAY or STRING - checked entity

	Returns:
	ARRAY of STRINGs
*/

private ["_curator","_target","_all","_varName"];
_curator = _this param [0,objnull,[objnull]];
_target = _this param [1,objnull,[objnull,grpnull,[],""]];

if !(_curator call bis_fnc_iscurator) exitwith {["%1 is not a curator",_curator] call bis_fnc_error; []}; //--- ToDO: Replace by 'isCurator'

_all = "%ALL";
_varName = "BIS_fnc_curatorAttributes";
switch (typename _target) do {
	case (typename objnull): {
		private ["_result"];
		if (isnull _target) then {_target = _curator;};
		_result = _target getvariable [_varName,_curator getvariable [_varName + "object",[_all]]];
		if (isplayer _target) then {_result = _target getvariable [_varName,_curator getvariable [_varName + "player",_result]];};
		_result
	};
	case (typename grpnull): {
		_target getvariable [_varName,_curator getvariable [_varName + "group",[_all]]];
	};
	case (typename []): {
		_curator getvariable [_varName + "waypoint",[_all]];
	};
	case (typename ""): {
		_curator getvariable [_varName + "marker",[_all]];
	};
};