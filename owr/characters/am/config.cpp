class CfgPatches {
	class owr_am_characters {
		author = "Sumrak";
		name = "OWR - AM Characters";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"owr_man_am"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_manbase;
	class owr_man_am: owr_manbase {
		scope = 2;
		side = 1;
		faction = owr_am;
		displayName = "AM personnel";
		
	  	class eventHandlers {
	    		//init = "(_this select 0) addPrimaryWeaponItem ""optic_mas_Holosight_camo"";";
		};
	};
};