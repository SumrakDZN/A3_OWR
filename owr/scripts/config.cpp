class CfgPatches {
	class owr_scripts {
		author = "Sumrak";
		name = "OWR - Scripts";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"owr_data", "A3_Functions_F_Curator", "A3_Modules_F_Curator"};
		requiredVersion = 0.1;
		units[] = {};
		weapons[] = {};
	};
};

class CfgFunctions 
{
	class A3_Functions_F_Curator
	{
		tag = "BIS";
		project = "arma3";

		class Curator
		{
			file = "owr\scripts\functions\overrides\curator_functions";

			class forceCuratorInterface{};
			class isForcedCuratorInterface{};

			class curatorObjectRegistered{};
			class curatorObjectRegisteredTable{};
			class registerCuratorObject{};
			class showCuratorFeedbackMessage{};
			class isCurator{};
			class removeDestroyedCuratorEditableObjects{};
			class curatorPinged{};
			class curatorWaypointPlaced{};
			class curatorObjectPlaced{};
			class curatorObjectEdited{};
			class curatorAttachObject{};
			class curatorRespawn{};
			class manageCuratorAddons{};
			class listCuratorPlayers{};
			class addCuratorAreaFromTrigger{};
			class setCuratorVisionModes{};
			class curatorVisionModes{};
			class toggleCuratorVisionMode{};
			class mirrorCuratorSettings{};

			class drawCuratorLocations{};
			class drawCuratorRespawnMarkers{};
			class drawCuratorDeaths{};

			class addCuratorIcon{};
			class removeCuratorIcon{};

			class isCuratorEditable{};

			class curatorAutomatic{};
			class curatorAutomaticPositions{};

			class setCuratorAttributes{};
			class curatorAttributes{};
			class showCuratorAttributes{};
			class initCuratorAttribute{};
			class setCuratorCamera{};
			class shakeCuratorCamera{};
			class curatorHint{};
			class curatorSayMessage {};

			class exportCuratorCostTable{};
		};
		class CuratorChallenges
		{
			file = "A3\functions_f_curator\CuratorChallenges";

			class addCuratorChallenge{};
			class finishCuratorChallenge{};
			class manageCuratorChallenges{};
			class formatCuratorChallengeObjects{};
			class completedCuratorChallengesCount{};

			class curatorChallengeFireWeapon{};
			class curatorChallengeGetInVehicle{};
			class curatorChallengeDestroyVehicle{};
			class curatorChallengeFindIntel{};
			class curatorChallengeSpawnLightning{};
			class curatorChallengeIlluminate{};
		};
		class Environment
		{
			file = "A3\functions_f_curator\Environment";

			class setOvercast{};
			class setFog{};
			class setDate{};
		};
		class Map
		{
			file = "A3\functions_f_curator\Map";

			class locationDescription{};
			class drawAO{};
			class drawMinefields{};
			class drawRespawnPositions{};
		};
		class Misc
		{
			file = "A3\functions_f_curator\Misc";

			class activateAddons{};
			class playEndMusic{};
			class neutralizeUnit{};
			class isLoading{};
			class isUnitVirtual{};
			class endMissionServer{};
			class exportCfgGroups{};
			class selectDiarySubject{};
		};
		class MP
		{
			file = "A3\functions_f_curator\MP";

			class sayMessage{};
			class playSound{};
			class playMusic{};
			class setObjectTexture{};
			class estimatedTimeLeft{};
		};
		class Objects
		{
			file = "A3\functions_f_curator\Objects";

			class initIntelObject{};
			class initVirtualUnit{};
		};
		class Respawn
		{
			file = "A3\functions_f_curator\Respawn";

			class initRespawnBackpack{};
			class respawnRounds{};
			class respawnMenuSpectator{};
		};
		class Variables
		{
			file = "A3\functions_f_curator\Variables";

			class setServerVariable{};
			class getServerVariable{preInit = 1;};
		};
	};
	class A3_Modules_F_Curator
	{
		class Curator
		{
			file = "owr\scripts\functions\overrides\curator_modules";
			class moduleCurator;
			class moduleCuratorAddEditingArea{};
			class moduleCuratorSetEditingAreaType{};
			class moduleCuratorAddEditingAreaPlayers{};
			class moduleCuratorAddEditableObjects{};
			class moduleCuratorSetObjectCost{};
			class moduleCuratorSetCostsVehicleClass{};
			class moduleCuratorSetCostsSide{};
			class moduleCuratorSetCostsDefault{};
			class moduleCuratorSetCoefs{};
			class moduleCuratorAddPoints{};
			class moduleCuratorAddAddons{};
			class moduleCuratorAddCameraArea{};
			class moduleCuratorAddIcon{};
			class moduleCuratorSetCamera{};
			class moduleCuratorSetAttributes{};
		};
	};
};