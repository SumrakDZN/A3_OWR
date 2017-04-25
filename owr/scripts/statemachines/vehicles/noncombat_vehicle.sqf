// only executed on server! - just purely from safety - it should not be executed elsewhere
if (!(isServer)) exitWith {};

_vehicle = (_this select 0);			// vehicle itself
_fuel_type = (_this select 1);			// 0 = cb, 1 = sb, 2 = el,  
_control_type = (_this select 2); 		// 0 = mn, 1 = ai, 2 = rt
_side_type = (_this select 3);			// 0 = AM, 1 = RU
_chassis_type = (_this select 4);

//diag_log format ["%1 %2 %3 %4", _vehicle, _fuel_type, _control_type, _side_type];

_vehicleMaxSpeed = getNumber (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "maxSpeed");

[_vehicle, 1.0] remoteExec ["setFuel", owner _vehicle];			// always fully fueled after manufacturing
_electricBuffer = 0.0;
_currFuel = 0.0;
_manualControl = false;

// setup damage handlers - vehicle chassis dependent
// _side = 0 = west, _side = 1 = east
[_vehicle, _side_type, _chassis_type] call owr_fn_scriptedDmgSysVehicleEH;

switch (_control_type) do {
	case 0: {
		_manualControl = true;
	};
	case 1: {
		switch (_side_type) do {
			case 0: {
				// B_UAV_AI
				createVehicleCrew _vehicle;
				// set skills based on CPU research
				
				if (["comp", 0, bis_curator_west] call owr_fn_isResearchComplete) then {
					if ((["comp", 1, bis_curator_west] call owr_fn_isResearchComplete)) then {
						if ((["comp", 2, bis_curator_west] call owr_fn_isResearchComplete)) then {
							{
								//_x setSkill 0.5;
								[_x, 0.5] remoteExec ["setSkill", owner _x];
							} forEach (crew _vehicle);
						} else {
							{
								//_x setSkill 0.37;
								[_x, 0.37] remoteExec ["setSkill", owner _x];
							} forEach (crew _vehicle);
						};
					} else {
						{
							//_x setSkill 0.25;
							[_x, 0.25] remoteExec ["setSkill", owner _x];
						} forEach (crew _vehicle);
					};
				} else {
					// no cpu research at all - ai dumb
					{
						//_x setSkill 0.15;
						[_x, 0.15] remoteExec ["setSkill", owner _x];
					} forEach (crew _vehicle);
				};
			};
			case 1: {
				// O_UAV_AI
				createVehicleCrew _vehicle;
				
				// set skills based on CPU research
				if (["comp", 0, bis_curator_east] call owr_fn_isResearchComplete) then {
					if ((["comp", 1, bis_curator_east] call owr_fn_isResearchComplete)) then {
						if ((["comp", 2, bis_curator_east] call owr_fn_isResearchComplete)) then {
							{
								//_x setSkill 0.5;
								[_x, 0.5] remoteExec ["setSkill", owner _x];
							} forEach (crew _vehicle);
						} else {
							{
								//_x setSkill 0.37;
								[_x, 0.37] remoteExec ["setSkill", owner _x];
							} forEach (crew _vehicle);
						};
					} else {
						{
							//_x setSkill 0.25;
							[_x, 0.25] remoteExec ["setSkill", owner _x];
						} forEach (crew _vehicle);
					};
				} else {
					// no cpu research at all - ai dumb
					{
						//_x setSkill 0.15;
						[_x, 0.15] remoteExec ["setSkill", owner _x];
					} forEach (crew _vehicle);
				};
				
			};
		};
	};
	case 2: {
		// not implemented, yet
	};
};

while {!(isNull _vehicle)} do {
	switch (_fuel_type) do {
		case 0: {
			// combustion engine, drains fuel based on the speed
			_currFuel = fuel _vehicle;
			_drainRate = (abs (speed _vehicle))/_vehicleMaxSpeed;
			[_vehicle, (_currFuel - (_drainRate/600))] remoteExec ["setFuel", owner _vehicle];
		};
		case 1: {
			// siberite engine, does not need re-fueling
			[_vehicle, 1] remoteExec ["setFuel", owner _vehicle];
			_currFuel = 1.0;
		};
		case 2: {
			// electric engine, solar panels
			// fuel drain
			_currFuel = fuel _vehicle;
			_drainRate = (abs (speed _vehicle))/_vehicleMaxSpeed;
			[_vehicle, (_currFuel - (_drainRate/250))] remoteExec ["setFuel", owner _vehicle];

			// re-charge
			_rechargeRate = 0;
			if (sunOrMoon > 0.1) then {
				// daylight
				_rechargeRate = (sunOrMoon/100) - (_drainRate/50);
				_currFuel = fuel _vehicle;
				if ((_currFuel < 0.1) && (_electricBuffer < 0.1)) then {
					_electricBuffer = _electricBuffer + _rechargeRate;
				} else {
					if (_electricBuffer != 0) then {
						_vehicle setFuel _electricBuffer;
						_electricBuffer = 0.0;
					} else {
						[_vehicle, (_currFuel + (_rechargeRate))] remoteExec ["setFuel", owner _vehicle];
					};
				};
			};
		};
	};

	sleep 1;

	// owner changed, we need to make sure vehicle has scripted damage system handler too
	if ((_lastOwner != (owner _vehicle)) && (_firstOwner != (owner _vehicle))) then {
		[_vehicle, _side_type, _chassis_type] remoteExec ["owr_fn_scriptedDmgSysVehicleEH", owner _vehicle];
	};

	_lastOwner = owner _vehicle;
};