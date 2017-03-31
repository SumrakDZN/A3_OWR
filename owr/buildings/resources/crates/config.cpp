class CfgPatches {
	class owr_resources_crates {
		author = "Sumrak";
		name = "OWR - Resources";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"owr_crates_pile_1", "owr_crates_pile_2", "owr_crates_pile_3", "owr_crates_pile_4", "owr_crates_pile_5"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base0c;
	class owr_crates_pile_1: owr_base0c {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\resources\crates\crates_pile_1.p3d";
		Icon = "\owr\ui\data\icon_resource_crates_ca.paa";
		displayName = "Pile of crates from the future";
	};
	class owr_crates_pile_2: owr_base0c {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\resources\crates\crates_pile_2.p3d";
		Icon = "\owr\ui\data\icon_resource_crates_ca.paa";
		displayName = "Pile of crates from the future";
	};
	class owr_crates_pile_3: owr_base0c {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\resources\crates\crates_pile_3.p3d";
		Icon = "\owr\ui\data\icon_resource_crates_ca.paa";
		displayName = "Pile of crates from the future";
	};
	class owr_crates_pile_4: owr_base0c {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\resources\crates\crates_pile_4.p3d";
		Icon = "\owr\ui\data\icon_resource_crates_ca.paa";
		displayName = "Pile of crates from the future";
	};
	class owr_crates_pile_5: owr_base0c {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\resources\crates\crates_pile_5.p3d";
		Icon = "\owr\ui\data\icon_resource_crates_ca.paa";
		displayName = "Pile of crates from the future";
	};
};