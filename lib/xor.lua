local xor = {}
xor.__index = xor

function xor.new(key, block_size)
    local instance = setmetatable({
        key = key,
        block_size = block_size or 4096
    }, xor)
    return instance
end

function xor:process_(input)
    local output = {}
    local key_len = #self.key
    local key_index = 1

    for i = 1, #input do
        local xor_byte = bit.bxor(string.byte(input, i), string.byte(self.key, key_index))
        table.insert(output, string.char(xor_byte))
        key_index = (key_index % key_len) + 1
    end

    return table.concat(output)
end

function xor:process_block(input)
    local output = {}
    local key_len = #self.key
    local key_index = 1
    local input_len = #input

    for i = 1, input_len, self.block_size do
        local block_end = math.min(i + self.block_size - 1, input_len)
        local block = { string.byte(input, i, block_end) }

        for j = 1, #block do
            local xor_byte = bit.bxor(block[j], string.byte(self.key, key_index))
            table.insert(output, string.char(xor_byte))
            key_index = (key_index % key_len) + 1
        end
    end

    return table.concat(output)
end

function xor:encode(input)
    return self:process_block(input)
end

function xor:decode(input)
    return self:process_block(input)
end

return xor
