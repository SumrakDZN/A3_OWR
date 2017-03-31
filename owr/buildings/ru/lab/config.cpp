class CfgPatches {
	class owr_ru_lab {
		author = "Sumrak";
		name = "OWR - RU Laboratory";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"lab_ru", "ghost_lab_ru"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base6c_ru;
	class owr_base0c_ru;
	class lab_ru: owr_base6c_ru {
		scope = 2;
		scopeCurator = 2;
		Icon = "\owr\ui\data\buildings\icon_lab_ca.paa";
		model = "owr\buildings\ru\lab\lab_ru.p3d";
		ghost = "ghost_lab_ru";
		displayName = "RU Laboratory";

		armor = 50;
		destrType = "DestructDefault";
		threat[] = {0.5, 0.8, 0.5};
		cost = 5;

		mComplx = 6.7;
	};
	class ghost_lab_ru: owr_base0c_ru {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\ru\lab\ghost_lab_ru.p3d";
		displayName = "RU Laboratory (ghost)";
	};
};