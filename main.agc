#include "myLib.agc"
#include "upgrade.agc"
#include "1water.agc"
#include "2land.agc"
#include "3air.agc"
#include "4water2.agc"
#include "5land2.agc"
#include "6air2.agc"
#include "7space2.agc"
#include "constants.agc"

// Project: EvilDuck 
// Created: 2023-11-27

// show all errors
SetErrorMode(2)
SetErrorMode(2)

// set window properties
SetWindowTitle("Race Against a Duck")
SetWindowSize( 1280, 720, 0 )
SetWindowAllowResize( 1 ) // allow the user to resize the window

global debug = 1
if debug = 0 then SetErrorMode(1)
global nextScreen = SPACE2

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

#constant tweenSprFadeIn 1019
#constant tweenSprFadeOut 1020
#constant tweenFadeLen# .5
CreateTweenSprite(tweenSprFadeIn, tweenFadeLen#)
SetTweenSpriteAlpha(tweenSprFadeIn, 0, 255, TweenEaseIn1())
CreateTweenSprite(tweenSprFadeOut, tweenFadeLen#)
SetTweenSpriteAlpha(tweenSprFadeOut, 255, 0, TweenEaseIn1())

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

global upgrades as integer[4, 7]

//First piece is the letter, 2nd is the stage, 3rd is the mode
global words as string[4, 4, 7]
SetWords()


global powers as string[4, 4, 7]
SetPowers()

//Overhead variables
global fpsr# = 100
global screen = 0

//Gameplay variables
global heroX# = 0
global heroY# = 0
global heroLocalDistance# = 0
global damageAmt# = 0
global scrapTotal = 0
global duckDistance# = 60000
global duckSpeed# = .013
#constant duckSpeedDefault# 2.2

global areaSeen = 1
global gameTime# = 0
if debug = 0 then nextScreen = TITLE

CreateSpriteExpress(coverS, w, h, 0, 0, 1)
SetSpriteColor(coverS, 0, 0, 0, 0)

//Loading in the heavy hitters all at once
if debug
	CreateSprite(cutsceneSpr2, 0)
	CreateSprite(cutsceneSpr3, 0)
	CreateSprite(airS, 0)
endif


LoadAnimatedSprite(waterS, "wBG/w", 52)
SetSpriteVisible(waterS, 0)
LoadAnimatedSprite(landS, "lBG/l", 60)
SetSpriteVisible(landS, 0)
if debug = 0 then LoadAnimatedSprite(airS, "sBG/s", 52)
SetSpriteVisible(airS, 0)
if debug = 0 then LoadAnimatedSprite(cutsceneSpr3, "intro/intro", 60)
SetSpriteVisible(cutsceneSpr3, 0)
if debug = 0 then LoadAnimatedSprite(cutsceneSpr2, "ending/end", 89)
SetSpriteVisible(cutsceneSpr2, 0)

//Duck 2 sprites
LoadAnimatedSprite(water2S, "w2BG/sw", 60)
SetSpriteVisible(water2S, 0)
LoadAnimatedSprite(water2TileS, "w2BG/2sw", 60)
SetSpriteVisible(water2TileS, 0)

tileI1 = LoadImage("waterTile1.png")
tileI2 = LoadImage("waterTile2.png")


//CreateTextExpress(superStart, "Game loaded." + chr(10) + "Please click"+chr(10)+"to start.", 52, fontGI, 1, w/2, h/2-52, -10, 3)

//SetPhysicsDebugOn()


//This is the array (technically not a queue) of races to be gone through in a gameplay order
global raceQueue as integer[0]
global raceQueueRef as integer[0]
global curRaceSet = 1
global raceSize = 0
if debug = 0 then SetRaceQueue(curRaceSet)

function SetRaceQueue(raceSet)
	
	//First, clearing the current race queue
	raceQueue.length = -1  // according to AGK docs this frees the memory
	// Also clear the "reference" race queue, which does not change by area
	raceQueueRef.length = -1
	
	if raceSet = 1 //Race Against a Duck order
		raceQueue.insert(WATER)
		raceQueue.insert(LAND)
		raceQueue.insert(AIR)
	elseif raceSet = 2 //Race Against a Duck 2 order
		raceQueue.insert(WATER2)
		raceQueue.insert(LAND2)
		raceQueue.insert(AIR2)
		raceQueue.insert(SPACE2)
	endif
	raceQueueRef = raceQueue
	
	raceSize = raceQueue.length
	duckDistance# = 20000*raceSize
	
	nextScreen = raceQueue[0]
	raceQueue.remove(0)
endfunction


do
    fpsr# = (60.0/ScreenFPS())*9
    if fpsr# > 5 then fpsr# = 5 
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
		
		
		if GetRawKeyState(81) and debug = 1 then heroLocalDistance# = heroLocalDistance# - 100
		
		if screen = WATER
			DoWater()
		elseif screen = LAND
			DoLand()
		elseif screen = AIR
			DoAir()
		elseif screen = WATER2
			DoWater2()
		elseif screen = LAND2
			//DoLand2()
		elseif screen = AIR2
			//DoAir2()
		elseif screen = SPACE2
			DoSpace2()
		endif
		
		if heroLocalDistance# <= 0
			if raceQueue.length > 0
				//Loading in the next race
				PlayTweenSprite(tweenSprFadeIn, coverS, 0)
				PlaySound(windMS, volumeS)
				WaitFadeTween()
				DeleteScene(screen)
				screen = 0
				nextScreen = raceQueue[1]
				raceQueue.remove(1)
			else
				//Last race just ended, finishing this 'session'
				//This was currently copied from the 'AIR' finishing code, should be updated
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
		if duckDistance# < 20000*(raceSize-areaSeen) then duckSpeed# = 100
		//Below is the old, hardcoded values for speeding the duck up when he reaches an undiscovered section - the above line is the updated one, though it may not work (needs testing)
		//if duckDistance# < 40000 and areaSeen = 1 then duckSpeed# = 100
		//if duckDistance# < 20000 and areaSeen = 2 then duckSpeed# = 100
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
				//TODO - change this current race set out to correspond with different menu screen buttons
				curRaceSet = 1
				SetRaceQueue(curRaceSet)
				
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
			SetRaceQueue(curRaceSet)
			duckSpeed# = duckSpeedDefault#
		endif
		
	endif
	

    
    UpdateAllTweens(GetFrameTime())
    
    if debug = 1
    		//Print( ScreenFPS() )
	    Print(GetRawLastKey())
	    //Print(HeroX#)
	    //if GetSpriteExists(hero)
	    //		Print(GetSpriteX(Hero))
	    //		Print(GetSpriteY(Hero))
		//endif
		Print(duckSpeed#)
		
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
	if GetTextExists(instruct) then SetTextVisible(instruct, 0)
	if GetTextExists(scrapText) then SetTextVisible(scrapText, 0)
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
		if GetImageExists(heroImg1) then DeleteImage(heroImg1)
		if GetImageExists(heroImg2) then DeleteImage(heroImg2)
		if GetImageExists(heroImg3) then DeleteImage(heroImg3)
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
			
			if scene = WATER or scene = WATER2 then LoadSpriteExpress(vehicle1+i, "w" + str$ + ".png", 60, 60, 10+i*3, 15 + i*65, 3)
			if scene = LAND or scene = LAND2 then LoadSpriteExpress(vehicle1+i, "l" + str$ + ".png", 60, 60, 10+i*3, 15 + i*65, 3)
			if scene = AIR or scene = AIR2 then LoadSpriteExpress(vehicle1+i, "s" + str$ + ".png", 60, 60, 10+i*3, 15 + i*65, 3)
			if scene = SPACE2 then LoadSpriteExpress(vehicle1+i, "s" + str$ + ".png", 60, 60, 10+i*3, 15 + i*65, 3)	//TODO: Replace these letters with new space ones
			
			CreateTextExpress(vehicle1+i, words[i+1, upgrades[i+1,scene]+1, scene], 48, fontGI, 0, 63+i*3, 35 + i*65, -11, 2)
		next i
		
		SetInstructionText(scene)
		
		//Duck will be the first spawnable object
		
		if scene = WATER
			InitWater()
		elseif scene = LAND
			InitLand()
		elseif scene = AIR
			InitAir()
		elseif scene = WATER2
			InitWater2()
		elseif scene = LAND2
			InitLand2()
		elseif scene = AIR2
			InitAir2()
		elseif scene = SPACE2
			InitSpace2()
		endif
		
		//Below line might be problematic, it's intention is to make sure the duck starts with you if you discover a new area, and duck is in rapid finish mode
		if duckSpeed# = 100 then duckDistance# = 20000*(raceSize-areaSeen)
		
		
				
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
	if scene = WATER// or scene = WATER2
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
	
	if area = WATER or area = WATER2
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
	
	if scene < UPGRADE
		
		DeleteSprite(hero)
		if GetSpriteExists(hero2) then DeleteSprite(hero2)		
		DeleteAnimatedSprite(duck)
		
		if scene = WATER
			SetSpriteVisible(waterS, 0)
			DeleteSprite(waterBarBack)
			DeleteSprite(waterBarFront)
		endif
		if scene = LAND
			SetSpriteVisible(landS, 0)
			DeleteAnimatedSprite(landBoost1)
			for i = landBoost1+1 to landBoost1 - 1 + boostTotal
				DeleteSprite(i)
			next i
			DeleteSprite(rail1)
		endif
		if scene = AIR
			SetSpriteVisible(airS, 0)
		endif

		if scene = WATER2
			SetSpriteVisible(water2S, 0)
			SetSpriteVisible(water2TileS, 0)
			DeleteParticles(lightP)
			for i = water2TileS+1 to water2TileE
				if GetSpriteExists(i) then DeleteSprite(i)
			next i
		endif
		
		if scene = SPACE2
			DeleteMashSequence()
		endif
		
		iMax = spawnActive.length
		for i = 1 to iMax
			DeleteAnimatedSprite(spawnActive[1].spr)
			spawnActive.remove(1)
		next i
			
		if GetSpriteExists(cutsceneSpr) then DeleteAnimatedSprite(cutsceneSpr)
			
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
	
	EmptyTrashBag()
	
endfunction




