class CfgPatches {
	class owr_am_source_sib {
		author = "Sumrak";
		name = "OWR - AM Source Siberite";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"source_sib_am", "ghost_source_sib_am"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base0c_am;
	class source_sib_am: owr_base0c_am {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\am\source_sib\source_sib_am.p3d";
		ghost = "ghost_source_sib_am";
		Icon = "\owr\ui\data\buildings\icon_ssib_ca.paa";

		displayName = "AM Siberite Mine";

		armor = 120;
		destrType = "DestructDefault";
		threat[] = {0.1, 0.2, 0.5};
		cost = 2;

		mComplx = 5.0;

		class EventHandlers {
			// (_this select 0): the vehicle
			// """" Random texture source (pick one from the property textureList[])
			// []: randomize the animation sources (accordingly to the property animationList[])
			// false: Don't change the mass even if an animation source has a defined mass
			//init = "if (local (_this select 0)) then {[(_this select 0), """", [], false] call bis_fnc_initVehicle;};";
		};
	};
	class ghost_source_sib_am: owr_base0c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\source_sib\ghost_source_sib_am.p3d";
		displayName = "AM Source Sib (ghost)";
	};
};