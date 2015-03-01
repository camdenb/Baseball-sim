
camera = require('lib/camera')
vector = require('lib/vector')

local baseDistanceScale = 200
local baseSize = 20
local runnerSize = 10

local baseline = vector(100, 40)
local mound = vector(200, 200)
local bases = nil

local baseRunners = {
	{active = true, totalDistance = 0, speed = 1},
	{active = false, totalDistance = 110, speed = 1},
	{active = true, totalDistance = 290, speed = 1},
	{active = false, totalDistance = 20, speed = 1}
}
local ball = {pos = vector(0,0), speed = vector(0,0)}

local fielder = {pos = vector(240, 400), throwingSpeed = 7}



local paused = true
local cam = nil

local tickCounter = 0
local tickMax = 3

function love.load()

	WINDOW_HEIGHT = 500
	WINDOW_WIDTH = 500

	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {resizable=true, vsync=enableVsync, fsaa=0})
	love.window.setTitle('Baseball')
	love.graphics.setBackgroundColor(200, 200, 200)

	cam = camera(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2)

	mound.x = WINDOW_WIDTH / 2 - baseSize / 2
	mound.y = WINDOW_HEIGHT / 2 - baseSize / 2
	bases = {
		{pos = vector(mound.x + baseDistanceScale, mound.y), distance = 90},
		{pos = vector(mound.x, mound.y - baseDistanceScale), distance = 180},
		{pos = vector(mound.x - baseDistanceScale, mound.y), distance = 270},
		{pos = vector(mound.x, mound.y + baseDistanceScale), distance = 360}
	}	

	-- for i,v in ipairs(bases) do
	-- 	v.x = baseline.x
	-- end

	-- bases[1].y = 90 + baseline.y
	-- bases[2].y = 180 + baseline.y
	-- bases[3].y = 270 + baseline.y
	-- bases[4].y = 360 + baseline.y

end

function love.update(dt)
	tickCounter = tickCounter + 1
	if tickCounter >= tickMax then
		tick()
		tickCounter = 0
	end

end

function tick()
	if not paused then
		for i,v in ipairs(baseRunners) do
			if v.active then
				v.totalDistance = v.totalDistance + v.speed
			end
		end

		ball.pos = ball.pos + ball.speed

	end
end

function love.draw()

	if paused then
		love.graphics.setColor(0, 0, 0)
		love.graphics.print('Paused', WINDOW_WIDTH - 60, 10)
	end
	
	cam:attach()
	drawWorld()
	cam:detach()

end

function drawWorld()
	love.graphics.setColor(230, 190, 160)
	love.graphics.setLineWidth(baseSize)
	--love.graphics.rectangle('fill', baseline.x, baseline.y, 10, 360)
	for i = 1, 4, 1 do
		love.graphics.line(bases[i].pos.x + baseSize / 2, bases[i].pos.y + baseSize / 2, bases[(i) % 4 + 1].pos.x + 
			baseSize / 2, bases[(i) % 4 + 1].pos.y + baseSize / 2)
	end

	love.graphics.setColor(240, 240, 240)
	for i,v in ipairs(bases) do
		love.graphics.rectangle('fill', v.pos.x, v.pos.y, baseSize, baseSize)
	end
	love.graphics.rectangle('fill', mound.x, mound.y + baseSize / 4, baseSize, baseSize / 2)

	for i,v in ipairs(baseRunners) do
		if v.active then
			local newX, newY = getPositionFromTotalDistance(v.totalDistance)
			love.graphics.setColor(100, 200, 200)
			love.graphics.rectangle('fill', newX, newY, runnerSize, runnerSize)
			-- love.graphics.setColor(255, 0, 0, 10)
			-- love.graphics.setLineWidth(1)
			-- for i2,v2 in ipairs(bases) do
			-- 	love.graphics.line(newX, newY, v2.x, v2.y)
			-- end
		end
	end

	love.graphics.setColor(255, 0, 0, 50)
	love.graphics.setLineWidth(1)
	for i2,v2 in ipairs(baseRunners) do
		local b = getBaseToThrowTo(fielder.pos, fielder.throwingSpeed)
		love.graphics.line(fielder.pos.x, fielder.pos.y, b.pos.x, b.pos.y)
	end

	love.graphics.setColor(200, 255, 200)
	love.graphics.rectangle('fill', fielder.pos.x, fielder.pos.y, runnerSize, runnerSize)
	love.graphics.line(ball.pos.x, ball.pos.y, ball.pos.x + (ball.speed.x) * 10, ball.pos.y + (ball.speed.y) * 10)

	love.graphics.setColor(100, 255, 255)
	love.graphics.rectangle('fill', ball.pos.x, ball.pos.y, 5, 5)

end

function love.resize(w, h)
	WINDOW_HEIGHT = h
	WINDOW_WIDTH = w
end

function love.keypressed(key)

	if key == 'p' or key == 'escape' then
		paused = not paused
	elseif key == 'n' then
		table.insert(baseRunners, {active = true, totalDistance = 0})
	elseif key == 't' then
		throwBall(fielder)
	end

end

function getPositionFromTotalDistance(dist)
	local pos = vector(0, 0)

	if dist >= 0 and dist < 90 then
		percentDist = (dist % 90) / 90
		pos.x = bases[4].pos.x + percentDist * (bases[1].pos.x - bases[4].pos.x) + runnerSize / 2
		pos.y = bases[4].pos.y + percentDist * (bases[1].pos.y - bases[4].pos.y) + runnerSize / 2
	elseif dist >= 90 and dist < 180 then
		percentDist = (dist % 90) / 90
		pos.x = bases[1].pos.x - percentDist * math.abs(bases[1].pos.x - bases[2].pos.x)
		pos.y = bases[1].pos.y - percentDist * math.abs(bases[1].pos.y - bases[2].pos.y)
	elseif dist >= 180 and dist < 270 then
		percentDist = (dist % 90) / 90
		pos.x = bases[2].pos.x - percentDist * math.abs(bases[3].pos.x - bases[2].pos.x) + runnerSize / 2
		pos.y = bases[2].pos.y + percentDist * math.abs(bases[3].pos.y - bases[2].pos.y) + runnerSize / 2
	elseif dist >= 270 and dist <= 360 then
		percentDist = (dist % 90) / 90
		pos.x = bases[3].pos.x + percentDist * math.abs(bases[4].pos.x - bases[3].pos.x)
		pos.y = bases[3].pos.y + percentDist * math.abs(bases[4].pos.y - bases[3].pos.y)
	else
		pos.x = bases[4].pos.x
		pos.y = bases[4].pos.y
	end

	return pos.x, pos.y
end

function getBaseToThrowTo(fielderPos, throwSpeed)

	local bestBase = nil
	local bestTime = 10000

	for i_base, base in ipairs(bases) do
		local throwTime = fielderPos:dist(base.pos) / throwSpeed
		for i_runner, runner in ipairs(baseRunners) do
			if runner.active then
				local runTime = (base.distance - runner.totalDistance) / runner.speed
				-- print('Time for runner', runTime)
				-- print('Time for thrower', throwTime)
				-- print('runnerTime - ballTime', (runTime - throwTime), runner.totalDistance)
				if (runTime - throwTime) < bestTime and (runTime - throwTime) > 0 then
					if bestBase == nil then
						bestBase = base
					end
					if base.distance >= bestBase.distance then
						bestBase = base
						bestTime = (runTime - throwTime)
					end
				end
			end
		end
	end

	if bestBase == nil then
		bestBase = bases[4]
	end

	return bestBase

end

function throwBall()
	ball.pos = fielder.pos
	bestBase = getBaseToThrowTo(fielder.pos, fielder.throwingSpeed)
	ball.speed = bestBase.pos - ball.pos
	ball.speed = ball.speed:normalized() * fielder.throwingSpeed
	print(ball.speed)
end