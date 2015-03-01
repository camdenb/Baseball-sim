
camera = require('lib/camera')
vector = require('lib/vector')

local baseDistanceScale = 200
local baseSize = 20
local runnerSize = 10

local baseline = vector(100, 40)
local mound = vector(200, 200)
local bases = {
	vector(0, 0),
	vector(0, 0),
	vector(0, 0),
	vector(0, 0),
}

local baseRunners = {
	{active = true, distanceAlongBaseline = 20},
	{active = false, distanceAlongBaseline = 20},
	{active = false, distanceAlongBaseline = 20},
	{active = false, distanceAlongBaseline = 20}
}



local paused = true
local cam = nil

local tickCounter = 0
local tickMax = 1

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
		vector(mound.x + baseDistanceScale, mound.y),
		vector(mound.x, mound.y - baseDistanceScale),
		vector(mound.x - baseDistanceScale, mound.y),
		vector(mound.x, mound.y + baseDistanceScale),
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
		love.graphics.line(bases[i].x + baseSize / 2, bases[i].y + baseSize / 2, bases[(i) % 4 + 1].x + baseSize / 2, bases[(i) % 4 + 1].y + baseSize / 2)
	end

	love.graphics.setColor(240, 240, 240)
	for i,v in ipairs(bases) do
		love.graphics.rectangle('fill', v.x, v.y, baseSize, baseSize)
	end
	love.graphics.rectangle('fill', mound.x, mound.y + baseSize / 4, baseSize, baseSize / 2)

	love.graphics.setColor(100, 200, 200)
	for i,v in ipairs(baseRunners) do
		if v.active then
			local newX, newY = getPositionFromDistanceAlongBaseline(v.distanceAlongBaseline)
			love.graphics.rectangle('fill', newX, newY, runnerSize, runnerSize)
		end
	end

end

function love.resize(w, h)
	WINDOW_HEIGHT = h
	WINDOW_WIDTH = w
end

function love.keypressed(key)

	if key == 'p' or key == 'escape' then
		paused = not paused
	end

end

function getPositionFromDistanceAlongBaseline(dist)
	local pos = vector(0, 0)

	if dist >= 0 and dist < 90 then
		pos.x = 10
		pos.y = 20
	end

	return pos.x, pos.y
end