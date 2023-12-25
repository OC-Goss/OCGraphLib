local component = require("component")
local computer = require("computer")
local gpu = component.gpu
local event = require("event")
local unicode = require("unicode")
local package = require("package")
local graphlib = require("graphlib")
local term = require("term")
local thread = require("thread")

local reactorCombine = {address ={}, reactor = {} , logicalThread = {}, uiThread = {}}

local combineData = {salt = {}, heat = {}, turbine = {}}

local whith,height = gpu.getResolution()

term.clear()

for i = 1, 62 do
    combineData.salt[i] = 0
    combineData.heat[i] = 0
    combineData.turbine[i] = 0
  end

local function getTemprature(reactor)
    if reactor.type == 'nc_salt_fission_reactor' then
        return reactor.getHeatStored()
    end
end

local function reactorLoop(reactor)
    
end

local function uiDisplay(reactor)
    while true do
        graphlib.cycleTable(combineData.salt,getTemprature(reactor))
        gpu.setForeground()
        gpu.setBackground()
        graphlib.drawGraph(combineData.salt,w-62-3, 3, 62, 16, 3000, {legend=true,title="Salt Temprature",textbg=0x0F0F0F,current=true})
    end
end

local function checkAvailable()
    for address, componentType in component.list() do
        local reactor = {}
       if componentType == "nc_salt_fission_reactor" then
        reactor = component.proxy(address)
        reactor.status = "init"
        reactor.optimumTemperature = ""
        reactor.MAXTEMPERATURE = reactor.getHeatCapacity()
        reactorCombine.address[0] = address
        reactorCombine.reactor[address] = reactor
        reactorCombine.logicalThread[address] = thread.create(reactorLoop,reactor)
        reactorCombine.uiThread[address] = thread.create(uiDisplay,reactor)
       end

       if componentType == "nc_heat_exchanger" then
        reactor = component.proxy(address)
        reactor.status = "init"
        reactorCombine.address[0] = address
        reactorCombine.reactor[address] = reactor
        reactorCombine.logicalThread[address] = thread.create(reactorLoop,reactor)
        reactorCombine.uiThread[address] = thread.create(uiDisplay,reactor)
       end

       if componentType == "nc_turbine" then
        reactor = component.proxy(address)
        reactor.status = "init"
        reactorCombine.address[0] = address
        reactorCombine.reactor[address] = reactor
        reactorCombine.logicalThread[address] = thread.create(reactorLoop,reactor)
        reactorCombine.uiThread[address] = thread.create(uiDisplay,reactor)
       end
    end

    if #reactorCombine ~= 0 then
        return true
    end

    return false
end