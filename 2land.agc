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
