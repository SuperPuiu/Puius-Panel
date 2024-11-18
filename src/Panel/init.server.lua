local Event

local Settings = require(script.Settings)
local Permissions = {}
local PluginsName = {}
local Plugins = {}

local function GivePanel(Player)
  if Player.PlayerGui:FindFirstChild("PanelUI") then return end
  local Panel = script.PanelUI:Clone()

  for _, v in pairs(script.Framework:GetChildren()) do
    v.Parent = Panel.Framework
  end

  for _, v in pairs(Panel.Framework:GetChildren()) do
    if not v:IsA("ModuleScript") then v.Enabled = true end
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
    PluginsName[Plugin.Name] = {}
    PluginsName[Plugin.Name]["Name"] = Commands.Name

    for Command, Attached in pairs(Commands) do
      if Command == "Name" or Command == "RequireExArguments" or Command == "Descriptions" then continue end

      Plugins[string.lower(Command)] = Attached
      PluginsName[Plugin.Name][Command] = Command
    end
  end

  Event.OnServerInvoke = function(Player, Data)
    if Data.Type == "RequestPlugins" then
      return PluginsName
    else
      local Status, AdditionalResponse = pcall(function()
        if not Permissions.Administrators[Player.UserId] and not Permissions.Moderators[Player.UserId] then return "User is not authorized to call the remote function." end
        if not Data then return "No data passed." end

        local Command = Data.Command
        local Targets = Data.Targets
        local Arguments = Data.Arguments

        if not Arguments then Arguments = {} end
        if type(Command) ~= "string" or type(Targets) ~= "table" then return "Unknown data types given." end
        return Plugins[Command](Player, Targets, Arguments) or `Executed {Command} command!`
      end)

      return AdditionalResponse or Status
    end
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
