local module = {}
local Panel = game.Players.LocalPlayer.PlayerGui:WaitForChild("PanelUI")
local Shared = require(Panel.Framework.Shared) -- Exposed functions for stuff such as arguments
local Watching = false

module.team = function()
  return Shared.GetArgument(game:GetService("Teams"):GetChildren(), "Team")
end

module.watch = function(Targets)
  if Watching then
    workspace.CurrentCamera.CameraSubject = Targets[1].Character.Humanoid
  else
    workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
  end

  Watching = not Watching
  return false
end

module.give = function()
  return Shared.GetArgument(game:GetService("ReplicatedStorage"):GetDescendants(), "Tool")
end

module.inventory = function(Targets)
  -- TODO
  return false
end

module.removetool = function(Targets)
  return Shared.GetArgument(Targets[1].Backpack:GetChildren())
end

setmetatable(module, {__index = function()
  return nil
end})

return module
