function draw_text(str,x,y,al,extra,c1,c2)
    str = ""..str
    local al = al or 1
    local c1 = c1 or 7
    local c2 = c2 or 13

    if al == 1 then x -= #str * 2 - 1
    elseif al == 2 then x -= #str * 4 end

    y -= 3

    if extra then
        print(str,x,y+3,0)
        print(str,x-1,y+2,0)
        print(str,x+1,y+2,0)
        print(str,x-2,y+1,0)
        print(str,x+2,y+1,0)
        print(str,x-2,y,0)
        print(str,x+2,y,0)
        print(str,x-1,y-1,0)
        print(str,x+1,y-1,0)
        print(str,x,y-2,0)
    end

    print(str,x+1,y+1,c2)
    print(str,x-1,y+1,c2)
    print(str,x,y+2,c2)
    print(str,x+1,y,c1)
    print(str,x-1,y,c1)
    print(str,x,y+1,c1)
    print(str,x,y-1,c1)
    print(str,x,y,0)
end
