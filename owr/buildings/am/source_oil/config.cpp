class CfgPatches {
	class owr_am_source_oil {
		author = "Sumrak";
		name = "OWR - AM Source Oil";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"source_oil_am", "ghost_source_oil_am"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base0c_am;
	class source_oil_am: owr_base0c_am {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\am\source_oil\source_oil_am.p3d";
		ghost = "ghost_source_oil_am";
		Icon = "\owr\ui\data\buildings\icon_soil_ca.paa";

		displayName = "AM Oil Drill";

		armor = 100;
		destrType = "DestructDefault";
		threat[] = {0.1, 0.2, 0.5};
		cost = 2;

		mComplx = 4.0;

		explosionEffect = "owr_buildingexplosion";

		class EventHandlers {
			// (_this select 0): the vehicle
			// """" Random texture source (pick one from the property textureList[])
			// []: randomize the animation sources (accordingly to the property animationList[])
			// false: Don't change the mass even if an animation source has a defined mass
			//init = "if (local (_this select 0)) then {[(_this select 0), """", [], false] call bis_fnc_initVehicle;};";
		};
	};
	class ghost_source_oil_am: owr_base0c_am {
		scope = 1;
		scopeCurator = 0;
		model = "owr\buildings\am\source_oil\ghost_source_oil_am.p3d";
		displayName = "AM Source Oil (ghost)";
	};
};