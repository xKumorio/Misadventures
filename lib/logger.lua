local logger = {}

function logger:create(name, fpath)
    local instance = {
        name = name,
        fpath = fpath,
        file = io.open(fpath, "a")
    }
    setmetatable(instance, { __index = logger })
    return instance
end

function logger:log(...)
    local string = ""
    for i, v in ipairs({...}) do
        string = string .. tostring(v) .. " "
    end
    self.file:write("[" .. os.date("%d.%m.%Y %H:%M:%S") .. "] ".. self.name .. ": " .. string .. "\n")
    self.file:flush()
end

function logger:log_full(...)
    local function get_caller_relative_path()
        local function get_current_path()
            local info = debug.getinfo(4, "S")
            return info.source:sub(2)
        end
    
        local relative_path = string.gsub(get_current_path(), "^" .. getWorkingDirectory(), "")
        if string.sub(relative_path, 1, 1) == "\\" or string.sub(relative_path, 1, 1) == "/" then
            relative_path = string.sub(relative_path, 2)
        end
        
        return relative_path
    end
    
    local function get_caller_function_name()
        local info = debug.getinfo(3, "n")
        if info and info.name then
            return info.name 
        else
            return "main"
        end
    end

    local string = ""
    for i, v in ipairs({...}) do
        string = string .. tostring(v) .. "\t"
    end

    local called_from_relative = get_caller_relative_path()
    local called_from_function = get_caller_function_name()

    self.file:write("[" .. os.date("%d.%m.%Y %H:%M:%S") .. "] " .. self.name .. ": " .. called_from_relative .. " -> " .. called_from_function .. ": ".. string .. "\n")
    self.file:flush()
end

function logger:clear()
    self.file:close()
    self.file = io.open(self.fpath, "w")
    self.file:close()
    self.file = io.open(self.fpath, "a")
end

function logger:close()
    self.file:close()
end

return logger
