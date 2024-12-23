#include "constants.agc"
#include "main.agc"
// File: 5land2.agc
// Created: 24-10-03

#constant land2Distance 20000

#constant land2heroY 300

// Upgrade variables
global land2nLanes = 2  // current number of lanes unlocked
global land2maxLanes = 5  // maximum possible number of lanes
global land2baseSpeed# = 0  // non-boosted speed
global land2boostSpeed# = 0  // boosted speed
global land2boostSpawnRate# = 0  // rate at which boost panels spawn?

// hero movement
global land2heroSpeed# = 1  // current hero speed, including boosts/slowdowns
global land2heroSpeedMax# = 1  // max hero speed without boosts/slowdowns
global land2heroIFrames# = 0  // hero invincibility frames after hitting an obstacle
global land2heroIFramesMax = 120
global land2currentLane = 2  // current lane, 1 = leftmost lane
global land2laneChangeFrame = 0  // frames remaining in lane change, max 5
global land2laneChangeDirection = 0  // -1 -> left, 1 -> right

function LoadSpriteFromSpawnable(spr as spawn, imagePath as string, depth as integer)
    // load a sprite from a spawnable's properties
    LoadSpriteExpress(spr.spr, imagePath, spr.size, spr.size, spr.x, spr.y, depth)
endfunction

function LaneToX(lane as integer)
    // calculate the current x-coordinate from a lane number at the hero y-coordinate
    x# = LaneToXWithOffset(lane, land2heroY)
endfunction x#

function LaneToXWithOffset(lane as integer, yOffset as float)
    // calculate the current x-coordinate from a lane number and y-coordinate
endfunction (yoffset * 4.0 / 3) + 100 * (lane - 1)

function InitObstacles()
    // load spawnable obstacles (cars and cones)
    sprID = land2sprCones
    for i = 0 to 39
        sprCone as spawn
        sprCone.spr = sprID
        sprCone.cat = BAD
        sprCone.x = Random(1, 5)  // lane number
        sprCone.y = 75 * i + Random(0, 80) - 40
        sprCone.size = 30
        LoadSpriteFromSpawnable(sprCone, "cone.png", 10)
        spawnActive.insert(sprCone)
        inc sprID, 1
    next i
endfunction

function InitBoostPanels()
    // load spawnable boost panels
    // panels come in runs of 4-7, and shift left or right one lane at a time
    // panels can spawn in all 5 lanes before the player unlocks more lanes,
    // which is the incentive for that upgrade
    sprBoostID = land2sprBoostPanels
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
            LoadSpriteFromSpawnable(sprBoost, "buoy2.png", 10)
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
    for lane = 0 to land2maxLanes - 1
        sprLane = land2sprStreet + lane
        LoadAnimatedSprite(sprLane, "cbg/onelanegrey/c1", 40)
        SetSpriteSize(sprLane, 1200, 820)
        SetSpritePosition(sprLane, -80 + 100 * lane, 0)
        // gray out unavailable lanes
        if lane < land2nLanes
            SetSpriteColor(sprLane, 180, 120, 190, 255)
        else
            SetSpriteColor(sprLane, 50, 50, 50, 255)
        endif
        PlaySprite(sprLane, 60 * land2heroSpeed#)
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
    InitObstacles()

endfunction

function DoSpawnables()
    // process movement for all spawnables (boosts, obstacles)
    for i = 0 to spawnActive.length - 1
        inc spawnActive[i].y, -4 * land2heroSpeed#
        if spawnActive[i].cat = BAD 
            // check for collisions
            if GetSpriteCollision(spawnActive[i].spr, hero) and land2HeroIFrames# = 0
                land2HeroIFrames# = land2heroIFramesMax
                PlaySound(hitS, volumeS)
            endif
            // recycle obstacle spawnables once they scroll offscreen
            if spawnActive[i].y < -100
                spawnActive[i].x = Random(1, 5)
                inc spawnActive[i].y, 3000
            endif
        endif
        SetSpritePosition(spawnActive[i].spr, LaneToXWithOffset(spawnActive[i].x, spawnActive[i].y), spawnActive[i].y)
    next i
endfunction

function DoLand2()

    // scroll buildings
    // once a building passes the top of the screen, reset its position to below the screen
    for i = 0 to 2
        IncSpritePosition(land2sprBuildings + i, -4.75 * land2heroSpeed#, -4.75 * 0.75 * land2heroSpeed#)
        if GetSpriteY(land2sprBuildings + i) < -3 * h
            SetSpritePosition(land2sprBuildings + i, 200 + 2*w, 2.0 / 3 * h)
        endif
    next i

    // hero inputs
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
    
    // hero movement
    if land2heroIFrames# > 0
        inc land2heroIFrames#, -1
        land2heroSpeed# = land2heroSpeedMax# - 0.5 * (land2heroIFrames# / land2heroIFramesMax)
        // slow down lanes to match hero slowdown
        for lane = 0 to land2maxLanes - 1
            SetSpriteSpeed(land2sprStreet + lane, 60 * land2heroSpeed#)
        next lane
    endif
    SetSpriteColor(hero, 255, 255 - 2*land2heroIFrames#, 255 - 2*land2heroIFrames#, 255)
    SetSpritePosition(hero, LaneToX(land2currentLane) - 9 * land2laneChangeDirection * land2laneChangeFrame, 300)
    inc heroLocalDistance#, -1 * land2heroSpeed#

    DoSpawnables()

endfunction
