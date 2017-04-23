class CfgPatches {
	class owr_missions {
		author = "Sumrak";
		name = "OWR - Missions";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data"};
		requiredVersion = 0.1;
		units[] = {};
		weapons[] = {};
	};
};
class CfgMissions
{
	class MPMissions
	{
		class owr_domination
		{
			briefingName = "Original War Domination";
			directory = "owr\missions\MPScenarios\owr_domination.pliocen";
		};
		class owr_skirmish
		{
			briefingName = "Original War Skirmish";
			directory = "owr\missions\MPScenarios\owr_skirmish.pliocen";
		};
	};
};