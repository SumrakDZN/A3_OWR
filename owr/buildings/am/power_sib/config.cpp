class CfgPatches {
	class owr_am_power_sib {
		author = "Sumrak";
		name = "OWR - AM Power Siberite";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"power_sib_am", "ghost_power_sib_am"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base0c_am;
	class power_sib_am: owr_base0c_am {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\am\power_sib\power_sib_am.p3d";
		ghost = "ghost_power_sib_am";
		Icon = "\owr\ui\data\buildings\icon_psib_ca.paa";

		displayName = "AM Power Siberite";

		mComplx = 5.5;

		armor = 130;
		destrType = "DestructDefault";
		threat[] = {0.3, 0.3, 0.5};
		cost = 5;
	};
	class ghost_power_sib_am: owr_base0c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\power_sib\ghost_power_sib_am.p3d";
		displayName = "AM Power Siberite (ghost)";
	};
};