// File: 3air.agc
// Created: 24-10-03

#constant airDistance 20000
global fixedAirSpeed# = .31
global airSpeedMax# = 2
global airSpeed# = 0
global airSpeedLoss# = .01

global airSpeedX# = 0.39
global airSpeedY# = 0.28
global airVelX# = 0
global airVelY# = 0

global spinType = 0
global spinLeft# = 0

function DoAir()
	
	SetSpriteFrame(bg3, 1+12.0*(Round(airDistance-heroLocalDistance#)/(1.0*airDistance)))
	
	if spinLeft# > 0
		inc spinLeft#, -fpsr#
		
		if spinType = 1
			SetSpriteAngle(airS, 15*sin((spinLeft# - Pow(spinLeft#, 2)/6)/200))
			
		elseif spinType = 2
			SetSpriteAngle(airS, 30*sin((spinLeft# - Pow(spinLeft#, 2)/6)/400))
		else //3
			SetSpriteAngle(airS, (spinLeft#)*360.0/(1200.0))
			//spinLeft# = 600*spawnActive[i].cat2
			//SetSpriteAngle(airS, 360*sin(spinLeft#))
		endif
		
		if spinLeft# < 0
			SetSpriteAngle(airS, 0)
		endif
	endif
	
	if damageAmt# > 0
		newC = GetSpriteColorGreen(hero)
		
		dec damageAmt#, fpsr#/3
		
		inc heroLocalDistance#, fixedAirSpeed#*fpsr#/(255.0/damageAmt#)
		
		SetSpriteColor(hero, 255, 255-damageAmt#, 255-damageAmt#, 255)
	endif
	
	if inputLeft
		inc heroX#, -airSpeedX#*1.5*fpsr#
		PlaySprite(hero, 5, 0, 1, 2)
		SetSpriteFlip(hero, 1, 0)
	endif
	if inputRight
		inc heroX#, airSpeedX#*1.5*fpsr#
		PlaySprite(hero, 5, 0, 1, 2)
		SetSpriteFlip(hero, 0, 0)
	endif
	
	if stateRight
		SetSpriteFlip(hero, 0, 0)
	elseif stateLeft
		SetSpriteFlip(hero, 1, 0)
	endif
	
	if (releaseLeft and stateRight = 0) or (releaseRight and stateLeft = 0) then PlaySprite(hero, 10, 0, 3, 4)
		
	if Abs(airVelX#) < .01
		airVelX# = 0
	else
		airVelX# =  (((airVelX#)*((94.0)^fpsr#))/(95.0)^fpsr#)
	endif
	
	if stateLeft then airVelX# = -airSpeedX#*fpsr#
	if stateRight then airVelX# = airSpeedX#*fpsr#
	inc heroX#, airVelX#
	
	//Up/down
	if inputUp
		inc heroY#, -airSpeedY#*1.5*fpsr#
	endif
	if inputDown
		inc heroY#, airSpeedY#*1.5*fpsr#
	endif
	
	if Abs(airVelY#) < .01
		airVelY# = 0
	else
		airVelY# =  (((airVelY#)*((54.0)^fpsr#))/(55.0)^fpsr#)
	endif
	
	if stateUp then airVelY# = -airSpeedY#*fpsr#
	if stateDown then airVelY# = airSpeedY#*fpsr#
	inc heroY#, airVelY#
	
	//Print(heroX#)
	
	heroX# = Min(Max(heroX#, 95), 1050)
	heroY# = Min(Max(heroY#, 250), 600)
	SetSpritePosition(hero, heroX#, heroY# + 15*sin(gameTime#/20))
	
	RenderAir()
		
	
	if airSpeed# > 0
		dec heroLocalDistance#, airSpeed#*fpsr#
		dec airSpeed#, airSpeedLoss#*fpsr#
	endif
	dec heroLocalDistance#, fixedAirSpeed#*fpsr#
	//IncSpriteAngle(airS, .14*fpsr#)
	
	SetSpriteFrame(airS, 1+Mod(Round(airDistance-heroLocalDistance#)/12, 52))
	
	SetSpriteX(heroIcon, GetSpriteX(progBack)-GetSpriteWidth(heroIcon)/2 + (GetSpriteWidth(progBack)*(airDistance - heroLocalDistance#)/airDistance)/3 + (GetSpriteWidth(progBack)*2/3)-GetSpriteWidth(heroIcon)/2)
	SetSpriteX(duckIcon, Min(GetSpriteX(progBack)-GetSpriteWidth(duckIcon)/2 + (GetSpriteWidth(progBack)*(20000 - (duckDistance#-40000))/20000)/3, GetSpriteX(progBack)+GetSpriteWidth(progBack)-GetSpriteWidth(duckIcon)))
	
	deleted = 0
	for i = 1 to spawnActive.length
		spr = spawnActive[i].spr
		if GetSpriteVisible(spr)
			if GetSpriteCollision(spr, hero) and GetSpriteColorAlpha(spr) > 120 and GetSpriteVisible(spr)
				
				if spawnActive[i].cat = GOOD
					airSpeed# = Max(airSpeed#, spawnActive[i].cat2*sqrt(Min(airSpeedMax#, 20)))
					if spinType < spawnActive[i].cat2 or spinLeft# <= 0
						if spawnActive[i].cat2 = 1
							spinLeft# = 800
						elseif spawnActive[i].cat2 = 2
							spinLeft# = 1200
						elseif spawnActive[i].cat2 = 3
							spinLeft# = 1200
						endif
						spinType = spawnActive[i].cat2
					endif
					if GetSoundInstances(windSS-1+spawnActive[i].cat2) = 0 then PlaySound(windSS-1+spawnActive[i].cat2, volumeS)
					if GetSoundInstances(windBoostS) = 0 then PlaySound(windBoostS, volumeS*.5)
					
				elseif spawnActive[i].cat = BAD
					if damageAmt# <= 0
						damageAmt# = 255
						airSpeed# = 0
						PlaySound(hitS, volumeS)
					endif
					//PlaySprite(hero, 10, 0, 1, 4)
				else //SCRAP
					CollectScrap(AIR)
				endif
				deleted = i
				i = spawnActive.length
				
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

function RenderAir()
	//Updating the duck first
	spr = duck
	dis = (duckDistance#+2000)
	x# = -0 + 20.0*sin(gameTime#/4)
	SetSpriteSizeSquare(spr, Max(1, 100 - (heroLocalDistance# - dis)/10.0 - 210))
	if GetSpriteWidth(spr) < 8
		SetSpriteVisible(spr, 0)
	else
		SetSpriteVisible(spr, 1)
	endif
	SetSpritePosition(spr, w/2 - GetSpriteWidth(spr)/2 - (heroLocalDistance# - dis)/7*(x#/100.0), -GetSpriteHeight(spr)/2 - (heroLocalDistance# - dis)/5)
	if (heroLocalDistance#+2700) < dis
		SetSpriteColorAlpha(spr, (255 + Max(-255, (heroLocalDistance#+2700 - dis)/1.5)))
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
		//Fade in
		SetSpriteColorAlpha(spr, 0)
		if (heroLocalDistance#+1100) < spawnActive[i].y
			SetSpriteColorAlpha(spr, (Min(255, (spawnActive[i].y - (heroLocalDistance#+1100))/1.5)))
		endif
		//Fade out
		if (heroLocalDistance#+2700) < spawnActive[i].y
			SetSpriteColorAlpha(spr, (255 + Max(-255, (heroLocalDistance#+2700 - spawnActive[i].y)/1.5)))
		endif
	next i
	
	//Print((heroLocalDistance#+3700) - spawnActive[spawnActive.length].y)
	//Print(heroLocalDistance#)
	//Print(GetSpriteColorAlpha(spawnActive[1].spr))
	
endfunction

