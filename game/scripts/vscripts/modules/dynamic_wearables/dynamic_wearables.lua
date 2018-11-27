ModuleRequire(..., "data")
ModuleLinkLuaModifier(..., "modifier_arena_wearable")

DynamicWearables = DynamicWearables or {}

function CDOTA_BaseNPC:GetWearableInSlot(slot)
	if not self.EquippedWearables then return end
	return self.EquippedWearables[slot]
end

function DynamicWearables:CreateDotaCustomWearable()
	local wearableEntity = CreateUnitByName("npc_arena_wearable", Vector(0), false, nil, nil, DOTA_TEAM_NOTEAM)
	wearableEntity:AddNewModifier(wearableEntity, nil, "modifier_arena_wearable", nil)
	wearableEntity.SetVisible = function(self, state)
		self.WearableVisible = state
	end
	return wearableEntity
end

function DynamicWearables:GetDefaultItemsForHero(heroName)
	local items = {}

	for name, wearable in pairs(CUSTOM_WEARABLES) do
		if wearable.default and table.includes(wearable.heroes or {}, heroName) then
			items[wearable.slot] = name
		end
	end

	return items
end

function DynamicWearables:AutoEquip(unit)
	local playerId = unit:GetPlayerID()
	local heroName = unit:GetFullName()
	local equippedItems = DynamicWearables:GetDefaultItemsForHero(heroName)

	for slot, name in pairs(equippedItems) do
		if not unit.EquippedWearables or not unit.EquippedWearables[slot] then
			DynamicWearables:EquipWearable(unit, name)
		end
	end
end

function DynamicWearables:CreateTimer(unit)
	if unit.UpdateWearablesTimer then return end
	unit.UpdateWearablesTimer = Timers:CreateTimer(function()
		if not IsValidEntity(unit) then return end

		local heroInvisibilityLevel = unit:IsInvisible() and 1 or 0
		local modelChanged = unit:HasModelChanged()
		for slot, wearable in pairs(unit.EquippedWearables or {}) do
			if IsValidEntity(wearable.entity) and wearable.entity.FindModifierByName then
				local itemInvisibilityLevel = heroInvisibilityLevel
				if modelChanged or wearable.entity.WearableVisible == false then
					itemInvisibilityLevel = itemInvisibilityLevel + 1.01
				end
				local modifier = wearable.entity:FindModifierByName("modifier_arena_wearable")
				if modifier then
					modifier:SetStackCount(itemInvisibilityLevel * 100)
				end
			end
		end

		return 0.03
	end)
end

function DynamicWearables:EquipWearable(unit, name)
	local wearable = CUSTOM_WEARABLES[name]
	if not wearable then return end

	DynamicWearables:UnequipWearable(unit, wearable.slot)

	local wearableEntity
	if wearable.strategy == WEARABLES_ATTACH_STRATEGY_ATTACHMENTS then
		wearableEntity = Attachments:AttachProp(
			unit,
			wearable.attachment or "attach_hitloc",
			wearable.model or "models/development/invisiblebox.vmdl",
			wearable.scale,
			wearable.properties
		)
	elseif wearable.strategy == WEARABLES_ATTACH_METHOD_BONE_MERGE then
		wearableEntity = DynamicWearables:CreateDotaCustomWearable()
		wearableEntity:SetOwner(unit)
		wearableEntity:FollowEntity(unit, true)
		if wearable.model then
			wearableEntity:SetModel(wearable.model)
			wearableEntity:SetOriginalModel(wearable.model)
		end
	elseif wearable.model ~= nil then
		error("Wearable " .. name .. " has model but has no attach starategy")
	end

	local particles = {}
	for particleIndex, particle in ipairs(wearable.particles) do
		local particleUnit
		if particle.target == "unit" then
			particleUnit = unit
		elseif particle.target == "entity" then
			particleUnit = wearableEntity
		else
			error("Invalid particle target in " .. name .. ".particles[" .. particleIndex .. "]")
		end
		local pfx = ParticleManager:CreateParticle(particle.name, particle.attach, particleUnit)
		for _,cp in ipairs(particle.controlPoints) do
			if cp.vector then
				ParticleManager:SetParticleControl(pfx, cp.index, cp.vector)
			else
				ParticleManager:SetParticleControlEnt(
					pfx,
					cp.index,
					particleUnit,
					cp.attach,
					cp.attachment or "attach_hitloc",
					particleUnit:GetAbsOrigin(),
					false
				)
			end
		end
		table.insert(particles, pfx)
	end

	if wearable.OnCreated then
		wearable.OnCreated(wearableEntity)
	end
	unit.EquippedWearables = unit.EquippedWearables or {}
	unit.EquippedWearables[wearable.slot] = {
		name = name,
		entity = wearableEntity,
		attachedParticles = particles,
		particleMap = wearable.particleMap or {},
		SetVisible = wearableEntity and wearableEntity.SetVisible or nil
	}
	DynamicWearables:CreateTimer(unit)
end

function DynamicWearables:UnequipWearable(unit, slot)
	local previousWearable = unit:GetWearableInSlot(slot)
	if not previousWearable then return end
	for _,v in ipairs(previousWearable.attachedParticles) do
		ParticleManager:DestroyParticle(v, true)
	end
	if previousWearable.entity then UTIL_Remove(previousWearable.entity) end

	unit.EquippedWearables[slot] = nil
end

function DynamicWearables:UnequipAll(unit)
	for slot in pairs(unit.EquippedWearables or {}) do
		DynamicWearables:UnequipWearable(unit, slot)
	end
	unit.EquippedWearables = nil
end

function DynamicWearables:PrecacheUnparsedWearable(context, wearable)
	if wearable.model then
		PrecacheModel(wearable.model, context)
	end
	for _,v in ipairs(wearable.particles or {}) do
		PrecacheResource("particle", v.name, context)
	end
end

function DynamicWearables:TranslateParticleName(unit, name)
	if unit.EquippedWearables then
		for _, wearable in pairs(unit.EquippedWearables) do
			if wearable.particleMap[name] then
				name = wearable.particleMap[name]
				break
			end
		end
	end
	return name
end

createParticle = createParticle or ParticleManager.CreateParticle
function ParticleManager:CreateParticle(particle_name, attachment, unit, caster, entAttachCP, entAttachPoint)
	if type(caster) == "number" then
		entAttachPoint = entAttachCP
		entAttachCP = caster
		caster = nil
	end
	if caster or unit then
		particle_name = DynamicWearables:TranslateParticleName(caster or unit, particle_name)
	end
	local particle = createParticle(ParticleManager, particle_name, attachment, unit)
	if entAttachCP then
		ParticleManager:SetParticleControlEnt(particle, entAttachCP, unit, PATTACH_POINT_FOLLOW, entAttachPoint or "attach_hitloc", unit:GetAbsOrigin(), true)
	end
	return particle
end

function DynamicWearables:HasWearable(playerId, name)
	if PLAYER_DATA[playerId].Inventory then
		return table.includes(PLAYER_DATA[playerId].Inventory, name)
	end
	return false
end
