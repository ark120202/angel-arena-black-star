modifier_arena_hero = class({
	IsPurgable    = function() return false end,
	IsHidden      = function() return true end,
	RemoveOnDeath = function() return false end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_PERMANENT end,
})

function modifier_arena_hero:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_REFLECT_SPELL,
		MODIFIER_PROPERTY_ABSORB_SPELL,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_ABILITY_LAYOUT,
		MODIFIER_EVENT_ON_RESPAWN
	}
end

function modifier_arena_hero:GetModifierAbilityLayout()
	return self.VisibleAbilitiesCount or self:GetSharedKey("VisibleAbilitiesCount") or 4
end

if IsServer() then
	modifier_arena_hero.HeroLevel = 1
	function modifier_arena_hero:OnCreated()
		self:StartIntervalThink(0.2)
	end

	function modifier_arena_hero:OnIntervalThink()
		local parent = self:GetParent()
		local hl = parent:GetLevel()
		if hl > self.HeroLevel  then
			if not parent:IsIllusion() then
				for i = self.HeroLevel + 1, hl do
					if LEVELS_WITHOUT_ABILITY_POINTS[i] then
						parent:SetAbilityPoints(parent:GetAbilityPoints() + 1)
					end
				end
			end
			local diff = hl - self.HeroLevel
			self.HeroLevel = hl
			--print("Adding str, agi, int, times: ", parent.CustomGain_Strength, parent.CustomGain_Agility, parent.CustomGain_Intelligence, diff)
			if parent.CustomGain_Strength then
				parent:ModifyStrength((parent.CustomGain_Strength - parent:GetKeyValue("AttributeStrengthGain", nil, true)) * diff)
			end
			if parent.CustomGain_Intelligence then
				parent:ModifyIntellect((parent.CustomGain_Intelligence - parent:GetKeyValue("AttributeIntelligenceGain", nil, true)) * diff)
			end
			if parent.CustomGain_Agility then
				parent:ModifyAgility((parent.CustomGain_Agility - parent:GetKeyValue("AttributeAgilityGain", nil, true)) * diff)
			end
		end
		local VisibleAbilitiesCount = 0
		for i = 0, parent:GetAbilityCount() - 1 do
			local ability = parent:GetAbilityByIndex(i)
			if ability and not ability:IsHidden() and not ability:GetAbilityName():starts("special_bonus_") then
				VisibleAbilitiesCount = VisibleAbilitiesCount + 1
			end
		end

		if self.VisibleAbilitiesCount ~= VisibleAbilitiesCount then
			self.VisibleAbilitiesCount = VisibleAbilitiesCount
			self:SetSharedKey("VisibleAbilitiesCount", VisibleAbilitiesCount)
		end
	end

	function modifier_arena_hero:OnDeath(k)
		local parent = self:GetParent()
		if k.attacker == parent and k.unit:IsCreep() then
			local gold = 0
			local xp = 0
			for k,v in pairs(CREEP_BONUSES_MODIFIERS) do
				if parent:HasModifier(k) then
					local gxp = type(v) == "function" and v(parent) or v
					if gxp then
						gold = math.max(gold, gxp.gold or 0)
						xp = math.max(xp, gxp.xp or 0)
					end
				end
			end
			if gold > 0 then
				Gold:ModifyGold(parent, gold)
				local particle = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf", PATTACH_ABSORIGIN, k.unit, parent:GetPlayerOwner())
				ParticleManager:SetParticleControl(particle, 1, Vector(0, gold, 0))
				ParticleManager:SetParticleControl(particle, 2, Vector(2, string.len(gold) + 1, 0))
				ParticleManager:SetParticleControl(particle, 3, Vector(255, 200, 33))
			end
			if xp > 0 then
				parent:AddExperience(xp, false, false)
			end
		end
		if k.unit == parent then
			parent:RemoveNoDraw()

			if parent:IsIllusion() then
				parent:ClearNetworkableEntityInfo()
			end
		end
	end

	function modifier_arena_hero:OnRespawn(k)
		-- TODO: Check if still required
		if k.unit == self:GetParent() and k.unit:GetUnitName() == "npc_dota_hero_crystal_maiden" then
			k.unit:AddNoDraw()
			Timers:CreateTimer(0.03, function()
				k.unit:RemoveNoDraw()
			end)
		end
	end

	function modifier_arena_hero:OnAttackStart(keys)
		local parent = self:GetParent()
		if keys.attacker == parent and keys.target:IsCustomRune() then
			parent:Stop()
			ExecuteOrderFromTable({
				UnitIndex = parent:GetEntityIndex(),
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
				Position = parent:GetAbsOrigin(),
			})
		end
	end
	function modifier_arena_hero:OnAbilityExecuted(keys)
		if self:GetParent() == keys.unit then
			local ability_cast = keys.ability
			local abilityname = ability_cast ~= nil and ability_cast:GetAbilityName()
			local caster = self:GetParent()
			local target = keys.target or caster:GetCursorPosition()
			if caster.talents_ability_multicast and caster.talents_ability_multicast[abilityname] then
				for i = 1, caster.talents_ability_multicast[abilityname] - 1 do
					Timers:CreateTimer(0.1*i, function()
						if IsValidEntity(caster) and IsValidEntity(ability_cast) then
							CastAdditionalAbility(caster, ability_cast, target)
						end
					end)
				end
			end
		end
	end
	function modifier_arena_hero:OnDestroy()
		if IsValidEntity(self.reflect_stolen_ability) then
			self.reflect_stolen_ability:RemoveSelf()
		end
	end
	function modifier_arena_hero:GetReflectSpell(keys)
		local parent = self:GetParent()
		if parent:IsIllusion() then return end
		local originalAbility = keys.ability
		self.absorb_without_check = false
		if originalAbility:GetCaster():GetTeam() == parent:GetTeam() then return end

		local item_lotus_sphere = FindItemInInventoryByName(parent, "item_lotus_sphere", false, false, true)

		if not self.absorb_without_check and item_lotus_sphere and parent:HasModifier("modifier_item_lotus_sphere") and item_lotus_sphere:PerformPrecastActions() then
			ParticleManager:SetParticleControlEnt(ParticleManager:CreateParticle("particles/arena/items_fx/lotus_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent), 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
			parent:EmitSound("Item.LotusOrb.Activate")
			self.absorb_without_check = true
		end

		if self.absorb_without_check then
			if IsValidEntity(self.reflect_stolen_ability) then
				self.reflect_stolen_ability:RemoveSelf()
			end
			local hCaster = self:GetParent()
			local hAbility = hCaster:AddAbility(originalAbility:GetAbilityName())
			if hAbility then
				hAbility:SetStolen(true)
				hAbility:SetHidden(true)
				hAbility:SetLevel(originalAbility:GetLevel())
				hCaster:SetCursorCastTarget(originalAbility:GetCaster())
				hAbility:OnSpellStart()
				hAbility:SetActivated(false)
				self.reflect_stolen_ability = hAbility
			end
		end
	end
	function modifier_arena_hero:GetAbsorbSpell(keys)
		local parent = self:GetParent()
		if self.absorb_without_check then
			self.absorb_without_check = nil
			return 1
		end
		return false
	end
end
