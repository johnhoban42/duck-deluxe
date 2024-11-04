#include "main.agc"
// File: 4water2.agc
// Created: 24-10-03


#constant water2Distance 20000

global diveSpeedX# = 0.35
global diveVelX# = 0

global diveAccelY# = .005	//Upgrade variable
global diveVelY# = 0
global diveVelMax# = .6	//Upgrade variable
global diveDeepTimer# = 0
global diveDeepTimerMax# = .75	//Upgrade variable

//Water tile visibility could be an upgrade variable?
//waterTileAlpha

global fixedWater2Speed# = 0.11



function InitWater2()
	
	heroX# = w/5
	heroY# = 0
	CreateSpriteExpress(hero, 140, 140, w, h, 50)
	
	activeBoost# = 0
	boatSpeed# = 0
	chargeC# = 0
	
	heroImg2 = LoadImage("duckl1.png")
	
	AddSpriteAnimationFrame(hero, heroImg2)
	SetSpriteSize(hero, 60, 60)
	
	LoadAnimatedSprite(duck, "duckW", 3)

	
	SetSpriteVisible(landS, 1)
	SetSpriteSize(landS, w, 100)
	SetSpriteMiddleScreenX(landS)
	SetSpriteY(landS, 100)
	SetSpriteDepth(landS, 90)
	
	
	CreateSprite(water2TileS, 0)
	SetSpriteColor(water2TileS, 0, 160, 200, 255)
	SetSpriteSize(water2TileS, w, h)
	SetSpriteY(water2TileS, GetSpriteHeight(landS) + GetSpriteY(landS))
	SetSpriteDepth(water2TileS, 990)
	water2TileE = water2TileS+1
	
	
	numCross = 40
	tileEH = 40/400 * w/numCross
	
	for i = 0 to numCross*numCross
		if (Mod(i/numCross, 2) = 0 and Mod(i,2) = 1) or (Mod(i/numCross, 2) = 1 and Mod(i,2) = 0)
			CreateSprite(water2TileE, 0)
			SetSpriteSizeSquare(water2TileE, w/numCross + tileEH*2)
			SetSpritePosition(water2TileE, w/numCross * Mod(i, numCross), GetSpriteY(water2TileS) + w/numCross * (i/numCross))
			
			SetSpriteColor(water2TileE, 40, 180, 220-(i/numCross)*5, 255)
			if Mod(water2TileE, 2) = 1
				AddSpriteAnimationFrame(water2TileE, tileI1)
				AddSpriteAnimationFrame(water2TileE, tileI2)
			else
				AddSpriteAnimationFrame(water2TileE, tileI2)
				AddSpriteAnimationFrame(water2TileE, tileI1)
			endif
			PlaySprite(water2TileE, 3, 1, 1, 2)
			SetSpriteDepth(water2TileE, 40)
			
			inc water2TileE, 1
		endif
	next i
	
	//Land moving image is 160 across
	//It's also 60 frames
	//Every frame, we will shift the water images over by 160/w*60
	
	//Setting the variables based on upgrades
	//fixedWaterSpeed# =
	
	areaSeen = Max(areaSeen, 1)
	
	SetSpriteVisible(bg3, 0)
	
	newS as spawn
	
	//Gameplay setting
	heroLocalDistance# = waterDistance
	waterVelX# = 0
	
	SetSpriteColor(landS, 135, 200, 255, 255)
	//SetSpriteColor(BG, 255, 255, 0, 255)
	
endfunction

function DoWater2()

	//IncSpriteY(cutsceneSpr, -2*fpsr#)
	//waterXMax = -
	heroX# = Min(Max(heroX#, 40), 320)
	SetSpritePosition(hero, heroX#, heroY# + (GetSpriteMiddleY(landS)) - GetSpriteHeight(hero) + 30 + 10*Abs(sin(gameTime#/8)) + 6*Abs(cos(gameTime#/3)))
	
	
	for i = water2TileS+1 to water2TileE-1
		rank = 2*(i - water2TileS) - 1
		SetSpriteSize(i, GetSpriteWidth(i), w/numCross + sin(-gameTime#/3 + 17*(rank/numCross))*4 + tileEH*2)
		if rank > numCross
			//Second row and down
			SetSpriteY(i, GetSpriteY(i-numCross/2) + GetSpriteHeight(i-numCross/2) - tileEH)
			//SetSpriteY(i, GetSpriteY(water2TileS) + w/numCross*(rank/numCross) + sin(gameTime#/6)*(rank/numCross))
		else
			//First row
			SetSpriteY(i, GetSpriteY(water2TileS))
		endif
		
		//Moving the water tiles along with land
		if Mod(rank/numCross, 2) = 1 then inc rank, 1
		//SetSpriteX(i, w/numCross * Mod(rank, numCross) - w/160*GetSpriteCurrentFrame(landS))
		//Above one looked really choppy, not using it :P
		SetSpriteX(i, w/numCross * Mod(rank, numCross) + Mod(heroLocalDistance#, 2*w/numCross))
		if GetSpriteX(i) < 100
			SetSpriteColorAlpha(i, Max(0, waterTileAlpha-GetSpriteX(i)))
		else
			SetSpriteColorAlpha(i, waterTileAlpha)
		endif
		
	next i
	Print(rank)
	if inputLeft
		inc heroX#, -waterSpeedX#*1.5*fpsr#
		PlaySprite(hero, 5, 0, 1, 2)
		SetSpriteFlip(hero, 1, 0)
	endif
	if inputRight
		inc heroX#, waterSpeedX#*1.5*fpsr#
		PlaySprite(hero, 5, 0, 1, 2)
		SetSpriteFlip(hero, 0, 0)
	endif
	
	if stateRight
		SetSpriteFlip(hero, 0, 0)
	elseif stateLeft
		SetSpriteFlip(hero, 1, 0)
	endif
	
	if (releaseLeft and stateRight = 0) or (releaseRight and stateLeft = 0) then PlaySprite(hero, 10, 0, 3, 4)
		
	if Abs(waterVelX#) < .01
		waterVelX# = 0
	else
		
		waterVelX# =  (((waterVelX#)*((64.0)^fpsr#))/(65.0)^fpsr#)
	endif
	//GlideNumToZero(waterVelX#, 40)
	
	if stateLeft then waterVelX# = -waterSpeedX#*fpsr#
	if stateRight then waterVelX# = waterSpeedX#*fpsr#
	inc heroX#, waterVelX#
	
	//Diving
	if stateSpace
		
		if heroY# <= 0
			diveDeepTimer# = 0
		endif
		
		if ((heroY# > 0 and diveVelY# >= (diveVelMax#-diveVelY#)) or heroY# <= 0) and diveDeepTimer# < diveDeepTimerMax#
			//Setting the dive to the max strength, but only when above water OR when currently underwater and diving
			diveVelY# = diveVelMax# +  diveVelMax#*0.2*(diveDeepTimerMax#-diveDeepTimer#)
			
			SetSpriteAngle(hero, diveVisAngle)
			
			inc diveDeepTimer#, GetFrameTime()
		endif
		
		
		//Print(boatSpeed#)
		//Sync()
		//Sleep(1000)
	endif
	if heroY# > 0
		diveVelY# = diveVelY# - diveAccelY#*fpsr#
		SetSpriteAngle(hero, diveVisAngle*diveVelY#)
		if diveVelY# < 0 and GetSpriteAngle(hero) < 360-diveVisAngle then SetSpriteAngle(hero, -diveVisAngle)
	endif
	if heroY# < 0
		//if diveVelY# < -5 then diveVelY# = -5
		
		//diveVelY# = diveVelY# + diveAccelY#*fpsr#*4
		//For being airborne
		
		//For now, leaving the water will just cancel movement
		diveVelY# = 0
		heroY# = 0
		SetSpriteAngle(hero, 0)
	endif
	
	inc heroY#, diveVelY#*fpsr#
	
	Print(heroY#)
	Print(diveDeepTimer#)
	Print(diveDeepTimerMax#)
	Print(GetSpriteAngle(hero))
	
	
	SetSpriteFrame(landS, 1+Mod(Round(landDistance-heroLocalDistance#)/6, 60))
	
	//if boatSpeed# > 0
	//	dec heroLocalDistance#, boatSpeed#*fpsr#
	//	dec boatSpeed#, boatSpeedLoss#*fpsr#
		
	//	if boatSpeed# <= 0
			
			
	//	endif
	//endif
	dec heroLocalDistance#, fixedWater2Speed#*fpsr#
	
	SetSpriteFrame(bg3, 1+8.0*(Round(waterDistance-heroLocalDistance#)/(1.0*waterDistance)))
	
	SetSpriteX(heroIcon, GetSpriteX(progBack)-GetSpriteWidth(heroIcon)/2 + (GetSpriteWidth(progBack)*(waterDistance - heroLocalDistance#)/waterDistance)/areaSeen)
	SetSpriteX(duckIcon, Min(GetSpriteX(progBack)-GetSpriteWidth(duckIcon)/2 + (GetSpriteWidth(progBack)*(20000 - (duckDistance#-40000))/20000)/areaSeen, GetSpriteX(progBack)+GetSpriteWidth(progBack)-GetSpriteWidth(duckIcon)))
	
	deleted = 0
	for i = 1 to spawnActive.length
		spr = spawnActive[i].spr
		/*if GetSpriteVisible(spr)
			if GetSpriteCollision(spr, hero) and Abs((GetSpriteY(hero) - GetSpriteY(spr))) < 80
				
				if spawnActive[i].cat = GOOD
					boatSpeed# = Max(boatSpeed#, sqrt(Min(boatSpeedMax, 20)*1.5))
					PlaySound(WindSS)
					PlaySound(rowGoodS, VolumeS*.8)
				elseif spawnActive[i].cat = BAD
					if damageAmt# <= 0
						damageAmt# = 255
						boatSpeed# = 0
						PlaySound(hitS, volumeS)
					endif
					//Sound effect
					//SetSpriteColor(hero, 255, 100, 100, 255)
				else //SCRAP
					CollectScrap(WATER)
				endif
				if spawnActive[i].cat <> RAMP
					deleted = i
					i = spawnActive.length
				endif
				
			endif
		endif*/
	next i
	if deleted <> 0
		if spawnActive[deleted].cat = GOOD
			DeleteAnimatedSprite(spawnActive[deleted].spr)
		else
			DeleteSprite(spawnActive[deleted].spr)
		endif
		spawnActive.remove(deleted)
	endif
	

	
endfunction

