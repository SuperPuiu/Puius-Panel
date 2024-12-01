local module = {}

local Panel = game.Players.LocalPlayer.PlayerGui:WaitForChild("PanelUI")
local ArgumentsFrame = Panel.MainFrame.Arguments

module.GetArgumentsEx = function(...)
  -- TODO
  local TypesNeeded = {...}
end

module.GetArgument = function(Folder, AllowedType)
  local i = 0
  local Argument

  for _, Button in pairs(ArgumentsFrame:GetChildren()) do
    if Button.Name == "TextButton" or Button:IsA("UIListLayout") then continue end

    Button:Destroy()
  end

  for _, v in pairs(Folder) do
    if not v:IsA(AllowedType) then continue end
    i = i + 1

    local ArgButton = ArgumentsFrame.TextButton:Clone()
    ArgButton.Parent = ArgumentsFrame
    ArgButton.Text = v.Name
    ArgButton.Name = v.Name
    ArgButton.Visible = true

    ArgButton.MouseButton1Up:Connect(function()
      ArgumentsFrame.Visible = false
      Argument = {v.Name}
    end)
  end

  if i == 0 then return end
  ArgumentsFrame.Visible = true

  ArgumentsFrame.CanvasSize = UDim2.new(0, ArgumentsFrame.UIListLayout.AbsoluteContentSize.X,
    0, ArgumentsFrame.UIListLayout.AbsoluteContentSize.Y)
  repeat task.wait() until ArgumentsFrame.Visible == false or Argument

  return Argument
end

return module
