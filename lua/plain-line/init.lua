-- init.lua

local mode_get_name = function(mode)
    local map = {
        [ 'c' ]   = "COMMAND",
        [ 'i' ]   = "INSERT",
        [ 'n' ]   = "NORMAL",
        [ 'v' ]   = "VISUAL",
        [ 'V' ]   = "V-LINE",
        [ '\22' ] = "V-BLOCK",
    }

    local label = map[mode.mode]

    if not label then
        label = "UNKNOWN"
    end

    return label
end

local mode_get_highlight = function(active, mode)
    local map = {
        [ 'c' ]   = "PlainLineModeCommand",
        [ 'i' ]   = "PlainLineModeInsert",
        [ 'n' ]   = "PlainLineModeNormal",
        [ 'v' ]   = "PlainLineModeVisual",
        [ 'V' ]   = "PlainLineModeVisual",
        [ '\22' ] = "PlainLineModeVisual",
    }

    local highlight = map[mode.mode]

    if not active or not highlight then
        highlight = "PlainLineModeInactive"
    end

    return highlight
end

local mode_append = function(active, mode)
    local name = mode_get_name(mode)
    local highlight = mode_get_highlight(active, mode)

    vim.wo.statusline = "%#" .. highlight .. "# " .. name .. " "
end

local branch_get_highlight = function(active)
    local highlight = "PlainLineBranchActive"

    if not active then
        highlight = "PlainLineBranchInactive"
    end

    return highlight
end

local branch_append = function(active)
    local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\n'")
    local highlight = branch_get_highlight(active)

    if branch == "" then
        return
    end

    vim.wo.statusline = vim.wo.statusline .. "%#" .. highlight .. "# " .. branch .. " "
end

local file_name_get_highlight = function(active)
    local highlight = "PlainLineActive"

    if not active then
        highlight = "PlainLineInactive"
    end

    return highlight
end

local file_name_append = function(active)
    local highlight = file_name_get_highlight(active)

    vim.wo.statusline = vim.wo.statusline .. "%#" .. highlight .. "# " .. "%f %m %="
end

local file_pos_append = function(active)
    local highlight = branch_get_highlight(active)

    vim.wo.statusline = vim.wo.statusline .. "%#" .. highlight .. "# " .. "Ln %l, Col %c "
end

local file_type_append = function(active, mode)
    local highlight = mode_get_highlight(active, mode)

    vim.wo.statusline = vim.wo.statusline .. "%#" .. highlight .. "# " .. "%{&filetype}" .. " "
end

local callback_enter = function(e)
    local mode = vim.api.nvim_get_mode()

    mode_append(true, mode)
    branch_append(true)

    file_name_append(true)
    file_pos_append(true)
    file_type_append(true, mode)
end

local callback_leave = function(e)
    local mode = vim.api.nvim_get_mode()

    mode_append(false, mode)
    branch_append(false)

    file_name_append(false)
    file_pos_append(false)
    file_type_append(false, mode)
end

local M = {}

M.execute = function()
    local enter  = {
        events   = { "BufEnter", "WinEnter", "ModeChanged" },
        callback = { callback = callback_enter },
    }

    local leave  = {
        events   = { "BufLeave", "WinLeave" },
        callback = { callback = callback_leave },
    }

    vim.api.nvim_create_autocmd(enter.events, enter.callback)
    vim.api.nvim_create_autocmd(leave.events, leave.callback)
end

return M
