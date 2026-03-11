-- บรรทัดที่ 1: โหลด Library
local Success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not Success or not WindUI then
    warn("Failed to load WindUI. Please check your Executor.")
    return
end

-- ตั้งค่า Theme
WindUI:AddTheme({
    Name = "My Theme",
    Accent = Color3.fromHex("#18181b"),
    Background = Color3.fromHex("#101010"),
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#7a7a7a"),
    Button = Color3.fromHex("#52525b"),
    Icon = Color3.fromHex("#a1a1aa"),
})
WindUI:SetTheme("My Theme")

-- สร้างหน้าต่างหลัก
local Window = WindUI:CreateWindow({
    Title = "INF HUB",
    Icon = "door-open",
    Author = "by nattawatdev",
    Folder = "InfHub",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    
    -- ระบบ Key System (แก้ไขปีกกาที่ Error แล้ว)
    KeySystem = { 
        Note = "Key System. With platoboost.",
        SaveKey = false, -- ใส่ไว้ข้างใน KeySystem ตามโครงสร้าง WindUI
        API = {                                                     
            { 
                Type = "platoboost",
                ServiceId = 1930, 
                Secret = "92633672-2f11-4637-87fe-6d825b425df7",
            },                                                      
        },                                                          
    },
})

-- ตัวอย่างการสร้าง Tab (หลังจากผ่านหน้า Key)
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "home",
})

MainTab:Button({
    Title = "Print Status",
    Callback = function()
        print("UI is working!")
    end
})
