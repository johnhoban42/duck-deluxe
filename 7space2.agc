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

function CreateMashInputSprite(spr, dir)
	if GetSpriteExists(spr) = 0 then CreateSprite(spr, 0)
	SetSpriteExpress(spr, 40, 40, 0, 0, 20)
	SetSpriteImage(spr, arrowI)
	if dir = 2 then SetSpriteAngle(spr, 180)
	if dir = 3 then SetSpriteAngle(spr, 270)
	if dir = 4 then SetSpriteAngle(spr, 90)
	
endfunction

function CreateMashSequence()
	
	DeleteMashSequence()
	
	curMashLen = mashLenMax - Random(0,2)
	
	mash as mashInput
	//MashList.insert(mash)
	//MashSecond.insert(mash)
	
	splitPos = 999
	isSplit = Random(1, 1)
	if isSplit = 1
		splitPos = Random(2, curMashLen-1)
	endif
	
	dir = 1
	if Random(1, 2) = 2 then dir = -1
	
	for i = 0 to curMashLen
		mash.spr = CreateSprite(0)
		mash.dir = Random(1, 4)
		MashList.insert(mash)
		
		CreateMashInputSprite(mash.spr, mash.dir)
		
		SetSpritePosition(mash.spr, w/2 - GetSpriteWidth(mash.spr)/2 - (-i+0.5+(curMashLen/2.0))*(100), 500)
		
		if i >= splitPos
			//Moving the top path up
			IncSpriteY(mash.spr, -70*dir)
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
			
			IncSpriteY(mash.spr, 70*dir)
		endif
		
	next i
	

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
	
	//No boosts... but INCREASED SPEED!
	
	If GetImageExists(arrowI) = 0 then arrowI = LoadImage("arrow.png")
	
	CreateMashSequence()
	
	
	CreateSpriteExpress(hero, 80, 80, w/2-40, 300, 5)
	
	
	
	//Gameplay setting
	heroLocalDistance# = space2Distance
	
		//Upgrade 1 - space start speed
	spaceSpeed# = 0.4 * (1 + upgrades[1, 7]*.75 + (upgrades[1, 7]/2)*.5 + (upgrades[1, 7]/3)*1.25)	
	
	spaceSpeedMult# = 1 + 0.1*(5)
	
	//Second chances are like 'oopsie' stickers, they get placed over a combo when the wrong thing is pushed
	//It always defaults to the speed path
	
endfunction

function DoSpace2()
	
	dec heroLocalDistance#, spaceSpeed#*fpsr#
	
	if inputSelect
		CreateMashSequence()
		
	endif
	
	Print(mashPos)
	Print(onSplit)
	
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
		
		
		
		if onSplit = 0
			//On the first path - always for speed ups
			if contMash
				SetSpriteVisible(MashList[mashPos].spr, 0)
				inc mashPos, 1
				if mashPos = MashList.length + 1
					//Boost
					CreateMashSequence()
					PlaySound(boostS, volumeS/3)
					spaceSpeed# = spaceSpeed#*spaceSpeedMult#
				endif
			else
				//WRONG INPUT!
				PlaySound(hitS, volumeS/2)
				//Have some kind of timeout
				CreateMashSequence()
			endif
		else
			//On the second path - for scrap/oopsie stickers
			if contMash
				SetSpriteVisible(MashSecond[mashPos].spr, 0)
				inc mashPos, 1
				if mashPos = MashSecond.length + 1
					//Boost
					CreateMashSequence()
					CollectScrap(SPACE2)
					//spaceSpeed# = spaceSpeed#*spaceSpeedMult#
				endif
			else
				//WRONG INPUT!
				PlaySound(hitS, volumeS/2)
				//Have some kind of timeout
				CreateMashSequence()
			endif
		endif
		
		
		
	endif 
	
	SetSpriteAngle(hero, -10 + 20*cos(gameTime#))
	
	SetSpriteX(heroIcon, GetSpriteX(progBack)-GetSpriteWidth(heroIcon)/2 + (GetSpriteWidth(progBack)*(waterDistance - heroLocalDistance#)/waterDistance)/areaSeen)
	SetSpriteX(duckIcon, Min(GetSpriteX(progBack)-GetSpriteWidth(duckIcon)/2 + (GetSpriteWidth(progBack)*(20000 - (duckDistance#-40000))/20000)/areaSeen, GetSpriteX(progBack)+GetSpriteWidth(progBack)-GetSpriteWidth(duckIcon)))
	
	
	Print(spaceSpeed#)
	
	Print(mashPos)
	Print(MashList[mashPos].dir)
	Print(GetSpriteHit(GetPointerX(), GetPointerY()))
	
endfunction