function Initialize(keys)
	local caster = keys.caster
	caster:AddItem(CreateItem("item_shivas_guard", caster, caster))
	caster:AddItem(CreateItem("item_octarine_core", caster, caster))
	caster:AddItem(CreateItem("item_skadi", caster, caster))
end

function MirrorImage( event )
	local caster = event.caster
	local ability = event.ability
	local unit_name = caster:GetUnitName()
	local images_count = ability:GetLevelSpecialValueFor( "images_count", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "outgoing_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "incoming_damage", ability:GetLevel() - 1 )

	local casterOrigin = caster:GetAbsOrigin()
	local casterAngles = caster:GetAngles()

	caster:Stop()

	local vRandomSpawnPos = {
		Vector( 0, 0, 0 ),
		Vector( 72, 0, 0 ),
		Vector( 0, 72, 0 ),
		Vector( -72, 0, 0 ),
		Vector( 0, -72, 0 ),
		Vector( 144, 0, 0 ),
		Vector( 0, 144, 0 ),
		Vector( -144, 0, 0 ),
		Vector( 0, -144, 0 ),
	}

	table.shuffle(vRandomSpawnPos)
	table.insert( vRandomSpawnPos, RandomInt( 1, images_count+1 ), Vector( 0, 0, 0 ) )
	FindClearSpaceForUnit( caster, casterOrigin + table.remove( vRandomSpawnPos, 1 ), true )

	for i=1, images_count do
		local origin = casterOrigin + table.remove( vRandomSpawnPos, 1 )
		local illusion = CreateUnitByName(unit_name, origin, true, nil, nil, caster:GetTeamNumber())

		illusion:SetAngles( casterAngles.x, casterAngles.y, casterAngles.z )
		
		local casterLevel = caster:GetLevel()
		for i=1,casterLevel-1 do
			illusion:CreatureLevelUp(1)
		end

		for itemSlot=0, 5 do
			local item = caster:GetItemInSlot(itemSlot)
			if item ~= nil then
				local itemName = item:GetName()
				local newItem = CreateItem(itemName, illusion, illusion)
				illusion:AddItem(newItem)
			end
		end

		illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
		
		illusion:MakeIllusion()
		illusion:SetHealth(caster:GetHealth())

		illusion:SetAngles( casterAngles.x, casterAngles.y, casterAngles.z )
		illusion:RemoveAbility("boss_water_passive")
		illusion:RemoveModifierByName("modifier_boss_any_passive")
		illusion:RemoveAbility("boss_any_passive")
		illusion:MoveToTargetToAttack(ability.target)
	end
	ability.target = nil
end