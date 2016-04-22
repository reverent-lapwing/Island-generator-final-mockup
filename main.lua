function love.load()
 sqr_3 = (3^0.5)
 
 S = 10000
 
 nodes = {}
 
 local x = -2*S
 local y = (1/3)*sqr_3*S
 
 local i = 1
 
 while x <= 2*S do 
  local magic_number = 64
    
  for j = 1, i do
   table.insert(nodes, { x = x, y = y*(1 - (i/magic_number) + (j-1)*(2/magic_number)), z = 0 })
  end 
 
  i = i + 1
  x = x + (1/magic_number)*S
  
  love.graphics.clear()
  love.graphics.print(i)
  love.graphics.present()
 end
 
 scale_x = love.graphics.getWidth()/((8/3)*sqr_3*S)
 scale_y = love.graphics.getHeight()/(S*4)

 island()
end

function SetFunc(r_size, min, max)
 local  r = {}

 n0 = 0
 n1 = S
 
 for i = 1, r_size do
  local magic_number_min = (n1-n0)/min
  local magic_number_max = (n1-n0)/max
  local c = math.random(n0+magic_number_min,n1-magic_number_min) local d = math.random(magic_number_min, math.min(magic_number_max,math.min(math.abs(n0-c),math.abs(c-n1))))
  r[i] = { r1 = c-d, r2 = c+d, a = (math.random(0, 3000000)/1000000)+0.0 }
  r[i].rd = ((r[i].r2 - r[i].r1)/2)^(2*r[i].a)
 end 
 
 local norm = 0
 
 for i = n0, n1 do
  local val = Func(i, r, 1)
  if norm < val then norm = val end
 end
 
 return r, norm
end

function Func( x, r, normal ) 
 local x = x* (S/n1)
 
 result = 0
 
 if x < 0 or x > S then local y0 = 1.5 return -math.abs((y0/n1)*(2*x-n1))+y0 + result end
 
 for _,v in pairs(r) do
  if x < math.min(v.r1, v.r2) or x > math.max(v.r1, v.r2) then
   plus = 0
  else
   plus = ((-(x-v.r1)*(x-v.r2))^v.a)/v.rd
  end 
  result = result + plus
 end

 return result/normal
end

function branch1( basin_level, l, r, n, rn )
 for _,v in pairs(nodes) do
  local x = (Func(v.x, l[1], n[1]) 
										+ Func((-v.x + sqr_3*v.y + S)/2, l[2], n[2]) 
          + Func((-v.x - sqr_3*v.y + 3*S)/2, l[3], n[3])
		        + Func(v.y, l[4], n[4])
          + Func((-v.y + sqr_3*v.x + S)/2, l[5], n[5])
          + Func((-v.y - sqr_3*v.x + 3*S)/2, l[6], n[6]))/6
  
  local y = (math.abs(Func(v.x, r[1], rn[1])) 
											+ math.abs(Func((-v.x + sqr_3*v.y + S)/2, r[2], rn[2])) 
											+ math.abs(Func((-v.x - sqr_3*v.y + 3*S)/2, r[3], rn[3]))
											+ math.abs(Func(v.y, r[4], rn[4]))
											+ math.abs(Func((-v.y + sqr_3*v.x + S)/2, r[5], rn[5]))
											+ math.abs(Func((-v.y - sqr_3*v.x + 3*S)/2, r[6], rn[6])))/6
  
  v.z = -basin_level +1 -((-x+1)^(y+1))
 end
end

function branch2( basin_level, l, r, n, rn)
 for _,v in pairs(nodes) do
  v.z = -basin_level
      +(Func(v.x, l[1], n[1]) 
      + Func((-v.x + sqr_3*v.y + S)/2, l[2], n[2]) 
      + Func((-v.x - sqr_3*v.y + 3*S)/2, l[3], n[3])
		    + Func(v.y, l[4], n[4])
      + Func((-v.y + sqr_3*v.x + S)/2, l[5], n[5])
      + Func((-v.y - sqr_3*v.x + 3*S)/2, l[6], n[6])
      + Func(v.x, r[1], rn[1])
      + Func((-v.x + sqr_3*v.y + S)/2, r[2], rn[2])
      + Func((-v.x - sqr_3*v.y + 3*S)/2, r[3], rn[3])
		    + Func(v.y, r[4], rn[4])
      + Func((-v.y + sqr_3*v.x + S)/2, r[5], rn[5])
      + Func((-v.y - sqr_3*v.x + 3*S)/2, r[6], rn[6]))/(12-basin_level)
 end
end

function island()
 local basin_level = (math.random(0, 200000)/1000000)+0.1

 local l = {}
 local r = {}
 local n = {}
 local rn= {}
 
 for i = 1, 6 do
  l[i], n[i] = SetFunc(10, 10, 5)
  r[i],rn[i] = SetFunc(100, 100, 50)
 end
 
 branch1(basin_level,l,r,n,rn)

end


function DrawAll()
 local index = 0

 for _,v in pairs(nodes) do
  if v.z < -1 then goto skip end

  if v.z > 0 then
   love.graphics.setColor(0xff*(v.z),0xff*(1-v.z),0x60,0xff)
  else
   love.graphics.setColor(0x5e*(1+v.z),0xa0*(1+v.z),0xff*(1+v.z),0xff)
  end   
 
   love.graphics.circle("fill", 
   (v.y+sqr_3*S) * scale_x,  
   (v.x+(2*S)) * scale_y,
--   math.max(2, v.z*10))
   2)
   
   index = index + 1
   
   ::skip::
 end
 
 return index
end

function DrawLand()
 local index = 0
 
 for _,v in pairs(nodes) do
  if v.z > 0 then   
   love.graphics.setColor(0xff*(v.z),0xff*(1-v.z),0x60,0xff)
  
   love.graphics.circle("fill", 
   (v.y+sqr_3*S) * scale_x,  
   (v.x+(2*S)) * scale_y,
   3)
   
   index = index + 1
  end
 end
 
 return index
end

function love.draw()
 index = DrawAll()
 
 love.graphics.setColor(0xff,0xff,0xff)
 love.graphics.print(love.timer.getDelta().."\ncircles drawn: "..index)
end


function love.mousepressed()
 island()
end

function love.update()
 island()
end
