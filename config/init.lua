require("full-border"):setup {
	type = ui.Border.ROUNDED,
}
require("git"):setup {
	order = 1500,
}
require("relative-motions"):setup {
	show_numbers = "relative",
	show_motion = true,
	enter_mode = "first",
}
require("yamb"):setup {
	cli = "fzf",
	jump_notify = true,
}
require("fg"):setup {
	default_action = "jump",
}
require("smart-enter"):setup {
	open_multi = true,
}

-- Disk free space indicator in status bar
local disk_free = ""
local function update_disk_free()
	local handle = io.popen("df -h . 2>/dev/null | awk 'NR==2 {print $4}'")
	if handle then
		local res = handle:read("*a")
		handle:close()
		if res then
			disk_free = res:gsub("%s+", "")
		end
	end
end
update_disk_free()

Status:children_add(function()
	if disk_free == "" then
		return ui.Span("")
	end
	return ui.Line({
		ui.Span(" "):fg("#a6adc8"),
		ui.Span("󰋊 " .. disk_free .. " free"):fg("#a6e3a1"),
		ui.Span(" "),
	})
end, 1500, Status.RIGHT)

-- Quick keybind cheatsheet in header
Header:children_add(function()
	return ui.Line({
		ui.Span("[o]"):fg("#89b4fa"):bold(), ui.Span("Open  "),
		ui.Span("[/]"):fg("#a6e3a1"):bold(), ui.Span("Filter  "),
		ui.Span("[fg]"):fg("#f9e2af"):bold(), ui.Span("Search  "),
		ui.Span("[,]"):fg("#cba6f7"):bold(), ui.Span("Sort  "),
		ui.Span("[y]"):fg("#fab387"):bold(), ui.Span("Copy  "),
		ui.Span("[F1]"):fg("#f38ba8"):bold(), ui.Span("Help"),
	})
end, 100, Header.RIGHT)

-- Per-folder sorting rules
-- e.g. Downloads by date (newest first), Home & others by alphabet
local folder_rules = {
	{ pattern = "Downloads", by = "mtime", reverse = true },
}

ps.sub("cd", function()
	update_disk_free()
	local cwd = cx.active and cx.active.current and tostring(cx.active.current.cwd)
	if not cwd then
		return
	end

	-- Keep zoxide database updated with navigated folders
	ya.async(function()
		Command("zoxide"):arg({ "add", cwd }):status()
	end)

	for _, rule in ipairs(folder_rules) do
		if cwd:find(rule.pattern) then
			ya.emit("sort", { rule.by, reverse = rule.reverse, dir_first = true })
			return
		end
	end

	-- Default fallback for other directories (alphabetical, directories first)
	ya.emit("sort", { "alphabetical", reverse = false, dir_first = true })
end)
