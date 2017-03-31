class CfgPatches {
	class owr_data {
		author = "Sumrak";
		name = "OWR - Main Configuration";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {};
		requiredVersion = 0.1;
		units[] = {};
		weapons[] = {};
	};
};

/*class CfgMods {
	class Mod_Base;
	class OWR: Mod_Base {
		picture = "\owr\ui\data\owr_icon_ca.paa";
		logo = "\owr\ui\data\owr_logo_ca.paa";
		logoOver = "\owr\ui\data\owr_logo_over_ca.paa";
		logoSmall = "\owr\ui\data\owr_logo_small_ca.paa";
		name = "Original War";
		tooltip = "Legendary RTS is back and in a way never seen before!";
		overview = "Experience cold war that turned hot around 2 million years ago in the lands of Siberia. Collect resources, build a base and vehicles to fight enemy in an unique RTS/FPS/RPG mix. Up to 3 RTS and 18 FPS players.";
		dir = "@owr";
		action = "http://owr.nightstalkers.cz";
	};
};*/

/*class CfgAddons {
	class PreloadAddons {
		class OWR {
			list[] = {"owr_data","owr_ui","owr_sounds","owr_scripts","owr_nature_deposits","owr_resources_crates","owr_am_aturrets","owr_am_barracks","owr_am_control_tower","owr_am_factory","owr_am_lab","owr_am_mturrets","owr_am_power_oil","owr_am_power_sib","owr_am_power_sol","owr_am_source_oil","owr_am_source_sib","owr_am_warehouse","owr_ru_aturrets","owr_ru_barracks","owr_ru_control_tower","owr_ru_factory","owr_ru_lab","owr_ru_mturrets","owr_ru_power_oil","owr_ru_power_sib","owr_ru_source_oil","owr_ru_source_sib","owr_ru_warehouse","owr_plants_trees","owr_map_pliocen_data","owr_map_pliocen","owr_weapons_infantry","owr_chracters_gear_backpacks","owr_am_characters","owr_ar_characters","owr_ru_characters","owr_weapons_vehicles","owr_ru_vehicles_tracked_heavy","owr_ru_vehicles_wheeled_heavy","owr_ru_vehicles_tracked_medium","owr_ru_vehicles_wheeled_medium","owr_am_vehicles_tracked_heavy","owr_am_vehicles_tracked_medium","owr_am_vehicles_wheeled_light","owr_am_vehicles_wheeled_medium"};
		};
	};
};*/

class CfgFactionClasses {
	class owr_am {
		displayName = "AM";
		priority = 1;
		side = 1;
		icon = "\a3\Data_f\cfgFactionClasses_BLU_ca.paa";
		flag = "\a3\Data_f\Flags\flag_nato_co.paa";
	};
	class owr_ar {
		displayName = "AR";
		priority = 1;
		side = 2;
		icon = "\a3\Data_f\cfgFactionClasses_IND_G_ca.paa";
		flag = "\a3\Data_f\Flags\flag_FIA_co.paa";
	};
	class owr_ru {
		displayName = "RU";
		priority = 1;
		side = 0;
		icon = "\a3\Data_f\cfgFactionClasses_OPF_ca.paa";
		flag = "\a3\Data_f\Flags\flag_CSAT_co.paa";
	};
};

class CfgEditorSubcategories {
	class owr_basebuild {
		displayName = "Buildings";
	};
	class owr_characters {
		displayName = "Personnel";
	};
	class owr_vehicles {
		displayName = "Vehicles";
	};
};

class owr_buildingcollapse_peffect {
	class Shards {
		simulation = "particles";
		type = "ObjectDestructionShardsSmall";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class Shards1 {
		simulation = "particles";
		type = "ObjectDestructionShardsSmall1";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class Shards2 {
		simulation = "particles";
		type = "ObjectDestructionShardsSmall2";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class Shards3 {
		simulation = "particles";
		type = "ObjectDestructionShardsSmall3";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class ShardsBurn {
		simulation = "particles";
		type = "ObjectDestructionShardsBurningSmall";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class ShardsBurn1 {
		simulation = "particles";
		type = "ObjectDestructionShardsBurningSmall1";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class ShardsBurn2 {
		simulation = "particles";
		type = "ObjectDestructionShardsBurningSmall2";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class ShardsBurn3 {
		simulation = "particles";
		type = "ObjectDestructionShardsBurningSmall3";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class Shards2_0 {
		simulation = "particles";
		type = "ObjectDestructionShards";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class Shards2_1 {
		simulation = "particles";
		type = "ObjectDestructionShards1";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class Shards2_2 {
		simulation = "particles";
		type = "ObjectDestructionShards2";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class Shards2_3 {
		simulation = "particles";
		type = "ObjectDestructionShards3";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class Smoke1 {
		simulation = "particles";
		type = "VehExpSmokeSmall";
		position[] = {0,0,0};
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class SmallSmoke1 {
		simulation = "particles";
		type = "VehExpSmoke2Small";
		position[] = {0,0,0};
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
};
class owr_buildingexplosion_peffect {
	class ExpSparks
	{
		simulation = "particles";
		type = "ExpSparks";
		position[] = {0,0,0};
		intensity = 1;
		interval = 1;
		lifeTime = 0.5;
	};
	class Shards
	{
		simulation = "particles";
		type = "ObjectDestructionShardsSmall";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class Shards1
	{
		simulation = "particles";
		type = "ObjectDestructionShardsSmall1";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class ShardsBurn
	{
		simulation = "particles";
		type = "ObjectDestructionShardsBurningSmall";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class ShardsBurn1
	{
		simulation = "particles";
		type = "ObjectDestructionShardsBurningSmall1";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class Shards2_0
	{
		simulation = "particles";
		type = "ObjectDestructionShards";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class Shards2_1
	{
		simulation = "particles";
		type = "ObjectDestructionShards1";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class LightExp
	{
		simulation = "light";
		type = "ExploLight";
		position[] = {0,1.5,0};
		intensity = 0.001;
		interval = 1;
		lifeTime = 0.5;
	};
	class Explosion2
	{
		simulation = "particles";
		type = "FireBallBrightSmall";
		position[] = {0,0,0};
		intensity = 1;
		interval = 1;
		lifeTime = 0.3;
	};
	class Smoke1
	{
		simulation = "particles";
		type = "VehExpSmokeSmall";
		position[] = {0,0,0};
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
};
class owr_vehicledestruction_peffect {
	class Shards {
		simulation = "particles";
		type = "ObjectDestructionShardsSmall";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class Shards1 {
		simulation = "particles";
		type = "ObjectDestructionShardsSmall1";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class ShardsBurn {
		simulation = "particles";
		type = "ObjectDestructionShardsBurningSmall";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class ShardsBurn1 {
		simulation = "particles";
		type = "ObjectDestructionShardsBurningSmall1";
		position = "";
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class Smoke1 {
		simulation = "particles";
		type = "VehExpSmokeSmall";
		position[] = {0,0,0};
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
	class SmallSmoke1 {
		simulation = "particles";
		type = "VehExpSmoke2Small";
		position[] = {0,0,0};
		intensity = 1;
		interval = 1;
		lifeTime = 1;
	};
};

class CfgAmmo {
	class Default;
	class owr_buildingcollapse: Default {
		hit = 1;
		indirectHit = 0;
		indirectHitRange = 0;
		model = "";
		simulation = "";
		cost = 1;
		soundHit[] = {"owr\sounds\damage\damaged_building",2.818383,1,1600};
		explosionSoundEffect = "DefaultExplosion";
		soundFly[] = {"",1,1};
		soundEngine[] = {"",1,4};
		explosionEffects = "owr_buildingcollapse_peffect";
	};
	class owr_buildingexplosion: Default {
		hit = 1;
		indirectHit = 0;
		indirectHitRange = 0;
		model = "";
		simulation = "";
		cost = 1;
		soundHit[] = {"owr\sounds\damage\damaged_explosion",2.818383,1,1600};
		explosionSoundEffect = "DefaultExplosion";
		soundFly[] = {"",1,1};
		soundEngine[] = {"",1,4};
		explosionEffects = "owr_buildingexplosion_peffect";
	};
	class owr_vehicledestruction: Default {
		hit = 1;
		indirectHit = 0;
		indirectHitRange = 0;
		model = "";
		simulation = "";
		cost = 1;
		soundHit[] = {"owr\sounds\damage\damaged_vehicle",2.818383,1,1600};
		explosionSoundEffect = "DefaultExplosion";
		soundFly[] = {"",1,1};
		soundEngine[] = {"",1,4};
		explosionEffects = "owr_vehicledestruction_peffect";
	};
};

class CfgVehicles {

	class B_Soldier_base_F;
	class owr_manbase: B_Soldier_base_F {
		editorSubcategory = "owr_characters";

		author = "Sumrak";
		_generalMacro = "Rifleman";
		scope = 0;

		nakedUniform = "U_BasicBody";
		uniformClass = "U_B_CombatUniform_mcam";
		model = "\A3\characters_F\BLUFOR\b_soldier_01.p3d";
		
		hiddenSelections[] = {"Camo","insignia"};
		
		//hiddenSelectionsTextures[] = {"\dar\characters\nato\us\data\nato_us_soldier_wood_clothing_co.paa","\dar\characters\data\insignias\tf_bering_ca.paa"};
		
		backpack = "";
		weapons[] = {"Throw","Put"};
		respawnWeapons[] = {"Throw","Put"};
		magazines[] = {"Chemlight_Blue"};
		respawnMagazines[] = {"Chemlight_Blue"};
		
		cost = 60000;
		threat[] = {1,0.3,0.1};

		items[] = {};
		respawnitems[] = {};
		linkedItems[] = {"ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"ItemMap","ItemCompass","ItemWatch","ItemRadio"};

		armor					= 100.0;			// total hit points (meaning global "health") of the object.  keep constant among various soldiers so that the hit points armor coefficients remains on the same scale
		armorStructural			=  1; 			// divides all damage taken to total hit point, either directly or through hit point passThrough coefficient. must be adjusted for each model to achieve consistent total damage results
		//explosionShielding		=  1; 		// for consistent explosive damage after adjusting = ( armorStructural / 10 )
		//minTotalDamageThreshold	=   50.0; 	// minimalHit for total damage
		impactDamageMultiplier	=   0.1; 		// multiplier for falling damage

		class HitPoints	{};
	};


	class Car;
	class Car_F: Car {
		class HitPoints;
	};

	class owr_car: Car_F {
		ejectDeadGunner = true;
		ejectDeadCargo = true;
		ejectDeadDriver = true;
		audible = 6;
		camouflage = 8;
		accuracy = 0.5;
		author = "Sumrak";
		explosionEffect = "owr_vehicledestruction";
		crewCrashProtection = 0.01;
		crewExplosionProtection = 0.01;
		class DestructionEffects {
			class Smoke1 {
				simulation = "particles";
				type = "ObjectDestructionSmoke";
				position = "destructionEffect1";
				intensity = 0.15;
				interval = 1;
				lifeTime = 3.5;
			};
		};
	};

	// base classes
	// 6c = six-cargo building
	//  typical usage - warehouse, depot, laboratory, armory, factory
	class owr_base6c: Car_F {
		scope = 0;
		picture = "\owr\ui\data\map_default_ca.paa";
		Icon = "\owr\ui\data\icon_default_ca.paa";
		mapSize = 16;
		author = "Sumrak";
		editorSubcategory = "owr_basebuild";
		fireResistance = 5; 
		armor = 32;
		cost = 50000;
		transportMaxBackpacks = 0; 
		transportSoldier = 6; 
		hasDriver = 0;
		hasCommander = 0;
		hasTerminal = 0;
		audible = 6;
		camouflage = 8;
		accuracy = 0.5;
		class TransportItems {
			class _xx_FirstAidKit {
				name = "FirstAidKit";
				count = 6;
			};
		};
		class Turrets {};
		driverAction = "ManActCargo";
		driverInAction = "ManActCargo";
		cargoAction[] = {"passenger_apc_generic01","passenger_apc_generic01","passenger_apc_generic01","passenger_apc_generic01","passenger_apc_generic01","passenger_apc_generic01"};
		getInAction = "GetInLow";
		getOutAction = "GetOutLow";
		cargoGetInAction[] = {"GetInLow"}; 
		cargoGetOutAction[] = {"GetOutLow"};

		explosionEffect = "owr_buildingcollapse";
		class Reflectors {};
		aggregateReflectors[] = {};
		class DestructionEffects {
			class Smoke1 {
				simulation = "particles";
				type = "ObjectDestructionSmoke";
				position = "destructionEffect1";
				intensity = 0.15;
				interval = 1;
				lifeTime = 3.5;
			};
		};
	};
	class owr_base6c_am: owr_base6c {
		side = 1;
		faction	= owr_am;
	};
	class owr_base6c_ru: owr_base6c {
		side = 0;
		faction	= owr_ru;
	};


	// base classes
	//  0c = zero cargo (incl. driver etc.)
	//  typical usage - power stations, mines,..
	class owr_base0c: Car_F {
		scope = 0;
		picture = "\owr\ui\data\map_default_ca.paa";
		Icon = "\owr\ui\data\icon_default_ca.paa";
		mapSize = 16;
		author = "Sumrak";
		editorSubcategory = "owr_basebuild";
		fireResistance = 5; 
		armor = 32; 
		cost = 50000; 
		transportMaxBackpacks = 0;
		transportSoldier = 0; 
		hasDriver = 0;
		hasGunner = 0;
		hasCommander = 0;
		hasTerminal = 0;
		class TransportItems {
			class _xx_FirstAidKit {
				name = "FirstAidKit";
				count = 1;
			};
		};
		class Turrets {};
		driverAction = "Disabled";
		cargoAction[] = {"Disabled"};
		getInAction = "";
		getOutAction = "";
		cargoGetInAction[] = {""}; 
		cargoGetOutAction[] = {""};
		audible = 6;
		camouflage = 8;
		accuracy = 0.5;
		explosionEffect = "owr_buildingcollapse";
		class Reflectors {};
		aggregateReflectors[] = {};
		class DestructionEffects {
			class Smoke1 {
				simulation = "particles";
				type = "VehExpSmokeSmall";
				position = "destructionEffect1";
				intensity = 1;
				interval = 1;
				lifeTime = 1;
			};
		};		
	};
	class owr_base0c_am: owr_base0c {
		side = 1;
		faction	= owr_am;
	};
	class owr_base0c_ru: owr_base0c {
		side = 0;
		faction	= owr_ru;
	};



	// TODO - 1c version for turrets!
	// TODO - 1f version for armories (cargo equals ffv positions)
};