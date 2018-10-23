LinkLuaModifier("modifier_doppelganger_mimic", "heroes/hero_doppelganger/mimic.lua", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function GenerateAbilityCooldownCache(caster)
		local cache = caster.abilityCooldownCache or {}
		for i = 0, caster:GetAbilityCount() - 1 do
			local ability = caster:GetAbilityByIndex(i)
			if ability then
				local remainingCooldown = ability:GetCooldownTimeRemaining()
				if remainingCooldown > 0 then
					cache[ability:GetAbilityName()] = GameRules:GetGameTime() + remainingCooldown
				end
			end
		end
		return cache
	end

	function ApplyAbilityCooldownsFromCache(caster, cache)
		caster.abilityCooldownCache = cache or {}
		for i = 0, caster:GetAbilityCount() - 1 do
			local ability = caster:GetAbilityByIndex(i)
			if ability then
				local abilityname = ability:GetAbilityName()
				if cache[abilityname] then
					local remainingCooldown = cache[abilityname] - GameRules:GetGameTime()
					if remainingCooldown > 0 then
						ability:StartCooldown(remainingCooldown)
					end
					cache[abilityname] = nil
				end
			end
		end
	end

	function ChangeHero(caster, targetName, callback)
		if caster.ChangingHeroProcessRunning then return end
		-- Save hero's state to give same state to new hero
		local state = {
			health = caster:GetHealth() / caster:GetMaxHealth(),
			mana = caster:GetMana() / caster:GetMaxMana(),
			Additional_str = caster.Additional_str,
			Additional_agi = caster.Additional_agi,
			Additional_int = caster.Additional_int,
			Additional_attackspeed = caster.Additional_attackspeed,
			abilityCooldownCache = GenerateAbilityCooldownCache(caster)
		}

		return HeroSelection:ChangeHero(caster:GetPlayerID(), targetName, true, nil, nil, function(newHero)
			ApplyAbilityCooldownsFromCache(newHero, state.abilityCooldownCache)
			if state.Additional_str then
				newHero.Additional_str = state.Additional_str
				newHero:ModifyStrength(state.Additional_str)
			end
			if state.Additional_agi then
				newHero.Additional_agi = state.Additional_agi
				newHero:ModifyAgility(state.Additional_agi)
			end
			if state.Additional_int then
				newHero.Additional_int = state.Additional_int
				newHero:ModifyIntellect(state.Additional_int)
			end
			if state.Additional_attackspeed then
				newHero.Additional_attackspeed = state.Additional_attackspeed
				if not newHero:HasModifier("modifier_item_shard_attackspeed_stack") then
					newHero:AddNewModifier(caster, nil, "modifier_item_shard_attackspeed_stack", {})
				end
				newHero:SetModifierStackCount("modifier_item_shard_attackspeed_stack", newHero, state.Additional_attackspeed)
			end

			newHero:SetHealth(state.health * newHero:GetMaxHealth())
			newHero:SetMana(state.mana * newHero:GetMaxMana())

			if callback then
				callback(newHero)
			end
		end, false)
	end
end


doppelganger_mimic = class({})

if IsServer() then
	function doppelganger_mimic:Spawn()
		self:SetLevel(1)
	end

	function doppelganger_mimic:OnUpgrade()
		if not self.bannedHeroes then
			self.bannedHeroes = self:GetKeyValue("BannedHeroes") or {}
		end
	end

	function doppelganger_mimic:CastFilterResultTarget(hTarget)
		return (hTarget == self:GetCaster() or hTarget:IsBoss() or self.bannedHeroes[hTarget:GetFullName()] or hTarget:IsIllusion()) and UF_FAIL_CUSTOM or UF_SUCCESS
	end

	function doppelganger_mimic:GetCustomCastErrorTarget(hTarget)
		return (hTarget == self:GetCaster() and "#dota_hud_error_cant_cast_on_self") or
			(hTarget:IsBoss() and "#dota_hud_error_ability_cant_target_boss") or
			(self.bannedHeroes[hTarget:GetFullName()] and "#arena_hud_error_cant_mimic") or
			(hTarget:IsIllusion() and "#dota_hud_error_cant_cast_on_illusions") or
			""
	end

	function doppelganger_mimic:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		self.new_steal_target = target

		caster:EmitSound("Hero_Rubick.SpellSteal.Cast")
		target:EmitSound("Hero_Rubick.SpellSteal.Target")

		ProjectileManager:CreateTrackingProjectile({
			Target = caster,
			Source = target,
			Ability = self,
			EffectName = "particles/arena/units/heroes/hero_doppelganger/mimic.vpcf",
			bDodgeable = false,
			bProvidesVision = false,
			iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
		})
	end

	function doppelganger_mimic:OnProjectileHit(hTarget, vLocation)
		local caster = self:GetCaster()
		local target = self.new_steal_target
		if IsValidEntity(target) then
			caster:EmitSound("Hero_Rubick.SpellSteal.Complete")

			ChangeHero(caster, target:GetFullName(), function(newHero)
				newHero:AddNewModifier(newHero, self, "modifier_doppelganger_mimic", nil)
				if not newHero:HasModifier("modifier_doppelganger_mimic") then
					HeroSelection:ChangeHero(newHero:GetPlayerID(), "npc_arena_hero_doppelganger", true, 0)
				end
			end)
		end
	end
end


modifier_doppelganger_mimic = class({
	IsHidden            = function() return true end,
	IsPurgable          = function() return false end,
	RemoveOnDeath       = function() return false end,
	GetAttributes       = function() return MODIFIER_ATTRIBUTE_PERMANENT end,
	GetTexture          = function() return "doppelganger_mimic" end,
	GetEffectName       = function() return "particles/units/heroes/hero_arc_warden/arc_warden_tempest_buff.vpcf" end,
	GetStatusEffectName = function() return "particles/status_fx/status_effect_arc_warden_tempest.vpcf" end,
})

if IsServer() then
	function modifier_doppelganger_mimic:DeclareFunctions()
		return {MODIFIER_EVENT_ON_RESPAWN}
	end

	function modifier_doppelganger_mimic:OnDestroy()
		local parent = self:GetParent()
		if not ChangeHero(parent, "npc_arena_hero_doppelganger") then
			-- Can't change hero now
			Timers:NextTick(function()
				parent:AddNewModifier(parent, self, "modifier_doppelganger_mimic", nil)
			end)
		end
	end
end
