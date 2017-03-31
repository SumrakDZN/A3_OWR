/*
	Author: Karel Moricky

	Description:
	Show feedback message when illegal operation is attempted in curator interface

	Parameter(s):
		0: OBJECT - curator
		1: NUMBER or STRING - error ID or message to be displayed

	Returns:
	BOOL
*/

#include "\A3\ui_f_curator\ui\defineResinclDesign.inc"

private ["_curator","_id","_time","_error"];
_curator = _this param [0,objnull,[objnull]];
_id = _this param [1,-1,[0,""]];

_time = missionnamespace getvariable ["bis_fnc_showcuratorfeedbackmessage_time",-1];
if (_time > time) exitwith {};
missionnamespace setvariable ["bis_fnc_showcuratorfeedbackmessage_time",time + 0.1];

_error = 1;
_message = switch _id do {

	//--- Interface
	case 000: {localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_000"};
	case 003: {localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_003"};

	//--- Placing
	case 101: {_error = 2; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_101"};
	case 102: {_error = 3; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_102"};
	case 103: {_error = 4; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_103"};

	//--- Placing Waypoints
	case 201: {_error = 2; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_201"};
	case 202: {_error = 3; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_102"};
	case 206: {localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_206"};

	//--- Editing
	case 301: {_error = 2; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_301"};
	case 302: {_error = 3; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_102"};
	case 303: {_error = 4; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_303"};
	case 304: {_error = 4; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_304"};
	case 305: {""};
	case 307: {_error = 5; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_307"};
	case 308: {_error = 5; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_308"};

	//--- Deleting
	case 401: {_error = 2; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_401"};
	case 402: {_error = 3; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_102"};
	case 404: {_error = 4; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_404"};
	case 405: {_error = 4; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_405"};
	case 407: {_error = 5; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_407"};

	//--- Destroying
	case 501: {_error = 2; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_501"};
	case 502: {_error = 3; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_102"};
	case 504: {_error = 4; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_504"};
	case 505: {_error = 4; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_505"};
	case 506: {localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_506"};
	case 507: {_error = 5; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_507"};

	//--- Syncing
	case 609: {_error = 4; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_609"};
	case 610: {_error = 4; localize "STR_A3_BIS_fnc_showCuratorFeedbackMessage_610"};

	default {
		if (typename _id == typename "") then {_id} else {""};
	};
};

playsound [format ["RscDisplayCurator_error0%1",_error],true];

disableserialization;
private ["_display","_ctrlMessage"];
_display = finddisplay IDD_RSCDISPLAYCURATOR;
_ctrlMessage = _display displayctrl IDC_RSCDISPLAYCURATOR_FEEDBACKMESSAGE;
_ctrlMessage ctrlsettext toupper _message;
_ctrlMessage ctrlsetfade 1;
_ctrlMessage ctrlcommit 0;
_ctrlMessage ctrlsetfade 0;
_ctrlMessage ctrlcommit 0.1;

if !(isnil "BIS_fnc_moduleCurator_feedbackMessage") then {terminate BIS_fnc_moduleCurator_feedbackMessage;};
BIS_fnc_moduleCurator_feedbackMessage = [_ctrlMessage] spawn {
	disableserialization;
	uisleep 3;
	_ctrlMessage = _this select 0;
	_ctrlMessage ctrlsetfade 1;
	_ctrlMessage ctrlcommit 0.5;
};
true