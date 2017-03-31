class CfgPatches {
	class owr_chracters_gear_backpacks {
		author = "Sumrak";
		name = "OWR - Gear Backpacks";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {};
		weapons[] = {};
	};
};

class CfgVehicles {
	class Bag_Base;
	class owr_backpack_crate_full: Bag_Base {
        	author = "Sumrak";
        	scope = 2;
        	model = "\owr\characters\gear\backpacks\backpack_crate_full.p3d";
        	displayName = "Backpack with supply crates";
        	picture = "\A3\weapons_f\ammoboxes\bags\data\ui\icon_B_C_Compact_dgtl_ca.paa";
        	maximumLoad = 0;
        	mass = 30;
    	};
	class owr_backpack_crate_empty: Bag_Base {
        	author = "Sumrak";
        	scope = 2;
        	model = "\owr\characters\gear\backpacks\backpack_crate_empty.p3d";
        	displayName = "Backpack for supply crates";
        	picture = "\A3\weapons_f\ammoboxes\bags\data\ui\icon_B_C_Compact_dgtl_ca.paa";
        	maximumLoad = 0;
        	mass = 5;
    	};
};