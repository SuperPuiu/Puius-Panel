local module = {}
local Settings = require(script.Parent.Parent.Parent.Settings)
local Replicated = game:GetService("ReplicatedStorage")

local function NextPlayer(List, Index)
  local NewItem = List[Index]

  if typeof(NewItem) ~= "Instance" then return end
  if not NewItem:IsA("Player") then return end

  return NewItem
end

-- Metadata
module.Name = "Vanilla Commands" -- This gives the category name when generating the buttons. Not adding it will result in the usage of the module's name.
module.Descriptions = {
  ["Kick"] = "kick <player> <message>", -- Use the same name which you used to implement the functionality of the said command.
  ["Ban"] = "ban <player> <message>",
  ["Unban"] = "unban <userid>",
  ["Team"] = "team <player> <team>",
  ["Give"] = "give <player> <tool>",
  ["RemoveTool"] = "removetool <player> <tool>"
  -- TODO: Finish descriptions.
} -- This allows help command to display information. When a command is not found within it, default text will be shown.
module.RequireExArguments = {} -- This allows the implementation of extended arguments. TODO.

-- Commands

module.Kick = function(_, Targets, Arguments)
  for i = 1, #Targets do
    local Player = NextPlayer(Targets, i)

    if Player then Player:Kick(Arguments[1] or "You have been kicked by a moderator.") end
  end
end

module.Ban = function(Executor, Targets, Arguments)
  -- Supports only single-target to prevent possible abuse.
  if game.PrivateServerId ~= nil and game.PrivateServerOwnerId ~= 0 then return "Unable to run BAN within a private server." end
  if not Settings.Administrators[Executor.UserId] then return "You must be an administrator to execute this command." end

  local Target = NextPlayer(Targets, 1)
  if not Target then return "Invalid target passed to BAN command." end

  local BanConfiguration = {
    UserIds = {Target.UserId},
    Duration = -1, -- Infinite ban.
    DisplayReason = Arguments[1] or "",
    PrivateReason = Arguments[2] or "",
    ExcludeAltAccounts = Arguments[3] or true,
    ApplyToUniverse = true
  }

  game:GetService("Players"):BanAsync(BanConfiguration)
  Target:Kick("You have been banned.")
end

module.Unban = function(Executor, Targets)
  -- Supports only single-target to prevent possible abuse.
  if game.PrivateServerId ~= nil and game.PrivateServerOwnerId ~= 0 then return "Unable to run UNBAN within a private server." end
  if not Settings.Administrators[Executor.UserId] then return "You must be an administrator to execute this command." end

  local Target = Targets[1]
  if tonumber(Target) == nil then return "Invalid target passed to UNBAN command." end

  local UnbanConfig = {
    UserIds = {Target},
    ApplyToUniverse = true,
  }

  game:GetService("Players"):UnbanAsync(UnbanConfig)
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
  for i = 1, #Targets do
    local Player = NextPlayer(Targets, i)
    if Player then Player.Character:PivotTo(Executor.Character:GetPivot() * CFrame.new(0, 0, -3)) end
  end
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
