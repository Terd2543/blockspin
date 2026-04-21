-- สคริปต์เปลี่ยน fire_rate ของปืนที่ถือ/มีทั้งหมดเป็น 700 (Min=500, Max=1000)
-- รันครั้งเดียวก็เปลี่ยนทันที และจะคอยอัปเดตเมื่อหยิบปืนใหม่

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GunsFolder = ReplicatedStorage:WaitForChild("Items"):WaitForChild("gun")

local function isGunTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return GunsFolder:FindFirstChild(tool.Name) ~= nil or tool.Name:match("Gun") or tool:FindFirstChild("Handle")
end

local function setFireRate(tool)
    if tool and isGunTool(tool) then
        pcall(function()
            tool:SetAttribute("fire_rate", 800
                )
            print("[+] ตั้ง fire_rate ของ " .. tool.Name .. " เป็น 800
                    ")
        end)
    end
end

-- เปลี่ยนปืนที่ถืออยู่ตอนนี้
local char = LocalPlayer.Character
if char then
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            setFireRate(tool)
        end
    end
end

-- เปลี่ยนปืนใน Backpack
local backpack = LocalPlayer:FindFirstChild("Backpack")
if backpack then
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            setFireRate(tool)
        end
    end
end

-- เมื่อหยิบปืนใหม่ขึ้นมา (Character.ChildAdded)
if char then
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.2)
            setFireRate(child)
        end
    end)
end

-- เมื่อใส่ปืนเข้ากระเป๋า (Backpack.ChildAdded)
if backpack then
    backpack.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            setFireRate(child)
        end
    end)
end

-- อัปเดตซ้ำทุก 2 วินาที (กันเกมรีเซ็ตค่า)
task.spawn(function()
    while true do
        task.wait(2)
        -- ตรวจปืนในตัวละคร
        local character = LocalPlayer.Character
        if character then
            for _, tool in ipairs(character:GetChildren()) do
                if tool:IsA("Tool") and isGunTool(tool) then
                    local current = tool:GetAttribute("fire_rate")
                    if current ~= 800 then
                        setFireRate(tool)
                    end
                end
            end
        end
        -- ตรวจใน Backpack
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            for _, tool in ipairs(bp:GetChildren()) do
                if tool:IsA("Tool") and isGunTool(tool) then
                    local current = tool:GetAttribute("fire_rate")
                    if current ~= 800 then
                        setFireRate(tool)
                    end
                end
            end
        end
    end
end)

print("✅ สคริปต์ทำงาน: fire_rate ของปืนทั้งหมดจะถูกตั้งเป็น 700 และคงค่านั้นไว้")
