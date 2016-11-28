function DoppelgangerEnd( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability	
	local radius = ability:GetLevelSpecialValueFor( "target_radius", ability:GetLevel() - 1 )
	
	target:RemoveNoDraw()	
	target:SetAbsOrigin(target.doppleganger_position)
	FindClearSpaceForUnit(target, target.doppleganger_position, true)
	
	if target == caster then
		for i = 1, ability:GetLevelSpecialValueFor("illusion_count", ability:GetLevel()-1) do
			local illusion = CreateIllusion(caster, ability, caster:GetAbsOrigin() + RandomVector(RandomInt(0, radius)), ability:GetLevelSpecialValueFor("illusion_incoming_damage", ability:GetLevel()-1) - 100, ability:GetLevelSpecialValueFor("illusion_outgoing_damage", ability:GetLevel()-1) - 100, ability:GetLevelSpecialValueFor("illusion_duration", ability:GetLevel()-1))
			illusion:SetForwardVector(caster:GetForwardVector())
		end
		caster:AddNewModifier(caster, ability, "modifier_invisible", {duration = ability:GetLevelSpecialValueFor("invisibilty_duration", ability:GetLevel()-1)})
	end
end

function DoppelgangerStart( keys )
	local target = keys.target
	target:Purge( false, true, false, false, false)
	target:AddNoDraw()
end

function CheckUnits(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor( "delay", ability:GetLevel() - 1 )
	local radius = ability:GetLevelSpecialValueFor( "target_radius", ability:GetLevel() - 1 )

	if target:GetMainControllingPlayer() == caster:GetMainControllingPlayer() and (target:IsIllusion() or target == caster) then
		local rand_position = ability:GetCursorPosition() + RandomVector(RandomInt(0, radius))
		target.doppleganger_position = rand_position

		local dopple_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_doppleganger_illlmove.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(dopple_particle, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(dopple_particle, 1, rand_position)

		ability:ApplyDataDrivenModifier(caster, target, "modifier_phantom_lancer_doppelganger_arena", {Duration = duration})
	end
end