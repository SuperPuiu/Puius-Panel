local module = {}
local Settings = require(script.Parent.Parent.Settings)
local Players = game:GetService("Players")
local Replicated = game:GetService("ReplicatedStorage")

module.Kick = function(_, Targets, Arguments)
  for _, Player in pairs(Targets) do
    if typeof(Player) ~= "Player" then continue end

    Player:Kick(Arguments[1] or "You have been kicked by a moderator.")
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

module.RemoveTool = function(Executor, Targets, Arguments)
  if Executor.Backpack:FindFirstChild(Arguments[1]) then
    Executor.Backpack[Arguments[1]]:Destroy()
  else
    for _, Player in pairs(Targets) do
      if typeof(Player) ~= "Player" then continue end

      local Tool = Player.Backpack:FindFirstChild()
      if Tool then Tool:Destroy() end
    end
  end
end

module.Respawn = function(_, Targets)
  for _, Player in pairs(Targets) do
    if typeof(Player) ~= "Player" then continue end

    Player:LoadCharacter()
  end
end

module.GoTo = function(Executor, Targets)
  local Player = Targets[1]
  if typeof(Player) ~= "Player" then return "Target is not a valid player." end

  Executor.Character:PivotTo(Player.Character:GetPivot() * CFrame.new(0, 0, -3))
end

module.Bring = function(Executor, Targets)

end

module.Team = function(Executor, Targets)

end

module.Give = function(Executor, Targets, Arguments)
  local Tool = Replicated:FindFirstChild(Arguments[1])

  if not Tool then
    Tool = Replicated:FindFirstChild(Targets[1])
    if Tool then
      Tool:Clone().Parent = Executor.Backpack
    end
  else
    for _, Player in pairs(Targets) do
      if typeof(Player) ~= "Player" then continue end

      Tool:Clone().Parent = Player.Backpack
    end
  end
end

module.Freeze = function(_, Targets)
  for _, Player in pairs(Targets) do
    if typeof(Player) ~= "Player" then continue end
    if not Player.Character then continue end
    if not Player.Character:FindFirstChild("HumanoidRootPart") then continue end

    Player.Character.HumanoidRootPart.Anchored = not Player.Character.HumanoidRootPart.Anchored
  end
end

return module
