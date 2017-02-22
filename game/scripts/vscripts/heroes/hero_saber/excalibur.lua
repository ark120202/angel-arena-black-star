saber_excalibur = class({})

function saber_excalibur:GetCastRange()
	return self:GetSpecialValueFor(self:GetCaster():HasScepter() and "cast_range_scepter" or "cast_range")
end
if IsServer() then
	function saber_excalibur:OnSpellStart()
		self:GetCaster():EmitSound("Arena.Hero_Saber.Excalibur.Ex")
	end
	function saber_excalibur:OnChannelFinish(bInterrupted)
		if not bInterrupted then
			local mana = self:GetCaster():GetMana() * self:GetSpecialValueFor("mana_pct") * 0.01
			local caster = self:GetCaster()
			if caster:GetMana() >= mana then
				caster:SpendMana(mana, self)
				local width = self:GetSpecialValueFor("width")
				local damage = mana * self:GetSpecialValueFor(caster:HasScepter() and "damage_per_mana_scepter" or "damage_per_mana")
				local startpoint = caster:GetAbsOrigin()
				local attach_attack_glow = caster:ScriptLookupAttachment("attach_sword_glow")
				if attach_attack_glow ~= 0 then
					startpoint = caster:GetAttachmentOrigin(attach_attack_glow)
				end
				self:GetCaster():EmitSound("Arena.Hero_Saber.Excalibur.Calibur")
				StartAnimation(caster, {duration=1.3, activity=ACT_DOTA_CHANNEL_END_ABILITY_5})
				for i = 1, self:GetCaster():HasScepter() and 3 or 1 do
					local endpoint = startpoint + (self:GetCursorPosition() - startpoint):Normalized() * self:GetCastRange()
					endpoint.z = GetGroundHeight(endpoint, nil) + 64
					if self:GetCaster():HasScepter() then
						endpoint = RotatePosition( startpoint, QAngle(0, (i-2)*25, 0), endpoint)
					end
					Timers:CreateTimer(self:GetSpecialValueFor("delay"), function()
						if IsValidEntity(self) and IsValidEntity(caster) then
							local pfx = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_saber/excalibur.vpcf", PATTACH_CUSTOMORIGIN, caster)
							ParticleManager:SetParticleControl(pfx, 0, startpoint)
							ParticleManager:SetParticleControl(pfx, 1, endpoint)
							ParticleManager:SetParticleControl(pfx, 4, Vector(width))
							EmitSoundOnLocationWithCaster(endpoint, "Hero_Phoenix.SunRay.Beam", caster)
							Timers:CreateTimer(0.2, function()
								ParticleManager:DestroyParticle(pfx, false)
								if IsValidEntity(caster) then
									caster:StopSound("Hero_Phoenix.SunRay.Beam")
								end
							end)
							local visionAoE = 100
							local pointCount = math.ceil((endpoint-startpoint):Length2D() / visionAoE)
							for i = 0, pointCount do
								local pos = startpoint + ((endpoint-startpoint):Normalized() * visionAoE * i)
								--DebugDrawSphere(pos, Vector(255,0,0),255,100,true, 2)
								self:CreateVisibilityNode(pos, visionAoE, 2)
							end
							local enemies = FindUnitsInLine(caster:GetTeam(), startpoint, endpoint, nil, width, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags())
							for _,v in ipairs(enemies) do
								ApplyDamage({
									victim = v,
									attacker = caster,
									damage = damage,
									damage_type = self:GetAbilityDamageType(),
									damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
									ability = self
								})
							end
						end
					end)
				end
			else
				Containers:DisplayError(caster:GetPlayerID(), "#dota_hud_error_not_enough_mana")
			end
		end
	end
else
	function saber_excalibur:GetManaCost()
		return self:GetCaster():GetMana() * self:GetSpecialValueFor("mana_pct") * 0.01
	end
end