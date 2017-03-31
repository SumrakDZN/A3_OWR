class CfgPatches {
	class owr_ru_factory {
		author = "Sumrak";
		name = "OWR - RU Factory";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"factory_ru", "ghost_factory_ru"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base6c_ru;
	class owr_base0c_ru;
	class factory_ru: owr_base6c_ru {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\ru\factory\factory_ru.p3d";
		ghost = "ghost_factory_ru";
		Icon = "\owr\ui\data\buildings\icon_factory_ca.paa";

		armor = 10;
		destrType = "DestructDefault";
		threat[] = {0.5, 0.8, 0.5};
		cost = 5;

		mComplx = 10;

		displayName = "RU Factory";
	};
	class ghost_factory_ru: owr_base0c_ru {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\ru\factory\ghost_factory_ru.p3d";
		displayName = "RU Factory (ghost)";
	};
};