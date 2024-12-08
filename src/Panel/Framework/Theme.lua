local Theme = {}
--[[
-- This module allows you to overwrite existing panel look. It is recommended to use this module for changing the panel's look.
-- TODO: Implement theme requirements. 
--]]

Theme.WindowPopup = TweenInfo.new(
  0.25,
  Enum.EasingStyle.Back,
  Enum.EasingDirection.Out,
  0,
  false,
  0
)

Theme.WindowClose = TweenInfo.new(
  0.25,
  Enum.EasingStyle.Back,
  Enum.EasingDirection.In,
  0,
  false,
  0
)

return Theme
