if Scepters == nil then
	_G.Scepters = class({})
end

function Scepters:SetGlobalScepterThink()
	if DOTA_ACTIVE_GAMEMODE_TYPE == DOTA_GAMEMODE_TYPE_RANDOM_OMG then
		return
	end
	Timers:CreateTimer(0.2, function()
		for _,v in ipairs(GetAllPlayers(true)) do
			local hero = v:GetAssignedHero()
			local hasScepter = HasScepter(hero)
			if hasScepter and not hero.ScepterAbilityUpgraded then
				Scepters:GiveScepterAbility(hero)
			elseif hero.ScepterAbilityUpgraded and not hasScepter then
				Scepters:RemoveScepterAbility(hero)
			end
		end
		return 0.2
	end)
end

function Scepters:GiveScepterAbility(hero)
	local heroName = GetFullHeroName(hero)
	local scepterHeroData = hero:GetKeyValue("ScepterGrantedAbility")
	if scepterHeroData then
		hero:AddAbility(scepterHeroData.AbilityName)
		if scepterHeroData.SwapWithAttributeBonus == 1 then
			hero:SwapAbilities(scepterHeroData.AbilityName, "attribute_bonus_arena", true, true)
		end
		if scepterHeroData.SwappedAbility then
			hero:SwapAbilities(scepterHeroData.SwappedAbility, scepterHeroData.AbilityName, true, true)
		end
		hero.ScepterAbilityUpgraded = true
	end
	if heroName == "npc_dota_hero_riki" then
		hero:AddAbility("riki_pocket_riki")
		hero:SwapAbilities("riki_tricks_of_the_trade", "riki_pocket_riki", true, true)
		hero:SwapAbilities("riki_tricks_of_the_trade", "attribute_bonus_arena", true, true)
		hero.ScepterAbilityUpgraded = true
	end
end

function Scepters:RemoveScepterAbility(hero)
	local heroName = GetFullHeroName(hero)
	local scepterHeroData = hero:GetKeyValue("ScepterGrantedAbility")
	if scepterHeroData then
		if scepterHeroData.SwappedAbility then
			hero:SwapAbilities(scepterHeroData.SwappedAbility, scepterHeroData.AbilityName, true, true)
		end
		if scepterHeroData.SwapWithAttributeBonus == 1 then
			hero:SwapAbilities(scepterHeroData.AbilityName, "attribute_bonus_arena", true, true)
		end
		hero:RemoveAbility(scepterHeroData.AbilityName)
		hero.ScepterAbilityUpgraded = false
	end
	
	if heroName == "npc_dota_hero_riki" then
		hero:SwapAbilities("attribute_bonus_arena", "riki_tricks_of_the_trade", true, true)
		hero:SwapAbilities("riki_tricks_of_the_trade", "riki_pocket_riki", true, true)
		hero:RemoveAbility("riki_pocket_riki")
		hero.ScepterAbilityUpgraded = false
	end
end