local injector = {}

local ffi = require("ffi")
local module = ffi.load(getWorkingDirectory().. "\\lib\\injector.dll")
ffi.cdef[[
    typedef unsigned char BYTE;
    typedef unsigned long  SIZE_T;

    bool inject(BYTE* p_src_data, SIZE_T file_size);
]]

function injector:inject(cbytes)
    module.inject(cbytes, ffi.sizeof(cbytes))
end

function injector:string_to_bytes(str)
    local bytes = {}
    for i = 1, #str do
        bytes[i] = str:byte(i)
    end
    return bytes
end

function injector:string_to_cbytes(str)
    local cbytes = ffi.new("uint8_t[?]", #str)
    for i = 0, #str - 1 do
        cbytes[i] = string.byte(str, i + 1)
    end
    return cbytes
end

function injector:lua_bytes_to_cbytes(bytes_tbl)
    local cbytes = ffi.new("uint8_t[?]", #bytes)
    for i = 1, #bytes_tbl do
        cbytes[i-1] = bytes_tbl[i]
    end
    return cbytes
end

function injector:bytes_to_string(bytes)
    local str = ""
    for i = 1, #bytes do
        str = str .. string.char(bytes[i])
    end
    return str
end

function injector:read_binary_file(path)
    local f = io.open(path, "rb")
    if not f then
        error("Unable to open file: " .. path)
    end
    local bytes_str = f:read("*a")
    f:close()
    return self:string_to_cbytes(bytes_str)
end

return injector
