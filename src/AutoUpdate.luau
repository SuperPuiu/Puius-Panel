local InsertService = game:GetService("InsertService")

return function(AutoUpdate, Existing)
  if not AutoUpdate.Enabled then return end
  local AssetVersion = InsertService:GetLatestAssetVersionAsync(6460917354)

  if Existing:GetAttribute("ModelVersion", AssetVersion) then return end
  if not Existing or not AutoUpdate then error("You must call auto updater with both parameters.") end

  local Panel = InsertService:LoadAssetVersion(AssetVersion)
  local OldPlugins = Existing:FindFirstChild("Plugins")
  if not OldPlugins then warn("Couldn't find Plugins folder.") return end

  Panel:SetAttribute("ModelVersion", AssetVersion)

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
