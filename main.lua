local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- [ การตั้งค่า Theme ให้ใกล้เคียงกับรูปภาพ ]
WindUI:AddTheme({
    Name = "HermanosTheme",
    Accent = Color3.fromHex("#FF0000"), -- สีแดงตามปุ่ม GitHub ในรูป
    Background = Color3.fromHex("#151515"),
    Outline = Color3.fromHex("#303030"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#808080"),
    Button = Color3.fromHex("#202020"),
    Icon = Color3.fromHex("#FFFFFF"),
})
WindUI:SetTheme("HermanosTheme")

-- [ สร้าง Window หลัก ]
local Window = WindUI:CreateWindow({
    Title = "INF'DEV | PVP",
    Icon = "shield", -- ไอคอนโล่
    Author = "by nattawatdev",
    Folder = "INFHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Resizable = true,
    KeySystem = {
        Title = "Key System",
        Description = "Please get key from Platoboost to continue.",
        SaveKey = false, -- บังคับ Get Key ทุกรอบตามต้องการ
        API = {
            {
                Type = "platoboost",
                ServiceId = 1930, 
                Secret = "92633672-2f11-4637-87fe-6d825b425df7",
            }
        },
        OnFinished = function()
            print("Access Granted!")
        end
    }
})

-- [[ TAB: GENERAL ]]
local GeneralTab = Window:Tab({ Title = "General", Icon = "user" })

GeneralTab:Section({ Title = "Information:" })
GeneralTab:Button({ Title = "Hand: $200", Icon = "banknote" })
GeneralTab:Button({ Title = "Bank: $0", Icon = "landmark" })

GeneralTab:Section({ Title = "Trolling:" })
GeneralTab:Slider({
    Title = "Magneto Range",
    Value = 350, Min = 0, Max = 1000,
    Callback = function(v) end
})
GeneralTab:Toggle({ Title = "Magneto", Default = false, Callback = function(v) end })

GeneralTab:Section({ Title = "Player Modifier:" })
GeneralTab:Toggle({ Title = "Hide Name", Default = true, Callback = function(v) end })
GeneralTab:Toggle({ Title = "Anti Aim", Default = true, Callback = function(v) end })
GeneralTab:Toggle({ Title = "Anti Kill", Default = true, Callback = function(v) end })
GeneralTab:Toggle({ Title = "Anti Ragdoll", Default = true, Callback = function(v) end })
GeneralTab:Slider({
    Title = "Speed Multiply",
    Value = 3, Min = 1, Max = 10,
    Callback = function(v) end
})
GeneralTab:Toggle({ Title = "Walk Speed", Default = true, Callback = function(v) end })
GeneralTab:Toggle({ Title = "Infinite Stamina", Default = true, Callback = function(v) end })
GeneralTab:Toggle({ Title = "Super Jump", Default = true, Callback = function(v) end })

-- [[ TAB: COMBAT ]]
local CombatTab = Window:Tab({ Title = "Combat", Icon = "crosshair" })

CombatTab:Section({ Title = "Gun:" })
CombatTab:Toggle({ Title = "Show FOV", Default = true, Callback = function(v) end })
CombatTab:Slider({
    Title = "FOV",
    Value = 168, Min = 0, Max = 800,
    Callback = function(v) end
})
CombatTab:Dropdown({
    Title = "FOV Mode",
    Multi = false,
    Options = {"Middle", "Mouse", "Closest"},
    Default = "Middle",
    Callback = function(v) end
})
CombatTab:Toggle({ Title = "Magic Bullet", Default = true, Callback = function(v) end })
CombatTab:Dropdown({
    Title = "Aim Part",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    Default = "Head",
    Callback = function(v) end
})

CombatTab:Section({ Title = "Melee:" })
CombatTab:Toggle({ Title = "Melee Aura", Default = true, Callback = function(v) end })

CombatTab:Section({ Title = "Throwable:" })
CombatTab:Toggle({ Title = "Throw Aura", Default = true, Callback = function(v) end })

-- [[ TAB: ESP ]]
local EspTab = Window:Tab({ Title = "Esp", Icon = "eye" })
EspTab:Section({ Title = "Esp Settings:" })
EspTab:Toggle({ Title = "Skeleton", Default = true, Callback = function(v) end })
EspTab:Toggle({ Title = "Name", Default = true, Callback = function(v) end })
EspTab:Toggle({ Title = "Health", Default = true, Callback = function(v) end })
EspTab:Toggle({ Title = "Distance", Default = true, Callback = function(v) end })
EspTab:Toggle({ Title = "Weapon", Default = true, Callback = function(v) end })

EspTab:Section({ Title = "Drop Items:" })
EspTab:Toggle({ Title = "Items Name", Default = true, Callback = function(v) end })

-- [[ TAB: MISC ]]
local MiscTab = Window:Tab({ Title = "Misc", Icon = "package" })
MiscTab:Toggle({ Title = "Auto Minigame", Default = true, Callback = function(v) end })
MiscTab:Button({ Title = "Claim Quest", Callback = function() end })
MiscTab:Button({ Title = "FPS Booster", Callback = function() end })

-- [[ TAB: SERVER ]]
local ServerTab = Window:Tab({ Title = "Server", Icon = "server" })
ServerTab:Button({ Title = "Copy JobId", Callback = function() end })
ServerTab:Input({
    Title = "JobId Teleport",
    Placeholder = "Enter Text...",
    Callback = function(v) end
})
ServerTab:Button({ Title = "Rejoin", Callback = function() end })

-- [[ TAB: CONFIG ]]
local ConfigTab = Window:Tab({ Title = "Config", Icon = "settings" })
ConfigTab:Button({ Title = "Save Config", Callback = function() end })
ConfigTab:Button({ Title = "Reset Config", Callback = function() end })
ConfigTab:Button({ Title = "Wipe Workspace", Callback = function() end })
