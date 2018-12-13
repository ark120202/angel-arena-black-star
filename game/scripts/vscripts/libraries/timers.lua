TIMERS_VERSION = "1.06"
require('libraries/binheap')

--[[

	1.06 modified by Celireor (now uses binary heap priority queue instead of iteration to determine timer of shortest duration)

	DO NOT MODIFY A REALTIME TIMER TO USE GAMETIME OR VICE VERSA MIDWAY WITHOUT FIRST REMOVING AND RE-ADDING THE TIMER

	-- A timer running every second that starts immediately on the next frame, respects pauses
	Timers:CreateTimer(function()
			print ("Hello. I'm running immediately and then every second thereafter.")
			return 1.0
		end
	)

	-- The same timer as above with a shorthand call
	Timers(function()
		print ("Hello. I'm running immediately and then every second thereafter.")
		return 1.0
	end)


	-- A timer which calls a function with a table context
	Timers:CreateTimer(GameMode.someFunction, GameMode)

	-- A timer running every second that starts 5 seconds in the future, respects pauses
	Timers:CreateTimer(5, function()
			print ("Hello. I'm running 5 seconds after you called me and then every second thereafter.")
			return 1.0
		end
	)

	-- 10 second delayed, run once using gametime (respect pauses)
	Timers:CreateTimer({
		endTime = 10, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()
			print ("Hello. I'm running 10 seconds after when I was started.")
		end
	})

	-- 10 second delayed, run once regardless of pauses
	Timers:CreateTimer({
		useGameTime = false,
		endTime = 10, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()
			print ("Hello. I'm running 10 seconds after I was started even if someone paused the game.")
		end
	})


	-- A timer running every second that starts after 2 minutes regardless of pauses
	Timers:CreateTimer("uniqueTimerString3", {
		useGameTime = false,
		endTime = 120,
		callback = function()
			print ("Hello. I'm running after 2 minutes and then every second thereafter.")
			return 1
		end
	})


	-- A timer using the old style to repeat every second starting 5 seconds ahead
	Timers:CreateTimer("uniqueTimerString3", {
		useOldStyle = true,
		endTime = GameRules:GetGameTime() + 5,
		callback = function()
			print ("Hello. I'm running after 5 seconds and then every second thereafter.")
			return GameRules:GetGameTime() + 1
		end
	})

]]



TIMERS_THINK = 0.01

if Timers == nil then
	print ( '[Timers] creating Timers' )
	Timers = {}
	setmetatable(Timers, {
		__call = function(t, ...)
			return t:CreateTimer(...)
		end
	})
	--Timers.__index = Timers
end

function Timers:start()
	Timers = self
	self.timers = {realTime = BinaryHeap("endTime"), gameTime = BinaryHeap("endTime")}
	self.nextTickCallbacks = {}
	
	local ent = Entities:CreateByClassname("info_target") -- Entities:FindByClassname(nil, 'CWorld')
	ent:SetThink("Think", self, "timers", TIMERS_THINK)
end

function Timers:Think()
	local nextTickCallbacks = table.merge({}, Timers.nextTickCallbacks)
	Timers.nextTickCallbacks = {}
	for _, cb in ipairs(nextTickCallbacks) do
		DebugCallFunction(cb)
	end
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return
	end

	-- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
	local now = GameRules:GetGameTime()

	-- Process timers
	local timers = Timers.timers
	self:ExecuteTimers(timers.realTime, Time())
	self:ExecuteTimers(timers.gameTime, GameRules:GetGameTime())

	return TIMERS_THINK
end

function Timers:ExecuteTimers(timerList, now)
	--Empty timer, ignore
	if not timerList[1] then return end
	
	--Timers are alr. sorted by end time upon insertion
	local currentTimer = timerList[1]
	
	local bOldStyle = currentTimer.useOldStyle == true
	
	currentTimer.endTime = currentTimer.endTime or now
	--Check if timer has finished
	if now >= currentTimer.endTime then
		-- Remove from timers list
		timerList:Remove(currentTimer)
		Timers.runningTimer = k
		Timers.removeSelf = false

		-- Run the callback
		local status, nextCall
		if currentTimer.context then
			status, nextCall = xpcall(function() return currentTimer.callback(currentTimer.context, currentTimer) end, function (msg)
										return msg..'\n'..debug.traceback()..'\n'
									end)
		else
			status, nextCall = xpcall(function() return currentTimer.callback(currentTimer) end, function (msg)
										return msg..'\n'..debug.traceback()..'\n'
									end)
		end

		Timers.runningTimer = nil

		-- Make sure it worked
		if status then
			-- Check if it needs to loop
			if nextCall and not Timers.removeSelf then
				-- Change its end time
				
				if bOldStyle then
					currentTimer.endTime = currentTimer.endTime + nextCall - now
				else
					currentTimer.endTime = currentTimer.endTime + nextCall
				end
				
				timerList:Insert(currentTimer)
			end

			-- Update timer data
			--self:UpdateTimerData()
		else
			-- Nope, handle the error
			Timers:HandleEventError('Timer', k, nextCall)
		end
		--run again!
		self:ExecuteTimers(timerList, now)
	end
end

function Timers:HandleEventError(name, event, err)
	if IsInToolsMode() then
		print(err)
	else
		StatsClient:HandleError(err)
	end

	-- Ensure we have data
	name = tostring(name or 'unknown')
	event = tostring(event or 'unknown')
	err = tostring(err or 'unknown')

	-- Tell everyone there was an error

	--Say(nil, name .. ' threw an error on event '..event, false)
	--Say(nil, err, false)

	-- Prevent loop arounds
	if not self.errorHandled then
		-- Store that we handled an error
		self.errorHandled = true
	end
end

function Timers:CreateTimer(name, args, context)
	if type(name) == "function" then
		if args ~= nil then
			context = args
		end
		args = {callback = name}
		name = args --backwards compatibility
	elseif type(name) == "table" then
		args = name
	elseif type(name) == "number" then
		args = {endTime = name, callback = args}
		name = args
	end
	if not args.callback then
		print("Invalid timer created: "..name)
		return
	end

	local now = GameRules:GetGameTime()
	local timers = self.timers
	local timerHeap = timers.gameTime
	if args.useGameTime ~= nil and args.useGameTime == false then
		now = Time()
		timerHeap = timers.realTime
	end

	if args.endTime == nil then
		args.endTime = now
	elseif args.useOldStyle == nil or args.useOldStyle == false then
		args.endTime = now + args.endTime
	end

	args.context = context

	timerHeap:Insert(args)

	return name
end

function Timers:NextTick(callback)
	table.insert(Timers.nextTickCallbacks, callback)
end

function Timers:RemoveTimer(name)

	local timers = self.timers
	local timerHeap = timers.gameTime
	if name.useGameTime ~= nil and name.useGameTime == false then
		timerHeap = timers.realTime
	end
	
	timerHeap:Remove(name)
	if Timers.runningTimer == name then
		Timers.removeSelf = true
	end
end

--[[ unused function
function Timers:RemoveTimers(killAll)
	local timers = {realTime = BinaryHeap("endTime"), gameTime = BinaryHeap("endTime")}
	Timers.removeSelf = true

	if not killAll then
		for k,v in pairs(Timers.timers) do
			if v.persist then
				timers[k] = v
			end
		end
	end

	Timers.timers = timers
end]]--

if not Timers.timers then Timers:start() end

GameRules.Timers = Timers
