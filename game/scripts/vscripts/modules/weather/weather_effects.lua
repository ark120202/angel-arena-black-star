function CreateLightningBlot(position)
	local originalPosition
	local lightningRodRadius = GetAbilitySpecial("item_lightning_rod", "protection_radius")
	for _,v in ipairs(FindUnitsInRadius(DOTA_TEAM_NEUTRALS, position, nil, lightningRodRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_OTHER, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)) do
		if v:HasModifier("modifier_item_lightning_rod_ward") then
			originalPosition = position
			position = v:GetAbsOrigin() + Vector(0, 0, 150)
			break
		end
	end


	local aoe = 125
	CreateGlobalParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", function(particle)
		local lightningSourcePosition = originalPosition and (originalPosition + Vector(0, 0, 1200)) or
			(position + Vector(RandomInt(-250, 250), RandomInt(-250, 250), 1200))
		ParticleManager:SetParticleControl(particle, 0, position)
		ParticleManager:SetParticleControl(particle, 1, lightningSourcePosition)
	end, PATTACH_WORLDORIGIN)
	EmitSoundOnLocationWithCaster(position, "Hero_Zuus.LightningBolt", nil)

	GridNav:DestroyTreesAroundPoint(position, aoe, true)
	local damage = GetDOTATimeInMinutesFull() * RandomInt(220, 300)
	for _,v in ipairs(FindUnitsInRadius(DOTA_TEAM_NEUTRALS, position, nil, aoe, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		if not v:IsMagicImmune() then
			ApplyDamage({
				attacker = GLOBAL_DUMMY,
				victim = v,
				damage_type = DAMAGE_TYPE_PURE,
				damage = damage
			})
		end
	end
end

function CreateCrystalNova(position)
	local aoe = 325
	CreateGlobalParticle("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf", function(particle)
		ParticleManager:SetParticleControl(particle, 0, position)
		ParticleManager:SetParticleControl(particle, 1, Vector(aoe, 2, aoe * 2))
	end)
	EmitSoundOnLocationWithCaster(position, "Hero_Crystal.CrystalNova", nil)
	local damage = 100 + GetDOTATimeInMinutesFull() * RandomInt(50, 180)
	local duration = 0.4 + ( RandomInt(4, 9) / 10 )
	for _,v in ipairs(FindUnitsInRadius(DOTA_TEAM_NEUTRALS, position, nil, aoe, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
		if not v:IsMagicImmune() then
			ApplyDamage({
				attacker = GLOBAL_DUMMY,
				victim = v,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage = damage
			})
			v:AddNewModifier(v, nil, "modifier_weather_blizzard_debuff", {
				duration = duration + RandomInt(1, 6) / 10
			})
		end
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
		maxDuration = 180,
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
		minDuration = 90,
		maxDuration = 180,
		recipients = {"rain", "blizzard"},

		particles = {"particles/rain_fx/econ_snow.vpcf"},
		sounds = {
			{"Arena.Weather.Snow.Ambient"},
			{"Arena.Weather.Snow.Gust", 3},
		},
		dummyModifier = "modifier_weather_snow",
	},
	blizzard = {
		minDuration = 60,
		maxDuration = 120,
		recipients = {"snow", "rain"},

		isCatastrophe = true,
		particles = {
			"particles/rain_fx/econ_weather_aurora.vpcf",
			"particles/rain_fx/econ_snow.vpcf",
			"particles/rain_fx/econ_snow.vpcf"
		},
		sounds = {
			{"Arena.Weather.Snow.Ambient"},
			{"Arena.Weather.Snow.Gust", 1},
			{"Arena.Weather.Snow.Gust", 5},
		},
		dummyModifier = "modifier_weather_snow",
		Think = function()
			if RollPercentage(40) then
				CreateCrystalNova(GetGroundPosition(Vector(RandomInt(-MAP_LENGTH, MAP_LENGTH), RandomInt(-MAP_LENGTH, MAP_LENGTH), 0), nil))
			end
		end,
	}
	-- particles/rain_fx/econ_weather_sirocco.vpcf
	-- particles/rain_fx/econ_weather_pestilence.vpcf
	-- particles/rain_fx/econ_weather_ash.vpcf
	-- particles/rain_fx/econ_weather_harvest.vpcf
	-- particles/rain_fx/econ_weather_spring.vpcf
}
