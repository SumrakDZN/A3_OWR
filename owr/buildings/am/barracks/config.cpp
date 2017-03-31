class CfgPatches {
	class owr_am_barracks {
		author = "Sumrak";
		name = "OWR - AM Barracks";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"barracks_am", "ghost_barracks_am"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base0c_am;
	class owr_base6c_am;
	class barracks_am: owr_base6c_am {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\am\barracks\barracks_am.p3d";
		Icon = "\owr\ui\data\buildings\icon_barracks_ca.paa";

		ghost = "ghost_barracks_am";

		armor = 50;
		destrType = "DestructDefault";
		threat[] = {1.0, 1.0, 0.5};
		cost = 10;

		mComplx = 5;

		displayName = "AM Barracks";

		class EventHandlers {};
	};
	class ghost_barracks_am: owr_base0c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\barracks\ghost_barracks_am.p3d";
		displayName = "AM Barracks (ghost)";
	};
};