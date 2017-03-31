class CfgPatches {
	class owr_am_aturrets {
		author = "Sumrak";
		name = "OWR - AM Automatic Turrets";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"aturret_am", "ghost_aturret_am", "owr_am_aturret_rgun", "owr_am_aturret_mgun", "owr_am_aturret_lgun", "owr_am_aturret_dgun", "owr_am_aturret_hgun", "owr_am_aturret_rlan", "owr_am_aturret_laser", "owr_am_aturret_dlaser"};
		weapons[] = {};
	};
};

class RCWSOptics;
class WeaponCloudsMGun;

class CfgVehicles {
	// base aturret, logic behind turret, once completed, it can be "upgraded" into weapon version
	class owr_base0c_am;
	class aturret_am: owr_base0c_am {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\am\auto_turret\aturret_am.p3d";
		Icon = "\owr\ui\data\buildings\icon_turret_auto_ca.paa";

		mComplx = 3.5;

		ghost = "ghost_aturret_am";

		displayName = "AM Automatic Turret";

		class EventHandlers {};
	};
	class ghost_aturret_am: owr_base0c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\auto_turret\ghost_aturret_am.p3d";
		displayName = "AM ATurret (ghost)";
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
	class owr_base1c_am: owr_base1c {
		side = 1;
		faction	= "owr_am";

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


	// actual weapon turrets

	class owr_am_aturret_rgun: owr_base1c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\auto_turret\aturret_rgun_am.p3d";
		Icon = "\owr\ui\data\buildings\icon_turret_auto_ca.paa";

		displayName = "AM ATurret rgun";
		crew = "B_UAV_AI";
		typicalCargo[] = {"B_UAV_AI"};

		mComplx = 1.5;

		class AnimationSources : AnimationSources {
			delete recoil_source;
			class muzzle_rot: muzzle_rot {
				weapon = "owr_am_w_rgun";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_am_w_rgun";
			};
			class minigun {
				source = "revolving";
				weapon = "owr_am_w_rgun";
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
				weapons[] = {"owr_am_w_rgun"};
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
	};
	class owr_am_aturret_mgun: owr_base1c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\auto_turret\aturret_mgun_am.p3d";
		Icon = "\owr\ui\data\buildings\icon_turret_auto_ca.paa";

		displayName = "AM ATurret mgun";
		crew = "B_UAV_AI";
		typicalCargo[] = {"B_UAV_AI"};

		mComplx = 1.0;

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

		class Turrets: Turrets {
			class MainTurret: NewTurret {
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
	};
	class owr_am_aturret_lgun: owr_base1c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\auto_turret\aturret_lgun_am.p3d";
		Icon = "\owr\ui\data\buildings\icon_turret_auto_ca.paa";

		displayName = "AM ATurret lgun";
		crew = "B_UAV_AI";
		typicalCargo[] = {"B_UAV_AI"};

		mComplx = 1.75;

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

		class Turrets: Turrets {
			class MainTurret: NewTurret {
				body = "MainTurret";
				gun = "MainGun";
				animationSourceGun = "mainGun";
				animationSourceHatch = "";
				gunBeg = "mainGunMuzzle";
				gunEnd = "mainGunChamber";
				weapons[] = {"owr_am_w_lgun"};
				magazines[] = {"owr_am_m_lgun"};
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
	};
	class owr_am_aturret_dgun: owr_base1c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\auto_turret\aturret_dgun_am.p3d";
		Icon = "\owr\ui\data\buildings\icon_turret_auto_ca.paa";

		displayName = "AM ATurret dgun";
		crew = "B_UAV_AI";
		typicalCargo[] = {"B_UAV_AI"};

		mComplx = 2.5;

		class AnimationSources : AnimationSources {
			class recoil_source: recoil_source {
				weapon = "owr_am_w_dgun";
			};
			class muzzle_rot: muzzle_rot {
				weapon = "owr_am_w_dgun";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_am_w_dgun";
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
				weapons[] = {"owr_am_w_dgun"};
				magazines[] = {"owr_am_m_dgun"};
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
			fired = "(_this select 0) addMagazineTurret ['owr_am_m_dgun',[0],2];";
		};
	};
	class owr_am_aturret_hgun: owr_base1c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\auto_turret\aturret_hgun_am.p3d";
		Icon = "\owr\ui\data\buildings\icon_turret_auto_ca.paa";

		displayName = "AM ATurret hgun";
		crew = "B_UAV_AI";
		typicalCargo[] = {"B_UAV_AI"};

		mComplx = 3.5;

		class AnimationSources : AnimationSources {
			class recoil_source: recoil_source {
				weapon = "owr_am_w_hgun";
			};
			class muzzle_rot: muzzle_rot {
				weapon = "owr_am_w_hgun";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_am_w_hgun";
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
				weapons[] = {"owr_am_w_hgun"};
				magazines[] = {"owr_am_m_hgun"};
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
	};
	class owr_am_aturret_rlan: owr_base1c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\auto_turret\aturret_rlan_am.p3d";
		Icon = "\owr\ui\data\buildings\icon_turret_auto_ca.paa";

		displayName = "AM ATurret rlan";
		crew = "B_UAV_AI";
		typicalCargo[] = {"B_UAV_AI"};

		mComplx = 3.0;

		// couldnt get it working with any other names for these (targeting system wasnt working) along with unique memory points
		memoryPointMissile[] = {"spice rakety","usti hlavne"};
		memoryPointMissileDir[] = {"konec rakety","konec hlavne"};

		class AnimationSources : AnimationSources {
			delete recoil_source;
			delete muzzle_rot;
			class Missiles_revolving {
				source = "revolving";
				weapon = "owr_am_w_vrl";
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
				weapons[] = {"owr_am_w_vrl"};
				magazines[] = {"owr_am_m_vrockets"};
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
			fired = "(_this select 0) addMagazineTurret ['owr_am_m_vrockets',[0],8];";
		};
	};
	class owr_am_aturret_laser: owr_base1c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\auto_turret\aturret_laser_am.p3d";
		Icon = "\owr\ui\data\buildings\icon_turret_auto_ca.paa";

		displayName = "AM ATurret laser";
		crew = "B_UAV_AI";
		typicalCargo[] = {"B_UAV_AI"};

		mComplx = 3.5;

		class AnimationSources : AnimationSources {
			class recoil_source: recoil_source {
				weapon = "owr_am_w_laser";
			};
			class muzzle_rot: muzzle_rot {
				weapon = "owr_am_w_laser";
			};
			class muzzle_hide: muzzle_hide {
				weapon = "owr_am_w_laser";
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
				weapons[] = {"owr_am_w_laser"};
				magazines[] = {"owr_am_m_laser"};
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
	};
	class owr_am_aturret_dlaser: owr_base1c_am {

	};
};