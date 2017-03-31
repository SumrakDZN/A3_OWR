class CfgPatches {
	class owr_ru_power_oil {
		author = "Sumrak";
		name = "OWR - RU Power Oil";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"power_oil_ru", "ghost_power_oil_ru"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base0c_ru;
	class power_oil_ru: owr_base0c_ru {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\ru\power_oil\power_oil_ru.p3d";
		ghost = "ghost_power_oil_ru";
		Icon = "\owr\ui\data\buildings\icon_poil_ca.paa";

		armor = 100;
		destrType = "DestructDefault";
		threat[] = {0.3, 0.3, 0.5};
		cost = 5;

		mComplx = 4.0;

		displayName = "RU Power Oil";
		
		explosionEffect = "owr_buildingexplosion";
	};
	class ghost_power_oil_ru: owr_base0c_ru {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\ru\power_oil\ghost_power_oil_ru.p3d";
		displayName = "RU Power Oil (ghost)";
	};
};