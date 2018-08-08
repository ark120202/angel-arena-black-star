function PrintTable(t, indent, done)
	PrintTableCall(t, print, indent, done)
end

local PhysicsUnitFDesc = {
	StopPhysicsSimulation = true,
	StartPhysicsSimulation = true,
	SetPhysicsVelocity = true,
	AddPhysicsVelocity = true,
	SetPhysicsVelocityMax = true,
	GetPhysicsVelocityMax = true,
	SetPhysicsAcceleration = true,
	AddPhysicsAcceleration = true,
	SetPhysicsFriction = true,
	GetPhysicsVelocity = true,
	GetPhysicsAcceleration = true,
	GetPhysicsFriction = true,
	FollowNavMesh = true,
	IsFollowNavMesh = true,
	SetGroundBehavior = true,
	GetGroundBehavior = true,
	SetSlideMultiplier = true,
	GetSlideMultiplier = true,
	Slide = true,
	IsSlide = true,
	PreventDI = true,
	IsPreventDI = true,
	SetNavCollisionType = true,
	GetNavCollisionType = true,
	OnPhysicsFrame = true,
	SetVelocityClamp = true,
	GetVelocityClamp = true,
	Hibernate = true,
	IsHibernate = true,
	DoHibernate = true,
	OnHibernate = true,
	OnPreBounce = true,
	OnBounce = true,
	OnPreSlide = true,
	OnSlide = true,
	AdaptiveNavGridLookahead = true,
	IsAdaptiveNavGridLookahead = true,
	SetNavGridLookahead = true,
	GetNavGridLookahead = true,
	SkipSlide = true,
	SetRebounceFrames = true,
	GetRebounceFrames = true,
	GetLastGoodPosition = true,
	SetStuckTimeout = true,
	GetStuckTimeout = true,
	SetAutoUnstuck = true,
	GetAutoUnstuck = true,
	SetBounceMultiplier = true,
	GetBounceMultiplier = true,
	GetTotalVelocity = true,
	GetColliders = true,
	RemoveCollider = true,
	AddCollider = true,
	AddColliderFromProfile = true,
	GetMass = true,
	SetMass = true,
	GetNavGroundAngle = true,
	SetNavGroundAngle = true,
	CutTrees = true,
	IsCutTrees = true,
	IsInSimulation = true,
	SetBoundOverride = true,
	GetBoundOverride = true,
	ClearStaticVelocity = true,
	SetStaticVelocity = true,
	GetStaticVelocity = true,
	AddStaticVelocity = true,
	SetPhysicsFlatFriction = true,
	GetPhysicsFlatFriction = true,
	PhysicsLastPosition = true,
	PhysicsLastTime = true,
	PhysicsTimer = true,
	PhysicsTimerName = true,
	bAdaptiveNavGridLookahead = true,
	bAutoUnstuck = true,
	bCutTrees = true,
	bFollowNavMesh = true,
	bHibernate = true,
	bHibernating = true,
	bPreventDI = true,
	bSlide = true,
	bStarted = true,
	fBounceMultiplier = true,
	fFlatFriction = true,
	fFriction = true,
	fMass = true,
	fNavGroundAngle = true,
	fSlideMultiplier = true,
	fVelocityClamp = true,
	lastGoodGround = true,
	nLockToGround = true,
	nMaxRebounce = true,
	nNavCollision = true,
	nNavGridLookahead = true,
	nRebounceFrames = true,
	nSkipSlide = true,
	nStuckFrames = true,
	nStuckTimeout = true,
	nVelocityMax = true,
	oColliders = true,
	staticForces = true,
	staticSum = true,
	vAcceleration = true,
	vLastGoodPosition = true,
	vLastVelocity = true,
	vSlideVelocity = true,
	vTotalVelocity = true,
	vVelocity = true,
}

function PrintTableCall(t, printFunc, indent, done)
	--printFunc ( string.format ('PrintTable type %s', type(keys)) )
	if type(t) ~= "table" then
		printFunc("PrintTable called on not table value")
		printFunc(tostring(t))
		return
	end

	done = done or {}
	done[t] = true
	if not indent then
		printFunc("Printing table")
	end
	indent = indent or 1

	local l = {}
	for k, v in pairs(t) do
		table.insert(l, k)
	end

	table.sort(l)
	for k, v in ipairs(l) do
		-- Ignore FDesc
		if v ~= 'FDesc' and PhysicsUnitFDesc[v] == nil then
			local value = t[v]
			if type(value) == "table" and not done[value] then
				done[value] = true
				printFunc(string.rep ("\t", indent)..tostring(v)..":")
				PrintTableCall(value, printFunc, indent + 2, done)
			elseif type(value) == "userdata" and not done[value] then
				done[value] = true
				printFunc(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
				PrintTableCall((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), printFunc, indent + 2, done)
			else
				if t.FDesc and t.FDesc[v] then
					printFunc(string.rep ("\t", indent)..tostring(t.FDesc[v]))
				else
					printFunc(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
				end
			end
		end
	end
end

function DebugAllCalls()
	if not GameRules.DebugCalls then
		print("Starting DebugCalls")
		GameRules.DebugCalls = true

		debug.sethook(function(...)
			local info = debug.getinfo(2)
			local src = tostring(info.short_src)
			local name = tostring(info.name)
			if name ~= "__index" then
				print("Call: ".. src .. " -- " .. name .. " -- " .. info.currentline)
			end
		end, "c")
	else
		print("Stopped DebugCalls")
		GameRules.DebugCalls = false
		debug.sethook(nil, "c")
	end
end
