ray  = {} -- namespace

ray .dist  = {}
ray .wall  = {}
ray .color  = {}

ray .maxSteps  = 12  -- max view distance
ray .cameraPlane  = w5 /math.tan( halfFOV )

--[[

   //======  90  =====##
   ||        .        ||
   ||        |        ||
   ||   II   |   I    ||
             |
  180  ~~~~~~+~~~~~~  0
             |
   ||  III   |  IV    ||
   ||        |        ||
   ||        '        ||
   ##=====  270  =====//


Rays in quadrant I  approaching Horiz wall:  (1.25, 1.25)  ~  (1.25, 1)  floor y
Rays in quadrant I  approaching Vert wall:  (1.25, 1.25)  ~  (1, 1.25)  floor x

Rays in quadrant II  approaching Horiz wall:  (-1.25, 1.25)   ~  (-1.25, 1)  floor y
Rays in quadrant II  approaching Vert wall:  (-1.25, 1.25)   ~  (-1, 1.25)  floor x

Rays in quadrant III  approaching Horiz wall:  (-1.25, -1.25)  ~  (-1.25, -1)  floor y
Rays in quadrant III  approaching Vert wall:  (-1.25, -1.25)  ~  (-1, -1.25)  floor x

Rays in quadrant IV  approaching Horiz wall:  (1.25, -1.25)   ~  (1.25, -1)  floor y
Rays in quadrant IV  approaching Vert wall:  (1.25, -1.25)   ~  (1, -1.25)  floor x

]]--

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function ray :cast()

  local maps  = require 'data.maps'
  local map  = maps[ level ]

  -- Adding 1 here, so we can read Y-axis bottom-up, instead of top-down.
  local yPlus1  = map.y +1 -- Otherwise, subtracting position, you'd reach 0...
  -- which would be out of bounds for map data, 'cuz lists start from 1.

  local normX  = player.x %1  -- player pos, normalized to one grid space
  local normY  = player.y %1
  local invX  = 1 -normX      -- inverted value
  local invY  = 1 -normY

  for i = 1, FOV do -- fan out from left to right  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    local angle  = player.begin +math.rad(i)  -- start @ left of screen, increment i

    if angle < halfpi then       -- quad I  = positive rise,  positive run
      hRise  = invY
      hRiseInit  = normY
      hRun  = math.tan( angle )
      hRunInit  = hRun *invY

      vRise  = math.tan( angle )
      vRiseInit  = vRise *invX
      vRun  = 1
      vRunInit  = invX

    elseif angle < math.pi then  -- quad II  = positive rise,  negative run
      hRise  = 1
      hRiseInit  = invY
      hRun  = -math.tan( angle )
      hRunInit  = hRun *invY

      vRise  = math.tan( angle )
      vRiseInit  = vRise *normX
      vRun  = -1
      vRunInit  = -normX

    elseif angle < threeqpi then  -- quad III  = negative rise,  negative run
      hRise  = -1
      hRiseInit  = -normY
      hRun  = -math.tan( angle )
      hRunInit  = hRun *normY

      vRise  = -math.tan( angle )
      vRiseInit  = vRise *normX
      vRun  = -1
      vRunInit  = -normX

    else                     -- quad IV  = negative rise,  positive run
      hRise  = -1
      hRiseInit  = -normY
      hRun  = math.tan( angle )
      hRunInit  = hRun *normY

      vRise  = -math.tan( angle )
      vRiseInit  = vRise *invX
      vRun  = 1
      vRunInit  = invX
    end

    local horizX  = player.x
    local horizY  = player.y
    local vertX  = player.x
    local vertY  = player.y

    local step  = 0
    local collide  = false --======================================================================

    while collide == false and step < ray .maxSteps do

      if     horizX < 1 or horizX > map .x then -- horiz bounds
        ray .color[i]  = { 0,0,0 }
        collide  = true

      elseif horizY < 1 or horizY > map .y then
        ray .color[i]  = { 100,0,0 }
        collide  = true

      elseif vertX < 1 or vertX > map .x then -- vert bounds
        ray .color[i]  = { 0,100,0 }
        collide  = true

      elseif vertY < 1 or vertY > map .y then
        ray .color[i]  = { 0,0,100 }
        collide  = true

      else  -- not out of bounds, test for collisions

        floorHx  = math.floor(horizX)
        floorHy  = math.floor(horizY)
        floorVx  = math.floor(vertX)
        floorVy  = math.floor(vertY)

        -- print('H: ' ..floorHx ..'  ' ..floorHy)
        -- print('V: ' ..floorVx ..'  ' ..floorVy)

        -- subtracting y from yPlus1 is so that it reads map data bottom-up.

        if map .data[ yPlus1 -floorHy ][ floorHx ] > 0 then
          ray .color[i]  = { 255,200,200 }
          collide  = true

        elseif map .data[ yPlus1 -floorVy ][ floorVx ] > 0 then
          ray .color[i]  = { 200,200,255 }
          collide  = true
        end -- collision test

        -- if no collisions found, take another step

        horizX  = horizX +hRun
        horizY  = horizY +hRise

        vertX  = vertX +vRun
        vertY  = vertY +vRise
        step  = step +1
      end -- tests

    end -- while collide == false =================================================================

    horizDist  = math.sqrt(floorHx *floorHx  +  floorHy *floorHy)
     -- pythagorus:  A squared + B squared = C squared
    vertDist  = math.sqrt(floorVx *floorVx  +  floorVy *floorVy)

    if horizDist < vertDist then
      ray .dist[i]  = horizDist *math.cos( angle ) -- cos of angle corrects for barrel distortion
    else
      ray .dist[i]  = vertDist *math.cos( angle )
    end -- compare horiz to vert distance, and pick the shorter of the two

      ray .wall[i]  = h5 /ray .dist[i] *ray .cameraPlane -- calculate projected wall height

  end -- FOV loop, fanning out from left to right
end -- ray :cast()

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

return ray
