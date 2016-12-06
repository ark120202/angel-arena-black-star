COOLDOWN_REDUCTION_ABILITIES = { --reductionType can be "percent" and "constant"
	["item_octarine_core_arena"] = {
		reductionType = "percent",
		reduction = GetAbilitySpecial("item_octarine_core_arena", "bonus_cooldown_pct"),
		reductionGroup = "octarine",
	},
	["item_refresher_core"] = {
		reductionType = "percent",
		reduction = GetAbilitySpecial("item_refresher_core", "bonus_cooldown_pct"),
		reductionGroup = "octarine",
	},
}

BOSS_DAMAGE_ABILITY_MODIFIERS = { -- в процентах
	zuus_static_field = 15,
	item_blade_mail = 0,
	centaur_return = 0,
	enigma_midnight_pulse = 0,
	enigma_black_hole = 0,
}

ON_DAMAGE_MODIFIER_PROCS = {
	["modifier_item_octarine_core_arena"] = function(attacker, victim, inflictor, damage, damagetype_const) if inflictor and attacker:GetTeam() ~= victim:GetTeam() then
		local heal
		if victim:IsHero() then
			heal = damage * GetAbilitySpecial("item_octarine_core_arena", "hero_lifesteal") * 0.01
			SafeHeal(attacker, heal, attacker)
		else
			heal = damage * GetAbilitySpecial("item_octarine_core_arena", "creep_lifesteal") * 0.01
			SafeHeal(attacker, heal, attacker)
		end
		if heal then
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, attacker, heal, nil)
			ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
		end

		local item = FindItemInInventoryByName(attacker, "item_octarine_core_arena", false)
		if item and RollPercentage(GetAbilitySpecial("item_octarine_core_arena", "bash_chance")) and not attacker:HasModifier("modifier_octarine_bash_cooldown") and victim:GetTeam() ~= attacker:GetTeam() then
			victim:AddNewModifier(attacker, item, "modifier_stunned", {duration = GetAbilitySpecial("item_octarine_core_arena", "bash_duration")})
			item:ApplyDataDrivenModifier(attacker, attacker, "modifier_octarine_bash_cooldown", {})
		end
	end end,
	["modifier_item_refresher_core"] = function(attacker, victim, inflictor, damage, damagetype_const) if inflictor and attacker:GetTeam() ~= victim:GetTeam() then
		local heal
		if victim:IsHero() then
			heal = damage * GetAbilitySpecial("item_refresher_core", "hero_lifesteal") * 0.01
		else
			heal = damage * GetAbilitySpecial("item_refresher_core", "creep_lifesteal") * 0.01
		end
		SafeHeal(attacker, heal, attacker)
		if heal then
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, attacker, heal, nil)
			ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
		end

		local item = FindItemInInventoryByName(attacker, "item_refresher_core", false)
		if item and RollPercentage(GetAbilitySpecial("item_refresher_core", "bash_chance")) and not attacker:HasModifier("modifier_octarine_bash_cooldown") and victim:GetTeam() ~= attacker:GetTeam() then
			victim:AddNewModifier(attacker, item, "modifier_stunned", {duration = GetAbilitySpecial("item_refresher_core", "bash_duration")})
			item:ApplyDataDrivenModifier(attacker, attacker, "modifier_octarine_bash_cooldown", {})
		end
	end end,
}

ON_DAMAGE_MODIFIER_PROCS_VICTIM = {
	["modifier_item_holy_knight_shield"] = function(attacker, victim, inflictor, damage, damagetype_const) if inflictor then
		local item = FindItemInInventoryByName(victim, "item_holy_knight_shield", false)
		if item and RollPercentage(GetAbilitySpecial("item_holy_knight_shield", "buff_chance")) and victim:GetTeam() ~= attacker:GetTeam() then
			if PreformAbilityPrecastActions(victim, item) then
				item:ApplyDataDrivenModifier(victim, victim, "modifier_item_holy_knight_shield_buff", {})
			end
		end
	end end
}

OUTGOING_DAMAGE_MODIFIERS = {
	["modifier_kadash_assasins_skills"] = {
		multiplier = function(attacker)
			local kadash_assasins_skills = attacker:FindAbilityByName("kadash_assasins_skills")
			if kadash_assasins_skills then
				return 1 + (kadash_assasins_skills:GetAbilitySpecial("all_damage_bonus_pct") * 0.01)
			end
		end
	},
	["modifier_arena_rune_arcane"] = {
		condition = function(_, _, inflictor)
			return inflictor
		end,
		multiplier = 1.5
	},
	["modifier_kadash_strike_from_shadows"] = {
		condition = function(_, _, inflictor)
			return not inflictor
		end,
		multiplier = function(attacker, victim, _, damage)
			local kadash_strike_from_shadows = attacker:FindAbilityByName("kadash_strike_from_shadows")
			attacker:RemoveModifierByName("modifier_kadash_strike_from_shadows")
			attacker:RemoveModifierByName("modifier_invisible")
			if kadash_strike_from_shadows then
				ApplyDamage({
					victim = victim,
					attacker = attacker,
					damage = damage * kadash_strike_from_shadows:GetAbilitySpecial("magical_damage_pct") * 0.01,
					damage_type = kadash_strike_from_shadows:GetAbilityDamageType(),
					ability = kadash_strike_from_shadows
				})
				kadash_strike_from_shadows:ApplyDataDrivenModifier(attacker, victim, "modifier_kadash_strike_from_shadows_debuff", nil)
				return 0
			end
		end
	},
	["modifier_item_piercing_blade"] = {
		condition = function(_, _, inflictor)
			return not inflictor
		end,
		multiplier = function(attacker, victim, _, damage)
			local pct = GetAbilitySpecial("item_piercing_blade", "attack_damage_to_pure_pct") * 0.01
			ApplyDamage({
				victim = victim,
				attacker = attacker,
				damage = damage * pct,
				damage_type = _G[GetKeyValue("item_piercing_blade", "AbilityUnitDamageType")],
				ability = FindItemInInventoryByName(attacker, "item_piercing_blade", false)
			})
			return 1 - pct
		end
	},
	["modifier_item_haganemushi"] = {
		condition = function(_, _, inflictor)
			return not inflictor
		end,
		multiplier = function(attacker, victim, _, damage)
			local pct = GetAbilitySpecial("item_haganemushi", "attack_damage_to_pure_pct") * 0.01
			ApplyDamage({
				victim = victim,
				attacker = attacker,
				damage = damage * pct,
				damage_type = _G[GetKeyValue("item_haganemushi", "AbilityUnitDamageType")],
				ability = FindItemInInventoryByName(attacker, "item_haganemushi", false)
			})
			return 1 - pct
		end
	}
}

INCOMING_DAMAGE_MODIFIERS = {
	["modifier_mana_shield_arena"] = {
		multiplier = function(attacker, victim, _, damage)
			local medusa_mana_shield_arena = victim:FindAbilityByName("medusa_mana_shield_arena")
			if medusa_mana_shield_arena and not victim:IsIllusion() and victim:IsAlive() then
				local absorption_percent = medusa_mana_shield_arena:GetAbilitySpecial("absorption_tooltip") * 0.01
				local ndamage = damage * absorption_percent
				local mana_needed = ndamage / medusa_mana_shield_arena:GetAbilitySpecial("damage_per_mana")
				if mana_needed <= victim:GetMana() then
					victim:EmitSound("Hero_Medusa.ManaShield.Proc")

					if RollPercentage(medusa_mana_shield_arena:GetAbilitySpecial("reflect_chance")) then
						ApplyDamage({
							attacker = victim,
							victim = attacker,
							ability = medusa_mana_shield_arena,
							damage = ndamage,
							damage_type = medusa_mana_shield_arena:GetAbilityDamageType(),
						})
					end
					victim:SpendMana(mana_needed, medusa_mana_shield_arena)					
					local particleName = "particles/units/heroes/hero_medusa/medusa_mana_shield_impact.vpcf"
					local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, victim)
					ParticleManager:SetParticleControl(particle, 0, victim:GetAbsOrigin())
					ParticleManager:SetParticleControl(particle, 1, Vector(mana_needed,0,0))
					return 1 - absorption_percent
				end
			end
		end
	},
	["modifier_mirratie_sixth_sense"] = {
		multiplier = function(_, victim)
			local mirratie_sixth_sense = victim:FindAbilityByName("mirratie_sixth_sense")
			if mirratie_sixth_sense and victim:IsAlive() and RollPercentage(mirratie_sixth_sense:GetAbilitySpecial("dodge_chance_pct")) then
				print("dodge!")
				ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, victim)
				return 0
			end
		end
	}
}