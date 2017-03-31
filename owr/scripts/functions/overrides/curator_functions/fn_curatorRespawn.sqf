/*
	Author: Karel Moricky

	Description:
	Restore unit for curators after respawn.
	When curator owner, it will transfer ownership to the new unit.
	When editable by curator, it will remove the dead unit and register the new one.

	Parameter(s):
		0: OBJECT - new unit
		1: OBJECT - old (dead) unit

	Returns:
	BOOL
*/

_new = _this param [0,objnull,[objnull]];
_old = _this param [1,objnull,[objnull]];

if (isnull _new) exitwith {"Player is null" call bis_fnc_error; false};

if (isnull _old) then {
	//--- Register
	if (local _new && isnil {_new getvariable "BIS_fnc_addCuratorPlayer_handler"}) then {
		_handler = _new addmpeventhandler ["mprespawn",{[_this,"bis_fnc_curatorrespawn",false] call bis_fnc_mp;}];
		_new setvariable ["BIS_fnc_addCuratorPlayer_handler",_handler,true];
	};
} else {
	if (isserver) then {
		//--- Restore marked units (after small delay, so scripted respawn setposing is not visible)
		[_new,_old] spawn {
			scriptname "bis_fnc_curatorRespawn: Refresh editable object";
			_new = _this select 0;
			_old = _this select 1;
			sleep 0.1;
			{
				_x addcuratoreditableobjects [[_new],false];
				_x removecuratoreditableobjects [[_old],false];
			} foreach (objectcurators _old);
		};

		//--- Restore curator
		_curator = getassignedcuratorlogic _old;
		if !(isnull _curator) then {
			unassigncurator _curator;
			_new assignCurator _curator;
		};
	};
};

true