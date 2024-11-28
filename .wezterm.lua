local wezterm = require 'wezterm';
local a = wezterm.action;

local c = wezterm.config_builder()
c.default_prog = {"C:/Program Files/PowerShell/7/pwsh.exe", "-NoLogo"}
c.color_scheme = 'Kanagawa (Gogh)'
c.use_fancy_tab_bar = false
c.tab_bar_at_bottom = true
c.leader = { key = "q", mods = "ALT" }
c.launch_menu = {
	{
		label = "PowerShell",
		args = {"C:/Program Files/PowerShell/7/pwsh.exe", "-NoLogo"},
	},
	{
		label = "Edge",
		args = {"start", "Program Files (x86)/Microsoft/Edge/Application/msedge.exe"},
	},
	{
		label = "Neovim",
		args = {"nvim"},
	}
}

c.keys = {
	{
		key = "m",
		mods = "LEADER",
		action = a.ShowLauncher,
	},
	{
		key = 'n',
		mods = 'LEADER',
		action = a.SwitchToWorkspace,
	},
  -- Switch to a monitoring workspace, which will have `top` launched into it
	{
		key = 'v',
		mods = 'LEADER',
		action = a.SwitchToWorkspace { name = 'Neovim', spawn = { args = { 'nvim' } } },
	},
	{
		key = 'w',
		mods = 'LEADER',
		action = a.PromptInputLine {
		description = wezterm.format {
			{ Attribute = { Intensity = 'Bold' } },
			{ Foreground = { AnsiColor = 'Fuchsia' } },
			{ Text = 'Enter name for new workspace: ' },
		},
		action = wezterm.action_callback(function(window, pane, line)
			-- line will be `nil` if they hit escape without entering anything
			-- An empty string if they just hit enter
			-- Or the actual line of text they wrote
			if line then
			window:perform_action(
				a.SwitchToWorkspace {
				name = line,
				},
				pane
			)
			end
		end),
		},
	},
	{
		key = 'h',
		mods = 'LEADER',
		action = a.ActivatePaneDirection "Left" ,
	},
	{
		key = 'j',
		mods = 'LEADER',
		action = a.ActivatePaneDirection "Down" ,
	},
	{
		key = 'k',
		mods = 'LEADER',
		action = a.ActivatePaneDirection "Up" ,
	},
	{
		key = 'l',
		mods = 'LEADER',
		action = a.ActivatePaneDirection "Right" ,
	},
	{
		key = 'z',
		mods = 'LEADER',
		action = a.TogglePaneZoomState,
	},
	{
		key = '[',
		mods = 'LEADER',
		action = a.ActivateTabRelative(-1),
	},
	{
		key = ']',
		mods = 'LEADER',
		action = a.ActivateTabRelative(1),
	},
	{
		key = 'p',
		mods = 'LEADER',
		action = a.SplitHorizontal { domain = "CurrentPaneDomain" },
	},
	{
		key = 'P',
		mods = 'LEADER',
		action = a.SplitVertical { domain = "CurrentPaneDomain" },
	},
	{
		key = 's',
		mods = 'LEADER',
		action = a.PaneSelect
	},
	{
		key = 'q',
		mods = 'LEADER',
		action = a.CloseCurrentPane { confirm = true }
	},
	{
		key = 'd',
		mods = 'LEADER',
		action = a.ShowDebugOverlay,
	},
	{
    key = 'r',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      -- Here you can dynamically construct a longer list if needed

      local home = wezterm.home_dir
      local windows = wezterm.mux.all_windows()
	  local workspaces = {}
	  for _, w in ipairs(windows) do
		if w.is_dead then
		  table.insert(workspaces, { id = w:get_title(), label = w:get_workspace(), is_dead = true })
		else
		  table.insert(workspaces, { id = w:get_title(), label = w:get_workspace() })
		end
	  end
		wezterm.log_info('workspaces = ' .. #workspaces)

      window:perform_action(
        a.InputSelector {
          action = wezterm.action_callback(
            function(inner_window, inner_pane, id, label)
              if not id and not label then
                wezterm.log_info 'cancelled'
              else
                wezterm.log_info('id = ' .. id)
                wezterm.log_info('label = ' .. label)
                inner_window:perform_action(
                  a.SwitchToWorkspace {
                    name = label,
                    spawn = {
                      label = 'Workspace: ' .. label,
                      cwd = id,
                    },
                  },
                  inner_pane
                )
              end
            end
          ),
          title = 'Choose Workspace',
          choices = workspaces,
          fuzzy = true,
          fuzzy_description = 'Fuzzy find and/or make a workspace',
        },
        pane
      )
    end),
  },
}
return c
