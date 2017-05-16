item_book_of_the_guardian_baseclass = {}

if IsServer() then
	function item_book_of_the_guardian_baseclass:OnSpellStart()
		ProjectileManager:CreateLinearProjectile({
			Ability = self,
			EffectName = "particles/arena/invisiblebox.vpcf",
			vSpawnOrigin = caster:GetAbsOrigin(),
			Source = caster,
			bHasFrontalCone = true,
			bReplaceExisting = false,
			fStartRadius = self:GetAbilitySpecial("start_radius"),
			fEndRadius = self:GetAbilitySpecial("end_radius"),
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			vVelocity = Vector(0),
			fExpireTime = GameRules:GetGameTime() + self:GetAbilitySpecial("blast_radius")/self:GetAbilitySpecial("blast_speed"),
			--bDeleteOnHit = false,
		})
	end
end
--particles/items_fx/aura_shivas.vpcf
--particles/items2_fx/shivas_guard_active.vpcf
--particles/econ/events/ti7/shivas_guard_slow.vpcf
--particles/econ/events/ti7/shivas_guard_active_ti7.vpcf
item_book_of_the_guardian = class(item_book_of_the_guardian_baseclass)