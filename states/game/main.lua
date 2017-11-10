--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local track  = ''
local mus  = false
local bgmdir  = fil .getDirectoryItems( 'data/music/' )

local ray  = require 'libs.ray'
local enemy  = require 'libs.enemy'
local e  = {} -- list of enemies

local mouseSensitivity  = 0.01
local lineWid  = WW /fov

local maps  = require 'data.maps'
local map  = maps[ level ]

local mapScale  = 10
local half  = mapScale /2

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function newSong() -- public domain songs from modarchive.org
  local lasttrack  = track
  while track == lasttrack do -- shuffle 'til we're certain it's not the same song
    track  = bgmdir[ mat .random( #bgmdir ) ]
  end
  print( 'track:  ' ..track )
  bgm  = aud .newSource( 'data/music/' ..track )
  aud .play( bgm )
end -- newSong()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function load()
  gra .setPointSize( mapScale )

  for d = 1, fov do
    ray .dist[#ray .dist +1] = 0
    ray .wall[#ray .wall +1] = 0
    ray .color[#ray .color +1] = 0
  end

  if mus then
    newSong()  -- begin music
  end -- if mus
end -- load()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .keypressed( key, scancode, isrepeat )
  if scancode == 'escape'  then  eve .quit()  end
end -- Lo .keypressed

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .keyreleased( key, scancode )

  if scancode == 'end' then -- skip to the next song
    bgm :stop()
  end -- if scancode

end -- Lo .keyreleased

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .mousemoved( x, y, dx, dy, istouch )
  player.dir  = player.dir +(dx *mouseSensitivity)
  player.begin  = player.dir -halfFov

  if     player.dir < 0   then player.dir  = 360 -player.dir
  elseif player.dir >= 360 then player.dir  = player.dir -360
  end

end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .update( dt ) -- DeltaTime  = time since last update,  in seconds.
  require('libs.lovebird.lovebird') .update()

  timer  = timer +dt
  desiredX  = player.x
  desiredY  = player.y

  if key .isDown( 'w' ) then
    desiredX  = desiredX +math.cos(player.dir) *player.speed
    desiredY  = desiredY +math.sin(player.dir) *player.speed
  end -- if key 'W'

  if key .isDown( 'a' ) then
    desiredX  = desiredX +math.sin(player.dir) *player.speed
    desiredY  = desiredY -math.cos(player.dir) *player.speed
  end -- if key 'A'

  if key .isDown( 's' ) then
    desiredX  = desiredX -math.cos(player.dir) *player.speed
    desiredY  = desiredY -math.sin(player.dir) *player.speed
  end -- if key 'S'

  if key .isDown( 'd' ) then

    desiredX  = desiredX -math.sin(player.dir) *player.speed
    desiredY  = desiredY +math.cos(player.dir) *player.speed
  end -- if key 'D'

  if desiredX >= 1 and desiredX < map .x then player .x  = desiredX end
  if desiredY >= 1 and desiredY < map .y then player .y  = desiredY end

  ray .cast()

  if mus then
    -- keep the music playing
    if bgm :isStopped() then
      newSong()
    end -- if bgm
  end -- if mus

end -- Lo .update(dt)

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .draw()

  gra .setLineWidth( lineWid )

  for i = 1, fov do
    local verticalSlice  = i *lineWid -lineWid /2
    gra .setColor( ray .color[i] )
    gra .line( verticalSlice,  h5 -ray .wall[i],  verticalSlice,  h5 +ray .wall[i] )
  end -- fov

  -- map walls
  gra .setColor( 200,  0,  0,  100 )
  gra .rectangle( 'fill',  w8 +half,  h1 +half,  map .x *mapScale,  map .y *mapScale )

  gra .setColor( 200,  0,  0,  200 )
  for x = 1,  map .x do
    for y = 1,  map .y do
      if map .data[y][x] > 0 then
        gra .points( w8 +x *mapScale,  h1 +y *mapScale )
      end -- if wall
    end -- x
  end -- print map

  -- rays
  gra .setLineWidth( 1 )
  local minimapX  = w8 +player .x *mapScale
  local minimapY  = h1 +player .y *mapScale

  for i = 1, fov do
    gra .setColor( 50, 30 +i *2.5, 50 )
    local xray  = math.cos(player.begin +i *ray .subsequent /7) *20
    local yray  = math.sin(player.begin +i *ray .subsequent /7) *20

    gra .line( minimapX, minimapY,  minimapX +xray, minimapY +yray )
  end -- fov

  gra .setColor( 255, 255, 255 )
  gra .points( minimapX,  minimapY )

  -- debug info
  gra .setColor( 255, 0, 0 )
  gra .print( player.dir ..'\n' ..player.x ..'\n' ..player.y, pad, pad )

end -- Lo .draw()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
