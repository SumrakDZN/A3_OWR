class CfgPatches {
	class owr_ru_control_tower {
		author = "Sumrak";
		name = "OWR - RU Control Tower";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data", "owr_ru_warehouse"};
		requiredVersion = 0.1;
		units[] = {"control_tower_ru", "ghost_control_tower_ru"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class warehouse_ru;
	class owr_base0c_ru;
	class control_tower_ru: warehouse_ru {
		model = "owr\buildings\ru\control_tower\control_tower_ru.p3d";
		ghost = "ghost_control_tower_ru";
		Icon = "\owr\ui\data\buildings\icon_control_tower_ca.paa";
		displayName = "RU Control Tower";
	};
	class ghost_control_tower_ru: owr_base0c_ru {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\ru\control_tower\ghost_control_tower_ru.p3d";
		displayName = "RU Control Tower (ghost)";
	};
};