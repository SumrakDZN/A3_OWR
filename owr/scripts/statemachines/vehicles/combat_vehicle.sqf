// only executed on server! - just purely from safety - it should not be executed elsewhere
if (!(isServer)) exitWith {};

_vehicle = (_this select 0);			// vehicle itself
_fuel_type = (_this select 1);			// 0 = cb, 1 = sb, 2 = el,  
_control_type = (_this select 2); 		// 0 = mn, 1 = ai, 2 = rt
_side_type = (_this select 3);			// 0 = AM, 1 = RU
_chassis_type = (_this select 4);

//diag_log format ["%1 %2 %3 %4", _vehicle, _fuel_type, _control_type, _side_type];

_vehicleMaxSpeed = getNumber (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "maxSpeed");
_vehicle selectWeaponTurret [((_vehicle weaponsTurret [0]) select 0), [0]];
_vehicleMagazineType = _vehicle currentMagazineTurret [0];
_magazineAdded = true;

[_vehicle, 1.0] remoteExec ["setFuel", owner _vehicle];		// always fully fueled after manufacturing
_electricBuffer = 0.0;
_currFuel = 0.0;
_manualControl = false;
_gunnerAdded = false;
_gunner = objNull;
_lastOwner = -1;
_firstOwner = owner _vehicle; // first owner always gets scripted dmg EH - server - we do not want to give him this EH again ever

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
				//createVehicleCrew _vehicle;
				_ai_grp = createGroup west;				
				_ai_driver = _ai_grp createUnit ["B_UAV_AI", getPos guy_from_west, [], 0, "FORM"];
				_ai_gunner = _ai_grp createUnit ["B_UAV_AI", getPos guy_from_west, [], 0, "FORM"];

				_ai_driver moveInDriver _vehicle;
				_ai_gunner moveInGunner _vehicle;

				// set skills based on CPU research
				if (["comp", 0, bis_curator_west] call owr_fn_isResearchComplete) then {
					if ((["comp", 1, bis_curator_west] call owr_fn_isResearchComplete)) then {
						if ((["comp", 2, bis_curator_west] call owr_fn_isResearchComplete)) then {
							{
								//_x setSkill 0.5;
								[_x, 1.0] remoteExec ["setSkill", owner _x];
							} forEach (crew _vehicle);
						} else {
							{
								//_x setSkill 0.37;
								[_x, 0.85] remoteExec ["setSkill", owner _x];
							} forEach (crew _vehicle);
						};
					} else {
						{
							//_x setSkill 0.25;
							[_x, 0.75] remoteExec ["setSkill", owner _x];
						} forEach (crew _vehicle);
					};
				} else {
					// no cpu research at all - ai dumb
					{
						//_x setSkill 0.15;
						[_x, 0.60] remoteExec ["setSkill", owner _x];
					} forEach (crew _vehicle);
				};
			};
			case 1: {
				// O_UAV_AI
				//createVehicleCrew _vehicle;
				_ai_grp = createGroup east;	
				_ai_driver = _ai_grp createUnit ["O_UAV_AI", getPos guy_from_east, [], 0, "FORM"];
				_ai_gunner = _ai_grp createUnit ["O_UAV_AI", getPos guy_from_east, [], 0, "FORM"];

				_ai_driver moveInDriver _vehicle;
				_ai_gunner moveInGunner _vehicle;

				// set skills based on CPU research
				if (["comp", 0, bis_curator_east] call owr_fn_isResearchComplete) then {
					if ((["comp", 1, bis_curator_east] call owr_fn_isResearchComplete)) then {
						if ((["comp", 2, bis_curator_east] call owr_fn_isResearchComplete)) then {
							{
								//_x setSkill 0.5;
								[_x, 1.00] remoteExec ["setSkill", owner _x];
							} forEach (crew _vehicle);
						} else {
							{
								//_x setSkill 0.37;
								[_x, 0.85] remoteExec ["setSkill", owner _x];
							} forEach (crew _vehicle);
						};
					} else {
						{
							//_x setSkill 0.25;
							[_x, 0.75] remoteExec ["setSkill", owner _x];
						} forEach (crew _vehicle);
					};
				} else {
					// no cpu research at all - ai dumb
					{
						//_x setSkill 0.15;
						[_x, 0.60] remoteExec ["setSkill", owner _x];
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
	
	//hintSilent format ["VEHICLE DEBUG\ngunnerAdded %1\ngunner %2\ncrew %3\nturretMags %4\ncurrFuel %5", _gunnerAdded, _gunner, crew _vehicle, _vehicle magazinesTurret [0], _currFuel];

	if (_manualControl) then {
		if (((count (crew _vehicle)) > 0) && (!_gunnerAdded)) then {
			// driver is IN, lets add AI gunner!
			_driver = ((crew _vehicle) select 0);
			_aiClass = "B_UAV_AI";
			if (_side_type == 1) then {
				_aiClass = "O_UAV_AI";
			};
			_gunner = (group _driver) createUnit [_aiClass, getPos _vehicle, [], 0, "FORM"];
			//[_gunner] join grpNull;
			_gunnerAdded = true;
			// set skill of gunner according to the skill of driver!
			// mechanic - receives full bonus up to 1.0 (1.0 == level 10)
			// other professions - receive up to 0.5 based on their mechanic level
			if ((_driver getVariable "ow_class") == 2) then {
				//_gunner setSkill (((crew _vehicle select 0) getVariable "ow_skill_mechanic") / 10);
				[_gunner, ((_driver getVariable "ow_skill_mechanic") / 10)] remoteExec ["setSkill", owner _gunner];
			} else {
				//_gunner setSkill ((((crew _vehicle select 0) getVariable "ow_skill_mechanic") / 10) / 2);
				[_gunner, (((_driver getVariable "ow_skill_mechanic") / 10) / 2)] remoteExec ["setSkill", owner _gunner];
			};
			//_gunner setRank "PRIVATE";
			// zeus control
			switch (_side_type) do {
				case 0: {
					bis_curator_west addCuratorEditableObjects [[_gunner], true];
				};
				case 1: {
					bis_curator_east addCuratorEditableObjects [[_gunner], true];
				};
			};
			
			// allright, lets move him into the vehicle!
			_gunner moveInGunner _vehicle;



			//hint format ["TEMP AI INFO\nNAME: %1 SKILL %2\n PLPRF: %3 PLMECH: %4",_gunner, skill _gunner, ((crew _vehicle select 0) getVariable "ow_class"), ((crew _vehicle select 0) getVariable "ow_skill_mechanic")];
		} else {
			if ((count (crew _vehicle)) == 1) then {
				// driver left
				if (!(isNull _gunner)) then {
					// remove temp vehicle ai
					deleteVehicle _gunner;
					_gunnerAdded = false;
				};
			};
		};
	};

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


	if (_currFuel == 0) then {
		if (_magazineAdded) then {
			//_vehicle removeMagazinesTurret [_vehicleMagazineType, [0]];
			[_vehicle, [_vehicleMagazineType, [0]]] remoteExec ["removeMagazinesTurret", owner _vehicle];
			_magazineAdded = false;
		};
		
	} else {
		if (!_magazineAdded) then {
			_ammoCnt = (getNumber (configFile >> "CfgMagazines" >> _vehicleMagazineType >> "count"));
			//_vehicle addMagazineTurret [_vehicleMagazineType, [0], _ammoCnt];
			[_vehicle, [_vehicleMagazineType, [0], _ammoCnt]] remoteExec ["addMagazineTurret", owner _vehicle];
			_magazineAdded = true;
		};
	};

	sleep 1.0;

	// owner changed, we need to make sure vehicle has scripted damage system handler too
	if ((_lastOwner != (owner _vehicle)) && (_firstOwner != (owner _vehicle))) then {
		[_vehicle, _side_type, _chassis_type] remoteExec ["owr_fn_scriptedDmgSysVehicleEH", owner _vehicle];
	};

	_lastOwner = owner _vehicle;
};