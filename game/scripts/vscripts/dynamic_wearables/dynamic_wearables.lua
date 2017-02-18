if not DynamicWearables then
	DynamicWearables = class({})
	DynamicWearables.RawItemsKV = LoadKeyValues( "scripts/items/items_game.txt" )
	DynamicWearables.DotaWearablesByIds = {}
	DynamicWearables.DotaWearablesByHeroes = {}
	DynamicWearables.DefaultWearables = {}
end
DynamicWearables.KVAttachTypeToLua = {
	absorigin_follow = PATTACH_ABSORIGIN_FOLLOW,
	customorigin = PATTACH_CUSTOMORIGIN,
	point_follow = PATTACH_POINT_FOLLOW,
	worldorigin = PATTACH_WORLDORIGIN
}
LinkLuaModifier("modifier_arena_wearable", "dynamic_wearables/modifier_arena_wearable.lua", LUA_MODIFIER_MOTION_NONE)
WEARABLES_ATTACH_METHOD_DOTA = 0
WEARABLES_ATTACH_METHOD_ATTACHMENTS = 1

function DynamicWearables:GetWearableDataById(wearableId)
	return DynamicWearables.DotaWearablesByIds[wearableId]
end

function CDOTA_BaseNPC:GetWearableInSlot(slot)
	if not self.EquippedWearables then return end
	return self.EquippedWearables[slot]
end

function DynamicWearables:CreateDotaCustomWearable()
	local wearableEntity = CreateUnitByName("npc_arena_wearable", Vector(0), false, nil, nil, DOTA_TEAM_NOTEAM)
	wearableEntity:AddNewModifier(wearableEntity, nil, "modifier_arena_wearable", nil)
	local DefaultModelSetter = wearableEntity.SetModel
	wearableEntity.SetModel = function(self, modelName)
		self:SetOriginalModel(modelName)
		DefaultModelSetter(self, modelName)
	end
	wearableEntity.IsDynamicWearable = function()
		return true
	end
	wearableEntity.SetVisible = function(self, state)
		self.WearableVisible = state
	end
	return wearableEntity
end

function CDOTA_BaseNPC:SetWearableVisible(slot, visible)
	local wearable = self:GetWearableInSlot(slot)
	if wearable then
		wearable.entity:SetVisible(slot)
	end
end

function CDOTA_BaseNPC:EquipItemsFromPlayerSelectionOrDefault()
	local CustomSet = {}
	local ItemSet = {}
	local DotaItems = DynamicWearables.DefaultWearables[GetFullHeroName(self)]
	if DotaItems then table.merge(ItemSet, DotaItems) end
	if CustomSet then table.merge(ItemSet, CustomSet) end
	for slot, id in pairs(ItemSet) do
		if not self.EquippedWearables or not self.EquippedWearables[slot] then
			self:EquipWearable(id)
		end
	end
	if not self.UpdateWearablesTimer then
		self.UpdateWearablesTimer = Timers:CreateTimer(function()
			if IsValidEntity(self) then
				local InvisibilityLevel = self:IsInvisible() and 1 or 0
				local modelChanged = self:HasModelChanged()
				for slot, wearable in pairs(self.EquippedWearables or {}) do
					if IsValidEntity(wearable.entity) then
						local itemLevel = InvisibilityLevel
						if modelChanged or wearable.entity.WearableVisible == false then
							itemLevel = itemLevel + 1.01
						end
						local modifier = wearable.entity:FindModifierByName("modifier_arena_wearable")
						if modifier then
							modifier:SetStackCount(itemLevel * 100)
						end
					else
						self.EquippedWearables[slot] = nil
					end
				end
				return 0.03
			end
		end)
	end
end

function CDOTA_BaseNPC:RemoveAllWearables()
	if self.EquippedWearables then
		for _, wearable in pairs(self.EquippedWearables) do
			for _,v in ipairs(wearable.attached_particles) do
				ParticleManager:DestroyParticle(v, true)
			end
			UTIL_Remove(wearable.entity)
		end
		self.EquippedWearables = nil
	end
end

function CDOTA_BaseNPC:EquipWearable(wearableId)
	local wearable = DynamicWearables:GetWearableDataById(wearableId)
	if not wearable then return end
	local wornWearable = self:GetWearableInSlot(wearable.slot)
	local wearableEntity
	if wornWearable then
		wearableEntity = wornWearable.entity
		for _,v in ipairs(wornWearable.attached_particles) do
			ParticleManager:DestroyParticle(v, true)
		end
	end
	if wearable.attach_method == WEARABLES_ATTACH_METHOD_DOTA then
		if not wearableEntity then
			wearableEntity = DynamicWearables:CreateDotaCustomWearable()
			wearableEntity:SetOwner(self)
		end
		wearableEntity:SetModel(wearable.model)
		wearableEntity:FollowEntity(self, true)
	elseif wearable.attach_method == WEARABLES_ATTACH_METHOD_ATTACHMENTS then
		if wearableEntity then
			wearableEntity:FollowEntity(nil, false)
		end
	end
	local particles = {}
	for _, particle in ipairs(wearable.particles) do
		local particleUnit = particle.bAttachToUnit and self or wearableEntity
		local pfx = ParticleManager:CreateParticle(particle.name, particle.attach, particleUnit)
		for _,control_point in ipairs(particle.control_points) do
			if control_point.vector then
				ParticleManager:SetParticleControl(pfx, control_point.index, control_point.vector)
			else
				--print(control_point.index, control_point.attachment)
				--print(particleUnit:GetUnitName())
				ParticleManager:SetParticleControlEnt(pfx, control_point.index, particleUnit, control_point.attach, control_point.attachment or "attach_hitloc", particleUnit:GetAbsOrigin(), false)
			end
		end
		table.insert(particles, pfx)
	end
	self.EquippedWearables = self.EquippedWearables or {}
	self.EquippedWearables[wearable.slot] = {
		id = wearableId,
		entity = wearableEntity,
		attached_particles = particles,
		particle_map = wearable.particle_map
	}
end

function DynamicWearables:CanPlayerEquipWearable(PlayerID, wearableId)
	local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
	if hero then
		local heroname = GetFullHeroName(hero)
		local DotaHeroWearables = self.DotaWearablesByHeroes[heroname]
		if DotaHeroWearables[tonumber(wearableId)] then
			return true
		end
	end
	return false
end

function DynamicWearables:EquipWearableOnPlayer(PlayerID, wearableId)
	if self:CanPlayerEquipWearable(PlayerID, wearableId) then
		local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
		hero:EquipWearable(wearableId)
	end
end

function DynamicWearables:ParseData()
	for wearableId, wearableData in pairsByKeys(DynamicWearables.RawItemsKV.items) do
		if wearableData.prefab == "wearable" or wearableData.prefab == "default_item" then
			wearableId = tonumber(wearableId)
			local newWearable = {
				--image_inventory
				slot = wearableData.item_slot or "weapon",
				model = wearableData.model_player,
				attach_method = WEARABLES_ATTACH_METHOD_DOTA,
				particle_map = {},
				particles = {},
				additional_attached_models = {},
			--	panorama_name = wearableData.item_name or "",
			--	panorama_description = wearableData.item_description or "",
			--	panorama_type_name = wearableData.item_type_name or "",
			}
			if wearableData.used_by_heroes then
				for hero, enabled in pairs(wearableData.used_by_heroes) do
					if enabled == 1 then
						DynamicWearables.DotaWearablesByHeroes[hero] = DynamicWearables.DotaWearablesByHeroes[hero] or {}
						table.insert(DynamicWearables.DotaWearablesByHeroes[hero], wearableId)
						if wearableData.prefab == "default_item" then
							DynamicWearables.DefaultWearables[hero] = DynamicWearables.DefaultWearables[hero] or {}
							DynamicWearables.DefaultWearables[hero][newWearable.slot] = wearableId
						end
					end
				end
			end
			if wearableData.visuals then
				--DynamicWearables.RawItemsKV.asset_modifiers TODO
				for k,v in pairs(wearableData.visuals) do
					if string.starts(k, "asset_modifier") then
						--"entity_model"
						--"ability_icon"
						local visualType = v.type
						if visualType == "particle_create" then
							for _, pfx in pairs(DynamicWearables.RawItemsKV.attribute_controlled_attached_particles) do
								if pfx.system == v.modifier then
									local particle_system = {
										name = pfx.system,
										attach = DynamicWearables.KVAttachTypeToLua[pfx.attach_type] or PATTACH_ABSORIGIN_FOLLOW,
										bAttachToUnit = pfx.attach_entity == "parent",
										control_points = {}
									}
									if pfx.control_points then
										for _,control_point in pairs(pfx.control_points) do
											local t = {
												index = control_point.control_point_index,
												attach = DynamicWearables.KVAttachTypeToLua[control_point.attach_type] or PATTACH_ABSORIGIN_FOLLOW,
												attachment = control_point.attachment
											}
											if control_point.position then
												t.vector = Vector(unpack(string.split(control_point.position)))
											end
											table.insert(particle_system.control_points, t)
										end
									end
									table.insert(newWearable.particles, particle_system)
								end
							end
						elseif visualType == "particle" then
							newWearable.particle_map[v.asset] = v.modifier
						else
							--print("[DynamicWearables] Unhandled visual type ")
						end
					end
				end
			end
			DynamicWearables.DotaWearablesByIds[wearableId] = newWearable
		end
	end

	for wearableName, wearableData in pairs(CUSTOM_WEARABLES) do
		wearableData = {
			slot = wearableData.slot or "weapon",
			model = wearableData.model or "models/development/invisiblebox.vmdl",
			attach_method = wearableData.attach_method or WEARABLES_ATTACH_METHOD_DOTA,
			particle_map = wearableData.particle_map or {},
			particles = wearableData.particles or {},
			additional_attached_models = wearableData.additional_attached_models or {},
			used_by_heroes = wearableData.used_by_heroes or {},
			IsDefault = wearableData or false
		}
		if wearableData.IsDefault and wearableData.used_by_heroes then
			for _,hero in ipairs(wearableData.used_by_heroes) do
				DynamicWearables.DefaultWearables[hero] = DynamicWearables.DefaultWearables[hero] or {}
				DynamicWearables.DefaultWearables[hero][wearableData.slot] = wearableName
				DynamicWearables.DotaWearablesByHeroes[hero] = DynamicWearables.DotaWearablesByHeroes[hero] or {}
				table.insert(DynamicWearables.DotaWearablesByHeroes[hero], wearableName)
			end
		end
		DynamicWearables.DotaWearablesByIds[wearableName] = wearableData
	end
	--PrintTable(DynamicWearables.DotaWearablesByIds)
end

--[[function DynamicWearables:GetPanoramaWearableById(wearableId)
	local data = DynamicWearables:GetWearableDataById(wearableId)
	return {
		id = wearableId,
		name = data.panorama_name,
		description = data.panorama_description,
		type_name = data.panorama_type_name
	}
end

function DynamicWearables:PanoramaGetEquipped(data)
	local PlayerID = tonumber(data.PlayerID)
	local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
	if hero then
		local heroname = GetFullHeroName(hero)
	end
	local allEquipped = {}
	for slot, wearable in pairs(DynamicWearables.DefaultWearables[GetFullHeroName(hero)]) do
		if hero.EquippedWearables[slot] then
			allEquipped[slot] = DynamicWearables:GetPanoramaWearableById(hero.EquippedWearables[slot].id)
		else
			allEquipped[slot] = DynamicWearables:GetPanoramaWearableById(wearable)
		end
	end
end

function DynamicWearables:PanoramaGetAvaliable(data)
	local PlayerID = tonumber(data.PlayerID)
	local hero = PlayerResource:GetSelectedHeroEntity(PlayerID)
	if hero then
		local avaliable = {}
		local heroname = GetFullHeroName(hero)
		if DynamicWearables.DotaWearablesByHeroes[heroname] then
			for _,v in ipairs(DynamicWearables.DotaWearablesByHeroes[heroname]) do
				local t = DynamicWearables:GetPanoramaWearableById(v)
				local td = DynamicWearables:GetWearableDataById(v)
				if t and td then
					avaliable[td.slot] = avaliable[td.slot] or {}
					table.insert(avaliable[td.slot], t)
				end
			end
		end
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(PlayerID), "dynamic_wearables_set_avaliable", avaliable)
	end
end]]

function DynamicWearables:PrecacheAllWearablesForHero(context, hero)
	local t = DynamicWearables.DotaWearablesByHeroes[hero]
	if t then
		for _,v in ipairs(t) do
			self:PrecacheWearableByID(context, v)
		end
	end
end

function DynamicWearables:PrecacheWearableByID(context, wearableId)
	local data = DynamicWearables:GetPanoramaWearableById(wearableId)
	PrecacheModel(data.model, context)
	for _,v in ipairs(data.particles) do
		PrecacheResource("particle", v.name, context)
	end
end

function DynamicWearables:Init()
	DynamicWearables:ParseData()
	--CustomGameEventManager:RegisterListener("dynamic_wearables_get_equipped", Dynamic_Wrap(self, "PanoramaGetEquipped"))
	--CustomGameEventManager:RegisterListener("dynamic_wearables_get_avaliable", Dynamic_Wrap(self, "PanoramaGetAvaliable"))
	--[[CustomGameEventManager:RegisterListener("dynamic_wearables_equip", function(_, data)
		if data.wearableId then
			self:EquipWearableOnPlayer(tonumber(data.PlayerID), data.wearableId)
		end
	end)]]
end
if false then
	DynamicWearables:ParseData()
	PlayerResource:GetSelectedHeroEntity(0):RemoveAllWearables()
	PlayerResource:GetSelectedHeroEntity(0):EquipItemsFromPlayerSelectionOrDefault()
end