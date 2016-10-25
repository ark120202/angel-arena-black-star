function InitializeFunctions(keys)
	local caster = keys.caster
	function caster:DisablePortal()
		if self.Teleport_Enabled then
			if self.particlefx ~= nil then
				ParticleManager:DestroyParticle(self.particlefx, false)
			end
			self.particlefx = ParticleManager:CreateParticle(self.Teleport_DisabledParticleName, PATTACH_ABSORIGIN, self)
			self.Teleport_Enabled = false
		end
	end
	function caster:EnablePortal()
		if not self.Teleport_Enabled then
			if self.particlefx ~= nil then
				ParticleManager:DestroyParticle(self.particlefx, false)
			end
			self.particlefx = ParticleManager:CreateParticle(self.Teleport_ParticleName, PATTACH_ABSORIGIN, self)
			self.Teleport_Enabled = true
		end
	end
end

function Teleport(keys)
	local caster = keys.caster
	if caster.Teleport_Enabled then
		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, caster.Teleport_Radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for _,v in ipairs(units) do
			if v ~= caster then
				if not caster.Teleport_Looped or (caster.Teleport_Looped and (not v.LastTeleportTime or GameRules:GetGameTime() - v.LastTeleportTime > 0.5)) then
					v:Stop()
					PlayerResource:SetCameraTarget(v:GetPlayerOwnerID(), v)
					FindClearSpaceForUnit(v, caster.Teleport_Target, true)
					Timers:CreateTimer(0.1, function() PlayerResource:SetCameraTarget(v:GetPlayerOwnerID(), nil); v:Stop() end)
					if caster.Teleport_ActionOnTeleport then
						caster:Teleport_ActionOnTeleport()
					end
				end
				v.LastTeleportTime = GameRules:GetGameTime()
			end
		end
	end
end