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
		binary_str = binary_str .. bin
	end
	return binary_str
end

-- Convert binary back to text
local function from_binary(binary_str)
	local text = ""
	for bin_line in binary_str:gmatch("[01%s]+") do -- Process each binary line separately
		local decoded_line = ""
		for bin in bin_line:gmatch("%S+") do -- Match each binary sequence (word)
			local byte = tonumber(bin, 2)
			if byte then
				decoded_line = decoded_line .. string.char(byte)
			end
		end
		text = text .. decoded_line .. "\n" -- Preserve new lines
	end
	return text
end

-- Detect if content is in binary format
local function is_binary(content)
	return content:match("[^01%s]") == nil -- Checks if only 0s and 1s exist
end

-- Toggle between text and binary
function M.binary_toggle()
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	if #lines == 0 then
		print("Buffer is empty, nothing to convert.")
		return
	end

	if is_binary(table.concat(lines, "\n")) then
		-- Convert binary to text
		local normal_text = {}
		for _, line in ipairs(lines) do
			table.insert(normal_text, from_binary(line))
		end
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, normal_text)
		print("Converted binary back to text!")
	else
		-- Convert text to binary
		local binary_content = {}
		for _, line in ipairs(lines) do
			table.insert(binary_content, to_binary(line))
		end
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, binary_content)
		print("Converted text to binary!")
	end
end

-- Show either text or binary based on file contents
function M.binary_show()
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	if #lines == 0 then
		print("Buffer is empty, nothing to show.")
		return
	end

	local content = table.concat(lines, "\n")
	local converted_output = {}

	if is_binary(content) then
		print("Displaying text version of binary!")
		for _, line in ipairs(lines) do
			table.insert(converted_output, from_binary(line))
		end
	else
		print("Displaying binary version of text!")
		for _, line in ipairs(lines) do
			table.insert(converted_output, to_binary(line))
		end
	end

	-- Open a split window
	vim.cmd("vsplit") -- Opens a vertical split
	local new_buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer
	vim.api.nvim_win_set_buf(0, new_buf) -- Set new buffer to split pane
	vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, converted_output)
end

-- Save binary output to a separate file
function M.binary_save()
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	if #lines == 0 then
		print("Buffer is empty, nothing to save.")
		return
	end

	local binary_content = {}
	for _, line in ipairs(lines) do
		table.insert(binary_content, to_binary(line))
	end

	local filename = vim.fn.expand("%:p") .. "_binary.txt" -- Ensure the filename is descriptive
	local file = io.open(filename, "w")
	if file then
		file:write(table.concat(binary_content, "\n"))
		file:close()
		print("Binary saved to " .. filename)
	else
		print("Error saving file!")
	end
end

-- Copy binary output to clipboard
function M.binary_copy()
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

	if #lines == 0 then
		print("Buffer is empty, nothing to copy.")
		return
	end

	local binary_content = {}
	for _, line in ipairs(lines) do
		table.insert(binary_content, to_binary(line))
	end

	local binary_text = table.concat(binary_content, "\n")
	vim.fn.setreg("+", binary_text) -- Copy to system clipboard
	print("Binary copied to clipboard!")
end

-- Register Commands
vim.api.nvim_create_user_command("BinaryToggle", M.binary_toggle, {})
vim.api.nvim_create_user_command("BinaryShow", M.binary_show, {})
vim.api.nvim_create_user_command("BinarySave", M.binary_save, {})
vim.api.nvim_create_user_command("BinaryCopy", M.binary_copy, {})

return M
