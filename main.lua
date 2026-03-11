local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "INF HUB",
    Icon = "door-open",
    Author = "by nattawatdev",
    Folder = "InfHub", -- ชื่อโฟลเดอร์ในเครื่องคุณ
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    KeySystem = { 
        Note = "Key System. Get key from Platoboost.",
        SaveKey = false, -- ปิดการจำคีย์ (ต้องอยู่ในนี้)
        API = {                                                     
            { 
                Type = "platoboost",
                ServiceId = 1930, 
                Secret = "92633672-2f11-4637-87fe-6d825b425df7",
            },                                                      
        },
        OnFinished = function()
            print("ผ่านการตรวจสอบคีย์แล้ว!")
        end
    } -- ปิด KeySystem ตรงนี้
})

-- สร้างหน้าหลักไว้ทดสอบ
local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
MainTab:Section({ Title = "Status" })
MainTab:Button({
    Title = "Key Verified Successfully",
    Callback = function() end
})
