
function OnItemEquipped(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not IsValidContainer(ability.container) then
		ability.container = Containers:CreateContainer({
			layout             = {3,3},
			range              = -1,
			closeOnOrder       = false,
			pids               = {caster:GetPlayerOwnerID()},
	    })

	    local data = CustomNetTables:GetTableValue("CAD", "itemContIds") or {}
	    data[ability:GetEntityIndex()] = ability.container.id
	    CustomNetTables:SetTableValue("CAD", "itemContIds", data)
	end
end

if IsServer() then
	

	
end