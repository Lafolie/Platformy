--[[
	COLLISION FUNCTIONS
	No idea if he wrote them but I'm giving credit to Jasoco from the forums for these.
	http://love2d.org/forums/memberlist.php?mode=viewprofile&u=594
	--------
	http://love2d.org/forums/viewtopic.php?f=4&t=2904
]]--


--This is more compact:
function overlap(x1,y1,w1,h1, x2,y2,w2,h2)
  return not (x1+w1 < x2  or x2+w2 < x1 or y1+h1 < y2 or y2+h2 < y1)
end

--And this one works for a single point inside a box:
function inside(x1,y1, x2,y2,w2,h2)
  return not (x1 < x2  or x2+w2 < x1 or y1 < y2 or y2+h2 < y1)
end

--And you can use this one to find collisions of a single point with a circle: (By checking if the distance is less than the radius of the circle)
function distanceFrom(x1,y1,x2,y2) 
  return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) 
end
