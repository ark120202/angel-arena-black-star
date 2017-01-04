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
	techies_suicide = 25,
	lina_laguna_blade = 50,
	lion_finger_of_death = 50,
	shredder_chakram_2 = 40,
	shredder_chakram = 40,
	sniper_shrapnel = 40,
	abaddon_death_coil = 40,
	abyssal_underlord_firestorm = 20,
	bristleback_quill_spray = 40,
	centaur_hoof_stomp = 40,
	centaur_double_edge = 40,
	kunkka_ghostship = 40,
	slark_dark_pact = 40,
	ember_spirit_flame_guard = 30,
	sandking_sand_storm = 40,
}

local function OctarineLifestel(attacker, victim, inflictor, damage, damagetype_const, itemname, cooldownModifierName)
	if inflictor and attacker:GetTeam() ~= victim:GetTeam() and not OCTARINE_NOT_LIFESTALABLE_ABILITIES[inflictor:GetAbilityName()] then
		local heal = math.floor(damage * GetAbilitySpecial(itemname, victim:IsHero() and "hero_lifesteal" or "creep_lifesteal") * 0.01)
		if heal >= 1 then
			if not victim:IsIllusion() then
				SafeHeal(attacker, heal, attacker)
			end
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, attacker, heal, nil)
			ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
		end

		local item = FindItemInInventoryByName(attacker, itemname, false)
		if item and RollPercentage(GetAbilitySpecial(itemname, "bash_chance")) and not attacker:HasModifier(cooldownModifierName) then
			victim:AddNewModifier(attacker, item, "modifier_stunned", {duration = GetAbilitySpecial(itemname, "bash_duration")})
			item:ApplyDataDrivenModifier(attacker, attacker, cooldownModifierName, {})
		end
	end
end
ON_DAMAGE_MODIFIER_PROCS = {
	["modifier_item_octarine_core_arena"] = function(attacker, victim, inflictor, damage, damagetype_const)
		OctarineLifestel(attacker, victim, inflictor, damage, damagetype_const, "item_octarine_core_arena", "modifier_octarine_bash_cooldown")
	end,
	["modifier_item_refresher_core"] = function(attacker, victim, inflictor, damage, damagetype_const)
		OctarineLifestel(attacker, victim, inflictor, damage, damagetype_const, "item_refresher_core", "modifier_octarine_bash_cooldown")
	end,
}

ON_DAMAGE_MODIFIER_PROCS_VICTIM = {
	["modifier_item_holy_knight_shield"] = function(attacker, victim, inflictor, damage) if inflictor then
		local item = FindItemInInventoryByName(victim, "item_holy_knight_shield", false)
		if item and RollPercentage(GetAbilitySpecial("item_holy_knight_shield", "buff_chance")) and victim:GetTeam() ~= attacker:GetTeam() then
			if PreformAbilityPrecastActions(victim, item) then
				item:ApplyDataDrivenModifier(victim, victim, "modifier_item_holy_knight_shield_buff", {})
			end
		end
	end end,
	["modifier_freya_pain_reflection"] = function(attacker, victim, inflictor, damage, damagetype_const)
		local freya_pain_reflection = victim:FindAbilityByName("freya_pain_reflection")
		local returnedDmg = damage * freya_pain_reflection:GetAbilitySpecial("damage_return_pct") * 0.01
		ApplyDamage({
			victim = attacker,
			attacker = victim,
			damage = returnedDmg,
			damage_type = freya_pain_reflection:GetAbilityDamageType(),
			ability = freya_pain_reflection
		})
		local heal = returnedDmg * freya_pain_reflection:GetAbilitySpecial("returned_to_heal_pct") * 0.01
		SafeHeal(victim, heal, victim)
		if heal then
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, victim, heal, nil)
			ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, victim)
		end
	end
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
	},
	["modifier_anakim_wisps"] = {
		condition = function(_, _, inflictor)
			return not inflictor
		end,
		multiplier = function(attacker, victim, _, damage)
			local anakim_wisps = attacker:FindAbilityByName("anakim_wisps")
			if anakim_wisps then
				local dt = {
					victim = victim,
					attacker = attacker,
					ability = anakim_wisps
				}
				dt.damage_type = DAMAGE_TYPE_PURE
				dt.damage = damage * anakim_wisps:GetAbilitySpecial("pure_damage_pct") * 0.01
				ApplyDamage(dt)
				dt.damage_type = DAMAGE_TYPE_MAGICAL
				dt.damage = damage * anakim_wisps:GetAbilitySpecial("magic_damage_pct") * 0.01
				ApplyDamage(dt)
				dt.damage_type = DAMAGE_TYPE_PHYSICAL
				dt.damage = damage * anakim_wisps:GetAbilitySpecial("physical_damage_pct") * 0.01
				ApplyDamage(dt)
				return 0
			end
		end
	},
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
				ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, victim)
				return 0
			end
		end
	}
}