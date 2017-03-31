class CfgPatches {
	class owr_am_control_tower {
		author = "Sumrak";
		name = "OWR - AM Control Tower";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data", "owr_am_warehouse"};
		requiredVersion = 0.1;
		units[] = {"control_tower_am", "ghost_control_tower_am"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class warehouse_am;
	class owr_base0c_am;
	class control_tower_am: warehouse_am {
		model = "owr\buildings\am\control_tower\control_tower_am.p3d";
		ghost = "ghost_control_tower_am";
		Icon = "\owr\ui\data\buildings\icon_control_tower_ca.paa";
		displayName = "AM Control Tower";
	};
	class ghost_control_tower_am: owr_base0c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\control_tower\ghost_control_tower_am.p3d";
		displayName = "AM Control Tower (ghost)";
	};
};