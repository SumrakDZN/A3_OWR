class CfgPatches {
	class owr_am_vehicles_wheeled_light {
		author = "Sumrak";
		name = "OWR - AM Wheeled Light";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {
			"owr_weapons_vehicles",
			"owr_data"
		};
		requiredVersion = 0.1;
		units[] = {

		};
		weapons[] = {};
	};
};

class RCWSOptics;
class WeaponCloudsMGun;

class CfgVehicles {
	class LandVehicle;
	class Car: LandVehicle {
		class NewTurret;
	};
	class Car_F: Car {
		class EventHandlers;
		class AnimationSources {
			class recoil_source;
			class muzzle_rot;
			class muzzle_hide;
		};
		class HitPoints { /// we want to use hitpoints predefined for all cars
			class HitLFWheel;
			class HitLF2Wheel;
			class HitRFWheel;
			class HitRF2Wheel;
			class HitBody;
		};
		class Turrets {
			class MainTurret: NewTurret {
				class ViewOptics;
			};
		};
	};

	class owr_car: Car_F {};

	class owr_car_am: owr_car {};

	// BASE CLASS
	class owr_am_light_wheeled: owr_car_am {
		scope	= 0;
		scopeCurator = 0;

		side	= 1;
		faction	= owr_am;
		editorSubcategory = "owr_vehicles";

		mComplx = 3.75;

		unitInfoType = "RscUnitInfoTank";
		radarType = 8;

		hiddenSelections[] = {"camo1"};
		hiddenSelectionsTextures[]={"\A3\Weapons_F\Data\placeholder_co.paa"};

		fireResistance 	= 15; 	/// lesser protection against fire than tanks
		armor 			= 100; 	/// just some protection against missiles, collisions and explosions
		armorStructural = 1;
		cost			= 50000; /// how likely is the enemy going to target this vehicle

		transportMaxBackpacks 	= 0; /// just some backpacks fit the trunk by default
		transportSoldier 		= 0; /// number of cargo except driver

		driverCanSee = "4+8+2+32+16";
		gunnerCanSee = "4+2+8+32+16";

		/// some values from parent class to show how to set them up
		wheelDamageRadiusCoef 	= 0.9; 			/// for precision tweaking of damaged wheel size
		wheelDestroyRadiusCoef 	= 0.4;			/// for tweaking of rims size to fit ground
		maxFordingDepth 		= 0.5;			/// how high water would damage the engine of the car
		waterResistance 		= 1;			/// if the depth of water is bigger than maxFordingDepth it starts to damage the engine after this time
		crewCrashProtection		= 0.05;			/// multiplier of damage to crew of the vehicle => low number means better protection
		driverLeftHandAnimName 	= "drivewheel"; /// according to what bone in model of car does hand move
		driverRightHandAnimName = "drivewheel";	/// beware, non-existent bones may cause game crashes (even if the bones are hidden during play)
		hideProxyInCombat = 0;
		forceHideDriver = 0;
		driverAction = "driver_offroad01";
		getInAction = "GetInMRAP_01";
		getOutAction = "GetOutMRAP_01";
		vehicleHasTurnout = 0;
		allowTabLock = 0;
		
		slingLoadCargoMemoryPoints[] = {"SlingLoadCargo1","SlingLoadCargo2","SlingLoadCargo3","SlingLoadCargo4"};
		
		/// memory points where do tracks of the wheel appear
		// front left track, left offset
		memoryPointTrackFLL = "TrackFLL";
		// front left track, right offset
		memoryPointTrackFLR = "TrackFLR";
		// back left track, left offset
		memoryPointTrackBLL = "TrackBLL";
		// back left track, right offset
		memoryPointTrackBLR = "TrackBLR";
		// front right track, left offset
		memoryPointTrackFRL = "TrackFRL";
		// front right track, right offset
		memoryPointTrackFRR = "TrackFRR";
		// back right track, left offset
		memoryPointTrackBRL = "TrackBRL";
		// back right track, right offset
		memoryPointTrackBRR = "TrackBRR";

		class TransportItems {
			class _xx_FirstAidKit {
				name = "FirstAidKit";
				count = 4;
			};
		};

		class AnimationSources : AnimationSources {
			class recoil_source: recoil_source {
				source = "reload";
			};
			class muzzle_rot: muzzle_rot {
				source = "ammorandom";
			};
			class muzzle_hide: muzzle_hide {
				source = "reload";
			};
		};

		class HitPoints {};
		class Damage /// damage changes material in specific places (visual in hitPoint)
		{
			tex[]={};
			mat[]=
			{
				"A3\data_f\glass_veh_int.rvmat", 		/// material mapped in model
				"A3\data_f\Glass_veh_damage.rvmat", 	/// changes to this one once damage of the part reaches 0.5
				"A3\data_f\Glass_veh_damage.rvmat",		/// changes to this one once damage of the part reaches 1

				"A3\data_f\glass_veh.rvmat",			/// another material
				"A3\data_f\Glass_veh_damage.rvmat",		/// changes into different ones
				"A3\data_f\Glass_veh_damage.rvmat"
			};
		};

		class Turrets: Turrets {
			class MainTurret: NewTurret {
				hasGunner = 0;
				body = "MainTurret";
				gun = "MainGun";
				animationSourceGun = "mainGun";
				animationSourceHatch = "";
				gunBeg = "mainGunMuzzle";
				gunEnd = "mainGunChamber";
				weapons[] = {"owr_am_w_mgun"};
				magazines[] = {"owr_am_m_mgun"};
				soundServo[] = {"A3\Sounds_F\vehicles\soft\UGV_01\Servo_UGV_gunner",0.31622776,1,30};
				soundServoVertical[] = {"A3\Sounds_F\vehicles\soft\UGV_01\Servo_UGV_gunner_vertical",0.31622776,1,30};
				gunnerAction = "gunner_mrap_01";
				gunnerGetInAction = "GetInMRAP_01";
				gunnerGetOutAction = "GetOutMRAP_01";
				gunnerOpticsEffect[] = {"TankGunnerOptics2","OpticsBlur1","OpticsCHAbera1"};
				hideWeaponsGunner = 1;
				forceHideGunner = 1;
				castGunnerShadow = 0;
				stabilizedInAxes = 3;
				outGunnerMayFire = 1;
				memoryPointGun = "mainGunMuzzle";
				memoryPointGunnerOptics = "mainGunOptics";
				gunnerForceOptics = 1;
				allowTabLock = 0;
				gunnerOpticsModel = "A3\drones_f\Weapons_F_Gamma\Reticle\UAV_Optics_Gunner_F.p3d";
				discreteDistance[] = {100,200,300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500};
				discreteDistanceInitIndex = 2;
				turretInfoType = "RscOptics_UGV_gunner"; //   
				usePip = 0;
				minElev = -16;
				maxElev = +24;
				selectionFireAnim = "mainGunMuzzle";
				class ViewOptics: RCWSOptics {};
				class ViewGunner: ViewOptics {
					initAngleX = -45;
					minAngleX = -55;
					maxAngleX = -20;
					minFov = 0.25;
					maxFov = 1.25;
					initFov = 0.75;
					visionMode[] = {};
				};
				class HitPoints {};
			};
		};

		weapons[] = {"CarHorn"};	//TruckHorn2
		#include "sounds.hpp"	/// sounds are in a separate file to make this one simple

		terrainCoef 	= 4.5; 	/// different surface affects this car more, stick to tarmac
		turnCoef 		= 2.0; 	/// should match the wheel turn radius
		precision 		= 10; 	/// how much freedom has the AI for its internal waypoints - lower number means more precise but slower approach to way
		brakeDistance 	= 3.0; 	/// how many internal waypoints should the AI plan braking in advance
		acceleration 	= 5; 	/// how fast acceleration does the AI think the car has

		#include "physx.hpp"	/// PhysX settings are in a separate file to make this one simple
		class PlayerSteeringCoefficients {
			 turnIncreaseConst 	= 0.3; // basic sensitivity value, higher value = faster steering
			 turnIncreaseLinear = 1.0; // higher value means less sensitive steering in higher speed, more sensitive in lower speeds
			 turnIncreaseTime 	= 1.0; // higher value means smoother steering around the center and more sensitive when the actual steering angle gets closer to the max. steering angle

			 turnDecreaseConst 	= 5.0; // basic caster effect value, higher value = the faster the wheels align in the direction of travel
			 turnDecreaseLinear = 3.0; // higher value means faster wheel re-centering in higher speed, slower in lower speeds
			 turnDecreaseTime 	= 0.0; // higher value means stronger caster effect at the max. steering angle and weaker once the wheels are closer to centered position

			 maxTurnHundred 	= 0.7; // coefficient of the maximum turning angle @ 100km/h; limit goes linearly to the default max. turn. angle @ 0km/h
		};
		class Exhausts /// specific exhaust effects for the car
		{
			class Exhaust1 /// the car has two exhausts - each on one side
			{
				position 	= "exhaust1_pos";  		/// name of initial memory point
				direction 	= "exhaust1_dir";	/// name of memory point for exhaust direction
				effect 		= "ExhaustsEffect";	/// what particle effect is it going to use
			};
		};

		class Reflectors	/// only front lights are considered to be reflectors to save CPU
		{
			class LightCarHeadL01 	/// lights on each side consist of two bulbs with different flares
			{
				color[] 		= {1900, 1800, 1700};		/// approximate colour of standard lights
				ambient[]		= {5, 5, 5};				/// nearly a white one
				position 		= "LightCarHeadL01";		/// memory point for start of the light and flare
				direction 		= "LightCarHeadL01_end";	/// memory point for the light direction
				hitpoint 		= "Light_L";				/// point(s) in hitpoint lod for the light (hitPoints are created by engine)
				selection 		= "Light_L";				/// selection for artificial glow around the bulb, not much used any more
				size 			= 1;						/// size of the light point seen from distance
				innerAngle 		= 100;						/// angle of full light
				outerAngle 		= 179;						/// angle of some light
				coneFadeCoef 	= 10;						/// attenuation of light between the above angles
				intensity 		= 1;						/// strength of the light
				useFlare 		= true;						/// does the light use flare?
				dayLight 		= false;					/// switching light off during day saves CPU a lot
				flareSize 		= 1.0;						/// how big is the flare

				class Attenuation
				{
					start 			= 1.0;
					constant 		= 0;
					linear 			= 0;
					quadratic 		= 0.25;
					hardLimitStart 	= 30;		/// it is good to have some limit otherwise the light would shine to infinite distance
					hardLimitEnd 	= 60;		/// this allows adding more lights into scene
				};
			};

			class LightCarHeadL02: LightCarHeadL01
			{
				position 	= "LightCarHeadL02";
				direction 	= "LightCarHeadL02_end";
				FlareSize 	= 0.5;						/// side bulbs aren't that strong
			};

			class LightCarHeadR01: LightCarHeadL01
			{
				position 	= "LightCarHeadR01";
				direction 	= "LightCarHeadR01_end";
				hitpoint 	= "Light_R";
				selection 	= "Light_R";
			};

			class LightCarHeadR02: LightCarHeadR01
			{
				position 	= "LightCarHeadR02";
				direction 	= "LightCarHeadR02_end";
				FlareSize 	= 0.5;
			};
		};

		aggregateReflectors[] = {{"LightCarHeadL01", "LightCarHeadL02"}, {"LightCarHeadR01", "LightCarHeadR02"}}; /// aggregating reflectors helps the engine a lot
	};


	// PHYSICS TWEAK CLASSES
	class owr_am_light_wheeled_combustion: owr_am_light_wheeled {
		scope = 0;

		// change properties for the combustion engine
		// will be used in the future for further tweaks of physx
		fuelCapacity = 10000;

		class EventHandlers {
			init = "(_this select 0) animateSource ['hide_solar', 1, true]; (_this select 0) animateSource ['hide_ai', 1, true];";
		};
	};

	class owr_am_light_wheeled_electric: owr_am_light_wheeled {
		scope = 0;
		// change properties for the electric engine
		// will be used in the future for further tweaks of physx
		fuelCapacity = 10000;
		maxSpeed = 65;
		class Exhausts {
			delete Exhaust1;
		};
		class EventHandlers {
			init = "(_this select 0) animateSource ['hide_comb', 1, true]; (_this select 0) animateSource ['hide_ai', 1, true];";
		};

		soundEngineOnInt[] = {"\owr\sounds\vehicles\am_med_startstop", db-8, 1.0};
		soundEngineOnExt[] = {"\owr\sounds\vehicles\am_med_startstop", db-2, 1.0, 200};
		soundEngineOffInt[] = {"\owr\sounds\vehicles\am_med_startstop", db-8, 1.0};
		soundEngineOffExt[] = {"\owr\sounds\vehicles\am_med_startstop", db-2, 1.0, 200};

		class Sounds: Sounds {
			class Idle_ext: Idle_ext {
				sound[]	=	{"\owr\sounds\vehicles\am_med_sib_idle", db-13,	1, 150};
			};
			class Engine: Engine {
				sound[]	=	{"\owr\sounds\vehicles\am_med_sol_1400",	db-11,1, 200};
			};
			class Engine1_ext: Engine1_ext {
				sound[]	=	{"\owr\sounds\vehicles\am_med_sol_1400",	db-9,1, 240};
			};
			class Engine2_ext: Engine2_ext {
				sound[]	=	{"\owr\sounds\vehicles\am_med_sol_1400",	db-8,1, 280};
			};
			class Engine3_ext: Engine3_ext {
				sound[]	=	{"\owr\sounds\vehicles\am_med_sol_1400",	db-7,1, 320};
			};
			class Engine4_ext: Engine4_ext {
				sound[]	=	{"\owr\sounds\vehicles\am_med_sol_2000",	db-6,1, 360};
			};
			class Engine5_ext: Engine5_ext {
				sound[]	=	{"\owr\sounds\vehicles\am_med_sol_2000",	db-5,1, 420};
			};

			class IdleThrust: IdleThrust {
				sound[] = {"\owr\sounds\vehicles\am_med_sib_idle", db-13,1, 200};
			};
			class EngineThrust: EngineThrust {
				sound[] = {"\owr\sounds\vehicles\am_med_sol_1400", db-5,1, 250};
			};
			class Engine1_Thrust_ext: Engine1_Thrust_ext {
				sound[] = {"\owr\sounds\vehicles\am_med_sol_1400", db-4,1, 280};
			};
			class Engine2_Thrust_ext: Engine2_Thrust_ext {
				sound[] = {"\owr\sounds\vehicles\am_med_sol_1400", db-3,1, 320};
			};
			class Engine3_Thrust_ext: Engine3_Thrust_ext {
				sound[] = {"\owr\sounds\vehicles\am_med_sol_2000", db-2,1, 360};
			};
			class Engine4_Thrust_ext: Engine4_Thrust_ext {
				sound[] = {"\owr\sounds\vehicles\am_med_sol_2000", db0,1, 400};
			};
			class Engine5_Thrust_ext: Engine5_Thrust_ext {
				sound[] = {"\owr\sounds\vehicles\am_med_sol_2000", db2,1, 450};
			};
		};
	};

	class owr_am_light_wheeled_combustion_ai: owr_am_light_wheeled_combustion {
		crew = "B_UAV_AI";
		typicalCargo[] = {"B_UAV_AI", "B_UAV_AI"};
		class EventHandlers {
			init = "(_this select 0) animateSource ['hide_solar', 1, true]; (_this select 0) animateSource ['hide_mn', 1, true];";
		};
	};
	class owr_am_light_wheeled_electric_ai: owr_am_light_wheeled_electric {
		crew = "B_UAV_AI";
		typicalCargo[] = {"B_UAV_AI", "B_UAV_AI"};
		class EventHandlers {
			init = "(_this select 0) animateSource ['hide_comb', 1, true]; (_this select 0) animateSource ['hide_mn', 1, true];";
		};
	};


	// ACTUAL VEHICLE CLASSES FOR THE GAMEPLAY
	// RADAR
	class owr_am_lt_wh_mn_cb_radar: owr_am_light_wheeled_combustion {
		scope = 2;
		scopeCurator = 2;

		// AM - LIGHT - WHEELED - MANNED - COMBUSTION - RADAR
		model 	= "\owr\vehicles\wheeled\light\mn_radar.p3d";  /// simple path to model
		picture	= "\A3\Weapons_F\Data\placeholder_co.paa";
		Icon	= "\owr\ui\data\research\icon_res_radar_ca.paa";

		displayName = "AM Light Comb Radar";

		hasGunner = 0;
		hasCommander = 0;

		class Turrets: Turrets {
			delete MainTurret;
		};
		class AnimationSources : AnimationSources {
			delete recoil_source;
			delete muzzle_rot;
			delete muzzle_hide;
		};
	};
	class owr_am_lt_wh_mn_el_radar: owr_am_light_wheeled_electric {
		scope = 2;
		scopeCurator = 2;

		// AM - LIGHT - WHEELED - MANNED - ELECTRIC - RADAR
		model 	= "\owr\vehicles\wheeled\light\mn_radar.p3d";  /// simple path to model
		picture	= "\A3\Weapons_F\Data\placeholder_co.paa";
		Icon	= "\owr\ui\data\research\icon_res_radar_ca.paa";

		displayName = "AM Light Electric Radar";

		hasGunner = 0;
		hasCommander = 0;

		class Turrets: Turrets {
			delete MainTurret;
		};
		class AnimationSources : AnimationSources {
			delete recoil_source;
			delete muzzle_rot;
			delete muzzle_hide;
		};
	};
	class owr_am_lt_wh_ai_cb_radar: owr_am_light_wheeled_combustion_ai {
		scope = 2;
		scopeCurator = 2;

		// AM - LIGHT - WHEELED - MANNED - COMBUSTION - RADAR
		model 	= "\owr\vehicles\wheeled\light\mn_radar.p3d";  /// simple path to model
		picture	= "\A3\Weapons_F\Data\placeholder_co.paa";
		Icon	= "\owr\ui\data\research\icon_res_radar_ca.paa";

		displayName = "AM Light Comb Radar";

		typicalCargo[] = {"B_UAV_AI"};
		hasGunner = 0;
		hasCommander = 0;

		class Turrets: Turrets {
			delete MainTurret;
		};
		class AnimationSources : AnimationSources {
			delete recoil_source;
			delete muzzle_rot;
			delete muzzle_hide;
		};
	};
	class owr_am_lt_wh_ai_el_radar: owr_am_light_wheeled_electric_ai {
		scope = 2;
		scopeCurator = 2;

		// AM - LIGHT - WHEELED - MANNED - ELECTRIC - RADAR
		model 	= "\owr\vehicles\wheeled\light\mn_radar.p3d";  /// simple path to model
		picture	= "\A3\Weapons_F\Data\placeholder_co.paa";
		Icon	= "\owr\ui\data\research\icon_res_radar_ca.paa";

		displayName = "AM Light Electric Radar";

		typicalCargo[] = {"B_UAV_AI"};
		hasGunner = 0;
		hasCommander = 0;

		class Turrets: Turrets {
			delete MainTurret;
		};
		class AnimationSources : AnimationSources {
			delete recoil_source;
			delete muzzle_rot;
			delete muzzle_hide;
		};
	};


	// MACHINE GUN
	class owr_am_lt_wh_mn_cb_mgun: owr_am_light_wheeled_combustion {
		scope = 2;
		scopeCurator = 2;

		// AM - LIGHT - WHEELED - MANNED - COMBUSTION - MACHINE GUN
		model 	= "\owr\vehicles\wheeled\light\mn_mgun.p3d";  /// simple path to model
		picture	= "\A3\Weapons_F\Data\placeholder_co.paa";
		Icon	= "\owr\ui\data\research\icon_res_gun_ca.paa";

		displayName = "AM Light Comb Machine Gun";

		class Turrets: Turrets {
			class MainTurret: MainTurret {
				weapons[] = {"owr_am_w_mgun"};
				magazines[] = {"owr_am_m_mgun"};
			};
		};
		class AnimationSources : AnimationSources {
			class recoil_source: recoil_source {
				weapon = "owr_am_w_mgun";
			};
			class muzzle_rot: muzzle_rot {
				weapon = "owr_am_w_mgun";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_am_w_mgun";
			};
		};
	};
	class owr_am_lt_wh_mn_el_mgun: owr_am_light_wheeled_electric {
		scope = 2;
		scopeCurator = 2;

		// AM - LIGHT - WHEELED - MANNED - ELECTRIC - MACHINE GUN
		model 	= "\owr\vehicles\wheeled\light\mn_mgun.p3d";  /// simple path to model
		picture	= "\A3\Weapons_F\Data\placeholder_co.paa";
		Icon	= "\owr\ui\data\research\icon_res_gun_ca.paa";

		displayName = "AM Light Elec Machine Gun";

		class Turrets: Turrets {
			class MainTurret: MainTurret {
				weapons[] = {"owr_am_w_mgun"};
				magazines[] = {"owr_am_m_mgun"};
			};
		};
		class AnimationSources : AnimationSources {
			class recoil_source: recoil_source {
				weapon = "owr_am_w_mgun";
			};
			class muzzle_rot: muzzle_rot {
				weapon = "owr_am_w_mgun";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_am_w_mgun";
			};
		};
	};
	class owr_am_lt_wh_ai_cb_mgun: owr_am_light_wheeled_combustion_ai {
		scope = 2;
		scopeCurator = 2;

		// AM - LIGHT - WHEELED - AI CONTROLLED - COMBUSTION - MACHINE GUN
		model 	= "\owr\vehicles\wheeled\light\mn_mgun.p3d";
		picture	= "\A3\Weapons_F\Data\placeholder_co.paa";
		Icon	= "\owr\ui\data\research\icon_res_gun_ca.paa";

		displayName = "AM Light Comb Machine Gun";
		
		class Turrets: Turrets {
			class MainTurret: MainTurret {
				weapons[] = {"owr_am_w_mgun"};
				magazines[] = {"owr_am_m_mgun"};
			};
		};
		class AnimationSources : AnimationSources {
			class recoil_source: recoil_source {
				weapon = "owr_am_w_mgun";
			};
			class muzzle_rot: muzzle_rot {
				weapon = "owr_am_w_mgun";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_am_w_mgun";
			};
		};
	};
	class owr_am_lt_wh_ai_el_mgun: owr_am_light_wheeled_electric_ai {
		scope = 2;
		scopeCurator = 2;

		// AM - LIGHT - WHEELED - AI CONTROLLED - ELECTRIC - MACHINE GUN
		model 	= "\owr\vehicles\wheeled\light\mn_mgun.p3d";
		picture	= "\A3\Weapons_F\Data\placeholder_co.paa";
		Icon	= "\owr\ui\data\research\icon_res_gun_ca.paa";

		displayName = "AM Light Elec Machine Gun";

		class Turrets: Turrets {
			class MainTurret: MainTurret {
				weapons[] = {"owr_am_w_mgun"};
				magazines[] = {"owr_am_m_mgun"};
			};
		};
		class AnimationSources : AnimationSources {
			class recoil_source: recoil_source {
				weapon = "owr_am_w_mgun";
			};
			class muzzle_rot: muzzle_rot {
				weapon = "owr_am_w_mgun";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_am_w_mgun";
			};
		};
	};


	// LIGHT GUN
	class owr_am_lt_wh_mn_cb_lgun: owr_am_light_wheeled_combustion {
		scope = 2;
		scopeCurator = 2;

		// AM - LIGHT - WHEELED - MANNED - COMBUSTION - LIGHT GUN
		model 	= "\owr\vehicles\wheeled\light\mn_lgun.p3d";
		picture	= "\A3\Weapons_F\Data\placeholder_co.paa";
		Icon	= "\owr\ui\data\research\icon_res_gun_ca.paa";

		displayName = "AM Light Comb Light Gun";

		class Turrets: Turrets {
			class MainTurret: MainTurret {
				weapons[] = {"owr_am_w_lgun"};
				magazines[] = {"owr_am_m_lgun"};
			};
		};
		class AnimationSources : AnimationSources {
			class recoil_source: recoil_source {
				weapon = "owr_am_w_lgun";
			};
			class muzzle_rot: muzzle_rot {
				weapon = "owr_am_w_lgun";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_am_w_lgun";
			};
		};
	};
	class owr_am_lt_wh_mn_el_lgun: owr_am_light_wheeled_electric {
		scope = 2;
		scopeCurator = 2;

		// AM - LIGHT - WHEELED - MANNED - ELECTRIC - LIGHT GUN
		model 	= "\owr\vehicles\wheeled\light\mn_lgun.p3d";
		picture	= "\A3\Weapons_F\Data\placeholder_co.paa";
		Icon	= "\owr\ui\data\research\icon_res_gun_ca.paa";

		displayName = "AM Light Elec Light Gun";

		class Turrets: Turrets {
			class MainTurret: MainTurret {
				weapons[] = {"owr_am_w_lgun"};
				magazines[] = {"owr_am_m_lgun"};
			};
		};
		class AnimationSources : AnimationSources {
			class recoil_source: recoil_source {
				weapon = "owr_am_w_lgun";
			};
			class muzzle_rot: muzzle_rot {
				weapon = "owr_am_w_lgun";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_am_w_lgun";
			};
		};
	};
	class owr_am_lt_wh_ai_cb_lgun: owr_am_light_wheeled_combustion_ai {
		scope = 2;
		scopeCurator = 2;

		// AM - LIGHT - WHEELED - AI CONTROLLED - COMBUSTION - LIGHT GUN
		model 	= "\owr\vehicles\wheeled\light\mn_lgun.p3d";
		picture	= "\A3\Weapons_F\Data\placeholder_co.paa";
		Icon	= "\owr\ui\data\research\icon_res_gun_ca.paa";

		displayName = "AM Light Comb Light Gun";

		class Turrets: Turrets {
			class MainTurret: MainTurret {
				weapons[] = {"owr_am_w_lgun"};
				magazines[] = {"owr_am_m_lgun"};
			};
		};
		class AnimationSources : AnimationSources {
			class recoil_source: recoil_source {
				weapon = "owr_am_w_lgun";
			};
			class muzzle_rot: muzzle_rot {
				weapon = "owr_am_w_lgun";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_am_w_lgun";
			};
		};
	};
	class owr_am_lt_wh_ai_el_lgun: owr_am_light_wheeled_electric_ai {
		scope = 2;
		scopeCurator = 2;

		// AM - LIGHT - WHEELED - AI CONTROLLED - ELECTRIC - LIGHT GUN
		model 	= "\owr\vehicles\wheeled\light\mn_lgun.p3d";
		picture	= "\A3\Weapons_F\Data\placeholder_co.paa";
		Icon	= "\owr\ui\data\research\icon_res_gun_ca.paa";

		displayName = "AM Light Elec Light Gun";

		class Turrets: Turrets {
			class MainTurret: MainTurret {
				weapons[] = {"owr_am_w_lgun"};
				magazines[] = {"owr_am_m_lgun"};
			};
		};
		class AnimationSources : AnimationSources {
			class recoil_source: recoil_source {
				weapon = "owr_am_w_lgun";
			};
			class muzzle_rot: muzzle_rot {
				weapon = "owr_am_w_lgun";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_am_w_lgun";
			};
		};
	};
};