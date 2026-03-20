local replicated = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local vim = game:GetService("VirtualInputManager")
local teleport = game:GetService('TeleportService')
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ฟังก์ชันที่เพิ่มตามคำขอ
local function hookButton(button)
    if not button then
        return
    end
    if button:FindFirstChild("UnlocksAtText") then
        button.UnlocksAtText.Visible = false
    end
    if button:FindFirstChild("EmoteName") then
        button.EmoteName.Visible = true
    end
    CoreUI.on_click(button, function() end)
end

local function lockTool(tool)
    if tool and tool:IsA("Tool") then
        pcall(function() tool:SetAttribute("Locked", true) end)
    end
end

local Client = Players.LocalPlayer
local Character = Client.Character or Client.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Backpack = Client:WaitForChild("Backpack")

_G = _G or {}
_G["Auto ATM"] = false
_G["AutoBike"] = false
_G["Deposit"] = false
_G["HackToolClass"] = "HackToolBasic"
_G["Amount"] = 3
_G["Money"] = 10000
_G["Auto Janitor Quest"] = false
_G["Auto Steak House"] = false
_G["Auto Seven Eleven Quest"] = false
_G["EnabledCustomWalkSpeed"] = false
_G["SpeedAmount"] = 8
_G["EnabledCustomJumpPower"] = false
_G["JumpAmount"] = 3.895
_G["AutoRespawn"] = false
_G["AntiDied"] = false
_G["AutoRejoinDieded"] = false
_G["AIWALKINGSPEED"] = 24
_G["OLD"] = 24
_G["DamageAura"] = false
_G["Around"] = 8
_G["FovCircle"] = false
_G["AroundRadius"] = 100
_G["Field of View"] = 70
_G["AmmoCrate"] = "Pistol"
_G["GunCrate"] = "Basic"
_G["CaseCrate"] = "Basic"
_G["StopWalking"] = false
_G["StopDriving"] = false
_G["detectedTeleport"] = false
_G["keys"] = {}

require(replicated.Modules.Game.UI.NotificationsUI).show_notification(
    "rbxassetid://103816145608946",
    "Yenix Hub Is Here",
    3,
    true
)

local fireproximityprompt = fireproximityprompt or getfenv().fireproximityprompt

function dist(Objective : CFrame)
    if not Client.Character or not Client.Character:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end
    return (Objective.Position - Client.Character.HumanoidRootPart.Position).Magnitude
end

function GetInfo(w : string)
    local amount = 0
    local IsHaving = false
    local Uid = nil
    local itemsFrame = Client.PlayerGui:FindFirstChild("Items")
    if itemsFrame then
        local holder = itemsFrame:FindFirstChild("ItemsHolder")
        if holder then
            local scroll = holder:FindFirstChild("ItemsScrollingFrame")
            if scroll then
                for i, v in pairs(scroll:GetChildren()) do
                    if v.Name ~= 'Folder' and v.Name ~= 'UIGridLayout' then
                        if v:FindFirstChild("ItemName") and v.ItemName.Text == w then
                            Uid = v.Name
                            amount = amount + 1
                            IsHaving = true
                            break
                        end
                    end
                end
            end
        end
    end
    return { [1] = amount, [2] = IsHaving, [3] = Uid }
end

function GetMoney()
    local topRight = Client.PlayerGui:FindFirstChild("TopRightHud")
    if topRight then
        local holder = topRight:FindFirstChild("Holder")
        if holder and holder:FindFirstChild("Frame") then
            local moneyLabel = holder.Frame:FindFirstChild("MoneyTextLabel")
            if moneyLabel then
                return tonumber(moneyLabel.Text:sub(2)) or 0
            end
        end
    end
    return 0
end

function ATMMoney()
    for i,v in ipairs(Client.PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") then
            if string.find(v.Text, "Bank Balance") then
                return tonumber(v.Text:match("%$(%d+)")) or 0
            end
        end
    end
    return 0
end

function GetChipPrice(types : string)
    local ChipPrice = {
        ["HackToolBasic"] = 10,
        ["HackToolPro"] = 150,
        ["HackToolUltimate"] = 350,
    }
    return ChipPrice[types]
end

function CheckingIsHacking()
    local slider = Client.PlayerGui:FindFirstChild("SliderMinigame")
    if slider then
        for i,v in pairs(slider:GetChildren()) do
            if v.Visible then
                return true
            end
        end
    end
    return false
end

function TeleportDetect()
    local count = 0
    local notifFrame = Client.PlayerGui:FindFirstChild("Notifications")
    if notifFrame then
        local frame = notifFrame:FindFirstChild("Frame")
        if frame then
            for _, v in pairs(frame:GetChildren()) do
                if v.Name == "Notification" and (v.Text == "Teleport detected" or v.Text == "Anti noclip triggered") then
                    count = count + 1
                    if count > 1 then return true end
                end
            end
        end
    end
    return false
end

do
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "DoorSystem" then
            if v:IsA('BasePart') then
                v.CanCollide = false
            end
        end
        if v.Name == "VehicleBlockers" then v:Destroy() end
    end
end

local function walkTo(destination: Vector3, value: boolean)
    if not value then return end
    local character = Client.Character or Client.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    local path = PathfindingService:CreatePath({
        AgentCanJump = true,
        AgentJumpHeight = 2,
        AgentHeight = 5.5,
        AgentRadius = 2.5,
    })

    local success = pcall(function()
        path:ComputeAsync(rootPart.Position, destination)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        for _, wp in ipairs(path:GetWaypoints()) do
            if _G["StopWalking"] then return end
            if humanoid.Health <= 0 then break end

            local finished = false
            local conn
            conn = humanoid.MoveToFinished:Connect(function()
                finished = true
                if conn then conn:Disconnect() end
            end)

            humanoid:MoveTo(wp.Position)

            if wp.Action == Enum.PathWaypointAction.Jump then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end

            repeat task.wait() until finished or _G["StopWalking"]
            if _G["StopWalking"] then return end
        end
    else
        warn("Pathfinding failed: ", path.Status)
    end
end

local function Driveto(model: Model, destination: Vector3, value: boolean, t)
    _G["StopDriving"] = true
    task.wait()
    _G["StopDriving"] = false

    local path = PathfindingService:CreatePath({
        AgentRadius = 1.5,
        AgentHeight = 5.5,
        AgentCanJump = true,
        AgentMaxSlope = 45
    })

    local success, err = pcall(function()
        path:ComputeAsync(model.PrimaryPart.Position, destination)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()

        for i, waypoint in ipairs(waypoints) do
            if _G["StopDriving"] then return end

            local startPos = model.PrimaryPart.Position
            local goalPos = waypoint.Position + Vector3.new(0, 1.5, 0)
            local dir = (goalPos - startPos).Unit
            local dist = (goalPos - startPos).Magnitude
            local movedDist = 0
            local speed = 55
            local startTime = tick()

            while movedDist < dist and not _G.StopDriving and value do
                if not value or (t and t:GetAttribute(_G.keys[3])) and not CheckingIsHacking() then
                    local carclip = model.PrimaryPart:FindFirstChild("CarClip")
                    if carclip then carclip:Destroy() end
                    break
                end
                task.wait()

                if _G["StopDriving"] then break end
                if Client.Character.Humanoid.Health <= 0 then break end
                if not _G["Auto ATM"] or not Client.Character.Humanoid.Sit then
                    break
                end

                if TeleportDetect() then
                    local carclip = model.PrimaryPart:FindFirstChild("CarClip")
                    if carclip then carclip:Destroy() end
                    Driveto(model, destination, value, t)
                    break
                end

                if Client.Character.Humanoid.Sit then
                    if model.PrimaryPart:FindFirstChild("CarClip") then
                        if waypoint.Action == Enum.PathWaypointAction.Jump then
                            local downPos = model.PrimaryPart.Position + Vector3.new(0, 6, 0)
                            local jumpRotation = CFrame.lookAt(downPos, downPos + dir)
                            model:SetPrimaryPartCFrame(jumpRotation)
                            task.wait(0.2)
                        end

                        local dt = tick() - startTime
                        movedDist = math.min(dt * speed, dist)
                        local newPos = startPos + dir * movedDist
                        local rotation = CFrame.lookAt(newPos, newPos + dir)
                        model:SetPrimaryPartCFrame(rotation)
                    else
                        local i = Instance.new("BodyVelocity")
                        i.Name = "CarClip"
                        i.MaxForce = Vector3.new(100000, 100000, 100000)
                        i.P = 1250
                        i.Velocity = Vector3.zero
                        i.Parent = model.PrimaryPart
                    end
                end
            end

            if _G["StopDriving"] then break end
        end

        local carclip = model.PrimaryPart:FindFirstChild("CarClip")
        if carclip then carclip:Destroy() end

    else
        warn("Pathfinding failed: ", path.Status)
    end
end

function StopWalking()
    _G["StopWalking"] = true
    if Client.Character and Client.Character:FindFirstChild("Humanoid") then
        Client.Character.Humanoid:MoveTo(Client.Character.HumanoidRootPart.Position)
    end
    task.wait()
    _G["StopWalking"] = false
end

function Get_Vehicles(types: string, callback)
    for _, b in ipairs(workspace:FindFirstChild("Vehicles") or {}) do
        if b:GetAttribute('OwnerUserId') ~= Client.UserId then
            local Checker = GetInfo(types)
            if Checker[2] then
                Functions.get("toggle_equip_item_1", Checker[3])
            end
        end
        if b:GetAttribute('OwnerUserId') == Client.UserId and not CheckingIsHacking() and not TeleportDetect() then
            task.wait(0.2)
            Functions.send("lock_vehicle", b, true)
            task.wait()
            callback(b)
        end
    end
end

local Functions = require(replicated.Modules.Core.Net)

local LoadFuncs = {}
LoadFuncs.__index = LoadFuncs

LoadFuncs['Auto ATM'] = setmetatable({}, {__call = function(self, value : boolean)
    if _G['AutoBike'] then
        Get_Vehicles("BMX",function(v)
            if not Client.Character.Humanoid.Sit and not CheckingIsHacking() and not TeleportDetect() then 
                v:SetPrimaryPartCFrame(Client.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5))
                fireproximityprompt(v.Chassis.DrivePromptAttachment.DrivePrompt, 1)
            elseif Client.Character.Humanoid.Sit and not CheckingIsHacking() and not TeleportDetect() then 
                local hacktool = GetInfo(_G['HackToolClass'])
                if hacktool[2] then 
                    if hacktool[1] >= 0 then
                        local closestATM, shortestDist = nil, math.huge
                        for _, vATM in ipairs(workspace.Map.Props:GetChildren()) do
                            if vATM.Name == "ATM" then
                                _G.keys = {}
                                for k in pairs(vATM:GetAttributes()) do table.insert(_G.keys, k) end
                                table.sort(_G.keys)
                                if _G.keys[3] and vATM:GetAttribute(_G.keys[3]) == false then
                                    local d = dist(vATM.Area.CFrame)
                                    if d < shortestDist then
                                        closestATM = vATM
                                        shortestDist = d
                                    end
                                end
                            end
                        end
                        if closestATM then 
                            if closestATM:GetAttribute(_G.keys[3]) == false then
                                repeat task.wait()
                                    local distance = dist(closestATM.Area.CFrame)

                                    if distance > 5 and Humanoid.Sit and not CheckingIsHacking() and not TeleportDetect() then
                                        Driveto(v, closestATM.Area.Position, value, closestATM)
                                    elseif distance < 5 and Humanoid.Sit and not CheckingIsHacking() and not TeleportDetect() then
                                        if _G.Deposit and GetMoney() >= _G.Money then
                                            Functions.get("transfer_funds","hand","bank",_G.Money)
                                        end
                                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

                                    elseif distance < 5 and not Humanoid.Sit and not TeleportDetect() then
                                        if not CheckingIsHacking() then
                                            Functions.send("request_begin_hacking_2", closestATM, _G['HackToolClass'])
                                        else
                                            task.wait(1.2)
                                            Functions.send("atm_win_3", closestATM)
                                        end
                                    end

                                until closestATM:GetAttribute(_G.keys[3]) == true or not value or hacktool[1] == 0
                            end
                        end
                    end
                else 
                    if GetMoney() <= GetChipPrice(_G.HackToolClass)*_G.Amount then
                        if ATMMoney()  >= GetChipPrice(_G.HackToolClass) then
                            local closestATMs, shortestDistd = nil, math.huge
                            for _, vs in ipairs(workspace.Map.Props:GetChildren()) do
                                if vs.Name == "ATM" then
                                    _G.keys = {}
                                    for k in pairs(vs:GetAttributes()) do table.insert(_G.keys, k) end
                                    table.sort(_G.keys)
                                    if _G.keys[3] and vs:GetAttribute(_G.keys[3]) == false then
                                        local d = dist(vs.Area.CFrame)
                                        if d < shortestDistd then
                                            closestATMs = vs
                                            shortestDistd = d
                                        end
                                    end
                                end
                            end
                            if closestATMs then 
                                if closestATMs:GetAttribute(_G.keys[3]) == false then
                                    repeat task.wait()
                                        if dist(closestATMs.Area.CFrame) > 5 and not  CheckingIsHacking() and not TeleportDetect() then 
                                            Driveto(v, closestATMs.Area.Position, value,closestATMs)
                                        elseif dist(closestATMs.Area.CFrame) < 5 and not CheckingIsHacking() and not TeleportDetect() and Humanoid.Sit then
                                            Functions.send("transfer_funds","bank","hand",GetChipPrice(_G.HackToolClass)*_G.Amount-GetMoney())		
                                        end
                                        return											
                                    until not value or GetMoney() <= GetChipPrice(_G.HackToolClass)*_G.Amount
                                end
                            end
                        end
                    else
                        if dist(CFrame.new(-212, 255, 387)) < 20 then
                            if GetMoney() >= GetChipPrice(_G.HackToolClass)*_G.Amount then
                                for i = 1, _G["Amount"] do
                                    Functions.get("purchase_consumable", workspace:WaitForChild("ShopZone_Illegal"), _G["HackToolClass"])
                                end
                                return
                            end
                        end
                        Driveto(v, Vector3.new(-212.181717, 255.525162, 387.744324), _G['Auto ATM'])	
                    end		
                end
            end
        end)
    else 

    end
end})

LoadFuncs["Auto Janitor Quest"] = setmetatable({}, {__call = function(self, value: boolean)
    if not value then StopWalking() end
    if value then
        if Client:GetAttribute("Job") == "janitor" then
            if Client.Character:FindFirstChild('Mop') then
                local nearestPuddle = nil
                local shortestDistance = math.huge

                for _, puddle in ipairs(workspace.Map.Tiles.BurgerPlaceTile.BurgerPlace.Interior.Puddles:GetChildren()) do
                    if puddle:IsA("BasePart") and puddle.Size.Magnitude > 0.001 and puddle.Transparency < 1 and puddle.Name ~= "NastyPuddle" and puddle.Name ~= "ToxicPuddle" and puddle.Name ~= "OilPuddle" then
                        local distance = (puddle.Position - Client.Character.HumanoidRootPart.Position).Magnitude
                        if distance < shortestDistance then
                            nearestPuddle = puddle
                            shortestDistance = distance
                        end
                    end
                end

                if nearestPuddle then
                    walkTo(nearestPuddle.Position, value)
                end
            else
                Humanoid:EquipTool('Mop')
            end
        else
            if dist(CFrame.new(110, 255, -309)) < 3 then
                Functions.send("apply_for_job", workspace:WaitForChild("BurgePlaceBeacon"))
            end
            walkTo(Vector3.new(110.824829, 255.190384, -309.609131), value)
        end
    end
end})

LoadFuncs["Auto Steak House"] = setmetatable({}, {
    __call = function(self, value: boolean)
        if not value then StopWalking() return end

        local steakList = {"Steak", "BronzeSteak", "SilverSteak", "GoldenSteak", "DiamondSteak"}
        local progressGui = Client.PlayerGui:FindFirstChild("ProgressBar")
        if progressGui then
            progressGui = progressGui:FindFirstChild("ProgressBarFrame")
        end
        local RootPart = Client.Character and Client.Character:FindFirstChild("HumanoidRootPart")

        local hasSteak = false
        local steakTool = nil

        for _, name in pairs(steakList) do
            if Backpack:FindFirstChild(name) then
                hasSteak = true
                steakTool = Backpack:FindFirstChild(name)
                break
            elseif Character:FindFirstChild(name) then
                hasSteak = true
                break
            end
        end

        if Client:GetAttribute("Job") == "steakhouse_cook" then
            if not hasSteak and (not progressGui or not progressGui.Visible) then
                if dist(CFrame.new(-279.035919, 256.224487, 334.839172)) < 5 then
                    vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
                walkTo(Vector3.new(-279.16619873046875, 256.2244873046875, 335.1399841308594), value)
            else
                if hasSteak and (not progressGui or not progressGui.Visible) then
                    if steakTool then
                        Humanoid:EquipTool(steakTool)
                    end
                    if workspace:FindFirstChild("Beacon") and workspace.Beacon.PrimaryPart then
                        walkTo(workspace.Beacon.PrimaryPart.Position, value)
                    end
                elseif progressGui and progressGui.Visible then
                    local scale = progressGui.MainFrame.BarAmount.Size.X.Scale
                    if scale > 0.95 and scale < 1 then
                        for _, v in pairs(workspace.Map.Tiles.ShoppingTile.SteakHouse.Interior:GetChildren()) do
                            if v.Name == "Grill" then
                                Functions.send("finish_grilling_2", v, "Perfect")
                            end
                        end
                    end
                end
            end
        else
            if dist(CFrame.new(-234.644211, 256.224518, 339.919342)) < 5 then
                Functions.send("apply_for_job", workspace.Map.Tiles.ShoppingTile.SteakHouse.Interior.SteakHouseBeacon)
            end
            walkTo(Vector3.new(-234.56198120117188, 256.2244873046875, 339.0831298828125), value)
        end
    end
})

LoadFuncs["Auto Seven Eleven Quest"] = setmetatable({}, {__call = function(self, Value : boolean)
    if not Value then StopWalking() end
    if Client:GetAttribute("Job") == "shelf_stocker" then
        if not Client.Backpack:FindFirstChild("BoxTool") and not Client.Character:FindFirstChild("BoxTool") then
            if dist(CFrame.new(143, 255, 207)) < 5 then
                fireproximityprompt(workspace.Map.Tiles.GasStationTile.Quick11.Interior.ShelfStockingJob.NormalBox.ProximityPrompt, 3)
            end
            walkTo(Vector3.new(143, 255, 207), Value)
        else
            if Client.Character:FindFirstChild("BoxTool") then
                repeat
                    task.wait()
                    for _, v in pairs(workspace.Map.Tiles.GasStationTile.Quick11.Interior.ShelfStockingJob.Shelves:GetChildren()) do
                        if v:FindFirstChild("Attachment") then
                            walkTo(v.Position, Value)
                        end
                    end
                until not Client.Character:FindFirstChild("BoxTool") or not Value
            else
                Humanoid:EquipTool(Client.Backpack:FindFirstChild("BoxTool"))
            end
        end
    else
        if dist(CFrame.new(165.542587, 255.190521, 203.767914)) < 5 then
            Functions.send("apply_for_job", workspace:WaitForChild("Map"):WaitForChild("Tiles"):WaitForChild("GasStationTile"):WaitForChild("Quick11"):WaitForChild("Interior"):WaitForChild("Quick11Beacon"))
        end
        walkTo(Vector3.new(166.34539794921875, 255.19053649902344, 203.02333068847656), Value)
    end
end})

LoadFuncs['EnabledCustomWalkSpeed'] = setmetatable({}, {__call = function(self, value : boolean)
    if value then
        Functions.send("set_sprinting_1", true)
        local hum = Client.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetAttribute("TargetWalkSpeed", _G['SpeedAmount'])
            hum.WalkSpeed = _G['SpeedAmount']
        end
    else
        Functions.send("set_sprinting_1", false)
        local hum = Client.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetAttribute("TargetWalkSpeed", 8)
            hum.WalkSpeed = 8
        end
    end
end})

LoadFuncs['EnabledCustomJumpPower'] = setmetatable({}, {__call = function(self, value : boolean)
    local hum = Client.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if value then
            hum.JumpHeight = _G['JumpAmount']
        else
            hum.JumpHeight = 3.895
        end
    end
end})

LoadFuncs['AutoRespawn'] = setmetatable({}, {__call = function(self, value : boolean)
    if not value then _G["detectedTeleport"] = false return end
    local deathScreen = Client.PlayerGui:FindFirstChild("DeathScreen")
    if deathScreen then
        local holder = deathScreen:FindFirstChild("DeathScreenHolder")
        if holder and holder.Visible then
            Functions.send('death_screen_request_respawn')
        end
    end
end})

LoadFuncs['AutoRejoinDieded'] = setmetatable({}, {__call = function(self, value : boolean)
    if Client.Character and Client.Character.Humanoid.Health <= 0 then
        teleport:Teleport(game.PlaceId, Client)
    end
end})

LoadFuncs['AntiDied'] = setmetatable({}, {__call = function(self, value : boolean)
    while _G['AntiDied'] do
        task.wait(0.8)
        if Client.Character and Client.Character.Humanoid.Health <= 30 then
            local root = Client.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.Anchored = _G['AntiDied']
                Client.Character:PivotTo(CFrame.new(root.CFrame.X, root.CFrame.Y + 60, root.CFrame.Z))
            end
        end
    end
end})

LoadFuncs['DamageAura'] = setmetatable({}, {__call = function(self, value : boolean)
    if value then
        for _, v in pairs(Client.Character:GetChildren()) do
            if v:IsA('Tool') then
                for _, vx in pairs(game:GetService("Players"):GetPlayers()) do
                    if vx ~= Client and vx.Character and vx.Character:FindFirstChild("HumanoidRootPart") then
                        if dist(vx.Character.HumanoidRootPart.CFrame) < _G['Around'] then
                            Functions.send("melee_attack", v, {vx}, vx.Character.HumanoidRootPart.CFrame, 0.4)
                        end
                    end
                end
            end
        end
    end
end})

task.spawn(function()
    while task.wait() do
        if _G['Auto Seven Eleven Quest'] or _G['Auto Janitor Quest'] or _G['Auto Steak House'] or _G['Auto ATM'] then
            local detected = false
            local notifFrame = Client.PlayerGui:FindFirstChild("Notifications")
            if notifFrame then
                local frame = notifFrame:FindFirstChild("Frame")
                if frame then
                    for _, v in pairs(frame:GetChildren()) do
                        if v.Name == "Notification" and v.Text == "Teleport detected" then
                            detected = true
                            break
                        end
                    end
                end
            end
            _G.detectedTeleport = detected
            _G['AIWALKINGSPEED'] = _G.detectedTeleport and 24 or _G['OLD']

            pcall(function()
                Functions.send("set_sprinting_1", true)
                local hum = Client.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:SetAttribute("TargetWalkSpeed", _G['AIWALKINGSPEED'])
                    hum.WalkSpeed = _G['AIWALKINGSPEED']
                end
            end)
        end
    end
end)

if not _G.Has then
    _G.Has = Drawing.new("Circle")
    _G.Has.Thickness = 1.5
    _G.Has.Color = Color3.fromRGB(255,255,255)
    _G.Has.Filled = false
end

RunService.Stepped:Connect(function()
    local Mouse = Client:GetMouse()
    _G.Has.Radius = _G['AroundRadius']
    _G.Has.Visible = _G.FovCircle
    _G.Has.Position = Vector2.new(Mouse.X, Mouse.Y + 55)
end)

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Yonix Hub",
    Icon = "rbxassetid://81857105973850",
    Author = "Yonix Team",
    Folder = "Yonix Hub",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Name = Client.Name,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. Client.UserId
    },
    KeySystem = {
        Note = "Enter key to access Yonix Hub",
        API = {
            {
                Type = "platoboost",
                ServiceId = 1930,
                Secret = "92633672-2f11-4637-87fe-6d825b425df7"
            }
        }
    }
})

Window:EditOpenButton({ Enabled = false })

local ToggleBtn = Instance.new("ImageButton", CoreGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Image = "rbxassetid://81857105973850"
ToggleBtn.Draggable = true
ToggleBtn.MouseButton1Click:Connect(function()
    Window:Toggle()
end)

UserInputService.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.T then
        Window:Toggle()
    end
end)

local TabHome = Window:Tab({ Title = "Home", Icon = "home" })
local TabVisual = Window:Tab({ Title = "Visual", Icon = "eye" })

local SectionATM = TabHome:Section({ Title = "ATM" })
local SectionJobs = TabHome:Section({ Title = "Jobs" })
local SectionModifiers = TabHome:Section({ Title = "Modifiers" })
local SectionSettings = TabHome:Section({ Title = "Settings" })
local SectionCrates = TabHome:Section({ Title = "Crates" })

local SectionGeneral = TabVisual:Section({ Title = "General" })
local SectionAimbot = TabVisual:Section({ Title = "Aimbot" })

SectionATM:Dropdown({
    Title = "Select Hack Tool Type",
    Values = { "HackToolBasic", "HackToolPro", "HackToolUltimate" },
    Default = _G.HackToolClass,
    Callback = function(v) _G.HackToolClass = v end
})

SectionATM:Slider({
    Title = "Item Amount",
    Min = 1, Max = 10, Default = _G.Amount,
    Callback = function(v) _G.Amount = v end
})

SectionATM:Slider({
    Title = "Money Amount",
    Min = 1, Max = 10000, Default = _G.Money,
    Callback = function(v) _G.Money = v end
})

SectionATM:Toggle({
    Title = "Auto ATM",
    Description = "ไอ้สัสขโมย",
    Default = _G["Auto ATM"],
    Callback = function(v)
        _G["Auto ATM"] = v
        if LoadFuncs["Auto ATM"] then
            task.spawn(function()
                while _G["Auto ATM"] do
                    LoadFuncs["Auto ATM"](v)
                    task.wait(0.1)
                end
            end)
        end
    end
})

SectionATM:Toggle({
    Title = "Enabled Bike",
    Description = "ไอ้สัสขโมยระดับโหดๆ",
    Default = _G.AutoBike,
    Callback = function(v) _G.AutoBike = v end
})

SectionATM:Toggle({
    Title = "Enabled Deposit",
    Description = "EZ Money",
    Default = _G.Deposit,
    Callback = function(v) _G.Deposit = v end
})

SectionJobs:Toggle({
    Title = "Auto Janitor",
    Description = "ภารโรง",
    Default = _G["Auto Janitor Quest"],
    Callback = function(v)
        _G["Auto Janitor Quest"] = v
        if LoadFuncs["Auto Janitor Quest"] then
            task.spawn(function()
                while _G["Auto Janitor Quest"] do
                    LoadFuncs["Auto Janitor Quest"](v)
                    task.wait(0.1)
                end
            end)
        end
    end
})

SectionJobs:Toggle({
    Title = "Auto Steak House",
    Description = "เชฟ",
    Default = _G["Auto Steak House"],
    Callback = function(v)
        _G["Auto Steak House"] = v
        if LoadFuncs["Auto Steak House"] then
            task.spawn(function()
                while _G["Auto Steak House"] do
                    LoadFuncs["Auto Steak House"](v)
                    task.wait(0.1)
                end
            end)
        end
    end
})

SectionJobs:Toggle({
    Title = "Auto 7-11",
    Description = "พนักงานเซเว่น",
    Default = _G["Auto Seven Eleven Quest"],
    Callback = function(v)
        _G["Auto Seven Eleven Quest"] = v
        if LoadFuncs["Auto Seven Eleven Quest"] then
            task.spawn(function()
                while _G["Auto Seven Eleven Quest"] do
                    LoadFuncs["Auto Seven Eleven Quest"](v)
                    task.wait(0.1)
                end
            end)
        end
    end
})

SectionModifiers:Toggle({
    Title = "Enabled Custom WalkSpeed",
    Description = "WalkSpeed",
    Default = _G.EnabledCustomWalkSpeed,
    Callback = function(v)
        _G.EnabledCustomWalkSpeed = v
        if LoadFuncs.EnabledCustomWalkSpeed then
            LoadFuncs.EnabledCustomWalkSpeed(v)
        end
    end
})

SectionModifiers:Slider({
    Title = "Speed Amount",
    Min = 1, Max = 30, Default = _G.SpeedAmount,
    Callback = function(v) _G.SpeedAmount = v end
})

SectionModifiers:Toggle({
    Title = "Enabled Custom JumpPower",
    Description = "JumpPower",
    Default = _G.EnabledCustomJumpPower,
    Callback = function(v)
        _G.EnabledCustomJumpPower = v
        if LoadFuncs.EnabledCustomJumpPower then
            LoadFuncs.EnabledCustomJumpPower(v)
        end
    end
})

SectionModifiers:Slider({
    Title = "Jump Amount",
    Min = 1, Max = 25, Default = _G.JumpAmount,
    Callback = function(v) _G.JumpAmount = v end
})

SectionSettings:Toggle({
    Title = "Auto Respawn if u died",
    Description = "แก้ให้ถ้าแม่งตายห่าตายโหง",
    Default = _G.AutoRespawn,
    Callback = function(v)
        _G.AutoRespawn = v
        if LoadFuncs.AutoRespawn then
            LoadFuncs.AutoRespawn(v)
        end
    end
})

SectionSettings:Toggle({
    Title = "Anti Died",
    Description = "กันแม่งถ้าแม่งตายอะ",
    Default = _G.AntiDied,
    Callback = function(v)
        _G.AntiDied = v
        if LoadFuncs.AntiDied then
            task.spawn(function()
                while _G.AntiDied do
                    LoadFuncs.AntiDied(v)
                    task.wait(0.8)
                end
            end)
        end
    end
})

SectionSettings:Toggle({
    Title = "Auto Rejoin When Died",
    Description = "แม่งจะรีเกมตอนที่แม่งตายห่าตายโหงอะ",
    Default = _G.AutoRejoinDieded,
    Callback = function(v)
        _G.AutoRejoinDieded = v
        if LoadFuncs.AutoRejoinDieded then
            LoadFuncs.AutoRejoinDieded(v)
        end
    end
})

SectionSettings:Slider({
    Title = "Instant Speed",
    Min = 1, Max = 150, Default = _G.AIWALKINGSPEED,
    Callback = function(v)
        _G.AIWALKINGSPEED = v
        _G.OLD = v
    end
})

SectionCrates:Dropdown({
    Title = "Choose Ammo Crate Type",
    Values = { "Pistol", "Rifle", "Shotgun", "Special" },
    Default = _G.AmmoCrate,
    Callback = function(v) _G.AmmoCrate = v end
})

SectionCrates:Button({
    Title = "Open Ammo Crate (Must be Near)",
    Callback = function()
        Functions.send('open_crate', workspace:WaitForChild("Map"):WaitForChild("Tiles"):WaitForChild("GunShopTile"):WaitForChild("PatriotWeapons"):WaitForChild("Interior"):WaitForChild("Crates"):WaitForChild("Ammo Crate"):WaitForChild("CrateOptions"):WaitForChild(_G.AmmoCrate), "money")
    end
})

SectionCrates:Dropdown({
    Title = "Choose Gun Crate Type",
    Values = { "Basic", "Advanced", "Superior", "Elite", "Legendary", "Omega" },
    Default = _G.GunCrate,
    Callback = function(v) _G.GunCrate = v end
})

SectionCrates:Button({
    Title = "Open Gun Crate (Must be Near)",
    Callback = function()
        Functions.send('open_crate', workspace:WaitForChild("Map"):WaitForChild("Tiles"):WaitForChild("GunShopTile"):WaitForChild("PatriotWeapons"):WaitForChild("Interior"):WaitForChild("Crates"):WaitForChild("Weapon Crate"):WaitForChild("CrateOptions"):WaitForChild(_G.GunCrate), "money")
    end
})

SectionCrates:Dropdown({
    Title = "Choose Car Crate Type",
    Values = { "Basic", "Rare", "Elite" },
    Default = _G.CaseCrate,
    Callback = function(v) _G.CaseCrate = v end
})

SectionCrates:Button({
    Title = "Open Car Crate (Must be Near)",
    Callback = function()
        Functions.send('open_crate', workspace:WaitForChild("Map"):WaitForChild("Tiles"):WaitForChild("PrestigeDealerAndHousing"):WaitForChild("PrestigeCarDealer"):WaitForChild("Interior"):WaitForChild("Crates"):WaitForChild("Car Crate"):WaitForChild("CrateOptions"):WaitForChild(_G.CaseCrate), "money")
    end
})

SectionGeneral:Toggle({
    Title = "Enabled Damage Aura",
    Description = "DamageAura",
    Default = _G.DamageAura,
    Callback = function(v)
        _G.DamageAura = v
        if LoadFuncs.DamageAura then
            task.spawn(function()
                while _G.DamageAura do
                    LoadFuncs.DamageAura(v)
                    task.wait(0.1)
                end
            end)
        end
    end
})

SectionGeneral:Slider({
    Title = "Range",
    Min = 1, Max = 30, Default = _G.Around,
    Callback = function(v) _G.Around = v end
})

SectionAimbot:Toggle({
    Title = "Enabled Fov Circle",
    Description = "Circle Fov",
    Default = _G.FovCircle,
    Callback = function(v) _G.FovCircle = v end
})

SectionAimbot:Slider({
    Title = "Radius Circle",
    Min = 1, Max = 200, Default = _G.AroundRadius,
    Callback = function(v) _G.AroundRadius = v end
})

SectionAimbot:Slider({
    Title = "Field of View",
    Min = 1, Max = 120, Default = _G["Field of View"],
    Callback = function(v)
        _G["Field of View"] = v
        workspace.Camera.FieldOfView = v
    end
})
