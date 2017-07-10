-- particles/rain_fx/

function CreateLightningBlot(position)
	local aoe = 100
	CreateGlobalParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", function(particle)
		ParticleManager:SetParticleControl(particle, 0, position)
		ParticleManager:SetParticleControl(particle, 1, position + Vector(RandomInt(-250, 250), RandomInt(-250, 250), 1200))
	end, PATTACH_WORLDORIGIN)
	EmitSoundOnLocationWithCaster(position, "Hero_Zuus.LightningBolt", nil)

	GridNav:DestroyTreesAroundPoint(position, aoe, true)
	for _,v in ipairs(FindUnitsInRadius(DOTA_TEAM_NEUTRALS, position, nil, aoe, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)) do
		ApplyDamage({
			attacker = GLOBAL_DUMMY,
			victim = v,
			damage_type = DAMAGE_TYPE_PURE,
			damage = RandomInt(600, 5000)
		})
	end
end

WEATHER_EFFECTS = {
	sunny = {
		minDuration = 120,
		maxDuration = 600,
		recipients = {"rain", "snow"},

		particles = {"particles/arena/weather/sunlight.vpcf"},
		dummyModifier = "modifier_weather_sunny",
	},
	rain = {
		minDuration = 120,
		maxDuration = 600,
		recipients = {"storm", "sunny", "snow"},

		particles = {"particles/rain_fx/econ_rain.vpcf"},
		sounds = {
			{"Arena.Weather.Rain.Ambient"}
		},
		dummyModifier = "modifier_weather_rain",
	},
	storm = {
		minDuration = 120,
		maxDuration = 240,
		recipients = {"rain", "sunny"},

		isCatastrophe = true,
		simulatesNight = true,
		particles = {"particles/rain_fx/econ_rain.vpcf"},
		sounds = {
			{"Arena.Weather.Rain.Ambient"},
			{"lightning.thunder"}
		},
		dummyModifier = "modifier_weather_rain",
		Think = function()
			CreateLightningBlot(GetGroundPosition(Vector(RandomInt(-MAP_LENGTH, MAP_LENGTH), RandomInt(-MAP_LENGTH, MAP_LENGTH), 0), nil))
		end,
	},
	snow = {
		minDuration = 120,
		maxDuration = 600,
		recipients = {"rain", "blizzard"},

		particles = {"particles/rain_fx/econ_snow.vpcf"},
		sounds = {
			{"Arena.Weather.Snow.Ambient"},
			{"Arena.Weather.Snow.Gust", 3},
		},
		dummyModifier = "modifier_weather_snow",
	},
	blizzard = {
		minDuration = 120,
		maxDuration = 240,
		recipients = {"snow", "rain"},

		isCatastrophe = true,
		particles = {"particles/rain_fx/econ_weather_aurora.vpcf", "particles/rain_fx/econ_snow.vpcf", "particles/rain_fx/econ_snow.vpcf"},
		sounds = {
			{"Arena.Weather.Snow.Ambient"},
			{"Arena.Weather.Snow.Gust", 1},
			{"Arena.Weather.Snow.Gust", 5},
		},
		dummyModifier = "modifier_weather_snow",
		Think = function()

		end,
	}
	-- particles/rain_fx/econ_weather_sirocco.vpcf
	-- particles/rain_fx/econ_weather_pestilence.vpcf
	-- particles/rain_fx/econ_weather_ash.vpcf
	-- particles/rain_fx/econ_weather_harvest.vpcf
	-- particles/rain_fx/econ_weather_spring.vpcf
}
