class CfgPatches {
	class owr_ru_source_oil {
		author = "Sumrak";
		name = "OWR - RU Source Oil";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"source_oil_ru", "ghost_source_oil_ru"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base0c_ru;
	class source_oil_ru: owr_base0c_ru {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\ru\source_oil\source_oil_ru.p3d";
		ghost = "ghost_source_oil_ru";
		Icon = "\owr\ui\data\buildings\icon_soil_ca.paa";

		armor = 100;
		destrType = "DestructDefault";
		threat[] = {0.1, 0.2, 0.5};
		cost = 2;

		displayName = "RU Oil Drill";

		mComplx = 4.0;

		explosionEffect = "owr_buildingexplosion";
	};
	class ghost_source_oil_ru: owr_base0c_ru {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\ru\source_oil\ghost_source_oil_ru.p3d";
		displayName = "RU Source Oil (ghost)";
	};
};