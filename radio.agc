// File: radio.agc
// Created: 26-01-16

global radioInitialized = 0

/////////////////////////////


// File: soundtest.agc
// Created: 23-10-03

global soundtestStateInitialized as integer = 0

global soundPlaying = 0

// Sound Check Misc Sprites
#constant sprSoundBase 6900
#constant sprSoundBack 6950
#constant sprSoundControl 6951
#constant sprSoundSelectLeft 6952
#constant sprSoundSelectRight 6953
#constant sprSoundDisplay 6958

// Sound Check Tweens
#constant twnSCLeftIn 6960
#constant twnSCLeftOut 6961
#constant twnSCRightIn 6962
#constant twnSCRightOut 6963

#constant soundTweenFI 929
#constant soundTweenFO 930

// current index of the sound player, modified by pressing the left or right buttons
global soundIndex = 0

// current index of the set title screen music, modified by pressing the set title screen music button
global titleIndex = 1

// current index of the set character selection screen music, modified by pressing the set character selection screen music button
global characterSelectIndex = 6

#constant jukeboxTweenTime 0.2

global stVol = 100

// Initialize the sound test screen
function InitSoundTest()
	
	//CreateSpriteExpressImage(ST_TITLE, bg3I, w*2, w*2, 0, 0, 1000)
	//if dispH then SetSpriteSizeSquare(ST_TITLE, h*2)
	//SetSpriteMiddleScreen(ST_TITLE)
	
	//Creation of the sprites/anything else needed goes here

	// create the music display sprite with each frame tied to one of the songs in our list
	CreateSprite(sprSoundDisplay, 0)
	for i = 1 to 8
		//if (i > 30 or i <= musicUnlocked)
		img = LoadImage("radio/banner" + str(i) + ".png")
		AddSpriteAnimationFrame(sprSoundDisplay, img)
		trashBag.insert(img)
		//endif
	next i
			
	CreateTweenCustom(soundTweenFI, .05)
	CreateTweenCustom(soundTweenFO, .1)
	SetTweenCustomInteger1(soundTweenFI, 1, 100, TweenSmooth1())
	SetTweenCustomInteger1(soundTweenFO, 100, 1, TweenSmooth1())
			
	// create the tweens for the song display banners to move on/off-screen via
	CreateTweenSprite(twnSCLeftIn, jukeboxTweenTime)
	CreateTweenSprite(twnSCLeftOut, jukeboxTweenTime)
	CreateTweenSprite(twnSCRightIn, jukeboxTweenTime)
	CreateTweenSprite(twnSCRightOut, jukeboxTweenTime)
	// position items based on device type
		
	
	// create the play/pause button
	LoadAnimatedSprite(sprSoundControl, "radio/play", 2)
	AddButton(sprSoundControl)
	
	LoadAnimatedSprite(sprSoundBack, "radio/back", 8)
	SetSpriteFrame(sprSoundBack, 8)
	AddButton(sprSoundBack)
	
	LoadSprite(sprSoundSelectLeft, "radio/leftArrow")
	LoadSprite(sprSoundSelectRight, "radio/leftArrow")
	SetSpriteAngle(sprSoundSelectLeft, 180)
	
	// position the current title song display
	
	// set the current character select music sprite frame to the correct value
		
	// create and position the jukebox base
	LoadSpriteExpress(sprSoundBase, "jukeboxdesktoptest.png", w, h, 0, 0, 70)
	//SetSpriteColorAlpha(sprSoundBase, 130)
	// create & position the simple buttons
	bSize = 160
	SetSpriteExpress(sprSoundBack, bSize, bSize, w/2 - bSize/2, h*4/5 - bSize/2 + 30, 69)
	SetSpriteExpress(sprSoundSelectLeft, bSize, bSize, w/7 - bSize/2 + 20, h/4 - bSize/2 + 20, 69)
	SetSpriteExpress(sprSoundSelectRight, bSize, bSize, w*6/7 - bSize/2 - 20, h/4 - bSize/2 + 20, 69)
	
	// position play/pause button
	SetSpriteExpress(sprSoundControl, bSize, bSize, w/2 - bSize/2, h/2 - bSize/2+20, 69)
	
	// position the song display
	banMult# = 183
	SetSpriteExpress(sprSoundDisplay, banMult#*7/2, banMult#, w/2 - banMult#*7/4, h/4 - banMult#/2+20, 71)
	


	
	// create the tweens for moving the song display sprite around when switching songs
	bannerWid = GetSpriteWidth(sprSoundDisplay)
	bannerMidX = w/2 - bannerWid/2
	//SetTweenSpriteX(twnSCLeftOut, bannerMidX, w, TweenOvershoot())
	//SetTweenSpriteX(twnSCLeftIn, -bannerWid, bannerMidX, TweenOvershoot())	
	//SetTweenSpriteX(twnSCRightOut, bannerMidX, -bannerWid, TweenOvershoot())	
	//SetTweenSpriteX(twnSCRightIn, w, bannerMidX, TweenOvershoot())
	
	SetTweenSpriteX(twnSCLeftOut, bannerMidX, bannerMidX+bannerWid*1.5, TweenSmooth1())
	SetTweenSpriteX(twnSCLeftIn, bannerMidX-bannerWid*1.5, bannerMidX, TweenOvershoot())	
	SetTweenSpriteX(twnSCRightOut, bannerMidX, bannerMidX-bannerWid*1.5, TweenSmooth1())	
	SetTweenSpriteX(twnSCRightIn, bannerMidX+bannerWid*1.5, bannerMidX, TweenOvershoot())
	
	// add button animations/functionality to the buttons of our screen
	
	AddButton(sprSoundControl)
	
	soundtestStateInitialized = 1
endfunction

// Soundtest screen execution loop
// Each time this loop exits, return the next state to enter into
function DoRadio()
	
	// Initialize if we haven't done so
	// Don't write anything before this!
	if radioInitialized = 0
		InitSoundTest()
	endif
	
	
	//if mod(round(localSeconds#)+1080, 8) = 0 and GetSpritePlaying(sprSoundBack) = 0 then PlaySprite(sprSoundBack, 10, 0, 1, 8)
	
	leaveRadio = 0
	
	//Do loop for the mode is here
	//check which button the player hit
	// back button
	if ButtonMultiTouchEnabled(sprSoundBack)
		leaveRadio = 1
		if soundPlaying = 1
			soundPlaying = 0
			StopMusicOGGSP(soundIndex)
			StopRaceMusic()	
			SetSpriteFrame(sprSoundControl, 1)
		endif
	// play/pause button
	
	elseif ButtonMultiTouchEnabled(sprSoundControl)
		// start playing song
		if soundPlaying = 0
			soundPlaying = 1
			if GetMusicPlayingOGGSP(soundIndex)
				PlayTweenCustom(soundTweenFI, 0)
				ResumeMusicOGG(soundIndex)
			else
				PlayMusicOGG(soundIndex, 1)
			endif
			SetSpriteFrame(sprSoundControl, 2)
		// stop playing song
		else
			soundPlaying = 0
			//PauseMusicOGG(GetMusicByID(FrameToSongID(soundIndex)))
			PlayTweenCustom(soundTweenFO, 0)
			SetSpriteFrame(sprSoundControl, 1)
		endif
	// song scroll left or right
	elseif (ButtonMultitouchEnabled(sprSoundSelectLeft) or ButtonMultitouchEnabled(sprSoundSelectRight)) //and GetSpriteX(sprSoundDisplay) = w / 2 - GetSpriteWidth(sprSoundDisplay) / 2
		// stop current music
		if soundPlaying = 1
			//soundPlaying = 0
			StopMusicOGGSP(soundIndex)
			//SetSpriteFrame(sprSoundControl, 1)
		endif
		//Quick mover stops the song spammers from crashing the game
		quickMover = 0
		if GetTweenSpritePlaying(twnSCRightOut, sprSoundDisplay) or GetTweenSpritePlaying(twnSCRightIn, sprSoundDisplay) or GetTweenSpritePlaying(twnSCLeftOut, sprSoundDisplay) or GetTweenSpritePlaying(twnSCLeftIn, sprSoundDisplay) then quickMover = 1
		
		UpdateAllTweens(jukeboxTweenTime*2)
		SetSpriteFrame(sprSoundDisplay, soundIndex + 1)
		stVol = 100
		// scroll left
		if ButtonMultitouchEnabled(sprSoundSelectLeft)
			// decrement sound index
			soundIndex = soundIndex - 1
			// handle wrap around
			if soundIndex = -1
				soundIndex = GetSpriteFrameCount(sprSoundDisplay)-1
			// jump indices to skip locked songs
			//elseif soundList[soundIndex] < 31 and soundList[soundIndex] > musicUnlocked
				//soundIndex = musicUnlocked
			endif
			// animate old banner frame out and new banner frame in
			PlayTweenSprite(twnSCLeftOut, sprSoundDisplay, 0)
			PlayTweenSprite(twnSCLeftIn, sprSoundDisplay, jukeboxTweenTime)
		// scroll right
		elseif ButtonMultitouchEnabled(sprSoundSelectRight)
			// increment sound index
			soundIndex = soundIndex + 1
			// handle wrap around
			if soundIndex = GetSpriteFrameCount(sprSoundDisplay)
				soundIndex = 0
			// jump indices to skip locked songs
			//elseif soundList[soundIndex] < 31 and soundList[soundIndex] > musicUnlocked
				//soundIndex = soundList.length - 11
			endif
			// animate old banner frame out and new banner frame in
			PlayTweenSprite(twnSCRightOut, sprSoundDisplay, 0)
			PlayTweenSprite(twnSCRightIn, sprSoundDisplay, jukeboxTweenTime)
		endif
		if soundPlaying = 1 and quickMover = 0
			//soundPlaying = 0
			PlayMusicOGG(soundIndex, 1)
		endif
		if quickMover
			SetSpriteFrame(sprSoundControl, 1)
			soundPlaying = 0
		endif
	endif
		
	if GetTweenCustomPlaying(soundTweenFI) then stVol = GetTweenCustomInteger1(soundTweenFI)
	if GetTweenCustomPlaying(soundTweenFO) then stVol = GetTweenCustomInteger1(soundTweenFO)
	if GetTweenCustomPlaying(soundTweenFI) or GetTweenCustomPlaying(soundTweenFO) then SetMusicVolumeOGG(soundIndex, volumeM*(stVol/100.0))
	if stVol = 1
		if GetMusicPlayingOGGSP(soundIndex) then PauseMusicOGG(soundIndex)
	endif
		
		
//~	print(soundList.length)	
//~	print(soundIndex)
//~	print(soundList[soundIndex])		
		
	// update the display frame when moving the new song in
	if not GetTweenSpritePlaying(twnSCLeftOut, sprSoundDisplay) and not GetTweenSpritePlaying(twnSCRightOut, sprSoundDisplay) and not GetSpriteCurrentFrame(sprSoundDisplay) = soundIndex + 1
		SetSpriteFrame(sprSoundDisplay, soundIndex + 1)
	endif
			
	
	// If we are leaving the state, exit appropriately
	// Don't write anything after this!
	if leaveRadio
		ExitSoundTest()
		nextScreen = MENU
		screen = 0
	endif
	
endfunction


// Cleanup upon leaving this state
function ExitSoundTest()

	//Deletion of the assets/setting variables correctly to leave is here
	DeleteSprite(sprSoundBase)
	DeleteAnimatedSprite(sprSoundBack)
	DeleteAnimatedSprite(sprSoundControl)
	DeleteSprite(sprSoundSelectRight)
	DeleteAnimatedSprite(sprSoundSelectLeft)
	
	DeleteSprite(sprSoundDisplay)
	DeleteTween(twnSCLeftIn)
	DeleteTween(twnSCLeftOut)
	DeleteTween(twnSCRightIn)
	DeleteTween(twnSCRightOut)
	DeleteTween(soundTweenFI)
	DeleteTween(soundTweenFO)
	
	EmptyTrashBag()

	soundtestStateInitialized = 0
endfunction


// NOTES:
// "state" is checked at the end of every Do-screen iteration
// if state is not equal to SOUNDTEST in our case, main function will start running whatever the new state's "do-screen" 
// LoadSpriteExpress(varID, imgPath, width, height, x, y, z-depth) will be instrumental to setting up images in the window
// varID is a constant tied to a number, just pick a unique multiple of 100 and then start +1'ing it for each name you need
// AddButton(varID) to connect a sprite created via LoadSpriteExpress to convenience code to make the sprite visually pop like other buttons
// in the do loop, have a series of ButtonMultiTouchEnabled(varID) checks to see if a button with the passed varID is being pressed
// if a button is being pressed, run interior code to play or stop the music/sounds that should be tied to the button
// PlayMusicOGGSP(songID, loopYN) takes a songID (IDs specified in constants.agc under "music indexes") and does all the work to get it to start playing, and will loop if loopYN is set to 1
// StopMusicOGGSP(songID) is its counterpart
// CreateTextExpress(varID, str, fontSize, fontImgID, alignment, x, y, depth) is the go-to for text creation
// for testing, set line 177 in main.agc to SOUNDTEST to make the game launch directly to the soundtest screen
// CreateSprite(varID, imgID) is the more rudimentary sprite initializiation function, pass 0 for imgID to initialize an empty sprite
// AddSpriteAnimationFrame(spriteID, imgID) adds a frame to the passed sprite's "animation array" (indexing starting at 1). this IGNORES any image passed in the sprite setup
// so I could AddSpriteAnimationFrame the imgIDs for play and pause buttons at indices 1 and 2 and then set the animation frame to 1 or 2 according to what songs are being started/stopped by the user
// if a sprite is being set up via CreateSprite and AddSpriteAnimationFrame, use SetSpriteExpress to position it, as that takes all the positional infor CreateSpriteExpress does without the initialization code
	
// CreateTweenSprite(tweenID, duration)
// SetTweenSpriteX(tweenID, startX, endX, TweenInterpolationType())
// PlayTweenSprite(tweenID
