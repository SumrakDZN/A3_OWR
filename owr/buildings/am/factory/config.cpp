class CfgPatches {
	class owr_am_factory {
		author = "Sumrak";
		name = "OWR - AM Factory";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"factory_am", "ghost_factory_am"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base6c_am;
	class owr_base0c_am;
	class factory_am: owr_base6c_am {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\am\factory\factory_am.p3d";
		ghost = "ghost_factory_am";
		Icon = "\owr\ui\data\buildings\icon_factory_ca.paa";

		armor = 10;
		destrType = "DestructDefault";
		threat[] = {0.5, 0.8, 0.5};
		cost = 5;

		mComplx = 10;

		displayName = "AM Factory";

		class EventHandlers {
			//init = "_this execVM ""\owr\scripts\statemachines\buildings\factory\factory_am.sqf"";";
		};
	};
	class ghost_factory_am: owr_base0c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\factory\ghost_factory_am.p3d";
		displayName = "AM Factory (ghost)";
	};
};