--[ SERVICES ]--
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

--[ VARIABLES ]--
local Tasks = {
	["Stored"] = {}
}

--[ MAIN ]--
Tasks.Add = function(Function, Lifetime) : string
	local Id = HttpService:GenerateGUID(false)
	table.insert(Tasks.Stored, {["Id"] = Id, ["Start"] = os.clock(), ["Lifetime"] = Lifetime, ["Function"] = Function})
	return Id
end

Tasks.Remove = function(Id)
	for Index, Entry in ipairs(Tasks.Stored) do
		if Entry.Id == Id then
			table.remove(Tasks.Stored, Index)
			break
		end
	end
end

Tasks.Delay = function(Time, Function) : RBXScriptConnection
	local Start = tick()
	local Connection; Connection = RunService.Heartbeat:Connect(function(DeltaTime)
		if (tick() - Start) >= Time then
			task.spawn(Function, DeltaTime)

			Connection:Disconnect()
			Connection = nil
		end
	end)
	return Connection
end

Tasks.Recurring = function(Function, Interval, DontDefer) : RBXScriptConnection
	local Last = (DontDefer and tick() - Interval) or tick()
	local Connection; Connection = RunService.Heartbeat:Connect(function(DeltaTime)
		if (tick() - Last) >= Interval then
			Last = tick()
			task.spawn(Function, DeltaTime)
		end
	end)
	return Connection
end

--[ SETUP ]--
RunService.Heartbeat:Connect(function(DeltaTime)
	if #Tasks.Stored == 0 then return end
	for _, Info in ipairs(Tasks.Stored) do
		if Info.Lifetime and (os.clock() - Info.Start) >= Info.Lifetime then
			Tasks.Remove(Info.Id)
			continue
		end

		task.spawn(Info.Function, DeltaTime)
	end
end)

--[ RETURN ]--
return Tasks