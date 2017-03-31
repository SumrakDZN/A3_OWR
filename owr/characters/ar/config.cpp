class CfgPatches {
	class owr_ar_characters {
		author = "Sumrak";
		name = "OWR - AR Characters";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"owr_man_ar"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_manbase;
	class owr_man_ar: owr_manbase {
		scope = 2;
		side = 2;
		faction = owr_ar;
		displayName = "AR personnel";

		uniformClass = "U_I_CombatUniform";
		model = "\A3\Characters_F_Beta\INDEP\ia_soldier_01.p3d";
	};
};