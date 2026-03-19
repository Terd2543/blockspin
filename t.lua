local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local lp = Players.LocalPlayer

-- ==========================================
-- [[ ⚙️ ตั้งค่า (SETTINGS) ]]
-- ==========================================
_G.AutoFarm = true
_G.FastAttack = true          -- เปิด/ปิดระบบโจมตีอัตโนมัติ (AOE)
_G.AUTOHAKI = true
_G.MobileAutoPunch = true
_G.SelectWeapon = "Combat"    -- ชื่ออาวุธที่ใช้ (เช่น "Melee", "Sword")
_G.AttackDistance = 200       -- ระยะที่สคริปต์จะเริ่มโจมตีมอนสเตอร์
_G.AttackDelay = 0.1           -- หน่วงเวลาระหว่างการโจมตีแต่ละรอบ (วินาที) ยิ่งน้อยยิ่งเร็ว

-- ระบบอัพสเตตัส (AddPoint)
_G.AutoAddPoint = true         -- เปิด/ปิดการอัพสเตตัสอัตโนมัติ
_G.AddPointType = "Melee"      -- ประเภทสเตตัสที่ต้องการอัพ (Melee, Defense, Sword, Gun, Fruit)
_G.AddPointAmount = 1000       -- จำนวนแต้มที่เพิ่มต่อครั้ง (ระวัง: บางเกมอาจจำกัด)
_G.AddPointDelay = 1            -- หน่วงเวลาระหว่างการอัพแต่ละครั้ง (วินาที)

-- ==========================================
-- [[ 🌍 ตรวจสอบโลก & ตัวแปร ]]
-- ==========================================
local World1 = game.PlaceId == 2753915549
local World2 = game.PlaceId == 4442272183
local World3 = game.PlaceId == 7449423635

local enemyFolder = workspace:WaitForChild("Enemies")
local net = RS:WaitForChild("Modules"):WaitForChild("Net")
local RegisterAttack = net:WaitForChild("RE/RegisterAttack")
local RegisterHit = net:WaitForChild("RE/RegisterHit")

local Mon, NameQuest, LevelQuest, CFrameQuest, CFrameMon
local Pos = CFrame.new(0, 20, 0) -- ยืนเหนือหัวมอนสเตอร์ 20 หน่วย

-- ==========================================
-- [[ 🛠️ ฟังก์ชันช่วยเหลือ (FUNCTIONS) ]]
-- ==========================================
local function topos(cf)
    pcall(function()
        if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = lp.Character.HumanoidRootPart
        local dist = (cf.Position - hrp.Position).Magnitude
        
        if lp.Character.Humanoid.Sit then lp.Character.Humanoid.Sit = false end
        if dist <= 100 then hrp.CFrame = cf return end
        
        -- บินไปหาเป้าหมาย
        local tween = TweenService:Create(hrp, TweenInfo.new(dist/350, Enum.EasingStyle.Linear), {CFrame = cf})
        tween:Play()
    end)
end

local function EquipWeapon()
    if not lp.Character then return end
    local tool = lp.Backpack:FindFirstChild(_G.SelectWeapon)
    if tool then 
        lp.Character.Humanoid:EquipTool(tool) 
    end
end

local function CheckQuest()
    local lv = lp.Data.Level.Value
    if World1 then
        if lv <= 9 then
            Mon="Bandit" LevelQuest=1 NameQuest="BanditQuest1"
            CFrameQuest=CFrame.new(1059.37, 15.45, 1550.42)
            CFrameMon=CFrame.new(1045.96, 27.00, 1560.82)
        elseif lv <= 14 then
            Mon="Monkey" LevelQuest=1 NameQuest="JungleQuest"
            CFrameQuest=CFrame.new(-1598.08, 35.55, 153.37)
            CFrameMon=CFrame.new(-1448.52, 67.85, 11.47)
        elseif lv <= 29 then
            Mon="Gorilla" LevelQuest=2 NameQuest="JungleQuest"
            CFrameQuest=CFrame.new(-1598.08, 35.55, 153.37)
            CFrameMon=CFrame.new(-1129.88, 40.46, -525.42)
        elseif lv <= 49 then
            Mon="Pirate" LevelQuest=1 NameQuest="BuggyQuest1"
            CFrameQuest=CFrame.new(-1141.07, 4.10, 3831.54)
            CFrameMon=CFrame.new(-1103.51, 13.75, 3896.09)
        end
        -- เพิ่มเควสอื่นๆ ตามต้องการ
    end
end

-- ฟังก์ชันตรวจสอบระยะทางจากตัวละครผู้เล่น
local function getDistanceFromCharacter(targetPos)
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return math.huge end
    return (char.HumanoidRootPart.Position - targetPos).Magnitude
end

-- ==========================================
-- [[ 🔄 1. ระบบนำทาง & ฟาร์ม (MAIN LOOP) ]]
-- ==========================================
task.spawn(function()
    while task.wait() do
        if not _G.AutoFarm then continue end
        
        pcall(function()
            CheckQuest()
            if not Mon then return end

            local mainUI = lp.PlayerGui:FindFirstChild("Main")
            local qFrame = mainUI and mainUI:FindFirstChild("Quest")
            
            if qFrame and not qFrame.Visible then
                -- ไปรับเควส
                topos(CFrameQuest)
                if (lp.Character.HumanoidRootPart.Position - CFrameQuest.Position).Magnitude < 20 then
                    task.wait(0.2)
                    RS.Remotes.CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
                end
            else
                -- มีเควสแล้ว -> หากลุ่มมอน
                local target = nil
                for _, v in pairs(enemyFolder:GetChildren()) do
                    if v.Name == Mon and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        target = v
                        break
                    end
                end

                if target then
                    EquipWeapon()
                    if _G.AUTOHAKI and not lp.Character:FindFirstChild("HasBuso") then
                        pcall(function() RS.Remotes.CommF_:InvokeServer("Buso") end)
                    end
                    
                    local hrp = target:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CanCollide = false
                        hrp.Size = Vector3.new(60, 60, 60)
                        target.Humanoid.WalkSpeed = 0
                        
                        topos(hrp.CFrame * Pos)
                    end
                else
                    -- หามอนไม่เจอ -> ไปจุดเกิดมอน
                    topos(CFrameMon)
                end
            end
        end)
    end
end)

-- ==========================================
-- [[ ⚡ 2. ระบบโจมตี AOE (FAST ATTACK) ]]
-- ==========================================
task.spawn(function()
    while task.wait(_G.AttackDelay) do   -- ใช้ _G.AttackDelay ในการหน่วง
        if _G.FastAttack and _G.AutoFarm and lp.Character and lp.Character:FindFirstChildOfClass("Tool") then
            pcall(function()
                local enemies = enemyFolder:GetChildren()
                local hitTargets = {}  -- เก็บเป้าหมายที่จะส่ง Hit

                -- ตรวจสอบมอนที่อยู่ในระยะ
                for _, v in ipairs(enemies) do
                    local hum = v:FindFirstChild("Humanoid")
                    local root = v:FindFirstChild("HumanoidRootPart")
                    if hum and root and hum.Health > 0 then
                        local dist = getDistanceFromCharacter(root.Position)
                        if dist <= _G.AttackDistance then
                            table.insert(hitTargets, root)  -- เก็บ HumanoidRootPart ไว้
                        end
                    end
                end

                -- ถ้ามีเป้าหมายอย่างน้อย 1 ตัว ให้ส่ง Attack หนึ่งครั้ง
                if #hitTargets > 0 then
                    RegisterAttack:FireServer(0)  -- ส่ง Attack หนึ่งครั้ง (argument อาจปรับตามเกม)
                    
                    -- ส่ง Hit ไปยังทุกเป้าหมายที่อยู่ในระยะ
                    for _, targetRoot in ipairs(hitTargets) do
                        RegisterHit:FireServer(targetRoot, {})  -- ส่ง Hit พร้อม HumanoidRootPart
                    end
                end
            end)
        end
    end
end)

-- ระบบคลิกหน้าจอ (จำลองการคลิกตี) เผื่อบางเกมต้องใช้
task.spawn(function()
    while task.wait() do
        if _G.MobileAutoPunch and _G.AutoFarm then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(1280, 672))
            end)
        end
    end
end)

-- ==========================================
-- [[ 💪 3. ระบบอัพสเตตัสอัตโนมัติ (ADD POINT) ]]
-- ==========================================
task.spawn(function()
    while task.wait(_G.AddPointDelay) do
        if _G.AutoAddPoint and _G.AutoFarm then
            pcall(function()
                local args = {
                    "AddPoint",
                    _G.AddPointType,
                    _G.AddPointAmount
                }
                RS.Remotes.CommF_:InvokeServer(unpack(args))
            end)
        end
    end
end)

-- ==========================================
-- [[ 👻 4. ระบบทะลุกำแพง (NOCLIP) ]]
-- ==========================================
RunService.Stepped:Connect(function()
    if _G.AutoFarm and lp.Character then
        pcall(function()
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    end
end)
