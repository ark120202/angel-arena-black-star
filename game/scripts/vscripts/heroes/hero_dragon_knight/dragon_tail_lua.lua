dragon_knight_dragon_tail_arena = class({})
function dragon_knight_dragon_tail_arena:GetCastRange()
	if self:GetCaster() and self:GetCaster().HasModifier and self:GetCaster():HasModifier("modifier_elder_dragon_form_lua") then
		return self:GetSpecialValueFor("dragon_cast_range")
	else
		return self:GetSpecialValueFor("cast_range")
	end
end

function dragon_knight_dragon_tail_arena:OnSpellStart()
	if IsServer() then
		local target = self:GetCursorTarget()

		if target and not target:IsMagicImmune() and not target:IsInvulnerable() then
			target:EmitSound("Hero_DragonKnight.DragonTail.Target")
			ParticleManager:CreateParticle("particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			target:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = self:GetSpecialValueFor("stun_duration")})

			ApplyDamage({
				attacker = self:GetCaster(),
				victim = target,
				damage_type = self:GetAbilityDamageType(),
				damage = self:GetAbilityDamage(),
				ability = self
			})

			for i = 1, self:GetSpecialValueFor("attack_amount") do
				Timers:CreateTimer(self:GetSpecialValueFor("attack_delay") * i, function()
					PerformGlobalAttack(self:GetCaster(), target, true, true, true, true, false, false, false)
				end)
			end
		end
	end
end