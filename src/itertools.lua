function filter(tbl, fn)
    newtbl = {}
    for item in all(tbl) do
        if fn(item) then
            newtbl[#newtbl + 1] = item
        end
    end
    return newtbl
end
