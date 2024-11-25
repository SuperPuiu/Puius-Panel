local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local GUI = script.Parent.Parent
local Server = game:GetService("ReplicatedStorage"):WaitForChild("PanelRemote")
local LocalCommands = require(script.Parent.LocalCommands)

local Panel = script.Parent.Parent
local SettingsContainer = Panel.Settings.ScrollingFrame
local PlayerList = Panel.MainFrame.PlayerFrame

local CTRL_Down = false
local PlayersSelected = {}
local PluginsName = Server:InvokeServer({Type = "RequestPlugins"})
local DisplayInformation = 0 -- 0 = Display and name, 1 = Name and UserId, 2 = User only

local function HandleBoolSetting(Name)
  if Panel:GetAttribute(Name) then
    SettingsContainer[Name].State.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
  else
    SettingsContainer[Name].State.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
  end

  Panel:SetAttribute(Name, not Panel:GetAttribute(Name))
end

local function RefreshPlayerList()
  local Order = 0

  local function CreatePlayerButton(Player)
    local Template = Panel.MainFrame.PlayerFrame:FindFirstChild(Player.Name)

    if not Template then
      Template = PlayerList.TextButton:Clone()
      Template.Headshot.Image = game:GetService("Players"):GetUserThumbnailAsync(Player.UserId, 
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size60x60)

      Player.Destroying:Connect(function()
        Template:Destroy()
      end)

      Template.MouseButton1Up:Connect(function()
        if CTRL_Down then
          if not table.find(PlayersSelected, Player) then table.insert(PlayersSelected, Player) end
        else
          PlayersSelected = {Player}
        end
      end)
    end

    Template.Parent = PlayerList
    Template.Name = Player.Name
    Template.LayoutOrder = Order

    if DisplayInformation == 0 then
      Template.TextLabel.Text = string.format("%s\n<font color='#5a8a29'>(%s)</font>", Player.DisplayName, Player.Name)
    elseif DisplayInformation == 1 then
      Template.TextLabel.Text = string.format("%s\n<font color='#5a8a29'>(%i)</font>", Player.Name, Player.UserId)
    elseif DisplayInformation == 2 then
      Template.TextLabel.Text = Player.Name
    end
    Template.Visible = true
  end

  for _, Player in pairs(Players:GetPlayers()) do
    if Player.Team == nil then
      CreatePlayerButton(Player)
    end
  end

  for _, Team in pairs(game:GetService("Teams"):GetTeams()) do
    Order = Order + 1
    local TeamTemplate

    if not Panel.MainFrame.PlayerFrame:FindFirstChild(Team.Name) then
      TeamTemplate = Panel.MainFrame.PlayerFrame.TextLabel:Clone()
    else
      TeamTemplate = Panel.MainFrame.PlayerFrame[Team.Name]
    end

    TeamTemplate.Text = Team.Name
    TeamTemplate.Name = Team.Name
    TeamTemplate.Parent = Panel.MainFrame.PlayerFrame
    TeamTemplate.BackgroundColor3 = Team.TeamColor.Color
    TeamTemplate.Visible = true
    TeamTemplate.LayoutOrder = Order

    for _, Player in pairs(Team:GetPlayers()) do
      CreatePlayerButton(Player)
    end
  end

  PlayerList.CanvasSize = UDim2.new(0, PlayerList.UIListLayout.AbsoluteContentSize.X,
    0, PlayerList.UIListLayout.AbsoluteContentSize.Y)
end

local function RunCommand(Command, Arguments)
  Command = string.lower(Command)
  if not Arguments and LocalCommands[Command] then Arguments = LocalCommands[Command](PlayersSelected) end
  if Arguments == false then return end -- Hacky way to stop the panel from continuing to run a command. Useful for local commands.

  print(Server:InvokeServer({Command = Command, Targets = PlayersSelected, Arguments = Arguments}))
  PlayersSelected = {}
  RefreshPlayerList()
end

local function ChangeDisplayInfo(Number, Str)
  SettingsContainer.PlayerButtonNaming.ScrollingFrame.Visible = false
  SettingsContainer.PlayerButtonNaming.State.Text = Str
  DisplayInformation = Number
  RefreshPlayerList()
end

Panel.PanelButton.MouseButton1Up:Connect(function()
  Panel.MainFrame.Visible = not Panel.MainFrame.Visible
  Panel.Settings.Visible = false
end)

Panel.MainFrame.Title.ImageButton.MouseButton1Up:Connect(function()
  Panel.Settings.Visible = not Panel.Settings.Visible
  Panel.Assets.Quack:Play()
end)

Players.PlayerAdded:Connect(function()
  RefreshPlayerList()
end)

UIS.InputBegan:Connect(function(Input, Processed)
  if Processed then return end

  if Input.KeyCode == Enum.KeyCode.Equals then
    Panel.MainFrame.Visible = not Panel.MainFrame.Visible
    Panel.Settings.Visible = false
  elseif Input.KeyCode == Enum.KeyCode.LeftControl then
    CTRL_Down = true
  end
end)

UIS.InputEnded:Connect(function(Input)
  if Input.KeyCode == Enum.KeyCode.LeftControl then
    CTRL_Down = false
  end
end)

game:GetService("RunService").Stepped:Connect(function()
  for _, v in pairs(Panel.MainFrame.PlayerFrame:GetChildren()) do
    if not v:IsA("TextButton") or v.Name == "TextButton" then continue end

    if not table.find(PlayersSelected, Players:FindFirstChild(v.Name)) then
      v.BorderSizePixel = 0
      v.TextColor3 = Color3.fromRGB(255, 255, 255)
      v.FontFace.Bold = false
    else
      v.BorderSizePixel = 2
      v.TextColor3 = Color3.fromRGB(0, 108, 162)
      v.FontFace.Bold = true
    end
  end
end)

SettingsContainer.OutputOnExecution.State.MouseButton1Up:Connect(function()
  HandleBoolSetting("OutputOnExecution")
end)

SettingsContainer.TerminalVisibility.State.MouseButton1Up:Connect(function()
  HandleBoolSetting("TerminalVisibility")
  Panel.MainFrame.Terminal.Visible = Panel:GetAttribute("TerminalVisibility")
end)

SettingsContainer.ResizingEnabled.State.MouseButton1Up:Connect(function()
  HandleBoolSetting("ResizingEnabled")
end)

SettingsContainer.PlayerButtonNaming.State.MouseButton1Up:Connect(function()
  SettingsContainer.PlayerButtonNaming.ScrollingFrame.Visible = true
end)

SettingsContainer.PlayerButtonNaming.ScrollingFrame.DisplayUser.MouseButton1Up:Connect(function()
  ChangeDisplayInfo(0, SettingsContainer.PlayerButtonNaming.ScrollingFrame.DisplayUser.Text)
end)

SettingsContainer.PlayerButtonNaming.ScrollingFrame.IDUser.MouseButton1Up:Connect(function()
  ChangeDisplayInfo(1, SettingsContainer.PlayerButtonNaming.ScrollingFrame.IDUser.Text)
end)

SettingsContainer.PlayerButtonNaming.ScrollingFrame.User.MouseButton1Up:Connect(function()
  ChangeDisplayInfo(2, SettingsContainer.PlayerButtonNaming.ScrollingFrame.User.Text)
end)

for Name, PluginTable in pairs(PluginsName) do
  if Name == "VanillaCommands" then continue end
  if Panel.MainFrame.Commands:FindFirstChild(Name) then
    warn("[PANEL]: Category already exists. Continuing with other plugins.")
    continue
  end

  local Template = Panel.MainFrame.Commands.Template:Clone()
  Template.Name = Name
  Template.TextLabel.Text = PluginTable.Name or Name
  Template.Parent = Panel.MainFrame.Commands

  for P_Name, Plugin in pairs(PluginTable) do
    if P_Name == "Name" or P_Name == "Descriptions" or P_Name == "RequireExArguments" then continue end
    local ButtonTemplate = Template.ScrollingFrame.Template:Clone()
    ButtonTemplate.Name = Plugin
    ButtonTemplate.Text = Plugin
    ButtonTemplate.Parent = Template.ScrollingFrame
    ButtonTemplate.Visible = true
  end

  Template.ScrollingFrame.CanvasSize = UDim2.new(0, Template.ScrollingFrame.UIListLayout.AbsoluteContentSize.X,
    0, Template.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
  Template.Visible = true
end

for _, Button in pairs(GUI.MainFrame.Commands:GetDescendants()) do
  if not Button:IsA("TextButton") then continue end

  Button.MouseButton1Up:Connect(function()
    RunCommand(Button.Name)
  end)
end

Panel:SetAttribute("ResizingEnabled", true)
Panel:SetAttribute("OutputOnExecution", true)
RefreshPlayerList()
