AI_THINK_INTERVAL = 0.3

AI_STATE_IDLE = 0
AI_STATE_AGGRESSIVE = 1
AI_STATE_RETURNING = 2
AI_STATE_CASTING = 3
AI_STATE_ORDER = 4

ModuleLinkLuaModifier(..., "modifier_simple_ai")

SimpleAI = {}
SimpleAI.__index = SimpleAI

function SimpleAI:new( unit, profile, params )
	local ai = {}
	setmetatable( ai, SimpleAI )

	ai.unit = unit
	ai.ThinkEnabled = true
	ai.Thinkers = {}
	ai.state = AI_STATE_IDLE
	ai.profile = profile

	if profile == "boss" then
		ai.stateThinks = {
			[AI_STATE_IDLE] = 'IdleThink',
			[AI_STATE_AGGRESSIVE] = 'AggressiveThink',
			[AI_STATE_RETURNING] = 'ReturningThink',
			[AI_STATE_CASTING] = 'CastingThink',
			[AI_STATE_ORDER] = 'OrderThink',
		}

		ai.spawnPos = params.spawnPos or unit:GetAbsOrigin()
		ai.aggroRange = params.aggroRange or unit:GetAcquisitionRange()
		ai.leashRange = params.leashRange or 1000
		ai.abilityCastCallback = params.abilityCastCallback
	end

	unit:AddNewModifier(unit, nil, "modifier_simple_ai", {})
	Timers:CreateTimer( ai.GlobalThink, ai )
	if unit.ai then
		unit.ai:Destroy()
	end
	unit.ai = ai
	return ai
end

function SimpleAI:SwitchState(newState)
	if self.stateThinks[newState] then
		self.state = newState
		if newState == AI_STATE_RETURNING then
			self.unit:MoveToPosition(self.spawnPos)
		end
	else
		self:SwitchState(AI_STATE_IDLE)
	end
end

function SimpleAI:GlobalThink()
	if self.MarkedForDestroy or not self.unit:IsAlive() then
		return
	end

	if self.ThinkEnabled then
		Dynamic_Wrap(SimpleAI, self.stateThinks[ self.state ])(self)
		if self.abilityCastCallback and self.state ~= AI_STATE_CASTING then
			self.abilityCastCallback(self)
		end
	end
	for k,_ in pairs(self.Thinkers) do
		if not k() then
			self.Thinkers[k] = nil
		end
	end
	return AI_THINK_INTERVAL
end

--Boss Thinkers
	function SimpleAI:OnOrder(order)
		if self.state == AI_STATE_RETURNING then
			if order.order_type ~= 1 or new_pos ~= self.spawnPos then
				self.unit:MoveToPosition(self.spawnPos)
			end
		end
	end

	function SimpleAI:IdleThink()
		--local units = Dynamic_Wrap(SimpleAI, "FindUnitsNearby")(self, self.aggroRange, false, true)
		local units = self:FindUnitsNearby(self.aggroRange, false, true, nil, DOTA_UNIT_TARGET_FLAG_NO_INVIS)
		if #units > 0 then
			self.unit:MoveToTargetToAttack( units[1] )
			self.aggroTarget = units[1]
			self:SwitchState(AI_STATE_AGGRESSIVE)
			return
		end
		if (self.spawnPos - self.unit:GetAbsOrigin()):Length2D() > 10 then
			self:SwitchState(AI_STATE_RETURNING)
			return
		end
	end

	function SimpleAI:AggressiveThink()
		local aggroTarget = self.aggroTarget
		if (
			(self.spawnPos - self.unit:GetAbsOrigin()):Length2D() > self.leashRange or
			not IsValidEntity(aggroTarget) or
			not aggroTarget:IsAlive() or
			(aggroTarget.IsInvisible and aggroTarget:IsInvisible()) or
			(aggroTarget.IsInvulnerable and aggroTarget:IsInvulnerable()) or
			(aggroTarget.IsAttackImmune and aggroTarget:IsAttackImmune())
		) then
			self:SwitchState(AI_STATE_RETURNING)
			return
		else
			-- Pretty dirty hack to forecefully update target
			self.unit:MoveToTargetToAttack(self.unit)
			self.unit:MoveToTargetToAttack(self.aggroTarget)
		end
	end

	function SimpleAI:ReturningThink()
		if (self.spawnPos - self.unit:GetAbsOrigin()):Length2D() < 10 then
			self:SwitchState(AI_STATE_IDLE)
			return
		end
	end

	function SimpleAI:CastingThink()

	end

	function SimpleAI:OrderThink()
		local orderEnd = false
		if self.ExecutingOrder.OrderType == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
			if (self.ExecutingOrder.Position - self.unit:GetAbsOrigin()):Length2D() < 10 then
				orderEnd = true
			end
		end
		if orderEnd then
			self.ExecutingOrder = nil
			self:SwitchState(AI_STATE_RETURNING)
		end
	end

--Utils
function SimpleAI:OnTakeDamage(attacker)
	if (self.state == AI_STATE_IDLE or self.state == AI_STATE_RETURNING) and (self.spawnPos - attacker:GetAbsOrigin()):Length2D() < self.leashRange then
		self.unit:MoveToTargetToAttack( attacker )
		self.aggroTarget = attacker
		self:SwitchState(AI_STATE_AGGRESSIVE)
	end
end

function SimpleAI:AddThink(func)
	self.Thinkers[func] = true
end

--Legacy
function SimpleAI:FindUnitsNearby(radius, bAllies, bEnemies, targettype, flags)
	local teamfilter = DOTA_UNIT_TARGET_TEAM_NONE
	if bAllies then
		teamfilter = teamfilter + DOTA_UNIT_TARGET_TEAM_FRIENDLY
	end
	if bEnemies then
		teamfilter = teamfilter + DOTA_UNIT_TARGET_TEAM_ENEMY
	end
	local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil, radius, teamfilter or DOTA_UNIT_TARGET_TEAM_ENEMY, targettype or DOTA_UNIT_TARGET_ALL, flags or DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	return units
end

function SimpleAI:FindUnitsNearbyForAbility(ability)
	local selfAbs = self.unit:GetAbsOrigin()
	return FindUnitsInRadius(self.unit:GetTeam(), selfAbs, nil, ability:GetCastRange(selfAbs, nil), ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false)
end

function SimpleAI:UseAbility(ability, target)
	if self.state ~= AI_STATE_CASTING and ability:IsFullyCastable() then
		self:SwitchState(AI_STATE_CASTING)
		if ability:HasBehavior(DOTA_ABILITY_BEHAVIOR_NO_TARGET) then
			self.unit:CastAbilityNoTarget(ability, -1)
		elseif ability:HasBehavior(DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then
			self.unit:CastAbilityOnTarget(target, ability, -1)
		elseif ability:HasBehavior(DOTA_ABILITY_BEHAVIOR_POINT) then
			self.unit:CastAbilityOnPosition(target, ability, -1)
		end
		local endtime = GameRules:GetGameTime() + ability:GetCastPoint() + 0.1
		self:AddThink(function()
			if GameRules:GetGameTime() >= endtime and not self.unit:IsChanneling() then
				self:SwitchState(AI_STATE_RETURNING)
				return false
			end
			return true
		end)
	end
end

function SimpleAI:ExecuteOrder(order)
	self.ExecutingOrder = order
	ExecuteOrderFromTable(order)
	self:SwitchState(AI_STATE_ORDER)
end

function SimpleAI:SetThinkEnabled(state)
	self.ThinkEnabled = state
end

function SimpleAI:AreUnitsInLineAround(width, length, teamFilter, typeFilter, flagFilter, min_unit_count)
	local line_count = 360/width
	for i = 1, line_count do
		local newLoc = self.unit:GetAbsOrigin() + (RotatePosition(Vector(0,0,0),QAngle(0,i*line_count,0),Vector(1,1,0))):Normalized() * speed

		local units = FindUnitsInLine(self.unit:GetTeam(), self.unit:GetAbsOrigin(), newLoc, nil, width, teamFilter or DOTA_UNIT_TARGET_TEAM_ENEMY, typeFilter or DOTA_UNIT_TARGET_ALL, flagFilter or DOTA_UNIT_TARGET_FLAG_NONE)
		if not min_unit_count or #units > min_unit_count then
			return units
		end
	end
end
function SimpleAI:Destroy()
	self.MarkedForDestroy = true
end
