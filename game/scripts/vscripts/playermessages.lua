if PlayerMessages == nil then
	PlayerMessages = class({})
	PlayerMessages._NextFreeMessageId = 1
end

function PlayerMessages:Initialize()
	if not PlayerMessages._initialized then
		PlayerMessages._initialized = true
		CustomGameEventManager:RegisterListener("playermessages_response", Dynamic_Wrap(PlayerMessages, "_RecieveMessageResponse"))
	end
end
PlayerMessages.ID_MESSAGE_BASE = "ply_msgs_"

--[[function PlayerMessages:CreateVote(team,)
	if not team
end]]

function PlayerMessages:SendMessage(playerID, data)
	if IsInToolsMode() then
		playerID = 0
	end
	local messageID = PlayerMessages._NextFreeMessageId
	PlayerMessages._NextFreeMessageId = PlayerMessages._NextFreeMessageId + 1
	local messageFields = data.messageFields or {
		{field = "Text", class = "FieldTextTitle", fieldData = {text = "Random title."}},
		{field = "Text", fieldData = {text = "No any field data."}}
	}
	--local messageDuration = data.duration -- or nil
	--local messageStyle = data.style -- or nil
	self:_InitializePlayerTable(playerID)
	local messageTable = {fields=messageFields, duration=messageDuration,--[[ style=messageStyle]]}
	PlayerTables:SetTableValue(PlayerMessages.ID_MESSAGE_BASE .. playerID, messageID, messageTable)
	return messageID
end

function PlayerMessages:_RecieveMessageResponse(data)
	local playerID = tonumber(data.playerID)
	local _ids = string.gsub(string.gsub(string.gsub(data.panelIndex, "invitebox_", ""), "subfield", ""), "field", "")
	local Indexes = {}
	for i in string.gmatch(_ids, "([^_]+)") do
		table.insert(Indexes, i)
	end
	local messageId = tonumber(Indexes[1])
	local fieldId = tonumber(Indexes[2])
	local messageTable = PlayerTables:GetTableValue(PlayerMessages.ID_MESSAGE_BASE .. playerID, messageId)
	local object = messageTable.fields[fieldId]
	for i = 3, #Indexes do
		if object.fieldData[tonumber(Indexes[i])] ~= nil then
			object = object.fieldData[tonumber(Indexes[i])]
		end
	end
	if object.onactivate then
		if object:onactivate() then
			PlayerTables:DeleteTableKey(PlayerMessages.ID_MESSAGE_BASE .. playerID, messageId)
		end
	end
end

function PlayerMessages:_InitializePlayerTable(playerID)
	if not PlayerTables:TableExists(PlayerMessages.ID_MESSAGE_BASE .. playerID) then
		PlayerTables:CreateTable(PlayerMessages.ID_MESSAGE_BASE .. playerID, {}, {playerID})
	end
end

PlayerMessages:Initialize()