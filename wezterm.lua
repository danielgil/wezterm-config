-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

config.color_scheme = "AdventureTime"
config.font = wezterm.font("JetBrains Mono")
config.font_size = 16

local w = require("wezterm")
local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = w.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

config.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- splitting
	{
		mods = "LEADER",
		key = "s",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "d",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "m",
		action = wezterm.action.TogglePaneZoomState,
	},
	-- rotate panes
	{
		mods = "LEADER",
		key = "Space",
		action = wezterm.action.RotatePanes("Clockwise"),
	},
	-- show the pane selection mode, but have it swap the active and selected panes
	{
		mods = "LEADER",
		key = "0",
		action = wezterm.action.PaneSelect({
			mode = "SwapWithActive",
		}),
	},
	-- move between split panes
	split_nav("move", "h"),
	split_nav("move", "j"),
	split_nav("move", "k"),
	split_nav("move", "l"),
	-- resize panes
	split_nav("resize", "h"),
	split_nav("resize", "j"),
	split_nav("resize", "k"),
	split_nav("resize", "l"),
	-- activate copy mode or vim mode
	{
		key = "Enter",
		mods = "LEADER",
		action = wezterm.action.ActivateCopyMode,
	},
	{
		key = "f",
		mods = "CTRL",
		action = wezterm.action.SendKey({
			key = "f",
			mods = "ALT",
		}),
	},
	{
		key = "b",
		mods = "CTRL",
		action = wezterm.action.SendKey({
			key = "b",
			mods = "ALT",
		}),
	},
	{ key = "g", mods = "LEADER", action = wezterm.action.QuickSelect },
	{ key = "u", mods = "CTRL", action = wezterm.action.ScrollByPage(-0.5) },
	{ key = "d", mods = "CTRL", action = wezterm.action.ScrollByPage(0.5) },
}

config.quick_select_patterns = {
	-- match eks node names
	"(?:fargate-)?ip(?:-(?:[0-9]){1,3}){4}.ec2.internal",
	-- match kubernetes pod names
	"\\w+(?:-\\w+)+",
}

return config
