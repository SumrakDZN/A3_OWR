class CfgPatches {
	class owr_am_power_oil {
		author = "Sumrak";
		name = "OWR - AM Power Oil";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"power_oil_am", "ghost_power_oil_am"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base0c_am;
	class power_oil_am: owr_base0c_am {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\am\power_oil\power_oil_am.p3d";
		ghost = "ghost_power_oil_am";
		Icon = "\owr\ui\data\buildings\icon_poil_ca.paa";

		displayName = "AM Power Oil";

		mComplx = 4.5;

		armor = 110;
		destrType = "DestructDefault";
		threat[] = {0.3, 0.3, 0.5};
		cost = 5;

		explosionEffect = "owr_buildingexplosion";
	};
	class ghost_power_oil_am: owr_base0c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\power_oil\ghost_power_oil_am.p3d";
		displayName = "AM Power Oil (ghost)";
	};
};