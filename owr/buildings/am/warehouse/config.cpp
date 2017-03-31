class CfgPatches {
	class owr_am_warehouse {
		author = "Sumrak";
		name = "OWR - AM Warehouse";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"warehouse_am", "ghost_warehouse_am"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base6c_am;
	class owr_base0c_am;
	class warehouse_am: owr_base6c_am {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\am\warehouse\warehouse_am.p3d";
		ghost = "ghost_warehouse_am";
		Icon = "\owr\ui\data\buildings\icon_warehouse_ca.paa";

		armor = 50;
		destrType = "DestructDefault";
		threat[] = {0.5, 0.8, 0.5};
		cost = 10;

		mComplx = 8;

		displayName = "AM Warehouse";

		explosionEffect = "owr_buildingexplosion";

		class EventHandlers {
			init = "_this execVM ""\owr\scripts\statemachines\buildings\warehouse\warehouse.sqf"";";
		};
	};
	class ghost_warehouse_am: owr_base0c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\warehouse\ghost_warehouse_am.p3d";
		displayName = "AM Depot (ghost)";
	};
};