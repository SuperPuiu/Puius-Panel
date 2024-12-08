local module = {}

module.Version = "4.0"

-- Accepts only IDs.
module.Administrators = {
  [game.CreatorId] = true,
}

module.Moderators = {
  [0] = true,
}

module.Panel = {
  ["AlwaysOnTop"] = true, -- Set DisplayOrder +1 from the highest DisplayOrder StarterGui
  ["TerminalAlwaysOnTop"] = true,
}

-- Not implemented until further notice
module.AutoUpdate = {
  ["LocalCommands"] = true,
  ["VanillaCommands"] = true,
  ["Enabled"] = true
}

return module
