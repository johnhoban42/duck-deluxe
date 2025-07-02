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

global diveBoost# = 0
global diveBoostQueue = 0
global diveBoostSlow# = .0008
#constant diveHopRise .01
global diveHop# = 0
global diveDamage = 0

global featherBoostFrameS
global featherBoostS

//Water tile visibility could be an upgrade variable?
//waterTileAlpha

global fixedWater2Speed# = 0.11 //Upgrade variable



function InitWater2()
	
	heroX# = 120
	heroY# = 0
	//CreateSpriteExpress(hero, 140, 140, w, h, 50)
	LoadAnimatedSprite(hero, "duckw2", 7)
	PlaySprite(hero, 10, 1, 1, 4)
	SetSpriteSizeSquare(hero, 60)
	SetSpriteDepth(hero, 50)
	activeBoost# = 0
	boatSpeed# = 0
	chargeC# = 0
	
 	diveVelY# = 0
	diveBoost# = 0
	diveBoostQueue = 0
	diveHop# = 0
	diveDamage = 0
	
	//heroImg2 = LoadImage("duckl1.png")
	
	//AddSpriteAnimationFrame(hero, heroImg2)
	
	LoadSpriteExpress(duck, "swampfoe1a.png", 120, 120, 999, 999, 60)
	
	//Gameplay setting
	heroLocalDistance# = water2Distance
	waterVelX# = 0
	
	if debug then scrapTotal = 1000
	
	//Base speed, upgrade 1
	fixedWater2Speed# = .2 * (1 + upgrades[1, 4]*.75 + (upgrades[1, 4]/2)*.5 + (upgrades[1, 4]/3)*1.25)	//Adding 7 should be the maximum
	
	//Feather boost, upgrade 2
	diveBoostSlow# = .0038 / (1 + upgrades[2, 4] + (upgrades[2, 4]/2)*.5 + (upgrades[2, 4]/3)*1) //2)
	
	//Water movement, upgrade 4
	diveVelMax# = .4 * (1 + upgrades[4, 4]*0.25 + (upgrades[4, 4]/2)*0.1 + (upgrades[4, 4]/2)*0.4)//2)
	diveRise# = .007 * (1 + upgrades[4, 4]*.5)//3)
	waterSpeedX# = (0.25) * (1 + 0.2*upgrades[4, 4] + 0.2*upgrades[4, 4]/3)
	
	//Dive depth, upgrade 3
	diveLevel = 1 + upgrades[3, 4]
	if diveLevel = 1 then diveDeepTimerMax# = 0.28/(diveVelMax#)
	if diveLevel = 2 then diveDeepTimerMax# = 0.41/(diveVelMax#)
	if diveLevel = 3 then diveDeepTimerMax# = 0.55/(diveVelMax#)
	if diveLevel = 4 then diveDeepTimerMax# = 0.69/(diveVelMax#)
	SetViewZoomMode(0)
	SetViewZoom(1/((4+diveLevel*1.5)/10.0))
	heroX# = 120 + 60*diveLevel
	
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
	
	
	CreateParticlesExpress(splashP, 10, 10, 4, 170, 500)
	img = LoadImage("splash.png")
	SetParticlesImage(splashP, img)
	trashBag.insert(img)
	SetParticlesStartZone(splashP, -10, -1, 10, 1)
	SetParticlesPosition(splashP, 9999, 9999)
	SetParticlesDirection(splashP, 0, -200)
	life# = .2
	SetParticlesLife(splashP, life#)
	r = 60
	g = 190
	b = 220
	AddParticlesColorKeyFrame(splashP, 0, r, g, b, 255)
	AddParticlesColorKeyFrame(splashP, life#*4/5, r, g, b, 255)
	AddParticlesColorKeyFrame(splashP, life#, r, g, b, 0)
	AddParticlesForce(splashP, 0, life#, 0, 1000)
	
	CreateParticlesExpress(featherP, 10, 8, 20*GetViewZoom()/1, 50, 80)
	SetParticlesImage(featherP, featherImg1)
	SetParticlesStartZone(featherP, -10, -1, 10, 1)
	//SetParticlesPosition(featherP, 9999, 9999)
	SetParticlesDirection(featherP, -200, 100)
	life# = .3
	SetParticlesLife(featherP, life#)
	r = 255
	g = 255
	b = 255
	AddParticlesColorKeyFrame(featherP, 0, r, g, b, 255)
	AddParticlesColorKeyFrame(featherP, life#*4/5, r, g, b*3/4, 255)
	AddParticlesColorKeyFrame(featherP, life#, r, g, b/2, 0)
	AddParticlesForce(featherP, 0, life#, -100, 5)
	
	//AddParticlesForce(featherP, life#/4, life#, -400, 0)
	
	
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
	
	fish1I = LoadImage("robofish1.png")
	fish2I = LoadImage("robofish2.png")
	fish3I = LoadImage("robofish3.png")
	
	//This variable makes sure that the scrap won't overpower the balance
	scrapWeight = 0
	
	newS as spawn
	iEnd = 40 + 8*diveLevel //+ (.5*diveLevel*diveLevel)
	for i = 1 to iEnd
		newS.spr = spawnS
		newS.cat = Random(1, 7)
		if newS.cat <= 3
			inc newS.cat, scrapWeight/2
		endif
		if newS.cat <= 3 then newS.cat = SCRAP
		if newS.cat = 4 or newS.cat = 5 then newS.cat = GOOD
		if newS.cat = 6 or newS.cat = 7 then newS.cat = BAD
		if i < 4 and newS.cat = BAD then newS.cat = SCRAP
		
		if upgrades[3, 4] = 0
			//Railroading the first three on the first attempt
			if i = 1 or i = 2 then newS.cat = SCRAP
			if i = 3 then newS.cat = GOOD
		endif
		
		newS.x = i*water2Distance/(iEnd+2) + 100 + Random(0, 340)
		newS.y = GetSpriteY(water2TileS) - 50 + Random(60, 350-(4-diveLevel)*70)
		
		
		if i = iEnd then newS.cat = SCRAP
		
		if newS.cat = GOOD
			scrapWeight = 0
			CreateSpriteExpress(spawnS, 10, 10, w, h, 8)
			AddSpriteAnimationFrame(spawnS, featherImg1)
			AddSpriteAnimationFrame(spawnS, featherImg2)
			AddSpriteAnimationFrame(spawnS, featherImg2)
			AddSpriteAnimationFrame(spawnS, featherImg3)
			AddSpriteAnimationFrame(spawnS, featherImg4)
			AddSpriteAnimationFrame(spawnS, featherImg4)
			PlaySprite(spawnS, 6)
			SetSpriteFrame(spawnS, Random(1, 6))
			newS.size = 60
			SetSpriteSizeSquare(spawnS, newS.size)
		elseif newS.cat = BAD
			scrapWeight = 0
			CreateSpriteExpress(spawnS, 10, 10, w, h, 8)
			AddSpriteAnimationFrame(spawnS, fish1I)
			AddSpriteAnimationFrame(spawnS, fish2I)
			AddSpriteAnimationFrame(spawnS, fish2I)
			AddSpriteAnimationFrame(spawnS, fish3I)
			PlaySprite(spawnS, 3, 1, 1, 2)
			newS.size = 75
			SetSpriteSizeSquare(spawnS, newS.size)
			SetSpriteFlip(spawnS, 1, 0)
			SetSpriteShape(spawnS, 3)
		else
			inc scrapWeight, 1
			CreateSpriteExpress(spawnS, 10, 10, w, h, 8)
			rnd = Random(1,8)
			for j = 1 to 4
				AddSpriteAnimationFrame(spawnS, scrapImgs[rnd, 1, j])//First index will be a random
			next j
			PlaySprite(spawnS, 3+Random(1,3))
			newS.size = 60
			SetSpriteSizeSquare(spawnS, newS.size)
		endif
		SetSpriteDepth(spawnS, 50)
		
		spawnActive.insert(newS)
		inc spawnS, 1
		
		
	next i
	
//~	iEnd = 10
//~	for i = 1 to iEnd
//~		newS.spr = spawnS
//~		newS.cat = BAD
//~		
//~		newS.x = i*water2Distance/iEnd + 100 + Random(0, 400)
//~		newS.y = GetSpriteY(water2TileS) + Random(60, 400-(4-diveLevel)*20)
//~		
//~			CreateSpriteExpress(spawnS, 30, 700, w, h, 8)
//~			SetSpriteShape(spawnS, 3)

//~		
//~		spawnActive.insert(newS)
//~		inc spawnS, 1
//~		
//~		
//~	next i
	
	//The end lamppost
	newS.spr = spawnS
	newS.cat = RAMP
	newS.x = water2Distance+370
	newS.y = 100
	CreateSprite(spawnS, 0)
	SetSpriteDepth(spawnS, 18)
	SetSpriteSize(spawnS, 20, 700)
	spawnActive.insert(newS)
	inc spawnS, 1
	
	//The feather boost meter
	featherBoostFrameS = LoadSprite("featherBar.png")
	SetSpriteExpress(featherBoostFrameS, 70, 70, 70, 590, 5) 
	FixSpriteToScreen(featherBoostFrameS, 1)
	
	featherBoostS = CreateSprite(0) 
	SetSpriteExpress(featherBoostS, 0, GetSpriteWidth(featherBoostFrameS)*2/9, GetSpriteX(featherBoostFrameS) + GetSpriteWidth(featherBoostFrameS)*4/9, GetSpriteY(featherBoostFrameS) + GetSpriteHeight(featherBoostFrameS)*5/18, 6) 
	FixSpriteToScreen(featherBoostS, 1)
	
	//SetSpriteColor(BG, 255, 255, 0, 255)
	
endfunction

function DoWater2()

	//IncSpriteY(cutsceneSpr, -2*fpsr#)
	//waterXMax = -
	heroX# = Min(Max(heroX#, 70), 420)
	SetSpritePosition(hero, heroX#, heroY# + 18 + (GetSpriteMiddleY(water2S)) - GetSpriteHeight(hero) + 30 + 4*Abs(sin(gameTime#/8)) + 2*Abs(cos(gameTime#/3)))
	if diveBoost# > 0 and heroY# <= 0
		IncSpriteY(hero, (1-diveHop#)*(-diveBoost#*36 - 10))
		SetSpriteAngle(hero, Max(-5, -diveBoost#*15 + 20))
		//Print(GetSpriteAngle(hero))
	else
		SetSpriteAngle(hero, 0)
	endif
	if diveHop# > 0 then diveHop# = GlideNumToZero(diveHop#, 44)
	//inc diveHop#, diveHopRise*fpsr#
	//Print(diveHop#)
	if inputLeft
		inc heroX#, -waterSpeedX#*1.5*fpsr#
	endif
	if inputRight
		inc heroX#, waterSpeedX#*1.5*fpsr#
	endif
	
	if stateRight
		//SetSpriteFlip(hero, 0, 0)
	elseif stateLeft
		//SetSpriteFlip(hero, 1, 0)
	endif
	
	//if (releaseLeft and stateRight = 0) or (releaseRight and stateLeft = 0) then PlaySprite(hero, 10, 0, 3, 4)
		
	if Abs(waterVelX#) < .01
		waterVelX# = 0
	else
		waterVelX# =  (((waterVelX#)*((64.0)^fpsr#))/(65.0)^fpsr#)
	endif
	//GlideNumToZero(waterVelX#, 40)
	
	if stateLeft then waterVelX# = -waterSpeedX#
	if stateRight then waterVelX# = waterSpeedX#

	inc heroX#, waterVelX#*fpsr#
	
	if diveDamage
		SetSpriteAngle(hero, Mod(heroY#*7, 360))
		diveVelY# = -0.4
		inc heroLocalDistance#, fixedWater2Speed#*fpsr#*2/3
		SetSpriteColor(hero, 255, 100, 100, 255)
		if heroY# < 0
			diveDamage = 0
			SetSpriteColor(hero, 255, 255, 255, 255)
		endif
	else
		//Diving
		if stateSpace and heroY# <= 0
			//Diving sound
			if GetSoundPlayingR(bubbleS) = 0 then PlaySound(bubbleS, volumeS/2)
			SetParticlesPosition(splashP, GetSpriteMiddleX(hero), (GetSpriteMiddleY(water2S)) + GetSpriteHeight(hero)/2)
			ResetParticleCount(splashP)
		endif
		if stateSpace
			
			if heroY# <= 0
				diveDeepTimer# = 0
			endif
			
			if ((heroY# > 0 and diveVelY# >= (diveVelMax#-diveVelY#)) or heroY# <= 0) and diveDeepTimer# < diveDeepTimerMax#
				//Setting the dive to the max strength, but only when above water OR when currently underwater and diving
				diveVelY# = diveVelMax# + diveVelMax#*0.2*(diveDeepTimerMax#-diveDeepTimer#)
				
				SetSpriteAngle(hero, diveVisAngle)
				
			endif
			
			diveHop# = 1
			inc diveDeepTimer#, GetFrameTime()
			
		endif
		if heroY# > 0
			//Rising the duck back up, if space is no longer held
			if (diveDeepTimer# >= diveDeepTimerMax#) or stateSpace = 0 then diveVelY# = diveVelY# - diveRise#*fpsr#
			
			SetSpriteAngle(hero, diveVisAngle*(diveVelY#))
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
			if diveBoostQueue <> 0
				PlaySound(WindSS)
				inc diveBoost#, diveBoostQueue
				diveBoostQueue = 0
				diveHop# = 1
				PlaySprite(hero, 10, 1, 5, 7)
				SetParticlesPosition(featherP, GetSpriteX(hero), GetSpriteMiddleY(hero))
				ResetParticleCount(featherP)
				PlaySound(flyoutS, volumeS/2)
			endif
		endif
	endif
	
	inc heroY#, diveVelY#*fpsr#
	
	//Print(heroY#)
	//Print(diveBoost#)
	//Print(diveDeepTimer#)
	//Print(diveDeepTimerMax#)
	//Print(GetSpriteAngle(hero))
	
	
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
	if diveBoost# > 0
		dec heroLocalDistance#, fixedWater2Speed#*fpsr# * diveBoost#*1.8
		dec diveBoost#, diveBoostSlow#*fpsr#
	endif
		
		
	if heroY# > 0 and diveBoost# <= 0
		StopSprite(hero)
		SetSpriteFrame(hero, 5)
	elseif diveBoost# <= 0
		if GetSpriteCurrentFrame(hero) > 4 then PlaySprite(hero, 10, 1, 1, 4)
		
	endif
	
	SetSpritePosition(duck, -1*(duckDistance# - 20000*(raceQueue.length+1)) - (water2Distance-heroLocalDistance#)+80, 70+4*cos(gameTime#*2))
	//Print(GetSPriteX(duck))
	//Print(raceSize)
	//Print(raceQueue.length)
	//SetSpriteFrame(bg3, 1+8.0*(Round(waterDistance-heroLocalDistance#)/(1.0*waterDistance)))
	
	//SetSpriteX(heroIcon, GetSpriteX(progBack)-GetSpriteWidth(heroIcon)/2 + (GetSpriteWidth(progBack)*(waterDistance - heroLocalDistance#)/waterDistance)/areaSeen)
	//SetSpriteX(duckIcon, Min(GetSpriteX(progBack)-GetSpriteWidth(duckIcon)/2 + (GetSpriteWidth(progBack)*(20000 - (duckDistance#-40000))/20000)/areaSeen, GetSpriteX(progBack)+GetSpriteWidth(progBack)-GetSpriteWidth(duckIcon)))
	
	deleted = 0
	for i = 1 to spawnActive.length
		spr = spawnActive[i].spr
		if i = spawnActive.length then spawnActive[i].x = water2Distance-30+heroX#
		SetSpriteX(spr, spawnActive[i].x-(water2Distance-heroLocalDistance#))
		if GetSpriteGroup(spr) <> SCRAP then SetSpriteY(spr, spawnActive[i].y)
		if GetSpriteVisible(spr)
			if GetSpriteCollision(spr, hero) and Abs((GetSpriteY(hero) - GetSpriteY(spr))) < 80
				
				if spawnActive[i].cat = GOOD
					if GetSpriteColorGreen(hero) <> 100 then inc diveBoostQueue, 1
					PlaySound(collectS, volumeS)
					//boatSpeed# = Max(boatSpeed#, sqrt(Min(boatSpeedMax, 20)*1.5))
					
					//PlaySound(rowGoodS, VolumeS*.8)
				elseif spawnActive[i].cat = BAD
					diveDamage = 1
					if GetSpriteColorGreen(hero) = 255 then PlaySound(hitS, volumeS)
					diveBoost# = diveBoost#*2/3
					diveBoostQueue = 0
					//if damageAmt# <= 0
					//	damageAmt# = 255
					//	boatSpeed# = 0
					//	PlaySound(hitS, volumeS)
					//endif
					//Sound effect
					//SetSpriteColor(hero, 255, 100, 100, 255)
				elseif GetTweenExists(spr) = 0 //SCRAP
					CollectScrap(WATER2)
					SetSpriteGroup(spr, SCRAP)
					PlaySprite(spr, 30)
					CreateTweenSprite(spr, .6)
					SetTweenSpriteY(spr, GetSpriteY(spr), GetSpriteY(spr) - GetSpriteHeight(spr)*1.5, TweenSmooth1())
					//SetTweenSpriteAlpha(spr, 255, 0, TweenEaseOut2())
					PlayTweenSprite(spr, spr, 0)
					PlayTweenSprite(tweenSprFadeOut, spr, .1)
				endif
				if spawnActive[i].cat <> RAMP and GetSpriteWidth(spr) = GetSpriteHeight(spr) and GetSpriteGroup(spr) <> SCRAP
					deleted = i
					i = spawnActive.length
				endif
				
				
			endif
			if spawnActive[i].cat = BAD and GetSpriteX(spawnActive[i].spr) < (w/5 + w/6*diveLevel)
				SetSpriteAngle(spr, 6.0*cos(gameTime#))
				spawnActive[i].x = spawnActive[i].x - 0.2*diveLevel*fpsr#
				if GetSpriteCurrentFrame(spr) <= 2 then PlaySprite(spr, 10, 1, 3, 4)
			endif
			if spawnActive[i].cat = GOOD
				SetSpriteColorBlue(spr, 185 + 70*sin( spawnActive[i].x-heroLocalDistance#))
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
	
	if diveBoost# > 0 or diveBoostQueue > 0
		SetSpriteSize(featherBoostS, 30*(diveBoost#+diveBoostQueue)*(2+upgrades[2, 4]), GetSpriteHeight(featherBoostS))
	else
		SetSpriteSize(featherBoostS, 0, GetSpriteHeight(featherBoostS))
	endif
	
	
	Print(GetSpriteX(duck))
	

	
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
