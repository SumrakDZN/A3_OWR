class CfgPatches {
	class owr_ru_characters {
		author = "Sumrak";
		name = "OWR - RU Characters";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"owr_man_ru"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_manbase;
	class owr_man_ru: owr_manbase {
		scope = 2;
		side = 0;
		faction = owr_ru;
		displayName = "RU personnel";
		
		uniformClass = "U_O_CombatUniform_ocamo";
		model = "\A3\characters_F\OPFOR\o_soldier_01.p3d";

	  	class eventHandlers {
	    	//init = "(_this select 0) addPrimaryWeaponItem ""optic_mas_Holosight_camo"";";
	    };
	};
};