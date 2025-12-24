local Players = game:GetService("Players")

type ControllerDef = {
    Name: string,
    [any]: any
}

type Controller = {
    Name: string,
    [any]: string
}

local CurrentClient = {}
CurrentClient.Player = Players.LocalPlayer
CurrentClient.Util = (script.Parent).utils

local Controllers: {[string]: Controller} =  {}
local StartPriorities = {}

local hasStarted = false
local startedComplete = false
local onStartedComplete = Instance.new("BindableEvent")

local waterMark = [[
   _____ _    _ _____  _____  ______ _   _ _______ 
  / ____| |  | |  __ \|  __ \|  ____| \ | |__   __|
 | |    | |  | | |__) | |__) | |__  |  \| |  | |   
 | |    | |  | |  _  /|  _  /|  __| | . ` |  | |   
 | |____| |__| | | \ \| | \ \| |____| |\  |  | |   
  \_____|\____/|_|  \_\_|  \_\______|_| \_|  |_|   
                                                   
                                                   
]]

local Promise = require(script.Parent.promise)
local debugger = require(script.Parent.debugger)

local function DoesControllerExist(cName: string): boolean
    return Controllers[cName] ~= nil
end

function CurrentClient.CreateController(cDef: ControllerDef): Controller
    assert(type(cDef) == "table", `Controller must be a table; got {type(cDef)}`)
	assert(type(cDef.Name) == "string", `Controller.Name must be a string; got {type(cDef.Name)}`)
	assert(#cDef.Name > 0, "Controller.Name must be a non-empty string")
	assert(not DoesControllerExist(cDef.Name), `Controller {cDef.Name} already exists`)
	assert(not hasStarted, `Controllers cannot be created after calling "Current.Start()"`)

    local newController = cDef :: Controller
    Controllers[newController.Name] = newController

    return newController
end

function CurrentClient.AddControllers(pFolder: Instance): { Controller }
    assert(not hasStarted, `Controllers cannot be added after calling "Current.Start()"`)

    local addedControllers = {}

    for _, module in pFolder:GetChildren() do
        if not module:IsA("ModuleScript") then
            continue
        end

        table.insert(addedControllers, require(module))
    end

    return addedControllers
end

function CurrentClient.PrioritizeStart(Controllers: { string })
    assert(not hasStarted, "Cannot call `PrioritizeStart` after Current has started!")

    for position, controller in Controllers do
        table.insert(StartPriorities, position, controller)
    end
end

function CurrentClient.AddControllersDeep(pFolder: Instance): { Controller }
    assert(not hasStarted, `Controllers cannot be added after calling "Current.Start()"`)

	local addedControllers = {}
	for _, module in pFolder:GetDescendants() do
		if not module:IsA("ModuleScript") then
			continue
		end

		table.insert(addedControllers, require(module))
	end

	return addedControllers
end

function CurrentClient.GetController(controllerName): Controller
    local controller = Controllers[controllerName]

    if controller then
        return controller
    end

    assert(hasStarted, "Cannot call GetController until Current has been started")
	assert(type(controllerName) == "string", `ControllerName must be a string; got {type(controllerName)}`)
	error(`Could not find controller "{controllerName}". Check to verify a controller with this name exists.`, 2)
end

function CurrentClient.GetControllers(): {Controller}
    assert(hasStarted, "Cannot call GetControllers until Current has been started")

    return Controllers
end

function CurrentClient.Start()
    if hasStarted then
        return Promise.reject("Current has already started!")
    end

    hasStarted = true

    table.freeze(Controllers)

    return Promise.new(function(resolve)
        local promisesStartControllers = {}

        for _, controller in Controllers do
            if type(controller.CurrentInit) == "function" then
                table.insert(
                    promisesStartControllers,
                    Promise.new(function(r)
                        debug.setmemorycategory(controller.Name)
                        controller:CurrentInit()
                        debugger.debugOutput("print", false, "☑️ Succesfully initialized "..controller.Name.."!")
                        r()
                    end)
                )
            end
        end

        resolve(Promise.all(promisesStartControllers))
    end):andThen(function()
        if #StartPriorities > 0 then
            for _, controller in StartPriorities do
                local actualController = Controllers[controller]
                if type(actualController.CurrentStart) == "function" then
	                task.spawn(function()
	                    debug.setmemorycategory(actualController.Name)
	                    actualController:CurrentStart()
                        actualController.Started = true
	                    debugger.debugOutput("print", false, "☑️ Succesfully started "..actualController.Name.."!")
					end)
				end
            end

            for _, controller in Controllers do
                if controller.Started then
                    continue
                end
                if type(controller.CurrentStart) == "function" then
                    task.spawn(function()
                        debug.setmemorycategory(controller.Name)
                        controller:CurrentStart()
                        controller.Started = true
                        debugger.debugOutput("print", false, "☑️ Succesfully started "..controller.Name.."!")
                    end)
                end
            end
        else
            for _, controller in Controllers do
                if controller.Started then
                    continue
                end
                if type(controller.CurrentStart) == "function" then
                    task.spawn(function()
                        debug.setmemorycategory(controller.Name)
                        controller:CurrentStart()
                        controller.Started = true
                        debugger.debugOutput("print", false, "☑️ Succesfully started "..controller.Name.."!")
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

function CurrentClient.OnStart()
    if startedComplete then
        return Promise.resolve()
    else
        return Promise.fromEvent(onStartedComplete.Event)
    end
end

return CurrentClient