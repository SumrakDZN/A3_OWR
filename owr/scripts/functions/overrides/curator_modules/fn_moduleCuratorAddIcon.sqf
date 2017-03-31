_logic = _this select 0;
_units = _this select 1;
_activated = _this select 2;

_curatorVar = _logic getvariable ["curator",""];
_curator = missionnamespace getvariable [_curatorVar,objnull];
_curators = if (isnull _curator) then {[]} else {[_curator]};
_areas = [];
{
	if  (_x call bis_fnc_isCurator && !(_x in _curators)) then {_curators set [count _curators,_x];};
} foreach (synchronizedobjects _logic);

if (count _curators == 0) exitwith {["No curator synchronized to %1",_logic] call bis_fnc_error;};

_texture = _logic getvariable ["texture",""];
_texture = _texture call bis_fnc_textureMarker;
if (_texture != "") then {
	_text = _logic getvariable ["text",""];
	_size = _logic getvariable ["size",1];
	_show2D = _logic getvariable ["show2D",true];
	_colorClass = _logic getvariable ["color","colorWhite"];
	_color = (configfile >> "cfgmarkercolors" >> _colorClass >> "color") call bis_fnc_colorConfigToRGBA;

	{
		_curator = _x;
		if (_activated) then {
			_id = [_curator,[_texture,_color,getposatl _logic,_size,_size,direction _logic,_text],_show2D] call bis_fnc_addcuratoricon;
			_logic setvariable ["id",_id];
		} else {
			[_curator,_logic getvariable ["id",-1]] call bis_fnc_addcuratoricon;
		};
	} foreach _curators;
};