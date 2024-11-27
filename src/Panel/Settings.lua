local module = {}

module.Version = "4.0"

-- Accepts only IDs.
module.Administrators = {
  [game.CreatorId] = true,
}

module.Moderators = {
  [0] = true,
}

-- PAC settings
module.PAC = {
  ["EnablePAC"] = true,
  ["EnableNoclipCheck"] = false, -- May mess up with elevators.
  ["EnableFlyCheck"] = true -- May mess up with fly scripts.
}

-- Not implemented until further notice
module.AutoUpdate = {
  ["LocalCommands"] = true,
  ["VanillaCommands"] = true,
  ["Enabled"] = true
}

return module
