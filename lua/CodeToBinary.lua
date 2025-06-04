local bit = require("bit") -- LuaJIT bitwise operations

local M = {}

-- Convert text to binary
local function to_binary(str)
	local binary_str = ""
	for i = 1, #str do
		local byte = string.byte(str, i)
		local bin = ""
		for j = 7, 0, -1 do
			bin = bin .. tostring(bit.band(bit.rshift(byte, j), 1))
		end
		binary_str = binary_str .. bin .. " "
	end
	return binary_str
end

-- Convert binary back to text
local function from_binary(binary_str)
	local text = ""
	for bin in binary_str:gmatch("%S+") do -- Match each binary sequence
		local byte = tonumber(bin, 2) -- Convert binary to decimal
		if byte then
			text = text .. string.char(byte) -- Convert decimal to character
		end
	end
	return text
end

-- Command to write binary into the current file (with confirmation)
function M.write_binary()
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local binary_content = ""

	for _, line in ipairs(lines) do
		binary_content = binary_content .. to_binary(line) .. "\n"
	end

	-- Confirmation before overwriting
	local choice = vim.fn.confirm("Write file as binary? This will wipe all content!", "&Yes\n&No", 2)
	if choice == 1 then
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(binary_content, "\n"))
		print("File converted to binary!")
	else
		print("Operation canceled.")
	end
end

-- Command to display binary in a **split pane**
function M.show_binary()
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local binary_content = {}

	for _, line in ipairs(lines) do
		table.insert(binary_content, to_binary(line))
	end

	-- Open a split without switching focus
	vim.cmd("vsplit") -- Opens vertical split
	local new_buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer
	vim.api.nvim_win_set_buf(0, new_buf) -- Set new buffer to split pane
	vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, binary_content)

	print("Binary view opened in a split pane!")
end
-- Command to convert binary back to normal text
function M.convert_binary_to_text()
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local normal_text = ""

	for _, line in ipairs(lines) do
		normal_text = normal_text .. from_binary(line) .. "\n"
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(normal_text, "\n"))
	print("Converted binary back to text!")
end

-- Register Commands
vim.api.nvim_create_user_command("BinaryWrite", M.write_binary, {})
vim.api.nvim_create_user_command("BinaryShow", M.show_binary, {})
vim.api.nvim_create_user_command("BinaryToText", M.convert_binary_to_text, {})

return M
