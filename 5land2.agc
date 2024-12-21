#include "constants.agc"
#include "main.agc"
// File: 5land2.agc
// Created: 24-10-03

#constant land2Distance 20000

#constant land2heroY 300

// Upgrade variables
global land2nLanes = 5  // number of lanes
global land2baseSpeed# = 0  // non-boosted speed
global land2boostSpeed# = 0  // boosted speed
global land2boostSpawnRate# = 0  // rate at which boost panels spawn?

// hero movement
global land2heroSpeed# = 1  // pixels per frame of speed
global land2currentLane = 2  // current lane, 1 = leftmost lane
global land2laneChangeFrame = 0  // frames remaining in lane change, max 5
global land2laneChangeDirection = 0  // -1 -> left, 1 -> right

function LaneToX(lane as integer)
    // calculate the current x-coordinate from a lane number at the hero y-coordinate
    x# = LaneToXWithOffset(lane, land2heroY)
endfunction x#

function LaneToXWithOffset(lane as integer, yOffset as float)
    // calculate the current x-coordinate from a lane number and y-coordinate
endfunction (yoffset * 4.0 / 3) + 100 * (lane - 1)

function InitBoostPanels()
    // load spawnable boost panels
    // panels come in runs of 4-7, and shift left or right one lane at a time
    // panels can spawn in all 5 lanes before the player unlocks more lanes,
    // which is the incentive for that upgrade
    sprBoostID = spawnStartS
    for i = 0 to 9
        panelX = Random(1, 5)  // x coordinate -> which lane boost spawns in
        panelY# = (i / 10.0) * land2Distance + Random(500, 1000)  // race distance
        for panel = 0 to 9
            // set panel properties
            sprBoost as spawn
            sprBoost.spr = sprBoostID
            sprBoost.cat = GOOD
            sprBoost.x = panelX
            sprBoost.y = panelY#
            sprBoost.size = 50
            LoadSpriteExpress(sprBoost.spr, "buoy2.png", sprBoost.size, sprBoost.size, sprBoost.x, sprBoost.y, 10)
            spawnActive.insert(sprBoost)
            // prepare the next panel's properties
            // when shifting the next panel left or right, give it a greater probability
            // of turning out of the leftmost and rightmost lanes
            inc sprBoostID, 1
            if panelX = 1
                inc panelX, Random(0, 1)
            elseif panelX = land2nLanes
                inc panelX, -1 * Random(0, 1)
            else
                inc panelX, Random(0, 2) - 1
            endif
            inc panelY#, 80
        next panel
    next i
endfunction

function InitLand2()
	
    // load building sprites
    imgBuildings = LoadImage("cbg/citytop1010.png")
    for i = 0 to 2
        CreateSpriteExpressImage(land2sprBuildings + i, imgbuildings, w, 3*h, 200 + w*i, (-2 + 4.0 / 3 * i) * h, 99)
    next i
    
    // load street sprites
    for lane = 0 to 4
        sprLane = land2sprStreet + lane
        LoadAnimatedSprite(sprLane, "cbg/onelanegrey/c1", 40)
        SetSpriteSize(sprLane, 1200, 820)
        SetSpritePosition(sprLane, -80 + 100 * lane, 0)
        SetSpriteColor(sprLane, 180, 120, 190, 255)
        PlaySprite(sprLane, 60)
        if mod(lane, 2) = 0
            SetSpriteFrame(sprLane, 1)
        else
            SetSpriteFrame(sprLane, 21)
        endif
    next lane

    // load hero sprite
    LoadAnimatedSprite(hero, "duckl", 2)
    SetSpriteSize(hero, 50, 50)
    SetSpritePosition(hero, 500, land2heroY)
    PlaySprite(hero, 10)
    heroLocalDistance# = land2Distance

    // create "spawnables" (boosts/obstacles)
    spawnActive.length = -1
    InitBoostPanels()

endfunction

function DoSpawnables()
    // process movement for all spawnables (boosts, obstacles)
    for i = 0 to spawnActive.length - 1
        inc spawnActive[i].y, -4
        SetSpritePosition(spawnActive[i].spr, LaneToXWithOffset(spawnActive[i].x, spawnActive[i].y), spawnActive[i].y)
    next i
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
        land2laneChangeFrame = 5
        land2laneChangeDirection = -1
    // start turning right
    elseif inputRight and land2laneChangeFrame = 0 and land2currentLane < land2nLanes
        land2currentLane = min(land2nLanes, land2currentLane + 1)
        land2laneChangeFrame = 5
        land2laneChangeDirection = 1
    endif
    if land2laneChangeFrame
        inc land2laneChangeFrame, -1
    endif
    SetSpritePosition(hero, LaneToX(land2currentLane) - 9 * land2laneChangeDirection * land2laneChangeFrame, 300)
    inc heroLocalDistance#, -1 * land2heroSpeed#

    DoSpawnables()

endfunction
