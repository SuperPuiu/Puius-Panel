local Players = game:GetService("Players")
-- local Player = Players.LocalPlayer
local GUI = script.Parent.Parent
local Server = game:GetService("ReplicatedStorage"):WaitForChild("PanelRemote")
local LocalCommands = require(script.Parent.LocalCommands)

local UIS = game:GetService("UserInputService")
local Panel = script.Parent.Parent

local CTRL_Down = false
local PlayersSelected = {}
local DisplayInformation = 0 -- 0 = Display and name, 1 = Name and UserId, 2 = User only

local function RunCommand(Command, Arguments)
  Command = string.lower(Command)
  if not Arguments and LocalCommands[Command] then Arguments = LocalCommands[Command](PlayersSelected) end

  print(Server:InvokeServer({Command = Command, Targets = PlayersSelected, Arguments = Arguments}))
end

local function RefreshPlayerList()
  local Order = 0

  local function CreatePlayerButton(v)
    local Template
    if Panel.MainFrame.PlayerFrame:FindFirstChild(v.Name) then
      Template = Panel.MainFrame.PlayerFrame[v.Name]
    else
      Template = Panel.MainFrame.PlayerFrame.TextButton:Clone()
      Template.Headshot.Image = game:GetService("Players"):GetUserThumbnailAsync(v.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60)
    end

    Template.Parent = Panel.MainFrame.PlayerFrame
    Template.Name = v.Name
    Template.LayoutOrder = Order

    if DisplayInformation == 0 then
      Template.TextLabel.Text = string.format("%s\n<font color='#5a8a29'>(%s)</font>", v.DisplayName, v.Name)
    elseif DisplayInformation == 1 then
      Template.TextLabel.Text = string.format("%s\n<font color='#5a8a29'>(%i)</font>", v.Name, v.UserId)
    elseif DisplayInformation == 2 then
      Template.TextLabel.Text = v.Name
    end

    v.Destroying:Connect(function()
      Template:Destroy()
    end)

    Template.MouseButton1Up:Connect(function()
      if CTRL_Down then
        if not table.find(PlayersSelected, v) then table.insert(PlayersSelected, v) end
      else
        PlayersSelected = {v}
      end
    end)

    Template.Visible = true
    Order = Order + 1
  end

  for _, v in pairs(Players:GetPlayers()) do
    if v.Team == nil then
      CreatePlayerButton(v)
    end
  end

  for _, Team in pairs(game:GetService("Teams"):GetTeams()) do
    Order = Order + 1
    local TeamTemplate = Panel.MainFrame.PlayerFrame.TextLabel:Clone()
    TeamTemplate.Text = Team.Name
    TeamTemplate.Name = Team.Name
    TeamTemplate.Parent = Panel.MainFrame.PlayerFrame
    TeamTemplate.BackgroundColor3 = Team.TeamColor.Color
    TeamTemplate.Visible = true

    for _, v in pairs(Team:GetPlayers()) do
      CreatePlayerButton(v)
    end
  end
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

game:GetService("RunService").RenderStepped:Connect(function()
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

for _, Button in pairs(GUI.MainFrame.Commands:GetDescendants()) do
  if not Button:IsA("TextButton") then continue end

  Button.MouseButton1Up:Connect(function()
    RunCommand(Button.Name)
  end)
end

RefreshPlayerList()
