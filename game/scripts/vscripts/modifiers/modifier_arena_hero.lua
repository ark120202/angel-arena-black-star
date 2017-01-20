modifier_arena_hero = class({})

function modifier_arena_hero:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_REFLECT_SPELL,
		MODIFIER_PROPERTY_ABSORB_SPELL,
	}
end

function modifier_arena_hero:IsPurgable()
	return false
end

function modifier_arena_hero:IsHidden()
	return true
end

function modifier_arena_hero:RemoveOnDeath()
	return false
end

function modifier_arena_hero:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

if IsServer() then
	modifier_arena_hero.HeroLevel = 1
	function modifier_arena_hero:OnCreated()
		self:StartIntervalThink(0.3)
	end

	function modifier_arena_hero:OnIntervalThink()
		local parent = self:GetParent()
		local hl = parent:GetLevel()
		if hl > self.HeroLevel  then
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
	end

	--[[function modifier_arena_hero:OnAttackStart(keys)
		local parent = self:GetParent()
		if keys.attacker == parent and keys.target:IsCustomRune() then
			
		end
	end]]
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
		self.absorb_without_check = false
		local item_lotus_sphere = FindItemInInventoryByName(parent, "item_lotus_sphere", false, false, true)
		if not self.absorb_without_check and parent:HasModifier("modifier_antimage_spell_shield_arena_reflect") then
			parent:EmitSound("Hero_Antimage.SpellShield.Reflect")
			self.absorb_without_check = true
		end
		if not self.absorb_without_check and item_lotus_sphere and parent:HasModifier("modifier_item_lotus_sphere") and PreformAbilityPrecastActions(parent, item_lotus_sphere) then
			ParticleManager:SetParticleControlEnt(ParticleManager:CreateParticle("particles/arena/items_fx/lotus_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent), 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
			parent:EmitSound("Item.LotusOrb.Activate")
			self.absorb_without_check = true 
		end
		if self.absorb_without_check then
			if IsValidEntity(self.reflect_stolen_ability) then
				self.reflect_stolen_ability:RemoveSelf()
			end
			local hCaster = self:GetParent()
			local hAbility = hCaster:AddAbility(keys.ability:GetAbilityName())
			if hAbility then
				hAbility:SetStolen(true)
				hAbility:SetHidden(true)
				hAbility:SetLevel(keys.ability:GetLevel())
				hCaster:SetCursorCastTarget(keys.ability:GetCaster())
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