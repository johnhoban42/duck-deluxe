#include "main.agc"
// File: 4water2.agc
// Created: 24-10-03


#constant water2Distance 20000

global diveSpeedX# = 0.35
global diveVelX# = 0

global diveRise# = .005	//Upgrade variable
global diveVelY# = 0
global diveVelMax# = .6	//Upgrade variable
global diveDeepTimer# = 0
global diveDeepTimerMax# = .75	//Upgrade variable
global diveLevel = 1		//Upgrade variable

//Water tile visibility could be an upgrade variable?
//waterTileAlpha

global fixedWater2Speed# = 0.11 //Upgrade variable



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

	//Gameplay setting
	heroLocalDistance# = water2Distance
	waterVelX# = 0
	
	fixedWater2Speed# = .2 * (1 + upgrades[1, 4] + 7)	//Adding 7 should be the maximum
	
	diveVelMax# = .4 * (1 + upgrades[2, 4] + 2)
	
	diveLevel = 3 + upgrades[3, 4]
	
	if diveLevel = 1 then diveDeepTimerMax# = 0.28/(diveVelMax#)
	if diveLevel = 2 then diveDeepTimerMax# = 0.41/(diveVelMax#)
	if diveLevel = 3 then diveDeepTimerMax# = 0.55/(diveVelMax#)
	if diveLevel = 4 then diveDeepTimerMax# = 0.69/(diveVelMax#)
	
	diveRise# = .02 * (1 + upgrades[4, 4])

	
	SetSpriteVisible(water2S, 1)
	SetSpriteSize(water2S, w, w/1000*75)
	SetSpriteMiddleScreenX(water2S)
	SetSpriteY(water2S, 150)
	SetSpriteDepth(water2S, 90)
	SetSpriteColor(water2S, 135, 200, 255, 255)
	
	LoadSpriteExpress(water2Trees, "w2BG/mangroves2.png", w*2, w/1000*370, 0, GetSpriteY(water2S)-(w/1000*370)+50, 150)
	
	//CreateSprite(water2TileS, 0)
	SetSpriteVisible(water2TileS, 1)
	SetSpriteColor(water2TileS, 0, 160, 200, 200)
	SetSpriteSize(water2TileS, w, w/1000*70)
	//SetSpriteSize(water2TileS, w, w/1000*155)
	SetSpriteY(water2TileS, GetSpriteHeight(water2S) + GetSpriteY(water2S))
	SetSpriteDepth(water2TileS, 10)
	//SetSpriteDepth(water2TileS, 990)
	water2TileE = water2TileS+1
	
	numCross = 8
	for i = 1 to numCross
		spr = water2TileE
		CreateSpriteExistingAnimation(spr, water2TileS)
		MatchSpriteSize(spr, water2TileS)
		SetSpriteSize(spr, w, GetSpriteHeight(spr)*(1+0.1*i))
		SetSpriteY(spr, GetSpriteY(spr-1) + GetSpriteHeight(spr-1))
		
		MatchSpriteColor(spr, water2TileS)
		
		colorDarker = i - diveLevel
		darkConst = 45
		darkAmt = 10
		if colorDarker > 0 and diveLevel < 4 then SetSpriteColor(spr, GetSpriteColorRed(spr), GetSpriteColorGreen(spr) - colorDarker*darkAmt - darkConst, GetSpriteColorBlue(spr) - colorDarker*darkAmt - darkConst, GetSpriteColorAlpha(spr))
		
		inc water2TileE, 1
	next i
	
	
	
	CreateParticles(lightP, 0, 0)
	img = LoadImage("firefly.png")
	SetParticlesImage(lightP, img)
	trashBag.insert(img)
	SetParticlesDepth(lightP, 10)
	SetParticlesStartZone(lightP, 0, 20, w, GetSpriteY(water2S)+GetSpriteHeight(water2TileS)/2)
	SetParticlesMax(lightP, -1)
	SetParticlesDirection(lightP, 4, 4)
	SetParticlesSize(lightP, 8)
	SetParticlesAngle(lightP, 360)
	SetParticlesFrequency(lightP, 4)
	life# = 1.2
	SetParticlesLife(lightP, life#)
	AddParticlesColorKeyFrame(lightP, 0, 230, 230, 0, 0)
	AddParticlesColorKeyFrame(lightP, life#/4, 230, 230, 0, 210)
	AddParticlesColorKeyFrame(lightP, life#*4/5, 230, 230, 0, 230)
	AddParticlesColorKeyFrame(lightP, life#, 230, 230, 0, 0)
	 
	//Land moving image is 160 across
	//It's also 60 frames
	//Every frame, we will shift the water images over by 160/w*60
	
	//Setting the variables based on upgrades
	//fixedWaterSpeed# =
	
	areaSeen = Max(areaSeen, 1)
	
	//SetSpriteVisible(bg3, 0)
	CreateSpriteExpress(water2BG, w, h, 0, 0, 2000)
	SetSpriteColor(water2BG, 10, 20, 80, 255)
	SetSpriteColor(water2Trees, 110, 120, 180, 255)
	
	newS as spawn
	iEnd = 25 + 10*diveLevel //+ (.5*diveLevel*diveLevel)
	for i = 1 to iEnd
		newS.spr = spawnS
		newS.cat = Random(SCRAP, SCRAP+1)
		if newS.cat = SCRAP+1 then newS.cat = SCRAP
		newS.x = i*water2Distance/iEnd + 100 + Random(0, 400)
		newS.y = GetSpriteY(water2TileS) + Random(60, 420-(4-diveLevel)*80)
		
		
		if i = iEnd then newS.cat = SCRAP
		
		if newS.cat = GOOD
			//LoadAnimatedSprite(spawnS, "current", 8)
			//SetSpriteDepth(spawnS, 8)
			//PlaySprite(spawnS, 20, 1, 1, 8)
			//newS.size = 100
		elseif newS.cat = BAD
			LoadSpriteExpress(spawnS, "buoy1.png", 10, 10, w, h, 8)
			SetSpriteShape(spawnS, 3)
			newS.size = 100
		else
			LoadSpriteExpress(spawnS, "scrap1.png", 10, 10, w, h, 8)
			newS.size = 50
			SetSpriteSizeSquare(spawnS, newS.size)
		endif
		SetSpriteDepth(spawnS, 50)
		
		spawnActive.insert(newS)
		inc spawnS, 1
		
		
	next i
	
	
	
	
	//SetSpriteColor(BG, 255, 255, 0, 255)
	
endfunction

function DoWater2()

	//IncSpriteY(cutsceneSpr, -2*fpsr#)
	//waterXMax = -
	heroX# = Min(Max(heroX#, 70), 420)
	SetSpritePosition(hero, heroX#, heroY# + (GetSpriteMiddleY(water2S)) - GetSpriteHeight(hero) + 30 + 10*Abs(sin(gameTime#/8)) + 6*Abs(cos(gameTime#/3)))
	
	
	
	if inputLeft
		inc heroX#, -waterSpeedX#*1.5*fpsr#
		PlaySprite(hero, 5, 0, 1, 2)
		//SetSpriteFlip(hero, 1, 0)
	endif
	if inputRight
		inc heroX#, waterSpeedX#*1.5*fpsr#
		PlaySprite(hero, 5, 0, 1, 2)
		//SetSpriteFlip(hero, 0, 0)
	endif
	
	if stateRight
		//SetSpriteFlip(hero, 0, 0)
	elseif stateLeft
		//SetSpriteFlip(hero, 1, 0)
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
			
		endif
		
		inc diveDeepTimer#, GetFrameTime()
		
		//Print(boatSpeed#)
		//Sync()
		//Sleep(1000)
	endif
	if heroY# > 0
		//Rising the duck back up, if space is no longer held
		if (diveDeepTimer# >= diveDeepTimerMax#) or stateSpace = 0 then diveVelY# = diveVelY# - diveRise#*fpsr#
		
		SetSpriteAngle(hero, diveVisAngle*diveVelY#)
		if diveVelY# < 0 and GetSpriteAngle(hero) < 360-diveVisAngle then SetSpriteAngle(hero, -diveVisAngle)
		
		dec heroLocalDistance#, fixedWater2Speed#*fpsr#/2.5
	endif
	if heroY# < 0
		//if diveVelY# < -5 then diveVelY# = -5
		
		//diveVelY# = diveVelY# + diveRise#*fpsr#*4
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
	
	
	SetSpriteFrame(water2S, 1+Mod(Round(landDistance-heroLocalDistance#)/6, 60))
	SetSpriteFrame(water2TileS, 1+Mod(Round(landDistance-heroLocalDistance#)/6, 60))
	for i = water2TileS+1 to water2TileE-1
		
		SetSpriteFrame(i, 1+Mod(GetSpriteCurrentFrame(water2TileS)-1 + Mod(i-1,2)*30, 60))
	next i
	
	SetSpriteX(water2Trees, (-w) + Mod(heroLocalDistance#, w))
	
	//if boatSpeed# > 0
	//	dec heroLocalDistance#, boatSpeed#*fpsr#
	//	dec boatSpeed#, boatSpeedLoss#*fpsr#
		
	//	if boatSpeed# <= 0
			
			
	//	endif
	//endif
	dec heroLocalDistance#, fixedWater2Speed#*fpsr#
	
	//SetSpriteFrame(bg3, 1+8.0*(Round(waterDistance-heroLocalDistance#)/(1.0*waterDistance)))
	
	SetSpriteX(heroIcon, GetSpriteX(progBack)-GetSpriteWidth(heroIcon)/2 + (GetSpriteWidth(progBack)*(waterDistance - heroLocalDistance#)/waterDistance)/areaSeen)
	SetSpriteX(duckIcon, Min(GetSpriteX(progBack)-GetSpriteWidth(duckIcon)/2 + (GetSpriteWidth(progBack)*(20000 - (duckDistance#-40000))/20000)/areaSeen, GetSpriteX(progBack)+GetSpriteWidth(progBack)-GetSpriteWidth(duckIcon)))
	
	deleted = 0
	for i = 1 to spawnActive.length
		spr = spawnActive[i].spr
		SetSpritePosition(spr, spawnActive[i].x-(water2Distance-heroLocalDistance#), spawnActive[i].y)
		if GetSpriteVisible(spr)
			if GetSpriteCollision(spr, hero) and Abs((GetSpriteY(hero) - GetSpriteY(spr))) < 80
				
				if spawnActive[i].cat = GOOD
					//boatSpeed# = Max(boatSpeed#, sqrt(Min(boatSpeedMax, 20)*1.5))
					//PlaySound(WindSS)
					//PlaySound(rowGoodS, VolumeS*.8)
				elseif spawnActive[i].cat = BAD
					//if damageAmt# <= 0
					//	damageAmt# = 255
					//	boatSpeed# = 0
					//	PlaySound(hitS, volumeS)
					//endif
					//Sound effect
					//SetSpriteColor(hero, 255, 100, 100, 255)
				else //SCRAP
					CollectScrap(WATER2)
				endif
				if spawnActive[i].cat <> RAMP
					deleted = i
					i = spawnActive.length
				endif
				
			endif
		endif
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

//Creating the old grid of squares
/*
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
	*/

//Making the old grid wavy
/*
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
		//SetSpriteX(i, w/numCross * Mod(rank, numCross) - w/160*GetSpriteCurrentFrame(water2S))
		//Above one looked really choppy, not using it :P
		SetSpriteX(i, w/numCross * Mod(rank, numCross) + Mod(heroLocalDistance#, 2*w/numCross))
		if GetSpriteX(i) < 100
			SetSpriteColorAlpha(i, Max(0, waterTileAlpha-GetSpriteX(i)))
		else
			SetSpriteColorAlpha(i, waterTileAlpha)
		endif
		
	next i
	Print(rank)
	*/
	
	
	//Making the bottom row water ripple - a bit too nauseating
	/*
	for i = water2TileS+1 to water2TileE-1
		row = i - (water2TileS+1)
		SetSpriteSize(i, GetSpriteWidth(i), GetSpriteHeight(water2TileS) + sin(-gameTime#/3 + 17*row + 17*row*row)*8 + row*20)
		if row <> 0 then SetSpriteY(i, GetSpriteY(i-1) + GetSpriteHeight(i-1))
	next i
	*/
