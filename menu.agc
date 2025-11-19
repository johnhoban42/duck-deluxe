// File: menu.agc
// Created: 25-04-01

global menuInitialized = 0

function InitMenu()
	for i = 1 to 3
		myTxt = CreateText("")
		SetTextExpress(myTxt, "Race Against a Duck " + Str(i), 80, fontGI, 0, 60, 200 + i*100, -22, 10)
	next i
endfunction

function DoMenu()
	//Creating the main menu
	if menuInitialized = 0
		InitMenu()
		menuInitialized = 1
	endif
	
	
	//Leaving the main menu
	if 0 = 1
		//Delete objects here
		menuInitialized = 0
	endif
	
endfunction

function CreateTitle1()
	SetSpriteVisible(cutsceneSpr3, 1)
	SetSpriteExpress(cutsceneSpr3, h, h, 0, 0, 10)
	SetSpriteMiddleScreen(cutsceneSpr3)
	PlaySprite(cutsceneSpr3, 3, 0, 1, 60)
	
	CreateTextExpress(cutsceneSpr, "Press SPACE to skip.", 40, fontMI, 2, w-20, h-60, -6, 8)
	SetTextVisible(cutsceneSpr, 0)
	
	SetSpriteVisible(bg, 0)
		
	LoadSpriteExpress(logo, "logo2.png", 460, 460, 0, 0, 20)
	SetSpriteMiddleScreen(logo)
	IncSpriteY(logo, -70)
	
	LoadSpriteExpress(startRace, "startButtonMid.png", 230, 230, 0, 0, 20)
	SetSpriteMiddleScreen(startRace)
	IncSpriteY(startRace, 230)
	PlayMusicOGG(introM, 0)
endfunction

function DoTitle1()
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
			curRaceSet = 2
			SetRaceQueue(curRaceSet)
			
			duckSpeed# = duckSpeedDefault#
			if GetMusicPlayingOGG(introM) then StopMusicOGG(introM)
			if GetMusicPlayingOGG(titleM) then StopMusicOGG(titleM)
		endif
	endif
endfunction

function CreateTitle2()
	LoadGame()
	//firstDuck2Race = 1
	//areaSeen = 3
	//scrapTotal = 10
	SetSpriteVisible(cutsceneSpr3, 1)
	SetSpriteExpress(cutsceneSpr3, h, h, 0, 0, 10)
	SetSpriteMiddleScreen(cutsceneSpr3)
	PlaySprite(cutsceneSpr3, 3, 0, 1, 60)
	
	CreateTextExpress(cutsceneSpr, "Press SPACE to skip.", 40, fontMI, 2, w-20, h-60, -6, 8)
	SetTextVisible(cutsceneSpr, 0)
	
	SetSpriteVisible(bg, 0)
		
	LoadSpriteExpress(logo, "logo2.png", 460, 460, 0, 0, 20)
	SetSpriteMiddleScreen(logo)
	IncSpriteY(logo, -70)
	
	CreateSpriteExpress(startRace, 230, 230, 0, 0, 20)
	img = LoadImage("startButtonMid.png")
	AddSpriteAnimationFrame(startRace, img)
	trashBag.insert(img)
	img = LoadImage("startButtonPressed.png")
	AddSpriteAnimationFrame(startRace, img)
	trashBag.insert(img)
	img = LoadImage("startButton.png")
	AddSpriteAnimationFrame(startRace, img)
	trashBag.insert(img)
	SetSpriteFrame(startRace, 3)
	//StopSprite(startRace)
	SetSpriteMiddleScreen(startRace)
	SetSpriteShape(startRace, 3)
	IncSpriteY(startRace, 230)
	IncSpriteX(startRace, -180)
	PlayMusicOGG(introM, 0)
	
	LoadSpriteExpress(contRace, "contButtonCant.png", 230, 230, 0, 0, 20)
	img = LoadImage("contButtonMid.png")
	AddSpriteAnimationFrame(contRace, img)
	trashBag.insert(img)
	img = LoadImage("contButtonPressed.png")
	AddSpriteAnimationFrame(contRace, img)
	trashBag.insert(img)
	img = LoadImage("contButton.png")
	AddSpriteAnimationFrame(contRace, img)
	trashBag.insert(img)
	if firstDuck2Race = 1 then SetSpriteFrame(contRace, 3)
	//StopSprite(contRace)
	SetSpriteMiddleScreen(contRace)
	SetSpriteShape(contRace, 3)
	IncSpriteY(contRace, 230)
	IncSpriteX(contRace, 180)
	
	CreateTextExpress(contRace, "Starting a new race will erase progress. Are you sure?", 50, fontMI, 1, w/2, 800, -10, 5)
	
	PlayMusicOGG(introM, 0)
endfunction

function DoTitle2()
	if GetSpritePlaying(cutsceneSpr3) = 0 and GetSpriteVisible(cutsceneSpr3) = 1
		PlayMusicOGG(titleM, 1)
		SetSpriteColor(coverS, 0, 0, 0, 255)
		SetSpriteVisible(cutsceneSpr3, 0)
		SetSpriteVisible(coverS, 1)
		SetSpriteVisible(bg, 1)
		PlayTweenSprite(tweenSprFadeOut, coverS, .3)
		SetTextVisible(cutsceneSpr, 0)
		
	endif
	
	if Hover(startRace)
		if GetSpriteCurrentFrame(startRace) <> 1 then PlaySound(clickDownS, volumeS)
		SetSpriteFrame(startRace, 1)
	else
		if GetSpriteCurrentFrame(startRace) <> 3 then PlaySound(clickUpS, volumeS)
		SetSpriteFrame(startRace, 3)
	endif
	
	//The continue button only moves if a save exists
	if firstDuck2Race = 1
		if Hover(contRace)
			if GetSpriteCurrentFrame(contRace) <> 1 then PlaySound(clickDownS, volumeS)
			SetSpriteFrame(contRace, 1)
		else
			if GetSpriteCurrentFrame(contRace) <> 3 then PlaySound(clickUpS, volumeS)
			SetSpriteFrame(contRace, 3)
		endif
	endif
	
	//Continuing to move the text if it's already on it's way up
	if GetTextY(contRace) < 800 then GlideTextToSpot(contRace, w/2, 640, 10)
	
	if inputSelect or Button(startRace) or GetPointerPressed()
		
		
		if GetSpriteVisible(cutsceneSpr3) and GetTextVisible(cutsceneSpr) = 0
			SetTextVisible(cutsceneSpr, 1)
			PlaySound(selectS, volumeS)
		elseif GetSpritePlaying(cutsceneSpr3) and GetTextVisible(cutsceneSpr) and inputSelect
			StopSprite(cutsceneSpr3)
			PlaySound(selectS, volumeS)
			
			if GetMusicPlayingOGG(introM) then StopMusicOGG(introM)
		elseif Button(startRace) and firstDuck2Race = 1 and GetTextY(contRace) > 700
			GlideTextToSpot(contRace, w/2, 580, 10)
			
		elseif (Button(contRace) and firstDuck2Race = 1) or Button(startRace) or inputSelect
			
			if Button(startRace) or (firstDuck2Race = 0)
				PlaySprite(startRace, 15, 0, 2, 3)
				firstDuck2Race = 0
				scrapTotal = 0
				areaSeen = 1
			else
				//Continuing race will be the default, if just 'inputSelect' is triggered, then the game will continue
				PlaySprite(contRace, 15, 0, 2, 3)
			endif
			
			//Can play button sound at full volume because it's disabled for main menu buttons
			PlaySound(selectS, volumeS)
			//if inputSelect then PlaySound(selectS, volumeS)
			SetSpriteColor(coverS, 255, 255, 255, 0)
			PlayTweenSprite(tweenSprFadeIn, coverS, 0)
			PlaySound(windMS, volumeS)
			PlaySound(clapS, volumeS)
			WaitFadeTween()
			DeleteScene(screen)
			screen = 0
			//TODO - change this current race set out to correspond with different menu screen buttons
			curRaceSet = 2
			SetRaceQueue(curRaceSet)
			
			duckSpeed# = duckSpeedDefault#
			if GetMusicPlayingOGG(introM) then StopMusicOGG(introM)
			if GetMusicPlayingOGG(titleM) then StopMusicOGG(titleM)
		endif
	endif
endfunction


function SaveGame()
	SaveSharedVariable("scrapTotal", str(scrapTotal))
	SaveSharedVariable("areaSeen", str(areaSeen))
	SaveSharedVariable("firstDuck2Race", str(firstDuck2Race))
endfunction

function LoadGame()
	scrapTotal = val(LoadSharedVariable("scrapTotal", "0"))
	areaSeen = val(LoadSharedVariable("areaSeen", "1"))
	firstDuck2Race = val(LoadSharedVariable("firstDuck2Race", "0"))
endfunction