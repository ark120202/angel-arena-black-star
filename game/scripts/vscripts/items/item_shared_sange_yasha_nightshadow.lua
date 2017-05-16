--TODO
function SangeOnAttack(caster, ability, target, modifier)
	if IsModifierStrongest(caster, string.gsub(modifier, "lesser_maim", "unique"), MODIFIER_PROC_PRIORITY.sange) then
		target:EmitSound("DOTA_Item.Maim")
		if target:GetModifierStackCount(modifier, caster) < ability:GetSpecialValueFor("maim_max_stacks") then
			AddStacksLua(ability, caster, target, modifier, 1, true)
		else
			ability:ApplyDataDrivenModifier(caster, target, modifier, {})
		end
	end
end

function YashaOnAttack(caster, ability, modifier)
	if IsModifierStrongest(caster, string.gsub(modifier, "fast_attack", "unique"), MODIFIER_PROC_PRIORITY.yasha) then
		if caster:GetModifierStackCount(modifier, caster) < ability:GetSpecialValueFor("fast_attack_max_stacks") then
			AddStacksLua(ability, caster, caster, modifier, 1, true)
		else
			ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
		end
	end
end

function NightshadowOnAttack(caster, cooldown_reducted, modifier)
	if IsModifierStrongest(caster, modifier, MODIFIER_PROC_PRIORITY.nightshadow) then
		for i = 0, caster:GetAbilityCount() - 1 do
			local ability = caster:GetAbilityByIndex(i)
			if ability then
				local cooldown_remaining = ability:GetCooldownTimeRemaining()
				ability:EndCooldown()
				if cooldown_remaining > cooldown_reducted then
					ability:StartCooldown(cooldown_remaining - cooldown_reducted)
				end
			end
		end
	end
end	

function SYNSModifierBuilder(itemName, options)
	options = options or {}
	local functions = options.functions or {}
	local modifierClass = class({})
	local modName = itemName .. "_unique"
	if options.sange or optins.yasha or options.nightshadow then
		table.insert(functions, MODIFIER_EVENT_ON_ATTACK_LANDED)
		function modifierClass:OnAttackLanded(keys)
			local caster = self:GetParent()
			if caster == keys.attacker then
				local ability = self:GetAbility()
				if options.sange and RollPercentage(ability:GetSpecialValueFor("chancevar")) then
					SangeOnAttack(caster, ability, target, modName)
				end
				if options.yasha and RollPercentage(ability:GetSpecialValueFor("chancevar")) then
					YashaOnAttack(caster, ability, modName)
				end
				if options.nightshadow and RollPercentage(ability:GetSpecialValueFor("chancevar")) then
					NightshadowOnAttack(caster, ability:GetSpecialValueFor("cooldown_reducted"), modName)
				end
			end
		end
	end
	function modifierClass:DeclareFunctions()
		return functions
	end
	return modifierClass
end