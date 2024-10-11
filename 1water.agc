#include "main.agc"
#include "constants.agc"
// File: 1water.agc
// Created: 24-10-03

#constant waterDistance 20000

global waterSpeedX# = 0.35
global waterVelX# = 0
global waterBarSize = 210

global chargeC# = 0
global chargeM = 600
global chargeSpeed# = .6
global rowCoolDown# = 0
global rowCoolDownMax = 450
global boatSpeedMax = 15
global boatSpeed# = 0
global boatSpeedLoss# = .01
global fixedWaterSpeed# = .013
global frameCheck = 0

function InitWater()
	
	heroX# = w/2
	heroY# = h*2/3 - 50
	CreateSpriteExpress(hero, 140, 140, w, h, 10)
	
	activeBoost# = 0
	boatSpeed# = 0
	chargeC# = 0
	
	heroImg1 = LoadImage("W_D"+str(1+upgrades[3,1])+"_1.png")
	heroImg2 = LoadImage("W_D"+str(1+upgrades[3,1])+"_3.png")
	heroImg3 = LoadImage("W_D"+str(1+upgrades[3,1])+"_5.png")
	
	AddSpriteAnimationFrame(hero, heroImg2)
	AddSpriteAnimationFrame(hero, heroImg3)
	AddSpriteAnimationFrame(hero, heroImg2)
	AddSpriteAnimationFrame(hero, heroImg1)
	SetSpriteFrame(hero, 4)
	SetSpriteShape(hero, 3)
	
	LoadAnimatedSprite(duck, "duckW", 3)
	SetSpriteFrame(duck, 1)
	SetSpriteDepth(duck, 5)
	
	CreateSpriteExpress(waterBarBack, waterBarSize, 49, 0, 610, 9)
	SetSpriteMiddleScreenX(waterBarBack)
	SetSpriteColor(waterBarBack, 205, 130, 20, 0)
	LoadAnimatedSprite(waterBarFront, "waterbar", 29)
	SetSpriteExpress(waterBarFront, GetSpriteWidth(waterBarBack), GetSpriteHeight(waterBarBack), GetSpriteX(waterBarBack), GetSpriteY(waterBarBack), 7)
	SetSpriteColor(waterBarFront, 235, 235, 235, 255)
	
	SetSpriteVisible(waterS, 1)
	SetSpriteSizeSquare(waterS, w)
	SetSpriteMiddleScreen(waterS)
	SetSpriteDepth(waterS, 90)
	
	//Setting the variables based on upgrades
	fixedWaterSpeed# = (0.092) * (1 + 0.8*upgrades[1, 1] + 0.9*upgrades[1, 1]/2 + 1.7*upgrades[1, 1]/3)	//V5 .88
	boatSpeedMax = (13) * (1 + .5*upgrades[2, 1] + .3*upgrades[2, 1]/3)	//V5 12
	chargeSpeed# = (.6) * (1 + 0.2*upgrades[3, 1] + 0.1*upgrades[3, 1]/2 + 0.3*upgrades[3, 1]/3)
	waterSpeedX# = (0.35) * (1 + 0.3*upgrades[4, 1] + 0.2*upgrades[4, 1]/3)
	
	areaSeen = Max(areaSeen, 1)
	
	
	newS as spawn
	for i = 1 to 60
		//Bouys
		newS.spr = spawnS
		LoadSpriteExpress(spawnS, "buoy2.png", 10, 10, w, h, 8)
		SetSpriteShape(spawnS, 3)
		newS.cat = BAD
		newS.x = -110
		newS.y = i*waterDistance/50 + 2500
		newS.size = 100
		spawnActive.insert(newS)
		inc spawnS, 1
	next i
	
	
	for i = 4 to 25
		newS.spr = spawnS
		newS.cat = Random(1, SCRAP+1)
		if newS.cat = SCRAP+1 then newS.cat = SCRAP
		newS.x = Random(0, 240)-80
		newS.y = i*waterDistance/25 + 100 + Random(0, 400)
		
		if i = 25 then newS.cat = SCRAP
		
		if newS.cat = GOOD
			LoadAnimatedSprite(spawnS, "current", 8)
			SetSpriteDepth(spawnS, 8)
			PlaySprite(spawnS, 20, 1, 1, 8)
			newS.size = 100
		elseif newS.cat = BAD
			LoadSpriteExpress(spawnS, "buoy1.png", 10, 10, w, h, 8)
			SetSpriteShape(spawnS, 3)
			newS.size = 100
		else
			LoadSpriteExpress(spawnS, "scrap1.png", 10, 10, w, h, 8)
			newS.size = 100
		endif
		spawnActive.insert(newS)
		inc spawnS, 1
	next i

	newS.spr = spawnS
	newS.cat = RAMP
	newS.x = 100
	newS.y = 3200
	LoadSprite(spawnS, "ramp.png")
	SetSpriteDepth(spawnS, 18)
	newS.size = 100
	spawnActive.insert(newS)
	inc spawnS, 1
	
	LoadAnimatedSprite(cutsceneSpr, "traffic", 4)
	SetSpriteMiddleScreen(cutsceneSpr)
	PlaySprite(cutsceneSpr, 1, 0, 1, 4)
	SetSpriteDepth(cutsceneSpr, 2)
	
	//Gameplay setting
	heroLocalDistance# = waterDistance
	waterVelX# = 0
	
endfunction

function DoWater()
	
	if GetSpriteCurrentFrame(cutsceneSpr) < 4
		
		gameTime# = 0
		
		SetSpritePosition(hero, heroX#, heroY# + 10*Abs(sin(gameTime#/8)) + 6*Abs(cos(gameTime#/3)))
		DrawWater()
		IncSpriteY(duck, 10*Abs(sin(gameTime#/9)) + 5*Abs(cos(gameTime#/4)))
		
		if frameCheck <> GetSpriteCurrentFrame(cutsceneSpr) and GetSpriteCurrentFrame(cutsceneSpr) <> 1
			PlaySound(beepReadyS, volumeS)
			frameCheck = GetSpriteCurrentFrame(cutsceneSpr)
		endif
		
	else
		if GetSpritePlaying(duck) = 0
			PlaySound(beepGoS, volumeS)
			PlaySound(windSS, volumeS)
			PlaySprite(duck, 20, 1, 2, 3)
			StopMusicOGG(waterM)
			StopMusicOGG(landM)
			StopMusicOGG(airM)
			PlayMusicOGG(waterM, 0)
			PlayMusicOGG(landM, 0)
			PlayMusicOGG(airM, 0)
			SetMusicVolumeOGG(waterM, 100)
			SetMusicVolumeOGG(landM, 0)
			SetMusicVolumeOGG(airM, 0)
		endif
		IncSpriteY(cutsceneSpr, -2*fpsr#)
		//waterXMax = -
		heroX# = Min(Max(heroX#, 195), 1080)
		SetSpritePosition(hero, heroX#, heroY# + 10*Abs(sin(gameTime#/8)) + 6*Abs(cos(gameTime#/3)))
		
		DrawWater()
		
		//SetSpriteColor(hero, GetSpriteColorRed(hero) - 1, GetSpriteColorRed(hero) - 1, GetSpriteColorRed(hero) - 1,255)
		
		if rowCoolDown# > 0
			dec rowCoolDown#, 1*fpsr#
			if rowCoolDown# <= 0 then chargeC# = 0
		else
			inc chargeC#, chargeSpeed#*fpsr#
			SetSpriteColor(waterBarFront, 235, 235, 235, 255)
			if chargeC# > chargeM
				SetSpriteColor(waterBarFront, 225, 255, 255, 255)
				if GetSoundInstances(rowReadyS) = 0 then PlaySound(rowReadyS, volumeS*.8)
			endif
		endif
		if chargeC# > chargeM*1.3 then chargeC# = 10
		SetSpriteFrame(waterBarFront, 1 + 28*Min(Round(chargeC#), chargeM)*1.0/chargeM*1.0)
		//waterBarSize*(Min(Round(chargeC#), chargeM)*1.0/chargeM*1.0), GetSpriteHeight(waterBarFront))
		
		
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
		
		//Rowing
		if inputSelect and rowCoolDown# <= 0
			
			rowCoolDown# = rowCoolDownMax
			
			SetSpriteColor(waterBarFront, 255, 210, 210, 255)
			if GetSpriteCurrentFrame(waterBarFront) = 29 then SetSpriteColor(waterBarFront, 180, 255, 255, 255)
			
			boatSpeed# = Max(boatSpeed#, sqrt(boatSpeedMax*1.0*Min(Round(chargeC#), chargeM)/chargeM))
			if GetSpriteCurrentFrame(waterBarFront) = 29
				boatSpeed# = boatSpeed#*1.2
				PlaySound(rowGoodS, volumeS*0.8)
				PlaySound(windSS, volumeS)
			else
				PlaySound(rowBadS, volumeS)
			endif
			//Print(boatSpeed#)
			//Sync()
			//Sleep(1000)
		endif
		
		SetSpriteFrame(waterS, 1+Mod(Round(waterDistance-heroLocalDistance#)/6, 52))
		
		if damageAmt# > 0
			newC = GetSpriteColorGreen(hero)
			
			dec damageAmt#, fpsr#/3
			
			inc heroLocalDistance#, fixedWaterSpeed#*fpsr#/(255.0/damageAmt#)
			
			SetSpriteColor(hero, 255, 255-damageAmt#, 255-damageAmt#, 255)
		endif
		
		if boatSpeed# > 0
			dec heroLocalDistance#, boatSpeed#*fpsr#
			dec boatSpeed#, boatSpeedLoss#*fpsr#
			
			if boatSpeed# <= 0
				
				
			endif
		endif
		dec heroLocalDistance#, fixedWaterSpeed#*fpsr#
		
		SetSpriteFrame(bg3, 1+8.0*(Round(waterDistance-heroLocalDistance#)/(1.0*waterDistance)))
		
		SetSpriteX(heroIcon, GetSpriteX(progBack)-GetSpriteWidth(heroIcon)/2 + (GetSpriteWidth(progBack)*(waterDistance - heroLocalDistance#)/waterDistance)/areaSeen)
		SetSpriteX(duckIcon, Min(GetSpriteX(progBack)-GetSpriteWidth(duckIcon)/2 + (GetSpriteWidth(progBack)*(20000 - (duckDistance#-40000))/20000)/areaSeen, GetSpriteX(progBack)+GetSpriteWidth(progBack)-GetSpriteWidth(duckIcon)))
		
		deleted = 0
		for i = 1 to spawnActive.length
			spr = spawnActive[i].spr
			if GetSpriteVisible(spr)
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
		
		//Print(fixedWaterSpeed#)
	endif
	
	
endfunction

function DrawWater()
	//Updating the duck first
	spr = duck
	dis = (duckDistance#-37500)	//This should probably be 40000, once the game actually starts without an FPS spike
	SetSpriteSizeSquare(spr, Max(1, 100 - (heroLocalDistance# - dis)/10.0 - 210))
	if GetSpriteWidth(spr) < 8
		SetSpriteVisible(spr, 0)
	else
		SetSpriteVisible(spr, 1)
	endif
	SetSpritePosition(spr, w/2 - GetSpriteWidth(spr)/2 - (heroLocalDistance# - dis)/7*(-160.0/100), -GetSpriteHeight(spr)/2 - (heroLocalDistance# - dis)/5)
	if GetSpriteY(hero)+120 < GetSpriteY(spr)
		SetSpriteColorAlpha(spr, (255 - Min(255, -(GetSpriteY(hero)+120) + 2.4*(GetSpriteY(spr)-GetSpriteY(hero)+120))))
		if GetSpriteColorAlpha(spr) <= 10 then SetSpriteVisible(spr, 0)
	endif
	//Print(duckDistance#)
	//Print(dis)
	//Print(GetSpriteX(duck))
	
	for i = 1 to spawnActive.length
		//if i = 61 then Print(spawnActive[i].y)
		spr = spawnActive[i].spr
		SetSpriteSizeSquare(spr, Max(1, spawnActive[i].size - (heroLocalDistance# - spawnActive[i].y)/10.0 - 210))
		if GetSpriteWidth(spr) < 8
			SetSpriteVisible(spr, 0)
		else
			SetSpriteVisible(spr, 1)
		endif
		SetSpritePosition(spr, w/2 - GetSpriteWidth(spr)/2 - (heroLocalDistance# - spawnActive[i].y)/7*(spawnActive[i].x/100), -GetSpriteHeight(spr)/2 - (heroLocalDistance# - spawnActive[i].y)/5)
		if GetSpriteY(hero)+120 < GetSpriteY(spr)
			SetSpriteColorAlpha(spr, (255 - Min(255, -(GetSpriteY(hero)+120) + 2.4*(GetSpriteY(spr)-GetSpriteY(hero)+120))))
			if GetSpriteColorAlpha(spr) <= 10 then SetSpriteVisible(spr, 0)
		endif
	next i
	
	//Changeing the ramp
	SetSpriteSize(spr, GetSpriteWidth(spr)*3, GetSpriteHeight(spr)*1.5)
	IncSpriteX(spr, -GetSpriteWidth(spr))
	IncSpriteY(spr, -GetSpriteHeight(spr))
	
endfunction

