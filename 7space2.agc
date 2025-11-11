#include "main.agc"
// File: 7space2.agc
// Created: 24-10-03

type mashInput
	spr as integer
	
	dir as integer
	//1 - Up
	//2 - Down
	//3 - Left
	//4 - Right
	
	
	
endtype

#constant space2Distance 20000
global spaceSpeed# = 1
global spaceSpeedMult# = 1.5

global MashList as mashInput[0]
global MashSecond as mashInput[0]

global mashLenMax = 5
global mashPos = 1
global onSplit = 0
global splitPos

global spaceBoost# = 0
global spaceBoostCooldown#

global oops as integer[5]
global oopsMax = 0
global oopsUsed = 0

function CreateMashInputSprite(spr, dir)
	if GetSpriteExists(spr) = 0 then CreateSprite(spr, 0)
	SetSpriteExpress(spr, 40, 40, 0, 0, 20)
	SetSpriteImage(spr, arrowI)
	SetSpriteColor(spr, 0, 255, 255, 255)	//Teal
	
	if dir = 2
		SetSpriteAngle(spr, 180)
		SetSpriteColor(spr, 255, 184, 255, 255)	//Pink
	elseif dir = 3
		SetSpriteAngle(spr, 270)
		SetSpriteColor(spr, 255, 0, 0, 255)	//Red
	elseif dir = 4
		SetSpriteAngle(spr, 90)
		SetSpriteColor(spr, 255, 184, 82, 255)	//Orange
	endif
	
endfunction

function CreateMashSequence()
	
	DeleteMashSequence()
	
	//The minimum length is 2, otherwise it will start on a split
	mashLenMax = 4 + 3 + upgrades[4, 7]
	curMashLen = mashLenMax - Random(0,2)
	
	mash as mashInput
	//MashList.insert(mash)
	//MashSecond.insert(mash)
	
	splitPos = 999
	isSplit = Random(1, 3 + 2*(3-upgrades[2, 7]))
	if isSplit <= 2
		isSplit = 1
		splitPos = Random(curMashLen/2, curMashLen-1)
	endif
	
	dir = 1
	if Random(1, 4) = 2 then dir = -1
	
	for i = 0 to curMashLen
		mash.spr = CreateSprite(0)
		mash.dir = Random(1, 4)
		MashList.insert(mash)
		
		CreateMashInputSprite(mash.spr, mash.dir)
		
		SetSpritePosition(mash.spr, w/2 - GetSpriteWidth(mash.spr)/2 - (-i+0.5+(curMashLen/2.0))*(100), 500)
		
		if i >= splitPos
			//Moving the top path up
			IncSpriteY(mash.spr, -50*dir)
		endif
			
		
		if i >= splitPos and i <> curMashLen
			//Creating the new path
			mash.spr = CreateSprite(0)
			oldDir = mash.dir
			while oldDir = mash.dir
				mash.dir = Random(1, 4)
			endwhile
			MashSecond.insert(mash)
			CreateMashInputSprite(mash.spr, mash.dir)
			SetSpritePosition(mash.spr, w/2 - GetSpriteWidth(mash.spr)/2 - (-i+0.5+(curMashLen/2.0))*(100), 500)
			
			IncSpriteY(mash.spr, 50*dir)
		endif
		
		//Setting the y of the background highlighter while the first arrow was made
		if i = 0
			SetSpriteY(pressThisBeam, GetSpriteMiddleY(mash.spr)-GetSpriteHeight(pressThisBeam)/2)
			SetSpriteVisible(pressThisBeam, 1)
			SetSpriteVisible(pressThisBeam2, 0)
		endif
		
	next i
	
	//global spaceBoostS
	//global spaceScrapS
	
	newS as spawn
	newS.spr = spawnS
	
	//Making the booster at the end of the normal chain
	LoadSpriteExpress(spawnS, "space/boostIcon.png", 10, 10, w, h, 8)
	newS.size = 75
	SetSpriteSizeSquare(spawnS, newS.size)
	SetSpriteY(spawnS, GetSpriteMiddleY(MashList[MashList.length].spr)-GetSpriteHeight(spawnS)/2)
	spaceBoostS = spawnS
	spawnActive.insert(newS)
	inc spawnS, 1
	
	//Making the scrap sprite at end of split path, if the path is split
	spaceScrapS = -1
	if isSplit = 1
		CreateSpriteExpress(spawnS, 10, 10, w, h, 8)
		rnd = Random(1,8)
		for j = 1 to 4
			AddSpriteAnimationFrame(spawnS, scrapImgs[rnd, 4, j])//First index will be a random
		next j
		PlaySprite(spawnS, 3+Random(1,3))
		newS.size = 50
		SetSpriteSizeSquare(spawnS, newS.size)
		SetSpriteY(spawnS, GetSpriteMiddleY(MashSecond[MashSecond.length].spr)-GetSpriteHeight(spawnS)/2)
		
		spaceScrapS = spawnS
		spawnActive.insert(newS)
		inc spawnS, 1
	endif

	

	onSplit = 0
	mashPos = 0
	
	
	
endfunction

function DeleteMashSequence()
	
	for i = 0 to MashList.length
		if GetSpriteExists(MashList[i].spr) then DeleteSprite(MashList[i].spr)
	next i
	for i = 0 to MashSecond.length
		if GetSpriteExists(MashSecond[i].spr) then DeleteSprite(MashSecond[i].spr)
	next i
	
	undim MashList[]
	undim MashSecond[]
	
endfunction

function InitSpace2()
	
	PlayMusicOGG(ambSpace2, 1)
	SetMusicVolumeOGG(ambSpace2, ambVol*volumeS)
	
	//No boosts... but INCREASED SPEED!
	
	pressThis = LoadSprite("space/pressSign.png")
	SetSpriteExpress(pressThis, 80, 80, w/2-40, h-100, 100)
	
	pressThisBeam = LoadSprite("space/pressSignBeam.png")
	SetSpriteExpress(pressThisBeam, GetSpriteWidth(pressThis), 100, GetSpriteX(pressThis), GetSpriteY(pressThis)-200, 100)
	SetSpriteColorAlpha(pressThisBeam, 190)
	pressThisBeam2 = LoadSprite("space/pressSignBeam.png")
	SetSpriteExpress(pressThisBeam2, GetSpriteWidth(pressThis), 100, GetSpriteX(pressThis), GetSpriteY(pressThis)-200, 100)
	SetSpriteColorAlpha(pressThisBeam2, 190)
	SetSpriteVisible(pressThisBeam2, 0)
	
	If GetImageExists(arrowI) = 0 then arrowI = LoadImage("arrow.png")
	
	wid = 80
	CreateSpriteExpress(hero, wid, wid, 300, 300, 5)
	LoadSpriteExpress(duck, "swampfoe1a.png", wid, wid, 800, 300, 60)
	
	
	
	
	
	//Gameplay setting
	heroLocalDistance# = space2Distance
	
		//Upgrade 1 - space start speed	//0.4 testing?
	spaceSpeed# = 0.06 * (1 + upgrades[1, 7]*.75 + (upgrades[1, 7]/2)*.5 + (upgrades[1, 7]/3)*1.25)	
	
	spaceSpeedMult# = 1 + 0.1*(5)
	
	img = LoadImage("space/oops.png")
	trashBag.insert(img)
	
	oopsUsed = 0
	oopsMax = -1 + 2*upgrades[3, 7]
	
	for i = 1 to oopsMax
		oops[i] = CreateSprite(img)
		SetSpriteExpress(oops[i], 70, 70, 40 + 85*(oopsMax-i), h-100, 20)
	next i
	
	CreateParticlesExpress(shineP, 15, 20, 10, 360, 800)
	img = LoadImage("space/shineParticle.png")
	SetParticlesImage(shineP, img)
	trashBag.insert(img)
	SetParticlesStartZone(shineP, -1, -1, 1, 1)
	SetParticlesPosition(shineP, 9999, 9999)
	SetParticlesDirection(shineP, 0, -300)
	life# = .2
	SetParticlesLife(shineP, life#)
	r = 244
	g = 255
	b = 233
	AddParticlesColorKeyFrame(shineP, 0, r, g, b, 255)
	AddParticlesColorKeyFrame(shineP, life#*3/4, r, g, b, 255)
	AddParticlesColorKeyFrame(shineP, life#, r, g, b, 0)
	//AddParticlesForce(shineP, 0, life#, -1000, 0)
	FixParticlesToScreen(shineP, 1)
	
	CreateMashSequence()
	
	//Second chances are like 'oopsie' stickers, they get placed over a combo when the wrong thing is pushed
	//It always defaults to the speed path
	
endfunction

function DoSpace2()
	
	heroLocalDistance# = heroLocalDistance# - spaceSpeed#*fpsr#



		
	//After a successful boost, make the difference go more in favor of the hero
	//EXCEPT for when they are neck and neck! Check a threshold if the hero distance is less than the duck distance
	if spaceBoost# > 0
		spaceBoost# = spaceBoost# - GetFrameTime()
		heroLocalDistance# = heroLocalDistance# - spaceSpeed#*fpsr#*spaceBoost#*1.5
	endif
	print(spaceBoost#)
	
	visualBoost# = (spaceBoost#^2 - spaceBoost#)*40
	
	diff# = Min(140, Max(-140, ((20000*curAreaSeen - heroLocalDistance#) - (20000*raceSize - duckDistance#))/40.0 - visualBoost#))
	if diff# > 0 and (20000*curAreaSeen - heroLocalDistance#) < (20000*raceSize - duckDistance#) then diff# = -1
	
	SetSpriteSizeSquare(hero, 150+diff#)
	SetSpritePosition(hero, w/3-GetSpriteWidth(hero)/2, h*2/5-GetSpriteHeight(hero)/2)
	SetSpriteSizeSquare(duck, 150-diff#)
	SetSpritePosition(duck, w*2/3-GetSpriteWidth(duck)/2, h*2/5-GetSpriteHeight(duck)/2)
	Print(diff#)
	
	if duckDistance# < 20000*(raceSize-curAreaSeen) then PlayTweenSprite(tweenSprFadeOut, duck, 0)
	
	SetSpriteAngle(hero, -10 + 20*cos(gameTime#))
	
	if inputSelect
		CreateMashSequence()
		
	endif
	
	//Print(mashPos)
	//Print(onSplit)
	
	if inputUp or inputDown or inputLeft or inputRight
		contMash = 0
		
		if onSplit = 0
			//Checking for main path
			if inputUp and MashList[mashPos].dir = 1 then contMash = 1
			if inputDown and MashList[mashPos].dir = 2 then contMash = 1
			if inputLeft and MashList[mashPos].dir = 3 then contMash = 1
			if inputRight and MashList[mashPos].dir = 4 then contMash = 1
		else
			//Checking for side path
			if inputUp and MashSecond[mashPos].dir = 1 then contMash = 1
			if inputDown and MashSecond[mashPos].dir = 2 then contMash = 1
			if inputLeft and MashSecond[mashPos].dir = 3 then contMash = 1
			if inputRight and MashSecond[mashPos].dir = 4 then contMash = 1
		endif	
	
		if splitPos = mashPos and contMash = 0
			//When at the spit point, check if the other direction is being taken
			if inputUp and MashSecond[0].dir = 1 then contMash = 1
			if inputDown and MashSecond[0].dir = 2 then contMash = 1
			if inputLeft and MashSecond[0].dir = 3 then contMash = 1
			if inputRight and MashSecond[0].dir = 4 then contMash = 1
			if contMash
				onSplit = 1
				mashPos = 0
			endif
		endif
		
		if contMash = 0 and oopsUsed < oopsMax
			contMash = 1
			inc oopsUsed, 1
			SetSpriteVisible(oops[oopsUsed], 0)
			PlaySound(oopsS, volumeS)
		endif
		
		if onSplit
			for i = 0 to MashList.length
				SetSpriteColorAlpha(MashList[i].spr, 90)
			next i
			SetSpriteColorAlpha(spaceBoostS, 90)
		endif
		if mashPos >= splitPos
			for i = 0 to MashSecond.length
				SetSpriteColorAlpha(MashSecond[i].spr, 90)
			next i
			SetSpriteColorAlpha(spaceScrapS, 90)
		endif
		
		
		if onSplit = 0
			//On the first path - always for speed ups
			if contMash
				SetSpriteVisible(MashList[mashPos].spr, 0)
				SetParticlesPosition(shineP, GetSpriteMiddleX(MashList[mashPos].spr), GetSpriteY(MashList[mashPos].spr))
				ResetParticleCount(shineP)
				SetSpriteVisible(pressThisBeam2, 0)
				IncSpriteSizeCenteredMult(spaceBoostS, 1.08)
				if mashPos < splitPos then IncSpriteSizeCenteredMult(spaceScrapS, 1.08)
				
				inc mashPos, 1
				
				if mashPos = MashList.length + 1
					//Boost
					PlaySound(boostS, volumeS/3)
					PlaySoundR(spaceCSE[mashPos+1], volumeS/1.5)
					spaceSpeedMult# = Pow(1 + 0.1*(MashList.length), 1.15)
					spaceSpeed# = spaceSpeed#*spaceSpeedMult#
					spaceBoost# = 1
					//Making the icons at the end of each line invisible
					spr = spaceBoostS
					SetSpriteMiddleScreenX(spr)
					PlaySprite(spr, 30)
					CreateTweenSprite(spr, .6)
					bigger = 50
					SetTweenSpriteSizeX(spr, GetSpriteWidth(spr), GetSpriteWidth(spr)+bigger, TweenOvershoot())
					SetTweenSpriteX(spr, GetSpriteX(spr), GetSpriteX(spr)-bigger/2, TweenOvershoot())
					SetTweenSpriteSizeY(spr, GetSpriteHeight(spr), GetSpriteHeight(spr)+bigger, TweenOvershoot())
					SetTweenSpriteY(spr, 400-GetSpriteHeight(spr), 400-GetSpriteHeight(spr)-bigger/2, TweenOvershoot())
					PlayTweenSprite(spr, spr, 0)
					PlayTweenSprite(tweenSprFadeOut, spr, .1)
					
					if GetSpriteExists(spaceScrapS) then SetSpriteVisible(spaceScrapS, 0)
					//Making a new mash sequence
					CreateMashSequence()
				else
					PlaySoundR(spaceCSE[mashPos], volumeS/2)
				endif
			else
				//WRONG INPUT!
				PlaySound(hitS, volumeS/2)
				
				SetSpriteVisible(spaceBoostS, 0)
				if GetSpriteExists(spaceScrapS) then SetSpriteVisible(spaceScrapS, 0)
				CreateMashSequence()
			endif
		else
			//On the second path - for scrap/oopsie stickers
			if contMash
				SetSpriteVisible(MashSecond[mashPos].spr, 0)
				SetParticlesPosition(shineP, GetSpriteMiddleX(MashSecond[mashPos].spr), GetSpriteY(MashSecond[mashPos].spr))
				ResetParticleCount(shineP)
				SetSpriteVisible(pressThisBeam, 0)
				IncSpriteSizeCenteredMult(spaceScrapS, 1.08)
				
				inc mashPos, 1
				
				if mashPos = MashSecond.length + 1
					PlaySoundR(spaceCSE[splitPos+mashPos+1], volumeS/1.5)
					CollectScrap(SPACE2)
					//Making the icons at the end of each line invisible
					spr = spaceScrapS
					SetSpriteMiddleScreenX(spr)
					PlaySprite(spr, 30)
					CreateTweenSprite(spr, .6)
					SetTweenSpriteY(spr, 450-GetSpriteHeight(spr), 450-GetSpriteHeight(spr) - GetSpriteHeight(spr)*1.5, TweenSmooth1())
					PlayTweenSprite(spr, spr, 0)
					PlayTweenSprite(tweenSprFadeOut, spr, .1)
					SetSpriteVisible(spaceBoostS, 0)
					//Making a new mash sequence
					CreateMashSequence()
				else
					PlaySoundR(spaceCSE[splitPos+mashPos], volumeS/2)
				endif
			else
				//WRONG INPUT!
				PlaySound(hitS, volumeS/2)
				
				SetSpriteVisible(spaceBoostS, 0)
				if GetSpriteExists(spaceScrapS) then SetSpriteVisible(spaceScrapS, 0)
				CreateMashSequence()
			endif
			
			
		endif

		
		//If at the split point, make the background beam appear at both places
		if splitPos = mashPos
			SetSpriteY(pressThisBeam, GetSpriteMiddleY(MashList[mashPos].spr)-GetSpriteHeight(pressThisBeam)/2)
			SetSpriteY(pressThisBeam2, GetSpriteMiddleY(MashSecond[0].spr)-GetSpriteHeight(pressThisBeam)/2)
			SetSpriteVisible(pressThisBeam2, 1)
		endif
		
	endif 
	
	if fpsr# < 5
		//Updating the mash list positions, so the current one is centered
		for i = 0 to MashList.length
			offset# = -i + mashPos + splitPos*onSplit //-i+0.5 + mashPos
			GlideToX(MashList[i].spr, w/2 - GetSpriteWidth(MashList[i].spr)/2 - (offset#)*(100), 20)		
		next i
		for i = 0 to MashSecond.length
			offset# = -i + mashPos - splitPos + splitPos*onSplit //-i+0.5 + mashPos - splitPos
			GlideToX(MashSecond[i].spr, w/2 - GetSpriteWidth(MashSecond[i].spr)/2 - (offset#)*(100), 20)
			
		next i
		//Repositioning the boost and scrap sprites at the end of the line, if they exist
		if GetSpriteExists(spaceBoostS)
			offset# = -(MashList.length+1) + mashPos + splitPos*onSplit
			GlideToX(spaceBoostS, w/2 - GetSpriteWidth(spaceBoostS)/2 - (offset#)*(100), 20)
		endif
		if GetSpriteExists(spaceScrapS)
			offset# = -(MashSecond.length+1) + mashPos - splitPos + splitPos*onSplit
			GlideToX(spaceScrapS, w/2 - GetSpriteWidth(spaceScrapS)/2 - (offset#)*(100), 20)
		endif
	endif
	
	SetSpriteX(heroIcon, GetSpriteX(progBack)-GetSpriteWidth(heroIcon)/2 + (GetSpriteWidth(progBack)*(waterDistance - heroLocalDistance#)/waterDistance)/areaSeen)
	SetSpriteX(duckIcon, Min(GetSpriteX(progBack)-GetSpriteWidth(duckIcon)/2 + (GetSpriteWidth(progBack)*(20000 - (duckDistance#-40000))/20000)/areaSeen, GetSpriteX(progBack)+GetSpriteWidth(progBack)-GetSpriteWidth(duckIcon)))
	
	
	//Print(spaceSpeed#)
	
	Print(mashPos)
	Print(MashList[mashPos].dir)
	Print(GetSpriteHit(GetPointerX(), GetPointerY()))
	
endfunction