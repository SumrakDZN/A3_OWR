class CfgPatches {
	class owr_ru_aturrets {
		author = "Sumrak";
		name = "OWR - RU Automatic Turrets";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"aturret_ru"};
		weapons[] = {};
	};
};

class RCWSOptics;
class WeaponCloudsMGun;

class CfgVehicles {
	// base aturret, logic behind turret, once completed, it can be "upgraded" into weapon version
	class owr_base0c_ru;
	class aturret_ru: owr_base0c_ru {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\ru\aturret\aturret_ru.p3d";
		Icon = "\owr\ui\data\buildings\icon_turret_auto_ca.paa";

		mComplx = 3.5;

		ghost = "ghost_aturret_ru";

		displayName = "RU Automatic Turret";

		class EventHandlers {};
	};
	class ghost_aturret_ru: owr_base0c_ru {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\ru\aturret\ghost_aturret_ru.p3d";
		displayName = "RU ATurret (ghost)";
	};




	class Land;
	class LandVehicle: Land {
		class ViewPilot;
		class NewTurret;
	};
	class StaticWeapon: LandVehicle {
	};
	class owr_base1c: StaticWeapon {
		class EventHandlers;
		class AnimationSources {
			class recoil_source;
			class muzzle_rot;
			class muzzle_hide;
		};
		class Turrets {
			class MainTurret: NewTurret {
				class ViewOptics;
			};
		};
	};
	class owr_base1c_ru: owr_base1c {
		side = 1;
		faction	= "owr_ru";

		armor = 150;
		destrType = "DestructDefault";
		threat[] = {1.0, 1.0, 0.5};
		cost = 10;
		audible = 6;
		camouflage = 8;
		accuracy = 0.5;

		class AnimationSources: AnimationSources {
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
	};


	class owr_ru_aturret_hmgun: owr_base1c_ru {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\ru\aturret\aturret_hmgun_ru.p3d";
		Icon = "\owr\ui\data\buildings\icon_turret_auto_ca.paa";

		displayName = "RU ATurret hmgun";
		crew = "O_UAV_AI";
		typicalCargo[] = {"O_UAV_AI"};

		mComplx = 1.75;

		class AnimationSources : AnimationSources {
			class recoil_source: recoil_source {
				weapon = "owr_ru_w_hmgun";
			};
			class muzzle_rot: muzzle_rot {
				weapon = "owr_ru_w_hmgun";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_ru_w_hmgun";
			};
		};

		class Turrets: Turrets {
			class MainTurret: NewTurret {
				body = "MainTurret";
				gun = "MainGun";
				animationSourceGun = "mainGun";
				animationSourceHatch = "";
				gunBeg = "mainGunMuzzle";
				gunEnd = "mainGunChamber";
				weapons[] = {"owr_ru_w_hmgun"};
				magazines[] = {"owr_ru_m_hmgun"};
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
				memoryPointGun[] = {"mainGun1_muzzle","mainGun2_muzzle"};
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

		class EventHandlers: EventHandlers {
			fired = "(_this select 0) addMagazineTurret ['owr_ru_m_hmgun',[0],2];";
		};
	};

	class owr_ru_aturret_rgun: owr_base1c_ru {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\ru\aturret\aturret_rgun_ru.p3d";
		Icon = "\owr\ui\data\buildings\icon_turret_auto_ca.paa";

		displayName = "RU ATurret rgun";
		crew = "O_UAV_AI";
		typicalCargo[] = {"O_UAV_AI"};

		mComplx = 2.0;

		class AnimationSources : AnimationSources {
			delete recoil_source;
			class muzzle_rot: muzzle_rot {
				weapon = "owr_ru_w_rgun";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_ru_w_rgun";
			};
		};

		class Turrets: Turrets {
			class MainTurret: NewTurret {
				body = "MainTurret";
				gun = "MainGun";
				animationSourceGun = "mainGun";
				animationSourceHatch = "";
				gunBeg = "mainGunMuzzle";
				gunEnd = "mainGunChamber";
				weapons[] = {"owr_ru_w_rgun"};
				magazines[] = {"owr_ru_m_rgun"};
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
				memoryPointGun[] = {"mainGun1_muzzle","mainGun2_muzzle"};
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

		class EventHandlers: EventHandlers {
			fired = "(_this select 0) addMagazineTurret ['owr_ru_m_rgun',[0],2];";
		};
	};

	class owr_ru_aturret_gun: owr_base1c_ru {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\ru\aturret\aturret_gun_ru.p3d";
		Icon = "\owr\ui\data\buildings\icon_turret_auto_ca.paa";

		displayName = "RU ATurret gun";
		crew = "O_UAV_AI";
		typicalCargo[] = {"O_UAV_AI"};

		mComplx = 2.75;

		class AnimationSources : AnimationSources {
			class recoil_source: recoil_source {
				weapon = "owr_ru_w_gun";
			};
			class muzzle_rot: muzzle_rot {
				weapon = "owr_ru_w_gun";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_ru_w_gun";
			};
		};

		class Turrets: Turrets {
			class MainTurret: NewTurret {
				body = "MainTurret";
				gun = "MainGun";
				animationSourceGun = "mainGun";
				animationSourceHatch = "";
				gunBeg = "mainGunMuzzle";
				gunEnd = "mainGunChamber";
				weapons[] = {"owr_ru_w_gun"};
				magazines[] = {"owr_ru_m_gun"};
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
				memoryPointGun[] = {"mainGun1_muzzle","mainGun2_muzzle"};
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

		class EventHandlers: EventHandlers {
			fired = "(_this select 0) addMagazineTurret ['owr_ru_m_gun',[0],2];";
		};
	};

	class owr_ru_aturret_hgun: owr_base1c_ru {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\ru\aturret\aturret_hgun_ru.p3d";
		Icon = "\owr\ui\data\buildings\icon_turret_auto_ca.paa";

		displayName = "RU ATurret hgun";
		crew = "O_UAV_AI";
		typicalCargo[] = {"O_UAV_AI"};

		mComplx = 3.75;

		class AnimationSources : AnimationSources {
			class recoil_source: recoil_source {
				weapon = "owr_ru_w_hgun";
			};
			class muzzle_rot: muzzle_rot {
				weapon = "owr_ru_w_hgun";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_ru_w_hgun";
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
				weapons[] = {"owr_ru_w_hgun"};
				magazines[] = {"owr_ru_m_hgun"};
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
				memoryPointGun[] = {"mainGun1_muzzle","mainGun2_muzzle"};
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

		class EventHandlers: EventHandlers {
			fired = "(_this select 0) addMagazineTurret ['owr_ru_m_hgun',[0],2];";
		};
	};
	class owr_ru_aturret_rlan: owr_base1c_ru {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\ru\aturret\aturret_rlan_ru.p3d";
		Icon = "\owr\ui\data\buildings\icon_turret_auto_ca.paa";

		displayName = "RU ATurret rlan";
		crew = "O_UAV_AI";
		typicalCargo[] = {"O_UAV_AI"};

		mComplx = 3.5;

		// couldnt get it working with any other names for these (targeting system wasnt working) along with unique memory points
		memoryPointMissile[] = {"spice rakety","usti hlavne"};
		memoryPointMissileDir[] = {"konec rakety","konec hlavne"};

		class AnimationSources : AnimationSources {
			delete recoil_source;
			delete muzzle_rot;
			class Missiles_revolving {
				source = "revolving";
				weapon = "owr_ru_w_vrl";
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
				weapons[] = {"owr_ru_w_vrl"};
				magazines[] = {"owr_ru_m_vrockets"};
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
				missileBeg = "mainGunMuzzle";
				missileEnd = "mainGunChamber";
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

		class EventHandlers: EventHandlers {
			fired = "(_this select 0) addMagazineTurret ['owr_ru_m_vrockets',[0],8];";
		};
	};
};