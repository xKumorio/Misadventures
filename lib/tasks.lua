local tasks = {}

local ffi = require("ffi")
ffi.cdef[[
unsigned long GetTickCount(void);
]]

local tasks_list = {}

function tasks.add(name, code, wait_time)
    if not name then
        error("tasks: arg 'name' is missing")
    elseif not code then
        error("tasks: arg 'code' is missing")
    elseif not wait_time then
        error("tasks: arg 'wait_time' is missing")
    end

    if name ~= "" and tasks.get(name) then
        error("tasks: already exists")
    end

    local task = {name = name, code = code, start_time = ffi.C.GetTickCount(), wait_time = wait_time}
    table.insert(tasks_list, task)
    local index = #tasks_list

    return tasks_list[index]
end

function tasks.remove_by_name(name)
    for i, v in ipairs(tasks_list) do
        if v.name == name then
            table.remove(tasks_list, i)
            return
        end
    end
end

function tasks.remove_by_value(value)
    local function get_index(value)
        for i, v in ipairs(tasks_list) do
            if v == value then
                return i
            end
        end
    end

    local i = get_index(value)
    if not i then 
        error("tasks: value not found")
    end
    table.remove(tasks_list, i)
end

function tasks.remove_all()
    tasks_list = {}
end

function tasks.get(name)
    for i, v in ipairs(tasks_list) do
        if v.name == name then
            return v
        end
    end
end

function tasks.process()
    for i, v in ipairs(tasks_list) do
        if ffi.C.GetTickCount() - v.start_time > v.wait_time then
            local success, result
            if type(v.code) == "function" then
                success, result = pcall(v.code)
            else
                success, result = pcall(loadstring(v.code))
            end
            table.remove(tasks_list, i)
            if not success then
                print("tasks: eror running code -> " .. result) 
            end
        end
    end
end

return tasks