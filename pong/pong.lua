event = require("event")
component = require("component")
local computer=require("computer")

local argDifficulty, argSpeed = ...
function getLenPlayer() -- len deve essere dispari
	if argDifficulty == '0' then -- easy
		return 5
	end
	if argDifficulty == '1' then -- medium
		return 3
	end
	if argDifficulty == '2' then -- hard
		return 1
	end
	return 5 -- default (arg nil)
end
function getSpeedGame()
	if argSpeed == '0' then -- slow
		return 0.2
	end
	if argSpeed == '1' then -- medium
		return 0.1
	end
	if argSpeed == '2' then -- fast
		return 0.05
	end
	return 0.1 -- default (arg nil)
end

local gpu = component.gpu
local w,h = gpu.getResolution()
local distWallPlayer = 6
local lenPlayer = getLenPlayer()
local border = 1
local borderChar = '#'
local playerChar = '|'
local sleepTime = getSpeedGame()
local sleepTimeUntilNow =0
local winScore = 10

local distWallScore = 3
local yScore = h/2
local player1Score = 0
local player2Score = 0
local resetBallSleepTime = 1

local quit = false
local win = false

function drawScores()
	gpu.set(distWallScore,yScore,tostring(player1Score))
	gpu.set(w-distWallScore,yScore,tostring(player2Score))
end
function drawPlayer(x,yCenter)
	local halfPlayer = lenPlayer/2 -1
	yCenter = math.max(yCenter,border + halfPlayer+1)
	yCenter = math.min(yCenter,h-border - halfPlayer-1)
	for i= yCenter - halfPlayer,yCenter + halfPlayer+1 do
		gpu.set(x,i,playerChar)
	end
end
function drawPlayer1(yCenter)
	drawPlayer(distWallPlayer,yCenter)
end
function drawPlayer2(yCenter)
	drawPlayer(w-distWallPlayer,yCenter)
end

function clearScreen()
	gpu.fill(1,1,w,h," ")
end
function clearColumnPlayer1()
	for i = 1+border,h-border do
		gpu.set(distWallPlayer,i," ")
	end
end
function clearColumnPlayer2()
	for i = 1+border,h-border do
		gpu.set(w-distWallPlayer,i," ")
	end
end
function drawBorder()
	for i= 1,w do
		gpu.set(i,1,borderChar)
		gpu.set(i,h,borderChar)
	end
	for i= 1,h do
		gpu.set(1,i,borderChar)
		gpu.set(w,i,borderChar)
	end
end

local xSpeed =-1
local ySpeed =0

local yCenterPlayer1 = h/2
local yCenterPlayer2 = h/2

local lastMovPlayer1 = 0
local lastMovPlayer2 = 0

local lastTimeMovPlayer1 = 0
local lastTimeMovPlayer2 = 0

--print("speed: (".. xSpeed .. " " .. ySpeed..")")
local xBall = math.random(1+border,w-border)
local yBall = math.random(1+border,h-border)

xBall = w/2
yBall = h/2

local lastXBall = xBall
local lastYBall = yBall

clearScreen()
local startMsg = "Score ".. winScore .. " to win!"
gpu.set(w/2 - string.len(startMsg)/2,h/2,startMsg)
os.sleep(1.5)
clearScreen()
drawBorder()

drawPlayer1(yCenterPlayer1)
drawPlayer2(yCenterPlayer2)
local beepTime = 0.05
local beepBounce1 = 97*2 +1
local beepBounce2= 48*2 +1
local beepScore = 110*2 +1
local beepResetBall = 123*2 +1
function bounceBeep()
	local x = math.random(0,1)
	if x==0 then
		computer.beep(beepBounce1,beepTime)
	else
		computer.beep(beepBounce2,beepTime)
	end
end
function scoreBeep()
	computer.beep(beepScore,beepTime)
end
function resetBallBeep()
	computer.beep(beepResetBall,beepTime)
end
function resetBall()
	xBall = w/2
	yBall = h/2
	math.randomseed(os.time())
	xSpeed = math.random(-1,1)
	ySpeed = math.random(-1,1)
	if xSpeed*ySpeed ==0 then
		xSpeed =1
		ySpeed =1
	end
	drawScores()
	gpu.set(lastXBall,lastYBall," ")
	gpu.set(xBall,yBall,"O")
	os.sleep(resetBallSleepTime)
	resetBallBeep()
end
function keydown(_,_,_,ch)
	if ch == 20 then -- T
		quit = true
	end
end
function touch(_,_,x,y)
	local xIn =x
	local yIn =y
	if xIn<w/2 and yIn-yCenterPlayer1 ~= 0 then -- meta schermo player 1
		clearColumnPlayer1()
		local movDir = (yIn-yCenterPlayer1)/math.abs(yIn-yCenterPlayer1)
		yCenterPlayer1 = yCenterPlayer1+ movDir
		drawPlayer1(yCenterPlayer1)
		lastTimeMovPlayer1 = sleepTimeUntilNow
		lastMovPlayer1 = movDir
	elseif yIn-yCenterPlayer2 ~= 0 then -- meta schermo player 2
		clearColumnPlayer2()
		local movDir = (yIn-yCenterPlayer2)/math.abs(yIn-yCenterPlayer2)
		yCenterPlayer2 = yCenterPlayer2+ movDir
		drawPlayer2(yCenterPlayer2)
		lastTimeMovPlayer2 = sleepTimeUntilNow
		lastMovPlayer2 = movDir
	end
end
event.listen("touch",touch)
event.listen("key_down",keydown)
while true do
	if quit or win then break 
	end
	gpu.set(lastXBall,lastYBall," ")
	gpu.set(xBall,yBall,"O")
	drawScores()
	os.sleep(sleepTime)
	sleepTimeUntilNow = sleepTimeUntilNow + sleepTime
	
	lastXBall = xBall
	lastYBall = yBall
	
	xBall = xBall + xSpeed
	yBall = yBall + ySpeed
	-- ogni 2 sec ridisegna i giocatori
	if(math.floor(sleepTimeUntilNow)%2 == 0)then
		drawPlayer1(yCenterPlayer1)
		drawPlayer2(yCenterPlayer2)
	end
	
	-- player collisions
	local halfPlayer = lenPlayer/2 -1 
	-- collision player1
	if xBall == distWallPlayer and  
		(yBall >= yCenterPlayer1-halfPlayer-1 and  yBall <= yCenterPlayer1+halfPlayer+1) then
		bounceBeep()
		xBall = xBall+1
		xSpeed = xSpeed * -1
		if (sleepTimeUntilNow - lastTimeMovPlayer1) <= 0.2 and lastMovPlayer1 ~= 0 then
			ySpeed = lastMovPlayer1
		end
		drawPlayer1(yCenterPlayer1)
		--gpu.set(w/2,h/2-2,tostring(sleepTimeUntilNow - lastTimeMovPlayer1))
	end
	-- collision player2
	if xBall == w-distWallPlayer and 
		(yBall >= yCenterPlayer2-halfPlayer-1 and  yBall <= yCenterPlayer2+halfPlayer+1) then
		bounceBeep()
		xBall = xBall-1
		xSpeed = xSpeed * -1
		if (sleepTimeUntilNow - lastTimeMovPlayer2) <= 0.2 and lastMovPlayer2 ~= 0 then
			ySpeed = lastMovPlayer2
		end
		drawPlayer2(yCenterPlayer2)
	end
	
	-- wall collisions
	--right wall
	if xBall >= w-border then 
		bounceBeep()
		player1Score = player1Score +1
		if player1Score >=winScore then
			win = true
		end 
		resetBall()
		--xBall = w-border
		--xSpeed = xSpeed * -1
	end
	--left wall
	if xBall <= 1+border then 
		bounceBeep()
		player2Score = player2Score +1
		if player2Score >=winScore then
			win = true
		end 
		resetBall()
		--xBall = 1+border
		--xSpeed = xSpeed * -1
	end
	--bottom wall
	if yBall >= h-border then 
		bounceBeep()
		yBall = h-border
		ySpeed = ySpeed * -1
	end
	--top wall
	if yBall <= 1+border then 
		bounceBeep()
		yBall = 1+border
		ySpeed = ySpeed * -1
	end
	if(math.floor(sleepTimeUntilNow)%10 == 0)then
		--gpu.set(w/2,h/2-2,"free ".. tostring(sleepTimeUntilNow))
		computer.freeMemory()
	end
end
clearScreen()
if win then
	local winner
	if player1Score >=winScore then
		winner = "1"
	else
		winner = "2"
	end
	local msg = "Player ".. winner .. " wins!"
	gpu.set(w/2 - string.len(msg)/2,h/2,msg)
else
	local msg = "Thank you for playing"
	gpu.set(w/2 - string.len(msg)/2,h/2,msg)
end

os.sleep(1.5)

event.ignore("key_down", keydown)
event.ignore("touch", touch)
clearScreen()
computer.freeMemory()