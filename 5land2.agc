#include "constants.agc"
#include "main.agc"
// File: 5land2.agc
// Created: 24-10-03

#constant land2Distance 20000

#constant land2heroY 300

// upgrade attribute identifiers
#constant attrnLanes 1
#constant attrBaseSpeed 2
#constant attrBoostFrames 3
#constant attrBoostGroupLength 4

// Upgrade variables
global land2nLanes = 0  // current number of lanes unlocked
global land2maxLanes = 5  // maximum possible number of lanes
global land2baseSpeed# = 0  // non-boosted speed
global land2boostSpeed# = 0  // boosted speed
global land2boostGroupLength = 0  // rate at which boost panels spawn?

// hero movement
global land2heroSpeed# = 1  // current hero speed, including boosts/slowdowns
global land2heroSpeedMax# = 1  // max hero speed without boosts/slowdowns
global land2heroIFrames# = 0  // hero invincibility frames after hitting an obstacle
global land2heroIFramesMax = 120
global land2heroBoostCharges# = 0
global land2heroBoostChargesMax = 10
global land2heroBoostFrames# = 0  // current remaining frames of boost
global land2heroBoostFramesMax = 60
global land2currentLane = 2  // current lane, 1 = leftmost lane
global land2laneChangeFrame = 0  // frames remaining in lane change, max 5
global land2laneChangeDirection = 0  // -1 -> left, 1 -> right

// background movement
global land2baseLaneSpeed = 52
global land2buildingXOffset = 0  // set in the init script

function InitUpgradeValues()
    // assign values to upgradeable attributes based on purchased levels 
    land2nLanes = 2 + upgrades[attrnLanes, LAND2]
    land2heroSpeedMax# = 1.25 + 0.25 * upgrades[attrnLanes, LAND2]
    land2heroBoostFramesMax = 60 + 30 * upgrades[attrBoostFrames, LAND2]
    land2boostGroupLength = 5 + upgrades[attrBoostGroupLength, LAND2] + 2 * (upgrades[attrBoostGroupLength, LAND2] / 2)

    land2heroSpeed# = land2heroSpeedMax#

endfunction

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
endfunction 105 + (yoffset * 4.0 / 3) + 100 * (lane - 1)

function LaneToXWithOffsetBoost(lane as integer, yOffset as float)
    // calculate the current x-coordinate from a lane number, specific to boost panels
endfunction 45 + (yoffset * 4.0 / 3) + 100 * (lane - 1)

function SetObstacleLane(obstacle as spawn)
    // given a obstacle's y-coordinate, assign it a lane such that
    // it isn't overlapping with a boost panel
    hitUpper = land2sprBoostPanels
    hitLower = land2sprBoostPanels
    while ((land2sprBoostPanels <= hitUpper and hitUpper < land2sprBoostPanels + 200) or (land2sprBoostPanels <= hitLower and hitLower < land2sprBoostPanels + 200))
        x = Random2(1, land2maxLanes)
        // "hide" any sprites that spawn outside of unlocked lanes
        // todo - we might want a more precise way of checking for overlaps between
        //      obstacles and boost panels. the random check is janky and not performant 
        if x > land2nLanes
            SetSpriteVisible(obstacle.spr, 0)
        else
            SetSpriteVisible(obstacle.spr, 1)
        endif
        SetSpritePosition(obstacle.spr, LaneToXWithOffset(x, obstacle.y), obstacle.y)
        // check upper and lower corners
        hitUpper = GetSpriteHit(GetSpriteX(obstacle.spr), GetSpriteY(obstacle.spr))
        hitLower = GetSpriteHit(GetSpriteX(obstacle.spr) + obstacle.size, GetSpriteY(obstacle.spr) + obstacle.size)
    endwhile
endfunction x

function InitObstacles()
    // load spawnable obstacles (cars and cones)
    sprID = land2sprCones
    for i = 0 to 19
        sprCone as spawn
        sprCone.spr = sprID
        sprCone.cat = BAD
        sprCone.size = 40
        LoadSpriteFromSpawnable(sprCone, "cone.png", 10) 
        sprCone.y = 600 + 180 * i + Random2(0, 100)
        sprCone.x = SetObstacleLane(sprCone)
        spawnActive.insert(sprCone)
        inc sprID, 1
    next i
endfunction

function InitBoostPanels()
    // load spawnable boost panels
    // panels come in runs and shift left or right one lane at a time
    // panels spawn less often until the player unlocks more lanes,
    // which is the incentive for that upgrade
    sprBoostID = land2sprBoostPanels
    nBoostStrings = 24 / (6 - land2nLanes)
    for i = 0 to nBoostStrings
        panelX = Random2(1, land2nLanes)  // x coordinate -> which lane boost spawns in
        panelY# = (i / (1.0 * nBoostStrings)) * land2Distance + Random2(500, 750)  // race distance
        for panel = 0 to land2boostGroupLength - 1
            // set panel properties
            sprBoost as spawn
            sprBoost.spr = sprBoostID
            sprBoost.cat = GOOD
            sprBoost.x = panelX
            sprBoost.y = panelY#
            sprBoost.size = 180
            // todo - write something like LoadAnimatedSpriteFromSpawnable?
            LoadAnimatedSprite(sprBoost.spr, "land2booster", 18)
            SetSpriteSize(sprBoost.spr, sprBoost.size, sprBoost.size * 0.4)
            SetSpritePosition(sprBoost.spr, sprBoost.x, sprBoost.y)
            SetSpriteDepth(sprBoost.spr, 10)
            PlaySprite(sprBoost.spr, 30)
            spawnActive.insert(sprBoost)
            // set the panel's underlying sprite's position.
            // we need to do this so we can check for overlaps when spawning
            // obstacles in the "SetObstacleLane" function.
            // this will also be done each frame in the game loop
            SetSpritePosition(sprBoost.spr, LaneToXWithOffset(sprBoost.x, sprBoost.y), sprBoost.y)
            // prepare the next panel's properties
            // when shifting the next panel left or right, give it a greater probability
            // of turning out of the leftmost and rightmost lanes
            inc sprBoostID, 1
            if panelX = 1
                inc panelX, Random2(0, 1)
            elseif panelX = land2nLanes
                inc panelX, Random2(-1, 0)
            else
                inc panelX, Random2(-1, 1)
            endif
            inc panelY#, 80
        next panel
    next i
endfunction

function InitLand2()

    // apply upgrade values
    InitUpgradeValues()
	
    // load building sprites
    // building positioning depends on how many lanes are unlocked
    land2buildingXOffset = -105 + 55 * land2nLanes
    for i = 0 to 2
        LoadSpriteExpress(land2sprBuildings + i, "cbg/citytop1010.png", w, 3*h, land2buildingXOffset + w*i, (-2 + 4.0 / 3 * i) * h, 99)
    next i

    streetDir$ = "cbg/lanes" + str(land2nLanes) + "/c" + str(land2nLanes)
    LoadAnimatedSprite(land2sprStreet, streetDir$, 40)
    SetSpriteSize(land2sprStreet, 1435, 820)
    SetSpritePosition(land2sprStreet, 0, 0)
    PlaySprite(land2sprStreet, land2baseLaneSpeed * land2heroSpeed#)

    // load boost meter
    // for now, just a basic rectangle that stretches with additional boosts
    CreateSpriteExpress(land2sprBoostMeter, 0, 30, 100, 600, 10)
    SetSpriteColor(land2sprBoostMeter, 255, 0, 0, 255)

    // load hero sprite
    LoadAnimatedSprite(hero, "duckc", 3)
    SetSpriteSize(hero, 40, 40)
    SetSpritePosition(hero, 500, land2heroY)
    SetSpriteDepth(hero, 1)
    PlaySprite(hero, 10)
    heroLocalDistance# = land2Distance

    // create "spawnables" (boosts/obstacles)
    spawnActive.length = -1
    InitBoostPanels()
    InitObstacles()

endfunction

function DoSpawnables()
    // process movement for all spawnables (boosts, obstacles)
    idx_to_delete = -1
    for i = 0 to spawnActive.length - 1
        inc spawnActive[i].y, -3.5 * land2heroSpeed#
        if spawnActive[i].cat = GOOD
            // check for collecting a boost
            if GetSpriteCollision(spawnActive[i].spr, hero) and spawnActive[i].x = land2currentLane
                idx_to_delete = i
                land2heroBoostCharges# = min(land2heroBoostCharges# + 1, land2heroBoostChargesMax)
                SetSpriteSize(land2sprBoostMeter, 20 * land2heroBoostCharges#, 20)
                if land2heroBoostCharges# = land2heroBoostChargesMax
                    SetSpriteColor(land2sprBoostMeter, 255, 215, 0, 255)
                elseif land2heroBoostCharges# >= 5
                    SetSpriteColor(land2sprBoostMeter, 0, 255, 0, 255)
                endif
                PlaySound(boostChargeS, volumeS/4)
            endif
            SetSpritePosition(spawnActive[i].spr, LaneToXWithOffsetBoost(spawnActive[i].x, spawnActive[i].y), spawnActive[i].y)
        elseif spawnActive[i].cat = BAD 
            // check for collisions
            if GetSpriteCollision(spawnActive[i].spr, hero) and land2HeroIFrames# = 0
                land2HeroIFrames# = land2heroIFramesMax
                PlaySound(hitS, volumeS)
            endif
            // recycle obstacle spawnables once they scroll offscreen
            if spawnActive[i].y < -100
                inc spawnActive[i].y, 3600
                spawnActive[i].x = SetObstacleLane(spawnActive[i])
            endif
            SetSpritePosition(spawnActive[i].spr, LaneToXWithOffset(spawnActive[i].x, spawnActive[i].y), spawnActive[i].y)
        endif
    next i
    // delete any collected boosts
    if idx_to_delete <> -1
        DeleteSprite(spawnActive[idx_to_delete].spr)
        spawnActive.remove(idx_to_delete)
    endif
endfunction

function DoLand2()

    // scroll buildings
    // once a building passes the top of the screen, reset its position to below the screen
    for i = 0 to 2
        IncSpritePosition(land2sprBuildings + i, -4.75 * land2heroSpeed#, -4.75 * 0.75 * land2heroSpeed#)
        if GetSpriteY(land2sprBuildings + i) < -3 * h
            SetSpritePosition(land2sprBuildings + i, land2buildingXOffset + 2*w, 2.0 / 3 * h)
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
    // use boost once meter with at least 5 charges held
    // boost time is proportionate to the number of charges held
    // if the boost meter is full (10 charges), the boost is extra long
    elseif stateSpace and land2heroBoostCharges# >= 5
        if land2heroBoostCharges# = land2heroBoostChargesMax
            land2heroBoostFrames# = land2heroBoostFramesMax * 1.5
        else
            land2heroBoostFrames# = land2heroBoostFramesMax * (land2heroBoostCharges# / land2heroBoostChargesMax)
        endif
        land2heroBoostCharges# = 0
        SetSpriteSize(land2sprBoostMeter, 0, 20)
        SetSpriteColor(land2sprBoostMeter, 255, 0, 0, 255)
        PlaySound(boostS)
    endif
    if land2laneChangeFrame
        inc land2laneChangeFrame, -1
    endif
    
    // hero movement
    if land2heroIFrames# > 0 or land2heroBoostFrames# > 0
        land2heroIFrames# = max(0, land2heroIFrames# - 1)
        land2heroBoostFrames# = max(0, land2heroBoostFrames# - 1)
        land2heroSpeed# = land2heroSpeedMax# - 0.5 * (land2heroIFrames# / land2heroIFramesMax) + 1.5 * (land2heroBoostFrames# / land2heroBoostFramesMax)
        // slow down lanes to match hero slowdown
        SetSpriteSpeed(land2sprStreet, land2baseLaneSpeed * land2heroSpeed#)
    endif
    SetSpriteColor(hero, 255, 255 - 2*land2heroIFrames#, 255 - 2*land2heroIFrames#, 255)
    SetSpritePosition(hero, LaneToX(land2currentLane) - 9 * land2laneChangeDirection * land2laneChangeFrame, 300)
    inc heroLocalDistance#, -1 * land2heroSpeed#

    DoSpawnables()

endfunction
