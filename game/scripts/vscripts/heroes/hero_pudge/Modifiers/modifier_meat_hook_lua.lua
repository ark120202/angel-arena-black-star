modifier_meat_hook_lua = class({})

function modifier_meat_hook_lua:IsDebuff()
	return true
end


function modifier_meat_hook_lua:IsStunDebuff()
	return true
end


function modifier_meat_hook_lua:RemoveOnDeath()
	return false
end


function modifier_meat_hook_lua:OnCreated( kv )
	if IsServer() then
		
		self.Projectile = self:GetAbility().projectile
		if self:ApplyHorizontalMotionController() == false then 
			self:Destroy()
		end
	end
end


function modifier_meat_hook_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end


function modifier_meat_hook_lua:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end


function modifier_meat_hook_lua:CheckState()
	if IsServer() then
		if self:GetCaster() ~= nil and self:GetParent() ~= nil then
			if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() and ( not self:GetParent():IsMagicImmune() ) then
				return { [MODIFIER_STATE_STUNNED] = true, }
			end
		end
	end
	return {}
end


function modifier_meat_hook_lua:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		local abs = self.Projectile:GetPosition()
		if self.Projectile.newProjectile then
			abs = self.Projectile.newProjectile:GetPosition()
		end
		self:GetParent():SetOrigin(abs)
	end
end

function modifier_meat_hook_lua:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

function modifier_meat_hook_lua:IsPurgable()
	return false
end