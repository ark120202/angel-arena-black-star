function CreateParticles(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	Timers:CreateTimer(0.03, function()
		if caster and not caster:IsNull() then
			local modifier = caster:FindModifierByName("modifier_anakim_wisps")
			if modifier then
				for i = 1, 8 do
					local pfx = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_anakim/attack_wisp.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_spirit" .. i, caster:GetAbsOrigin(), true)
					modifier:AddParticle(pfx, false, false, -1, true, false)
				end
			end
		end
	end)
end