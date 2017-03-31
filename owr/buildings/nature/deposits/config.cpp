class CfgPatches {
	class owr_nature_deposits {
		author = "Sumrak";
		name = "OWR - Deposits";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {"owr_deposit_siberite", "owr_deposit_oil"};
		weapons[] = {};
	};
};

class CfgVehicles {
	class owr_base0c;
	class owr_deposit_siberite: owr_base0c {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\nature\deposits\deposit.p3d";
		Icon = "\owr\ui\data\buildings\icon_deposit_siberite_ca.paa";
		displayName = "Nature Siberite Deposit";
	};
	class owr_deposit_oil: owr_base0c {
		scope = 2;
		scopeCurator = 2;
		model = "owr\buildings\nature\deposits\deposit.p3d";
		Icon = "\owr\ui\data\buildings\icon_deposit_oil_ca.paa";
		displayName = "Nature Oil Deposit";
	};
};