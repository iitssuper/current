# Current
## A Knit forked/inspired modular loading project

## INSTALLATION 🔨
Unfortunately there is no Wally installation method yet (Will come later)

* Step 1
  Download the [.rbxm file](https://github.com/iitssuper/current/releases/download/v0.1.0-beta/Current.rbxm)

* Step 2
  Drag and drop the files into the **ReplicatedStorage**
  <br>
  <img width="341" height="264" alt="image" src="https://github.com/user-attachments/assets/a1a6e7b2-ee54-4758-8611-d391f1de0afa" />
  <br>
  Make sure the hierarcy is correct as seen on the image above ^


## SET-UP 👨‍💻
### SERVER-SIDE
Insert a [Script](https://create.roblox.com/docs/reference/engine/classes/Script) in ServerScriptService
<br>
<img width="195" height="50" alt="image" src="https://github.com/user-attachments/assets/0d43373a-dbed-4e0b-b14f-28ddefae3e3d" />
<br>
Require the src module: 
```lua
local Current = require(path.to.your.src)
```
<br>
Add your Services by using the following function:

```lua
Current.AddServices(Folder)
```

<br>
Then start Current with the following function:

```lua
Current.Start()
```

And you're ready to go!

### CLIENT-SIDE
Require the src module: 
```lua
local Current = require(path.to.your.src)
```
<br>
Add your Controllers by using the following function:

```lua
Current.AddControllers(Folder)
```

<br>
Then start Current with the following function:

```lua
Current.Start()
```

## ⚠️ IMPORTANT NOTE ABOUT SET-UP:
There are different ways to load up modules and start them for both Client and Server:

```lua
The function: 
Current.AddServices(Directory) // Current.AddControllers(Directory)

Will load modules like this:

Directory
├─ Module 1        [✔]
├─ Module 2        [✔]
├─ Module 3        [✔]
└─ Module 4        [✔]

Which means using this hierarcy:

Directory 
├─ Module 1        [✔]
├─ Module 2        [✔]
│  └─ Module 3     [✘]
└─ Module 4        [✔]

Will make it so some modules will not be loaded.
```

```lua
The function: 
Current.AddServicesDeep(Directory) // Current.AddControllersDeep(Directory)

Will load modules like this:

Directory
├─ Module 1        [✔]
├─ Module 2        [✔]
│  └─ Module 3     [✔]
└─ Module 4        [✔]

Which will also load modules using this hierarcy:

Directory
├─ Module 1        [✔]
├─ Module 2        [✔]
├─ Module 3        [✔]
└─ Module 4        [✔]
```

## Prioritizing start
You can prioritize which module will start by using the following function:

```lua
Current.PrioritizeStart({
  [1] = "MyServiceName",
  [2] = "MySecondServiceName",
  ...
})
```

The modules passed in the array will start (in order) before anyone else, so it would be:

1st started: MyServiceName
2nd started: MySecondServiceName
...

### IMPORTANT NOTE ABOUT PRIORITIZING
It's very important that you use the Service/Controller name and not the module name!


# SERVICES
Services are Server-Sided modules, which must be put somewhere the server is able to access them.
```lua
--// CREATION OF A SERVICE

local Current = require(path.to.src)

local MyService = Current.CreateService({
  Name = "MyService"
})

return MyService
```

## ADDING THE START FUNCTION
This function will run once Current will start every service.
```lua
function MyService:CurrentStart()
  print("Started!")
end
```

## ADDING THE INIT FUNCTION
This function runs before starting a service.

```lua
function MyService:CurrentInit()
  print("Initialized!")
end
```

## ACCESSING METADATA
Accessing the service's metadata is as easy as creating a metatable and using the self keyword:

```lua
local MyService = Current.CreateService({
  Name = "MyService",
  MyData = 1
})

function MyService:CurrentStart()
  print(self.MyData) --> 1
end
```

You can also instantiate metadata inside a function and access it later:

```lua
function MyService:CurrentStart()
  self.MyData = 1
  self:CheckData()
end

function MyService:CheckData()
  return self.MyData
end
```

# CONTROLLERS
Controllers are client-side modules, which must be put somewhere the client is able to access them.

*Note*: You can access the local player directly from Current by using: `Current.Player`, which will always be up-to-date to the local player.

```lua
--// CREATION OF A CONTROLLER

local Current = require(path.to.src)

local MyController = Current.CreateController({
  Name = "MyController"
})

return MyController
```

## ADDING THE START FUNCTION
This function will run once Current will start every service.
```lua
function MyController:CurrentStart()
  print("Started!")
end
```

## ADDING THE INIT FUNCTION
This function runs before starting a service.

```lua
function MyController:CurrentInit()
  print("Initialized!")
end
```

## ACCESSING METADATA
Accessing the controller's metadata is as easy as creating a metatable and using the self keyword:

```lua
local MyController = Current.CreateController({
  Name = "MyController",
  MyData = 1
})

function MyController:CurrentStart()
  print(self.MyData) --> 1
end
```

You can also instantiate metadata inside a function and access it later:

```lua
function MyController:CurrentStart()
  self.MyData = 1
  self:CheckData()
end

function MyController:CheckData()
  return self.MyData
end
```
