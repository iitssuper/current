type Service = {
    Name: string,
    [any]: any
}

type ServiceDef = {
    Name: string,
    [any]: any
}

local waterMark = [[
   _____ _    _ _____  _____  ______ _   _ _______ 
  / ____| |  | |  __ \|  __ \|  ____| \ | |__   __|
 | |    | |  | | |__) | |__) | |__  |  \| |  | |   
 | |    | |  | |  _  /|  _  /|  __| | . ` |  | |   
 | |____| |__| | | \ \| | \ \| |____| |\  |  | |   
  \_____|\____/|_|  \_\_|  \_\______|_| \_|  |_|   
                                                   
                                                   
]]

local Signal = require(script.Parent.signal)
local Promise = require(script.Parent.promise)
local debugger = require(script.Parent.debugger)

local hasStarted = false
local startedComplete = false
local onStartedComplete = Instance.new("BindableEvent")
local Services: {[string]:  Service} = {}
local StartPriorities = {}

local function DoesServiceExist(ServiceName: string)
    return Services[ServiceName] ~= nil
end

local CurrentServer = {}
CurrentServer.Util = (script.Parent).utils

function CurrentServer.CreateService(serviceDef: ServiceDef): Service
    assert(type(serviceDef) == "table", `Service must be a table; got {type(serviceDef)}`)
	assert(type(serviceDef.Name) == "string", `Service.Name must be a string; got {type(serviceDef.Name)}`)
	assert(#serviceDef.Name > 0, "Service.Name must be a non-empty string")
	assert(not DoesServiceExist(serviceDef.Name), `Service "{serviceDef.Name}" already exists`)
	assert(not hasStarted, `Services cannot be created after calling "Current.Start()"`)

    local service = serviceDef :: Service
    Services[service.Name] = service

    return service
end

function CurrentServer.AddServices(pFolder: Instance): {Service}
    assert(not hasStarted, "Services cannot be added after calling `Current.Start()`")

    local addedServices = {}

    for _, module in pFolder:GetChildren() do
        if not module:IsA("ModuleScript") then
            continue
        end

        table.insert(addedServices, require(module))
    end

    return addedServices
end

function CurrentServer.AddServicesDeep(pFolder: Instance): {Service}
    assert(not hasStarted, "Services cannot be added after calling `Current.Start()`")

    local addedServices = {}

    for _, module in pFolder:GetDescendants() do
        if not module:IsA("ModuleScript") then
            continue
        end

        table.insert(addedServices, require(module))
    end

    return addedServices
end

function CurrentServer.PrioritizeStart(Controllers: { string })
    assert(not hasStarted, "Cannot call `PrioritizeStart` after Current has started!")

    for position, service in Controllers do
        table.insert(StartPriorities, position, service)
    end
end

function CurrentServer.GetService(serviceName): Service
    local service = Services[serviceName]

    if service then
        return service
    end

    assert(hasStarted, "Cannot call GetService until Current has been started")
	assert(type(serviceName) == "string", `ServiceName must be a string; got {type(serviceName)}`)
	error(`Could not find service "{serviceName}". Check to verify a service with this name exists.`, 2)
end

function CurrentServer.GetServices(): {Service}
    assert(hasStarted, "Cannot call GetServices until Current has been started")

    return Services
end

function CurrentServer.CreateSignal()
    return Signal.new()
end

function CurrentServer.Start()
    if hasStarted then
        return Promise.reject("Current has already started!")
    end

    debugger.debugOutput("print", false, waterMark)

    hasStarted = true

    table.freeze(Services)

    return Promise.new(function(resolve)
        local promisesInitServices = {}

        for _, service in Services do
			if type(service.CurrentInit) == "function" then
				table.insert(
					promisesInitServices,
					Promise.new(function(r)
						debug.setmemorycategory(service.Name)
						service:CurrentInit()
                        debugger.debugOutput("print", false, "☑️ Succesfully initialized "..service.Name.."!")
						r()
					end)
				)
			end
		end

        resolve(Promise.all(promisesInitServices))
    end):andThen(function()
        if #StartPriorities > 0 then
            for _, service in StartPriorities do
                local actualService = Services[service]
                if type(actualService.CurrentStart) == "function" then
	                task.spawn(function()
	                    debug.setmemorycategory(actualService.Name)
	                    actualService:CurrentStart()
                        actualService.Started = true
	                    debugger.debugOutput("print", false, "☑️ Succesfully started "..actualService.Name.."!")
					end)
				end
            end

            for _, service in Services do
                if service.Started then
                    continue
                end
                if type(service.CurrentStart) == "function" then
                    task.spawn(function()
                        debug.setmemorycategory(service.Name)
                        service:CurrentStart()
                        service.Started = true
                        debugger.debugOutput("print", false, "☑️ Succesfully started "..service.Name.."!")
                    end)
                end
            end
        else
            for _, service in Services do
                if service.Started then
                    continue
                end
                if type(service.CurrentStart) == "function" then
                    task.spawn(function()
                        debug.setmemorycategory(service.Name)
                        service:CurrentStart()
                        service.Started = true
                        debugger.debugOutput("print", false, "☑️ Succesfully started "..service.Name.."!")
                    end)
                end
            end
        end

		startedComplete = true
		onStartedComplete:Fire()

		task.defer(function()
			onStartedComplete:Destroy()
		end)
    end)
end

return CurrentServer