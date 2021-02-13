local component = require("component")
local sp = require("subpixel3")
local unicode = require("unicode")
local gpu = component.gpu

local graphlib = {}

local clamp = function(num, min, max)
  if num > max then
    return max
  elseif num < min then
    return min
  else
    return num
  end
end

local lerpIndex = function(data, index)
  return (data[index//1] or data[1]) * (1 - index % 1) + (data[index//1+1] or data[#data]) * (index % 1)
end

local drawPixel = function(bmptab,iw,ih,x,y,val)
  x = x
  y = y-1
  if x < 0 or x > iw - 1 or y < 0 or y > ih - 1 then
    return
  end  
  local i = x + y * iw
  bmptab[i] = val
end

local drawLine = function(bmptab,iw,ih,x1,y1,x2,y2,val)
  val = val//1%2
  local dx, dy = x2 - x1, y2 - y1
  local step = 0
  if math.abs(dx) >= math.abs(dy) then
    step = math.abs(dx)
  else
    step = math.abs(dy)
  end
  dx = dx / step
  dy = dy / step
  for i=1, step do
    drawPixel(bmptab, iw, ih, x1//1, y1//1, val)
    x1 = x1 + dx
    y1 = y1 + dy
  end
end

function graphlib.cycleTable(data, newdata, len) -- shifts the table over by one index (old index 1 gets removed), and appends the new data
  local rval = data[1]
  for i = 1, len or #data do
    data[i] = data[i + 1] or 0
  end
  data[len or #data] = newdata
  return rval
end

function graphlib.drawGraph(data, xpos, ypos, width, height, range2, options) -- plots a graph of the given data
  local ofg, obg = gpu.getForeground(), gpu.getBackground()
  if not options then
    options = {}
  end
  if options.fg then
    gpu.setForeground(options.fg)
  end
  if options.bg then
    gpu.setBackground(options.bg)
  end
  local bmptab = {}
  local range = range2
  if not range then
    range = 0
    for i, d in ipairs(data) do
      range = math.max(range, d)
    end
  end
  local iw, ih = width*2, height*4
  for x = 0, iw+1 do
    if options.style == 2 then
      drawLine(bmptab,iw,ih,x,(ih-lerpIndex(data,x/(iw/(#data-1))+1)//(range/(ih-1)))//1,x,ih+1,1)
    else
      drawLine(bmptab,iw,ih,x,(ih-lerpIndex(data,x/(iw/(#data-1))+1)//(range/(ih-1)))//1,x+1,(ih-lerpIndex(data,(x+1)/(iw/(#data-1))+1)//(range/(ih-1)))//1,1)
    end
  end
  local bmpdisp = sp.tableToBraille(bmptab,width,height)
  for y=1,height do
    gpu.set(xpos,ypos+y-1,unicode.sub(bmpdisp,(y-1)*width+1,y*width))
  end
  if options.textfg then
    gpu.setForeground(options.textfg)
  else
    gpu.setForeground(ofg)
  end
  if options.textbg then
    gpu.setBackground(options.textbg)
  else
    gpu.setBackground(obg)
  end
  if options.legend or options.title or options.current then
    gpu.fill(xpos-12,ypos,12,height," ")
  end
  if options.legend then
    gpu.set(xpos-#tostring(range)-1,ypos,tostring(range))
    gpu.set(xpos-2,ypos+height-1,"0")
  end
  if options.title then
    gpu.set(xpos-#tostring(options.title)-1,ypos+height//2-1,tostring(options.title))
  end
  if options.current then
    gpu.set(xpos-#tostring(data[#data])-1,ypos+height//2,tostring(data[#data]))
  end
  if options.textfg then
    gpu.setForeground(ofg)
  end
  if options.textbg then
    gpu.setBackground(obg)
  end
end

return graphlib