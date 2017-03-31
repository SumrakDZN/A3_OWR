/*
	Author: Karel Moricky

	Description:
	Show hint in curator interface

	Parameter(s):
		0: STRING - title
		1: STRING - text
		2 (Optional) NUMBER - duration in seconds (default: 30s)

	Returns:
	CONTROL - UI control of the hint text
*/


#include "\A3\ui_f\hpp\defineResinclDesign.inc"
#include "\A3\ui_f_curator\ui\defineResinclDesign.inc"

#define DISPLAY (finddisplay IDD_RSCDISPLAYCURATOR)
#define CONTROLGROUP (DISPLAY displayctrl IDC_RSCADVANCEDHINT_HINTGROUP)
#define CONTROLTITLE (DISPLAY displayctrl IDC_RSCADVANCEDHINT_TITLE)
#define CONTROLHINT (DISPLAY displayctrl IDC_RSCADVANCEDHINT_HINT)

private ["_title","_text","_duration","_ctrlPos"];
_title = _this param [0,"",[""]];
_text = _this param [1,"",[""]];
_duration = _this param [2,30,[0]];

if (isnull DISPLAY) exitwith {"Curator display is not open" call bis_fnc_error; controlnull};
if (_text == "") exitwith {
	missionnamespace setvariable ["BIS_fnc_curatorHint_time",time];
	CONTROLGROUP ctrlshow false;
	controlnull
};
if (_title == "") then {_title = localize "str_a3_cfguigrids_igui_variables_grid_hint_0";};

CONTROLGROUP ctrlsetfade 0;
CONTROLGROUP ctrlcommit 0;
CONTROLGROUP ctrlshow true;

[CONTROLGROUP,_duration] spawn {
	disableserialization;
	scriptname "BIS_fnc_curatorHint: Duration";
	_ctrlGroup = _this select 0;
	_duration = _this select 1;

	_time = time + _duration;
	BIS_fnc_curatorHint_time = _time;
	waituntil {time > _time || _time != BIS_fnc_curatorHint_time};

	if (_time == BIS_fnc_curatorHint_time) then {
		_ctrlGroup ctrlsetfade 1;
		_ctrlGroup ctrlcommit 5;
	};
};

CONTROLTITLE ctrlsettext toupper _title;

CONTROLHINT ctrlsetstructuredtext parsetext _text;
[CONTROLHINT,0.01] call bis_fnc_ctrlfittotextheight;
_ctrlPos = ctrlposition CONTROLGROUP;
_ctrlPos set [3,(ctrlposition CONTROLTITLE select 3) + (ctrlposition CONTROLHINT select 3)];
CONTROLGROUP ctrlsetposition _ctrlPos;
CONTROLGROUP ctrlcommit 0;
CONTROLHINT