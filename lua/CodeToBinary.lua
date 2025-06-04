local M = {}

-- Convert text to binary
local function to_binary(str)
	local binary_str = ""
	for i = 1, #str do
		local byte = string.byte(str, i)
		local bin = ""
		for j = 7, 0, -1 do
			bin = bin .. ((bit32.extract(byte, j) == 1) and "1" or "0")
		end
		binary_str = binary_str .. bin .. " "
	end
	return binary_str
end

-- Command to overwrite the file with binary content
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

-- Command to display binary in a separate buffer
function M.show_binary()
	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local binary_content = {}

	for _, line in ipairs(lines) do
		table.insert(binary_content, to_binary(line))
	end

	-- Create a new buffer for binary display
	local new_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, binary_content)
	vim.api.nvim_set_current_buf(new_buf)
end

-- Register Commands
vim.api.nvim_create_user_command("BinaryWrite", M.write_binary, {})
vim.api.nvim_create_user_command("BinaryShow", M.show_binary, {})

return M
