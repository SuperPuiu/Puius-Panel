local module = {}

-- Accepts only IDs.
module.Administrators = {
  [game.CreatorId] = true,
}

module.Moderators = {
  [0] = true,
}

return module
