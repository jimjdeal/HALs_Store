/*
	Function: HALs_money_fnc_init
	Author: HallyG

	Example:
	[] spawn HALs_money_fnc_initModule;
__________________________________________________________________*/
if (!hasInterface) exitWith {};
if (!isNil "HALs_money_debug") exitWith {};

["HALs_money",
	[
		["startingFunds", 1000, {_this max 0 min 999999}],
		["startingBalance", 0, {_this max 0 min 999999}],
		["debug", 0, {_this isEqualTo 1}]
	]
] call HALs_fnc_getModuleSettings;

[player, HALs_money_startingFunds] call HALs_money_fnc_addFunds;

// Add money when player picks up money
player addEventHandler ["Take", {
	params ["_unit", "_container", "_item"];
	
	private _money = 0;
	switch (_item) do {
		case "Money_bunch": {_money = 50};
		case "Money_roll": {_money = 150};
		case "Money_stack": {_money = 300};
		case "Money": {_money = 600};
	};

	if (_money > 0) then {
		player removeItem _item;
		[player, _money] call HALs_money_fnc_addFunds;
	};
}];

player addEventHandler ["InventoryOpened", {
	_h = [] spawn {
		disableSerialization;
		waitUntil {!isNull findDisplay 602};
		
		if (isNull (uiNamespace getVariable ["HALs_InventoryMoneyInfo", controlNull])) then {
			uiNamespace setVariable ["HALs_InventoryMoneyInfo", (findDisplay 602) ctrlCreate ["RscStructuredText", 12365]];
		};
		
		_ctrl = uiNamespace getVariable ["HALs_InventoryMoneyInfo", controlNull];
		if (!isNull _ctrl) then {
			ctrlPosition (findDisplay 602 displayCtrl 2) params ["_x", "_y", "", "_h"];
			_w = ctrlPosition (findDisplay 602 displayCtrl 111) param [2, 0];
			_ctrl ctrlSetPosition [_x - _w, _y, _w, _h];
			_ctrl ctrlCommit 0;
			_ctrl ctrlShow true;
			
			while {ctrlShown _ctrl} do {
				_ctrl ctrlSetStructuredText parseText format [
					"<t align='right' shadow='1' font='RobotoCondensed' color='#aaffaa'>%1 %2</t>",
					([player] call HALs_money_fnc_getFunds) toFixed 2,
					HALs_store_currencySymbol
				];
				
				sleep 0.5;
			};
		};
	};
}];