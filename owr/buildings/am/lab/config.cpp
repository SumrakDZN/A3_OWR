class CfgPatches {
	class owr_am_lab {
		author = "Sumrak";
		name = "OWR - AM Laboratory";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"lab_am", "ghost_lab_am"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base6c_am;
	class owr_base0c_am;
	class lab_am: owr_base6c_am {
		scope = 2;
		scopeCurator = 2;
		Icon = "\owr\ui\data\buildings\icon_lab_ca.paa";
		model = "owr\buildings\am\lab\lab_am.p3d";
		ghost = "ghost_lab_am";
		displayName = "AM Laboratory";

		armor = 50;
		destrType = "DestructDefault";
		threat[] = {0.5, 0.8, 0.5};
		cost = 5;

		mComplx = 6.7;

		faction	= "owr_am";
	};
	class ghost_lab_am: owr_base0c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\lab\ghost_lab_am.p3d";
		displayName = "AM Laboratory (ghost)";
	};
};