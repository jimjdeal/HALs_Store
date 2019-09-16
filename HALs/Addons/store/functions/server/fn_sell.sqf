/*
	Function: HALs_store_fnc_sell
	Author: HallyG
	Handles the sell transcations on the server.

	Argument(s):
	0: Seller <OBJECT>
	1: Item Classname <STRING>
	3: Item price <NUMBER>
	4: Number of items <NUMBER>

	Return Value:
	None

	Example:
	[player, "hgun_P07_F", 100, 5] call HALs_store_fnc_sell;
__________________________________________________________________*/
params [
	["_unit", objNull, [objNull]],
	["_classname", "", [""]],
	["_price", 0, [0]],
	["_amt", 0, [0]]
];

if (!isServer) exitWith {};
if (isNull _unit) exitWith {};
if (!alive _unit) exitWith {};
if (_amt < 1) exitWith {};
if (_classname isEqualTo "") exitWith {};

try {
	// Fetch current trader
	private _trader = _unit getVariable ["HALs_store_trader_current", objNull];
	if (isNull _trader) then {throw [""]};

    // Check if the trader will buy this item
	private _stock = [_trader, _classname] call HALs_store_fnc_getTraderStock;
	if (_stock isEqualTo -1) then {throw ["The trader will not buy this item."]};

    // Check that player has the item
    // Remove items from unit
	private _removed = false;
	{
		_removed = [_x, _classname] call HALs_store_fnc_removeContainerItem;
		if (_removed) exitWith {};
	} forEach [backpackContainer _unit, vestContainer _unit, uniformContainer  _unit];

	if (!_removed) then {
		_removed = [_unit, _classname] call HALs_store_fnc_removePlayerItem;
	};

	if (!_removed) then {
		throw ["Unable to sell item."];
	};

    private _amount = floor 1;
    private _total = (_price max 0) * _amount;

	// Update unit's funds and trader's stock
	[_trader, _classname, _amount] call HALs_store_fnc_updateStock;
	[_unit, _total] call HALs_money_fnc_addFunds;

	private _message = format ["x%1 %2(s) sold for %3 %4", _amount, [(_classname call HALs_fnc_getConfigClass) >> "displayName", ""] call HALs_fnc_getConfigValue, _total, HALs_store_currencySymbol];

	// Log sell
	if (HALs_store_debug) then {
		private _log = format ["%2(%1) sold %3 to (%4).", name _unit, getPlayerUID _unit, _message, _trader];
		[_log] call HALs_fnc_log;
	};

	throw [_message, "FD_CP_CLEAR_F"];
} catch {
	_exception params [
		["_message", ""],
		["_sound", "FD_CP_NOT_CLEAR_F", [""]]
	];

	if (count _message > 0) then {
		[_message, _sound] remoteExecCall ["HALs_store_fnc_systemChat", _unit];
	};
};
