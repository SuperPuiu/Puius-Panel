--[[
-- The objective of pushing the terminal's code into its own script is so it can run without being tied to the "graphical" part of the
-- panel. This means that you can use the terminal without having the actual "panel part" and vice versa. Hope it made sense.
-- Shared module is _still_ required. It wouldn't make sense to maintain some functions which are found both within the graphical and 
-- not graphical parts of the panel.
--]]

local UIS = game:GetService("UserInputService")
local Shared = require(script.Parent.Shared)
local Panel = script.Parent.Parent
local Terminal = Panel.Terminal.Interface
local PluginsName = Shared.GetPluginsName()

--[[
-- CompleteName(Location, Name) accepts Location table and Name string as arguments. The function compares strlen(Name) characters of
-- every Location element with Name in an attempt to find the string which is asked for. Always returns a table.
--]]
local function CompleteName(Location, Name)
  local ForReturn = {}

  local len = string.len(Name)
  Name = string.lower(Name)

  for Key, Value in pairs(Location) do
    local ForComparison = Key

    if type(ForComparison) == "number" then ForComparison = Value end
    if typeof(ForComparison) == "Instance" then ForComparison = ForComparison.Name end

    local sub = string.lower(string.sub(ForComparison, 1, len))

    if sub == Name then
      table.insert(ForReturn, ForComparison)
    end
  end

  return ForReturn
end

UIS.InputBegan:Connect(function(Input)
  if Input.KeyCode == Enum.KeyCode.Tab and Terminal.CommandLine.TextBox:IsFocused() then
    --[[
    -- Allow tab completion for commands / player names. This means that you can press TAB and the script will auto complete the
    -- command / player name for you. Arguments aren't supported due to obvious reasons.
    --]]
    local Data = Terminal.CommandLine.TextBox.Text:split(" ")

    if #Data == 1 then
      -- Completion for command name
      local Command = {}
      for _, PluginTable in pairs(PluginsName) do
        for _, Name in pairs(CompleteName(PluginTable, Data[1])) do
          table.insert(Command, Name)
        end
      end

      if Command[1] == nil then Panel.Assets.Quack:Play() return end

      game:GetService("RunService").RenderStepped:Wait()
      Terminal.CommandLine.TextBox.Text = Command[1]
      Terminal.CommandLine.TextBox.CursorPosition = string.len(Command[1]) + 1
      -- local Completion = CompleteName()
    elseif #Data == 2 then
      -- Completion for Player name
      local PlayersFound = CompleteName(game.Players:GetPlayers(), string.sub(Data[2], 1, string.len(Data[2])))
      if PlayersFound[1] == nil then Panel.Assets.Quack:Play() return end

      game:GetService("RunService").RenderStepped:Wait()
      Terminal.CommandLine.TextBox.Text = Data[1].." "..PlayersFound[1]
      Terminal.CommandLine.TextBox.CursorPosition = string.len(Terminal.CommandLine.TextBox.Text) + 1
    end

  elseif Input.KeyCode == Enum.KeyCode.Up then

  elseif Input.KeyCode == Enum.KeyCode.Down then

  end
end)

Terminal.CommandLine.TextBox.FocusLost:Connect(function()
  local Text = Terminal.CommandLine.TextBox.Text
  if #string.gsub(Text, "[%s]", "") == 0 then return end -- Empty string 

  local Data = Text:split(" ")
  local Label = Terminal.Template:Clone()
  Label.Name = "OldCommand"
  Label.TextBox.Text = Text
  Label.TextLabel.Text = Terminal.CommandLine.TextLabel.Text
  Label.Parent = Terminal
  Label.Visible = true

  Terminal.CommandLine.TextBox.Text = ""

  if not Data[2] then return end
  Shared.RunCommand(Data[1], {game.Players:FindFirstChild(Data[2])}, {Data[3]})
end)
