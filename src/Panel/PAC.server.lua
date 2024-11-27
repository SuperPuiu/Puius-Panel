local ModelsWhitelisted = {}
local TemporaryBypass = {}

local Settings = require(script.Parent.Settings)
if Settings.PAC.EnablePAC == false then return end

local TimeBetweenLoops = 0.03

local BindableEvent = Instance.new("BindableEvent")
BindableEvent.Parent = game.ServerStorage
BindableEvent.Name = "PAC"

local function FireRay(start, rayStop, filter)
  -- Implementation of Puius Raycast Module
  local direction = rayStop - start

  local raycastParams = RaycastParams.new()
  raycastParams.FilterDescendantsInstances = filter or {}
  raycastParams.FilterType = Enum.RaycastFilterType.Exclude
  raycastParams.IgnoreWater = true

  local data = workspace:Raycast(start, direction, raycastParams)

  return data
end

local function IsFlying(Character)

end

local function IsNoclipping(Player, LastPosition)
  if TemporaryBypass[Player] == true then LastPosition = nil return end

  if not LastPosition then
    LastPosition = Player.Character.HumanoidRootPart.Position
  end

  local data = FireRay(LastPosition, Player.Character.HumanoidRootPart.Position, ModelsWhitelisted)

  if data then if data.Instance then Player.Character:PivotTo(CFrame.new(LastPosition.X, LastPosition.Y, LastPosition.Z)) end end
  LastPosition = Player.Character.HumanoidRootPart.Position

  return LastPosition
end

game.Players.PlayerAdded:Connect(function(Player)
  Player.CharacterAdded:Connect(function(Character)
    table.insert(ModelsWhitelisted, Character)
    local LastPosition

    while true do
      if not Character then break end
      if not Character:FindFirstChild("HumanoidRootPart") then break end
      if Character.Humanoid.Health <= 0 then break end

      pcall(function()
        if Settings.PAC.EnableNoclipCheck then LastPosition = IsNoclipping(Player) end
        if Settings.PAC.EnableFlyCheck then IsFlying(Player) end
      end)

      task.wait(TimeBetweenLoops)
    end
  end)
end)

BindableEvent.Event:Connect(function(Data)
  if Data.Type == "AddWhitelistedInstance" then
    table.insert(ModelsWhitelisted, Model)
  elseif Data.Type == "ChangeTimeBetweenLoops" then
    TimeBetweenLoops = Data.Time
  elseif Data.Type == "GrantBypass" then
    TemporaryBypass[Data.Player] = true
  elseif Data.Type == "RevokeBypass" then
    TemporaryBypass[Data.Player] = false
  end
end)
