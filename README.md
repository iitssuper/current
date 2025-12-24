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


## USAGE 👨‍💻
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
Add your Services by using the .AddServices() function function
