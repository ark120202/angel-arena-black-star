modifier_boss_kel_thuzad_immortality = class({})
if IsServer() then
	function modifier_boss_kel_thuzad_immortality:OnCreated()
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("initial_stack_count"))
	end

	function modifier_boss_kel_thuzad_immortality:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_MIN_HEALTH
		}
	end

	function modifier_boss_kel_thuzad_immortality:OnTakeDamage(keys)
		local parent = keys.unit
		if parent == self:GetParent() and parent:GetHealth() <= 1 then
			if self:GetStackCount() > 0 then
				self:DecrementStackCount()
				parent:SetHealth(parent:GetMaxHealth())
				ParticleManager:CreateParticle("particles/arena/units/heroes/hero_sara/fragment_of_logic.vpcf", PATTACH_ABSORIGIN, parent)
				parent:EmitSound("Hero_Chen.HandOfGodHealHero")
			end
		end
	end

	function modifier_boss_kel_thuzad_immortality:GetMinHealth()
		if self:GetStackCount() > 0 then
			return 1
		end
	end
end
-lua PlayerResource:GetSelectedHeroEntity(5):FindModifierByName("modifier_boss_kel_thuzad_immortality"):SetStackCount(10000)
-pick npc_arena_hero_destroyer
-lua PlayerResource:GetSelectedHeroEntity(5):AddAbility("boss_kel_thuzad_invulnerability")
-lua PlayerResource:GetSelectedHeroEntity(5):AddExperience(1000,0,false,false)
-lua PlayerResource:GetSelectedHeroEntity(5):SetMaxHealth(100000)
-lua PlayerResource:GetSelectedHeroEntity(5):SetBaseMaxHealth(100000)
-lua for i = 0, 9 do Gold:ModifyGold(i, 100000000) end
-lua for i = 0, 100 do PlayerResource:GetSelectedHeroEntity(8):AddItemByName("item_eye_of_the_prophet") end
-lua Duel:SetDuelTimer(0)
-lua CHAT_COMMANDS["createcreep"].f({"medium", 1, 180}, PlayerResource:GetSelectedHeroEntity(5))
-lua _G.RandomRefresher = Timers.CreateTimer(function() RefreshAbilities(PlayerResource:GetSelectedHeroEntity(5), {}); RefreshItems(PlayerResource:GetSelectedHeroEntity(5), {}); return 0.1 end)
-lua PlayerResource:GetPlayer(3):SetTeam(3)
for _,v in ipairs(FindAllOwnedUnits(PlayerResource:GetPlayer(4))) do
	v:SetTeam(targetTeam)
end
-lua PlayerResource:UpdateTeamSlot(3, 3, 1)
-lua PlayerResource:SetCustomTeamAssignment(3, 3)