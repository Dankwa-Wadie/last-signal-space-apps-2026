stepAll(1/24)
for i=1,4 do
  local a=Vector3.new(-14+i*4.2,2.9,-2*i); local b=a+Vector3.new(9,0,0)
  walk("Walker"..i,a,b,k/(n-1))
end
return "ok"
