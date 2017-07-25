LinkLuaModifier("modifier_doppelganger_mimic", "heroes/hero_doppelganger/mimic.lua", LUA_MODIFIER_MOTION_NONE)

doppelganger_mimic = class({})

if IsServer() then
	function doppelganger_mimic:Spawn()
		self.bannedHeroes = self:GetKeyValue("BannedHeroes") or {}
		self:SetLevel(1)
	end

	function doppelganger_mimic:CastFilterResultTarget(hTarget)
		return (hTarget == self:GetCaster() or hTarget:IsBoss() or self.bannedHeroes[hTarget:GetFullName()]) and UF_FAIL_CUSTOM or UF_SUCCESS
	end

	function doppelganger_mimic:GetCustomCastErrorTarget(hTarget)
		return (hTarget == self:GetCaster() and "#dota_hud_error_cant_cast_on_self") or
			(hTarget:IsBoss() and "#dota_hud_error_ability_cant_target_boss") or
			(self.bannedHeroes[hTarget:GetFullName()] and "#arena_hud_error_cant_mimic") or
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
			HeroSelection:ChangeHero(caster:GetPlayerID(), target:GetFullName(), true, 0, nil, function(newHero)
				newHero:AddNewModifier(newHero, self, "modifier_doppelganger_mimic", nil)
				if not newHero:HasModifier("modifier_doppelganger_mimic") then
					HeroSelection:ChangeHero(newHero:GetPlayerID(), "npc_arena_hero_doppelganger", true, 0)
				end
			end)
		end
	end
end


modifier_doppelganger_mimic = class({
	IsHidden   = function() return true end,
	IsPurgable = function() return false end,
	GetTexture = function() return "doppelganger_mimic" end,
})

if IsServer() then
	function modifier_doppelganger_mimic:OnDestroy()
		HeroSelection:ChangeHero(self:GetParent():GetPlayerID(), "npc_arena_hero_doppelganger", true, 0, nil, function(newHero)

		end)
	end
end
