mirratie_impaling_shot = class({})

function mirratie_impaling_shot:GetAbilityDamageType()
	if self:GetCaster():HasScepter() then
		return DAMAGE_TYPE_PURE
	end
	return self.BaseClass.GetAbilityDamageType(self)
end

function mirratie_impaling_shot:CastFilterResultTarget( hTarget )
	if IsServer() then
		if hTarget and hTarget:IsMagicImmune() and not self:GetCaster():HasScepter() then
			return UF_FAIL_MAGIC_IMMUNE_ENEMY
		end
		return UnitFilter(hTarget, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), self:GetCaster():GetTeamNumber())
	end
	return UF_SUCCESS
end

function mirratie_impaling_shot:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("cast_range_scepter")
	end
	return self.BaseClass.GetCastRange(self, vLocation, hTarget)
end

if IsServer() then
	function mirratie_impaling_shot:OnSpellStart()
		self.ChannelTarget = self:GetCursorTarget()
		self:GetCaster():EmitSound("Ability.AssassinateLoad")
	end

	function mirratie_impaling_shot:OnChannelFinish(bInterrupted)
		if not bInterrupted then
			self:GetCaster():EmitSound("Hero_Sniper.AssassinateProjectile")
			local hTarget = self.ChannelTarget
			if hTarget then
				ProjectileManager:CreateTrackingProjectile({
					EffectName = "particles/arena/units/heroes/hero_mirratie/impaling_shot.vpcf",
					Ability = self,
					iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
					Source = self:GetCaster(),
					Target = hTarget,
					--iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2
				})
			end
		end
		self.ChannelTarget = nil
	end

	function mirratie_impaling_shot:OnProjectileHit(hTarget, vLocation)
		if hTarget and not hTarget:IsInvulnerable() and (not hTarget:IsMagicImmune() or self:GetCaster():HasScepter()) and not hTarget:TriggerSpellAbsorb(self) then
			hTarget:EmitSound("Hero_Sniper.AssassinateDamage")
			local stun_duration = self:GetSpecialValueFor("stun_duration")
			local damage = self:GetAbilityDamage()

			if self:GetCaster():HasScepter() then
				stun_duration = self:GetSpecialValueFor("stun_duration_scepter")
				damage = self:GetSpecialValueFor("damage_scepter")
			end
			local damage_table = {
				victim = hTarget,
				attacker = self:GetCaster(),
				damage = damage,
				damage_type = self:GetAbilityDamageType(),
				ability = self
			}
			ApplyDamage(damage_table)
			hTarget:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = stun_duration})

			local impale_effect_pct = self:GetSpecialValueFor("impale_effect_pct")
			damage_table.damage = damage * impale_effect_pct * 0.01
			local loc1 = hTarget:GetAbsOrigin()
			local loc2 = loc1+(loc1-self:GetCaster():GetAbsOrigin()):Normalized() * self:GetSpecialValueFor("impale_range")
			
			local pfx = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_mirratie/impaling_shot_impale.vpcf", PATTACH_ABSORIGIN, hTarget)
			ParticleManager:SetParticleControl(pfx, 0, loc2)
			ParticleManager:SetParticleControl(pfx, 1, loc1)
			self:CreateVisibilityNode(loc1, 10, 1)
			for _,v in ipairs(FindUnitsInLine(self:GetCaster():GetTeamNumber(), loc1, loc2, nil, self:GetSpecialValueFor("impale_width"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags())) do
				if v~= hTarget and (not v:IsMagicImmune() or self:GetCaster():HasScepter()) then
					damage_table.victim = v
					ApplyDamage(damage_table)
					v:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = stun_duration * impale_effect_pct * 0.01})
				end
			end
		end

		return true
	end
end