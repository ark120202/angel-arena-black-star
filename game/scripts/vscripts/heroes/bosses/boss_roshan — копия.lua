function Initialize(keys)
	local caster = keys.caster
	--local sets = {{}}
end

function OnDeath(keys)
	local caster = keys.caster
	Notifications:TopToAll({text="#bosses_roshan_killed"})
	Timers:CreateTimer(BOSSES_SETTINGS.roshan.RespawnTime, function()
		Notifications:TopToAll({text="#bosses_roshan_respawn"})
		Bosses:SpawnStaticBoss("roshan")
	end)
end