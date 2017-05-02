function HeroSelection:GetLinkedHeroLockedAlly(hero, desiredTeam)
	for team,_v in pairs(PlayerTables:GetAllTableValuesForReadOnly("hero_selection")) do
		if team == desiredTeam then
			for plyId,v in pairs(_v) do
				if v.hero == hero and v.status == "locked" then
					return plyId
				end
			end
		end
	end
end