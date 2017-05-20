item_book_of_the_guardian_baseclass = {}
LinkLuaModifier("modifier_item_book_of_the_guardian", "items/modifier_item_book_of_the_guardian.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_book_of_the_guardian_effect", "items/modifier_item_book_of_the_guardian.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_book_of_the_guardian_blast", "items/modifier_item_book_of_the_guardian.lua", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function item_book_of_the_guardian_baseclass:OnSpellStart()
		local caster = self:GetCaster()
		local blast_radius = self:GetAbilitySpecial("blast_radius")
		local blast_speed = self:GetAbilitySpecial("blast_speed")
		local fExpireTime = GameRules:GetGameTime() + blast_radius / blast_speed
		local pfx = ParticleManager:CreateParticle("", PATTACH_ABSORIGIN_FOLLOW, caster)
		local affectedUnits = {}
		Timers:CreateTimer(function()
			for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("aura_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
				if not affectedUnits[v] then
					affectedUnits[v] = true
					ApplyDamage({
						attacker = caster,
						victim = hTarget,
						damage = caster:GetIntellect() * self:GetSpecialValueFor("blast_damage_int_mult"),
						damage_type = self:GetAbilityDamageType(),
						ability = self
					})
					hTarget:AddNewModifier(caster, self, "modifier_item_book_of_the_guardian_blast", {duration = self:GetSpecialValueFor("blast_debuff_duration")})
				end
			end
			return 0.2
		end)
	end
end
--particles/items_fx/aura_shivas.vpcf
--particles/items2_fx/shivas_guard_active.vpcf
--particles/econ/events/ti7/shivas_guard_slow.vpcf
--particles/econ/events/ti7/shivas_guard_active_ti7.vpcf
item_book_of_the_guardian = class(item_book_of_the_guardian_baseclass)