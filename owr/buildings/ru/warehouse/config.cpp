class CfgPatches {
	class owr_ru_warehouse {
		author = "Sumrak";
		name = "OWR - RU Warehouse";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"warehouse_ru", "ghost_warehouse_ru"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base6c_ru;
	class owr_base0c_ru;
	class warehouse_ru: owr_base6c_ru {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\ru\warehouse\warehouse_ru.p3d";
		ghost = "ghost_warehouse_ru";
		Icon = "\owr\ui\data\buildings\icon_warehouse_ca.paa";

		armor = 50;
		destrType = "DestructDefault";
		threat[] = {0.5, 0.8, 0.5};
		cost = 10;

		mComplx = 8;

		displayName = "RU Warehouse";

		explosionEffect = "owr_buildingexplosion";

		class EventHandlers {
			init = "_this execVM ""\owr\scripts\statemachines\buildings\warehouse\warehouse.sqf"";";
		};
	};
	class ghost_warehouse_ru: owr_base0c_ru {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\ru\warehouse\ghost_warehouse_ru.p3d";
		displayName = "RU Depot (ghost)";
	};
};