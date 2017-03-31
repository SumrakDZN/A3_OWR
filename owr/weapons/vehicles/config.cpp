class CfgPatches {
	class owr_weapons_vehicles {
		author = "Sumrak";
		name = "OWR - Weapons for Vehicles";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"A3_Weapons_F"};
		requiredVersion = 0.1;
		units[] = {};
		weapons[] = {
			"owr_am_w_mgun",
			"owr_am_w_lgun",
			"owr_am_w_vrl",
			"owr_am_w_hgun",
			"owr_am_w_rgun",
			"owr_am_w_laser",
			"owr_am_w_dgun",
			"owr_ru_w_hmgun",
			"owr_ru_w_rgun",
			"owr_ru_w_gun",
			"owr_ru_w_hgun",
			"owr_ru_w_vrl",
			"owr_ru_w_rocket"
		};
	};
};

// place for all vehicle weapons
class CfgAmmo {
	class MissileBase;
	class BulletBase;

	class owr_am_a_vehicle_rockets: MissileBase {
		model = "\A3\Weapons_F\Ammo\Rocket_01_fly_F";
		proxyShape = "\A3\Weapons_F\Ammo\Rocket_01_F";
		hit = 46;
		indirectHit = 0;
		indirectHitRange = 3.25;
		cost = 500;
		maxSpeed = 720;
		irLock = 1;
		laserLock = 0;
		airLock = 0;
		maxControlRange = 5000;
		trackOversteer = 1;
		trackLead = 1;
		maneuvrability = 8;
		timeToLive = 20;
		simulationStep = 0.01;
		airFriction = 0.1;
		sideAirFriction = 0.16;
		initTime = 0.002;
		thrustTime = 1.07;
		thrust = 530;
		fuseDistance = 5;
		CraterEffects = "GrenadeCrater";
		explosionEffects = "GrenadeExplosion";
		effectsMissileInit = "MissileDAR1";
		effectsMissile = "missile2";
		whistleDist = 4;
		muzzleEffect = "";
		weaponLockSystem = "2 + 16";
		manualControl = 0;
	};
	class owr_ru_a_vehicle_rockets: MissileBase {
		model = "\A3\Weapons_F\Ammo\Rocket_01_fly_F";
		proxyShape = "\A3\Weapons_F\Ammo\Rocket_01_F";
		hit = 46.0;
		indirectHit = 0;
		indirectHitRange = 3.25;
		cost = 500;
		maxSpeed = 720;
		irLock = 1;
		laserLock = 1;
		airLock = 0;
		maxControlRange = 5000;
		trackOversteer = 1;
		trackLead = 1;
		maneuvrability = 8;
		timeToLive = 20;
		simulationStep = 0.01;
		airFriction = 0.1;
		sideAirFriction = 0.16;
		initTime = 0.002;
		thrustTime = 1.07;
		thrust = 530;
		fuseDistance = 5;
		CraterEffects = "GrenadeCrater";
		explosionEffects = "GrenadeExplosion";
		effectsMissileInit = "MissileDAR1";
		effectsMissile = "missile2";
		whistleDist = 4;
		muzzleEffect = "";
		weaponLockSystem = "2 + 16";
		manualControl = 0;
	};
	class owr_a_ru_rocket: MissileBase {
		model = "\A3\Weapons_F_beta\Launchers\titan\titan_missile_at_fly";
		hit = 120;
		indirectHit = 0;
		indirectHitRange = 4;
		explosive = 0.8;
		cost = 500;
		irLock = 1;
		aiAmmoUsageFlags = "128 + 512";
		airLock = 0;
		laserLock = 1;
		manualControl = 1;
		maxControlRange = 5000;
		explosionSoundEffect = "DefaultExplosion";
		effectsMissileInit = "RocketBackEffectsRPG";
		initTime = 0.25;
		trackOversteer = 1;
		trackLead = 0.85;
		timeToLive = 30;
		maneuvrability = 6;
		simulationStep = 0.002;
		airFriction = 0.084;
		sideAirFriction = 0.05;
		maxSpeed = 200;
		thrustTime = 3;
		thrust = 130;
		fuseDistance = 50;
		effectsMissile = "missile2";
		whistleDist = 4;
		weaponLockSystem = "2 + 16";
	};



	class owr_mgun: BulletBase {
		hit = 7.5;
		indirectHitRange = 0;
		cartridge = "FxCartridge_65_caseless";
		dangerRadiusBulletClose = 8;
		dangerRadiusHit = 12;
		suppressionRadiusBulletClose = 6;
		suppressionRadiusHit = 8;
		cost = 1.2;
		airLock = 1;
		typicalSpeed = 820;
		caliber = 1;
		model = "\A3\Weapons_f\Data\bullettracer\tracer_yellow";
		tracerScale = 1.0;
		tracerStartTime = 0.05;
		tracerEndTime = 1;
		airFriction = -0.0009;
	};
	class owr_lgun: BulletBase {
		hit = 16;
		indirectHit = 0;
		indirectHitRange = 0;
		cartridge = "FxCartridge_127";
		visibleFire = 8;
		audibleFire = 120;
		dangerRadiusBulletClose = 12;
		dangerRadiusHit = 16;
		suppressionRadiusBulletClose = 8;
		suppressionRadiusHit = 12;
		cost = 5;
		airLock = 1;
		caliber = 2.6;
		typicalSpeed = 880;
		timeToLive = 10;
		model = "\A3\Weapons_f\Data\bullettracer\tracer_white";
		tracerScale = 1.2;
		tracerStartTime = 0.075;
		tracerEndTime = 1;
		airFriction = -0.00086;
	};
	class owr_gun: BulletBase {
		soundFly[] = {"",1.0,1,50};
		soundHit1[] = {"A3\Sounds_F\arsenal\explosives\shells\30mm40mm_shell_explosion_01",1.7782794,1,1600};
		soundHit2[] = {"A3\Sounds_F\arsenal\explosives\shells\30mm40mm_shell_explosion_02",1.7782794,1,1600};
		soundHit3[] = {"A3\Sounds_F\arsenal\explosives\shells\30mm40mm_shell_explosion_03",1.7782794,1,1600};
		soundHit4[] = {"A3\Sounds_F\arsenal\explosives\shells\30mm40mm_shell_explosion_04",1.7782794,1,1600};
		multiSoundHit[] = {"soundHit1",0.25,"soundHit2",0.25,"soundHit3",0.25,"soundHit4",0.25};
		explosionSoundEffect = "DefaultExplosion";
		hit = 20;
		indirectHit = 0;
		indirectHitRange = 2;
		explosive = 0.8;
		explosionEffects = "ExploAmmoExplosion";
		craterEffects = "ExploAmmoCrater";
		visibleFire = 16;
		audibleFire = 150;
		visibleFireTime = 3;
		dangerRadiusBulletClose = 16;
		dangerRadiusHit = 40;
		suppressionRadiusBulletClose = 10;
		suppressionRadiusHit = 14;
		cost = 20;
		deflecting = 5;
		airFriction = -0.0006;
		fuseDistance = 3;
		typicalSpeed = 400;
		caliber = 2;
		model = "\A3\Weapons_f\Data\bullettracer\tracer_white";
		tracerScale = 1;
		tracerStartTime = 0.05;
		tracerEndTime = 1;
	};
	class owr_hgun: owr_gun {
		weaponType = "cannon";
		hit = 30;
		indirectHit = 0;
		indirectHitRange = 3;
		explosive = 0.8;
		visibleFire = 32;
		audibleFire = 200;
		visibleFireTime = 3;
		dangerRadiusBulletClose = 20;
		dangerRadiusHit = 60;
		suppressionRadiusBulletClose = 12;
		suppressionRadiusHit = 24;
		cost = 20;
		airFriction = -0.00036;
		fuseDistance = 3;
		typicalSpeed = 960;
		caliber = 1.4;
		airlock = 1;
		tracerScale = 2.5;
		tracerStartTime = 0.1;
		tracerEndTime = 4.7;
		soundHit1[] = {"A3\Sounds_F\arsenal\explosives\shells\30mm40mm_shell_explosion_01",1.7782794,1,1600};
		soundHit2[] = {"A3\Sounds_F\arsenal\explosives\shells\30mm40mm_shell_explosion_02",1.7782794,1,1600};
		soundHit3[] = {"A3\Sounds_F\arsenal\explosives\shells\30mm40mm_shell_explosion_03",1.7782794,1,1600};
		soundHit4[] = {"A3\Sounds_F\arsenal\explosives\shells\30mm40mm_shell_explosion_04",1.7782794,1,1600};
		multiSoundHit[] = {"soundHit1",0.25,"soundHit2",0.25,"soundHit3",0.25,"soundHit4",0.25};
	};

	class owr_am_a_laser: BulletBase {
		hit = 38.2;
		indirectHit = 0;
		indirectHitRange = 0;
		cartridge = "FxCartridge_127";
		visibleFire = 10;
		audibleFire = 15;
		cost = 5;
		coefGravity = 0;
		airLock = 1;
		caliber = 2.6;
		typicalSpeed = 1;
		model = "\A3\Weapons_f\Data\bullettracer\tracer_white";
		tracerScale = 1.2;
		tracerStartTime = 0.075;
		tracerEndTime = 1;
		airFriction = 0.0;
	};
	class owr_am_a_mgun: owr_mgun {
		hit = 14.3;
	};
	class owr_am_a_lgun: owr_lgun {
		hit = 38.2;
	};
	class owr_am_a_dgun: owr_lgun {
		hit = 35.7;
	};
	class owr_ru_a_hmgun: owr_lgun {
		hit = 11.5;
	};
	class owr_ru_a_rgun: owr_lgun {
		hit = 11.5;
	};
	class owr_ru_a_gun: owr_gun {
		hit = 33.4;
	};
	class owr_ru_a_hgun: owr_hgun {
		hit = 45.5;
	};
	class owr_am_a_hgun: owr_hgun {
		hit = 51.5;
	};
};


class CfgMagazines {
	class VehicleMagazine;

	// AM
	class owr_am_m_mgun: VehicleMagazine {
		scope = 2;
		count = 999999;
		ammo = "owr_am_a_mgun";
		initSpeed = 910;
		maxLeadSpeed = 200;
		tracersEvery = 1;
		nameSound = "mgun";
		displayName = "AM Machine Gun Ammo";
		descriptionShort = "Lot of ammo for lot of pew pew";
	};
	class owr_am_m_lgun: VehicleMagazine {
		scope = 2;
		count = 999999;
		ammo = "owr_am_a_lgun";
		initSpeed = 1200;
		maxLeadSpeed = 200;
		tracersEvery = 1;
		nameSound = "mgun";
		displayName = "AM Light Cannon Ammo";
		descriptionShort = "Lot of ammo for lot of pew pew";
	};
	class owr_am_m_dgun: VehicleMagazine {
		scope = 2;
		count = 2;
		ammo = "owr_am_a_dgun";
		initSpeed = 1200;
		maxLeadSpeed = 200;
		tracersEvery = 1;
		nameSound = "mgun";
		displayName = "AM Double Cannon Ammo";
		descriptionShort = "Lot of ammo for lot of pew pew";
	};
	class owr_am_m_hgun: VehicleMagazine {
		scope = 2;
		displayName = "AM Heavy Cannon Ammo";
		descriptionShort = "Lot of ammo for lot of pew pew";
		ammo = "owr_am_a_hgun";
		count = 999999;
		initSpeed = 960;
		maxLeadSpeed = 300;
		nameSound = "cannon";
		tracersEvery = 1;
		weight = 126;
	};
	class owr_am_m_laser: VehicleMagazine {
		scope = 2;
		count = 999999;
		ammo = "owr_am_a_laser";
		initSpeed = 100000;
		maxLeadSpeed = 100000;
		tracersEvery = 1;
		nameSound = "mgun";
		displayName = "AM Laser Ammo";
		descriptionShort = "Lot of ammo for lot of pew pew";
	};
	class owr_am_m_vrockets: VehicleMagazine {
		scope = 2;
		count = 8;
		ammo = "owr_am_a_vehicle_rockets";
		displayName = "AM Rockets";
		displayNameShort = "AM Rockets";
		descriptionShort = "AM Rockets";
		initSpeed = 30;
		maxLeadSpeed = 650;
		nameSound = "missiles";
		sound[] = {"A3\sounds_f\dummysound",3.1622777,1};
		reloadSound[] = {"A3\sounds_f\dummysound",0.00031622776,1};
	};


	// RU
	class owr_ru_m_hmgun: VehicleMagazine {
		scope = 2;
		count = 2;
		ammo = "owr_ru_a_hmgun";
		initSpeed = 910;
		maxLeadSpeed = 200;
		tracersEvery = 1;
		nameSound = "mgun";
		displayName = "RU Heavy Machine Gun Ammo";
		descriptionShort = "Lot of ammo for lot of pew pew";
	};
	class owr_ru_m_rgun: VehicleMagazine {
		scope = 2;
		count = 2;
		ammo = "owr_ru_a_rgun";
		initSpeed = 910;
		maxLeadSpeed = 200;
		tracersEvery = 1;
		nameSound = "mgun";
		displayName = "RU Minigun Ammo";
		descriptionShort = "Lot of ammo for lot of pew pew";
	};
	class owr_ru_m_gun: VehicleMagazine {
		scope = 2;
		count = 2;
		ammo = "owr_ru_a_gun";
		initSpeed = 1200;
		maxLeadSpeed = 200;
		tracersEvery = 1;
		nameSound = "cannon";
		displayName = "RU Cannon Ammo";
		descriptionShort = "Lot of ammo for lot of pew pew";
	};
	class owr_ru_m_hgun: VehicleMagazine {
		scope = 2;
		displayName = "RU Heavy Cannon Ammo";
		descriptionShort = "Lot of ammo for lot of pew pew";
		ammo = "owr_ru_a_hgun";
		count = 2;
		initSpeed = 960;
		maxLeadSpeed = 300;
		nameSound = "cannon";
		tracersEvery = 1;
		weight = 126;
	};
	class owr_ru_m_vrockets: VehicleMagazine {
		scope = 2;
		count = 8;
		ammo = "owr_ru_a_vehicle_rockets";
		displayName = "RU Rockets";
		displayNameShort = "RU Rockets";
		descriptionShort = "RU Rockets";
		initSpeed = 30;
		maxLeadSpeed = 650;
		nameSound = "rockets";
		sound[] = {"A3\sounds_f\dummysound",3.1622777,1};
		reloadSound[] = {"A3\sounds_f\dummysound",0.00031622776,1};
	};
	class owr_ru_m_rockets: VehicleMagazine {
		scope = 2;
		count = 2;
		ammo = "owr_a_ru_rocket";
		displayName = "RU Rocket";
		displayNameShort = "RU Rocket";
		descriptionShort = "RU Rocket";
		initSpeed = 30;
		maxLeadSpeed = 650;
		nameSound = "rockets";
		sound[] = {"A3\sounds_f\dummysound",3.1622777,1};
		reloadSound[] = {"A3\sounds_f\dummysound",0.00031622776,1};
	};
};

class Mode_FullAuto;

class CfgWeapons {
	class MGun;
	class LMG_RCWS;
	class RocketPods;
	class MissileLauncher;
	class CannonCore;

	class owr_am_w_mgun: LMG_RCWS {
		displayName = "AM Machine Gun";
		magazines[] = {"owr_am_m_mgun"};
		ballisticsComputer = 2;

		reloadMagazineSound[] = {"A3\sounds_f\dummysound",0.01,1,10};

		class GunParticles {
			class effect1 {
				positionName = "mainGunMuzzle";
				directionName = "mainGunEnd";
				effectName = "MachineGunCloud";
			};
		};

		showAimCursorInternal = 0;
		class manual: MGun {
			displayName = "AM Machine Gun";
			reloadTime = 0.15;
			dispersion = 0.00147;
			sounds[] = {"StandardSound"};
			class StandardSound {
				begin1[] = {"A3\sounds_f\weapons\M200\Mk200_st_4a",1.0,1,1200};
				begin2[] = {"A3\sounds_f\weapons\M200\Mk200_st_5a",1.0,1,1200};
				begin3[] = {"A3\sounds_f\weapons\M200\Mk200_st_6a",1.0,1,1200};
				soundBegin[] = {"begin1",0.34,"begin2",0.33,"begin3",0.33};
				weaponSoundEffect = "DefaultRifle";
				closure1[] = {"A3\sounds_f\weapons\closure\sfx7",1.0,1,20};
				closure2[] = {"A3\sounds_f\weapons\closure\sfx8",1.0,1,20};
				soundClosure[] = {"closure1",0.5,"closure2",0.5};
			};
			soundContinuous = 0;
			soundBurst = 0;
			minRange = 0;
			minRangeProbab = 0.01;
			midRange = 1;
			midRangeProbab = 0.01;
			maxRange = 2;
			maxRangeProbab = 0.01;
		};
		class close: manual {
			burst = 7;
			aiRateOfFire = 1;
			aiRateOfFireDistance = 50;
			minRange = 0;
			minRangeProbab = 0.05;
			midRange = 20;
			midRangeProbab = 0.7;
			maxRange = 50;
			maxRangeProbab = 0.1;
			showToPlayer = 0;
		};
		class short: close {
			burst = 6;
			aiRateOfFire = 2;
			aiRateOfFireDistance = 300;
			minRange = 50;
			minRangeProbab = 0.05;
			midRange = 200;
			midRangeProbab = 0.7;
			maxRange = 300;
			maxRangeProbab = 0.1;
		};
		class medium: close {
			burst = 5;
			aiRateOfFire = 4;
			aiRateOfFireDistance = 600;
			minRange = 200;
			minRangeProbab = 0.05;
			midRange = 500;
			midRangeProbab = 0.7;
			maxRange = 600;
			maxRangeProbab = 0.1;
		};
		class far: close {
			burst = 4;
			aiRateOfFire = 5;
			aiRateOfFireDistance = 1000;
			minRange = 400;
			minRangeProbab = 0.05;
			midRange = 850;
			midRangeProbab = 0.4;
			maxRange = 1100;
			maxRangeProbab = 0.01;
		};
	};
	class owr_am_w_rgun: LMG_RCWS {
		displayName = "AM Minigun";
		magazines[] = {"owr_am_m_mgun"};

		reloadMagazineSound[] = {"A3\sounds_f\dummysound",0.01,1,10};

		class GunParticles {
			class effect1 {
				positionName = "mainGunMuzzle";
				directionName = "mainGunEnd";
				effectName = "MachineGunCloud";
			};
		};
		class manual: MGun {
			displayName = "AM Minigun";
			autoFire = 1;
			aiRateOfFire = 0.5;
			sounds[] = {"StandardSound"};
			class StandardSound
			{
				begin1[] = {"A3\Sounds_F\arsenal\weapons_vehicles\LMG_Minigun_65mm\LMG_minigun_65mm_01",1.0,1,2000};
				begin2[] = {"A3\Sounds_F\arsenal\weapons_vehicles\LMG_Minigun_65mm\LMG_minigun_65mm_02",1.0,1.1,2000};
				begin3[] = {"A3\Sounds_F\arsenal\weapons_vehicles\LMG_Minigun_65mm\LMG_minigun_65mm_03",1.0,0.9,2000};
				soundBegin[] = {"begin1",0.33,"begin2",0.33,"begin3",0.34};
				closure1[] = {"A3\sounds_f\weapons\gatling\gatling_rotation_short_2",0.31622776,1,20};
				closure2[] = {"A3\sounds_f\weapons\gatling\gatling_rotation_short_3",0.31622776,1,20};
				soundClosure[] = {"closure1",0.5,"closure2",0.5};
			};
			reloadTime = 0.1;
			dispersion = 0.00387;
			showToPlayer = 1;
			soundContinuous = 0;
			burst = 1;
			multiplier = 3;
			aiRateOfFireDistance = 50;
			minRange = 1;
			minRangeProbab = 0.01;
			midRange = 2;
			midRangeProbab = 0.01;
			maxRange = 3;
			maxRangeProbab = 0.01;
		};
		class close: manual {
			showToPlayer = 0;
			soundBurst = 0;
			burst = 10;
			aiRateOfFire = 0.5;
			aiRateOfFireDistance = 50;
			minRange = 0;
			minRangeProbab = 0.05;
			midRange = 100;
			midRangeProbab = 0.7;
			maxRange = 200;
			maxRangeProbab = 0.1;
		};
		class short: close {
			burst = 8;
			aiRateOfFire = 2;
			aiRateOfFireDistance = 300;
			minRange = 50;
			minRangeProbab = 0.05;
			midRange = 200;
			midRangeProbab = 0.7;
			maxRange = 400;
			maxRangeProbab = 0.1;
		};
		class medium: close {
			burst = 6;
			aiRateOfFire = 3;
			aiRateOfFireDistance = 600;
			minRange = 300;
			minRangeProbab = 0.05;
			midRange = 400;
			midRangeProbab = 0.7;
			maxRange = 600;
			maxRangeProbab = 0.1;
		};
		class far: close {
			burst = 4;
			aiRateOfFire = 5;
			aiRateOfFireDistance = 1000;
			minRange = 500;
			minRangeProbab = 0.05;
			midRange = 600;
			midRangeProbab = 0.4;
			maxRange = 800;
			maxRangeProbab = 0.01;
		};
	};
	class owr_am_w_lgun: LMG_RCWS {
		displayName = "AM Light Cannon";
		magazines[] = {"owr_am_m_lgun"};
		ballisticsComputer = 2;

		reloadMagazineSound[] = {"A3\sounds_f\dummysound",0.01,1,10};

		class GunParticles {
			class effect1 {
				positionName = "mainGunMuzzle";
				directionName = "mainGunEnd";
				effectName = "MachineGunCloud";
			};
		};
		showAimCursorInternal = 0;
		class manual: MGun
		{
			displayName = "AM Light Cannon";
			reloadTime = 0.60;
			dispersion = 0.00147;
			sounds[] = {"StandardSound"};
			class StandardSound
			{
				begin1[] = {"A3\sounds_f\weapons\hmg\hmg_gun",1.4125376,1.1,2000};
				soundBegin[] = {"begin1",1};
				weaponSoundEffect = "DefaultRifle";
				closure1[] = {"A3\sounds_f\weapons\closure\sfx7",1.0,1,20};
				closure2[] = {"A3\sounds_f\weapons\closure\sfx8",1.0,1,20};
				soundClosure[] = {"closure1",0.5,"closure2",0.5};
			};
			soundContinuous = 0;
			soundBurst = 0;
			minRange = 0;
			minRangeProbab = 0.01;
			midRange = 1;
			midRangeProbab = 0.01;
			maxRange = 2;
			maxRangeProbab = 0.01;
		};
		class close: manual
		{
			burst = 7;
			aiRateOfFire = 1;
			aiRateOfFireDistance = 50;
			minRange = 0;
			minRangeProbab = 0.05;
			midRange = 20;
			midRangeProbab = 0.7;
			maxRange = 50;
			maxRangeProbab = 0.1;
			showToPlayer = 0;
		};
		class short: close
		{
			burst = 6;
			aiRateOfFire = 2;
			aiRateOfFireDistance = 300;
			minRange = 50;
			minRangeProbab = 0.05;
			midRange = 200;
			midRangeProbab = 0.7;
			maxRange = 300;
			maxRangeProbab = 0.1;
		};
		class medium: close
		{
			burst = 5;
			aiRateOfFire = 4;
			aiRateOfFireDistance = 600;
			minRange = 200;
			minRangeProbab = 0.05;
			midRange = 500;
			midRangeProbab = 0.7;
			maxRange = 600;
			maxRangeProbab = 0.1;
		};
		class far: close
		{
			burst = 4;
			aiRateOfFire = 5;
			aiRateOfFireDistance = 1000;
			minRange = 400;
			minRangeProbab = 0.05;
			midRange = 850;
			midRangeProbab = 0.4;
			maxRange = 1100;
			maxRangeProbab = 0.01;
		};
	};
	class owr_am_w_dgun: owr_am_w_lgun {
		displayName = "AM Double Cannon";

		reloadMagazineSound[] = {"A3\sounds_f\dummysound",0.01,1,10};

		class GunParticles {
			class effect1 {
				positionName = "mainGun1_cloud";
				directionName = "mainGun1_chamber";
				effectName = "MachineGunCloud";
			};
			class effect2 {
				positionName = "mainGun2_cloud";
				directionName = "mainGun2_chamber";
				effectName = "MachineGunCloud";
			};
		};
		magazines[] = {"owr_am_m_dgun"};
		magazineReloadTime = 0.75;
		class manual: MGun
		{
			displayName = "AM Double Cannon";
			autoFire = 1;
			reloadTime = 0.01;
			dispersion = 0.00247;
			sounds[] = {"StandardSound"};
			class StandardSound {
				begin1[] = {"A3\sounds_f\weapons\hmg\hmg_gun",1.4125376,1.1,2000};
				soundBegin[] = {"begin1",1};
				weaponSoundEffect = "DefaultRifle";
				closure1[] = {"A3\sounds_f\weapons\closure\sfx7",1.0,1,20};
				closure2[] = {"A3\sounds_f\weapons\closure\sfx8",1.0,1,20};
				soundClosure[] = {"closure1",0.5,"closure2",0.5};
			};
			soundContinuous = 0;
			burst = 2;
			soundBurst = 1;
			minRange = 0;
			minRangeProbab = 0.01;
			midRange = 1;
			midRangeProbab = 0.01;
			maxRange = 2;
			maxRangeProbab = 0.01;
		};
		class close: manual
		{
			burst = 7;
			aiRateOfFire = 1;
			aiRateOfFireDistance = 50;
			minRange = 0;
			minRangeProbab = 0.05;
			midRange = 20;
			midRangeProbab = 0.7;
			maxRange = 50;
			maxRangeProbab = 0.1;
			showToPlayer = 0;
		};
		class short: close
		{
			burst = 6;
			aiRateOfFire = 2;
			aiRateOfFireDistance = 300;
			minRange = 50;
			minRangeProbab = 0.05;
			midRange = 200;
			midRangeProbab = 0.7;
			maxRange = 300;
			maxRangeProbab = 0.1;
		};
		class medium: close
		{
			burst = 5;
			aiRateOfFire = 4;
			aiRateOfFireDistance = 600;
			minRange = 200;
			minRangeProbab = 0.05;
			midRange = 500;
			midRangeProbab = 0.7;
			maxRange = 600;
			maxRangeProbab = 0.1;
		};
		class far: close
		{
			burst = 4;
			aiRateOfFire = 5;
			aiRateOfFireDistance = 1000;
			minRange = 400;
			minRangeProbab = 0.05;
			midRange = 850;
			midRangeProbab = 0.4;
			maxRange = 1100;
			maxRangeProbab = 0.01;
		};
	};
	class owr_am_w_laser: LMG_RCWS {
		displayName = "AM Laser";
		magazines[] = {"owr_am_m_laser"};
		ballisticsComputer = 2;

		reloadMagazineSound[] = {"A3\sounds_f\dummysound",0.01,1,10};

		class GunParticles {
		};
		showAimCursorInternal = 0;
		class manual: MGun {
			displayName = "AM Laser";
			reloadTime = 1.00;
			dispersion = 0.0;
			sounds[] = {"StandardSound"};
			class StandardSound
			{
				begin1[] = {"\owr\sounds\weapons\am_laser_fire",1.4125376,1.1,2000};
				soundBegin[] = {"begin1",1};
				weaponSoundEffect = "DefaultRifle";
				closure1[] = {"A3\sounds_f\weapons\closure\sfx7",1.0,1,20};
				closure2[] = {"A3\sounds_f\weapons\closure\sfx8",1.0,1,20};
				soundClosure[] = {"closure1",0.5,"closure2",0.5};
			};
			soundContinuous = 0;
			soundBurst = 0;
			minRange = 0;
			minRangeProbab = 0.01;
			midRange = 1;
			midRangeProbab = 0.01;
			maxRange = 2;
			maxRangeProbab = 0.01;
		};
		class close: manual
		{
			burst = 7;
			aiRateOfFire = 1;
			aiRateOfFireDistance = 50;
			minRange = 0;
			minRangeProbab = 0.05;
			midRange = 20;
			midRangeProbab = 0.7;
			maxRange = 50;
			maxRangeProbab = 0.1;
			showToPlayer = 0;
		};
		class short: close
		{
			burst = 6;
			aiRateOfFire = 2;
			aiRateOfFireDistance = 300;
			minRange = 50;
			minRangeProbab = 0.05;
			midRange = 200;
			midRangeProbab = 0.7;
			maxRange = 300;
			maxRangeProbab = 0.1;
		};
		class medium: close
		{
			burst = 5;
			aiRateOfFire = 4;
			aiRateOfFireDistance = 600;
			minRange = 200;
			minRangeProbab = 0.05;
			midRange = 500;
			midRangeProbab = 0.7;
			maxRange = 600;
			maxRangeProbab = 0.1;
		};
		class far: close
		{
			burst = 4;
			aiRateOfFire = 5;
			aiRateOfFireDistance = 1000;
			minRange = 400;
			minRangeProbab = 0.05;
			midRange = 850;
			midRangeProbab = 0.4;
			maxRange = 1100;
			maxRangeProbab = 0.01;
		};
	};
	class owr_am_w_hgun: CannonCore {
		scope = 1;
		displayName = "AM Heavy Cannon";
		magazines[] = {"owr_am_m_hgun"};
		reloadMagazineSound[] = {"A3\sounds_f\dummysound",0.01,1,10};
		cursor = "EmptyCursor";
		cursorAim = "cannon";
		nameSound = "cannon";
		sound[] = {"A3\sounds_f\dummysound",2.5118864,1,1800};
		soundContinuous = 0;
		minRange = 5;
		minRangeProbab = 0.7;
		midRange = 1200;
		midRangeProbab = 0.7;
		maxRange = 2500;
		maxRangeProbab = 0.1;
		reloadTime = 0.3;
		aiRateOfFire = 0.6;
		aiRateOfFireDistance = 500;
		magazineReloadTime = 2;
		autoReload = 1;
		ballisticsComputer = 1;
		canLock = 2;
		autoFire = 1;
		modes[] = {"player","close","short","medium","far"};
		shotFromTurret = 1;
		showAimCursorInternal = 0;
		class GunParticles {
			class Effect {
				effectName = "AutoCannonFired";
				positionName = "mainGunMuzzle";
				directionName = "mainGunEnd";
			};
		};
		class player: Mode_FullAuto {
			displayName = "AM Heavy Cannon";
			sounds[] = {"StandardSound"};
			class StandardSound {
				begin1[] = {"A3\Sounds_F\weapons\30mm\30mm_st_02",1.9952624,1,1500};
				soundBegin[] = {"begin1",1};
				weaponSoundEffect = "DefaultRifle";
			};
			soundContinuous = 0;
			reloadTime = 0.75;
			dispersion = 0.00147;
		};
		class close: player
		{
			showToPlayer = 0;
			burst = 5;
			aiRateOfFire = 0.5;
			aiRateOfFireDistance = 50;
			minRange = 0;
			minRangeProbab = 0.05;
			midRange = 500;
			midRangeProbab = 0.7;
			maxRange = 1000;
			maxRangeProbab = 0.2;
			aiDispersionCoefX = 6;
			aiDispersionCoefY = 6;
		};
		class short: close
		{
			burst = 4;
			aiRateOfFire = 1;
			aiRateOfFireDistance = 300;
			minRange = 500;
			minRangeProbab = 0.05;
			midRange = 1000;
			midRangeProbab = 0.7;
			maxRange = 1500;
			maxRangeProbab = 0.2;
		};
		class medium: short
		{
			burst = 3;
			aiRateOfFire = 3;
			aiRateOfFireDistance = 600;
			minRange = 1000;
			minRangeProbab = 0.05;
			midRange = 1500;
			midRangeProbab = 0.7;
			maxRange = 2000;
			maxRangeProbab = 0.1;
		};
		class far: medium
		{
			burst = 3;
			aiRateOfFire = 5;
			aiRateOfFireDistance = 1000;
			minRange = 1500;
			minRangeProbab = 0.05;
			midRange = 2500;
			midRangeProbab = 0.4;
			maxRange = 3000;
			maxRangeProbab = 0.01;
		};
	};
	class owr_am_w_vrl: RocketPods {
		displayName = "AM Vehicle Rocket Launcher";
		magazines[] = {"owr_am_m_vrockets"};
		magazineReloadTime = 4.5;
		modes[] = {"Far_AI","Medium_AI","Close_AI","Burst"};
		canLock = 2;
		weaponLockDelay = 2.0;
		missileLockCone = 5;
		WeaponLockSystem = 4;
		cmImmunity = 0.9;
		cursor = "EmptyCursor";
		cursorAim = "missile";
		showAimCursorInternal = 0;
		holdsterAnimValue = 1;
		class Far_AI: RocketPods
		{
			showToPlayer = 0;
			minRange = 2500;
			minRangeProbab = 0.31;
			midRange = 5000;
			midRangeProbab = 0.61;
			maxRange = 7500;
			maxRangeProbab = 0.11;
			displayName = "AM Vehicle Rocket";
			sounds[] = {"StandardSound"};
			class StandardSound {
				begin1[] = {"A3\Sounds_F\weapons\Rockets\new_rocket_7",1.7782794,1.2,1600};
				soundBegin[] = {"begin1",1};
				weaponSoundEffect = "DefaultRifle";
			};
			soundFly[] = {"\A3\Sounds_F\weapons\Rockets\rocket_fly_2",1.0,1.2,700};
			weaponSoundEffect = "DefaultRifle";
			burst = 1;
			reloadTime = 2.0;
			magazineReloadTime = 4.5;
			autoFire = 1;
		};
		class Medium_AI: Far_AI
		{
			minRange = 800;
			minRangeProbab = 0.31;
			midRange = 2000;
			midRangeProbab = 0.71;
			maxRange = 5200;
			maxRangeProbab = 0.31;
			burst = 1;
			reloadTime = 1.2;
		};
		class Close_AI: Far_AI
		{
			minRange = 200;
			minRangeProbab = 0.21;
			midRange = 800;
			midRangeProbab = 0.81;
			maxRange = 1500;
			maxRangeProbab = 0.31;
			reloadTime = 0.7;
			burst = 1;
		};
		class Burst: RocketPods
		{
			displayName = "AM Vehicle Rocket";
			minRange = 1;
			minRangeProbab = 0.001;
			midRange = 2;
			midRangeProbab = 0.001;
			maxRange = 3;
			maxRangeProbab = 0.001;
			burst = 1;
			magazineReloadTime = 4.5;
			reloadTime = 0.8;
			soundContinuous = 0;
			autoFire = 1;
			sounds[] = {"StandardSound"};
			class StandardSound
			{
				begin1[] = {"A3\Sounds_F\weapons\Rockets\new_rocket_7",1.7782794,1.2,1600};
				soundBegin[] = {"begin1",1};
				weaponSoundEffect = "DefaultRifle";
			};
			soundFly[] = {"A3\Sounds_F\weapons\Rockets\rocket_fly_1",1.7782794,1.2,700};
			textureType = "semi";
		};
	};

	// RU
	class owr_ru_w_hmgun: owr_am_w_lgun {
		displayName = "RU Heavy Machine Gun";
		class GunParticles {
			class effect1 {
				positionName = "mainGun1_cloud";
				directionName = "mainGun1_chamber";
				effectName = "MachineGunCloud";
			};
			class effect2 {
				positionName = "mainGun2_cloud";
				directionName = "mainGun2_chamber";
				effectName = "MachineGunCloud";
			};
		};
		magazines[] = {"owr_ru_m_hmgun"};
		magazineReloadTime = 0.15;
		reloadMagazineSound[] = {"A3\sounds_f\dummysound",0.01,1,10};
		class manual: MGun
		{
			displayName = "RU Heavy Machine Gun";
			autoFire = 1;
			reloadTime = 0.01;
			dispersion = 0.00847;
			sounds[] = {"StandardSound"};
			class StandardSound {
				begin1[] = {"A3\sounds_f\weapons\hmg\hmg_gun",1.4125376,1.1,2000};
				soundBegin[] = {"begin1",1};
				weaponSoundEffect = "DefaultRifle";
				closure1[] = {"A3\sounds_f\weapons\closure\sfx7",1.0,1,20};
				closure2[] = {"A3\sounds_f\weapons\closure\sfx8",1.0,1,20};
				soundClosure[] = {"closure1",0.5,"closure2",0.5};
			};
			soundContinuous = 0;
			burst = 2;
			soundBurst = 1;
			minRange = 0;
			minRangeProbab = 0.01;
			midRange = 1;
			midRangeProbab = 0.01;
			maxRange = 2;
			maxRangeProbab = 0.01;
		};
		class close: manual
		{
			burst = 7;
			aiRateOfFire = 1;
			aiRateOfFireDistance = 50;
			minRange = 0;
			minRangeProbab = 0.05;
			midRange = 20;
			midRangeProbab = 0.7;
			maxRange = 50;
			maxRangeProbab = 0.1;
			showToPlayer = 0;
		};
		class short: close
		{
			burst = 6;
			aiRateOfFire = 2;
			aiRateOfFireDistance = 300;
			minRange = 50;
			minRangeProbab = 0.05;
			midRange = 200;
			midRangeProbab = 0.7;
			maxRange = 300;
			maxRangeProbab = 0.1;
		};
		class medium: close
		{
			burst = 5;
			aiRateOfFire = 4;
			aiRateOfFireDistance = 600;
			minRange = 200;
			minRangeProbab = 0.05;
			midRange = 500;
			midRangeProbab = 0.7;
			maxRange = 600;
			maxRangeProbab = 0.1;
		};
		class far: close
		{
			burst = 4;
			aiRateOfFire = 5;
			aiRateOfFireDistance = 1000;
			minRange = 400;
			minRangeProbab = 0.05;
			midRange = 850;
			midRangeProbab = 0.4;
			maxRange = 1100;
			maxRangeProbab = 0.01;
		};
	};
	class owr_ru_w_rgun: owr_am_w_lgun {
		displayName = "RU Minigun";
		class GunParticles {
			class effect1 {
				positionName = "mainGun1_cloud";
				directionName = "mainGun1_chamber";
				effectName = "MachineGunCloud";
			};
			class effect2 {
				positionName = "mainGun2_cloud";
				directionName = "mainGun2_chamber";
				effectName = "MachineGunCloud";
			};
		};
		magazines[] = {"owr_ru_m_rgun"};
		magazineReloadTime = 0.1;
		reloadMagazineSound[] = {"A3\sounds_f\dummysound",0.01,1,10};
		class manual: MGun
		{
			displayName = "RU Minigun";
			autoFire = 1;
			reloadTime = 0.01;
			dispersion = 0.01157;
			sounds[] = {"StandardSound"};
			class StandardSound
			{
				begin1[] = {"A3\Sounds_F\arsenal\weapons_vehicles\LMG_Minigun_65mm\LMG_minigun_65mm_01",1.0,1,2000};
				begin2[] = {"A3\Sounds_F\arsenal\weapons_vehicles\LMG_Minigun_65mm\LMG_minigun_65mm_02",1.0,1.1,2000};
				begin3[] = {"A3\Sounds_F\arsenal\weapons_vehicles\LMG_Minigun_65mm\LMG_minigun_65mm_03",1.0,0.9,2000};
				soundBegin[] = {"begin1",0.33,"begin2",0.33,"begin3",0.34};
				closure1[] = {"A3\sounds_f\weapons\gatling\gatling_rotation_short_2",0.31622776,1,20};
				closure2[] = {"A3\sounds_f\weapons\gatling\gatling_rotation_short_3",0.31622776,1,20};
				soundClosure[] = {"closure1",0.5,"closure2",0.5};
			};
			soundContinuous = 0;
			burst = 2;
			soundBurst = 1;
			minRange = 0;
			minRangeProbab = 0.01;
			midRange = 1;
			midRangeProbab = 0.01;
			maxRange = 2;
			maxRangeProbab = 0.01;
		};
		class close: manual
		{
			burst = 7;
			aiRateOfFire = 1;
			aiRateOfFireDistance = 50;
			minRange = 0;
			minRangeProbab = 0.05;
			midRange = 20;
			midRangeProbab = 0.7;
			maxRange = 50;
			maxRangeProbab = 0.1;
			showToPlayer = 0;
		};
		class short: close
		{
			burst = 6;
			aiRateOfFire = 2;
			aiRateOfFireDistance = 300;
			minRange = 50;
			minRangeProbab = 0.05;
			midRange = 200;
			midRangeProbab = 0.7;
			maxRange = 300;
			maxRangeProbab = 0.1;
		};
		class medium: close
		{
			burst = 5;
			aiRateOfFire = 4;
			aiRateOfFireDistance = 600;
			minRange = 200;
			minRangeProbab = 0.05;
			midRange = 500;
			midRangeProbab = 0.7;
			maxRange = 600;
			maxRangeProbab = 0.1;
		};
		class far: close
		{
			burst = 4;
			aiRateOfFire = 5;
			aiRateOfFireDistance = 1000;
			minRange = 400;
			minRangeProbab = 0.05;
			midRange = 850;
			midRangeProbab = 0.4;
			maxRange = 1100;
			maxRangeProbab = 0.01;
		};
	};
	class owr_ru_w_gun: owr_am_w_lgun {
		displayName = "RU Cannon";
		class GunParticles {
			class effect1 {
				positionName = "mainGun1_cloud";
				directionName = "mainGun1_chamber";
				effectName = "MachineGunCloud";
			};
			class effect2 {
				positionName = "mainGun2_cloud";
				directionName = "mainGun2_chamber";
				effectName = "MachineGunCloud";
			};
		};
		magazines[] = {"owr_ru_m_gun"};
		magazineReloadTime = 0.80;
		reloadMagazineSound[] = {"A3\sounds_f\dummysound",0.01,1,10};
		class manual: MGun
		{
			displayName = "RU Cannon";
			autoFire = 1;
			reloadTime = 0.02;
			dispersion = 0.00547;
			sounds[] = {"StandardSound"};
			class StandardSound {
				begin1[] = {"A3\sounds_f\weapons\hmg\hmg_gun",1.4125376,1.1,2000};
				soundBegin[] = {"begin1",1};
				weaponSoundEffect = "DefaultRifle";
				closure1[] = {"A3\sounds_f\weapons\closure\sfx7",1.0,1,20};
				closure2[] = {"A3\sounds_f\weapons\closure\sfx8",1.0,1,20};
				soundClosure[] = {"closure1",0.5,"closure2",0.5};
			};
			soundContinuous = 0;
			burst = 2;
			soundBurst = 1;
			minRange = 0;
			minRangeProbab = 0.01;
			midRange = 1;
			midRangeProbab = 0.01;
			maxRange = 2;
			maxRangeProbab = 0.01;
		};
		class close: manual
		{
			burst = 7;
			aiRateOfFire = 1;
			aiRateOfFireDistance = 50;
			minRange = 0;
			minRangeProbab = 0.05;
			midRange = 20;
			midRangeProbab = 0.7;
			maxRange = 50;
			maxRangeProbab = 0.1;
			showToPlayer = 0;
		};
		class short: close
		{
			burst = 6;
			aiRateOfFire = 2;
			aiRateOfFireDistance = 300;
			minRange = 50;
			minRangeProbab = 0.05;
			midRange = 200;
			midRangeProbab = 0.7;
			maxRange = 300;
			maxRangeProbab = 0.1;
		};
		class medium: close
		{
			burst = 5;
			aiRateOfFire = 4;
			aiRateOfFireDistance = 600;
			minRange = 200;
			minRangeProbab = 0.05;
			midRange = 500;
			midRangeProbab = 0.7;
			maxRange = 600;
			maxRangeProbab = 0.1;
		};
		class far: close
		{
			burst = 4;
			aiRateOfFire = 5;
			aiRateOfFireDistance = 1000;
			minRange = 400;
			minRangeProbab = 0.05;
			midRange = 850;
			midRangeProbab = 0.4;
			maxRange = 1100;
			maxRangeProbab = 0.01;
		};
	};
	class owr_ru_w_hgun: owr_am_w_lgun {
		displayName = "RU Heavy Cannon";
		class GunParticles {
			class effect1 {
				positionName = "mainGun1_cloud";
				directionName = "mainGun1_chamber";
				effectName = "MachineGunCloud";
			};
			class effect2 {
				positionName = "mainGun2_cloud";
				directionName = "mainGun2_chamber";
				effectName = "MachineGunCloud";
			};
		};
		magazines[] = {"owr_ru_m_hgun"};
		magazineReloadTime = 1.11;
		reloadMagazineSound[] = {"A3\sounds_f\dummysound",0.01,1,10};
		class manual: MGun {
			displayName = "RU Heavy Cannon";
			autoFire = 1;
			reloadTime = 0.01;
			dispersion = 0.00547;
			sounds[] = {"StandardSound"};
			class StandardSound {
				begin1[] = {"A3\Sounds_F\weapons\30mm\30mm_st_02",1.9952624,1,1500};
				soundBegin[] = {"begin1",1};
				weaponSoundEffect = "DefaultRifle";
			};
			soundContinuous = 0;
			burst = 2;
			soundBurst = 1;
			minRange = 0;
			minRangeProbab = 0.01;
			midRange = 1;
			midRangeProbab = 0.01;
			maxRange = 2;
			maxRangeProbab = 0.01;
		};
		class close: manual
		{
			burst = 7;
			aiRateOfFire = 1;
			aiRateOfFireDistance = 50;
			minRange = 0;
			minRangeProbab = 0.05;
			midRange = 20;
			midRangeProbab = 0.7;
			maxRange = 50;
			maxRangeProbab = 0.1;
			showToPlayer = 0;
		};
		class short: close
		{
			burst = 6;
			aiRateOfFire = 2;
			aiRateOfFireDistance = 300;
			minRange = 50;
			minRangeProbab = 0.05;
			midRange = 200;
			midRangeProbab = 0.7;
			maxRange = 300;
			maxRangeProbab = 0.1;
		};
		class medium: close
		{
			burst = 5;
			aiRateOfFire = 4;
			aiRateOfFireDistance = 600;
			minRange = 200;
			minRangeProbab = 0.05;
			midRange = 500;
			midRangeProbab = 0.7;
			maxRange = 600;
			maxRangeProbab = 0.1;
		};
		class far: close
		{
			burst = 4;
			aiRateOfFire = 5;
			aiRateOfFireDistance = 1000;
			minRange = 400;
			minRangeProbab = 0.05;
			midRange = 850;
			midRangeProbab = 0.4;
			maxRange = 1100;
			maxRangeProbab = 0.01;
		};
	};
	class owr_ru_w_vrl: RocketPods {
		displayName = "RU Vehicle Rocket Launcher";
		magazines[] = {"owr_ru_m_vrockets"};
		magazineReloadTime = 4.5;
		modes[] = {"Far_AI","Medium_AI","Close_AI","Burst"};
		canLock = 2;
		weaponLockDelay = 2.0;
		missileLockCone = 5;
		WeaponLockSystem = 4;
		cmImmunity = 0.9;
		cursor = "EmptyCursor";
		cursorAim = "missile";
		showAimCursorInternal = 0;
		holdsterAnimValue = 1;
		class Far_AI: RocketPods
		{
			showToPlayer = 0;
			minRange = 2500;
			minRangeProbab = 0.31;
			midRange = 5000;
			midRangeProbab = 0.61;
			maxRange = 7500;
			maxRangeProbab = 0.11;
			displayName = "RU Vehicle Rocket";
			sounds[] = {"StandardSound"};
			class StandardSound {
				begin1[] = {"A3\Sounds_F\weapons\Rockets\new_rocket_7",1.7782794,1.2,1600};
				soundBegin[] = {"begin1",1};
				weaponSoundEffect = "DefaultRifle";
			};
			soundFly[] = {"\A3\Sounds_F\weapons\Rockets\rocket_fly_2",1.0,1.2,700};
			weaponSoundEffect = "DefaultRifle";
			burst = 1;
			reloadTime = 4.0;
			magazineReloadTime = 4.5;
			autoFire = 1;
		};
		class Medium_AI: Far_AI
		{
			minRange = 800;
			minRangeProbab = 0.31;
			midRange = 2000;
			midRangeProbab = 0.71;
			maxRange = 5200;
			maxRangeProbab = 0.31;
			burst = 1;
			reloadTime = 1.2;
		};
		class Close_AI: Far_AI
		{
			minRange = 200;
			minRangeProbab = 0.21;
			midRange = 800;
			midRangeProbab = 0.81;
			maxRange = 1500;
			maxRangeProbab = 0.31;
			reloadTime = 0.7;
			burst = 1;
		};
		class Burst: RocketPods
		{
			displayName = "RU Vehicle Rocket";
			minRange = 1;
			minRangeProbab = 0.001;
			midRange = 2;
			midRangeProbab = 0.001;
			maxRange = 3;
			maxRangeProbab = 0.001;
			burst = 1;
			magazineReloadTime = 4.5;
			reloadTime = 0.8;
			soundContinuous = 0;
			autoFire = 1;
			sounds[] = {"StandardSound"};
			class StandardSound
			{
				begin1[] = {"A3\Sounds_F\weapons\Rockets\new_rocket_7",1.7782794,1.2,1600};
				soundBegin[] = {"begin1",1};
				weaponSoundEffect = "DefaultRifle";
			};
			soundFly[] = {"A3\Sounds_F\weapons\Rockets\rocket_fly_1",1.7782794,1.2,700};
			textureType = "semi";
		};
	};
	class owr_ru_w_rocket: MissileLauncher {
		displayName = "RU Rocket Launcher";
		minRange = 50;
		minRangeProbab = 0.6;
		midRange = 2000;
		midRangeProbab = 0.9;
		maxRange = 4000;
		maxRangeProbab = 0.1;
		reloadTime = 1;
		magazineReloadTime = 12;
		reloadMagazineSound[] = {"A3\Sounds_F\arsenal\weapons_static\Missile_Launcher\reload_Missile_Launcher",0.8912509,1,10};
		sounds[] = {"StandardSound"};
		class StandardSound
		{
			begin1[] = {"A3\Sounds_F\arsenal\weapons_static\Missile_Launcher\Titan",1.4125376,1,1100};
			soundBegin[] = {"begin1",1};
		};
		soundFly[] = {"A3\Sounds_F\arsenal\weapons_static\Missile_Launcher\rocket_fly",1.0,1.1,700};
		lockingTargetSound[] = {"A3\Sounds_F\arsenal\weapons_static\Missile_Launcher\Locking_Titan",0.56234133,1};
		lockedTargetSound[] = {"A3\Sounds_F\arsenal\weapons_static\Missile_Launcher\Locked_Titan",0.56234133,2.5};
		magazines[] = {"owr_ru_m_rockets"};
		aiRateOfFire = 8.0;
		aiRateOfFireDistance = 4000;
		weaponLockDelay = 3.0;
		textureType = "semi";
	};

};