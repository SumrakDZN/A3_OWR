class CfgPatches {
	class owr_am_power_sol {
		author = "Sumrak";
		name = "OWR - AM Power Solar";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"power_sol_am", "ghost_power_sol_am"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base0c_am;
	class power_sol_am: owr_base0c_am {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\am\power_sol\power_sol_am.p3d";
		ghost = "ghost_power_sol_am";
		Icon = "\owr\ui\data\buildings\icon_psol_ca.paa";

		displayName = "AM Power Solar";

		mComplx = 4.5;

		armor = 100;
		destrType = "DestructDefault";
		threat[] = {0.3, 0.3, 0.5};
		cost = 5;
	};
	class ghost_power_sol_am: owr_base0c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\power_sol\ghost_power_sol_am.p3d";
		displayName = "AM Power Solar (ghost)";
	};
};