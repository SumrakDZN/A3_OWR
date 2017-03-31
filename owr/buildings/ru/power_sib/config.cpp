class CfgPatches {
	class owr_ru_power_sib {
		author = "Sumrak";
		name = "OWR - RU Power Siberite";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"power_sib_ru", "ghost_power_sib_ru"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base0c_ru;
	class power_sib_ru: owr_base0c_ru {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\ru\power_sib\power_sib_ru.p3d";
		ghost = "ghost_power_sib_ru";
		Icon = "\owr\ui\data\buildings\icon_psib_ca.paa";

		armor = 135;
		destrType = "DestructDefault";
		threat[] = {0.3, 0.3, 0.5};
		cost = 5;

		mComplx = 5.5;

		displayName = "RU Power Siberite";
	};
	class ghost_power_sib_ru: owr_base0c_ru {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\ru\power_sib\ghost_power_sib_ru.p3d";
		displayName = "RU Power Siberite (ghost)";
	};
};