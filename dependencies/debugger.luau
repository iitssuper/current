local RunService = game:GetService("RunService")
local debugger = {}

local function getRunContext()
    if RunService:IsClient() then
        return "[C]"
    elseif RunService:IsServer() then
        return "[S]"
    end
end

local function debugWarn(useDebugLines: boolean, ...)
    if not useDebugLines then
        warn(getRunContext(), ...)
    else
        warn(getRunContext(), debug.info(3, "s"), "at line: "..debug.info(3, "l").." // ", ...)
    end
end

local function debugPrint(useDebugLines: boolean, ...)
    if not useDebugLines then
        print(getRunContext(), ...)
    else
        print(getRunContext(), debug.info(2, "s"), "at line: "..debug.info(2, "l").." // ", ...)
    end
end

function debugger.debugOutput(priority, useDebugLines: boolean, ...)
    if not priority then
        priority = "print"
    end

    if priority:lower() == "warn" then
        debugWarn(useDebugLines, ...)
    elseif priority:lower() == "print" then
		debugPrint(useDebugLines, ...)
    end
end

return debugger