#include "myLib.agc"

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

#constant WATER 1
#constant LAND 2
#constant AIR 3
#constant UPGRADE 4
#constant TITLE 5
#constant FINISH 6

global heroImg1
global heroImg2
global heroImg3

global hero2Img1
global hero2Img2
global hero2Img3
global hero2Img4
global hero2Img5
global hero2Img6

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
		
		//Duck will be the first spawnable object
		
		if scene = WATER
				
			SetTextString(instruct, "LEFT/RIGHT - Move" + CHR(10) + "SPACE with Full Bar - Row" + CHR(10) + "Collect scrap metal!")
			
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
			
			SetTextString(instruct, "LEFT/RIGHT - Move" + CHR(10) + "UP - Jump" + CHR(10) + "SPACE - Use Boost")
			
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
			
			SetTextString(instruct, "LEFT/RIGHT/UP/DOWN - Move" + CHR(10) + "Hit Tornados?" + CHR(10) + "Get an upgrade!")
			if upgrades[2, 3] > 0 then SetTextString(instruct, "LEFT/RIGHT/UP/DOWN - Move" + CHR(10) + "Hit Tornados - Boost" + CHR(10) + "Win the race!")
			
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
		
		CreateSpriteExpress(instruct, 320, 320, w/2+180 + (areaSeen-1)*56, h/2 - 30, 60)
		img1 = LoadImage("upgradeR1.png")
		AddSpriteAnimationFrame(instruct, img1)
		img2 = LoadImage("upgradeR2.png")
		AddSpriteAnimationFrame(instruct, img2)
		trashBag.insert(img1)
		trashBag.insert(img2)
		PlaySprite(instruct, 2, 1, 1, 2)
		LoadSpriteExpress(vehicle4, "upgradeV" + str(areaSeen) + ".png", GetSpriteWidth(instruct), GetSpriteWidth(instruct), GetSpriteX(instruct), GetSpriteY(instruct), 70)
		
		for i = 0 to 2
			LoadSpriteExpress(vehicle1 + i, "mode" + str(1+i) + ".png", 395*0.6, 80*0.6, 70 + i*(360), 25, 30)
			if i+1 > areaSeen then IncSpriteY(vehicle1 + i, 9999)
		next i
		
		if areaSeen = 1 then LoadSpriteExpress(upgradeBG, "upgradebg1.png", w, h, 0, 0, 99)
		if areaSeen = 2 then LoadSpriteExpress(upgradeBG, "upgradebg2.png", w, h, 0, 0, 99)
		if areaSeen = 3 then LoadSpriteExpress(upgradeBG, "upgradebg3.png", w, h, 0, 0, 99)
		
		LoadSpriteExpress(startRace, "nextRace.png", 420/2.8, 165/2.8, 1100-300*(3-areaSeen), 350, 5)
		
		//TODO - Slide everything in, fade in a slightly dark layer
		for j = 0 to 2
			for i = 0 to 3
				//One upgrade pod
				spr = upgrage1StartSpr + 200*j + i*10
				LoadSpriteExpress(spr, "shopbox" + str(j+1) + ".png", 362, 154, 10 + j*360, 80 + i*156, 20)
				//SetSpriteColor(spr, 30, 30, 30, 220)
				
				LoadSpriteExpress(spr + 1, "shopPlate.png", 240, 75, GetSpriteX(spr) + 72, GetSpriteY(spr) + 60, 14)
				SetSpriteColor(spr+1, 110, 110, 110, 255)
				
				LoadSpriteExpress(spr + 2, "icon" + str(j+1) + "bg.png", 40, 40, GetSpriteX(spr) + 16, GetSpriteY(spr) + 92, 14)
				
				for k = 0 to 2
					if k = 0 then CreateTextExpress(spr + k, "", 96, fontMI, 1, GetSpriteX(spr) + 30, GetSpriteY(spr) + 2, 0, 15)
					if k = 1 then CreateTextExpress(spr + k, "", 48, font1I + upgrades[i+1, j+1], 0, GetSpriteX(spr) + 30 + 30, GetSpriteY(spr) + 2 + 5, -7, 15)
					if k = 2 then CreateTextExpress(spr + k, "", 24, fontMI, 1, GetSpriteMiddleX(spr+1), GetSpriteY(spr) + 73, -4, 10)
					
				next k
				
				if j = 0 then str$ = "w"
				if j = 1 then str$ = "l"
				if j = 2 then str$ = "s"
				size = 75
				if i = 0 then LoadSpriteExpress(spr + 3, str$ + "M.png", size, size, GetSpriteX(spr)-5, GetSpriteY(spr)-10, 20)
				if i = 1 then LoadSpriteExpress(spr + 3, str$ + "O.png", size, size, GetSpriteX(spr)-5, GetSpriteY(spr)-10, 20)
				if i = 2 then LoadSpriteExpress(spr + 3, str$ + "D.png", size, size, GetSpriteX(spr)-5, GetSpriteY(spr)-10, 20)
				if i = 3 then LoadSpriteExpress(spr + 3, str$ + "E.png", size, size, GetSpriteX(spr)-5, GetSpriteY(spr)-10, 20)
				
				
				if i = 0 then str$ = "M"
				if i = 1 then str$ = "O"
				if i = 2 then str$ = "D"
				if i = 3 then str$ = "E"
				
				if upgrades[i+1, j+1] <> 3
					SetTextString(spr + 1, words[i+1, upgrades[i+1,j+1]+1, j+1])
					SetTextString(spr + 2, str$ + words[i+1, upgrades[i+1,j+1]+2, j+1] + "- " + Str(GetCost(i,j)) + "~" + chr(10) + powers[i+1, upgrades[i+1,j+1]+2, j+1])
				else
					SetTextString(spr + 1, words[i+1, 4, j+1])
					SetTextString(spr + 2, "")
					SetSpriteVisible(spr+1, 0)
					IncTextY(spr+1, 40)
					IncSpriteY(spr+3, 40)
					IncSpritePosition(spr+2, 290, -38) //Icons
				endif
				SetTextFontImage(spr + 1, font1I + upgrades[i+1, j+1])

				if GetCost(i,j) > scrapTotal then SetTextColor(spr + 2, 160, 160, 160, 255)

				if j = 0 then LoadSpriteExpress(spr + 4, "W" + str$ + str(1+upgrades[i+1,j+1]) + ".png", GetSpriteWidth(spr+2), GetSpriteHeight(spr+2), GetSPriteX(spr+2), GetSpriteY(spr+2), GetSpriteDepth(spr+2)-1)
				if j = 1 then LoadSpriteExpress(spr + 4, "L" + str$ + str(1+upgrades[i+1,j+1]) + ".png", GetSpriteWidth(spr+2), GetSpriteHeight(spr+2), GetSPriteX(spr+2), GetSpriteY(spr+2), GetSpriteDepth(spr+2)-1)
				if j = 2 then LoadSpriteExpress(spr + 4, "S" + str$ + str(1+upgrades[i+1,j+1]) + ".png", GetSpriteWidth(spr+2), GetSpriteHeight(spr+2), GetSPriteX(spr+2), GetSpriteY(spr+2), GetSpriteDepth(spr+2)-1)
				
				
				if j >= areaSeen
					for k = 0 to 2
						IncSpriteX(spr+k, 9999)
						IncTextX(spr+k, 9999)
					next k
					IncSpriteX(spr+3, 9999)
					IncSpriteX(spr+4, 9999)
				endif
			
			next i
		next j
		
		PlayMusicOGG(upgradeM, 1)
		
		PlayTweenSprite(tweenSprFadeOut, coverS, 0)
	
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

global heroWaterDistance# = 0000
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

function DoWater()
	
	if GetSpriteCurrentFrame(cutsceneSpr) < 4
		
		
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
		
		SetSpriteFrame(waterS, 1+Mod(Round(waterDistance-heroWaterDistance#)/6, 52))
		
		if damageAmt# > 0
			newC = GetSpriteColorGreen(hero)
			
			dec damageAmt#, fpsr#/3
			
			inc heroWaterDistance#, fixedWaterSpeed#*fpsr#/(255.0/damageAmt#)
			
			SetSpriteColor(hero, 255, 255-damageAmt#, 255-damageAmt#, 255)
		endif
		
		if boatSpeed# > 0
			dec heroWaterDistance#, boatSpeed#*fpsr#
			dec boatSpeed#, boatSpeedLoss#*fpsr#
			
			if boatSpeed# <= 0
				
				
			endif
		endif
		dec heroWaterDistance#, fixedWaterSpeed#*fpsr#
		
		SetSpriteFrame(bg3, 1+8.0*(Round(waterDistance-heroWaterDistance#)/(1.0*waterDistance)))
		
		SetSpriteX(heroIcon, GetSpriteX(progBack)-GetSpriteWidth(heroIcon)/2 + (GetSpriteWidth(progBack)*(waterDistance - heroWaterDistance#)/waterDistance)/areaSeen)
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
	SetSpriteSizeSquare(spr, Max(1, 100 - (heroWaterDistance# - dis)/10.0 - 210))
	if GetSpriteWidth(spr) < 8
		SetSpriteVisible(spr, 0)
	else
		SetSpriteVisible(spr, 1)
	endif
	SetSpritePosition(spr, w/2 - GetSpriteWidth(spr)/2 - (heroWaterDistance# - dis)/7*(-160.0/100), -GetSpriteHeight(spr)/2 - (heroWaterDistance# - dis)/5)
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
		SetSpriteSizeSquare(spr, Max(1, spawnActive[i].size - (heroWaterDistance# - spawnActive[i].y)/10.0 - 210))
		if GetSpriteWidth(spr) < 8
			SetSpriteVisible(spr, 0)
		else
			SetSpriteVisible(spr, 1)
		endif
		SetSpritePosition(spr, w/2 - GetSpriteWidth(spr)/2 - (heroWaterDistance# - spawnActive[i].y)/7*(spawnActive[i].x/100), -GetSpriteHeight(spr)/2 - (heroWaterDistance# - spawnActive[i].y)/5)
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


global heroLandDistance# = 2000
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
		dec heroLandDistance#, boostSpeed#
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
	
	SetSpriteX(heroIcon, GetSpriteX(progBack)-GetSpriteWidth(heroIcon)/2 + (GetSpriteWidth(progBack)*(landDistance - heroLandDistance#)/landDistance)/areaSeen + (GetSpriteWidth(progBack)/areaSeen))
	SetSpriteFrame(landS, 1+Mod(Round(landDistance-heroLandDistance#)/6, 60))
	SetSpriteX(duckIcon, Min(GetSpriteX(progBack)-GetSpriteWidth(duckIcon)/2 + (GetSpriteWidth(progBack)*(40000 - (duckDistance#-20000))/20000)/areaSeen, GetSpriteX(progBack)+GetSpriteWidth(progBack)-GetSpriteWidth(duckIcon)))
	SetSpriteX(duck, (heroLandDistance#-(duckDistance#-20000)))
	
	SetSpriteX(rail1, -GetSpriteWidth(rail1)/4+Mod(20000+heroLandDistance#/2.5, GetSpriteWidth(rail1)/4))
	
	if damageAmt# > 0
		newC = GetSpriteColorGreen(hero)
		dec damageAmt#, fpsr#/3
		inc heroLandDistance#, fixedLandSpeed#*fpsr#/(255.0/damageAmt#)*landSlowDown#
		SetSpriteColor(hero, 255, 255-damageAmt#, 255-damageAmt#, 255)
	endif
	
	deleted = 0
	for i = 1 to spawnActive.length
		spr = spawnActive[i].spr
		SetSpriteX(spr, (heroLandDistance#-spawnActive[i].x))
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
	
	dec heroLandDistance#, fixedLandSpeed#*fpsr#
	
	if heroLandDistance# < 300
		IncSpriteY(hero, -(300-heroLandDistance#)*2.5)
		SetSpriteFrame(hero, 3)
		SetSpriteFrame(hero2, 6)
		if GetSoundInstances(windBoostS) = 0 then PlaySound(windBoostS, volumeS*.8)
	endif
	
	//print(heroLandDistance#)
	//print(boostAmt#)
	
endfunction

global heroAirDistance# = 0
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
	/*
	//waterXMax = -
	
		

	
	//Rowing
	if inputSelect and rowCoolDown# <= 0
		
		rowCoolDown# = rowCoolDownMax
		
		SetSpriteColor(waterBarFront, 255, 210, 210, 255)
		if chargeC# >= chargeM then SetSpriteColor(waterBarFront, 180, 255, 255, 255)
		
		boatSpeed# = Max(boatSpeed#, sqrt(boatSpeedMax*1.0*Min(Round(chargeC#), chargeM)/chargeM))
		if chargeC# >= chargeM then boatSpeed# = boatSpeed#*1.2
		//Print(boatSpeed#)
		//Sync()
		//Sleep(1000)
	endif
	
	SetSpriteFrame(waterS, 1+Mod(Round(waterDistance-heroWaterDistance#)/6, 52))
	

	
	if boatSpeed# > 0
		dec heroWaterDistance#, boatSpeed#*fpsr#
		dec boatSpeed#, boatSpeedLoss#*fpsr#
		
		if boatSpeed# <= 0
			
			
		endif
	endif
	dec heroWaterDistance#, fixedWaterSpeed#*fpsr#
	
	*/
	
	SetSpriteFrame(bg3, 1+12.0*(Round(airDistance-heroAirDistance#)/(1.0*airDistance)))
	
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
		
		inc heroAirDistance#, fixedAirSpeed#*fpsr#/(255.0/damageAmt#)
		
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
	
	DrawAir()
		
	
	if airSpeed# > 0
		dec heroAirDistance#, airSpeed#*fpsr#
		dec airSpeed#, airSpeedLoss#*fpsr#
	endif
	dec heroAirDistance#, fixedAirSpeed#*fpsr#
	//IncSpriteAngle(airS, .14*fpsr#)
	
	SetSpriteFrame(airS, 1+Mod(Round(airDistance-heroAirDistance#)/12, 52))
	
	SetSpriteX(heroIcon, GetSpriteX(progBack)-GetSpriteWidth(heroIcon)/2 + (GetSpriteWidth(progBack)*(airDistance - heroAirDistance#)/airDistance)/3 + (GetSpriteWidth(progBack)*2/3)-GetSpriteWidth(heroIcon)/2)
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

function DrawAir()
	//Updating the duck first
	spr = duck
	dis = (duckDistance#+2000)
	x# = -0 + 20.0*sin(gameTime#/4)
	SetSpriteSizeSquare(spr, Max(1, 100 - (heroAirDistance# - dis)/10.0 - 210))
	if GetSpriteWidth(spr) < 8
		SetSpriteVisible(spr, 0)
	else
		SetSpriteVisible(spr, 1)
	endif
	SetSpritePosition(spr, w/2 - GetSpriteWidth(spr)/2 - (heroAirDistance# - dis)/7*(x#/100.0), -GetSpriteHeight(spr)/2 - (heroAirDistance# - dis)/5)
	if (heroAirDistance#+2700) < dis
		SetSpriteColorAlpha(spr, (255 + Max(-255, (heroAirDistance#+2700 - dis)/1.5)))
	endif
	//Print(duckDistance#)
	//Print(dis)
	//Print(GetSpriteX(duck))
	
	for i = 1 to spawnActive.length
		//if i = 61 then Print(spawnActive[i].y)
		spr = spawnActive[i].spr
		SetSpriteSizeSquare(spr, Max(1, spawnActive[i].size - (heroAirDistance# - spawnActive[i].y)/10.0 - 210))
		if GetSpriteWidth(spr) < 8
			SetSpriteVisible(spr, 0)
		else
			SetSpriteVisible(spr, 1)
		endif
		SetSpritePosition(spr, w/2 - GetSpriteWidth(spr)/2 - (heroAirDistance# - spawnActive[i].y)/7*(spawnActive[i].x/100), -GetSpriteHeight(spr)/2 - (heroAirDistance# - spawnActive[i].y)/5)
		//Fade in
		SetSpriteColorAlpha(spr, 0)
		if (heroAirDistance#+1100) < spawnActive[i].y
			SetSpriteColorAlpha(spr, (Min(255, (spawnActive[i].y - (heroAirDistance#+1100))/1.5)))
		endif
		//Fade out
		if (heroAirDistance#+2700) < spawnActive[i].y
			SetSpriteColorAlpha(spr, (255 + Max(-255, (heroAirDistance#+2700 - spawnActive[i].y)/1.5)))
		endif
	next i
	
	//Print((heroAirDistance#+3700) - spawnActive[spawnActive.length].y)
	//Print(heroAirDistance#)
	//Print(GetSpriteColorAlpha(spawnActive[1].spr))
	
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

function DoUpgrade()
	
	
	
	for j = 0 to 2
		for i = 0 to 3
			spr = upgrage1StartSpr + 200*j + i*10
			
			if i = 0 then str$ = "M"
			if i = 1 then str$ = "O"
			if i = 2 then str$ = "D"
			if i = 3 then str$ = "E"
			
			//upgrades[i, j]
			cost = GetCost(i, j)
			if Button(spr) and scrapTotal >= cost and upgrades[i+1, j+1] <= 2
				inc upgrades[i+1, j+1], 1
				inc scrapTotal, -cost
				PlaySound(buyS, volumeS)
				PlaySound(selectS, volumeS)
				UpdateScrapText()
				
				if upgrades[i+1, j+1] <> 3
					SetTextString(spr + 1, words[i+1, upgrades[i+1,j+1]+1, j+1])
					SetTextString(spr + 2, str$ + words[i+1, upgrades[i+1,j+1]+2, j+1] + "- " + Str(GetCost(i,j)) + "~" + chr(10) + powers[i+1, upgrades[i+1,j+1]+2, j+1])
				else
					SetTextString(spr + 1, words[i+1, 4, j+1])
					SetTextString(spr + 2, "")
					SetSpriteVisible(spr+1, 0)
					IncTextY(spr+1, 40)
					IncSpriteY(spr+3, 40)
					IncSpritePosition(spr+2, 290, -38) //Icons
					IncSpritePosition(spr+4, 290, -38) //Icons
				endif
				SetTextFontImage(spr + 1, font1I + upgrades[i+1, j+1])
				if j = 0 then SetSpriteImage(spr + 4, LoadImage("W" + str$ + str(1+upgrades[i+1,j+1]) + ".png"))
				if j = 1 then SetSpriteImage(spr + 4, LoadImage("L" + str$ + str(1+upgrades[i+1,j+1]) + ".png"))
				if j = 2 then SetSpriteImage(spr + 4, LoadImage("S" + str$ + str(1+upgrades[i+1,j+1]) + ".png"))
				trashBag.insert(GetSpriteImageID(spr+4))
				
			endif

			if GetCost(i,j) > scrapTotal then SetTextColor(spr + 2, 160, 160, 160, 255)

		next i
	next j
	
	
	if Button(startRace)
		
		duckDistance# = 60000
		duckSpeed# = duckSpeedDefault#
		StopMusicOGG(upgradeM)
		PlaySound(selectS, volumeS)
		PlayTweenSprite(tweenSprFadeIn, coverS, 0)
		PlaySound(windMS, volumeS)
		WaitFadeTween()
		
		DeleteScene(UPGRADE)
		screen = 0
		nextScreen = WATER
	endif
	
endfunction

function GetCost(i, j)
	cost = 0
	up = upgrades[i+1, j+1]
	
	if j = 0
		if up = 0 then cost = 5
		if up = 1 then cost = 20
		if up = 2 then cost = 100
	elseif j = 1
		if up = 0 then cost = 25
		if up = 1 then cost = 60
		if up = 2 then cost = 150
	else
		if up = 0 then cost = 50
		if up = 1 then cost = 120
		if up = 2 then cost = 300
	endif
	
	

	
endfunction cost

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
