item_book_of_the_guardian_baseclass = {}
LinkLuaModifier("modifier_item_book_of_the_guardian", "items/modifier_item_book_of_the_guardian.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_book_of_the_guardian_effect", "items/modifier_item_book_of_the_guardian.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_book_of_the_guardian_blast", "items/modifier_item_book_of_the_guardian.lua", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function item_book_of_the_guardian_baseclass:OnSpellStart()
		local caster = self:GetCaster()
		local blast_radius = self:GetAbilitySpecial("blast_radius")
		local blast_speed = self:GetAbilitySpecial("blast_speed")
		local blast_damage_int_mult = self:GetSpecialValueFor("blast_damage_int_mult")
		local blast_debuff_duration = self:GetSpecialValueFor("blast_debuff_duration")
		local blast_vision_duration = self:GetSpecialValueFor("blast_vision_duration")
		local startTime = GameRules:GetGameTime()
		local affectedUnits = {}

		local pfx = ParticleManager:CreateParticle("particles/econ/events/ti7/shivas_guard_active_ti7.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(pfx, 1, Vector(blast_radius, blast_radius / blast_speed * 1.5, blast_speed))
		caster:EmitSound("DOTA_Item.ShivasGuard.Activate")

		Timers:CreateTimer(function()
			local now = GameRules:GetGameTime()
			local elapsed = now - startTime
			local abs = caster:GetAbsOrigin()
			self:CreateVisibilityNode(abs, blast_radius, blast_vision_duration)

			for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), abs, nil, elapsed * blast_speed, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
				if not affectedUnits[v] then
					affectedUnits[v] = true
					ApplyDamage({
						attacker = caster,
						victim = v,
						damage = caster:GetIntellect() * blast_damage_int_mult,
						damage_type = self:GetAbilityDamageType(),
						ability = self
					})

					local impact_pfx = ParticleManager:CreateParticle("particles/econ/events/ti7/shivas_guard_impact_ti7.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
					ParticleManager:SetParticleControlEnt(impact_pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
					v:AddNewModifier(caster, self, "modifier_item_book_of_the_guardian_blast", {duration = blast_debuff_duration})
				end
			end
			if elapsed * blast_speed < blast_radius then
				return 0.1
			end
		end)
	end
end

item_book_of_the_guardian = class(item_book_of_the_guardian_baseclass)
