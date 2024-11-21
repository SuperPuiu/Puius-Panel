return function(AutoUpdate, Existing)
  if Existing:GetAttribute("Updated") then return end
  if not Existing or not AutoUpdate then error("You must call auto updater with both parameters.") end

  local Panel = script:WaitForChild("Panel")
  local OldPlugins = Existing:FindFirstChild("Plugins")
  if not OldPlugins then warn("Couldn't find Plugins folder.") return end

  if not AutoUpdate.Enabled then return end
  Panel:SetAttribute("Updated", true)

  if not AutoUpdate.VanillaCommands then
    local VanillaCommands = OldPlugins.Server.VanillaCommands
    Panel.Plugins.Server.VanillaCommands:Destroy()
    VanillaCommands.Parent = Panel.Plugins.Server
  end

  if not AutoUpdate.LocalCommands then
    local LocalCommands = Existing.Framework.LocalCommands
    Panel.Framework.LocalCommands:Destroy()
    LocalCommands.Parent = Panel.Framework
  end

  Existing:Destroy()
  Panel.Parent = game:GetService("ServerScriptService")
end
