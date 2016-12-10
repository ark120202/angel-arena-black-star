if not DynamicWearables then
	DynamicWearables = class({})
	DynamicWearables.RawItemsKV = LoadKeyValues( "scripts/items/items_game.txt" )
end


--Returns list of item id's that were equipped on that player
function CustomWearables:RemoveAndParseDotaWearables(unit)
	local wearableModels = {}
	for _,v in pairs(unit:GetChildren()) do
		if v:GetClassname() == "dota_item_wearable" then
			table.insert(wearableModels, v:GetModelName())
			v:AddEffects(EF_NODRAW)
			v:SetModel("models/development/invisiblebox.vmdl")
			--v:RemoveSelf()
		end
	end
	PrintTable(wearableModels)
end

function CDOTA_BaseNPC:EquipModel(vmdl)
	local ent = CreateUnitByName("dota_item_wearable", Vector(0), false, nil, nil, self:GetTeamNumber())
	ent:SetModel(vmdl)
	ent:FollowEntity(self, true)
	if not self.ents then self.ents = {} end
	table.insert(self.ents, ent)
end

function CustomWearables:ParseData()
	local itemsKV = DynamicWearables.RawItemsKV.items
	for k,v in pairsByKeys(itemsKV) do

	end
end

if IsInToolsMode() and PlayerResource then
	local testHero = PlayerResource:GetSelectedHeroEntity(0)
	--CustomWearables:RemoveAndParseDotaWearables(testHero)
--	testHero:EquipModel("models/items/mirana/warden_of_the_eternal_night_mount/warden_of_the_eternal_night_mount.vmdl")
end