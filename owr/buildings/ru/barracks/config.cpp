class CfgPatches {
	class owr_ru_barracks {
		author = "Sumrak";
		name = "OWR - RU Barracks";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"barracks_ru", "ghost_barracks_ru"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base0c_ru;
	class owr_base6c_ru;
	class barracks_ru: owr_base6c_ru {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\ru\barracks\barracks_ru.p3d";
		Icon = "\owr\ui\data\buildings\icon_barracks_ca.paa";

		ghost = "ghost_barracks_ru";

		mComplx = 5;

		armor = 30;
		destrType = "DestructDefault";
		threat[] = {1.0, 1.0, 0.5};
		cost = 10;

		displayName = "RU Barracks";

		class EventHandlers {};
	};
	class ghost_barracks_ru: owr_base0c_ru {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\ru\barracks\ghost_barracks_ru.p3d";
		displayName = "RU Barracks (ghost)";
	};
};