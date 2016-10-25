if DynamicCosmetics == nil then
	_G.DynamicCosmetics = class({})
end
--TODO

function DynamicCosmetics:Init()
	local kvTable = LoadKeyValues("scripts/items/items_game.txt")
	self._UnformattedWearables = kvTable["items"]

	local kvLoadedTable = LoadKeyValues( "scripts/items/items_game.txt" )
	CosmeticLib._AllItemsByID = kvLoadedTable[ "items" ]
	CosmeticLib._NameToID = CosmeticLib._NameToID or {}
	
	for CosmeticID, CosmeticTable in pairs( CosmeticLib._AllItemsByID ) do
		if CosmeticTable[ "prefab" ] then	
			if CosmeticTable["prefab"] == "default_item" and CosmeticTable["used_by_heroes"] and type(CosmeticTable["used_by_heroes"]) == "table" then
				CosmeticLib:_InsertIntoDefaultTable( CosmeticID )
				CosmeticLib._NameToID[ CosmeticTable["name"]] = CosmeticID
			elseif CosmeticTable["prefab"] == "wearable" and CosmeticTable["used_by_heroes"] and type(CosmeticTable["used_by_heroes"]) == "table" then
				CosmeticLib:_InsertIntoWearableTable( CosmeticID )
				CosmeticLib._NameToID[ CosmeticTable["name"]] = CosmeticID
			end
		end
	end
	
	for CosmeticID, CosmeticTable in pairs( CosmeticLib._AllItemsByID ) do
		if CosmeticTable[ "prefab" ] and CosmeticTable["prefab"] == "bundle" and CosmeticTable["used_by_heroes"] ~= nil and type(CosmeticTable["used_by_heroes"]) == "table" then
			CosmeticLib:_InsertIntoBundleTable( CosmeticID )
			CosmeticLib._NameToID[CosmeticTable["name"]] = CosmeticID
		end
	end
	
	CosmeticLib._AllItemsByID["-1"] = {model_player = "models/development/invisiblebox.vmdl"}
end

function DynamicCosmetics:GetDefaultAttachedItems(unit)
	for _,v in ipairs(unit:GetChildren()) do
		if v:GetClassname() == "dota_item_wearable" then
			UTIL_Remove(v)
			local id = CosmeticLib:GetIDByModelName( wearable:GetModelName() )
			local item = CosmeticLib._AllItemsByID[ id ]
			if item then
				-- Structure table[ item_slot ] = { handle entindex, item_id }
				local item_slot = item[ "item_slot" ] or "weapon"
				unit._DynamicCosmetics_slots[ item_slot ] = { handle = wearable, item_id = id }
			end
		end
	end
end

function DynamicCosmetics:Unit(unit)
	unit._DynamicCosmetics_slots = {}

end

function CDOTA_BaseNPC:DynamicCosmetics()
	return DynamicCosmetics:Unit(self)
end