/*
	Author: Karel Moricky

	Description:
	Spawn units based on curator settings.
	Used when curator role is not taken.

	Parameter(s):
		0: OBJECT - curator (costs and coefficients will be read from it)
		1: ARRAY of SIDEs - sides of placed units
		2: NUMBER - cheat coefficient (1 means default costs, 0.5 means 50% values; allows spawning of more units)
		3: NUMBER - infantry probability (probabilities are compared together, the ones with higher number have better chance of spawning)
		4: NUMBER - ground vehicles probability
		5: NUMBER - aircrafts probability
		6: NUMBER - marine probability

	Returns:
	ARRAY of GROUPs
*/

_curator = _this param [0,objnull,[objnull]];
_sides = _this param [1,[],[[]]];
_cheatCoef = _this param [2,1,[0]];

if (count _sides == 0) exitwith {["No sides defined"] call bis_fcn_error;};

_ratioInfantry = _this param [3,1,[1]];
_ratioGround = _this param [4,1,[1]];
_ratioAir = _this param [5,1,[1]];
_ratioWater = _this param [6,1,[1]];

_weights = [_ratioInfantry,_ratioGround,_ratioAir,_ratioWater];

//////////////////////////////////////////////////////////////////////////////////

//--- Spawn AI enemies
_addons = curatoraddons _curator;
_areas = curatoreditingarea _curator;
_coef = _curator curatorCoef "place";

//--- Calculate area weights
_areaWeightValues = [];
_areaWeightSum = 0;
{
	_xPos = _x select 0;
	_xSize = _x select 1;

	_positions = [_xPos,_xSize] call bis_fnc_curatorAutomaticPositions;
	_xWeight = (
		(count (_positions select 0) max 0 min 1) * (_weights select 0) +
		(count (_positions select 1) max 0 min 1) * (_weights select 1) +
		(count (_positions select 2) max 0 min 1) * (_weights select 2) +
		(count (_positions select 3) max 0 min 1) * (_weights select 3)
	);
	_areaWeightValues set [_foreachindex,_xWeight];
	_areaWeightSum = _areaWeightSum + _xWeight;
} foreach _areas;

_units = [];
{
	_xUnits = getarray (configfile >> "cfgpatches" >> _x >> "units");
	{
		_unit = tolower _x;
		if !(_unit in _units) then {_units set [count _units,_unit];};
	} foreach _xUnits;
} foreach _addons;

if (count _units == 0) exitwith {};

//--- Find placeable groups
_sideIDs = [];
{
	_sideIDs set [count _sideIDs,_x call bis_fnc_sideID];
} foreach _sides;


//////////////////////////////////////////////////////////////////////////////////
//--- Calculate unit cost
_costs = [_curator,_units] call bis_fnc_curatorObjectRegistered;
_enabledUnits = [];
_enabledUnitCosts = [];

_vehiclesGround = [];
_vehiclesAir = [];
_vehiclesWater = [];
{
	_result = _costs select _foreachindex;
	_enabled = _result param [0,false,[false]];

	if (_enabled) then {
		_cost = _result param [1,0,[0]];
		_cost = _cost * _cheatCoef;
		_enabledUnits set [count _enabledUnits,tolower _x];
		_enabledUnitCosts set [count _enabledUnitCosts,_cost];

		//--- Register vehicles separately
		_simulation = tolower gettext (configfile >> "cfgvehicles" >> _x >> "simulation");
		_side = getnumber (configfile >> "cfgvehicles" >> _x >> "side");
		if (
			_simulation in ["airplanex","carx","helicopterx","helicopterrtd","airplanex","shipx","submarinex","tankx"]
			&&
			!(_x iskindof "StaticWeapon")
			&&
			_side in _sideIDs
		) then {

			scopename "bis_fnc_systemcurator_vehicle";

			_armed = false;
			{
				{
					_weaponSimulation = gettext (configfile >> "cfgweapons" >> _x >> "simulation");
					_weaponMagazines = getarray (configfile >> "cfgweapons" >> _x >> "magazines");
					if (_weaponSimulation == "weapon" && count _weaponMagazines > 0) then {
						_armed = true;
						breakto "bis_fnc_systemcurator_vehicle";
					};
				} foreach (getarray (_x >> "weapons"));
			} foreach (_x call bis_fnc_getturrets);

			if (_armed) then {
				_cost = _result param [2,_cost,[0]];
				_side = getnumber (configfile >> "cfgvehicles" >> _x >> "side") call bis_fnc_sidetype;
				_vehicleArray = [tolower _x,_cost * _cheatCoef,_side];
				switch _simulation do {
					case "airplanex";
					case "helicopterrtd";
					case "helicopterx": {
						_vehiclesAir set [count _vehiclesAir,_vehicleArray];
					};
					case "carx";
					case "tankx": {
						_vehiclesGround set [count _vehiclesGround,_vehicleArray];
					};
					case "shipx";
					case "submarinex": {
						_vehiclesWater set [count _vehiclesWater,_vehicleArray];
					};
				};
			};
		};
	};
} foreach _units;

//////////////////////////////////////////////////////////////////////////////////
//--- Calculate groups

_groupsInfantry = [];
_groupsGround = [];
_groupsAir = [];
_groupsWater = [];

//--- ToDo: Load in MP type init and save into mission logic. Calculcate only cost here.

_groupClasses = missionnamespace getvariable "BIS_fnc_curatorAutomatic_groupClasses";
if (isnil {_groupClasses}) then {
	_groupClasses = [configfile >> "cfgGroups",3,false] call bis_fnc_returnChildren;
	missionnamespace setvariable ["BIS_fnc_curatorAutomatic_groupClasses",_groupClasses];
};

{
	_side = [_x,"side",-1] call bis_fnc_returnconfigentry;
	if (_side in _sideIDs) then {

		//--- Units
		_cost = 0;
		_enabled = true;
		_simulations = [];
		{
			_vehicle = tolower gettext (_x >> "vehicle");
			_vehicleID = _enabledUnits find _vehicle;
			if (_vehicleID < 0) exitwith {_enabled = false;};

			_cost = _cost + (_enabledUnitCosts select _vehicleID);
			_simulation = tolower gettext (configfile >> "cfgvehicles" >> _vehicle >> "simulation");
			if !(_simulation in _simulations) then {_simulations set [count _simulations,_simulation];};
		} foreach (_x call bis_fnc_returnChildren);

		if (_enabled) then {
			_groups = switch true do {
				case ("airplanex" in _simulations);
				case ("helicopterrtd" in _simulations);
				case ("helicopterx" in _simulations): {_groupsAir};

				case ("carx" in _simulations);
				case ("tankx" in _simulations): {_groupsGround};

				case ("shipx" in _simulations);
				case ("submarinex" in _simulations): {_groupsWater};

				default {_groupsInfantry};
			};
			_groups set [count _groups,[_x,_cost,_side call bis_fnc_sidetype]];
		};
	};
} foreach _groupClasses;

_removeExpensive = {
	{
		_xCost = _x select 1;
		if ((_points + _xCost * _coef) < ((_areaPoints - _areaPointsLimit) max 0)) then {
			_this set [_foreachindex,objnull];
		};
	} foreach _this;
	_this = _this - [objnull];
	_this
};
_spawnGroup = {
	_spawnGroupWeights = [];
	{_spawnGroupWeights set [_foreachindex,_x select 1];} foreach (_this select 1);
	_pos = (_this select 0) call bis_fnc_selectrandom;
	_groupArray = [_this select 1,_spawnGroupWeights] call bis_fnc_selectrandomweighted;
	_type = _groupArray select 0;
	_cost = _groupArray select 1;
	_side = _groupArray select 2;
	if (typename _pos == typename objnull) then {_pos = position _pos;};
	["Group %1 created",configname _type] call bis_fnc_logFormat;
	[_pos,_side,_type] call bis_fnc_spawnGroup;
};
_spawnVehicle = {
	_spawnVehicleWeights = [];
	{_spawnVehicleWeights set [_foreachindex,_x select 1];} foreach (_this select 1);
	_pos = (_this select 0) call bis_fnc_selectrandom;
	_vehicleArray = [_this select 1,_spawnVehicleWeights] call bis_fnc_selectrandomweighted;
	_type = _vehicleArray select 0;
	_cost = _vehicleArray select 1;
	_side = _vehicleArray select 2;
	_dir = 0;
	if (typename _pos == typename objnull) then {
		//--- Road position
		_dir = direction _pos;
		_pos = position _pos;
	} else {
		if (typename (_pos select 0) == (typename [])) then {_pos = _pos select 0;}; //--- Converts from selectBestPlaces format
	};
	["Vehicle %1 created",_type] call bis_fnc_logFormat;
	_vehicle = createvehicle [_type,_pos,[],0,"none"];
	_vehicle setdir _dir;
	_group = creategroup _side;
	[_vehicle,_group] call bis_fnc_spawnCrew;
	_group
};

_pointsStart = curatorpoints _curator;
_areaPointsLimit = _pointsStart / (count _areas max 1);
_spawnedGroups = [];
_allTotal = 0;
{
	_area = _x;
	_areaPos = _area select 0;
	_areaSize = _area select 1;
	_areaWeight = (_areaWeightValues select _foreachindex) / _areaWeightSum;
	_areaPoints = curatorpoints _curator;
	_areaPointsLimit = _pointsStart * _areaWeight;
	_areaWeights = +_weights;

	_positions = [_areaPos,_areaSize] call bis_fnc_curatorAutomaticPositions;
	_positionsInfantry = _positions select 0;
	_positionsGround = _positions select 1;
	_positionsAir = _positions select 2;
	_positionsWater = _positions select 3;

	_groupsInfantryLocal = +_groupsInfantry;
	_groupsGroundLocal = +_groupsGround;
	_groupsAirLocal = +_groupsAir;
	_groupsWaterLocal = +_groupsWater;
	_vehiclesGroundLocal = +_vehiclesGround;
	_vehiclesAirLocal = +_vehiclesAir;
	_vehiclesWaterLocal = +_vehiclesWater;

	_n = 0;
	while {
		_allGroups = _groupsInfantryLocal + _groupsGroundLocal + _groupsAirLocal + _groupsWaterLocal;
		_allVehicles = _vehiclesGroundLocal + _vehiclesAirLocal + _vehiclesWaterLocal;
		count (_allGroups + _allVehicles) > 0 && _n < 10
	} do {
		_points = curatorpoints _curator;

		//--- Remove expensive items
		_groupsInfantryLocal = _groupsInfantryLocal call _removeExpensive;
		_groupsGroundLocal = _groupsGroundLocal call _removeExpensive;
		_groupsAirLocal = _groupsAirLocal call _removeExpensive;
		_groupsWaterLocal = _groupsWaterLocal call _removeExpensive;
		_vehiclesGroundLocal = _vehiclesGroundLocal call _removeExpensive;
		_vehiclesAirLocal = _vehiclesAirLocal call _removeExpensive;
		_vehiclesWaterLocal = _vehiclesWaterLocal call _removeExpensive;

		_allGroups = _groupsInfantryLocal + _groupsGroundLocal + _groupsAirLocal + _groupsWaterLocal;
		_allVehicles = _vehiclesGroundLocal + _vehiclesAirLocal + _vehiclesWaterLocal;

		_allCount = count (_allGroups + _allVehicles);

		if (_allCount > 0) then {

			_cost = 0;

			//--- Eliminate unsuitable types (e.g., no water vehicles when the area is landlocked)
			_coefs = [
				((count _positionsInfantry) * (count _groupsInfantryLocal)) min 1,
				((count _positionsGround) * ((count _groupsGroundLocal) + (count _vehiclesGroundLocal))) min 1,
				((count _positionsAir) * ((count _groupsAirLocal) + (count _vehiclesAirLocal))) min 1,
				((count _positionsWater) * ((count _groupsWaterLocal) + (count _vehiclesWaterLocal))) min 1
			];
			{
				_areaWeights set [_foreachindex,_x * (_coefs select _foreachindex)];
			} foreach _areaWeights;
			if (_areaWeights call bis_fnc_magnitudesqr == 0) exitwith {_allCount = 0;};

			_type = [[0,1,2,3],_areaWeights] call bis_fnc_selectrandomweighted;
			_group = switch (_type) do {
				//--- Infantry
				case 0: {
					[_positionsInfantry,_groupsInfantryLocal] call _spawnGroup
				};
				//--- Ground
				case 1: {
					if (random 1 > 0.5 && count _vehiclesGroundLocal > 0 || count _groupsGroundLocal == 0) then {
						[_positionsGround,_vehiclesGroundLocal] call _spawnVehicle
					} else {
						[_positionsGround,_groupsGroundLocal] call _spawnGroup
					};
				};
				//--- Air
				case 2: {
					if (random 1 > 0.5 && count _vehiclesAirLocal > 0 || count _groupsAirLocal == 0) then {
						[_positionsAir,_vehiclesAirLocal] call _spawnVehicle
					} else {
						[_positionsAir,_groupsAirLocal] call _spawnGroup
					};
				};
				//--- Water
				case 3: {
					if (random 1 > 0.5 && count _vehiclesWater > 0 || count _groupsWaterLocal == 0) then {
						[_positionsWater,_vehiclesWaterLocal] call _spawnVehicle
					} else {
						[_positionsWater,_groupsWaterLocal] call _spawnGroup
					};
				};
				//--- Nothing
				default {
					"NULL" call bis_fnc_log;
					grpnull
				};
			};
			_spawnedGroups set [count _spawnedGroups,_group];

			//--- Mark as automatic
			_group setvariable ["BIS_fnc_curatorAutomatic",true];
			_group setvariable ["BIS_fnc_curatorAutomatic_area",_area];

			//--- Execute scripted event handler on every group member
			[_curator,"curatorGroupPlaced",[_curator,_group]] call bis_fnc_callScriptedEventHandler;
			{
				[_curator,"curatorObjectPlaced",[_curator,_x]] call bis_fnc_callScriptedEventHandler;
			} foreach units _group;

			_objects = [];
			{
				_objects pushback _x;
				_objects pushback vehicle _x;
			} foreach units _group;
			_curator addcuratoreditableobjects [_objects,true];
			_curator addcuratorpoints (_cost * _coef);
		};
		_allTotal = _allTotal + _allCount;
		_n = _n + 1;
		sleep 0.1;
	};
} foreach _areas;

if (_allTotal == 0) then {
	_curator addcuratorpoints -1;
};

_spawnedGroups