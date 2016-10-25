modifier_banned = class({})

if IsServer() then
	function modifier_banned:OnCreated(keys)
		CustomGameEventManager:Send_ServerToPlayer(self:GetParent():GetPlayerOwner(), "apply_moidifer_banned", {})
		CustomGameEventManager:Send_ServerToPlayer(self:GetParent():GetPlayerOwner(), "time_hide", {})
	end

	function modifier_banned:OnDestroy()
		CustomGameEventManager:Send_ServerToPlayer(self:GetParent():GetPlayerOwner(), "remove_moidifer_banned", {})
		CustomGameEventManager:Send_ServerToPlayer(self:GetParent():GetPlayerOwner(), "time_show", {})
	end
end