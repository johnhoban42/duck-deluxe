#include "myLib.agc"
#include "upgrade.agc"
#include "1water.agc"
#include "2land.agc"
#include "3air.agc"
#include "4water2.agc"
#include "5land2.agc"
#include "6air2.agc"
#include "7space2.agc"

// Project: EvilDuck 
// Created: 2023-11-27

// show all errors
SetErrorMode(2)

// set window properties
SetWindowTitle("Race Against a Duck")
SetWindowSize( 1280, 720, 0 )
SetWindowAllowResize( 1 ) // allow the user to resize the window



#constant w 1280
#constant h 720

#constant DESKTOP 1
#constant MOBILE 2

global deviceType = DESKTOP

// set display properties
SetVirtualResolution(w, h) // doesn't have to match the window
SetOrientationAllowed(1, 1, 1, 1) // allow both portrait and landscape on mobile devices
SetSyncRate(60, 0) // 30fps instead of 60 to save battery
SetScissor(0,0,0,0 ) // use the maximum available screen space, no black borders
UseNewDefaultFonts( 1 ) // since version 2.0.22 we can use nicer default fonts

SetVSync(1)

#constant WATER 1
#constant LAND 2
#constant AIR 3
#constant WATER2 4
#constant LAND2 5
#constant AIR2 6
#constant SPACE2 7

#constant UPGRADE 8
#constant TITLE 9
#constant FINISH 10

global heroImg1
global heroImg2
global heroImg3

global hero2Img1
global hero2Img2
global hero2Img3
global hero2Img4
global hero2Img5
global hero2Img6

#constant hitS 1
LoadSoundOGG(hitS, "sounds/hit.ogg")
#constant selectS 2
LoadSoundOGG(selectS, "sounds/select.ogg")
#constant windSS 3
LoadSoundOGG(windSS, "sounds/windS.ogg")
#constant windMS 4
LoadSoundOGG(windMS, "sounds/windM.ogg")
#constant windLS 5
LoadSoundOGG(windLS, "sounds/windL.ogg")
#constant buyS 6
LoadSoundOGG(buyS, "sounds/buySound.ogg")
#constant scrapS 7
LoadSoundOGG(scrapS, "sounds/scrap.ogg")
#constant clapS 8
LoadSoundOGG(clapS, "sounds/clap.ogg")
#constant rowReadyS 9
LoadSoundOGG(rowReadyS, "sounds/rowReady.ogg")
#constant rowBadS 10
LoadSoundOGG(rowBadS, "sounds/rowBad.ogg")
#constant rowGoodS 11
LoadSoundOGG(rowGoodS, "sounds/rowGood.ogg")
#constant jumpS 12
LoadSoundOGG(jumpS, "sounds/jump.ogg")
#constant boostS 13
LoadSoundOGG(boostS, "sounds/boost.ogg")
#constant boostChargeS 14
LoadSoundOGG(boostChargeS, "sounds/boostCharge.ogg")
#constant beepReadyS 15
LoadSoundOGG(beepReadyS, "sounds/beepReady.ogg")
#constant beepGoS 16
LoadSoundOGG(beepGoS, "sounds/beepGo.ogg")
#constant windBoostS 17
LoadSoundOGG(windBoostS, "sounds/windBoost.ogg")

global volumeS = 100

#constant introM 1
LoadMusicOGG(introM, "music/intro.ogg")
#constant waterM 2
LoadMusicOGG(waterM, "music/water.ogg")
#constant landM 3
LoadMusicOGG(landM, "music/land.ogg")
#constant airM 4
LoadMusicOGG(airM, "music/air.ogg")
#constant upgradeM 5
LoadMusicOGG(upgradeM, "music/upgrade.ogg")
#constant endingM 6
LoadMusicOGG(endingM, "music/ending.ogg")
#constant titleM 7
LoadMusicOGG(titleM, "music/title.ogg")
SetMusicLoopTimesOGG(titleM, 4.941, 33.030)


//Sprite/Image/Audio constants
#constant hero 1001
#constant hero2 1002

#constant scrapText 1010

#constant progFront 1011
#constant progBack 1012
#constant heroIcon 1013
#constant duckIcon 1014
#constant flag1 1015
#constant flag2 1016
#constant flag3 1017
#constant cutsceneSpr 1018
#constant coverS 1019

#constant waterBarFront 1021
#constant waterBarBack 1022


#constant logo 1023
#constant startRace 1024
#constant finishS 1025
#constant restartS 1026

#constant cutsceneSpr2 1027 //Endig
#constant cutsceneSpr3 1028	//Intro

#constant landBoost1 1031
#constant landBoost2 1032
#constant landBoost3 1033
#constant landBoost4 1034
#constant landBoost5 1035
#constant landBoost6 1036
#constant landBoost7 1037
#constant scvs 1038
#constant rail1 1039
#constant rail2 1040

#constant tweenSprFadeIn 1019
#constant tweenSprFadeOut 1020
#constant tweenFadeLen# .5
CreateTweenSprite(tweenSprFadeIn, tweenFadeLen#)
SetTweenSpriteAlpha(tweenSprFadeIn, 0, 255, TweenEaseIn1())
CreateTweenSprite(tweenSprFadeOut, tweenFadeLen#)
SetTweenSpriteAlpha(tweenSprFadeOut, 255, 0, TweenEaseIn1())


#constant duck 1201

#constant instruct 1202
#constant vehicle1 1203
#constant vehicle2 1204
#constant vehicle3 1205
#constant vehicle4 1206

#constant superStart 1601

#constant bg 2001
#constant waterS 2002
#constant landS 2003
#constant airS 2004
#constant bg2 2005
#constant bg3 2006

#constant upgradeBG 3000
#constant upgrage1StartSpr 3001
#constant upgrage2StartSpr 3201
#constant upgrage3StartSpr 3401

#constant spawnStartS 10001
global spawnS = spawnStartS


#constant font1I 40001
#constant font2I 40002
#constant font3I 40003
#constant font4I 40004
#constant fontMI 40005
#constant fontGI 40006
LoadImage(font1I, "font1.png")
LoadImage(font2I, "font2.png")
LoadImage(font3I, "font3.png")
LoadImage(font4I, "font4.png")
LoadImage(fontMI, "fontM.png")
LoadImage(fontGI, "fontG.png")

#constant GOOD 1
#constant BAD 2
#constant SCRAP 3
#constant RAMP 4
type spawn
	
	spr as integer
	cat as integer
	cat2 as integer //Tornado size
	//Category 1 is GOOD
	//Category 2 is BAD
	//Category 3 is SCRAP
	
	//Changing variables
	x as float
	y as float
	size as float
endtype
global spawnActive as spawn[0]

global upgrades as integer[4, 3]

//First piece is the letter, 2nd is the stage, 3rd is the mode
global words as string[4, 4, 3]
SetWords()


global powers as string[4, 4, 3]
SetPowers()

//Overhead variables
global fpsr# = 100
global screen = 0
global nextScreen = TITLE

//Gameplay variables
global heroX# = 0
global heroY# = 0
global damageAmt# = 0
global scrapTotal = 0
global duckDistance# = 60000
global duckSpeed# = .013
#constant duckSpeedDefault# 2.2

global areaSeen = 1
global gameTime# = 0

CreateSpriteExpress(coverS, w, h, 0, 0, 1)
SetSpriteColor(coverS, 0, 0, 0, 0)

//Loading in the heavy hitters all at once
LoadAnimatedSprite(waterS, "wBG/w", 52)
SetSpriteVisible(waterS, 0)
LoadAnimatedSprite(landS, "lBG/l", 60)
SetSpriteVisible(landS, 0)
LoadAnimatedSprite(airS, "sBG/s", 52)
SetSpriteVisible(airS, 0)
LoadAnimatedSprite(cutsceneSpr3, "intro/intro", 60)
SetSpriteVisible(cutsceneSpr3, 0)
LoadAnimatedSprite(cutsceneSpr2, "ending/end", 89)
SetSpriteVisible(cutsceneSpr2, 0)


//CreateTextExpress(superStart, "Game loaded." + chr(10) + "Please click"+chr(10)+"to start.", 52, fontGI, 1, w/2, h/2-52, -10, 3)

//SetPhysicsDebugOn()



do
    fpsr# = (60.0/ScreenFPS())*9
	DoInputs()
	
	inc gameTime#, fpsr#
	if gameTime# > 36000 then dec gameTime#, 36000


	if screen = 0
		if GetTextExists(superStart) = 0
			SetupScene(nextScreen)
			nextScreen = 0
		else
			if GetPointerPressed()
				DeleteText(superStart)
				Sync()
				Sleep(200)
			endif
		endif
	endif

	

	if screen < UPGRADE
		if screen = WATER
			DoWater()
			if heroWaterDistance# <= 0
				PlayTweenSprite(tweenSprFadeIn, coverS, 0)
				PlaySound(windMS, volumeS)
				WaitFadeTween()
				DeleteScene(screen)
				screen = 0
				nextScreen = LAND
			endif
		elseif screen = LAND
			DoLand()
			if heroLandDistance# <= 0
				PlayTweenSprite(tweenSprFadeIn, coverS, 0)
				PlaySound(windMS, volumeS)
				WaitFadeTween()
				DeleteScene(screen)
				screen = 0
				nextScreen = AIR
			endif
		elseif screen = AIR
			DoAir()
			if heroAirDistance# <= 0
				
				StopMusicOGG(waterM)
				StopMusicOGG(landM)
				StopMusicOGG(airM)
				
				HideUIText()
				LoadSpriteExpress(finishS, "finishHero.png", 924, 429, 0, 0, 4)
				SetSpriteMiddleScreen(finishS)
				PlayTweenSprite(tweenSprFadeOut, coverS, 0)
				PlaySound(clapS, volumeS)
				
				for i = 1 to 120
					UpdateAllTweens(GetFrameTime())
					Sync()
				next i
				
				PlayTweenSprite(tweenSprFadeIn, coverS, 0)
				PlaySound(windMS, volumeS)
				WaitFadeTween()
				
				DeleteSprite(finishS)
				DeleteScene(screen)
				screen = 0
				nextScreen = FINISH
			endif
		endif
		dec duckDistance#, duckSpeed#*fpsr#
		if duckDistance# < 40000 and areaSeen = 1 then duckSpeed# = 100
		if duckDistance# < 20000 and areaSeen = 2 then duckSpeed# = 100
		if GetRawKeyPressed(82) then duckSpeed# = 100
		if GetSpriteExists(cutsceneSpr)
			if GetSpriteCurrentFrame(cutsceneSpr) <> 4 then inc duckDistance#, duckSpeed#*fpsr#
		endif
		
		if GetSpriteExists(hero2)
			SetSpritePosition(hero2, GetSpriteX(hero), GetSpriteY(hero))
			SetSpriteAngle(hero2, GetSpriteAngle(hero))
		endif
		
		if duckDistance# <= 0
			
			StopMusicOGG(waterM)
			StopMusicOGG(landM)
			StopMusicOGG(airM)
			
			HideUIText()
			LoadSpriteExpress(finishS, "finishDuck.png", 924, 429, 0, 0, 4)
			SetSpriteMiddleScreen(finishS)
			PlayTweenSprite(tweenSprFadeOut, coverS, 0)
			PlaySound(clapS, volumeS)
			
			WaitFadeTween()
			WaitFadeTween()
			
			PlayTweenSprite(tweenSprFadeIn, coverS, 0)
			PlaySound(windMS, volumeS)
			WaitFadeTween()
			
			DeleteScene(screen)
			DeleteSprite(finishS)
			screen = 0
			nextScreen = UPGRADE
		endif
		
	endif
	
	if screen = UPGRADE
		DoUpgrade()
	endif
	
	if screen = TITLE
		if GetSpritePlaying(cutsceneSpr3) = 0 and GetSpriteVisible(cutsceneSpr3) = 1
			PlayMusicOGG(titleM, 1)
			SetSpriteColor(coverS, 0, 0, 0, 255)
			SetSpriteVisible(cutsceneSpr3, 0)
			SetSpriteVisible(coverS, 1)
			SetSpriteVisible(bg, 1)
			PlayTweenSprite(tweenSprFadeOut, coverS, .3)
			SetTextVisible(cutsceneSpr, 0)
			
		endif
		
		if inputSelect or Button(startRace) or GetPointerPressed()
			
			if GetSpriteVisible(cutsceneSpr3) and GetTextVisible(cutsceneSpr) = 0
				SetTextVisible(cutsceneSpr, 1)
				PlaySound(selectS, volumeS)
			elseif GetSpritePlaying(cutsceneSpr3) and GetTextVisible(cutsceneSpr) and inputSelect
				StopSprite(cutsceneSpr3)
				PlaySound(selectS, volumeS)
				
				if GetMusicPlayingOGG(introM) then StopMusicOGG(introM)
			elseif Button(startRace) or inputSelect
				if inputSelect then PlaySound(selectS, volumeS)
				SetSpriteColor(coverS, 255, 255, 255, 0)
				PlayTweenSprite(tweenSprFadeIn, coverS, 0)
				PlaySound(windMS, volumeS)
				PlaySound(clapS, volumeS)
				WaitFadeTween()
				DeleteScene(screen)
				screen = 0
				nextScreen = WATER
				duckDistance# = 60000
				duckSpeed# = duckSpeedDefault#
				if GetMusicPlayingOGG(introM) then StopMusicOGG(introM)
				if GetMusicPlayingOGG(titleM) then StopMusicOGG(titleM)
			endif
		endif
	endif
	
	if screen = FINISH
		
		if GetSpritePlaying(cutsceneSpr2) = 0
			PlayTweenSprite(tweenSprFadeIn, restartS, 0)
			PlayTweenSprite(tweenSprFadeIn, startRace, 0)
			PlayTweenSprite(tweenSprFadeIn, scvs, 0)
		endif
		
		if GetSpriteColorAlpha(scvs) > 0 and Button(scvs)
			OpenBrowser("https://store.steampowered.com/app/2416940/Space_Crab_VS/")
		endif
		
		if inputSelect or GetPointerPressed()
			
			if GetSpritePlaying(cutsceneSpr2) and GetTextVisible(cutsceneSpr) = 0
				SetTextVisible(cutsceneSpr, 1)
				PlaySound(selectS, volumeS)
			elseif GetSpritePlaying(cutsceneSpr2) and GetTextVisible(cutsceneSpr) and inputSelect
				StopSprite(cutsceneSpr2)
				SetSpriteFrame(cutsceneSpr2, 89)
				SetTextVisible(cutsceneSpr, 0)
				PlaySound(selectS, volumeS)
				
			else
			endif
		endif
		
		if Button(startRace)
			SetTextVisible(cutsceneSpr, 0)
			if GetMusicPlayingOGG(endingM) then StopMusicOGG(endingM)
			SetSpriteColor(coverS, 255, 255, 255, 0)
			PlayTweenSprite(tweenSprFadeIn, coverS, 0)
			PlaySound(windMS, volumeS)
			WaitFadeTween()
			DeleteScene(screen)
			screen = 0
			nextScreen = UPGRADE
			duckDistance# = 60000
			duckSpeed# = duckSpeedDefault#
		endif
		
		if Button(restartS)
			SetTextVisible(cutsceneSpr, 0)
			if GetMusicPlayingOGG(endingM) then StopMusicOGG(endingM)
			for i = 0 to 4
				for j = 0 to 3
					upgrades[i, j] = 0
				next j
			next i
			scrapTotal = 0
			areaSeen = 1
			SetSpriteColor(coverS, 255, 255, 255, 0)
			PlayTweenSprite(tweenSprFadeIn, coverS, 0)
			PlaySound(windMS, volumeS)
			WaitFadeTween()
			DeleteScene(screen)
			screen = 0
			nextScreen = WATER
			duckDistance# = 60000
			duckSpeed# = duckSpeedDefault#
		endif
		
	endif
	

    //Print( ScreenFPS() )
    UpdateAllTweens(GetFrameTime())
    //Print(GetRawLastKey())
    Print(HeroX#)
    if GetSpriteExists(hero)
    		Print(GetSpriteX(Hero))
    		Print(GetSpriteY(Hero))
	endif
    Sync()
loop

function WaitFadeTween()
	iEnd = 300/fpsr#
	for i = 1 to iEnd
		UpdateAllTweens(GetFrameTime())
		Sync()
	next i
	UpdateAllTweens(1)
endfunction



function HideUIText()
	SetTextVisible(instruct, 0)
	SetTextVisible(scrapText, 0)
endfunction

global trashBag as integer[0]
function EmptyTrashBag()
	endI = trashBag.length
	for i = 1 to endI
		if GetImageExists(trashBag[0]) then DeleteImage(trashBag[0])
		trashBag.remove(0)
	next i
endfunction
//trashBag.insert(GetSpriteImageID(i))

function SetupScene(scene)



	EmptyTrashBag()

	if GetSpriteExists(hero)
		DeleteSprite(hero)
		DeleteImage(heroImg1)
		DeleteImage(heroImg2)
		DeleteImage(heroImg3)
		if GetImageExists(hero2Img1) then DeleteImage(hero2Img1)
		if GetImageExists(hero2Img2) then DeleteImage(hero2Img2)
		if GetImageExists(hero2Img3) then DeleteImage(hero2Img3)
		if GetImageExists(hero2Img4) then DeleteImage(hero2Img4)
		if GetImageExists(hero2Img5) then DeleteImage(hero2Img5)
		if GetImageExists(hero2Img6) then DeleteImage(hero2Img6)
	endif

	damageAmt# = 0
	duckSpeed# = duckSpeedDefault# //This will change depending on how many upgrades you have

	if scene < UPGRADE

		if GetMusicPlayingOGG(waterM) = 0 then PlayMusicOGG(waterM, 0)
		if GetMusicPlayingOGG(landM) = 0 then PlayMusicOGG(landM, 0)
		if GetMusicPlayingOGG(airM) = 0 then PlayMusicOGG(airM, 0)
		SetMusicVolumeOGG(waterM, 0)
		SetMusicVolumeOGG(landM, 0)
		SetMusicVolumeOGG(airM, 0)
		
		CreateTextExpress(instruct, "", 44, fontGI, 2, w-20, 580, -13, 2)
		
		SetBG(scene)
		
		//LoadSpriteExpress(instruct, "mode" + str(scene) + ".png", 395*0.6, 80*0.6, 60, 20, 3)
		for i = 0 to 3
			if i = 0 then str$ = "M"
			if i = 1 then str$ = "O"
			if i = 2 then str$ = "D"
			if i = 3 then str$ = "E"
			
			if scene = 1 then LoadSpriteExpress(vehicle1+i, "w" + str$ + ".png", 60, 60, 10+i*3, 15 + i*65, 3)
			if scene = 2 then LoadSpriteExpress(vehicle1+i, "l" + str$ + ".png", 60, 60, 10+i*3, 15 + i*65, 3)
			if scene = 3 then LoadSpriteExpress(vehicle1+i, "s" + str$ + ".png", 60, 60, 10+i*3, 15 + i*65, 3)
			CreateTextExpress(vehicle1+i, words[i+1, upgrades[i+1,scene]+1, scene], 48, fontGI, 0, 63+i*3, 35 + i*65, -11, 2)
		next i
		
		SetInstructionText(scene)
		
		//Duck will be the first spawnable object
		
		if scene = WATER
			
			//SetMusicVolumeOGG(waterM, 100)
			
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
			heroWaterDistance# = waterDistance
			waterVelX# = 0
			
		elseif scene = LAND
			
			
			if duckSpeed# = 100 then duckDistance# = 40000
			
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
			heroLandDistance# = landDistance
		
			boostAmt# = boostTotal
		
		elseif scene = AIR
			
			
			if duckSpeed# = 100 then duckDistance# = 20000
			
			SetMusicVolumeOGG(airM, 100)
			
			heroX# = w/2
			heroY# = h*2/3 - 50
			CreateSpriteExpress(hero, 140, 140, w, h, 10)
			
			heroImg1 = LoadImage("S_D"+str(1+upgrades[3,3])+"_1.png")
			heroImg2 = LoadImage("S_D"+str(1+upgrades[3,3])+"_3.png")
			heroImg3 = LoadImage("S_D"+str(1+upgrades[3,3])+"_5.png")
			
			AddSpriteAnimationFrame(hero, heroImg2)
			AddSpriteAnimationFrame(hero, heroImg3)
			AddSpriteAnimationFrame(hero, heroImg2)
			AddSpriteAnimationFrame(hero, heroImg1)
			SetSpriteFrame(hero, 4)
			SetSpriteShape(hero, 3)
			
			LoadAnimatedSprite(duck, "duckA", 3)
			PlaySprite(duck, 15, 1, 1, 3)
			SetSpriteDepth(duck, 12)
			
			SetSpriteVisible(airS, 1)
			SetSpriteAngle(airS, 0)
			spinLeft# = 0
			SetSpriteSizeSquare(airS, w*1.2)
			SetSpriteMiddleScreen(airS)
			SetSpriteDepth(airS, 90)
			IncSpriteY(airS, 150)
			SetSpriteOffset(airS, GetSpriteWidth(airS)/2, GetSpriteHeight(airS)/2-120)
			
			areaSeen = Max(areaSeen, 3)
			
			//Setting the variables based on upgrades
			fixedAirSpeed# = (.31)*(1 + 1*upgrades[1, 3] + 1*upgrades[1, 3]/3) //.31
			airSpeedMax# = (2)*(1 + 0.5*upgrades[2, 3]/2 + 0.2*upgrades[2, 3]/3)
			airSpeedX# = (0.39)*(1 + 0.3*upgrades[3, 3] + 0.1*upgrades[3, 3] + 0.2*upgrades[3, 3]/3)
			airSpeedY# = (0.28)*(1 + 0.2*upgrades[4, 3] + 0.1*upgrades[4, 3] + 0.2*upgrades[4, 3]/3)
			
			for i = 4 to 27
				newS.spr = spawnS
				rnd = Random(1, 5)
				if rnd <= 3 then newS.cat = SCRAP
				if rnd = 4 or rnd = 5 then newS.cat = GOOD
				newS.x = Random(0, 240)-120
				newS.y = i*airDistance/27 + 470 + Random(0, 200)
				
				if newS.cat = GOOD
					str$ = "s"
					newS.cat2 = 1
					if random(1, 2) = 2
						if random(1, 2) = 1
							str$ = "m"
							newS.cat2 = 2
						else
							str$ = "l"
							newS.cat2 = 3
						endif
					endif
					LoadAnimatedSprite(spawnS, "tornado" + str$, 4)
					SetSpriteDepth(spawnS, 13)
					PlaySprite(spawnS, 20, 1, 1, 4)
					newS.size = 200
					SetSpriteShape(spawnS, 3)
					if upgrades[2, 3] < 1 then newS.cat = BAD
				else
					LoadSpriteExpress(spawnS, "scrap" + Str(4 + Random(1,3)) + ".png", 10, 10, w, h, 8)
					newS.size = 30
				endif
				spawnActive.insert(newS)
				inc spawnS, 1
			next i
			
			
			//Gameplay setting
			heroAirDistance# = airDistance
			airVelX# = 0
			airVelY# = 0
		
		endif
		
		
				
		CreateSpriteExpress(progBack, 610, 35, 0, 50, 9)
		SetSpriteMiddleScreenX(progBack)
		SetSpriteColor(progBack, 100, 100, 100, 0)
		DeleteSprite(progFront)
		LoadSpriteExpress(progFront, "mapBar" + Str(areaSeen) + ".png", GetSpriteWidth(progBack), GetSpriteHeight(progBack)-10, GetSpriteX(progBack), GetSpriteY(progBack)+5, 7)
		//SetSpriteColor(progFront, 170, 170, 170, 255)
		
		LoadSpriteExpress(heroIcon, "heroIcon.png", 40, 40, GetSpriteX(progBack)-20, GetSpriteMiddleY(progBack)-20, 5)
		LoadSpriteExpress(duckIcon, "duckIcon.png", 40, 40, GetSpriteX(progBack)-20, GetSpriteMiddleY(progBack)-20, 6)
		
	
		
		LoadAnimatedSprite(flag1, "flag", 7)
		LoadAnimatedSprite(flag2, "flag", 7)
		LoadAnimatedSprite(flag3, "finish", 9)
		PlaySprite(flag1, 15, 1, 1, 7)
		PlaySprite(flag2, 15, 1, 1, 7)
		PlaySprite(flag3, 15, 1, 1, 9)
		for i = flag1 to flag3
			SetSpriteExpress(i, 36, 36, GetSpriteX(progBack) - 40 + GetSpriteWidth(progBack)*(i-flag1+1)/areaSeen, GetSpriteY(progBack)-25, 8)
			SetSpriteVisible(i, 1)
			if (i-flag1+1 > areaSeen) then SetSpriteVisible(i, 0)
		next i
		SetSpriteDepth(flag3, 3)
		IncSpriteX(flag3, -5)
		IncSpriteY(flag3, 16)
		
		SetSpriteColor(coverS, 255, 255, 255, 255)
		PlayTweenSprite(tweenSprFadeOut, coverS, 0)
		
	elseif scene = UPGRADE
		CreateUpgrade()
		
		
	
	elseif scene = TITLE
		SetBG(TITLE)
		
		SetSpriteVisible(cutsceneSpr3, 1)
		SetSpriteExpress(cutsceneSpr3, h, h, 0, 0, 10)
		SetSpriteMiddleScreen(cutsceneSpr3)
		PlaySprite(cutsceneSpr3, 3, 0, 1, 60)
		
		CreateTextExpress(cutsceneSpr, "Press SPACE to skip.", 40, fontMI, 2, w-20, h-60, -6, 8)
		SetTextVisible(cutsceneSpr, 0)
		
		SetSpriteVisible(bg, 0)
			
		LoadSpriteExpress(logo, "logo.png", 460, 460, 0, 0, 20)
		SetSpriteMiddleScreen(logo)
		IncSpriteY(logo, -70)
		
		LoadSpriteExpress(startRace, "startButton.png", 230, 230, 0, 0, 20)
		SetSpriteMiddleScreen(startRace)
		IncSpriteY(startRace, 230)
		PlayMusicOGG(introM, 0)
	
	elseif scene = FINISH
	
		SetBG(FINISH)	//No BG for this
		SetSpriteVisible(cutsceneSpr2, 1)
		SetSpriteExpress(cutsceneSpr2, h, h, 0, 0, 10)
		SetSpriteMiddleScreen(cutsceneSpr2)
		PlaySprite(cutsceneSpr2, 4, 0, 1, 89)
			
		CreateTextExpress(cutsceneSpr, "Press SPACE to skip.", 40, fontMI, 2, w-20, h-60, -6, 8)
		SetTextVisible(cutsceneSpr, 0)
		
		LoadSpriteExpress(startRace, "nextRace.png", 420/2, 165/2, 0, 0, 5)
		SetSpriteMiddleScreen(startRace)
		IncSpriteY(startRace, 130)
		IncSpriteX(startRace, -500)
		
		LoadSpriteExpress(restartS, "startOver.png", 420/2, 165/2, 0, 0, 5)
		SetSpriteMiddleScreen(restartS)
		IncSpriteY(restartS, 130)
		IncSpriteX(restartS, 500)
		
		LoadSpriteExpress(scvs, "scvs.png", 420/2, 420/2, 0, 0, 5)
		SetSpriteMiddleScreen(scvs)
		IncSpriteY(scvs, -90)
		IncSpriteX(scvs, 500)
		
		SetSpriteColorAlpha(startRace, 0)
		SetSpriteColorAlpha(restartS, 0)
		SetSpriteColorAlpha(scvs, 0)
		
		PlayMusicOGG(endingM, 0)
		//LoadSpriteExpress(restartS
		//PlayTweenSprite(tweenSprFadeOut, coverS, 0)
		
		PlayTweenSprite(tweenSprFadeOut, coverS, 0)
	endif
	
	if scene <> TITLE and scene <> FINISH
		CreateTextExpress(scrapText, "Scrap: " + str(scrapTotal) + " ~", 50, fontGI, 0, 1000, 30, -12, 5)
		//SetTextColor(scrapText, 0, 0, 0, 255)
	endif
	
	
	
	screen = scene
	

endfunction




function SetBG(scene)
	
	if GetSpriteExists(bg) then DeleteSprite(bg)
	if GetSpriteExists(bg2) then DeleteSprite(bg2)
	if GetSpriteExists(bg3) then DeleteAnimatedSprite(bg3)
	
	//TODO: Load these BG images in beforehand
	if scene = WATER
		LoadSprite(bg, "bgW.png")
		SetSpriteExpress(bg, w, w*1.5, 0, -w*0.25, 999)
		
		LoadAnimatedSprite(bg3, "island", 9)
		SetSpriteExpress(bg3, w*.7, w*1.5*.7, 0, -w*0.6, 998)
		SetSpriteMiddleScreen(bg3)
		IncSpriteX(bg3, -70)
		IncSpriteY(bg3, -w*0.18)
		
	elseif scene = LAND
		LoadSprite(bg, "bgL.png")
		SetSpriteExpress(bg, w, w, 0, -h*.1, 999)
		IncSpriteY(bg, -300)
		
		//SetSpriteColor(bg, 220, 220, 220, 255)
	elseif scene = AIR
		
		LoadAnimatedSprite(bg3, "sBG/skybg", 13)
		SetSpriteExpress(bg3, w, w*1.5, 0, -w*.6, 998)
		
	elseif scene = TITLE
		LoadSprite(bg, "bgL.png")
		SetSpriteExpress(bg, w, w, 0, -h*.1, 999)
		IncSpriteY(bg, -100)
		
	endif
	
endfunction




function CollectScrap(area)
	PlaySound(scrapS, volumeS)
	
	if area = WATER
		num = Random(3, 5)
		if scrapTotal = 0 then num = 5
		inc scrapTotal, num
	elseif area = LAND
		num = Random(10, 14)
		inc scrapTotal, num
	else //AIR
		num = Random(20, 29)
		inc scrapTotal, num
	endif
	
	UpdateScrapText()
	//Updating the scrap textbox
	
endfunction

function UpdateScrapText()
	
	SetTextString(scrapText, "Scrap: " + str(scrapTotal) + " ~")
endfunction


function SetInstructionText(sceneL)
	if sceneL = WATER
		SetTextString(instruct, "LEFT/RIGHT - Move" + CHR(10) + "SPACE with Full Bar - Row" + CHR(10) + "Collect scrap metal!")
	elseif sceneL = LAND
			SetTextString(instruct, "LEFT/RIGHT - Move" + CHR(10) + "UP - Jump" + CHR(10) + "SPACE - Use Boost")
	elseif sceneL = AIR
		SetTextString(instruct, "LEFT/RIGHT/UP/DOWN - Move" + CHR(10) + "Hit Tornados?" + CHR(10) + "Get an upgrade!")
		if upgrades[2, 3] > 0 then SetTextString(instruct, "LEFT/RIGHT/UP/DOWN - Move" + CHR(10) + "Hit Tornados - Boost" + CHR(10) + "Win the race!")
	endif
endfunction

function DeleteScene(scene)
	
	if scene = WATER
			DeleteSprite(hero)			
			DeleteSprite(duck)
			
			DeleteSprite(waterBarBack)
			DeleteSprite(waterBarFront)
			
			
			SetSpriteVisible(waterS, 0)
			//DeleteAnimatedSprite(waterS)			
			
			iMax = spawnActive.length
			for i = 1 to iMax
				if spawnActive[1].cat = GOOD
					DeleteAnimatedSprite(spawnActive[1].spr)
				else
					DeleteSprite(spawnActive[1].spr)
				endif
				spawnActive.remove(1)
			next i

			DeleteAnimatedSprite(cutsceneSpr)
			
			//Gameplay setting
			heroWaterDistance# = waterDistance

	elseif scene = LAND
		
		DeleteSprite(hero)

			
			DeleteSprite(hero2)

			
			DeleteAnimatedSprite(landBoost1)
			for i = landBoost1+1 to landBoost1 - 1 + boostTotal
				DeleteSprite(i)
			next i

			DeleteAnimatedSprite(duck)
			
			DeleteSprite(rail1)
			
			SetSpriteVisible(landS, 0)
			//DeleteAnimatedSprite(landS)
			
			iMax = spawnActive.length
			for i = 1 to iMax
				if spawnActive[1].cat = BAD
					DeleteAnimatedSprite(spawnActive[1].spr)
				else
					DeleteSprite(spawnActive[1].spr)
				endif
				spawnActive.remove(1)
			next i
		
	elseif scene = AIR
		
			DeleteSprite(hero)
			
			SetSpriteVisible(airS, 0)
			//DeleteAnimatedSprite(airS)

			DeleteAnimatedSprite(duck)
			
			iMax = spawnActive.length
			for i = 1 to iMax
				if spawnActive[1].cat = GOOD
					DeleteAnimatedSprite(spawnActive[1].spr)
				else
					DeleteSprite(spawnActive[1].spr)
				endif
				spawnActive.remove(1)
			next i
			
			
	elseif scene = UPGRADE
		
		DeleteSprite(upgradeBG)
		for j = 0 to 2
			for i = 0 to 3
				//One upgrade pod
				spr = upgrage1StartSpr + 200*j + i*10
				for k = 0 to 2
					DeleteSprite(spr+k)
					DeleteText(spr+k)
				next k
				DeleteSprite(spr + 3)
				DeleteSprite(spr + 4)
			next i
		next j
		DeleteSprite(startRace)
	
	elseif scene = TITLE
		
		//SetSpriteVisible(cutsceneSpr, 0)
		DeleteAnimatedSprite(cutsceneSpr3)
		DeleteText(cutsceneSpr)
		DeleteSprite(logo)
		DeleteSprite(startRace)
	
	elseif scene = FINISH
		
		SetSpriteVisible(cutsceneSpr2, 0)
		//DeleteAnimatedSprite(cutsceneSpr)
		DeleteText(cutsceneSpr)
		DeleteSprite(restartS)
		DeleteSprite(startRace)
		DeleteSprite(scvs)
	
	endif
		
	for i = instruct to vehicle4
		if GetSpriteExists(i) then DeleteSprite(i)
		if GetTextExists(i) then DeleteText(i)
	next i
		
		
	if scene = WATER or scene = LAND or scene = AIR
		//These are deleted for every gameplay section
		DeleteSprite(progBack)
		DeleteSprite(progFront)
		DeleteSprite(heroIcon)
		DeleteSprite(duckIcon)
		
		DeleteAnimatedSprite(flag1)
		DeleteAnimatedSprite(flag2)
		DeleteAnimatedSprite(flag3)
		
	endif
	
	if GetTextExists(scrapText) then DeleteText(scrapText)		
	
endfunction
