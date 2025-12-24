--[[
 _____ _   _______ ___________ _ _____   _     _____  ___ ______ ___________ 
/  ___| | | | ___ \  ___| ___ ( )  ___| | |   |  _  |/ _ \|  _  \  ___| ___ \
\ `--.| | | | |_/ / |__ | |_/ //\ `--.  | |   | | | / /_\ \ | | | |__ | |_/ /
 `--. \ | | |  __/|  __||    /   `--. \ | |   | | | |  _  | | | |  __||    / 
/\__/ / |_| | |   | |___| |\ \  /\__/ / | |___\ \_/ / | | | |/ /| |___| |\ \ 
\____/ \___/\_|   \____/\_| \_| \____/  \_____/\___/\_| |_/___/ \____/\_| \_| ]]

local RunService = game:GetService("RunService")

if RunService:IsServer() then
    return require(script.Parent.dependencies.currentServer)
else
    local CurrentServer = script.Parent.dependencies:FindFirstChild("currentServer")

    if CurrentServer and RunService:IsRunning() then
        CurrentServer:Destroy()
    end

    return require(script.Parent.dependencies.currentClient)
end