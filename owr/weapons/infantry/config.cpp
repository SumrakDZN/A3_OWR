class CfgPatches {
	class owr_weapons_infantry {
		author = "Sumrak";
		name = "OWR - Weapons for Infantry";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"A3_Weapons_F", "A3_Weapons_F_Exp"};
		requiredVersion = 0.1;
		units[] = {};
		weapons[] = {};
	};
};

// place for infantry weapons
/*
	ideas

	utilize size of the map = mortar
*/

class CfgAmmo {
	// rifle ammo
	class BulletBase;
	class B_762x51_Ball: BulletBase {
		hit = 32;	// 12
	};
	class B_556x45_Ball: BulletBase {
		hit = 30;	// 8
	};
	class B_65x39_Caseless: BulletBase {
		hit = 30;	// 10 
	};
	class B_408_Ball: BulletBase {
		hit = 48;	// 24 and was 0.008
	};
	class B_127x108_Ball: BulletBase {
		hit = 55; 	// 35
	};
	class B_9x21_Ball: BulletBase {
		hit = 18;	// 4
	};
	class B_762x39_Ball_F: BulletBase {
		hit = 32;	// 11
	};

	// greandes
	class Grenade;
	class GrenadeHand: Grenade {
		hit = 40;			// 8
		indirectHit = 26; 	// 8
	};

	// launchers
	class RocketBase;
	class R_PG32V_F: RocketBase {
		hit = 300;
		indirectHit = 225;
	};
};