function CheckHealthCrit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	if (target:GetHealth() / target:GetMaxHealth()) * 100 <= ability:GetLevelSpecialValueFor("crit_health_pct", level) and RollPercentage(ability:GetLevelSpecialValueFor("crit_chance_pct", level)) and ability:PerformPrecastActions() then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_zaken_last_chance_crit", nil)
	end
end

function CheckHealth(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local hppct = (target:GetHealth() / target:GetMaxHealth()) * 100
	if ability:IsCooldownReady() and ability:IsOwnersManaEnough() and not target:IsMagicImmune() then
		if hppct <= ability:GetLevelSpecialValueFor("stun_health_pct", level) and RollPercentage(ability:GetLevelSpecialValueFor("stun_chance_pct", level)) and ability:PerformPrecastActions() then
			ParticleManager:CreateParticle("particles/arena/units/heroes/hero_zaken/last_chance_stun.vpcf", PATTACH_ABSORIGIN, caster)
			target:AddNewModifier(caster, ability, "modifier_stunned", {duration = ability:GetLevelSpecialValueFor("stun_duration", level)})
		elseif hppct <= ability:GetLevelSpecialValueFor("root_health_pct", level) and RollPercentage(ability:GetLevelSpecialValueFor("root_chance_pct", level)) and ability:PerformPrecastActions() then
			ParticleManager:CreateParticle("particles/arena/units/heroes/hero_zaken/last_chance_root.vpcf", PATTACH_ABSORIGIN, caster)
			target:AddNewModifier(caster, ability, "modifier_rooted", {duration = ability:GetLevelSpecialValueFor("root_duration", level)})
		elseif hppct <= ability:GetLevelSpecialValueFor("silence_health_pct", level) and RollPercentage(ability:GetLevelSpecialValueFor("silence_chance_pct", level)) and ability:PerformPrecastActions() then
			ParticleManager:CreateParticle("particles/arena/units/heroes/hero_zaken/last_chance_silence.vpcf", PATTACH_ABSORIGIN, caster)
			target:AddNewModifier(caster, ability, "modifier_silence", {duration = ability:GetLevelSpecialValueFor("silence_duration", level)})
		end
	end
end
