#include "constants.agc"
#include "main.agc"
// File: 5land2.agc
// Created: 24-10-03

#constant land2Distance 20000

#constant land2heroY 200

// upgrade attribute identifiers
#constant attrnLanes 1
#constant attrBaseSpeed 2
#constant attrBoostFrames 3
#constant attrBoostGroupLength 4

#constant laneWid 88

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
global land2heroBoostFramesMax# = 1//60
global land2TriggerBoost = 0
global land2currentLane = 2  // current lane, 1 = leftmost lane
global land2laneChangeFrame = 0  // frames remaining in lane change, max 5
global land2laneChangeDirection = 0  // -1 -> left, 1 -> right
global land2boostScalar# = 7.5
global land2BehindCar = 0
global land2AnimSpeed = 10
//global land2DrainSpeed# =

global carListEnd = 0

// background movement
global land2baseLaneSpeed = 52
global land2buildingXOffset = 0  // set in the init script
global land2scrollScalar# = 0.1  // background scroll speed, relative to hero speed

//~function InitUpgradeValues()
    //~// assign values to upgradeable attributes based on purchased levels 
    //~land2nLanes = 5//2 + upgrades[attrnLanes, LAND2]
    //~land2heroSpeedMax# = 6 + 3 * upgrades[attrBaseSpeed, LAND2]
    //~land2AnimSpeed = 10 + 3 * upgrades[attrBaseSpeed, LAND2]
    //~land2heroBoostFramesMax = 60 + 30 * upgrades[attrBoostFrames, LAND2]
    //~land2boostGroupLength = 5 + upgrades[attrBoostGroupLength, LAND2] + 2 * (upgrades[attrBoostGroupLength, LAND2] / 2)

    //~land2heroSpeed# = land2heroSpeedMax#

//~endfunction

//~function LoadSpriteFromSpawnable(spr as spawn, imagePath as string, depth as integer)
    //~// load a sprite from a spawnable's properties
    //~LoadSpriteExpress(spr.spr, imagePath, spr.size, spr.size, spr.x, spr.y, depth)
//~endfunction

function LaneToX(lane as integer)
    // calculate the current x-coordinate from a lane number at the hero y-coordinate
    x# = LaneToXWithOffset(lane, land2heroY)
endfunction x#

function LaneToXWithOffset(lane as integer, yOffset as float)
    // calculate the current x-coordinate from a lane number and y-coordinate
endfunction -80 + (yoffset * 3.0 / 2) + laneWid * (5 - lane - 1)
//endfunction 105 + (yoffset * 4.0 / 3) + 100 * (lane - 1)

function LaneToXWithOffsetCar(lane as integer, yOffset as float)
    // calculate the current x-coordinate from a lane number and y-coordinate
endfunction -10 + (yoffset * 3.0 / 2) + laneWid * (5 - lane - 1)

function LaneToXWithOffsetBoost(lane as integer, yOffset as float)
    // calculate the current x-coordinate from a lane number, specific to boost panels
endfunction -155 + (yoffset * 3.0 / 2) + laneWid * (5- lane - 1)
//endfunction 45 + (yoffset * 4.0 / 3) + 100 * (lane - 1)

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
    lastLane = -1
    //sprID = land2sprCones
    carListEnd = 60
    for i = 0 to carListEnd//19
        sprCone as spawn
        sprCone.spr = LoadSprite("cbg/car"+str(Random(1,5))+".png") //sprID
        sprCone.cat = BAD
        sprCone.size = 160
        // scale the offset of the first obstacle by hero speed
        sprCone.y = 600 + (300 * upgrades[attrBaseSpeed, LAND2]) + (180 * i + Random2(0, 100))
        //sprCone.x = SetObstacleLane(sprCone)
        sprCone.x = Random2(1, land2nLanes)
        if Random(1,5) <> 5
	        if sprCone.x = lastLane
				sprCone.x = 1+Mod(sprCone.x, land2nLanes)
	        endif
	        lastLane = sprCone.x
        endif
        //sprCone.x = 1
        
        SetSpriteExpress(sprCone.spr, sprCone.size, sprCone.size, sprCone.x, sprCone.y, GetSpriteDepth(hero)-1)
        SetSpriteShapeBox(sprCone.spr, 0, 0, 50, 10, 0, 0)
        spawnActive.insert(sprCone)
        //inc sprID, 1
        
    next i
endfunction

function InitBoostPanels()
    // load spawnable boost panels
    // panels come in runs and shift left or right one lane at a time
    // panels spawn less often until the player unlocks more lanes,
    // which is the incentive for that upgrade
    //sprBoostID = land2sprBoostPanels
    nBoostStrings = 72 / 4 // (6 - land2nLanes)
    for i = 0 to nBoostStrings
        panelX = Random2(1, land2nLanes)  // x coordinate -> which lane boost spawns in
        panelY# = (i / (1.0 * nBoostStrings)) * land2Distance + Random2(500, 750)  // race distance
        for panel = 0 to land2boostGroupLength - 1
            // set panel properties
            sprBoost as spawn
            //sprBoost.spr = CreateSprite(0) //sprBoostID
            sprBoost.cat = GOOD
            sprBoost.x = panelX
            sprBoost.y = panelY#
            sprBoost.size = 70
            // todo - write something like LoadAnimatedSpriteFromSpawnable?
            sprBoost.spr = CreateSprite(0)
            if panel <> land2boostGroupLength - 1
            		for j = 1 to 18
					AddSpriteAnimationFrame(sprBoost.spr, boosterI[j])
	            next j
			else
				for j = 1 to 18
					AddSpriteAnimationFrame(sprBoost.spr, boosterLastI[j])
	            next j
            	
            endif
            
            SetSpriteSize(sprBoost.spr, sprBoost.size*14/5, sprBoost.size)
            SetSpriteShapeBox(sprBoost.spr, -sprBoost.size*7/5, -sprBoost.size/2, sprBoost.size*7/5, sprBoost.size/2-15, 0, 0)
            SetSpritePosition(sprBoost.spr, sprBoost.x, sprBoost.y)
            SetSpriteDepth(sprBoost.spr, 10)
            PlaySprite(sprBoost.spr, 30)
            if panel = land2boostGroupLength - 1
            		SetSpriteGroup(sprBoost.spr, LAND2) //If a panel is the last one, then trigger the boost
            		//SetSpriteColor(sprBoost.spr, 0, 0, 255, 255)
            		//SetSpriteColor(sprBoost.spr, 255, 0, 255, 255)
            endif
            spawnActive.insert(sprBoost)
            // set the panel's underlying sprite's position.
            // we need to do this so we can check for overlaps when spawning
            // obstacles in the "SetObstacleLane" function.
            // this will also be done each frame in the game loop
            SetSpritePosition(sprBoost.spr, LaneToXWithOffset(sprBoost.x, sprBoost.y), sprBoost.y)
            // prepare the next panel's properties
            // when shifting the next panel left or right, give it a greater probability
            // of turning out of the leftmost and rightmost lanes
            //inc sprBoostID, 1
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

function InitScrap()
    // init scrap spawnables
    // scrap is distributed uniformly across all lanes
    // more lanes unlocked = more scrap spawns
    sprScrapID = land2sprScrap
    scrapRank = GetScrapRank()
    for i = 0 to 36 * land2nLanes
       // sprScrapID = land2sprScrap + i
        scrapX = Random2(1, land2nLanes)
        scrapY = 1000 + i * land2Distance / (6 * land2nLanes) + Random2(-100, 100)
        // set scrap properties
        sprScrap as spawn
        sprScrap.spr = CreateSprite(0) // = sprScrapID
        sprScrap.cat = SCRAP
        sprScrap.x = scrapX
        sprScrap.y = scrapY
        sprScrap.size = 60
        
		for j = 1 to carListEnd
			//if spawnActive[j].x = sprScrap.x and Abs(sprScrap.y-spawnActive[j].x) < 250 then sprScrap.x = 1+Mod(sprScrap.x, land2nLanes)
			if spawnActive[j].x = sprScrap.x and Abs(sprScrap.y-spawnActive[j].y) < 150 then sprScrap.y = sprScrap.y + 300
        	next j
        
        // randomize scrap sprite
        
			
        
        
        scrapType = Random2(1, 8)
        scrapImgPath$ = "scrap/scrap" + str(scrapType) + "_" + str(scrapRank) + "_"
        // final load
        SetSpriteSize(sprScrap.spr, sprScrap.size, sprScrap.size)
        SetSpritePosition(sprScrap.spr, sprScrap.x, sprScrap.y)
        SetSpriteDepth(sprScrap.spr, 10)
        
        scrapSet = GetScrapRank()
			rnd = Random(1,8)
			for j = 1 to 4
				AddSpriteAnimationFrame(sprScrap.spr, scrapImgs[rnd, scrapSet, j])//First index will be a random
			next j
        PlaySprite(sprScrap.spr, 3+Random(1,3))
        spawnActive.insert(sprScrap)
        
		
        
        
    next i
endfunction

function InitLand2()

    // apply upgrade values
    // assign values to upgradeable attributes based on purchased levels 
    land2nLanes = 2 + upgrades[attrnLanes, LAND2]
    land2heroSpeedMax# = 5 + 2.5 * upgrades[attrBaseSpeed, LAND2]
    land2AnimSpeed = 10 + 3 * upgrades[attrBaseSpeed, LAND2]
    land2heroBoostFramesMax# = 0.4 + 0.2 * upgrades[attrBoostFrames, LAND2] + 0.2 * (upgrades[attrBoostFrames, LAND2]/3)
    land2boostGroupLength = 5 + upgrades[attrBoostGroupLength, LAND2] + 2 * (upgrades[attrBoostGroupLength, LAND2] / 2)

    land2heroSpeed# = land2heroSpeedMax#
    //InitUpgradeValues()
	
    // load building sprites
    // building positioning depends on how many lanes are unlocked
    land2buildingXOffset = -105 + 55 * land2nLanes
    for i = 0 to 4
        LoadSpriteExpress(land2sprBuildings + i, "cbg/citytop1010.png", 2*h, 3*h, land2buildingXOffset + w*i, (-2 + 4.0 / 3 * i) * h, 99)
    next i
   // SetSpriteColor(land2sprBuildings, 0, 255, 255, 255)

    //streetDir$ = "cbg/lanes" + str(land2nLanes) + "/c" + str(land2nLanes)
	for i = 0 to 5
		land2sprStreet[i].length = land2nLanes
	next i
	
	land2sprStreet[1, 1] = LoadSprite("cbg/lane1.png")
    SetSpriteExpress(land2sprStreet[1, 1], 2*h, 2*h*30/42, 0, 0, 90)
    //SetSpriteExpress(land2sprStreet[1], 2*h*21/20, (2*h*21/20)*30/42, 0, 0, 1)
   
    //SetSpriteSize(land2sprStreet[1], 1435, 820)
    //SetSpritePosition(land2sprStreet[1], 0, 0)
    //PlaySprite(land2sprStreet[1], land2baseLaneSpeed * land2heroSpeed# * land2scrollScalar#)
	for i = 1 to land2sprStreet.length
		for j = 1 to land2sprStreet[i].length
			if i <> 1 or j <> 1
				land2sprStreet[i, j] = LoadSprite("cbg/lane" + str(1+Mod(j+1, 2)) + ".png")
				SetSpriteExpress(land2sprStreet[i, j], 2*h, 2*h*30/42, 0, 0, 110)
				//SetSpriteColorRed(land2sprStreet[i, j], 200-i*50)
			endif
    		//LoadSprite(land2sprStreet[i], land2sprStreet[1])
    		next j
    next i

    // reset hero movement characteristics
    land2currentLane = 2
    land2heroBoostFrames# = 0
    land2heroIFrames# = 0
    land2heroBoostCharges# = 0  // reset boost count

    // load boost meter
    // for now, just a basic rectangle that stretches with additional boosts
    CreateSpriteExpress(land2sprBoostMeter, 0, 30, 100, 600, 10)
    SetSpriteColor(land2sprBoostMeter, 255, 0, 0, 255)

    // load hero sprite
    LoadAnimatedSprite(hero, "cbg/duckc", 4)
    SetSpriteSize(hero, 55, 55)
    SetSpritePosition(hero, 500, land2heroY)
    SetSpriteDepth(hero, 30)
    SetSpriteShapeBox(hero, -60, -25, 60, 20, 0, 0)
    PlaySprite(hero, land2AnimSpeed)
    heroLocalDistance# = land2Distance

	oldAreaSeen = areaSeen
	areaSeen = 4//Max(areaSeen, 2)
	LoadSpriteExpress(duck, "enemy2/land2foe"+str(areaSeen-1)+".png", 200, 200, 460, 300, 5)
	areaSeen = oldAreaSeen

	img = LoadImage("cbg/bolt.png")
	for i = 1 to 10
		land2Bolt[i] = CreateSprite(img)
		SetSpriteExpress(land2Bolt[i], 20, 20, 999,999, 999)
	next i
	trashBag.insert(img)
	
	finishLine = LoadSprite("finishRod.png")
	SetSpriteSize(finishLine, 20, 700)
	SetSpriteDepth(finishLine, 101)
	SetSpriteOffset(finishLine, 10, 350)
	SetSpriteAngle(finishLine, 90)
	SetSpriteMiddleScreenX(finishLine)
	//FixSpriteToScreen(finishLine, 1)
	

    // create "spawnables" (boosts/obstacles/scrap)
    spawnActive.length = -1
    InitObstacles()
    InitBoostPanels()
    InitScrap()
    
    HighlightLaneLand2()

endfunction

function DoSpawnables()
	
	land2BehindCar = 0
	
    // process movement for all spawnables (boosts, obstacles)
    idx_to_delete = -1
    for i = 0 to spawnActive.length - 1
        //inc spawnActive[i].y, -3.5 * land2heroSpeed# * land2scrollScalar# * fpsr#*0.4166/3.74
        //spawnActive[i].y = heroLocalDistance#*2/3
        //(-h*7.3 + Mod(heroLocalDistance#*2/3+GetSpriteHeight(land2sprBuildings)*8+GetSpriteHeight(land2sprBuildings)*4/9*i, GetSpriteHeight(land2sprBuildings)*20/9))
        
        //inc spawnActive[i].y, -3.5 * land2heroSpeed# * land2scrollScalar# * fpsr#*0.4166/3.74
        if spawnActive[i].cat = GOOD
            // check for collecting a boost
            if GetSpriteCollision(spawnActive[i].spr, hero) and spawnActive[i].x = land2currentLane
                idx_to_delete = i
                land2heroBoostCharges# = land2heroBoostCharges# + 1
                //land2heroBoostCharges# = min(land2heroBoostCharges# + 1, land2heroBoostChargesMax)
                
                if GetSpriteGroup(spawnActive[i].spr) = LAND2
                	land2TriggerBoost = 1
                endif
                
                PlaySound(boostChargeS, volumeS/4)
            endif
            SetSpritePosition(spawnActive[i].spr, LaneToXWithOffsetBoost(spawnActive[i].x, spawnActive[i].y-(land2Distance-heroLocalDistance#)*2/3), spawnActive[i].y-(land2Distance-heroLocalDistance#)*2/3)
            if (GetSpriteY(spawnActive[i].spr)+GetSpriteHeight(spawnActive[i].spr) < GetSpriteY(hero)) and GetSpriteGroup(spawnActive[i].spr) = LAND2
            	//land2TriggerBoost = 1
            	land2HeroBoostCharges# = 0
            	SetSpriteGroup(spawnActive[i].spr, 0)
            endif
            
        elseif spawnActive[i].cat = BAD 
            // check for collisions
            if GetSpriteCollision(spawnActive[i].spr, hero) and spawnActive[i].x = land2currentLane //and land2HeroIFrames# = 0 
                land2BehindCar = 1
                //SetSprite
                //land2HeroIFrames# = land2heroIFramesMax
                //PlaySound(hitS, volumeS)
                if land2heroBoostFrames# > 0
                	SetSpriteGroup(spawnActive[i].spr, LAND2)
                	CollectScrap(CARSCRAP)
                	//Sound
                else
                	land2BehindCar = 1
                endif
                
            endif
            // recycle obstacle spawnables once they scroll offscreen
            if spawnActive[i].y < -300
                inc spawnActive[i].y, 3600
                spawnActive[i].x = SetObstacleLane(spawnActive[i])
            endif
            if GetSpriteGroup(spawnActive[i].spr) <> LAND2 then SetSpritePosition(spawnActive[i].spr, LaneToXWithOffsetCar(spawnActive[i].x, spawnActive[i].y-(land2Distance-heroLocalDistance#)*2/3), spawnActive[i].y-(land2Distance-heroLocalDistance#)*2/3)
        		if GetSpriteGroup(spawnActive[i].spr) = LAND2
                		IncSpritePosition(spawnActive[i].spr, 1.4*fpsr#, -0.8*fpsr#)
                		IncSpriteAngle(spawnActive[i].spr, 1.4*fpsr#)
                endif
        elseif spawnActive[i].cat = SCRAP
            // check for collecting scrap
            if GetSpriteCollision(spawnActive[i].spr, hero) and spawnActive[i].x = land2currentLane and GetTweenExists(spawnActive[i].spr) = 0
                CollectScrap(LAND2)
                PlaySprite(spawnActive[i].spr, 30)
				if GetTweenExists(spawnActive[i].spr) then DeleteTween(spawnActive[i].spr)
				CreateTweenSprite(spawnActive[i].spr, .6)
				SetTweenSpriteY(spawnActive[i].spr, GetSpriteY(spawnActive[i].spr), GetSpriteY(spawnActive[i].spr) - GetSpriteHeight(spawnActive[i].spr)*1.5, TweenSmooth1())
				PlayTweenSprite(spawnActive[i].spr, spawnActive[i].spr, 0)
				PlayTweenSprite(tweenSprFadeOut, spawnActive[i].spr, .1)
                //idx_to_delete = i
            endif
            if GetTweenExists(spawnActive[i].spr) = 0 then SetSpritePosition(spawnActive[i].spr, LaneToXWithOffset(spawnActive[i].x, spawnActive[i].y-(land2Distance-heroLocalDistance#)*2/3), spawnActive[i].y-(land2Distance-heroLocalDistance#)*2/3)
        endif
        
        if GetSpriteY(spawnActive[i].spr) > GetSpriteY(finishLine) then SetSpriteVisible(spawnActive[i].spr, 0)
        
    next i
	if GetSpriteY(spawnActive[i].spr) < GetSpriteY(hero)-80 and spawnActive[i].x = land2currentLane and GetSpriteDepth(spawnActive[i].spr) < GetSpriteDepth(hero) then SetSpriteDepth(spawnActive[i].spr, GetSpriteDepth(hero)+2)

    // delete any collected boosts
    if idx_to_delete <> -1
        DeleteSprite(spawnActive[idx_to_delete].spr)
        spawnActive.remove(idx_to_delete)
    endif
endfunction

function DoLand2()
//SetViewZoom(0.5)
    // scroll buildings
    // once a building passes the top of the screen, reset its position to below the screen
    for i = 0 to 4
        //IncSpritePosition(land2sprBuildings + i, -4.75 * land2heroSpeed# * land2scrollScalar#, -4.75 * 0.75 * land2heroSpeed# * land2scrollScalar#)
        SetSpriteX(land2sprBuildings + i, -w*1.25+Mod(heroLocalDistance#+GetSpriteWidth(land2sprBuildings)*i, GetSpriteWidth(land2sprBuildings)*5))
        SetSpriteY(land2sprBuildings + i, (-h*7.3 + Mod(heroLocalDistance#*2/3+GetSpriteHeight(land2sprBuildings)*8+GetSpriteHeight(land2sprBuildings)*4/9*i, GetSpriteHeight(land2sprBuildings)*20/9)))
       
		for j = 1 to land2sprStreet[i].length
			SetSpritePosition(land2sprStreet[i+1, j], GetSpriteX(land2sprBuildings+i)+176-(j-1)*laneWid, 1293+GetSpriteY(land2sprBuildings+i)) //+4/6*GetSpriteHeight(land2sprBuildings))
       	next j
       //SetSpritePosition(land2sprStreet[i+1], GetSpriteX(land2sprBuildings+i)-26, 1260+GetSpriteY(land2sprBuildings+i)) //+4/6*GetSpriteHeight(land2sprBuildings))
       
	//SetSpriteX(water2Trees2, (-w*0.7*2/3) + Mod(heroLocalDistance#*0.6, w*0.7*2/3))
         //if GetSpriteY(land2sprBuildings + i) < -3 * h
        //    SetSpritePosition(land2sprBuildings + i, land2buildingXOffset + 2*w, 2.0 / 3 * h)
        //endif
    next i
    
    SetSpritePosition(finishLine, LaneToXWithOffset(1, land2Distance*2/3-(land2Distance-heroLocalDistance#)*2/3)+60, land2Distance*2/3-(land2Distance-heroLocalDistance#)*2/3-120)
    
    land2TriggerBoost = 0
    DoSpawnables()
	
	//SetSpritePosition(land2sprStreet[1], GetSpriteX(land2sprBuildings), 800+GetSpriteY(land2sprBuildings)) //+4/6*GetSpriteHeight(land2sprBuildings))
	//SetSpritePosition(land2sprStreet[2], GetSpriteX(land2sprBuildings), GetSpriteY(land2sprBuildings)+1.2*GetSpriteHeight(land2sprBuildings))
	//IncSpriteY(land2sprStreet[1], GetSpriteHeight(land2sprBuildings+1))
//Print(GetSpriteX(land2sprStreet[1]))
//Print(GetSpriteY(land2sprStreet[1]))
	Print(GetViewOffsetX())
    // hero inputs
    DoInputs()
    // start turning Right
    
	for i = 0 to spawnActive.length - 1
		if GetSpriteCollision(spawnActive[i].spr, hero) and spawnActive[i].cat = BAD and spawnActive[i].x - land2currentLane = 1 and inputLeft
			if land2heroBoostFrames# > 0 
				SetSpriteGroup(spawnActive[i].spr, LAND2)
	            	CollectScrap(CARSCRAP)
	            	//Sound
	           else
	           	inputLeft = 0
				//Honk SE
			endif
			
			
		endif
		if GetSpriteCollision(spawnActive[i].spr, hero) and spawnActive[i].cat = BAD and spawnActive[i].x - land2currentLane = -1 and inputRight
			if land2heroBoostFrames# > 0 
				SetSpriteGroup(spawnActive[i].spr, LAND2)
	            	CollectScrap(CARSCRAP)
	            	//Sound
	           else
	           	inputRight = 0
				//Honk SE
			endif
		endif
	next i
      
    if inputRight and land2laneChangeFrame = 0 and land2currentLane > 1
        land2currentLane = max(1, land2currentLane - 1)
        land2laneChangeFrame = 5
        land2laneChangeDirection = -1
        HighlightLaneLand2()
    // start turning Left
    elseif inputLeft and land2laneChangeFrame = 0 and land2currentLane < land2nLanes
        land2currentLane = min(land2nLanes, land2currentLane + 1)
        land2laneChangeFrame = 5
        land2laneChangeDirection = 1
        HighlightLaneLand2()
    // use boost once meter with at least 5 charges held
    // boost time is proportionate to the number of charges held
    // if the boost meter is full (10 charges), the boost is extra long
   	endif
   	//if inputSelect and land2heroBoostCharges# >= 5
   	if land2TriggerBoost
   		land2TriggerBoost = 0
        land2heroBoostFrames# = land2heroBoostFramesMax# //*(1.0 + 0.05*(land2heroBoostChargesMax-land2heroBoostCharges#))
        land2boostSpeed# = land2heroBoostCharges#
        //if land2heroBoostCharges# = land2heroBoostChargesMax
        //    land2heroBoostFrames# = land2heroBoostFramesMax * 1.5
        //else
        //    land2heroBoostFrames# = land2heroBoostFramesMax * (land2heroBoostCharges# / land2heroBoostChargesMax)
       // endif
        land2heroBoostCharges# = 0
        SetSpriteSize(land2sprBoostMeter, 0, 20)
        SetSpriteColor(land2sprBoostMeter, 255, 0, 0, 255)
        PlaySound(boostS)
    endif
    if land2laneChangeFrame
        inc land2laneChangeFrame, -1
    endif
    
    if land2heroBoostCharges# > 0
    		for i = 1 to Round(land2heroBoostCharges#)
    			
			//The orbs circling the sun
			theta = gameTime#
			
			ratioC# = 360*i/Round(land2heroBoostCharges#)
			
			
			yAng# = theta + ratioC#
			if Mod(yAng#, 360) > 180
				SetSpriteDepth(land2Bolt[i], GetSpriteDepth(hero) + 1)
			else
				SetSpriteDepth(land2Bolt[i], GetSpriteDepth(hero) - 1)
			endif
			SetSpritePosition(land2Bolt[i], GetSpriteMiddleX(hero) + 40*cos(theta + ratioC#)-GetSpriteWidth(hero)/2, GetSpriteMiddleY(hero)-20 + 10*sin(theta + ratioC#))
    		next i
   	 	//land2heroBoostCharges# = land2heroBoostCharges# - GetFrameTime()/2
   	 	//SetSpriteSize(land2sprBoostMeter, 20 * land2heroBoostCharges#, 20)
        //if land2heroBoostCharges# = land2heroBoostChargesMax
        //    SetSpriteColor(land2sprBoostMeter, 255, 215, 0, 255)
        //elseif land2heroBoostCharges# >= 5
        //    SetSpriteColor(land2sprBoostMeter, 0, 255, 0, 255)
        //endif
        //duckMinus = 155.0*land2heroBoostCharges#/land2heroBoostChargesMax
       // Print(duckMinus)
        //SetSpriteColor(hero, 255-duckMinus, 255, 255, 255)
   	 	//SetSpriteSize(land2sprBoostMeter, 0, 20)
       	 //SetSpriteColor(land2sprBoostMeter, 255, 0, 0, 255)
	else
		for i = 1 to 10
    			SetSpritePosition(land2Bolt[i], 999, 999)
    		next i
	endif
    
    Print(land2heroBoostFrames#)
    // hero movement
    if land2BehindCar = 0 //land2heroIFrames# > 0 or land2heroBoostFrames# > 0 or land2BehindCar = 0
        land2heroIFrames# = max(0, land2heroIFrames# - 1)
        land2heroBoostFrames# = max(0, land2heroBoostFrames# - GetFrameTime())
        if land2heroBoostFrames# <= 0 then land2boostSpeed# = 0
        //land2heroSpeed# = land2heroSpeedMax# * (1 - 0.5 * (land2heroIFrames# / land2heroIFramesMax) + 1.5 * (land2heroBoostFrames# / land2heroBoostFramesMax))
        land2heroSpeed# = land2heroSpeedMax# * (1 + 0.1*land2boostSpeed# + 0.04 * (land2boostSpeed#^2))
        
        
        
        
        if GetSpritePlaying(hero) = 0 then ResumeSprite(hero)
        
        //Modifying the speed at the end of a boost
        if land2heroBoostFrames# > 0
        		SetSpriteSpeed(hero, land2AnimSpeed*2)
        		if land2heroBoostFrames# < land2heroBoostFramesMax#/3 then land2heroSpeed# = land2heroSpeed#*(land2heroBoostFrames#/(land2heroBoostFramesMax#/3))
        		if land2heroBoostFrames# < land2heroBoostFramesMax#/6
		    		StopSprite(hero)
		    		SetSpriteFrame(hero, 1)
		    	endif
        		//if land2heroSpeed# < land2heroSpeedMax# then land2heroSpeed# = land2heroSpeedMax#
        else
        		SetSpriteSpeed(hero, land2AnimSpeed)
        	endif
        
        
        // slow down lanes to match hero slowdown
		//for i = 1 to land2sprStreet.length
        	//	SetSpriteSpeed(land2sprStreet[i], land2baseLaneSpeed * land2heroSpeed# * land2scrollScalar#)
		//next i
    else
    		//For when you are stuck behind a car
   	 	land2heroSpeed# = 0
    		StopSprite(hero)
    		SetSpriteFrame(hero, 1)
    endif
    
    //SetSpriteColor(hero, 255, 255 - 2*land2heroIFrames#, 255 - 2*land2heroIFrames#, 255)
    SetSpriteColor(hero, 255 - 255*(land2heroBoostFrames#/(land2heroBoostFramesMax#)), 255, 255, 255)
    //SetSpriteColor(hero, 255, 255, 255, 255)
    if fpsr# < 25 then GlideToX(hero, LaneToX(land2currentLane), 10)
    //SetSpriteX(hero, LaneToX(land2currentLane) - 9 * land2laneChangeDirection * land2laneChangeFrame)
    //Print(land2currentLane)
    

    //inc heroLocalDistance#, -1 * land2heroSpeed# * fpsr#*0.4166/3.74
    inc heroLocalDistance#, -1 * land2heroSpeed# * fpsr#*0.4166/3.74

	SetSpritePosition(duck, LaneToXWithOffset(land2nLanes+1.5, 0-(duckDistance#-(heroLocalDistance#-land2Distance) - 20000*(raceSize - (curAreaSeen-1)))*2/3), 0-(duckDistance#-(heroLocalDistance#-land2Distance) - 20000*(raceSize - (curAreaSeen-1)))*2/3)

    Print(land2BehindCar)

endfunction

function HighlightLaneLand2()
	for i = 1 to land2sprStreet.length
		for j = 1 to land2sprStreet[i].length 
			if j = land2currentLane
				ColorLaneLand2(land2sprStreet[i, j], 0)
			else
				ColorLaneLand2(land2sprStreet[i, j], 1)
			endif
		next j
	next i
	
	for i = 0 to spawnActive.length - 1
		if spawnActive[i].x = land2currentLane
			ColorSpawnableLand2(spawnActive[i].spr, 0)
		elseif Abs(spawnActive[i].x - land2currentLane) < 2
			ColorSpawnableLand2(spawnActive[i].spr, 1)
		else
			ColorSpawnableLand2(spawnActive[i].spr, 2)
		endif
		if spawnActive[i].x > land2currentLane
			SetSpriteDepth(spawnActive[i].spr, GetSpriteDepth(hero)-3*Abs(spawnActive[i].x - land2currentLane))
		else
			SetSpriteDepth(spawnActive[i].spr, GetSpriteDepth(hero)+3*Abs(spawnActive[i].x - land2currentLane))
		endif
		if spawnActive[i].cat = GOOD then SetSpriteDepth(spawnActive[i].spr, GetSpriteDepth(spawnActive[i].spr)+2)
	next i
	
endfunction

function ColorLaneLand2(spr, dark)
	alpha = GetSpriteColorAlpha(spr)
	if dark = 0 then SetSpriteColor(spr, 214, 38, 255, 255)
	if dark = 1 then SetSpriteColor(spr, 130*.6, 63*.6, 175*.6, 255)
	SetSpriteColorAlpha(spr, alpha)
endfunction

function ColorSpawnableLand2(spr, dark)
	alpha = GetSpriteColorAlpha(spr)
	blue = GetSpriteColorgreen(spr)
	if dark = 0 then SetSpriteColor(spr, 255, 255, 255, 255)
	if dark = 1 then SetSpriteColor(spr, 230, 195, 230, 255)
	if dark = 2 then SetSpriteColor(spr, 220, 180, 220, 255)
	SetSpriteColorAlpha(spr, alpha)
	if blue = 0
		SetSpriteColorgreen(spr, 0)
	endif
endfunction

//~function FreezeLand2()

    //~

//~endfunction

//~function UnfreezeLand2()

    //~// placeholder. all animations get restarted during the scene init

//~endfunction
