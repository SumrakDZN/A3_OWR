class CfgPatches {
	class owr_ru_source_sib {
		author = "Sumrak";
		name = "OWR - RU Source Siberite";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"source_sib_ru", "ghost_source_sib_ru"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base0c_ru;
	class source_sib_ru: owr_base0c_ru {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\ru\source_sib\source_sib_ru.p3d";
		ghost = "ghost_source_sib_ru";
		Icon = "\owr\ui\data\buildings\icon_ssib_ca.paa";

		armor = 120;
		destrType = "DestructDefault";
		threat[] = {0.1, 0.2, 0.5};
		cost = 2;

		mComplx = 5.0;

		displayName = "RU Siberite Mine";
	};
	class ghost_source_sib_ru: owr_base0c_ru {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\ru\source_sib\ghost_source_sib_ru.p3d";
		displayName = "RU Source Sib (ghost)";
	};
};