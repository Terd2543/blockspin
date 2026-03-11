local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// [ CONFIG ]
local Config = {
    Enabled = false,
    FOV = 150,
    MaxDistance = 1500,
    Prediction = 0.165
}

--// [ LIST ปืนที่รองรับ ]
local GunNames = {
    "P226","MP5","M24","Draco","Glock","Sawnoff","Uzi","G3","C9",
    "Hunting Rifle","Anaconda","AK47","Remington","Double Barrel"
}
local GunLookup = {}
for _, name in pairs(GunNames) do GunLookup[name] = true end

--// [ DRAWING SETUP ]
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 1
fovCircle.NumSides = 100
fovCircle.Filled = false -- ห้ามทึบ
fovCircle.Visible = false

--// [ FUNCTIONS ]
local function GetClosestTarget()
    local closest = nil
    local shortest = math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local distFromMe = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
            
            if distFromMe <= Config.MaxDistance then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist <= Config.FOV and dist < shortest then
                        shortest = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

--// [ UI SETUP ]
WindUI:AddTheme({
    Name = "My Theme",
    Accent = Color3.fromHex("#18181b"),
    Background = Color3.fromHex("#101010"),
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#FFFFFF"),
})
WindUI:SetTheme("My Theme")

local Window = WindUI:CreateWindow({
    Title = "INF HUB",
    Icon = "door-open",
    Author = "by nattawatdev",
    Folder = "InfHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    KeySystem = { 
        Note = "Key System. Get key from Platoboost.",
        SaveKey = false, -- บังคับให้ Get Key ทุกครั้งที่รัน
        API = {                                                     
            { 
                Type = "platoboost",
                ServiceId = 1930, 
                Secret = "92633672-2f11-4637-87fe-6d825b425df7",
            },                                                      
        },
        OnFinished = function()
            --// เริ่มระบบแฮกเมื่อผ่านคีย์
            local send = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Send")
            local oldFire
            oldFire = hook
