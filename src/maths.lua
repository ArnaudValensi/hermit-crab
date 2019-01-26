function is_point_in_box(px,py,x,y,w,h)
	if flr(px)>=flr(x) and flr(px)<flr(x+w) and flr(py)>=flr(y) and flr(py)<flr(y+h) then
		return true
	else
		return false
	end
end
