--- This module gives you a constructor for an object pool object that can
-- manage a set number of objects for you, allowing them to be created and
-- destroyed without allocating and deallocating memory and doing gc shiet.

function iterator(pool, i)
    i = i + 1
    while pool[i] and not pool[i]._alive do
        i = i + 1
    end
    local value = pool[i]
    if value then
        return i, value
    end
    return nil
end

return function (size, init)
    local pool = {}
    for i = 1, size do
        local item = {}
        init(item)
        item._alive = false
        item._next = i + 1
        table.insert(pool, item)
    end
    local free = 1
    return {
        get = function ()
            if free == 0 then return nil
            else
                local item = pool[free]
                item._alive = true
                free = item._next
                return item
            end

        end,
        kill = function (index)
            local item = pool[index]
            item._next = free
            item._alive = false
            free = index
        end,
        iterate = function ()
            return iterator, pool, 0
        end
    }
end
