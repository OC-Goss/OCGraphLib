local component = require("component")
local computer = require("computer")
local gpu = component.gpu
local event = require("event")
local unicode = require("unicode")
local package = require("package")
package.loaded["graphlib"] = nil
local graphlib = require("graphlib")

local turbine = component.it_gas_turbine
local battery = component.big_battery

-- unless you are hyper-lucky, you will need to change these uuids accordingly
local intrans = component.proxy("c843b55a-b82b-4d8b-91fa-256cfd1cb57d")
local outtrans = component.proxy("e2285330-23b2-49dc-aa8e-4d79a16d4cbf")

gpu.setResolution(160,38)
--gpu.setResolution(80,19)
local w, h = gpu.getResolution()
gpu.fill(1,1,w,h," ")

local clamp = function(num, min, max)
  if num > max then
    return max
  elseif num < min then
    return min
  else
    return num
  end
end

local sin = function(theta)
  return math.sin(theta/math.pi)
end

local cos = function(theta)
  return math.cos(theta/math.pi)
end

local turbs = {}
local bat = {}
local transi = {}
local transo = {}
for i = 1, 62 do
  turbs[i] = 0
  bat[i] = 0
  transi[i] = 0
  transo[i] = 0
end

local tinterv = 1
local binterv = 60
local j = 0
local c = computer.uptime()
local lc = 0
local lc2 = 0
local li = 1
local tb = battery.getEnergyStored()
gpu.fill(1,1,w,h," ")
while not event.pull(0,"interrupted") do
  c = computer.uptime() 
  if c > lc + tinterv then
    graphlib.cycleTable(turbs,math.floor(turbine.getSpeed()))
    graphlib.cycleTable(transi,intrans.getAvg()//10/100)
    graphlib.cycleTable(transo,outtrans.getAvg()//10/100)
    lc = c
    j = j + 1
  end
  if c > lc2 + binterv then
    graphlib.cycleTable(bat,(tb/li)//10000000/100)
    lc2 = c
    li = 0
    tb = 0
  else
    tb = tb + battery.getEnergyStored()
    li = li + 1
  end
  gpu.setForeground(0xFF6D00)
  gpu.setBackground(0x1E1E1E)
  graphlib.drawGraph(turbs, w-62-3, 3, 62, 16, 3000, {legend=true,title="RPM",textbg=0x0F0F0F,current=true})
  gpu.setForeground(0xFF0040)
  graphlib.drawGraph(bat, w-62-3, 21, 62, 16, battery.getMaxEnergyStored()/1000000000, {style=1,legend=true,title="Bat (GRF)",textbg=0x0F0F0F,current=true})
  gpu.setForeground(0x00FF80)
  graphlib.drawGraph(transi, 5+12, 3, 62, 16, 600 and nil, {style=1,legend=true,title="In (kRF/t)",textbg=0x0F0F0F,current=true})
  graphlib.drawGraph(transo, 5+12, 21, 62, 16, 600 and nil, {style=1,legend=true,title="Out (kRF/t)",textbg=0x0F0F0F,current=true})
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
end