if not CustomWearables then
	_G.CustomWearables = class({})
end

function CustomWearables:Unit(unit)
	if not unit.CustomWearables then unit.CustomWearables = {Attachments = {}, ParticleMap = {}, PlayerKeys = {}} end
	if not unit.CustomWearablesConst then unit.CustomWearablesConst = {EverEquippedMap = {}} end
end

function CustomWearables:TranslateParticle(unit, particle)
	return unit.CustomWearables.ParticleMap[particle] or particle
end

function CustomWearables:HasWearable(pID, name)
	local steamid = PlayerResource:GetSteamAccountID(pID)
	if CUSTOM_WEARABLES_PLAYER_ITEMS[steamid] then
		return table.contains(CUSTOM_WEARABLES_PLAYER_ITEMS[steamid], name)
	end
	return false
end

function CustomWearables:RemoveDotaWearables(unit)
	for _,v in pairs(unit:GetChildren()) do
		if v:GetClassname() == "dota_item_wearable" then
			v:AddEffects(EF_NODRAW)
			v:SetModel("models/development/invisiblebox.vmdl")
			--v:RemoveSelf()
		end
	end
end

function CustomWearables:EquipWearables(unit, herokey)
	if not herokey then
		herokey = GetFullHeroName(unit) or unit:GetUnitName()
	elseif type(herokey) == "table" and herokey:entindex() then
		herokey = GetFullHeroName(herokey)
	end
	local wearables = CustomWearables:GetPlayerHeroWearables(unit, herokey)
	for _,v in ipairs(wearables) do
		CustomWearables:EquipWearable(unit, v)
	end
	if unit.WearablesRemoved then
		CustomWearables:RemoveDotaWearables(unit)
	end
end

function CustomWearables:EquipWearable(unit, handle)
	CustomWearables:Unit(unit)
	if handle.base_model and type(handle.base_model) == "string" then
		unit:SetModel(handle.base_model)
		unit:SetOriginalModel(handle.base_model)
	end
	if handle.base_model_scale and type(handle.base_model_scale) == "number" then
		unit:SetModelScale(handle.base_model_scale)
	end
	if handle.models and type(handle.models) == "table" and #handle.models > 0 then
		for _,v in ipairs(handle.models) do
			CustomWearables:EquipWearableModel(unit, v)
		end
	end
	if handle.particles and type(handle.particles) == "table" and table.count(handle.particles) > 0 then
		for k,v in pairs(handle.particles) do
			if unit.CustomWearables.ParticleMap[k] then
				print("[CustomWearables:EquipWearable] Unit already has a particle in particle map, override: unit, key, oldValue, newValue", unit:GetUnitName(), k, unit.CustomWearables.ParticleMap[k], v)
			end
			unit.CustomWearables.ParticleMap[k] = v
		end
	end
	if handle.hidden_slots and type(handle.hidden_slots) == "table" and #handle.hidden_slots > 0 then
		for _,v in ipairs(handle.hidden_slots) do
			if CosmeticLib:_Identify( unit ) then
				CosmeticLib:RemoveFromSlot( unit, v )
				unit._cosmeticlib_wearables_slots[v].handle:AddEffects(EF_NODRAW)
			end
			--Attachments:Attachment_HideCosmetic({index = unit:GetEntityIndex(), PlayerID = unit:GetPlayerID(), model = GetModelName()})
		end
	end
	if handle.hide_wearables then
		unit.WearablesRemoved = true
	end
	if handle.on_first_equip then
		if not unit.CustomWearablesConst.EverEquippedMap[handle.name] then
			unit.CustomWearablesConst.EverEquippedMap[handle.name] = true
			handle.on_first_equip(handle, unit)
		end
	end
	if handle.on_equip then
		handle.on_equip(handle, unit)
	end
	if handle.PlayerKeys then
		if not unit.CustomWearables.PlayerKeys then unit.CustomWearables.PlayerKeys = {} end
		table.merge(unit.CustomWearables.PlayerKeys, handle.PlayerKeys)
	end
	return
	--[[TODO
	if handle.custom_slots and type(handle.custom_slots) == "table" and #handle.custom_slots > 0 then
		for k,v in ipairs(handle.custom_slots) do
			if CosmeticLib:_Identify( unit ) then
				CustomWearables:EquipCustomModelToSlot(unit, k, v)
			end
		end
	end]]
end

function CustomWearables:UnequipAllWearables(unit)
	CustomWearables:Unit(unit)
	for _,v in ipairs(unit.CustomWearables.Attachments) do
		UTIL_Remove(v)
	end
	unit.CustomWearables = nil
	CustomWearables:Unit(unit)
end

function CustomWearables:EquipWearableModel(unit, modelHandle)
	CustomWearables:Unit(unit)
	local a = Attachments:AttachProp(unit, modelHandle.attachPoint or "attach_hitloc", modelHandle.model or "models/development/invisiblebox.vmdl", modelHandle.scale or 1.0, modelHandle.properties)
	if modelHandle.callback then modelHandle.callback(a) end
	table.insert(unit.CustomWearables.Attachments, a)
end

function CustomWearables:EquipCustomModelToSlot(unit, slot_name, model_name)
	CustomWearables:Unit(unit)
	if CosmeticLib:_Identify( unit ) then
		local handle_table = unit._cosmeticlib_wearables_slots[ slot_name ]
		if handle_table then
			handle_table[ "handle" ]:SetModel( model_name )
			handle_table[ "item_id" ] = nil
		end
	end
end

function CustomWearables:GetPlayerHeroWearables(unitvar, herokey)
	local wearables = {}
	if type(herokey) == "table" and herokey:entindex() then
		herokey = GetFullHeroName(herokey)
	end
	local playerID = UnitVarToPlayerID(unitvar)
	if playerID and playerID > -1 then
		local steamid = PlayerResource:GetSteamAccountID(playerID)
		if CUSTOM_WEARABLES_PLAYER_ITEMS[steamid] then
			for _,v in ipairs(CUSTOM_WEARABLES_PLAYER_ITEMS[steamid]) do
				local h = CustomWearables:WearableNameToHandle(v)
				if h and h.hero == herokey or not h.hero then
					table.insert(wearables, h)
				end
			end
		end
	end
	return wearables
end

function CustomWearables:WearableNameToHandle(wearable)
	local t = {name = wearable}
	table.merge(t, CUSTOM_WEARABLES_ITEM_HANDLES[wearable])
	return t
end
-----------------------------------------------------------------------------------------
--Function remap
-----------------------------------------------------------------------------------------
function CDOTA_BaseNPC:EquipWearable(handle)
	CustomWearables:Unit(self)
	return CustomWearables:EquipWearable(self, handle)
end
function CDOTA_BaseNPC:UnequipAllWearables()
	CustomWearables:Unit(self)
	CustomWearables:UnequipAllWearables(self)
end
function CDOTA_BaseNPC:TranslateParticle(particle)
	CustomWearables:Unit(self)
	return CustomWearables:TranslateParticle(self, particle)
end