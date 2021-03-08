local util = require 'util'

function select(n, ...)
    local args = {...}
    return args[n]
end

function iter(...)
    for i, v in ipairs({...}) do
        print(i, v)
    end
end

items = {
    'tango is a nerd',
    'he is very evil',
    'hellk yeah'
}

print(select(1, table.unpack(items)))
iter(table.unpack(items))

local str = 'hello hello'

print(str[1])
