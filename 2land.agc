#include "main.agc"
// File: 2land.agc
// Created: 24-10-03

#constant landDistance 20000
global heroYLow# = 0
global heroVelY# = 0
#constant gravity# 3.2

global fixedLandSpeed# = .7

global landSpeedX# = 0.65
global landChargeSpeed# = 0.2
global landSlowDown# = 1



global boostTotal = 3
global boostAmt# = 0
global activeBoost# = 0
global boostSpeed# =  8.4
global boostRecharge# = .0024
global boostDrain# = .02

function InitLand()
	
	
	SetMusicVolumeOGG(landM, 100)
	
	CreateSpriteExpress(hero, 128, 128, w, h, 10)
	heroX# = w/2
	heroY# = h*2/3 - 20
	heroYLow# = heroY#
	
	heroImg1 = LoadImage("L_D"+str(1+upgrades[3,2])+"_1.png")
	heroImg2 = LoadImage("L_D"+str(1+upgrades[3,2])+"_2.png")
	heroImg3 = LoadImage("L_D"+str(1+upgrades[3,2])+"_3.png")
	
	AddSpriteAnimationFrame(hero, heroImg1)
	AddSpriteAnimationFrame(hero, heroImg3)
	AddSpriteAnimationFrame(hero, heroImg2)
	SetSpriteFrame(hero, 1)
	SetSpriteShape(hero, 3)
	
	CreateSpriteExpress(hero2, 128, 128, w, h, 9)
	
	hero2Img1 = LoadImage("L_D"+str(1+upgrades[3,2])+"M1_1.png")
	hero2Img2 = LoadImage("L_D"+str(1+upgrades[3,2])+"M1_2.png")
	hero2Img3 = LoadImage("L_D"+str(1+upgrades[3,2])+"M1_3.png")
	hero2Img4 = LoadImage("L_D"+str(1+upgrades[3,2])+"M1_4.png")
	hero2Img5 = LoadImage("L_D"+str(1+upgrades[3,2])+"M1_5.png")
	hero2Img6 = LoadImage("L_D"+str(1+upgrades[3,2])+"M1_6.png")
	AddSpriteAnimationFrame(hero2, hero2Img1)
	AddSpriteAnimationFrame(hero2, hero2Img2)
	AddSpriteAnimationFrame(hero2, hero2Img3)
	AddSpriteAnimationFrame(hero2, hero2Img4)
	AddSpriteAnimationFrame(hero2, hero2Img5)
	AddSpriteAnimationFrame(hero2, hero2Img6)
	PlaySprite(hero2, 15, 1, 1, 2)
	
	//Setting the variables based on upgrades
	//fixedLandSpeed# = 0.7 * (1 + .8*upgrades[1, 2] + .6*upgrades[1, 2]/3) //V5 stats
	fixedLandSpeed# = 0.6 * (1 + .5*upgrades[1, 2])
	boostTotal = 3 + 1*upgrades[2, 2] + 1*upgrades[2, 2]/3
	landSlowDown# = 1 * (1 - .25*upgrades[3, 2] + .15*upgrades[3, 2]/3)
	boostSpeed# = 4.4 * (1 + 0.6*upgrades[4, 2] + 0.6*upgrades[4, 2]/2 + 2.6*upgrades[4, 2]/3)
	
	LoadAnimatedSprite(landBoost1, "bolt", 10)
	SetSpriteExpress(landBoost1, 50, 50, 300, 630, 5)
	PlaySprite(landBoost1, 5, 1, 1, 4)
	for i = landBoost1+1 to landBoost1 - 1 + boostTotal
		CreateSpriteExistingAnimation(i, landBoost1)
		SetSpriteExpress(i, 50, 50, 300 + (i-landBoost1)*70, 630, 5)
		PlaySprite(i, 5, 1, 1, 4)
	next i
	
	
	
	areaSeen = Max(areaSeen, 2)
	
	LoadAnimatedSprite(duck, "duckl", 2)
	PlaySprite(duck, 30, 1, 1, 2)
	SetSpriteDepth(duck, 30)
	SetSpriteSizeSquare(duck, 70)
	SetSpriteY(duck, h/2+20)
	
	SetSpriteVisible(landS, 1)
	SetSpriteSizeSquare(landS, w)
	SetSpriteMiddleScreen(landS)
	IncSpriteY(landS, -220)
	SetSpriteDepth(landS, 90)
	
	LoadSpriteExpress(rail1, "rail.png", 4000*.6, 140*.6, 0, 240, 40)
	//LoadSpriteExpress(rail2, "rail.png", 3000*.6, 140*.6, GetSpriteWidth(rail1), 240, 40)
	
	//Setting the variables based on upgrades
	//4th upgrade spot
							
	//Spawnables for the land
	newS as spawn
	for i = 3 to 22
		newS.spr = spawnS
		rnd = Random(1, 9)
		if rnd <= 2 then newS.cat = GOOD
		if rnd >= 3 and rnd <= 5 then newS.cat = BAD
		if rnd >= 6 and rnd <= 9 then newS.cat = SCRAP
		newS.x = i*landDistance/22 + Random(0, 300) - 2000
		//newS.y = i*waterDistance/25 + 00 + Random(0, 400)
		
		if newS.cat = GOOD
			CreateSpriteExistingAnimation(spawnS, landBoost1)
			PlaySprite(spawnS, 5, 1, 1, 4)
			SetSpriteSizeSquare(spawnS, 70)
			SetSpriteY(spawnS, Random(250, 480))
			SetSpriteDepth(spawnS, 8)
		elseif newS.cat = BAD
			LoadAnimatedSprite(spawnS, "terrain" + Str(Random(1,3)) + "_", 5)
			SetSpriteSize(spawnS, 260*1.221, 110*1.221)
			SetSpritePosition(spawnS, w/2, 480)
			SetSpriteDepth(spawnS, 20)
			SetSpriteShape(spawnS, 3)
		else
			LoadSpriteExpress(spawnS, "scrap" + Str(1 + Random(1,3)) + ".png", 10, 10, w, h, 8)
			SetSpriteY(spawnS, Random(250, 480))
			SetSpriteSizeSquare(spawnS, 50)
		endif
		spawnActive.insert(newS)
		inc spawnS, 1
	next i
	
	
	//Gameplay setting
	heroLocalDistance# = landDistance

	boostAmt# = boostTotal
	
endfunction

function DoLand()
	
	heroX# = Min(Max(heroX#, 50), 600)
	SetSpritePosition(hero, heroX#, heroY# + 4*Abs(sin(gameTime#/3)) + 6*Abs(cos(gameTime#/2)))
	//Lag
	inc heroX#, -.2*fpsr#
	
	if inputSelect and boostAmt# >= 1
		//Boost
		dec boostAmt#, 1
		activeBoost# = 1
		PlaySound(boostS, volumeS)
	endif
	
	if boostAmt# < boostTotal then inc boostAmt#, boostRecharge#
	
	if activeBoost# > 0
		dec heroLocalDistance#, boostSpeed#
		dec activeBoost#, boostDrain#
		inc heroX#, .4*fpsr#
	endif
	
	if inputUp and heroY# = heroYLow#
		//Jump
		heroVelY# = -80*9
		dec heroY#, 3
		SetSpriteFrame(hero, 3)
		PlaySprite(hero2, 15, 1, 5, 6)
		PlaySound(jumpS, volumeS)
	endif
	if heroY# <> heroYLow#
		inc heroY#, heroVelY#*fpsr#/400
		inc heroVelY#, gravity#*fpsr#
		if heroVelY# > -60 and GetSpriteCurrentFrame(hero) = 3
			SetSpriteFrame(hero, 2)
			PlaySprite(hero2, 15, 1, 3, 4)
		endif
		if heroY# > heroYLow#
			heroY# = heroYLow#
			heroVelY# = 0
			SetSpriteFrame(hero, 1)
			PlaySprite(hero2, 15, 1, 1, 2)
		endif
		
	endif
	
	if inputLeft then inc heroX#, -landSpeedX#*1.5*fpsr#
	if inputRight then inc heroX#, landSpeedX#*1.5*fpsr#
	if stateLeft then inc heroX#, -landSpeedX#*fpsr#
	if stateRight then inc heroX#, landSpeedX#*fpsr#
	
	for i = landBoost1 to landBoost1 - 1 + boostTotal
		//Cut the sprite to make it recharge
		if (i - landBoost1 + 1) <= boostAmt#
			if GetSpriteCurrentFrame(i) > 4 then PlaySprite(i, 5, 1, 1, 4)
		else
			//SetSpriteFrame(i, 4 + Max(0, Min(6, Round(.5+(i - landBoost1 + 1) - boostAmt#)*6)))
			//SetSpriteFrame(i, 5)
			SetSpriteFrame(i, Random(5,9))
		endif
		//Print((i - landBoost1 + 1) - boostAmt#)
	next i 
	
	SetSpriteX(heroIcon, GetSpriteX(progBack)-GetSpriteWidth(heroIcon)/2 + (GetSpriteWidth(progBack)*(landDistance - heroLocalDistance#)/landDistance)/areaSeen + (GetSpriteWidth(progBack)/areaSeen))
	SetSpriteFrame(landS, 1+Mod(Round(landDistance-heroLocalDistance#)/6, 60))
	SetSpriteX(duckIcon, Min(GetSpriteX(progBack)-GetSpriteWidth(duckIcon)/2 + (GetSpriteWidth(progBack)*(40000 - (duckDistance#-20000))/20000)/areaSeen, GetSpriteX(progBack)+GetSpriteWidth(progBack)-GetSpriteWidth(duckIcon)))
	SetSpriteX(duck, (heroLocalDistance#-(duckDistance#-20000)))
	
	SetSpriteX(rail1, -GetSpriteWidth(rail1)/4+Mod(20000+heroLocalDistance#/2.5, GetSpriteWidth(rail1)/4))
	
	if damageAmt# > 0
		newC = GetSpriteColorGreen(hero)
		dec damageAmt#, fpsr#/3
		inc heroLocalDistance#, fixedLandSpeed#*fpsr#/(255.0/damageAmt#)*landSlowDown#
		SetSpriteColor(hero, 255, 255-damageAmt#, 255-damageAmt#, 255)
	endif
	
	deleted = 0
	for i = 1 to spawnActive.length
		spr = spawnActive[i].spr
		SetSpriteX(spr, (heroLocalDistance#-spawnActive[i].x))
		if spawnActive[i].cat = BAD then SetSpriteFrame(spr, Max(Min(5, 5-(GetSpriteX(spr)/(w/5))), 1))
		
		if GetSpriteVisible(spr)
			if GetSpriteCollision(spr, hero) //and Abs((GetSpriteY(hero) - GetSpriteY(spr))) < 80
				
				if spawnActive[i].cat = GOOD
					boostAmt# = Min(boostAmt# + 1, boostTotal)
					PlaySound(boostChargeS, volumeS*0.6)
				elseif spawnActive[i].cat = BAD
					if damageAmt# <= 0 and heroVelY# = 0
						damageAmt# = 255
						activeBoost# = 0
						PlaySound(hitS, volumeS)
					endif
				else //SCRAP
					CollectScrap(LAND)
				endif
				if spawnActive[i].cat <> BAD then deleted = i
				//i = spawnActive.length
				
			endif
		endif
	next i
	if deleted <> 0
		if spawnActive[deleted].cat = BAD
			DeleteAnimatedSprite(spawnActive[deleted].spr)
		else
			DeleteSprite(spawnActive[deleted].spr)
		endif
		spawnActive.remove(deleted)
	endif
	
	dec heroLocalDistance#, fixedLandSpeed#*fpsr#
	
	if heroLocalDistance# < 300
		IncSpriteY(hero, -(300-heroLocalDistance#)*2.5)
		SetSpriteFrame(hero, 3)
		SetSpriteFrame(hero2, 6)
		if GetSoundInstances(windBoostS) = 0 then PlaySound(windBoostS, volumeS*.8)
	endif
	
	//print(heroLocalDistance#)
	//print(boostAmt#)
	
endfunction
