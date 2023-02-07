event = require("event")
component = require("component")
local computer=require("computer")
local process = require("process")

local gpu = component.gpu
local w,h = gpu.getResolution()
local quit = false
local startPressed = false
local beepTime = 0.05
local beepOptionUp = 195
local beepOptionDown = 220
local beepMenuChange = 391
local beepStart = 440
-- 0 -> difficulty menu
-- 1 -> speed menu
local menuSelected = 0
function clearScreen()
	gpu.fill(1,1,w,h," ")
end
function intro()
	local charIntro = '?'
	local title = "PONG"
	local madeby = "Made by alexmalefico"
	for i=1,w do
		for j=1,h do
			gpu.set(i,j,charIntro)
		end
	end
	for j=1,h do
		for i=1,w do
			gpu.set(i,j," ")
		end
	end
	local x = w/2 - string.len(title)/2
	gpu.set(x ,h/2 - 2,title)
	x = w/2 - string.len(madeby)/2
	gpu.set(x ,h/2 + 2,madeby)
end
clearScreen()
intro()
os.sleep(2)
clearScreen()
local charCursor = '>'
local yMenuDiff = 4
local yCursorMenuDiff = yMenuDiff+2

local msgMenuDiff = "Choose difficulty"
local msg = msgMenuDiff
local xMenuDiff = w/5 - string.len(msg)/2
local xMsgMenuDiff = xMenuDiff
gpu.set(xMenuDiff,yMenuDiff,msg)
xMenuDiff = xMenuDiff + string.len(msg)/4
msg = "Easy"
gpu.set(xMenuDiff,yMenuDiff+2,msg)
msg = "Medium"
gpu.set(xMenuDiff,yMenuDiff+3,msg)
msg = "Hard"
gpu.set(xMenuDiff,yMenuDiff+4,msg)

gpu.set(xMenuDiff-1,yCursorMenuDiff,charCursor)

local yMenuSpeed = 4
local yCursorMenuSpeed = yMenuSpeed+3

local msgMenuSpeed = "Choose speed"
local msg = msgMenuSpeed
local xMenuSpeed = w - w/5 - string.len(msg)/2
local xMsgMenuSpeed = xMenuSpeed
gpu.set(xMenuSpeed ,yMenuSpeed,msg)
xMenuSpeed = xMenuSpeed + string.len(msg)/4
msg = "Slow"
gpu.set(xMenuSpeed,yMenuSpeed+2,msg)
msg = "Medium"
gpu.set(xMenuSpeed,yMenuSpeed+3,msg)
msg = "Fast"
gpu.set(xMenuSpeed,yMenuSpeed+4,msg)

gpu.set(xMenuSpeed-1,yCursorMenuSpeed,charCursor)
local msg = "PONG GAME SETTINGS"
gpu.set(w/2 - string.len(msg)/2,1,msg)
local msg = "Press T to terminate the game"
gpu.set(w/2 - string.len(msg)/2,h-3,msg)
local msg = "Press S to start the game"
gpu.set(w/2 - string.len(msg)/2,h-1,msg)


local sleepTime = 0.1
local sleepTimeUntilNow = 0

local lastYCursorDiff = yCursorMenuDiff
local lastYCursorSpeed = yCursorMenuSpeed

local secTraBlink = 0.25

local speedVisible = true
local lastTimeVisibleSpeed = 0

local diffVisible = true
local lastTimeVisibleDiff = 0

function blinkMsgMenuDiff()
	writeMsgMenuSpeed()
	if sleepTimeUntilNow - lastTimeVisibleDiff >=secTraBlink then
		if diffVisible then
			clearMsgMenuDiff()
			diffVisible = false
		else
			writeMsgMenuDiff()
			diffVisible = true
		end
		lastTimeVisibleDiff = sleepTimeUntilNow
	end 
end
function blinkMsgMenuSpeed() 
	writeMsgMenuDiff()
	if sleepTimeUntilNow - lastTimeVisibleSpeed >=secTraBlink then
		if speedVisible then
			clearMsgMenuSpeed()
			speedVisible = false
		else
			writeMsgMenuSpeed()
			speedVisible = true
		end
		lastTimeVisibleSpeed = sleepTimeUntilNow
	end 
end
function clearMsgMenuDiff()
	for i=xMsgMenuDiff,xMsgMenuDiff+string.len(msgMenuDiff) do
		gpu.set(i,yMenuDiff," ")
	end
end
function clearMsgMenuSpeed()
	for i=xMsgMenuSpeed,xMsgMenuSpeed+string.len(msgMenuSpeed) do
		gpu.set(i,yMenuSpeed," ")
	end
end
function writeMsgMenuDiff()
	gpu.set(xMsgMenuDiff,yMenuDiff,msgMenuDiff)
end
function writeMsgMenuSpeed()
	gpu.set(xMsgMenuSpeed,yMenuSpeed,msgMenuSpeed)
end
function keydown(_,_,_,ch)
	if ch == 20 then -- T
		quit = true
	end
	if ch == 31 then -- S
		startPressed = true
	end
	if ch == 203 then -- left key
		computer.beep(beepMenuChange,beepTime)
		if menuSelected == 0 then
			menuSelected = 1
		else
			menuSelected = 0
		end
	end
	if ch == 205 then -- right key
		computer.beep(beepMenuChange,beepTime)
		if menuSelected == 1 then
			menuSelected = 0
		else
			menuSelected = 1
		end
	end
	if ch == 200 then -- up key
		computer.beep(beepOptionUp,beepTime)
		if menuSelected == 0 then
			-- limita il mov del cursore MENU DIFFICULTY tra le opzioni possibili
			if yCursorMenuDiff <= yMenuDiff+2 then 
				yCursorMenuDiff = yMenuDiff+4
			else
				yCursorMenuDiff = yCursorMenuDiff -1
			end
		else
			-- limita il mov del cursore MENU SPEED tra le opzioni possibili
			if yCursorMenuSpeed <= yMenuSpeed+2 then 
				yCursorMenuSpeed = yMenuSpeed+4
			else
				yCursorMenuSpeed = yCursorMenuSpeed -1
			end
		end
	end
	if ch == 208 then -- down key
		computer.beep(beepOptionDown,beepTime)
		if menuSelected == 0 then
			-- limita il mov del cursore MENU DIFFICULTY tra le opzioni possibili
			if yCursorMenuDiff >= yMenuDiff+4 then 
				yCursorMenuDiff = yMenuDiff+2
			else
				yCursorMenuDiff = yCursorMenuDiff +1
			end
		else
			-- limita il mov del cursore MENU SPEED tra le opzioni possibili
			if yCursorMenuSpeed >= yMenuSpeed+4 then 
				yCursorMenuSpeed = yMenuSpeed+2
			else
				yCursorMenuSpeed = yCursorMenuSpeed +1
			end
		end
	end
end
event.listen("key_down",keydown)


while true do
	if quit or startPressed then break
	end
	os.sleep(sleepTime)
	sleepTimeUntilNow = sleepTimeUntilNow + sleepTime
	
	gpu.set(xMenuSpeed-1,lastYCursorSpeed," ")
	gpu.set(xMenuDiff-1,lastYCursorDiff," ")
	
	gpu.set(xMenuSpeed-1,yCursorMenuSpeed,charCursor)
	gpu.set(xMenuDiff-1,yCursorMenuDiff,charCursor)
	
	lastYCursorDiff = yCursorMenuDiff
	lastYCursorSpeed = yCursorMenuSpeed
	
	if menuSelected == 0 then
		blinkMsgMenuDiff()
	elseif menuSelected == 1 then
		blinkMsgMenuSpeed()
	end
end
clearScreen()
local argDiff = tostring(yCursorMenuDiff - (yMenuDiff+2))
local argSpeed = tostring(yCursorMenuSpeed - (yMenuSpeed+2))

local path = process.running()
local index = string.find(path, "/[^/]*$") -- index of last slash
path = string.sub(path,1,index)
if startPressed then
	computer.beep(beepStart,beepTime)
	event.ignore("key_down", keydown)
	computer.freeMemory()
	os.execute(path .. "pong" .. " " .. argDiff .. " " .. argSpeed)
end
event.ignore("key_down", keydown)
computer.freeMemory()
