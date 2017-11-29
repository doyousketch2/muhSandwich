--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

local track  = ''
local mus  = false
local bgmdir  = fil .getDirectoryItems( 'data/music/' )

local ray  = require 'libs.ray'
local enemy  = require 'libs.enemy'
local e  = {} -- list of enemies

local mouseSensitivity  = 0.001
local lineWid  = WW /FOV
local halfLine  = lineWid /2

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

  for d = 1, FOV do
    ray .dist[#ray .dist +1]  = 0
    ray .wall[#ray .wall +1]  = 0
    ray .color[#ray .color +1]  = 0
  end

  mou .setRelativeMode( true )
  mou .setGrabbed( true )

  if mus then
    newSong()  -- begin music
  end -- if mus
end -- load()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .keypressed( key, scancode, isrepeat )
  if scancode == 'escape'  then  eve .quit()  end

  if key == 'tab' then  -- toggle opposite
    local state  = not mou .isGrabbed()
    mou .setRelativeMode( state )
    mou .setGrabbed( state )
  end
end -- Lo .keypressed

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .keyreleased( key, scancode )

  if scancode == 'end' then -- skip to the next song
    bgm :stop()
  end -- if scancode

end -- Lo .keyreleased

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .mousemoved( x, y, dx, dy, istouch )
  player.rad  = player.rad +dx *mouseSensitivity
  
  player.cos  = math.cos( player.rad )
  player.sin  = math.sin( player.rad )
  player.dir  = math.deg( player.rad )

  if player.dir < 0   then player.dir  = 360 +player.dir end
  if player.dir >= 360 then player.dir  = player.dir -360 end

  player.begin  = player.rad -halfFOV
  -- minus 1, because lists are 1-based.  Better here, than 90 times in FOV loop

  if player.begin < 0 then player.begin  = 360 +player.begin end
  if player.begin >= 360 then player.begin  = player.begin -360 end

end

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Lo .update( dt ) -- DeltaTime  = time since last update,  in seconds.
  require('libs.debug.lovebird') .update() -- to view =  http://127.0.0.1:8000

  timer  = timer +dt
  desiredX  = player.x
  desiredY  = player.y

  if key .isDown( 'w' ) then
    desiredX  = desiredX +player.cos *player.speed
    desiredY  = desiredY +player.sin *player.speed
  end -- if key 'w'

  if key .isDown( 'a' ) then
    desiredX  = desiredX +player.sin *player.speed
    desiredY  = desiredY -player.cos *player.speed
  end -- if key 'a'

  if key .isDown( 's' ) then
    desiredX  = desiredX -player.cos *player.speed
    desiredY  = desiredY -player.sin *player.speed
  end -- if key 's'

  if key .isDown( 'd' ) then
    desiredX  = desiredX -player.sin *player.speed
    desiredY  = desiredY +player.cos *player.speed
  end -- if key 'd'

  if desiredX >= 1 
    and desiredX < map .x 
    and map .data[ math.floor( player.y ) ][ math.floor( player.x ) ]
    then player .x  = desiredX 
  end

  if desiredY >= 1 
    and desiredY < map .y 
    and map .data[ math.floor( player.y ) ][ math.floor( player.x ) ]
    then player .y  = desiredY 
  end

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

  for i = 1, FOV do -- each sliver is a vertical slice of the screen
    local sliver  = i *lineWid -halfLine
    gra .setColor( ray .color[i] )
    gra .line( sliver,  h5 -ray .wall[i],  sliver,  h5 +ray .wall[i] )
  end -- FOV

  -- Minimap ~~~~~~~~~~~~~~~~~~~~~~~~~~

  -- bounds of map
  gra .setColor( 180, 20, 20 )
  gra .rectangle( 'fill',  w8 +half,  h1 +half,  map .x *mapScale,  map .y *mapScale )

  -- map walls
  gra .setColor( 0, 0, 100 )
  for x = 1,  map .x do
    for y = 1,  map .y do
      if map .data[y][x] > 0 then
        gra .points( w8 +x *mapScale,  h1 +y *mapScale )
      end -- if wall
    end -- x
  end -- print map

  -- rays
  gra .setLineWidth( 1 )
  local miniX  = w8 +player .x *mapScale
  local miniY  = h1 +player .y *mapScale

  for i = 1, FOV do
    local angle  = player.begin +math.rad(i)

    gra .setColor( 50, 30 +i *2.5, 50 )
    local xray  = math.cos( angle ) *ray .dist[i] *mapScale
    local yray  = math.sin( angle ) *ray .dist[i] *mapScale

    gra .line( miniX,  miniY,  miniX +xray,  miniY +yray )

  end -- FOV

  -- player
  gra .setColor( 255, 255, 255 )
  gra .points( miniX,  miniY )

  -- debug info ~~~~~~~~~~~~~~~~~~~~~~~

  gra .setColor( 255, 0, 0 )
  gra .print( ' Dir: ' ..player.dir ..'\n'
            ..'  X: ' ..player.x ..'\n'
            ..'  Y: ' ..player.y,   pad,  pad )

end -- Lo .draw()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
