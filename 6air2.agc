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
global scrapErupted = 0

global air2X# = 200
#constant heroAir2Y 190

function InitAir2()
	
	heroLocalDistance# = air2Distance
	
	SetViewZoomMode(1)
	
	LoadSpriteExpress(hero, "duckA2.png", 100, 100, w/2, h/2 + heroAir2Y, 7)
	FixSpriteToScreen(hero, 0)
	
	//LoadAnimatedSprite(air2BG, "mbg\m4", 8)
	CreateSprite(air2BG, 0)
	for i = 4 to 1 step -1
		num = i
		if i = 3 then num = 4
		if i = 4 then num = 8
		for j = 1 to num*2
			img = LoadImage("mbg\m" + str(num) + "0" + str(j) + ".png")
			AddSpriteAnimationFrame(air2BG, img)
			trashBag.insert(img)
		next j
	next i
	SetSpriteExpress(air2BG, h*2, h, 0, 0, 200)
	SetSpriteMiddleScreen(air2BG)
	PlaySprite(air2BG, 5+10, 1, 1, 16)
	FixSpriteToScreen(air2BG, 1)
	SetSpriteColorAlpha(air2BG, 170)
	
	LoadSpriteExpress(air2BBG, "noise.png", w, h*2, 0, -h, 300)
	FixSpriteToScreen(air2BBG, 1)
	SetSpriteColor(air2BBG, 255, 181, 117, 255)
	
	slipEnd = 0
	for i = 1 to slipEnd
		slipS[i] = CreateSprite(0)
		spr = slipS[i]
		SetSpriteExpress(spr, slipWid, h*3, w/2, -h, 80)
		SetSpriteGroup(spr, AIR2)
		SetSpriteColorAlpha(spr, 100)
		FixSpriteToScreen(spr, 1)
		//Tessalate the slipstream image
		//SetSpriteExpress(slipS[i])
	next i
	
	
	newS as spawn
	iEnd = 0
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
	
	//Rivers
	riverI as integer[6]
	for i = 1 to 6
		riverI[i] = LoadImage("mesaBG\rivermain0" + str(i) + ".png")
		trashBag.insert(riverI[i])
	next i
	randomX1 = random(0, 800)
	for i = 0 to 11
		newS.spr = spawnS
		CreateSpriteExpressImage(spawnS, riverI[Random(1,6)], 416, 800, randomX1-650 + (Mod(i,2))*w, -800*((i/2)-1), 250)
		newS.y = GetSpriteY(spawnS)
		
		spawnActive.insert(newS)
		inc spawnS, 1
	next i
	
	//Shrubs
	shrubI as integer[6]
	for i = 1 to 6
		shrubI[i] = LoadImage("mesaBG\shrubpatch" + str(i) + ".png")
		trashBag.insert(shrubI[i])
	next i
	shrubSize = 180
	for i = 0 to 23
		newS.spr = spawnS
		CreateSpriteExpressImage(spawnS, shrubI[Random(1,6)], shrubSize, shrubSize, randomX1-650-200 - Random(0, 300) + w*Mod(i,3), Random(0, h)+h/2 - i/3*h, 250)
		newS.y = GetSpriteY(spawnS)
		
		spawnActive.insert(newS)
		inc spawnS, 1
	next i
	
	//Volcanoes
	/*
	volcanoI = LoadImage("mesaBG\volcano.png") //as integer[6]
	//for i = 1 to 6
		//volcanoI[i] = LoadImage("mesaBG\shrubpatch" + str(i) + ".png")
		trashBag.insert(volcanoI)
	//next i
	volcanoSize = 190
	for i = 0 to 14
		newS.spr = spawnS
		CreateSpriteExpressImage(spawnS, volcanoI, volcanoSize, volcanoSize, randomX1-650-200 - Random(0, 300) + w*Mod(i,3), Random(0, h)+h/2 - i/3*h, 250)
		newS.y = GetSpriteY(spawnS)
		//SetSpriteDepth(spawnS, 180)
		SetSpriteColor(spawnS, 255, 200, 140, 255)
		spawnActive.insert(newS)
		inc spawnS, 1
	next i
	*/
	//The evil bird
	eggBird = LoadSprite("mesaBG/mesaBird.png")
	SetSpriteExpress(eggBird, 129, 129, w/2-129/2, 80, 20)
	FixSpriteToScreen(eggBird, 1)
		
	
endfunction

function DoAir2()
	
	SetViewZoom(1 - .65*sqrt((air2Distance-heroLocalDistance#)/air2Distance))
	SetSpriteY(air2BBG, 0 - h*Mod(heroLocalDistance#, air2Distance*50)/(air2Distance*50))
	SetViewOffset(0, -(air2Distance-heroLocalDistance#)/10)
	
	//SetSpritePosition(hero, heroX#, 500)
	SetSpriteX(hero, air2X# + GetSpriteWidth(hero)/2)
	SetSpriteSize(hero, 100/GetViewZoom(), 100/GetViewZoom())
	SetSpriteY(hero, (h/2 + GetViewOffsetY()) + heroAir2Y*(1/GetViewZoom())) //-30 + 520*sqrt((air2Distance-heroLocalDistance#)/air2Distance))
	
	
	//dec heroLocalDistance#, 0.1*fpsr#
	
	if GetSpriteMiddleX(hero) > w/2 + 400/GetViewZoom() or (inputSelect and air2Dir# > 0) then air2TurnTarget = -1
	if GetSpriteMiddleX(hero) < w/2 - 400/GetViewZoom() or (inputSelect and air2Dir# < 0)  then air2TurnTarget = 1
	
	
	
	//Change the ducks acceleration
	air2Dir# = air2Dir# + air2Accel#*air2TurnTarget*fpsr#
	
	//Increase the duck X
	air2X# = air2X# + air2Vel#*air2Dir#/GetViewZoom()
	
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
		
		SetSpriteX(spr, (w/2 + (w/8)*(1*sin(1*waver#) + 2*sin(0.5*waver#) + 0.25*sin(4*waver#)))/GetViewZoom())
		
		//1*sin(1*X) + 2*sin(0.5*X) + 0.25*sin(4*X)
		
		
	next i
	
	
	
	
	inc heroLocalDistance#, -air2DefSpeed#*fpsr#*30
	if GetSpriteHitGroup(AIR2, GetSpriteMiddleX(hero), GetSpriteMiddleY(hero)) or GetSpriteHitGroup(AIR2, GetSpriteX(hero), GetSpriteMiddleY(hero)) or GetSpriteHitGroup(AIR2, GetSpriteX(hero)+GetSpriteWidth(hero), GetSpriteMiddleY(hero))
		inc heroLocalDistance#, -air2SlipSpeed#*fpsr#
		SetSpriteColor(hero, 0, 255, 0, 255)
	endif
	

	
	
	
	if heroLocalDistance# < air2Distance*3/5 and GetSpriteCurrentFrame(air2BG) <= 16 then PlaySprite(air2BG, 5+10, 1, 17, 24)
	if heroLocalDistance# < air2Distance*2/5 and GetSpriteCurrentFrame(air2BG) <= 24 then PlaySprite(air2BG, 5+10, 1, 25, 28)
	if heroLocalDistance# < air2Distance*1/5 and GetSpriteCurrentFrame(air2BG) <= 28 then PlaySprite(air2BG, 5+10, 1, 29, 30)
		
	
	
	
	
	deleted = 0
	for i = 1 to spawnActive.length
		spr = spawnActive[i].spr
		//if i = spawnActive.length then spawnActive[i].x = water2Distance-30+heroX#
		//Want width to be small, so that rivers/bushes aren't affected
		if GetSpriteWidth(spr) < 100
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
		else
			//For the larger background chunks
			SetSpriteY(spr, spawnActive[i].y + (air2Distance-heroLocalDistance#)/150.0)
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
	
	
	if scrapErupted = 0 and Mod(gameTime#, 800) = 1
		scrapErupted = 1
		MakeBullets()
	elseif Mod(gameTime#, 800) > 200
		scrapErupted = 0
	endif
	
	for i = 1 to bulletActive.length
		inc bulletActive[i].time, GetFrameTime()
		if bulletActive[i].time > 0 and bulletActive[i].time < 9999
			//Decrease the bullet's timer until it is below 0...
			//Then let the bullet ride!
			if GetSpriteVisible(bulletActive[i].spr) = 0 then SetSpriteVisible(bulletActive[i].spr, 1)
			
			if bulletActive[i].formula = 1 and GetSpriteGroup(bulletActive[i].spr) <> SCRAP
				originX = GetSpriteMiddleX(eggBird)
				originY = GetSpriteMiddleY(eggBird)
				SetSpriteX(bulletActive[i].spr, originX + 100*bulletActive[i].time/bulletActive[i].num)
				SetSpriteY(bulletActive[i].spr, originY + bulletActive[i].time*100)
			endif
			if bulletActive[i].time < 2.5 then SetSpriteAngle(bulletActive[i].spr, bulletActive[i].time*500)
			//Print(bulletActive[i].time)
			
			//Hatch the egg, becomes either scrap or evil bird
			if bulletActive[i].time > 2.5 and GetSpriteFrameCount(bulletActive[i].spr) = 1
				SetSpriteAngle(bulletActive[i].spr, 0)
				ClearSpriteAnimationFrames(bulletActive[i].spr)
				if bulletActive[i].isScrap = 1
					rnd = Random(1, 8)
					AddSpriteAnimationFrame(bulletActive[i].spr, scrapImgs[rnd, 3, 1])
					AddSpriteAnimationFrame(bulletActive[i].spr, scrapImgs[rnd, 3, 2])
					AddSpriteAnimationFrame(bulletActive[i].spr, scrapImgs[rnd, 3, 3])
					AddSpriteAnimationFrame(bulletActive[i].spr, scrapImgs[rnd, 3, 4])
					PlaySprite(bulletActive[i].spr, 10, 1, 1, 4)
				else
					AddSpriteAnimationFrame(bulletActive[i].spr, miniBird1I)
					AddSpriteAnimationFrame(bulletActive[i].spr, miniBird2I)
					PlaySprite(bulletActive[i].spr, 10, 1, 1, 2)
				endif
				
			endif
			
			if GetSpriteCollision(hero, bulletActive[i].spr)
				if bulletActive[i].isScrap = 0
					//Evil mini bird
					bulletActive[i].time = 9000
				else
					//Scrap
					CollectScrap(AIR2)
					spr = bulletActive[i].spr
					SetSpriteGroup(spr, SCRAP)
					PlaySprite(spr, 30)
					if GetTweenExists(spr) then DeleteTween(spr)
					CreateTweenSprite(spr, .6)
					SetTweenSpriteY(spr, GetSpriteY(spr), GetSpriteY(spr) - GetSpriteHeight(spr)*1.5, TweenSmooth1())
					PlayTweenSprite(spr, spr, 0)
					PlayTweenSprite(tweenSprFadeOut, spr, .1)
					bulletActive[i].time = 9999
				endif	
			endif
			
			if GetSpriteY(bulletActive[i].spr) > 2000
				bulletActive[i].time = 9999
			endif
		endif
	next i
	//Print(GetFrameTime())
	
endfunction

type bullet
	
	spr as integer
	time as float
	formula as integer
	isScrap as integer
	num as float //This is the number that will be plugged into the formula

endtype
global bulletActive as bullet[0]

function MakeBullets()
	
	if GetImageExists(eggBadI) = 0
		eggBadI = LoadImage("mesaBG/eggRed.png")
		eggGoodI = LoadImage("mesaBG/eggScrap.png")
		miniBird1I = LoadImage("mesaBG/minibird1.png")
		miniBird2I = LoadImage("mesaBG/minibird2.png")
	endif
	
	pattern = Random(1, 1)
	
	bulletAmt = 0
	if pattern = 1 then bulletAmt = 10
	
	scrapAmt = 0
	newB as bullet
	
	newB.formula = pattern
	
	for i = 1 to bulletAmt
		newB.spr = CreateSprite(eggBadI)
		FixSpriteToScreen(newB.spr, 1)
		SetSpriteVisible(newB.spr, 0)
		SetSpriteExpress(newB.spr, 30, 30, 0, 0, 40)
		newB.isScrap = 0
		
		if random(1, 15) = 15 and scrapAmt < 2
			newB.isScrap = 1
			inc scrapAmt, 1
			AddSpriteAnimationFrame(newB.spr, eggGoodI)
		else
			AddSpriteAnimationFrame(newB.spr, eggBadI)
		endif
		SetSpriteFrame(newB.spr, 1)
		
		newB.time = -i*0.3
		newB.num = -bulletAmt/2 + i + 0.5
		
		bulletActive.insert(newB)
	next i
	
endfunction