local module = {}

module.Version = "4.0"

-- Accepts only IDs.
module.Administrators = {
  [game.CreatorId] = true,
}

module.Moderators = {
  [0] = true,
}

module.AutoUpdate = {
  ["LocalCommands"] = true,
  ["VanillaCommands"] = true,
}

return module
