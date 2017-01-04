modifier_meat_hook_bloodstained_lua = class({})

function modifier_meat_hook_bloodstained_lua:GetTexture()
	return "arena/modifier_meat_hook_bloodstained_lua"
end

function modifier_meat_hook_bloodstained_lua:IsPurgable()
	return false
end

function modifier_meat_hook_bloodstained_lua:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end