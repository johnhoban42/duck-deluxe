#include "main.agc"
// File: 7space2.agc
// Created: 24-10-03

#constant space2Distance 20000

type mashInput
	spr as integer
	
	dir as integer
	//1 - Up
	//2 - Down
	//3 - Left
	//4 - Right
	
	
	
endtype

global MashList as mashInput[0]

global mashLenMax = 6
global mashPos = 1

function CreateMashInputSprite(spr, dir)
	
	CreateSpriteExpressImage(spr, arrowI, 40, 40, 0, 0, 20)
	if dir = 2 then SetSpriteAngle(spr, 180)
	if dir = 3 then SetSpriteAngle(spr, 270)
	if dir = 4 then SetSpriteAngle(spr, 90)
	
endfunction

function CreateMashSequence()
	
	DeleteMashSequence()
	
	curMashLen = mashLenMax - Random(0,2)
	
	mash as mashInput
	MashList.insert(mash)
	
	for i = 1 to curMashLen
		mash.spr = mashSprS - 1 + i
		mash.dir = Random(1, 4)
		MashList.insert(mash)
		
		CreateMashInputSprite(mash.spr, mash.dir)
		
		SetSpritePosition(mash.spr, w/2 - GetSpriteWidth(mash.spr)/2 - (-i+0.5+(curMashLen/2.0))*(100), 500)
		
	next i
		
	mashPos = 1
	
endfunction

function DeleteMashSequence()
	
	//iEnd = MashList.length + 1
	for i = 0 to mashLenMax
		if GetSpriteExists(mashSprS+i) then DeleteSprite(mashSprS+i)
		//mashList.remove(0)
		
		//Print(i)
		//Sync()
		//Sleep(3000)
	next i
	
	undim mashList[]
	//global MashList as mashInput[0]
	
endfunction

function InitSpace2()
	
	If GetImageExists(arrowI) = 0 then arrowI = LoadImage("arrow.png")
	
	CreateMashSequence()
	
	
	CreateSpriteExpress(hero, 80, 80, w/2-40, 300, 5)
	
	
	
	//Gameplay setting
	heroLocalDistance# = space2Distance
	
endfunction

function DoSpace2()
	
	dec heroLocalDistance#, 0.1*fpsr#
	
	if inputSelect
		CreateMashSequence()
		
	endif
	
	
	if inputUp or inputDown or inputLeft or inputRight
		contMash = 0
		
		if inputUp and MashList[mashPos].dir = 1 then contMash = 1
		if inputDown and MashList[mashPos].dir = 2 then contMash = 1
		if inputLeft and MashList[mashPos].dir = 3 then contMash = 1
		if inputRight and MashList[mashPos].dir = 4 then contMash = 1
		
		if contMash
			SetSpriteVisible(MashList[mashPos].spr, 0)
			inc mashPos, 1
			if mashPos = MashList.length + 1
				//Boost
				CreateMashSequence()
				PlaySound(boostS, volumeS)
			endif
		else
			//WRONG INPUT!
			PlaySound(hitS, volumeS)
			//Have some kind of timeout
			CreateMashSequence()
		endif
		
		
		
	endif 
	
	SetSpriteAngle(hero, -10 + 20*cos(gameTime#))
	
	Print(mashPos)
	Print(MashList[mashPos].dir)
	Print(GetSpriteHit(GetPointerX(), GetPointerY()))
	
endfunction