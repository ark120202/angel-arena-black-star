Verify = Verify or class({})

function Verify:Override()
	local errors = {}
	local override = LoadKeyValues("scripts/npc/npc_abilities_override.txt")
	local abilities = LoadKeyValues("scripts/npc/npc_abilities.txt")
	table.merge(abilities, LoadKeyValues("scripts/npc/items.txt"))

	for name, overriden in pairs(override) do
		local original = abilities[name]
		if original then
			if overriden.AbilitySpecial then
				if original.AbilitySpecial then
					for specialIndex,specialValues in pairs(overriden.AbilitySpecial) do
						local originalValues = original.AbilitySpecial[specialIndex]
						if originalValues then
							for k,v in pairs(specialValues) do
								if originalValues[k] then
									-- Good!
								elseif k ~= "CalculateSpellDamageTooltip" then
									table.insert(errors, name .. ": override has AbilitySpecial/" .. specialIndex .. "/" .. k .. ", default hasn't")
								end
							end
							for k,v in pairs(originalValues) do
								if specialValues[k] then
									-- Good!
								elseif k ~= "CalculateSpellDamageTooltip" then
									table.insert(errors, name .. ": default has AbilitySpecial/" .. specialIndex .. "/" .. k .. ", override hasn't")
								end
							end

							if originalValues.LinkedSpecialBonus and
								specialValues.LinkedSpecialBonus and
								originalValues.LinkedSpecialBonus ~= specialValues.LinkedSpecialBonus then
								table.insert(errors, name .. ": override's AbilitySpecial/" .. specialIndex .. "/LinkedSpecialBonus not equals to default")
							end
						elseif specialIndex ~= "99" then
							table.insert(errors, name .. ": override has AbilitySpecial/" .. specialIndex .. ", default hasn't")
						end
					end
				else
					table.insert(errors, name .. ": override has AbilitySpecial, default hasn't")
				end
			end
		else
			table.insert(errors, name .. ": not found in default file")
		end
	end
	if #errors > 0 then
		return errors
	end
end

function Verify:Levels()
	local errors = {}

	function Check(className, maxLevel, path, value)
		local splittedWithSpaces = value:split(" ")
		local splittedCount = #splittedWithSpaces
		local bitStyleCount = #value:split("|")
		local commaStyleCount = #value:split(",")
		local semiStyleCount = #value:split(";")
		if bitStyleCount <= 1 and
			commaStyleCount <= 1 and
			semiStyleCount <= 1 and
			splittedCount ~= 0 and
			splittedCount ~= 1 then
			if table.allEqual(splittedWithSpaces, splittedWithSpaces[1]) then
				table.insert(errors, className .. ": " .. path .. " has repeated values")
			end
			if splittedCount ~= maxLevel then
				table.insert(errors, className .. ": " .. path .. " has " .. splittedCount .. " values, instead of " .. maxLevel)
			end
		end
	end

	for className, classEntry in pairs(Verify:_GetChangedAbilities()) do
		if type(classEntry) == "table" then
			local maxLevel = classEntry.MaxLevel or GetKeyValue(className, "MaxLevel") or classEntry.MaxUpgradeLevel or GetKeyValue(className, "MaxUpgradeLevel")
			if not maxLevel then
				maxLevel = GetKeyValue(className, "AbilityType") == "DOTA_ABILITY_TYPE_ULTIMATE" and 3 or 4
			end
			for k,v in pairs(classEntry) do
				if type(v) ~= "table" and
					k ~= "ItemAliases" then
					Check(className, maxLevel, k, tostring(v))
				end
			end

			for specialIndex,specialValues in pairs(classEntry.AbilitySpecial or {}) do
				for k,v in pairs(specialValues) do
					Check(className, specialValues.levelkey and 8 or maxLevel, "AbilitySpecial/" .. specialIndex .. "/" .. k, tostring(v))
				end
			end
		end
	end
	if #errors > 0 then
		return errors
	end
end

function Verify:All()
	Verify.verified = true
	local all = {}
	all.override = Verify:Override()
	all.levels = Verify:Levels()
	if table.count(all) > 0 then
		PrintTable(all)
	end
end

function Verify:_GetChangedAbilities()
	local abilities = {}
	table.merge(abilities, LoadKeyValues("scripts/npc/npc_abilities_override.txt"))
	table.merge(abilities, LoadKeyValues("scripts/npc/npc_abilities_custom.txt"))
	table.merge(abilities, LoadKeyValues("scripts/npc/npc_items_custom.txt"))
	return abilities
end

function Verify:_GetAllAbilities()
	local abilities = {}
	table.merge(abilities, KeyValues.AbilityKV)
	table.merge(abilities, KeyValues.ItemKV)
	return abilities
end

if IsInToolsMode() and not Verify.verified then
	Verify:All()
end
