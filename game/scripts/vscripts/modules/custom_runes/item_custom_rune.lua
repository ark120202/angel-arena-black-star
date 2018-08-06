item_custom_rune = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
})

if IsServer() then
	function item_custom_rune:OnSpellStart(args)
		CustomRunes:PickUpRune(self:GetOwner(), self)
	end
end

item_arena_tripledamage_rune = class(item_custom_rune)
item_arena_haste_rune = class(item_custom_rune)
item_arena_illusion_rune = class(item_custom_rune)
item_arena_invisibility_rune = class(item_custom_rune)
item_arena_regeneration_rune = class(item_custom_rune)
item_arena_bounty_rune = class(item_custom_rune)
item_arena_arcane_rune = class(item_custom_rune)
item_arena_heart_rune = class(item_custom_rune)	
