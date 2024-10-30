local Event

local Settings = require(script.Settings)
local Permissions = {}
local Plugins = {}

local function GivePanel(Player)
  if Player.PlayerGui:FindFirstChild("PanelUI") then return end
  local Panel = script.PanelUI:Clone()

  for _, v in pairs(script.Framework:GetChildren()) do
    v.Parent = Panel.Framework
    v.Enabled = true
  end

  Panel.Parent = Player.PlayerGui
end

local function Main()
  if not game:GetService("ReplicatedStorage"):FindFirstChild("PanelRemote") then
    Event = Instance.new("RemoteFunction")
    Event.Parent = game:GetService("ReplicatedStorage")
    Event.Name = "PanelRemote"
  end

  Permissions.Administrators = Settings.Administrators
  Permissions.Moderators = Settings.Moderators

  for _, Plugin in pairs(script.Plugins:GetChildren()) do
    local Commands = require(Plugin)

    for Command, Attached in pairs(Commands) do
      Plugins[string.lower(Command)] = Attached
    end
  end

  Event.OnServerInvoke = function(Player, Data)
    if not Permissions.Administrators[Player.UserId] or Permissions.Moderators then return "User is not authorized to call the remote function." end
    if not Data then return "No data passed." end

    local Command = Data.Command
    local Target = Data.Target
    local Arguments = Data.Arguments

    if type(Command) ~= "string" or type(Target) ~= "table" or type(Arguments) ~= "table" then return "Unknown data types given." end
    return Plugins[Command](Player, Target, Arguments) or `Executed {Command} command!`
  end

  game:GetService("Players").PlayerAdded:Connect(function(Player)
    if Permissions.Administrators[Player.UserId] or Permissions.Moderators[Player.UserId] then
      GivePanel(Player)
    end
  end)

  for _, Player in pairs(game:GetService("Players"):GetPlayers()) do
    if Permissions.Administrators[Player.UserId] or Permissions.Moderators[Player.UserId] then
      GivePanel(Player)
    end
  end
end

Main()
