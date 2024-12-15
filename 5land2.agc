#include "constants.agc"
#include "main.agc"
// File: 5land2.agc
// Created: 24-10-03

#constant land2Distance 20000

// Upgrade variables
global land2nLanes = 2  // number of lanes
global land2baseSpeed# = 0  // non-boosted speed
global land2boostSpeed# = 0  // boosted speed
global land2boostSpawnRate# = 0  // rate at which boost panels spawn?

global land2heroSpeed# = 1  // pixels per frame of speed

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
    inc heroLocalDistance#, -1 * land2heroSpeed#

endfunction
