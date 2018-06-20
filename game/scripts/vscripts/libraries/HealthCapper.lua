if not HealthCapper then
	HealthCapper = {}
end

function HealthCapper:Think()
	
	if not IsValidEntity(self) then
		return
	end
	
	local MaxHealth = self:GetMaxHealth()
	if MaxHealth <= 0 or MaxHealth > 2000000000 then
		self:SetMaxHealth(2000000000)
		self:SetHealth(2000000000)
	end
	
	return 0.25
end

function HealthCapper:LogNPC(keys)
	local npc = EntIndexToHScript(keys.entindex)
	if npc:IsRealHero() and not npc.HealthCapper then	
		npc.HealthCapper = true
		Timers:CreateTimer(HealthCapper.Think, npc)
  end
end

function HealthCapper:OnActivate() 
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(HealthCapper, 'LogNPC'), self)
end
