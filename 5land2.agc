#include "constants.agc"
#include "main.agc"
// File: 5land2.agc
// Created: 24-10-03

#constant land2Distance 20000

// Upgrade variables
global land2nLanes = 5  // number of lanes
global land2baseSpeed# = 0  // non-boosted speed
global land2boostSpeed# = 0  // boosted speed
global land2boostSpawnRate# = 0  // rate at which boost panels spawn?

// hero movement
global land2heroSpeed# = 1  // pixels per frame of speed
global land2currentLane = 2  // current lane, 1 = leftmost lane
global land2laneChangeFrame = 0  // frames remaining in lane change, max 10
global land2laneChangeDirection = 0  // -1 -> left, 1 -> right

function InitLand2()
	
    // load building sprites
    imgBuildings = LoadImage("cbg/citytop1010.png")
    for i = 0 to 2
        CreateSpriteExpressImage(land2sprBuildings + i, imgbuildings, w, 3*h, 200 + w*i, (-2 + 4.0 / 3 * i) * h, 99)
    next i
    
    // load street sprite
    LoadAnimatedSprite(land2sprStreet, "cbg/fivelane/c5", 40)
    SetSpriteSize(land2sprStreet, w, h)
    PlaySprite(land2sprStreet, 60)

    // load hero sprite
    LoadAnimatedSprite(hero, "duckl", 2)
    SetSpriteSize(hero, 70, 70)
    SetSpritePosition(hero, 500, 300)
    PlaySprite(hero, 10)

    heroLocalDistance# = land2Distance

endfunction

function DoLand2()

    // scroll buildings
    // once a building passes the top of the screen, reset its position to below the screen
    for i = 0 to 2
        IncSpritePosition(land2sprBuildings + i, -4.75, -4.75 * 0.75)
        if GetSpriteY(land2sprBuildings + i) < -3 * h
            SetSpritePosition(land2sprBuildings + i, 200 + 2*w, 2.0 / 3 * h)
        endif
    next i

    // hero movement
    DoInputs()
    // start turning left
    if inputLeft and land2laneChangeFrame = 0 and land2currentLane > 1
        land2currentLane = max(1, land2currentLane - 1)
        land2laneChangeFrame = 10
        land2laneChangeDirection = -1
    // start turning right
    elseif inputRight and land2laneChangeFrame = 0 and land2currentLane < land2nLanes
        land2currentLane = min(land2nLanes, land2currentLane + 1)
        land2laneChangeFrame = 10
        land2laneChangeDirection = 1
    endif
    if land2laneChangeFrame
        inc land2laneChangeFrame, -1
    endif

    SetSpritePosition(hero, 310 + 90 * land2currentLane - 9 * land2laneChangeDirection * land2laneChangeFrame, 300)
    inc heroLocalDistance#, -1 * land2heroSpeed#

endfunction
