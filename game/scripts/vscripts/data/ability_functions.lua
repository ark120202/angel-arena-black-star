BOSS_DAMAGE_ABILITY_MODIFIERS = { -- в процентах
	zuus_static_field = 10,
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
	kunkka_torrent = 40,
	slark_dark_pact = 40,
	ember_spirit_flame_guard = 30,
	sandking_sand_storm = 40,
	antimage_mana_void_arena = 0,
	ancient_apparition_ice_blast = 0,
	doom_bringer_infernal_blade = 10,
	winter_wyvern_arctic_burn = 10,
	freya_ice_cage = 10
}

local function OctarineLifesteal(attacker, victim, inflictor, damage, damagetype_const, itemname, cooldownModifierName)
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
	modifier_item_octarine_core_arena = function(attacker, victim, inflictor, damage, damagetype_const)
		OctarineLifesteal(attacker, victim, inflictor, damage, damagetype_const, "item_octarine_core_arena", "modifier_octarine_bash_cooldown")
	end,
	modifier_item_refresher_core = function(attacker, victim, inflictor, damage, damagetype_const)
		OctarineLifesteal(attacker, victim, inflictor, damage, damagetype_const, "item_refresher_core", "modifier_octarine_bash_cooldown")
	end,
	modifier_sara_evolution = function(attacker, victim, _, damage)
		local ability = attacker:FindAbilityByName("sara_evolution")
		if ability and attacker.ModifyEnergy then
			attacker:ModifyEnergy(damage * ability:GetSpecialValueFor("damage_to_energy_pct") * 0.01, true)
		end
	end,
}

ON_DAMAGE_MODIFIER_PROCS_VICTIM = {
	modifier_item_holy_knight_shield = function(attacker, victim, inflictor, damage) if inflictor then
		local item = FindItemInInventoryByName(victim, "item_holy_knight_shield", false)
		if item and RollPercentage(GetAbilitySpecial("item_holy_knight_shield", "buff_chance")) and victim:GetTeam() ~= attacker:GetTeam() then
			if PreformAbilityPrecastActions(victim, item) then
				item:ApplyDataDrivenModifier(victim, victim, "modifier_item_holy_knight_shield_buff", {})
			end
		end
	end end,
}

OUTGOING_DAMAGE_MODIFIERS = {
	modifier_kadash_assasins_skills = {
		multiplier = function(attacker)
			local kadash_assasins_skills = attacker:FindAbilityByName("kadash_assasins_skills")
			if kadash_assasins_skills then
				return 1 + (kadash_assasins_skills:GetAbilitySpecial("all_damage_bonus_pct") * 0.01)
			end
		end
	},
	modifier_arena_rune_arcane = {
		condition = function(_, _, inflictor)
			return inflictor
		end,
		multiplier = 1.5
	},
	modifier_kadash_strike_from_shadows = {
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
	modifier_item_piercing_blade = {
		condition = function(attacker, _, inflictor)
			return not inflictor and not attacker:HasModifier("modifier_item_haganemushi")
		end,
		multiplier = function(attacker, victim, _, damage, damagetype)
			local pct = GetAbilitySpecial("item_piercing_blade", "attack_damage_to_pure_pct") * 0.01
			ApplyDamage({
				victim = victim,
				attacker = attacker,
				damage = GetPreMitigationDamage(damage, victim, attacker, damagetype) * pct,
				damage_type = _G[GetKeyValue("item_piercing_blade", "AbilityUnitDamageType")],
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				ability = FindItemInInventoryByName(attacker, "item_piercing_blade", false)
			})
			return 1 - pct
		end
	},
	modifier_item_haganemushi = {
		condition = function(_, _, inflictor)
			return not inflictor
		end,
		multiplier = function(attacker, victim, _, damage, damagetype)
			local pct = GetAbilitySpecial("item_haganemushi", "attack_damage_to_pure_pct") * 0.01
			ApplyDamage({
				victim = victim,
				attacker = attacker,
				damage = GetPreMitigationDamage(damage, victim, attacker, damagetype) * pct,
				damage_type = _G[GetKeyValue("item_haganemushi", "AbilityUnitDamageType")],
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				ability = FindItemInInventoryByName(attacker, "item_haganemushi", false)
			})
			return 1 - pct
		end
	},
	modifier_sai_release_of_forge = {

		condition = function(_, _, inflictor)
			return not inflictor
		end,
		multiplier = function(attacker, victim, _, damage, damagetype)
			local ability = attacker:FindAbilityByName("sai_release_of_forge")
			local pct = ability:GetSpecialValueFor("pure_damage_pct") * 0.01
			ApplyDamage({
				victim = victim,
				attacker = attacker,
				damage = GetPreMitigationDamage(damage, victim, attacker, damagetype) * pct,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				ability = ability
			})
			return 1 - pct
		end
	},
	modifier_anakim_wisps = {
		condition = function(_, _, inflictor)
			return not inflictor
		end,
		multiplier = function(attacker, victim, _, damage)
			local anakim_wisps = attacker:FindAbilityByName("anakim_wisps")
			if anakim_wisps then
				local dt = {
					victim = victim,
					attacker = attacker,
					ability = anakim_wisps,
					damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
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
	modifier_item_golden_eagle_relic_unique = function(_, _, inflictor)
		if not IsValidEntity(inflictor) then
			return {
				LifestealPercentage = GetAbilitySpecial("item_golden_eagle_relic", "lifesteal_pct")
			}
		end
	end,
	modifier_item_lucifers_claw_unique = function(_, _, inflictor)
		if not IsValidEntity(inflictor) then
			return {
				LifestealPercentage = GetAbilitySpecial("item_lucifers_claw", "lifesteal_percent")
			}
		end
	end,
	modifier_soul_eater_demon_weapon_from = function(attacker, victim, inflictor)
		if not inflictor then
			return 0
		end
	end
}

INCOMING_DAMAGE_MODIFIERS = {
	modifier_mana_shield_arena = {
		multiplier = function(attacker, victim, _, damage)
			local medusa_mana_shield_arena = victim:FindAbilityByName("medusa_mana_shield_arena")
			if medusa_mana_shield_arena and not victim:IsIllusion() and victim:IsAlive() and not victim:PassivesDisabled() then
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
	modifier_mirratie_sixth_sense = {
		multiplier = function(_, victim)
			local mirratie_sixth_sense = victim:FindAbilityByName("mirratie_sixth_sense")
			if mirratie_sixth_sense and victim:IsAlive() and RollPercentage(mirratie_sixth_sense:GetAbilitySpecial("dodge_chance_pct")) and not victim:PassivesDisabled() then
				ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, victim)
				return 0
			end
		end
	},
	modifier_item_blade_mail_arena_active = {
		multiplier = function(_, victim)
			local modifier = victim:FindModifierByNameAndCaster("modifier_item_blade_mail_arena_active", victim)
			if modifier and IsValidEntity(modifier:GetAbility()) then
				return 1 - modifier:GetAbility():GetAbilitySpecial("reduced_damage_pct") * 0.01
			end
		end
	},
	modifier_item_sacred_blade_mail_active = {
		multiplier = function()
			return 1 - GetAbilitySpecial("item_sacred_blade_mail", "reduced_damage_pct") * 0.01
		end
	},
	modifier_saber_instinct = {
		multiplier = function(attacker, victim, inflictor, damage)
			local saber_instinct = victim:FindAbilityByName("saber_instinct")
			if not IsValidEntity(inflictor) and saber_instinct and victim:IsAlive() and not victim:PassivesDisabled() then
				if attacker:IsRangedUnit() then
					if RollPercentage(saber_instinct:GetAbilitySpecial("ranged_evasion_pct")) then
						PopupEvadeMiss(victim, attacker)
						ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, victim)
						return false
					end
				else
					if RollPercentage(saber_instinct:GetAbilitySpecial("melee_block_chance")) then
						local blockPct = saber_instinct:GetAbilitySpecial("melee_damage_pct") * 0.01
						return {
							BlockedDamage = blockPct * damage,
						}
					end
				end
			end
		end
	},
	modifier_sara_fragment_of_armor = {
		multiplier = function(attacker, victim, inflictor, damage)
			local sara_fragment_of_armor = victim:FindAbilityByName("sara_fragment_of_armor")
			if sara_fragment_of_armor and not victim:IsIllusion() and victim:IsAlive() and not victim:PassivesDisabled() and victim.GetEnergy and sara_fragment_of_armor:GetToggleState() then
				local blocked_damage_pct = sara_fragment_of_armor:GetAbilitySpecial("blocked_damage_pct") * 0.01
				local mana_needed = (damage * blocked_damage_pct) / sara_fragment_of_armor:GetAbilitySpecial("damage_per_energy")
				if victim:GetEnergy() >= mana_needed then
					victim:EmitSound("Hero_Medusa.ManaShield.Proc")
					victim:ModifyEnergy(-mana_needed)
					local particleName = "particles/arena/units/heroes/hero_sara/fragment_of_armor_impact.vpcf"
					local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, victim)
					ParticleManager:SetParticleControl(particle, 0, victim:GetAbsOrigin())
					ParticleManager:SetParticleControl(particle, 1, Vector(mana_needed,0,0))
					return 1 - blocked_damage_pct
				end
			end
		end
	},
	modifier_arena_healer = {damage = 1},
	modifier_anakim_transfer_pain = {
		multiplier = function(attacker, victim, inflictor, damage)
			local anakim_transfer_pain = victim:FindAbilityByName("anakim_transfer_pain")
			if anakim_transfer_pain and victim:IsAlive() then
				local transfered_damage_pct = anakim_transfer_pain:GetAbilitySpecial("transfered_damage_pct")
				local radius = anakim_transfer_pain:GetAbilitySpecial("radius")
				local dealt_damage = damage * transfered_damage_pct * 0.01
				local summonTable = victim.custom_summoned_unit_ability_anakim_summon_divine_knight

				if summonTable and IsValidEntity(summonTable[1]) and summonTable[1]:IsAlive() and (summonTable[1]:GetAbsOrigin() - victim:GetAbsOrigin()):Length2D() <= radius then
					ApplyDamage({
						attacker = attacker,
						victim = summonTable[1],
						ability = anakim_transfer_pain,
						damage = dealt_damage,
						damage_type = DAMAGE_TYPE_PURE
					})
					return 1 - transfered_damage_pct * 0.01
				end
			end
		end
	},
	modifier_item_timelords_butterfly = {
		multiplier = function(_, victim)
			if victim:IsAlive() and not victim:IsMuted() and RollPercentage(GetAbilitySpecial("item_timelords_butterfly", "dodge_chance_pct")) then
				ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, victim)
				return false
			end
		end
	},
}

CREEP_BONUSES_MODIFIERS = {
	modifier_item_golden_eagle_relic_unique = {gold = GetAbilitySpecial("item_golden_eagle_relic", "kill_gold"), xp = GetAbilitySpecial("item_golden_eagle_relic", "kill_xp")},
	modifier_say_demonic_power = function(self)
		local ability = self:FindAbilityByName("say_demonic_power")
		if abiltiy then
			return {gold = ability:GetLevelSpecialValueFor("bonus_creep_gold", ability:GetLevel() - 1)}
		end
	end,
	modifier_item_skull_of_midas = {gold = GetAbilitySpecial("item_skull_of_midas", "kill_gold"), xp = GetAbilitySpecial("item_skull_of_midas", "kill_xp")},
	modifier_talent_creep_gold = function(self)
		local modifier = self:FindModifierByName("modifier_talent_creep_gold")
		if modifier then
			return {gold = modifier:GetStackCount()}
		end
	end
}
