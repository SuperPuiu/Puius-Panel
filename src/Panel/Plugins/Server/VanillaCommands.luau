local module = {}
local Settings = require(script.Parent.Parent.Parent.Settings)
local Replicated = game:GetService("ReplicatedStorage")

-- Metadata
module.Name = "Vanilla Commands" -- This gives the panel button a custom name. Not adding it will result in the usage of the module's name.
module.Descriptions = {
  ["Kick"] = "kick <player> <message>", -- Use the same name which you used to implement the functionality of the said command.
  ["Ban"] = "ban <player> <message>",
  ["Unban"] = "unban <userid>",
  ["Team"] = "team <player> <team>",
  ["Give"] = "give <player> <tool>",
  ["RemoveTool"] = "removetool <player> <tool>"
  -- TODO: Finish descriptions.
} -- This allows help command to display information. When a command is not found within it, default text will be shown.
module.RequireExArguments = {
  ["Kick"] = {
    {["Message"] = "string"}
  },

  ["Give"] = {
    {["Tool"] = "string"}
  },

  ["RemoveTool"] = {
    {["Tool"] = "string"}
  },

  ["Ban"] = {
    {["DisplayReason"] = "string"},
    {["PrivateReason"] = "string"},
    {["Duration"] = "number"},
    {["ExcludeAltAccounts"] = "bool"},
  },

  ["Unban"] = {
    {["UserId"] = "number"}
  },

  ["Team"] = {
    {["Team"] = "string"}
  }
} -- This allows the implementation of extended arguments. They are automatically generated.

-- Commands

module.Kick = function(_, Targets, Arguments)
  for _, Player in pairs(Targets) do
    Player:Kick(Arguments.Message or "You have been kicked by a moderator.")
  end
end

module.Ban = function(Executor, Targets, Arguments)
  -- Supports only single-target to prevent possible abuse.
  if game.PrivateServerId ~= nil and game.PrivateServerOwnerId ~= 0 then return "Unable to run BAN within a private server." end
  if not Settings.Administrators[Executor.UserId] then return "You must be an administrator to execute this command." end

  local Target = Targets[1];
  if not Target then return "Invalid target passed to BAN command." end

  local BanConfiguration = {
    UserIds = {Target.UserId},
    Duration = -1, -- Infinite ban.
    DisplayReason = Arguments.DisplayReason or "",
    PrivateReason = Arguments.PrivateReason or "",
    ExcludeAltAccounts = Arguments.ExcludeAltAccounts or true,
    ApplyToUniverse = true
  };

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

  for _, Player in pairs(Targets) do
    if Player.Backpack:FindFirstChild(Arguments.Tool or "") then 
      Player.Backpack[Arguments.Tool]:Destroy() 
    end
  end
end

module.Respawn = function(_, Targets)
  for _, Player in pairs(Targets) do
    Player:LoadCharacter()
  end
end

module.GoTo = function(Executor, Targets)
  local Player = Targets[1]
  Executor.Character:PivotTo(Player.Character:GetPivot() * CFrame.new(0, 0, -3))
end

module.Bring = function(Executor, Targets)
  for _, Player in pairs(Targets) do
    Player.Character:PivotTo(Executor.Character:GetPivot() * CFrame.new(0, 0, -3))
  end
end

module.Team = function(_, Targets, Arguments)
  if not Arguments then return "No arguments passed for TEAM command." end
  if typeof(Arguments.Team) ~= "string" then return "Argument 1 isn't a string for TEAM command. Type is: "..typeof(Arguments.Team) end
  local Team = game:GetService("Teams"):FindFirstChild(Arguments.Team or "")

  if not Team then return "Argument 1 doesn't exist for TEAM command." end

  for _, Player in pairs(Targets) do
    Player.Team = Team
  end
end

module.Give = function(_, Targets, Arguments)
  local Tool = Replicated:FindFirstChild(Arguments.Tool or "", true)
  if not Tool or not Tool:IsA("Tool") then Tool = game:GetService("ServerStorage"):FindFirstChild(Arguments.Tool or "", true) end;

  if Tool then
    if not Tool:IsA("Tool") then return end

    for _, Player in pairs(Targets) do
      Tool:Clone().Parent = Player.Backpack
    end
  end
end

module.Freeze = function(_, Targets)
  for _, Player in pairs(Targets) do
    if not Player.Character then continue end
    if not Player.Character:FindFirstChild("HumanoidRootPart") then continue end

    Player.Character.HumanoidRootPart.Anchored = not Player.Character.HumanoidRootPart.Anchored
  end
end

return module
