// File: menu.agc
// Created: 25-04-01

global menuInitialized = 0
global menuLineSelected = 1
global menuThumbnail
global menuDescText

global pauseLineSelected = 1

type menuItem
	id as string
	name as string
	desc as string
	
	txt as integer
	//parent as menuItem
endtype

global mainMenuLine as menuItem[0]

function InitMenu()
	//for i = 1 to 3
	//	myTxt = CreateText("")
	//	SetTextExpress(myTxt, "Race Against a Duck " + Str(i), 80, fontGI, 0, 60, 200 + i*100, -22, 10)
	//next i
	
	OpenToRead(2, "menuOptions.txt")
	newItem$ = ReadLine(2)
	nLine as menuItem
	
	lineMainID = 0
	
	while (newItem$ <> "")
		
		if Left(newItem$, 1) <> "~"
			//Is a new head title
			inc lineMainID, 1	//This gets incremented when a new head title appears
			if lineMainID <> 1 then mainMenuLine.insert(nLine)
			
			nLine.id = str(lineMainID)
			
			if FindStringCount(newItem$, "=") > 0 then newItem$ = GetStringToken(newItem$, "=", 1)
			nLine.name = newItem$
			
		else
			//Is a description
			nLine.desc = newItem$
		endif
		
		
		newItem$ = ReadLine(2)
	endwhile
	mainMenuLine.insert(nLine)

	for i = 1 to mainMenuLine.length
		mainMenuLine[i].txt = CreateText("")
		SetTextExpress(mainMenuLine[i].txt, mainMenuLine[i].name, 50, fontMI, 0, 40, 40 + 80*i, -10, 20)
		//SetTextColor(mainMenuLine[i].txt, 100, 100, 100, 255)
	next i
	SetTextX(mainMenuLine[menuLineSelected].txt, 65)
	
	CloseFile(2)
	
	menuThumbnail = CreateSprite(0)
	SetSpriteExpress(menuThumbnail, 400, 400, 600, 130, 40)
	SetSpriteColor(menuThumbnail, 100, 100, 100, 255)
	
	
endfunction

function DoMenu()
	//Creating the main menu
	if menuInitialized = 0
		InitMenu()
		menuInitialized = 1
		
		if GetSpriteExists(coverS) then PlayTweenSprite(tweenSprFadeOut, coverS, 0)
	endif
	
	//Changing the selected menu line item
	if InputUp or InputDown
		
		PlaySound(selectS, volumeS)
		SetTextX(mainMenuLine[menuLineSelected].txt, 40)
		if InputDown
			inc menuLineSelected, 1
		elseif InputUp
			dec menuLineSelected, 1
		endif
		if menuLineSelected = 0 then menuLineSelected = mainMenuLine.length
		if menuLineSelected > mainMenuLine.length then menuLineSelected = 1
		SetTextX(mainMenuLine[menuLineSelected].txt, 65)
		
	endif
	
	
	for i = 1 to mainMenuLine.length		
		
		for j = 0 to Len(mainMenuLine[i].name)
			SetTextCharY(mainMenuLine[i].txt, j, 1*Sin(gameTime#+j*2+i*20))
			if i = menuLineSelected then SetTextCharY(mainMenuLine[i].txt, j, 5*Sin(gameTime#-j*12+i*20))
		next j
	next i
	
	Print(menuLineSelected)
	//Print(GetTextY(mainMenuLine[2].txt))
	//Leaving the main menu
	
	leaveMenu = 0
	if inputSelect
		//TODO: check that the existing option can be selected
		if menuLineSelected = 1 //RAaD ReDucks
			curRaceSet = 1
			leaveMenu = 1
			webVersion = 0
		elseif menuLineSelected = 2 //RAaD 2
			curRaceSet = 2
			leaveMenu = 1
			webVersion = 0
		elseif menuLineSelected = 3 //Mystery, for now
			ShowPopup("You can still upgrade! Leave" + chr(10) + "without spending your scrap?", 1)
		elseif menuLineSelected = 5 //Duck Radio
			nextScreen = RADIO
			screen = 0
			leaveMenu = 1
			curRaceSet = 0
		elseif menuLineSelected = 6	//RAaD Original
			curRaceSet = 1
			leaveMenu = 1
			webVersion = 1
		endif
	endif
	
	if leaveMenu = 1
		ClearPopup()
		
		spawnS = spawnStartS
		
		if curRaceSet = 1 or curRaceSet = 2
			SetRaceQueue(curRaceSet)
			nextScreen = TITLE
			screen = 0
		endif
		PlaySound(beepGoS, volumeS)
		
		for i = 1 to mainMenuLine.length
			DeleteText(mainMenuLine[i].txt)
		next i
		while mainMenuLine.length > 0
			mainMenuLine.remove(0)
		endwhile
		DeleteSprite(menuThumbnail)
		
		menuInitialized = 0
	endif
	
endfunction

global settingsChanged = 0
function DoPauseMenu()
	leavePause = 0
	returnDeluxeMenu = 0
	
	if InputUp or InputDown or inputEsc
		ClearPopup()
		PlaySound(collectS, volumeS)
		
		SetTextX(pauseLine[pauseLineSelected], 140 + pauseLineSelected*15)
		if InputDown
			inc pauseLineSelected, 1
		elseif InputUp
			dec pauseLineSelected, 1
		endif
		if pauseLineSelected <> 1 and inputEsc
			pauseLineSelected = 1
			inputEsc = 0
		endif
		if pauseLineSelected = 0 then pauseLineSelected = pauseLine.length
		if pauseLineSelected > pauseLine.length then pauseLineSelected = 1
		SetTextX(pauseLine[pauseLineSelected], 165 + pauseLineSelected*15)
		
		SetTextString(pauseLine[2], pauseOptions[2] + ": " + str(volumeG))
		SetTextString(pauseLine[3], pauseOptions[3] + ": " + str(volumeM))
		SetTextString(pauseLine[4], pauseOptions[4] + ": " + str(volumeS))
		if pauseLineSelected = 2
			SetTextString(pauseLine[2], pauseOptions[2] + ": <- " + str(volumeG) + " ->")
			if volumeG = 0 then SetTextString(pauseLine[2], pauseOptions[2] + ":    0 ->")
			if volumeG = 100 then SetTextString(pauseLine[2], pauseOptions[2] + ": <- 100")
		endif
		if pauseLineSelected = 3
			SetTextString(pauseLine[3], pauseOptions[3] + ": <- " + str(volumeM) + " ->")
			if volumeM = 0 then SetTextString(pauseLine[3], pauseOptions[3] + ":    0 ->")
			if volumeM = 100 then SetTextString(pauseLine[3], pauseOptions[3] + ": <- 100")
		endif
		if pauseLineSelected = 4
			SetTextString(pauseLine[4], pauseOptions[4] + ": <- " + str(volumeS) + " ->")
			if volumeS = 0 then SetTextString(pauseLine[4], pauseOptions[4] + ":    0 ->")
			if volumeS = 100 then SetTextString(pauseLine[4], pauseOptions[4] + ": <- 100")
		endif

	endif
	
	if inputSelect
		//TODO: check that the existing option can be selected
		if pauseLineSelected = 1 //Resume Race
			leavePause = 1
		elseif pauseLineSelected = pauseLine.length and isDuckDeluxe //Return to triathlon menu
			if GetPopupActive()
				returnDeluxeMenu = 1
				leavePause = 1
			else
				ShowPopup("Return to main menu?" + chr(10) + "(Progress will be saved.)", 1)
			endif
		elseif pauseLineSelected = 5 //Forfeit Race
			if GetPopupActive()
				duckSpeed# = 36*fpsr#
				leavePause = 1
			else
				ShowPopup("You sure? You will keep your" + chr(10) + "scrap. (You can also press 'R'.)", 1)
			endif
			//If in the upgrade screen, change the text, and go back to the title screen
		
		endif
	endif
	
	
	for i = 1 to pauseLine.length		
		for j = 0 to Len(GetTextString(pauseLine[i]))
			SetTextCharY(pauseLine[i], j, 1*Sin(gameTime#+j*2+i*20))
			if i = pauseLineSelected then SetTextCharY(pauseLine[i], j, 5*Sin(gameTime#-j*12+i*20))
		next j
	next i
	
	Print(pauseLineSelected)
	
	if (stateLeft or stateRight) and GetSoundInstances(selectS) = 0
		if stateLeft then dec holdTimer#, GetFrameTime()*90
		if stateRight then inc holdTimer#, GetFrameTime()*90
		//Need to update strings outside of the inputLeft/Right block, should make a new stateLeft/Right block and move the string updates there
	endif
	Print(holdTimer#)
	
	volInc = 5
	
	if inputLeft or inputRight
		ClearPopup()
		holdTimer# = 0
		if pauseLineSelected = 2 //Global Volume
			PlaySound(selectS, volumeS)
			if inputLeft	//Lower
				volumeG = Max(volumeG-volInc, 0)
			else	//Right, Higher
				volumeG = Min(volumeG+volInc, 100)
			endif
			volumeG = Round((volumeG)/5) * 5
			settingsChanged = 1
		endif
		
		if pauseLineSelected = 3 //Music Volume
			PlaySound(selectS, volumeS)
			if inputLeft	//Lower
				volumeM = Max(volumeM-volInc, 0)
			else	//Right, Higher
				volumeM = Min(volumeM+volInc, 100)
			endif
			volumeM = Round((volumeM)/5) * 5
			settingsChanged = 1
		endif
		
		if pauseLineSelected = 4 //Sound Volume
			PlaySound(selectS, volumeS)
			if inputLeft	//Lower
				volumeS = Max(volumeS-volInc, 0)
			else	//Right, Higher
				volumeS = Min(volumeS+volInc, 100)
			endif
			volumeS = Round((volumeS)/5) * 5
			settingsChanged = 1
		endif
		
		SetMusicSystemVolumeOGG(volumeG*volumeM/100.0)
		SetSoundSystemVolume(volumeG*volumeS/100.0)
	endif
	
	if stateLeft or stateRight
		if pauseLineSelected = 2 //Global Volume
			SetTextString(pauseLine[2], pauseOptions[2] + ": <- " + str(Trunc(volumeG+holdTimer#)) + " ->")
			if (volumeG+holdTimer#) <= 0 then SetTextString(pauseLine[2], pauseOptions[2] + ":    0 ->")
			if (volumeG+holdTimer#) >= 100 then SetTextString(pauseLine[2], pauseOptions[2] + ": <- 100")
			
			SetMusicSystemVolumeOGG((volumeG+holdTimer#)*volumeM/100.0)
			SetSoundSystemVolume((volumeG+holdTimer#)*volumeS/100.0)
		endif
		
		if pauseLineSelected = 3 //Music Volume
			SetTextString(pauseLine[3], pauseOptions[3] + ": <- " + str(Trunc(volumeM+holdTimer#)) + " ->")
			if (volumeM+holdTimer#) <= 0 then SetTextString(pauseLine[3], pauseOptions[3] + ":    0 ->")
			if (volumeM+holdTimer#) >= 100 then SetTextString(pauseLine[3], pauseOptions[3] + ": <- 100")
			SetMusicSystemVolumeOGG((volumeM+holdTimer#)*volumeG/100.0)
		endif
		
		if pauseLineSelected = 4 //Sound Volume
			SetTextString(pauseLine[4], pauseOptions[4] + ": <- " + str(Trunc(volumeS+holdTimer#)) + " ->")
			if (volumeS+holdTimer#) <= 0 then SetTextString(pauseLine[4], pauseOptions[4] + ":    0 ->")
			if (volumeS+holdTimer#) >= 100 then SetTextString(pauseLine[4], pauseOptions[4] + ": <- 100")
			SetSoundSystemVolume((volumeS+holdTimer#)*volumeG/100.0)
		endif
		
	endif

	if inputEsc and pauseLineSelected then leavePause = 1

	if releaseLeft or releaseRight or leavePause
		if pauseLineSelected = 2 then volumeG = Min(Max(volumeG + holdTimer#, 0), 100)
		if pauseLineSelected = 3 then volumeM = Min(Max(volumeM + holdTimer#, 0), 100)
		if pauseLineSelected = 4 then volumeS = Min(Max(volumeS + holdTimer#, 0), 100)
		SetMusicSystemVolumeOGG(volumeG*volumeM/100.0)
		SetSoundSystemVolume(volumeG*volumeS/100.0)
	endif
	
	Print(volumeG)

	TintPauseText()
	
	if leavePause
		DeleteSprite(pauseScreen)
		iEnd = 4
		if screen < UPGRADE then inc iEnd, 1
		if isDuckDeluxe then inc iEnd, 1
		for i = 1 to iEnd
			DeleteText(pauseLine[i])
		next i
		//Get rid of the pause screen artifacts
		ResumeMusicOGG(curRaceMusic)
		ResumeMusicOGG(oldRaceMusic)
		if settingsChanged <> 0 then SaveGame()
		if screen = UPGRADE and webVersion = 0
			PauseMusicOGG(upgrade2M)
			ResumeMusicOGG(upgrade2M)
		elseif screen = UPGRADE and webVersion = 1
			PauseMusicOGG(upgradeM)
			ResumeMusicOGG(upgradeM)
		endif
		ClearPopup()
		UnfreezeGameplay()
		paused = 0
		inputSelect = 0
		inputEsc = 0
		
		if returnDeluxeMenu
			
			if GetMusicPlayingOGG(introM) then StopMusicOGG(introM)
			if GetMusicPlayingOGG(titleM) then StopMusicOGG(titleM)
			
			PlayTweenSprite(tweenSprFadeIn, coverS, 0)
			PlaySound(windMS, volumeS)
			WaitFadeTween()
			DeleteScene(screen)
			SetSpriteVisible(bg, 0)
			SetTextVisible(scrapText, 0)
			PlaySprite(cutsceneSpr3, 3, 0, 1, 60)
			StopSprite(cutsceneSpr3)
			if screen = UPGRADE
				StopMusicOGG(upgrade2M)
				DeleteUpgrade2()
			endif
			screen = 0
			nextScreen = MENU
			SaveGame()
				
			
		endif
		
	endif
	
endfunction

function TintPauseText()
	longLen = 0
	for i = 1 to pauseLine.length
		longLen = Max(longLen, Len(GetTextString(pauseLine[i])))
	next i
	r1 = 255
	g1 = 50
	b1 = 220
	r2 = 129
	g2 = 255
	b2 = 124
	
	for i = 1 to pauseLine.length
		strLen = Len(GetTextString(pauseLine[i]))
		for j = 0 to strLen
			SetTextCharColor(pauseLine[i], j, 255, 255, 255, 255)
			if j < longLen*3/7 then SetTextCharColor(pauseLine[i], j, r1+(255-r1)*(j/(longLen*3/7)), g1+(255-g1)*j/(longLen*3/7), b1+(255-b1)*j/(longLen*3/7), 255)
			if j > longLen*4/7 then SetTextCharColor(pauseLine[i], j, 255-((j-longLen*4/7)*(255-r2)/(longLen*3/7)), 255-((j-longLen*4/7)*(255-g2)/(longLen*3/7)), 255-((j-longLen*4/7)*(255-b2)/(longLen*3/7)), 255)
			//255-((j-longLen*4/7)*(255-r2)/(longLen*3/7))
		next j
	next i
		
endfunction

function CreateTitle1()
	
	HideUIText()
	SetSpriteVisible(pauseButton, 0)
	
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
		SetSpriteVisible(pauseButton, 1)
		
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
			//DeleteScene(scene)
			screen = 0
			//TODO - change this current race set out to correspond with different menu screen buttons
			if isDuckDeluxe = 0 then curRaceSet = 2
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
	HideUIText()
	SetSpriteVisible(pauseButton, 0)
	
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
	
	CreateSpriteExpress(firstGameButton, 230, 230, 0, 0, 20)
	img = LoadImage("firstGameButtonMid.png")
	AddSpriteAnimationFrame(firstGameButton, img)
	trashBag.insert(img)
	img = LoadImage("firstGameButtonPressed.png")
	AddSpriteAnimationFrame(firstGameButton, img)
	trashBag.insert(img)
	img = LoadImage("firstGameButton.png")
	AddSpriteAnimationFrame(firstGameButton, img)
	trashBag.insert(img)
	SetSpriteMiddleScreen(firstGameButton)
	SetSpriteShape(firstGameButton, 3)
	IncSpriteY(firstGameButton, 230)
	IncSpriteX(firstGameButton, -480)
	if isDuckDeluxe then SetSpriteVisible(firstGameButton, 0)
	
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
		SetSpriteVisible(pauseButton, 1)
		
	endif
	
	if Hover(startRace) and GetSpritePlaying(cutsceneSpr3) = 0
		if GetSpriteCurrentFrame(startRace) <> 1 then PlaySound(clickDownS, volumeS)
		SetSpriteFrame(startRace, 1)
	else
		if GetSpriteCurrentFrame(startRace) <> 3 then PlaySound(clickUpS, volumeS)
		SetSpriteFrame(startRace, 3)
	endif
	
	if Hover(firstGameButton) and GetSpritePlaying(cutsceneSpr3) = 0 and isDuckDeluxe = 0
		if GetSpriteCurrentFrame(firstGameButton) <> 1 then PlaySound(clickDownS, volumeS)
		SetSpriteFrame(firstGameButton, 1)
	else
		if GetSpriteCurrentFrame(firstGameButton) <> 3 then PlaySound(clickUpS, volumeS)
		SetSpriteFrame(firstGameButton, 3)
	endif
	if Button(firstGameButton) and GetSpritePlaying(cutsceneSpr3) = 0 and isDuckDeluxe = 0
		PlaySprite(firstGameButton, 15, 0, 2, 3)
		PlaySound(selectS, volumeS)
		OpenBrowser("https://www.newgrounds.com/portal/view/910584")
	endif
	
	//The continue button only moves if a save exists
	if firstDuck2Race = 1 and GetSpritePlaying(cutsceneSpr3) = 0
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
			
		elseif ((Button(contRace) and firstDuck2Race = 1) or Button(startRace) or inputSelect) and GetSpritePlaying(cutsceneSpr3) = 0
			
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

//global saveSpr = 0
global saveImg

function SaveGame()
//~	OpenToWrite(1, "duck2Save.txt")
//~	
//~	WriteLine(1, str(scrapTotal))
//~	WriteLine(1, str(areaSeen))
//~	WriteLine(1, str(firstDuck2Race))
//~	
//~	CloseFile(1)
	
	if GetSpriteExists(saveSpr) = 0
		saveImg = LoadImage("saveIcon.png")
		CreateSprite(saveSpr, saveImg)
		SetSpriteExpress(saveSpr, 80, 80, w-120, h-120, 1)
		FixSpriteToScreen(saveSpr, 1)
		//AddSpriteAnimationFrame(saveSpr, blankI)
		AddSpriteAnimationFrame(saveSpr, saveImg)
		AddSpriteAnimationFrame(saveSpr, blankI)
		AddSpriteAnimationFrame(saveSpr, saveImg)
		AddSpriteAnimationFrame(saveSpr, blankI)
		AddSpriteAnimationFrame(saveSpr, saveImg)
		AddSpriteAnimationFrame(saveSpr, saveImg)
		AddSpriteAnimationFrame(saveSpr, saveImg)
		AddSpriteAnimationFrame(saveSpr, saveImg)
		AddSpriteAnimationFrame(saveSpr, blankI)
	endif
	StopSprite(saveSpr)
	PlaySprite(saveSpr, 8, 0)
	
	SaveSharedVariable("scrapTotal", str(scrapTotal))
	SaveSharedVariable("areaSeen", str(areaSeen))
	SaveSharedVariable("firstDuck2Race", str(firstDuck2Race))
	for i = 1 to 4
		for j = 1 to 7
			SaveSharedVariable("upgrade" + str(i) + str(j), str(upgrades[i, j]))
		next j
	next i
	
	SaveSharedVariable("volumeM", str(volumeM))
	SaveSharedVariable("volumeS", str(volumeS))
	SaveSharedVariable("volumeG", str(volumeG))
	SaveSharedVariable("tipNum", str(tipNum))
	
	SaveSharedVariable("water2InsTrigger1", str(water2InsTrigger1))
	SaveSharedVariable("land2InsTrigger1", str(land2InsTrigger1))
	SaveSharedVariable("upgradeInsTrigger1", str(upgradeInsTrigger1))
	
	
endfunction

function LoadGame()
//~	OpenToRead(1, "duck2Save.txt")
//~	
//~	scrapTotal = Val(ReadLine(1))
//~	areaSeen = Val(ReadLine(1))
//~	firstDuck2Race = Val(ReadLine(1))
//~	
//~	CloseFile(1)
	
	scrapTotal = val(LoadSharedVariable("scrapTotal", "0"))
	areaSeen = val(LoadSharedVariable("areaSeen", "0"))
	firstDuck2Race = val(LoadSharedVariable("firstDuck2Race", "0"))
	for i = 1 to 4
		for j = 1 to 7
			upgrades[i, j] = val(LoadSharedVariable("upgrade" + str(i) + str(j), "0"))
		next j
	next i
	
	volumeM = val(LoadSharedVariable("volumeM", "100"))
	volumeS = val(LoadSharedVariable("volumeS", "100"))
	volumeG = val(LoadSharedVariable("volumeG", "100"))
	tipNum = val(LoadSharedVariable("tipNum", "0"))
	
	water2InsTrigger1 = val(LoadSharedVariable("water2InsTrigger1", "0"))
	land2InsTrigger1 = val(LoadSharedVariable("land2InsTrigger1", "0"))
	upgradeInsTrigger1 = val(LoadSharedVariable("upgradeInsTrigger1", "0"))
	
endfunction



