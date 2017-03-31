/*
	Author: Karel Moricky

	Description:
	Returns list of playable units with access to curator

	Returns:
	ARRAY - list of units
*/

private ["_players"];
_players = [];
{
	private ["_player"];
	_player = getassignedcuratorunit _x;
	if (!isnull _player && !(_x in _players)) then {
		_players set [count _players,_player];
	};
} foreach allcurators;
_players