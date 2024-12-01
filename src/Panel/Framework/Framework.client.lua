local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local GUI = script.Parent.Parent
local Server = game:GetService("ReplicatedStorage"):WaitForChild("PanelRemote")
local LocalCommands = require(script.Parent.Client.VanillaCommands)

local Panel = script.Parent.Parent
local SettingsContainer = Panel.Settings.ScrollingFrame
local PlayerList = Panel.MainFrame.PlayerFrame
local Terminal = Panel.MainFrame.Terminal

local CTRL_Down = false -- Used for multi selection
local PlayersSelected = {}
local PluginsName = Server:InvokeServer({Type = "RequestPlugins"}) -- {PluginName = {Name = Name}}
local DisplayInformation = 0 -- 0 = Display and name, 1 = Name and UserId, 2 = User only

--[[
-- CompleteName(Location, Name) accepts Location table and Name string as arguments. The function compares strlen(Name) characters of
-- every Location element with Name in an attempt to find the string which is asked for. Always returns a table.
--]]
local function CompleteName(Location, Name)
  local ForReturn = {}

  local len = string.len(Name)

  for Key, Value in pairs(Location) do
    local ForComparison = Key

    if not tostring(ForComparison) then ForComparison = Value end

    local sub = string.sub(ForComparison, 1, len)

    if sub == Name then
      table.insert(ForReturn)
    end
  end

  return ForReturn
end

--[[
-- HandleBoolSetting(Name) accepts Name string as an argument and aims to centralize Bool related settings. Name **must** exist 
-- within SettingsContainer, else it will throw an error.
--]]
local function HandleBoolSetting(Name)
  if Panel:GetAttribute(Name) then
    SettingsContainer[Name].State.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
  else
    SettingsContainer[Name].State.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
  end

  Panel:SetAttribute(Name, not Panel:GetAttribute(Name))
end

--[[
-- RefreshPlayerList() can be called freely whenever the `PlayerList` ScrollingFrame has to be updated. Normally it's called
-- whenever a new player joins or a command is fired, after PlayersSelected table is cleared.
--]]
local function RefreshPlayerList()
  local Order = 0
  --[[
  -- CreatePlayerButton(Player) accepts a Player instance as argument and based on it and based on the provided settings it creates
  -- a new button or updates an existing button within PlayerList ScrollingFrame. Order variable has to be manually updated.
  --]]
  local function CreatePlayerButton(Player)
    local Template = Panel.MainFrame.PlayerFrame:FindFirstChild(Player.Name)

    if not Template then
      -- If there isn't any existing button, simply create a new one with the template found within PlayerList and update its elements.
      Template = PlayerList.TextButton:Clone()
      Template.Headshot.Image = game:GetService("Players"):GetUserThumbnailAsync(Player.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size60x60)

      Player.Destroying:Connect(function()
        Template:Destroy()
      end)

      Template.MouseButton1Up:Connect(function()
        -- Holding down CTRL allows you to select multiple players at once. This aims to allow you do so.
        if CTRL_Down then
          if not table.find(PlayersSelected, Player) then
            table.insert(PlayersSelected, Player)
          else
            for i, v in pairs(PlayersSelected) do
              if v == Player then table.remove(PlayersSelected, i) end
            end
          end
        else
          PlayersSelected = {Player}
        end
      end)
    end

    Template.Parent = PlayerList
    Template.Name = Player.Name
    Template.LayoutOrder = Order -- Order is modified outside the function.

    -- As stated above, DisplayInformation can be one of the 3 values: 1 (DisplayName and Name), 2 (Name and UserId) and 3 (Name)
    if DisplayInformation == 0 then
      Template.TextLabel.Text = string.format("%s\n<font color='#5a8a29'>(%s)</font>", Player.DisplayName, Player.Name)
    elseif DisplayInformation == 1 then
      Template.TextLabel.Text = string.format("%s\n<font color='#5a8a29'>(%i)</font>", Player.Name, Player.UserId)
    elseif DisplayInformation == 2 then
      Template.TextLabel.Text = Player.Name
    end
    Template.Visible = true
  end

  -- Considering that there may be players which aren't in a team, they should appear on top of other teams.
  for _, Player in pairs(Players:GetPlayers()) do
    if Player.Team == nil then
      Order = Order + 1
      CreatePlayerButton(Player)
    end
  end

  -- The following loop aims to create (or update, somehow) existing Team TextLabels and add Players under their respective team.
  for _, Team in pairs(game:GetService("Teams"):GetTeams()) do
    Order = Order + 1
    local TeamTemplate = Panel.MainFrame.PlayerFrame:FindFirstChild(Team.Name)

    if not TeamTemplate then
      TeamTemplate = Panel.MainFrame.PlayerFrame.TextLabel:Clone()
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

  -- In the end, update the PlayerList CanvasSize based on information given by the UIListLayout
  PlayerList.CanvasSize = UDim2.new(0, PlayerList.UIListLayout.AbsoluteContentSize.X,
    0, PlayerList.UIListLayout.AbsoluteContentSize.Y)
end

--[[
-- RunCommand(Command, Arguments) accepts Command string and Arguments table, and it is the function which handles preparing
-- and invoking the RemoteFunction to execute the command (or in some cases, run the command only locally).
--]]
local function RunCommand(Command, Arguments)
  Command = string.lower(Command)
  if not Arguments and LocalCommands[Command] then Arguments = LocalCommands[Command](PlayersSelected) end
  if Arguments == false then return end -- Hacky way to stop the panel from continuing to run a command. Useful for local commands.

  print(Server:InvokeServer({Command = Command, Targets = PlayersSelected, Arguments = Arguments}))
  PlayersSelected = {}
  RefreshPlayerList()
end

--[[
-- ChangeDisplayInfo(Number, Str) accepts Number number and Str string as arguments, and based on it modifies DisplayInformation
-- and SettingsContainer.PlayerButtonNaming ScrollingFrame.
--]]
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
  elseif Input.KeyCode == Enum.KeyCode.Tab and Terminal.CommandLine.TextBox:IsFocused() then
    --[[
    -- Allow tab completion for commands / player names. This means that you can press TAB and the script will auto complete the
    -- command / player name for you. Arguments aren't supported due to obvious reasons.
    --]]
    local Data = Terminal.CommandLine.TextBox.Text:split(" ")

    if #Data == 1 then
      -- Completion for command name
      local Command
      for _, PluginTable in pairs(PluginsName) do

      end
      local Completion = CompleteName()
    elseif #Data == 2 then
      -- Completion for Player name
    end
  end
end)

UIS.InputEnded:Connect(function(Input)
  if Input.KeyCode == Enum.KeyCode.LeftControl then
    CTRL_Down = false
  end
end)

-- This loop here wastes resources and the functionality should be reimplemented -@SuperPuiu
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

Terminal.CommandLine.TextBox.FocusLost:Connect(function()
  local Text = Terminal.CommandLine.TextBox.Text

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
    -- Ignore plugin metadata
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

  Panel.MainFrame.Commands.CanvasSize = UDim2.new(0, Panel.MainFrame.Commands.UIListLayout.AbsoluteContentSize.X,
    0, Panel.MainFrame.Commands.UIListLayout.AbsoluteContentSize.Y)
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
