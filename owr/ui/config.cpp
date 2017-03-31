class CfgPatches {
	class owr_ui {
		author = "Sumrak";
		name = "OWR - UI Definitions";
		url = "http://owr.nightstalkers.cz";
		requiredAddons[] = {"A3_Ui_F_Curator"};
		requiredVersion = 0.1;
		units[] = {};
		weapons[] = {};
	};
};


class CfgCurator
{
	/*class DrawObject
	{
		iconSize = 0.65;
		iconDriver = "\a3\Ui_f\data\IGUI\Cfg\CommandBar\imageDriver_ca.paa";
		iconCommander = "\a3\Ui_f\data\IGUI\Cfg\CommandBar\imageCommander_ca.paa";
		iconGunner = "\a3\Ui_f\data\IGUI\Cfg\CommandBar\imageGunner_ca.paa";
		iconCargo = "\a3\Ui_f\data\IGUI\Cfg\CommandBar\imageCargo_ca.paa";
		class PlayerPings
		{
			animationLength = 6000;
			alowRepeatAfter = 4000;
		};
		class 3D
		{
			sizeNormal = 1.0;
			sizeSelected = 1.0;
			sizeTarget = 1.1;
			sizeCoefStartDistance = 50;
			sizeCoefEndDistance = 1250;
			startIconFading = 1250;
			endIconFading = 1750;
			starLogictIconFading = 1000;
			endLogicIconFading = 1500;
		};
		class 2D
		{
			sizeNormal = 1.0;
			sizeSelected = 1.0;
			sizeTarget = 1.1;
			sizeCoefStartDistance = 50;
			sizeCoefEndDistance = 200;
			size = 26;
		};
	};*/
	class DrawObject {
		class 3D {
			alphaNormal = 0.75;
			alphaNormalBackground = 0.75;
			alphaSelected = 1.0;
			alphaSelectedBackground = 0.75;
		};
		class 2D {
			alphaNormal = 0.75;
			alphaNormalBackground = 0.75;
			alphaSelected = 1.0;
			alphaSelectedBackground = 0.75;
		};
	};
	class DrawGroup {
		textureWest = "";
		textureEast = "";
		textureGuer = "";
		textureCivilian = "";
		textureUnknown = "";
		class 3D
		{
			sizeCoefStartDistance = 5000;
			sizeCoefEndDistance = 6000;
			alphaNormal = 0.5;
			alphaSelected = 1;
			alphaTarget = 1;
			color = "side";
			colorPreview[] = {1,1,1,1};
			textureWest = "";
			textureEast = "";
			textureGuer = "";
			textureCivilian = "";
			textureUnknown = "";
		};
		class 2D
		{
			alphaNormal = 0.5;
			alphaSelected = 1;
			alphaTarget = 1;
			color = "side";
			colorPreview[] = {1,1,1,1};
			textureWest = "";
			textureEast = "";
			textureGuer = "";
			textureCivilian = "";
			textureUnknown = "";
		};
	};

	class DrawPlayer
	{
		class 3D
		{
			texture = "\A3\ui_f\data\igui\cfg\islandmap\iconPlayer_ca.paa";
			color[] = {0.7,0.7,0,1};
			textureRemote = "\A3\ui_f\data\igui\cfg\islandmap\iconPlayer_ca.paa";
			colorRemote[] = {1,1,1,0.5};
			textureLaser = "\a3\Ui_F_Curator\Data\CfgCurator\laser_ca.paa";
			colorLaser[] = {1,1,1,0.5};
		};
		class 2D
		{
			texture = "\A3\ui_f\data\igui\cfg\islandmap\iconPlayer_ca.paa";
			color[] = {0.7,0.7,0,1};
			textureRemote = "\A3\ui_f\data\igui\cfg\islandmap\iconPlayer_ca.paa";
			colorRemote[] = {1,1,1,0.5};
			textureLaser = "\a3\Ui_F_Curator\Data\CfgCurator\laser_ca.paa";
			colorLaser[] = {1,1,1,0.5};
		};
	};
};

class CfgScriptPaths
{
	OWROverrides = "owr\ui\scripts\";
};


class RscControlsGroupNoScrollbars;
class RscFrame;
class RscButton;
class RscText;
class RscStructuredText;
class RscTree;
class RscControlsGroup;
class RscActivePicture;

class RscDisplayCurator {
	scriptName = "RscDisplayCurator";
	scriptPath = "OWROverrides";
	class Controls {
		class owr_bar_top: RscControlsGroupNoScrollbars {
			x = "safezoneX + 12.5 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
			w = "safezoneW - 25 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
			idc = 11223;
			y = "0.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + 		(safezoneY)";
			h = "1.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
			class controls {
				class PointsBackground: RscStructuredText {
					w = "safezoneW - 25 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					idc = 112233;
					x = "0 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					h = "1 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorBackground[] = {0.1,0.1,0.1,0.5};
					text = "";
				};
			};
		};

		class owr_message_box: RscControlsGroupNoScrollbars {
			idc = 11220;
			x = "(-0.3795)";
			y = "(0.02)";
			w = "16.3 *  (((safezoneW / safezoneH) min 1.2) / 40)";
			h = "4.6 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)"; //"safezoneH - 0.25"; 
			class controls {
				class message_picture: RscActivePicture {
					color[] = {1,1,1,1};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112201;
					text = "";
					x = "0.3 * (((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2.85 *   (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "3.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {1,1,1,1};
					tooltip = "";
				};
				class message_text: RscStructuredText {
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112202;
					text = "";
					x = "0";
					y = "4.05 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "16.3 *  (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "0.08";
					colorText[] = {1,1,1,1};
					tooltip = "";
				};
			};
		};

		class owr_selected_box: RscControlsGroupNoScrollbars {
			idc = 11221;
			x = "(-0.3795)";
			y = "(0.92)";

			w = "6.3 *  (((safezoneW / safezoneH) min 1.2) / 40)";
			h = "safezoneH - 0.25"; // 2 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
			class controls
			{
				class EntitiesBackground: RscText
				{
					idc = 112211;
					x = "0";
					y = "0";
					w = "6.3 *  (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "0.35";
					colorBackground[] = {0.1,0.1,0.1,0.5};
				};
				class EntitiesFrame: RscFrame
				{
					idc = 112212;
					x = "0";
					y = "0";
					w = "6.3 *  (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "0.35";
					colorText[] = {0,0,0,1};
				};
				class text_info: RscStructuredText
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112213;
					text = "";
					x = "0.3 * (((safezoneW / safezoneH) min 1.2) / 40)";
					y = "4.45 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "6.3 *  (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "0.35";
					colorText[] = {1,1,1,1};
					tooltip = "Selected unit info";
				};
				class picture_info: RscActivePicture
				{
					color[] = {1,1,1,1};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112214;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "0.3 * (((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "3 *   (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "3.5 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {1,1,1,1};
					tooltip = "";
				};
				class text_info_skills: RscStructuredText
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112215;
					text = "";
					x = "3.15 * (((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.35 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "6.3 *  (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "0.35";
					colorText[] = {1,1,1,1};
					tooltip = "Selected unit info";
				};
			};
		};

		class owr_action_box: RscControlsGroupNoScrollbars {
			idc = 11222;
			x = "(-0.1895)";
			y = "(0.92)";

			w = "6.3 *  (((safezoneW / safezoneH) min 1.2) / 40)";
			h = "safezoneH - 0.25"; // 2 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
			class controls
			{
				class EntitiesBackground: RscText
				{
					idc = 112222;
					x = "0";
					y = "0";
					w = "6.3 *  (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "0.35";
					colorBackground[] = {0.1,0.1,0.1,0.5};
				};
				class EntitiesFrame: RscFrame
				{
					idc = 112223;
					x = "0";
					y = "0";
					w = "6.3 *  (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "0.35";
					colorText[] = {0,0,0,1};
				};
				// first row
				class action01: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112224;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_guer_ca.paa";
					x = "0.2 * (((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.35 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.7 * (((safezoneW / safezoneH) min 1.2) / 40)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR ACTION01";
				};
				class action02: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112225;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_guer_ca.paa";
					x = "2.1 * (((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.35 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.7 * (((safezoneW / safezoneH) min 1.2) / 40)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR ACTION02";
				};
				class action03: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112226;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_guer_ca.paa";
					x = "4.0 * (((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.35 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.7 * (((safezoneW / safezoneH) min 1.2) / 40)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR ACTION03";
				};
				//second row
				class action04: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112227;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_guer_ca.paa";
					x = "0.2 * (((safezoneW / safezoneH) min 1.2) / 40)";
					y = "2.25 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.7 * (((safezoneW / safezoneH) min 1.2) / 40)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR ACTION04";
				};
				class action05: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112228;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_guer_ca.paa";
					x = "2.1 * (((safezoneW / safezoneH) min 1.2) / 40)";
					y = "2.25 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.7 * (((safezoneW / safezoneH) min 1.2) / 40)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR ACTION05";
				};
				class action06: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112229;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_guer_ca.paa";
					x = "4.0 * (((safezoneW / safezoneH) min 1.2) / 40)";
					y = "2.25 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.7 * (((safezoneW / safezoneH) min 1.2) / 40)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR ACTION06";
				};
				// third row
				class action07: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112230;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_guer_ca.paa";
					x = "0.2 * (((safezoneW / safezoneH) min 1.2) / 40)";
					y = "4.15 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.7 * (((safezoneW / safezoneH) min 1.2) / 40)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR ACTION07";
				};
				class action08: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112231;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_guer_ca.paa";
					x = "2.1 * (((safezoneW / safezoneH) min 1.2) / 40)";
					y = "4.15 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.7 * (((safezoneW / safezoneH) min 1.2) / 40)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR ACTION08";
				};
				class action09: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112232;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_guer_ca.paa";
					x = "4.0 * (((safezoneW / safezoneH) min 1.2) / 40)";
					y = "4.15 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.7 * (((safezoneW / safezoneH) min 1.2) / 40)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR ACTION09";
				};
			};
		};

		class owr_unit_list: RscControlsGroupNoScrollbars {
			
			idc = 11224;
			x = "(0.0)";
			y = "(0.92)";

			w = "22 *  (((safezoneW / safezoneH) min 1.2) / 40)";
			h = "safezoneH - 0.25"; // 2 * ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25)
			class controls
			{
				class EntitiesBackground: RscText
				{
					idc = 112244;
					x = "0";
					y = "0";
					w = "22 * (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "0.35";
					colorBackground[] = {0.1,0.1,0.1,0.5};
				};
				class EntitiesFrame: RscFrame
				{
					idc = 112245;
					x = "0";
					y = "0";
					w = "22 * (((safezoneW / safezoneH) min 1.2) / 40)";
					h = "0.35";
					colorText[] = {0,0,0,1};
				};
				/*class Entities: RscTree
				{
					idc = 112246;
					h = "safezoneH - 2 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					multiselectEnabled = 1;
					expandOnDoubleclick = 0;
					colorMarked[] = {1,1,1,0.35};
					colorMarkedSelected[] = {1,1,1,0.7};
					x = "0 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "11 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					sizeEx = "0.8 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
				};*/
				class p01: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112246;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "0.3 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p02: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112247;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "2.4 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p03: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112248;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "4.5 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p04: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112249;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "6.6 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p05: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112250;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "8.7 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p06: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112251;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "10.8 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p07: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112252;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "12.9 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p08: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112253;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "15.0 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p09: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112254;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "17.1 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p10: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112255;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "19.2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "0.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p11: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112256;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "0.3 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "3.25 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p12: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112257;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "2.4 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "3.25 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p13: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112258;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "4.5 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "3.25 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p14: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112259;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "6.6 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "3.25 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p15: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112260;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "8.7 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "3.25 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p16: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112261;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "10.8 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "3.25 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p17: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112262;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "12.9 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "3.25 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p18: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112263;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "15.0 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "3.25 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p19: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112264;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "17.1 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "3.25 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
				class p20: RscActivePicture
				{
					color[] = {1,1,1,0.75};
					colorActive[] = {1,1,1,1};
					shadow = 0;
					idc = 112265;
					text = "\a3\ui_f_curator\Data\Displays\RscDisplayCurator\side_west_ca.paa";
					x = "19.2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					y = "3.25 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					w = "2 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
					h = "2.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
					colorText[] = {0,0.3,0.6,1};
					tooltip = "OWR PERSONNEL";
				};
			};
		};





		// these overrides WILL HIDE ZEUS FEATURES (left and right tab) 
		class Main: RscControlsGroupNoScrollbars
		{
			x = "safezoneX + 12.5 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
			w = "0.0 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
			idc = 16806;
			y = "0.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + 		(safezoneY)";
			h = "0.0 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
		};
		class AddBar: RscControlsGroupNoScrollbars {
			x = "safezoneX + safezoneW - 12.5 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
			idc = 16805;
			y = "0.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + 		(safezoneY)";
			w = "0.0 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
			h = "0.0 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
		};
		class Add: RscControlsGroupNoScrollbars
		{
			h = "0.0 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
			//h = "safezoneH - 2 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
			x = "safezoneX + safezoneW - 12.5 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
			idc = 450;
			y = "1.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + 		(safezoneY)";
			w = "0.0 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
			//w = "11 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
		};
		class MissionBar: RscControlsGroupNoScrollbars
		{
			idc = 16809;
			x = "1.5 * 							(			((safezoneW / safezoneH) min 1.2) / 40) + 		(safezoneX)";
			y = "0.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + 		(safezoneY)";
			w = "0.0 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
			h = "0.0 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
		};
		class Mission: RscControlsGroupNoScrollbars
		{
			h = "0.0 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
			idc = 453;
			x = "1.5 * 							(			((safezoneW / safezoneH) min 1.2) / 40) + 		(safezoneX)";
			y = "1.5 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + 		(safezoneY)";
			w = "0.0 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
		};
		class Clock: RscControlsGroup
		{
			x = "0.5 - 8 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
			idc = 16808;
			y = "2.2 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) + 		(safezoneY)";
			w = "0.0 * 							(			((safezoneW / safezoneH) min 1.2) / 40)";
			h = "0.0 * 							(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25)";
		};
	};
};