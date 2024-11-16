local module = {}
local Settings = require(script.Parent.Parent.Settings)
local Replicated = game:GetService("ReplicatedStorage")

local function NextPlayer(List, Index)
  local NewItem = List[Index]

  if not typeof(NewItem) == "Instance" then return end
  if not NewItem:IsA("Player") then return end

  return NewItem
end

module.Kick = function(_, Targets, Arguments)
  for i = 1, #Targets do
    local Player = NextPlayer(Targets, i)

    if Player then Player:Kick(Arguments[1] or "You have been kicked by a moderator.") end
  end
end

module.Ban = function(Executor, Targets)
  if not Settings.Administrators[Executor.UserId] then return "You must be an administrator to execute this command." end
  local UserId
  local Target = Targets[1]
end

module.Unban = function(Executor, Targets)
  if not Settings.Administrators[Executor.UserId] then return "You must be an administrator to execute this command." end
  local User = Targets[1]
end

module.RemoveTool = function(_, Targets, Arguments)
  if not Arguments then return end

  for i = 1, #Targets do
    local Player = NextPlayer(Targets, i)
    if not Player then continue end

    if Player.Backpack:FindFirstChild(Arguments[1] or "") then Player.Backpack[Arguments[1]]:Destroy() end
  end
end

module.Respawn = function(_, Targets)
  for i = 1, #Targets do
    local Player = NextPlayer(Targets, i)
    
    if Player then Player:LoadCharacter() end
  end
end

module.GoTo = function(Executor, Targets)
  local Player = Targets[1]
  if typeof(Player) ~= "Instance" then return "Target is not an instance." end
  if Player:IsA("Player") ~= "Player" then return end

  Executor.Character:PivotTo(Player.Character:GetPivot() * CFrame.new(0, 0, -3))
end

module.Bring = function(Executor, Targets)

end

module.Team = function(_, Targets, Arguments)
  if not Arguments then return "No arguments passed for TEAM command." end
  if typeof(Arguments[1]) ~= "string" then return "Argument 1 isn't a string for TEAM command. Type is: "..typeof(Arguments[1]) end
  local Team = game:GetService("Teams"):FindFirstChild(Arguments[1] or "")

  if not Team then return "Argument 1 doesn't exist for TEAM command." end

  for i = 1, #Targets do
    local Player = NextPlayer(Targets, i)
    if Player then Player.Team = Team end
  end
end

module.Give = function(_, Targets, Arguments)
  local Tool = Replicated:FindFirstChild(Arguments[1] or "")

  if Tool then
    for i = 1, #Targets do
      local Player = NextPlayer(Targets, i)
      
      if Player then Tool:Clone().Parent = Player.Backpack end
    end
  end
end

module.Freeze = function(_, Targets)
  for _, Player in pairs(Targets) do
    if typeof(Player) ~= "Instance" then continue end
    if not Player:IsA("Player") then continue end
    if not Player.Character then continue end
    if not Player.Character:FindFirstChild("HumanoidRootPart") then continue end

    Player.Character.HumanoidRootPart.Anchored = not Player.Character.HumanoidRootPart.Anchored
  end
end

return module
