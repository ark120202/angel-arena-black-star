function Initialize(keys)
	local caster = keys.caster
	--
end

function OnDeath(keys)
	Notifications:TopToAll({text="#bosses_hell_killed"})
	Timers:CreateTimer(BOSSES_SETTINGS.hell.RespawnTime, function()
		Notifications:TopToAll({text="#bosses_hell_respawn"})
		Bosses:SpawnStaticBoss("hell")
	end)
end