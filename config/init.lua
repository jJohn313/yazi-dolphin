require("session"):setup {
	sync_yanked = true,
}
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
require("easyjump"):setup {
	icon_fg = "#94e2d5",
	first_key_fg = "#fab387",
}

-- Non-blocking disk free space indicator in status bar
local disk_free = ""
local update_disk_free = ya.async(function()
	local output = Command("df"):arg({ "-h", "." }):stdout(Command.PIPED):output()
	if output and output.stdout then
		local line2 = output.stdout:match("\n([^\n]+)")
		if line2 then
			local free = line2:match("%S+%s+%S+%s+%S+%s+(%S+)")
			if free then
				disk_free = free
				ya.render()
			end
		end
	end
end)
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

-- =============================================================================
-- Dynamic Context Island (MIME/Extension-Aware Action Badge)
-- =============================================================================

local function get_file_ext(filename)
	return filename:match("%.([^./]+)$") and filename:match("%.([^./]+)$"):lower() or ""
end

Header:children_add(function()
	local active = cx.active
	local hovered = active and active.current and active.current.hovered

	-- Base spans for the capsule container
	local spans = {
		ui.Span(" "):fg("#1A1A1A"),
	}

	local function add_action(key, label, key_col, lbl_col)
		table.insert(spans, ui.Span("[" .. key .. "]"):fg(key_col or "#C1B48E"):bg("#1A1A1A"):bold())
		table.insert(spans, ui.Span(" " .. label .. " "):fg(lbl_col or "#CE7688"):bg("#1A1A1A"))
	end

	local function add_sep()
		table.insert(spans, ui.Span("│ "):fg("#3A3A3A"):bg("#1A1A1A"))
	end

	-- Check clipboard/yank state to dynamically highlight Paste
	local yanked = (active and active.yanked) and #active.yanked or 0
	if yanked > 0 then
		local is_cut = active.is_cut
		local verb = is_cut and "Move " or "Paste "
		add_action("p", verb .. "(" .. yanked .. ")", "#000000", "#FFDCB9")
		add_sep()
	end

	if not hovered then
		add_action("o", "Open", "#C1B48E", "#A05969")
		table.insert(spans, ui.Span(" "):fg("#1A1A1A"))
		return ui.Line(spans)
	end

	local is_dir = hovered.cha and hovered.cha.is_dir
	local ext = get_file_ext(hovered.name)

	-- 1. Context-specific actions based on file type
	if is_dir then
		add_action("l", "Enter")
		add_action("mv", "SendTo")
		add_action("C", "Compress")
	elseif ext:match("^(zip|tar|gz|bz2|xz|7z|rar|zst)$") then
		add_action("o", "Unpack Menu", "#FFDCB9", "#CE7688")
		add_action("l", "Peek Inside")
		add_action("mv", "SendTo")
	elseif ext:match("^(png|jpg|jpeg|webp|gif|svg|avif)$") then
		add_action("l", "View (imv)")
		add_action("^d", "Drag")
		add_action("T", "Max Preview")
	elseif ext:match("^(mp4|mkv|webm|avi|mov|mp3|flac|wav|opus)$") then
		add_action("l", "Play (mpv)")
		add_action("^d", "Drag")
		add_action("T", "Max Preview")
	elseif ext:match("^(md|markdown|txt|org)$") then
		add_action("l", "Glow/Edit")
		add_action("o", "Menu")
		add_action("df", "Diff")
	elseif ext:match("^(lua|py|rs|go|c|cpp|sh|toml|json|yaml|yml)$") then
		add_action("l", "Edit (micro)")
		add_action("o", "Menu")
		add_action("df", "Diff")
	elseif ext == "pdf" then
		add_action("l", "Open PDF")
		add_action("o", "Menu")
	else
		add_action("o", "Open With")
		add_action("l", "Open")
	end

	add_sep()

	-- 2. General file manipulation verbs (applicable anywhere)
	add_action("y", "Yank", "#A49978", "#804654")
	add_action("x", "Cut", "#930006", "#804654")
	add_action("c,m", "Chmod", "#A49978", "#804654")

	table.insert(spans, ui.Span(" "):fg("#1A1A1A"))
	return ui.Line(spans)
end, 100, Header.RIGHT)

-- Publish hover state for optional desktop HUD/bar integrations
ps.sub("hover", function()
	local h = cx.active and cx.active.current and cx.active.current.hovered
	if h then
		local name_clean = (h.name or ""):gsub('"', '\\"')
		local is_dir = (h.cha and h.cha.is_dir) and true or false
		local payload = string.format('{"name":"%s","is_dir":%s}', name_clean, tostring(is_dir))
		os.execute("echo '" .. payload .. "' > /tmp/yazi-hover.sock 2>/dev/null &")
	end
end)

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
