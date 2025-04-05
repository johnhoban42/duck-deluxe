#include "main.agc"
// File: 6air2.agc
// Created: 24-10-03

#constant air2Distance 20000

//The slipstream sprite
global slipS as integer[5]
global slipEnd = 3
global slipWid = 50

global air2Dir# = 1
global air2Vel# = 2.0
global air2Accel# = .015
global air2TurnTarget = 0

global air2DefSpeed# = 0.1
global air2SlipSpeed# = .2

global air2X# = 200

function InitAir2()
	
	heroLocalDistance# = air2Distance
	
	LoadSpriteExpress(hero, "duckA2.png", 100, 100, w/2, 500, 7)
	
	LoadAnimatedSprite(air2BG, "mbg\m4", 8)
	SetSpriteExpress(air2BG, h*2, h, 0, 0, 200)
	SetSpriteMiddleScreen(air2BG)
	PlaySprite(air2BG, 5, 1)
	
	for i = 1 to slipEnd
		slipS[i] = CreateSprite(0)
		spr = slipS[i]
		SetSpriteExpress(spr, slipWid, h*3, w/2, -h, 80)
		SetSpriteGroup(spr, AIR2)
		SetSpriteColorAlpha(spr, 100)
		//Tessalate the slipstream image
		//SetSpriteExpress(slipS[i])
	next i
	
	
	newS as spawn
	iEnd = 50
	for i = 1 to iEnd
		newS.spr = spawnS
		newS.cat = Random(1, 7)
		if newS.cat <= 3 then newS.cat = BAD
		if newS.cat = 4 or newS.cat = 5 then newS.cat = BAD
		if newS.cat = 6 or newS.cat = 7 then newS.cat = SCRAP
		//if i < 4 and newS.cat = BAD then newS.cat = SCRAP
		
		
		newS.x = Random(100, w-100)
		newS.y = -i*waterDistance/25 -100 + Random(0, 400)
		
		
		if i = iEnd then newS.cat = SCRAP
		
		if newS.cat = GOOD
			CreateSpriteExpress(spawnS, 10, 10, w, h, 8)
			PlaySprite(spawnS, 6)
			SetSpriteFrame(spawnS, Random(1, 6))
			newS.size = 60
			SetSpriteSizeSquare(spawnS, newS.size)
		elseif newS.cat = BAD
			CreateSpriteExpress(spawnS, 10, 10, w, h, 30)
			//AddSpriteAnimationFrame(spawnS, fish1I)
			//PlaySprite(spawnS, 3, 1, 1, 2)
			newS.size = 140
			
			SetSpriteSizeSquare(spawnS, newS.size)
			SetSpriteShapeCircle(spawnS, 0, 0, newS.size/2-30)
			SetSpriteColor(spawnS, 100, 100, 100, 255)
			//SetSpriteFlip(spawnS, 1, 0)
		else
			CreateSpriteExpress(spawnS, 10, 10, w, h, 8)
			for j = 1 to 4
				AddSpriteAnimationFrame(spawnS, scrapImgs[1, j, 1])//First index will be a random
			next j
			PlaySprite(spawnS, 3+Random(1,3))
			newS.size = 60
			SetSpriteSizeSquare(spawnS, newS.size)
			
		endif
		SetSpriteDepth(spawnS, 50)
		
		spawnActive.insert(newS)
		inc spawnS, 1
		
		
	next i
	
	
endfunction

function DoAir2()
	
	//SetSpritePosition(hero, heroX#, 500)
	
	SetSpriteX(hero, air2X#)
	
	dec heroLocalDistance#, 0.1*fpsr#
	
	if GetSpriteMiddleX(hero) > w - 100 or (inputSelect and air2Dir# > 0) then air2TurnTarget = -1
	if GetSpriteMiddleX(hero) < 100 or (inputSelect and air2Dir# < 0)  then air2TurnTarget = 1
	
	
	
	//Change the ducks acceleration
	air2Dir# = air2Dir# + air2Accel#*air2TurnTarget*fpsr#
	
	//Increase the duck X
	air2X# = air2X# + air2Vel#*air2Dir#
	
	print(air2X#)
	
	//The turn is done
	if abs(air2Dir#) > abs(air2TurnTarget) and air2TurnTarget <> 0
		air2Dir# = air2TurnTarget
		air2TurnTarget = 0
		//Put animation change here
		
	endif
	
	SetSpriteColor(hero, 255, 255, 255, 255)
	
	//Updating the slipstreams
	for i = 1 to slipEnd
		spr = slipS[i]
		waver# = gameTime#/(11-i) + 200*i
		
		SetSpriteX(spr, w/2 + (w/8)*(1*sin(1*waver#) + 2*sin(0.5*waver#) + 0.25*sin(4*waver#)))
		
		//1*sin(1*X) + 2*sin(0.5*X) + 0.25*sin(4*X)
		
		
	next i
	
	
	
	
	inc heroLocalDistance#, -air2DefSpeed#*fpsr#
	if GetSpriteHitGroup(AIR2, GetSpriteMiddleX(hero), GetSpriteMiddleY(hero)) or GetSpriteHitGroup(AIR2, GetSpriteX(hero), GetSpriteMiddleY(hero)) or GetSpriteHitGroup(AIR2, GetSpriteX(hero)+GetSpriteWidth(hero), GetSpriteMiddleY(hero))
		inc heroLocalDistance#, -air2SlipSpeed#*fpsr#
		SetSpriteColor(hero, 0, 255, 0, 255)
	endif
	
	//Progress bar at top
	SetSpriteX(heroIcon, GetSpriteX(progBack)-GetSpriteWidth(heroIcon)/2 + (GetSpriteWidth(progBack)*(waterDistance - heroLocalDistance#)/waterDistance)/areaSeen)
	SetSpriteX(duckIcon, Min(GetSpriteX(progBack)-GetSpriteWidth(duckIcon)/2 + (GetSpriteWidth(progBack)*(40000 - (duckDistance#-20000))/20000)/areaSeen, GetSpriteX(progBack)+GetSpriteWidth(progBack)-GetSpriteWidth(duckIcon)))
	
	
	
	deleted = 0
	for i = 1 to spawnActive.length
		spr = spawnActive[i].spr
		//if i = spawnActive.length then spawnActive[i].x = water2Distance-30+heroX#
		SetSpriteX(spr, spawnActive[i].x)
		SetSpriteY(spr, spawnActive[i].y+(air2Distance-heroLocalDistance#))
		//if GetSpriteGroup(spr) <> SCRAP then SetSpriteY(spr, spawnActive[i].y)
		if GetSpriteVisible(spr)
			
			if spawnActive[i].cat = SCRAP
				if GetSpriteGroup(spr) <> SCRAP then IncSpritePosition(spr, 60*cos(gameTime#/2), 40*sin(gameTime#/2))
			endif
			
			if GetSpriteCollision(spr, hero) and Abs((GetSpriteY(hero) - GetSpriteY(spr))) < 80
				
				if spawnActive[i].cat = GOOD
					if GetSpriteColorGreen(hero) <> 100 then inc diveBoostQueue, 1
					PlaySound(collectS, volumeS)
					//boatSpeed# = Max(boatSpeed#, sqrt(Min(boatSpeedMax, 20)*1.5))
					
					//PlaySound(rowGoodS, VolumeS*.8)
				elseif spawnActive[i].cat = BAD
					//diveDamage = 1
					if GetSpriteColorGreen(hero) = 255 then PlaySound(hitS, volumeS)
					SetSpriteColorGreen(hero, 0)
					SetSpriteColorBlue(hero, 0)
					//diveBoost# = 0
					//diveBoostQueue = 0
				elseif GetTweenExists(spr) = 0 //SCRAP
					CollectScrap(WATER2)
					SetSpriteGroup(spr, SCRAP)
					PlaySprite(spr, 30)
					CreateTweenSprite(spr, .6)
					SetTweenSpriteY(spr, GetSpriteY(spr), GetSpriteY(spr) - GetSpriteHeight(spr)*1.5, TweenSmooth1())
					//SetTweenSpriteAlpha(spr, 255, 0, TweenEaseOut2())
					PlayTweenSprite(spr, spr, 0)
					PlayTweenSprite(tweenSprFadeOut, spr, .1)
					spawnActive[i].x = GetSpriteX(spr)
				endif
				if spawnActive[i].cat <> RAMP and GetSpriteWidth(spr) = GetSpriteHeight(spr) and GetSpriteGroup(spr) <> SCRAP
					deleted = i
					i = spawnActive.length
				endif
				
				
			endif
			if spawnActive[i].cat = BAD and GetSpriteX(spawnActive[i].spr) < (w/5 + w/6*diveLevel)
				//SetSpriteAngle(spr, 6.0*cos(gameTime#))
				//spawnActive[i].x = spawnActive[i].x - 0.2*diveLevel*fpsr#
				//if GetSpriteCurrentFrame(spr) <= 2 then PlaySprite(spr, 10, 1, 3, 4)
			endif
			if spawnActive[i].cat = GOOD
				//SetSpriteColorBlue(spr, 185 + 70*sin( spawnActive[i].x-heroLocalDistance#))
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