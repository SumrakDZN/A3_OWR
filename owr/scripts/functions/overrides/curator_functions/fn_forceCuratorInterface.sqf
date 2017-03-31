/*
	Author: Karel Moricky

	Description:
	Force curator interface, so user cannot exit it by pressing Zeus key

	Parameter(s):
		0: BOOL - true to force the interafce
		1 (Optional): BOOL - true to keep trying until the interface is actually opened

	Returns:
	BOOL
*/

private ["_force"];
_force = _this param [0,false,[false]];
_scheduled = _this param [1,false,[false]];
missionnamespace setvariable ["BIS_fnc_forceCuratorInterface_force",_force];

if (_scheduled) then {
	if (_force) then {
		_n = 0;
		waituntil {time > 0};
		while {
			isnull curatorcamera && _n < 500
		} do {
			opencuratorinterface;
			_n = _n + 1;
			sleep 0.01;
		};
	};
} else {
	if (_force) then {
		opencuratorinterface
	};
};
_force