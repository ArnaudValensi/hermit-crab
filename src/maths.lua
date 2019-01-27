function is_point_in_box(px,py,x,y,w,h)
	if flr(px)>=flr(x) and flr(px)<flr(x+w) and flr(py)>=flr(y) and flr(py)<flr(y+h) then
		return true
	else
		return false
	end
end

function vertical_ray_cast(celx, cely, dir, level)
	empty_cells = {}
	cely += dir
	while not fget(level.sprite_at(celx, cely), 7) and cely > 0 and cely <= 128 do
		add(empty_cells, new_vec(celx, cely))
		cely += dir
	end
	return empty_cells
end
