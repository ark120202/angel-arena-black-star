ModuleRequire(..., "weather_effects")
FALLBACK_WEATHER_TYPES = {}

for k,v in pairs(WEATHER_EFFECTS) do
	if not v.isCatastrophe then
		table.insert(FALLBACK_WEATHER_TYPES, k)
	end
end

Weather = Weather or class({
	current = nil,
	endTime = -1,
	soundMap = {}
})

for _,v in pairs(WEATHER_EFFECTS) do
	if v.dummyModifier then
		ModuleLinkLuaModifier(..., v.dummyModifier, "modifiers/" .. v.dummyModifier)
	end
end

function Weather:Init()
	Weather:Start(Weather:SelectRandomRecipient())
	Timers:CreateTimer(1/30, Dynamic_Wrap(Weather, "Think"))
end

function Weather:GetWeatherInfo(new)
	if new then
		return WEATHER_EFFECTS[new]
	end
end

function Weather:Start(new)
	local newWeatherInfo = Weather:GetWeatherInfo(new)
	if not newWeatherInfo then error("Invalid weather type.") end
	-- Cleanup
	local currentWeatherInfo = Weather:GetWeatherInfo(Weather.current)
	if currentWeatherInfo and currentWeatherInfo.dummyModifier then
		GLOBAL_DUMMY:RemoveModifierByName(currentWeatherInfo.dummyModifier)
	end

	Weather.current = new

	-- Apply new efffects
	if newWeatherInfo.OnStart then
		newWeatherInfo.OnStart()
	end
	if newWeatherInfo.dummyModifier then
		GLOBAL_DUMMY:AddNewModifier(GLOBAL_DUMMY, nil, newWeatherInfo.dummyModifier, nil)
	end

	Weather.endTime = GameRules:GetDOTATime(false, true) + RandomInt(newWeatherInfo.minDuration, newWeatherInfo.maxDuration)

	local sounds = {}
	for _,v in ipairs(newWeatherInfo.sounds or {}) do
		sounds[v[1]] = (v[2] or 0) + GLOBAL_DUMMY:GetSoundDuration(v[1], nil)
	end

	-- Send to clients
	PlayerTables:SetTableValues("weather", {
		current = new,
		particles = newWeatherInfo.particles or {},
		sounds = sounds,
		changeTime = GameRules:GetDOTATime(false, true)
	})
end

function Weather:SelectRandomRecipient(new)
	local info = Weather:GetWeatherInfo(new)
	local recipients = info and info.recipients or FALLBACK_WEATHER_TYPES
	return recipients[RandomInt(1, #recipients)]
end

function Weather:Think()
	local weatherInfo = Weather:GetWeatherInfo(Weather.current)
	local now = GameRules:GetDOTATime(false, true)
	if weatherInfo.Think then
		weatherInfo.Think()
	end
	if weatherInfo.simulatesNight then
		GameRules:BeginTemporaryNight(2/30)
	end

	if now >= Weather.endTime then
		Weather:Start(Weather:SelectRandomRecipient(Weather.current))
	end
	return 1/30
end
