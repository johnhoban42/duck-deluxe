#include "constants.agc"

global inputSelect = 0
global inputExit = 0
global inputSkip = 0
global inputLeft = 0
global inputRight = 0
global inputUp = 0
global inputDown = 0
global inputSpace = 0
global stateLeft = 0
global stateRight = 0
global stateUp = 0
global stateDown = 0
global stateSpace = 0

global releaseLeft = 0
global releaseRight = 0

function DoInputs()
	inputSelect = 0
	inputExit = 0
	inputSkip = 0
	inputLeft = 0
	inputRight = 0
	inputUp = 0
	inputDown = 0
	stateLeft = 0
	stateRight = 0
	stateUp = 0
	stateDown = 0
	stateSpace = 0
	releaseLeft = 0
	releaseRight = 0
	
	if GetRawKeyPressed(13) or GetRawKeyPressed(32) or GetRawKeyPressed(90) then inputSelect = 1
	if GetRawKeyPressed(13) or GetRawKeyPressed(32) or GetRawKeyPressed(90) then inputSpace = 1
	if GetRawKeyPressed(27) or GetRawKeyPressed(8) or GetRawKeyPressed(46) then inputExit = 1
	if GetRawKeyState(17) then inputSkip = 1
	if GetRawKeyPressed(37) or GetRawKeyPressed(65) then inputLeft = 1
	if GetRawKeyPressed(39) or GetRawKeyPressed(68) then inputRight = 1
	if GetRawKeyPressed(38) or GetRawKeyPressed(87) then inputUp = 1
	if GetRawKeyPressed(40) or GetRawKeyPressed(83) then inputDown = 1
	
	if GetRawKeyState(37) or GetRawKeyState(65) then stateLeft = 1
	if GetRawKeyState(39) or GetRawKeyState(68) then stateRight = 1
	if GetRawKeyState(38) or GetRawKeyState(87) then stateUp = 1
	if GetRawKeyState(40) or GetRawKeyState(83) then stateDown = 1
	if GetRawKeyState(13) or GetRawKeyState(32) or GetRawKeyState(90) then stateSpace = 1
	
	
	if GetRawKeyReleased(37) or GetRawKeyReleased(65) then releaseLeft = 1
	if GetRawKeyReleased(39) or GetRawKeyReleased(68) then releaseRight = 1
	
	if GetRawJoystickConnected(1)
		//for i = 1 to 64
			//For testing controller inputs
		//	if GetRawJoystickButtonState(1, i) then Print(i)
		//next i
		if GetRawJoystickButtonPressed(1, 1) or GetRawJoystickButtonPressed(1, 4) then inputSelect = 1
		if GetRawJoystickButtonPressed(1, 7) or GetRawJoystickButtonPressed(1, 8) then inputExit = 1
		if GetRawJoystickButtonPressed(1, 13) then inputLeft = 1
		if GetRawJoystickButtonPressed(1, 15) then inputRight = 1
		if GetRawJoystickButtonPressed(1, 14) then inputUp = 1
		if GetRawJoystickButtonPressed(1, 16) then inputDown = 1
	endif
	
endfunction

//Volume for music and sound effects
global volumeM = 100
global volumeS = 100

//Core functions that are used in the app, and possible future apps
function SyncG()
	PingUpdate()
	ButtonsUpdate()
	UpdateAllTweens(GetFrameTime())
    Sync()
endfunction

function max(num1, num2)
	ret = 0	
	if num1 > num2
		ret = num1
	else
		ret = num2
	endif
endfunction ret

function min(num1, num2)
	ret = 0	
	if num1 < num2
		ret = num1
	else
		ret = num2
	endif
endfunction ret

global imageA as Integer[0]

function LoadAnimatedSprite(spr, imgBase$, frameTotal)
	CreateSprite(spr, 0)
	
	//The image array inserts the sprite ID first, then the amount of frames, then images at the positions afterwards
	imageA.insert(spr)
	imageA.insert(frameTotal)
	for i = 1 to frameTotal
		if GetFileExists(imgBase$ + str(i) + ".png")
			imageA.insert(LoadImage(imgBase$ + str(i) + ".png"))
		else
			imageA.insert(LoadImage(imgBase$ + "0" + str(i) + ".png"))
		endif
		
		AddSpriteAnimationFrame(spr, imageA[imageA.length])
	next i
endfunction

function LoadAnimatedSpriteReversible(spr, imgBase$, frameTotal)
	CreateSprite(spr, 0)
	
	//The image array inserts the sprite ID first, then the amount of frames, then images at the positions afterwards
	imageA.insert(spr)
	imageA.insert(frameTotal*2 - 1)
	for i = 1 to frameTotal
		if GetFileExists(imgBase$ + str(i) + ".png")
			imageA.insert(LoadImage(imgBase$ + str(i) + ".png"))
		else
			imageA.insert(LoadImage(imgBase$ + "0" + str(i) + ".png"))
		endif
		
		AddSpriteAnimationFrame(spr, imageA[imageA.length])
	next i
	
	for i = frameTotal-1 to 1 step -1
		if GetFileExists(imgBase$ + str(i) + ".png")
			imageA.insert(LoadImage(imgBase$ + str(i) + ".png"))
		else
			imageA.insert(LoadImage(imgBase$ + "0" + str(i) + ".png"))
		endif
		
		AddSpriteAnimationFrame(spr, imageA[imageA.length])
	next i
endfunction

function CreateSpriteExistingAnimation(spr, refSpr)
	CreateSprite(spr, 0)
	
	//index = imageA.find(refSpr)
	index = ArrayFind(imageA, refSpr)
	
	for i = 1 to imageA[index+1]
		AddSpriteAnimationFrame(spr, imageA[index+1+i])
	next i
endfunction

function DeleteAnimatedSprite(spr)
	DeleteSprite(spr)
	//index = imageA.find(spr)
	index = ArrayFind(imageA, spr)
	
	//Checking we got a sprite ID and not an imageID
	//if Abs(imageA[index] - imageA[index+1]) < 3 then //Find the next one, IDK
	
	if index <> -1
		size = imageA[index+1] + 2
		for i = 1 to size
			if i > 1 then DeleteImage(imageA[index])
			imageA.remove(index)
		next i
	endif
	
	//Check that the number after the current number is less than 30, to not accidentally find an image ID as an index
endfunction

function GetSpriteMiddleX(spr)
	ret = GetSpriteX(spr) + GetSpriteWidth(spr)/2
endfunction ret

function GetSpriteMiddleY(spr)
	ret = GetSpriteY(spr) + GetSpriteHeight(spr)/2
endfunction ret

function SetSpriteMiddleScreen(spr)
	SetSpritePosition(spr, w/2-GetSpriteWidth(spr)/2, h/2-GetSpriteHeight(spr)/2)
endfunction

function SetSpriteMiddleScreenX(spr)
	SetSpriteX(spr, w/2-GetSpriteWidth(spr)/2)
endfunction



function SetSpriteMiddleScreenY(spr)
	SetSpriteY(spr, h/2-GetSpriteHeight(spr)/2)
endfunction

function SetSpriteMiddleScreenOffset(spr, dx, dy)
	SetSpriteMiddleScreen(spr)
	IncSpritePosition(spr, dx, dy)
endfunction

function SetTextMiddleScreen(txt, flip)
	//SetTextPosition(txt, w/2-GetTextTotalWidth(txt)/2 + flip*GetTextTotalWidth(txt), h/2-GetTextTotalHeight(txt)/2 + flip*GetTextTotalHeight(txt))
	SetTextAlignment(txt, 1)
	SetTextPosition(txt, w/2, h/2-GetTextTotalHeight(txt)/2 + flip*GetTextTotalHeight(txt)) //If the alignment is in the middle, we dont need the X offset
endfunction

function SetTextMiddleScreenX(txt, flip)
	//SetTextX(txt, w/2-GetTextTotalWidth(txt)/2 + flip*GetTextTotalWidth(txt))
	SetTextAlignment(txt, 1)
	SetTextX(txt, w/2)		//If the alignment is in the middle, we dont need the X offset
endfunction

function SetTextMiddleScreenOffset(txt, flip, dx, dy)
	SetTextMiddleScreen(txt, flip)
	SetTextPosition(txt, GetTextX(txt) + dx, GetTextY(txt) + dy)
endfunction

function SetSpriteSizeSquare(spr, size)
	SetSpriteSize(spr, size, size)
endfunction

function MatchSpriteSize(spr, sprOrigin)
	SetSpriteSize(spr, GetSpriteWidth(sprOrigin), GetSpriteHeight(sprOrigin))
endfunction

function MatchSpritePosition(spr, sprOrigin)
	SetSpritePosition(spr, GetSpriteX(sprOrigin), GetSpriteY(sprOrigin))
endfunction

function Hover(sprite) 
	if GetSpriteExists(sprite) = 0 then exitfunction 0	//Added in to make sure bad buttons aren't targeted
	returnValue = GetSpriteHitTest(sprite, GetPointerX()+GetViewOffsetX(), GetPointerY())
endfunction returnValue

function Button(sprite) 
	returnValue = GetPointerPressed() and Hover(sprite)
	if selectTarget = sprite and inputSelect then returnValue = 1
	if returnValue = 1 and screen <> UPGRADE then PlaySound(selectS, volumeS)
endfunction returnValue

function GetSpriteVisibleR(sprite)
	returnValue = 0
	if GetSpriteExists(sprite) then returnValue = GetSpriteVisible(sprite)
endfunction returnValue

function CreateSpriteExpress(spr, wid, hei, x, y, depth)
	CreateSprite(spr, 0)
	SetSpriteSize(spr, wid, hei)
	SetSpritePosition(spr, x, y)
	SetSpriteDepth(spr, depth)
endfunction

function CreateSpriteExpressImage(spr, img, wid, hei, x, y, depth)
	CreateSprite(spr, img)
	SetSpriteSize(spr, wid, hei)
	SetSpritePosition(spr, x, y)
	SetSpriteDepth(spr, depth)
endfunction

function LoadSpriteExpress(spr, file$, wid, hei, x, y, depth)
	LoadSprite(spr, file$)
	SetSpriteSize(spr, wid, hei)
	SetSpritePosition(spr, x, y)
	SetSpriteDepth(spr, depth)
endfunction

function SetSpriteExpress(spr, wid, hei, x, y, depth)
	SetSpriteSize(spr, wid, hei)
	SetSpritePosition(spr, x, y)
	SetSpriteDepth(spr, depth)
endfunction

function CreateParticlesExpress(ID, depth, maximum, size, angle, freq)
	CreateParticles(ID, 0, 0)
	SetParticlesDepth(ID, depth)
	SetParticlesMax(ID, maximum)
	SetParticlesSize(ID, size)
	SetParticlesAngle(ID, angle)
	SetParticlesFrequency(ID, freq)
endfunction

function CreateTextExpress(txt, content$, size, fontI, alignment, x, y, spacing, depth)
	CreateText(txt, content$)
	SetTextSize(txt, size)
	SetTextFontImage(txt, fontI)
	SetTextAlignment(txt, alignment)
	SetTextPosition(txt, x, y)
	SetTextSpacing(txt, spacing)
	SetTextDepth(txt, depth)
endfunction

function SetTextExpress(txt, content$, size, fontI, alignment, x, y, spacing, depth)
	SetTextString(txt, content$)
	SetTextSize(txt, size)
	SetTextFontImage(txt, fontI)
	SetTextAlignment(txt, alignment)
	SetTextPosition(txt, x, y)
	SetTextSpacing(txt, spacing)
	SetTextDepth(txt, depth)
endfunction

function IncSpriteX(spr, amt)
	SetSpriteX(spr, GetSpriteX(spr)+amt)
endfunction

function IncSpriteY(spr, amt)
	SetSpriteY(spr, GetSpriteY(spr)+amt)
endfunction

function IncSpriteXFloat(spr, amt#)
	SetSpriteX(spr, GetSpriteX(spr)+amt#)
endfunction

function IncSpriteYFloat(spr, amt#)
	SetSpriteY(spr, GetSpriteY(spr)+amt#)
endfunction

function IncSpritePosition(spr, amtX#, amtY#)
	SetSpritePosition(spr, GetSpriteX(spr)+amtX#, GetSpriteY(spr)+amtY#)
endfunction

function IncSpriteAngle(spr, amt#)
	SetSpriteAngle(spr, GetSpriteAngle(spr) + amt#)
endfunction


function IncSpriteSizeCentered(spr, amt#)
	//The regular amt is for X
	amtY# = amt# * GetSpriteHeight(spr)/GetSpriteWidth(spr)
	SetSpritePosition(spr, GetSpriteX(spr)-amt#/2, GetSpriteY(spr)-amtY#/2)
	SetSpriteSize(spr, GetSpriteWidth(spr)+amt#, GetSpriteHeight(spr)+amtY#)
endfunction

function IncSpriteSizeCenteredMult(spr, ratio#)
	amt# = ratio#
	SetSpritePosition(spr, GetSpriteMiddleX(spr)-(GetSpriteWidth(spr)*amt#)/2, GetSpriteMiddleY(spr)-(GetSpriteHeight(spr)*amt#)/2)
	SetSpriteSize(spr, GetSpriteWidth(spr)*amt#, GetSpriteHeight(spr)*amt#)
endfunction

function IncTextX(txt, amt)
	SetTextX(txt, GetTextX(txt) + amt)
endfunction

function IncTextY(txt, amt)
	SetTextY(txt, GetTextY(txt) + amt)
endfunction

function SetSpriteSizeCentered(spr, newWid, newHei)
	SetSpritePosition(spr, GetSpriteMiddleX(spr) - newWid, GetSpriteMiddleY(spr) - newHei)
	SetSpriteSize(spr, newWid, newHei)
endfunction

function GlideToSpot(spr, x, y, denom)
	SetSpritePosition(spr, (((GetSpriteX(spr)-x)*((denom-1)^fpsr#))/(denom)^fpsr#)+x, (((GetSpriteY(spr)-y)*((denom-1)^fpsr#))/(denom)^fpsr#)+y)
endfunction

function GlideToX(spr, x, denom)
	SetSpriteX(spr, (((GetSpriteX(spr)-x)*((denom-1)^fpsr#))/(denom)^fpsr#)+x)
endfunction

function GlideToY(spr, y, denom)
	SetSpriteY(spr, (((GetSpriteY(spr)-y)*((denom-1)^fpsr#))/(denom)^fpsr#)+y)
endfunction

function GlideToWidth(spr, wid, denom)
	SetSpriteSize(spr, (((GetSpriteWidth(spr)-wid)*((denom-1)^fpsr#))/(denom)^fpsr#)+wid, GetSpriteHeight(spr))
endfunction

function GlideToScissorX_L(spr, cutX, denom)
	SetSpriteScissor(spr, (((cutX)*((denom-1)^fpsr#))/(denom)^fpsr#), 0, w, h)
endfunction

function GlideToScissorX_R(spr, cutX, denom)
	SetSpriteScissor(spr, 0, 0, (((cutX)*((denom-1)^fpsr#))/(denom)^fpsr#), h)
endfunction

function GlideTextToSpot(txt, x, y, denom)
	
	SetTextPosition(txt, (((GetTextX(txt)-x)*((denom-1)^fpsr#))/(denom)^fpsr#)+x, (((GetTextY(txt)-y)*((denom-1)^fpsr#))/(denom)^fpsr#)+y)

endfunction

function GlideTextToX(txt, x, denom)
	SetTextX(txt, (((GetTextX(txt)-x)*((denom-1)^fpsr#))/(denom)^fpsr#)+x)
endfunction

function GlideViewOffset(x, y, denomX, denomY)
	
	SetViewOffset((((GetViewOffsetX()-x)*((denomX-1)^fpsr#))/(denomX)^fpsr#)+x, (((GetViewOffsetY()-y)*((denomY-1)^fpsr#))/(denomY)^fpsr#)+y)

endfunction

function GlideNumToZero(oldNum#, denom)
	newVal# =  (((oldNum#)*((denom-1)^fpsr#))/(denom)^fpsr#)
endfunction newVal#

function SnapbackToSpot(spr, iCur, iEnd, x, y, dx, dy, denom)
	
	if (iCur < iEnd*3/4)
		//Moving to the farther position
		SetSpritePosition(spr, (((GetSpriteX(spr)-(x+dx))*((denom-1)^fpsr#))/(denom)^fpsr#)+(x+dx), (((GetSpriteY(spr)-(y+dy))*((denom-1)^fpsr#))/(denom)^fpsr#)+(y+dy))
	else
		//Sliding back
		SetSpritePosition(spr, (((GetSpriteX(spr)-x)*((denom-1)^fpsr#))/(denom)^fpsr#)+x, (((GetSpriteY(spr)-y)*((denom-1)^fpsr#))/(denom)^fpsr#)+y)
	endif
	
endfunction

function SnapbackToX(spr, iCur, iEnd, x, dx, denom, ratio)
	
	if (iCur < iEnd*(ratio-1)/ratio)
		//Moving to the farther position
		SetSpriteX(spr, (((GetSpriteX(spr)-(x+dx))*((denom-1)^fpsr#))/(denom)^fpsr#)+(x+dx))
	else
		//Sliding back
		SetSpriteX(spr, (((GetSpriteX(spr)-x)*((denom-2)^fpsr#))/(denom-1)^fpsr#)+x)
	endif
	
endfunction

function SnapbackToY(spr, iCur, iEnd, y, dy, denom)
	
	if (iCur < iEnd*3/4)
		//Moving to the farther position
		SetSpriteY(spr, (((GetSpriteY(spr)-(y+dy))*((denom-1)^fpsr#))/(denom)^fpsr#)+(y+dy))
	else
		//Sliding back
		SetSpriteY(spr, (((GetSpriteY(spr)-y)*((denom-1)^fpsr#))/(denom)^fpsr#)+y)
	endif
	
endfunction

//Fades a sprite in over a given time
function FadeSpriteIn(spr, curT#, startT#, endT#)
	if curT# < endT#
		SetSpriteColorAlpha(spr, 255.0 - 255.0*(curT#-startT#)/(endT#-startT#))
	elseif curT# > endT#
		SetSpriteColorAlpha(spr, 255.0*(curT#-startT#)/(endT#-startT#))
	else
		SetSpriteColorAlpha(spr, 255)
	endif
	
endfunction

function FadeSpriteOut(spr, curT#, startT#, endT#)
	if curT# < endT#
		SetSpriteColorAlpha(spr, 255.0*(curT#-startT#)/(endT#-startT#))
	elseif curT# > endT#
		SetSpriteColorAlpha(spr, 255.0 - 255.0*(curT#-startT#)/(endT#-startT#))
	else
		SetSpriteColorAlpha(spr, 0)
	endif
	
endfunction
	//SetSpriteColorAlpha(i, (specialTimerAgainst2#/(chronoCrabTimeMax/10))*255.0)
	
function IncSpriteColorAlpha(spr, incNum)
	SetSpriteColorAlpha(spr, GetSpriteColorAlpha(spr) + incNum)
endfunction

//The touch variables
global oldTouch as Integer[20]
global newTouch as Integer[20]
global currentTouch as Integer[1]
global oldY as Integer[20]

function ProcessMultitouch()
	
	//Clearing the currentTouch array to reset it for this frame
	for i = 1 to currentTouch.length
		currentTouch.remove()
	next
	currentTouch.length = 0
	
	//Populating the newTouch array with all current touches
	newTouch[1] = GetRawFirstTouchEvent(1)
	for i = 2 to 20
		newTouch[i] = GetRawNextTouchEvent()
	next i
	
	//This is here incase we need to test multitouch logic
//~	for i = 1 to 20
//~		Print(newTouch[i])
//~	next i
//~	Print(9)
//~	for i = 1 to 20
//~		Print(oldTouch[i])
//~	next i
	
	//Checking the newTouch array for any touches that weren't in the previous frame, and acting on those touches
	for i = 1 to 20
		if newTouch[i] <> 0 and oldTouch.find(newTouch[i]) = -1
			//This is a new touch! This touch ID is added to the list of current touches.
			currentTouch.insert(newTouch[i])			
		
		//Checking if there was a touch by the other player at the same time as a release
		elseif oldTouch[i] <> 0 and oldY[i] > 1 and GetRawTouchCurrentY(oldTouch[i]) > 1 and ((GetRawTouchCurrentY(oldTouch[i]) > h/2 and oldY[i] < h/2) or (GetRawTouchCurrentY(oldTouch[i]) < h/2 and oldY[i] > h/2))
			currentTouch.insert(oldTouch[i])	
			//Print(GetRawTouchCurrentY(oldTouch[i]))
			//Print(0)
			//Print(oldY[i])
			//Sync()
			//Sleep(500)
			//If there are problems with the multitouch, they are probably here
		endif
				
	next i
	
	//Setting the oldTouch array to the contents of the current newTouch array
	for i = 1 to 20
		oldTouch[i] = newTouch[i]
	next i
	oldTouch.sort()
	
	for i = 1 to 20
		oldY[i] = GetRawTouchCurrentY(oldTouch[i])
	next i
	
endfunction

function GetMulitouchPressedButton(spr)
	result = 0
	
	for i = 1 to currentTouch.length
		x = GetRawTouchCurrentX(currentTouch[i])
		y = GetRawTouchCurrentY(currentTouch[i])		
		if GetSpriteHitTest(spr, x, y) then result = 1
	next i
	
endfunction result

//These top and bottom functions are probably used more for this project only, but they can stay
function GetMultitouchPressedTop()
	result = 0
	
	for i = 1 to currentTouch.length
		y = GetRawTouchCurrentY(currentTouch[i])		
		if y < h/2 then result = 1
	next i
	
	if deviceType = DESKTOP and GetPointerPressed() and GetPointerY() < h/2 then result = 1
	
endfunction result

function GetMultitouchPressedBottom()
	result = 0
	
	for i = 1 to currentTouch.length
		y = GetRawTouchCurrentY(currentTouch[i])		
		if y > h/2 then result = 1
	next i
	
	if deviceType = DESKTOP and GetPointerPressed() and GetPointerY() > h/2 then result = 1
	
	
endfunction result

//For the character selection
function GetMultitouchPressedTopLeft()
	result = 0
	
	for i = 1 to currentTouch.length
		x = GetRawTouchCurrentX(currentTouch[i])	
		y = GetRawTouchCurrentY(currentTouch[i])		
		if x < w/4 and y < h/2 then result = 1
	next i
	
endfunction result

//For the character selection
function GetMultitouchPressedTopRight()
	result = 0
	
	for i = 1 to currentTouch.length
		x = GetRawTouchCurrentX(currentTouch[i])	
		y = GetRawTouchCurrentY(currentTouch[i])		
		if x > w*3/4 and y < h/2 then result = 1
	next i
	
endfunction result

//For the character selection
function GetMultitouchPressedBottomLeft()
	result = 0
	
	for i = 1 to currentTouch.length
		x = GetRawTouchCurrentX(currentTouch[i])	
		y = GetRawTouchCurrentY(currentTouch[i])		
		if x < w/4 and y > h/2 then result = 1
	next i
	
endfunction result

//For the character selection
function GetMultitouchPressedBottomRight()
	result = 0
	
	for i = 1 to currentTouch.length
		x = GetRawTouchCurrentX(currentTouch[i])	
		y = GetRawTouchCurrentY(currentTouch[i])		
		if x > w*3/4 and y > h/2 then result = 1
	next i
	
endfunction result

function ButtonMultitouchEnabled(spr)
	if GetSpriteExists(spr)
	    if (Button(spr) and (GetPointerPressed() or inputSelect) and deviceType = DESKTOP) or (GetMulitouchPressedButton(spr) and deviceType = MOBILE)
	        returnValue = 1
	    else
	        returnValue = 0
	    endif
	else
		returnValue = 0
	endif
endfunction returnValue

function ClearMultiTouch()
	//Clearing the currentTouch array to reset it for this frame
	for j = 1 to 2
		for i = 1 to currentTouch.length
			currentTouch.remove()
		next
		currentTouch.length = 0
		
		SyncG()
		ProcessMultitouch()
	next j
endfunction

function PlaySoundR(sound, vol)
	if GetSoundExists(sound) or GetMusicExistsOGG(sound)
		if GetDeviceBaseName() <> "android"
			//The normal case, for normal devices
			PlaySound(sound, vol*volumeS/100.0)
		else
			//The strange case for WEIRD and PSYCHO android devices
			PlayMusicOGG(sound, 0)
			SetMusicVolumeOGG(sound, volumeS)
		endif
	endif
	
endfunction

function GetSoundPlayingR(sound)
	result = 0
	
	if GetSoundExists(sound) or GetMusicExistsOGG(sound)
		if GetDeviceBaseName() <> "android"
			//The normal case, for normal devices
			result = GetSoundInstances(sound)
		else
			//The strange case for WEIRD and PSYCHO android devices
			result = GetMusicPlayingOGGSP(sound)
		endif
	endif
	
endfunction result

function GetMusicPlayingOGGSP(songID)
	exist = 0
	exist = GetMusicExistsOGG(songID)
	if exist
		exist = GetMusicPlayingOGG(songID)
	endif
endfunction exist

function StopMusicOGGSP(songID)

	if GetMusicExistsOGG(songID)
		StopMusicOGG(songID)
		DeleteMusicOGG(songID)
	endif

endfunction

function ArrayFind(array as integer[], var)
	index = -1
	for i = 0 to array.length
		if array[i] = var then index = i
	next i
endfunction index

function LoadImageR(txt$)
	img = 0
	if GetFileExists(txt$) then img = LoadImage(txt$)
endfunction img

function LoadImageR2(index, txt$)
	if GetFileExists(txt$) then index = LoadImage(txt$)
endfunction

function SetSpriteColorRandomBright(spr)
	//Recoloring!
	r = 0
	g = 0
	b = 0
	r1 = Random(1, 3)
	r2 = Random(1, 2)
	r3 = Random(0, 255)
	if r1 = 1	//Red based
		r =  255
		if r2 = 1 then g = r3
		if r2 = 2 then b = r3
	elseif r1 = 2	//Blue based
		b =  255
		if r2 = 1 then r = r3
		if r2 = 2 then g = r3
	else	//Green based
		g =  255
		if r2 = 1 then r = r3
		if r2 = 2 then b = r3
	endif
	SetSpriteColorRed(spr, r)
	SetSpriteColorGreen(spr, g)
	SetSpriteColorBlue(spr, b)
	
endfunction

function SetSpriteColorByCycle(spr, numOf360)
	//Make sure the cycleLength is divisible by 6!
	cycleLength = 360
	colorTime = Mod(numOf360*3, 360)
	phaseLen = cycleLength/6
	
	tmpSpr = CreateSprite(0)
	
	//Each colorphase will last for one phaseLen
	if colorTime <= phaseLen	//Red -> O
		t = colorTime
		SetSpriteColor(tmpSpr, 255, (t*127.0)/phaseLen, 0, 255)
		
	elseif colorTime <= phaseLen*2	//Orange -> Y
		t = colorTime-phaseLen
		SetSpriteColor(tmpSpr, 255, 128+(t*127.0)/phaseLen, 0, 255)
		
	elseif colorTime <= phaseLen*3	//Yellow -> G
		t = colorTime-phaseLen*2
		SetSpriteColor(tmpSpr, 255-(t*255.0/phaseLen), 255, 0, 255)
		
	elseif colorTime <= phaseLen*4	//Green -> B
		t = colorTime-phaseLen*3
		SetSpriteColor(tmpSpr, 0, 255-(t*255.0/phaseLen), (t*255.0/phaseLen), 255)
		
	elseif colorTime <= phaseLen*5	//Blue -> P
		t = colorTime-phaseLen*4
		SetSpriteColor(tmpSpr, (t*139.0/phaseLen), 0, 255, 255)
		
	else 	//Purple -> R
		t = colorTime-phaseLen*5
		SetSpriteColor(tmpSpr, 139+(t*116.0/phaseLen), 0, 255-(t*255.0/phaseLen), 255)
		
	endif
	//The -255 is a remnant from SPA, to keep the color changing the same, this can be removed if desired
	r = 255-GetSpriteColorRed(tmpSpr)
	g = 255-GetSpriteColorGreen(tmpSpr)
	b = 255-GetSpriteColorBlue(tmpSpr)
	SetSpriteColor(spr, r, g, b, GetSpriteColorAlpha(spr))
	
	DeleteSprite(tmpSpr)
endfunction

function SetTextColorByCycle(txt, numOf360)
	//Make sure the cycleLength is divisible by 6!
	cycleLength = 360
	colorTime = Mod(numOf360*3, 360)
	phaseLen = cycleLength/6
	
	tmpSpr = CreateSprite(0)
	
	//Each colorphase will last for one phaseLen
	if colorTime <= phaseLen	//Red -> O
		t = colorTime
		SetSpriteColor(tmpSpr, 255, (t*127.0)/phaseLen, 0, 255)
		
	elseif colorTime <= phaseLen*2	//Orange -> Y
		t = colorTime-phaseLen
		SetSpriteColor(tmpSpr, 255, 128+(t*127.0)/phaseLen, 0, 255)
		
	elseif colorTime <= phaseLen*3	//Yellow -> G
		t = colorTime-phaseLen*2
		SetSpriteColor(tmpSpr, 255-(t*255.0/phaseLen), 255, 0, 255)
		
	elseif colorTime <= phaseLen*4	//Green -> B
		t = colorTime-phaseLen*3
		SetSpriteColor(tmpSpr, 0, 255-(t*255.0/phaseLen), (t*255.0/phaseLen), 255)
		
	elseif colorTime <= phaseLen*5	//Blue -> P
		t = colorTime-phaseLen*4
		SetSpriteColor(tmpSpr, (t*139.0/phaseLen), 0, 255, 255)
		
	else 	//Purple -> R
		t = colorTime-phaseLen*5
		SetSpriteColor(tmpSpr, 139+(t*116.0/phaseLen), 0, 255-(t*255.0/phaseLen), 255)
		
	endif
	//The -255 is a remnant from SPA, to keep the color changing the same, this can be removed if desired
	r = 255-GetSpriteColorRed(tmpSpr)
	g = 255-GetSpriteColorGreen(tmpSpr)
	b = 255-GetSpriteColorBlue(tmpSpr)
	SetTextColor(txt, r, g, b, GetTextColorAlpha(txt))
	
	DeleteSprite(tmpSpr)
endfunction

function GetColorByCycle(numOf360, rgb$)
	cycleLength = 360
	colorTime = Mod(numOf360*3, 360)
	phaseLen = cycleLength/6
	
	tmpSpr = CreateSprite(0)
	
	//Each colorphase will last for one phaseLen
	if colorTime <= phaseLen	//Red -> O
		t = colorTime
		SetSpriteColor(tmpSpr, 255, (t*127.0)/phaseLen, 0, 255)
		
	elseif colorTime <= phaseLen*2	//Orange -> Y
		t = colorTime-phaseLen
		SetSpriteColor(tmpSpr, 255, 128+(t*127.0)/phaseLen, 0, 255)
		
	elseif colorTime <= phaseLen*3	//Yellow -> G
		t = colorTime-phaseLen*2
		SetSpriteColor(tmpSpr, 255-(t*255.0/phaseLen), 255, 0, 255)
		
	elseif colorTime <= phaseLen*4	//Green -> B
		t = colorTime-phaseLen*3
		SetSpriteColor(tmpSpr, 0, 255-(t*255.0/phaseLen), (t*255.0/phaseLen), 255)
		
	elseif colorTime <= phaseLen*5	//Blue -> P
		t = colorTime-phaseLen*4
		SetSpriteColor(tmpSpr, (t*139.0/phaseLen), 0, 255, 255)
		
	else 	//Purple -> R
		t = colorTime-phaseLen*5
		SetSpriteColor(tmpSpr, 139+(t*116.0/phaseLen), 0, 255-(t*255.0/phaseLen), 255)
		
	endif
	
	result = 0
	//The -255 is a remnant from SPA, to keep the color changing the same, this can be removed if desired
	if rgb$ = "r" then result = 255-GetSpriteColorRed(tmpSpr)
	if rgb$ = "g" then result = 255-GetSpriteColorGreen(tmpSpr)
	if rgb$ = "b" then result = 255-GetSpriteColorBlue(tmpSpr)
	DeleteSprite(tmpSpr)
endfunction result

global pingList as Integer[0]
global pingNum = 701
#constant pingStart 701
#constant pingEnd 750
//Ping sprites - 501 through 550

function Ping(x, y, size)
	spr = 0
	for i = pingStart to pingEnd
		if GetSpriteExists(i) = 0
			spr = i
			i = pingEnd + 1
		endif
	next i

	if spr <> 0
		CreateSprite(spr, 0)
		SetSpriteSizeSquare(spr, size)
		SetSpritePosition(spr, x - GetSpriteWidth(spr)/2, y - GetSpriteHeight(spr)/2)
		SetSpriteDepth(spr, 50)
	endif

endfunction

function PingColor(x, y, size, red, green, blue, depth)
	spr = 0
	for i = pingStart to pingEnd
		if GetSpriteExists(i) = 0
			spr = i
			i = pingEnd + 1
		endif
	next i

	if spr <> 0
		CreateSprite(spr, 0)
		SetSpriteSizeSquare(spr, size)
		SetSpritePosition(spr, x - GetSpriteWidth(spr)/2, y - GetSpriteHeight(spr)/2)
		SetSpriteColor(spr, red, green, blue, 255)
		SetSpriteDepth(spr, depth)
	endif

endfunction

function PingUpdate()
	speed# = 6
	for i = pingStart to pingEnd
		if GetSpriteExists(i)
			IncSpriteColorAlpha(i, -speed#*fpsr#)
			if GetSpriteColorAlpha(i) <= 10 then DeleteSprite(i)
		endif
	next i

endfunction

global buttons as Integer[0]
global tweenButton = 15
global tweenButtonOld = 16
//tweenButton lasts until 35
function ButtonsUpdate()
	for i = 0 to buttons.length
		if GetSpriteExists(buttons[i])
			spr = buttons[i]
			if (GetMulitouchPressedButton(spr) or Button(spr)) and GetSpriteVisible(spr)
				
				//Skips the current tween on an existing sprite, if still playing
				skip = 0
				for i = 15 to 35
					if GetTweenSpritePlaying(i, spr) then skip = 1
				next i
				
				//The case for playing the tween
				//The sound logic makes sure that
				if skip = 0
					if GetTweenExists(tweenButton) = 0 then CreateTweenSprite(tweenButton, .3)
					//GetTween
					impact# = 1.2
					SetTweenSpriteSizeX(tweenButton, GetSpriteWidth(spr)*impact#, GetSpriteWidth(spr), TweenOvershoot())
					SetTweenSpriteSizeY(tweenButton, GetSpriteHeight(spr)*impact#, GetSpriteHeight(spr), TweenOvershoot())
					SetTweenSpriteX(tweenButton, GetSpriteMiddleX(spr)-(GetSpriteWidth(spr)*impact#)/2, GetSpriteX(spr), TweenOvershoot())
					SetTweenSpriteY(tweenButton, GetSpriteMiddleY(spr)-(GetSpriteHeight(spr)*impact#)/2, GetSpriteY(spr), TweenOvershoot())
					PlayTweenSprite(tweenButton, spr, 0)
					
					tweenButtonOld = tweenButton
					inc tweenButton, 1
					if tweenButton > 35 then tweenButton = 15
					
					//PlaySoundR(buttonSound, 100)
				else
					//if GetSoundPlayingR(buttonSound) = 0 then PlaySoundR(buttonSound, 100)
				endif
				
			endif
			
		endif
	next i
endfunction

function AddButton(spr)
	//buttons.sort()
	index = buttons.find(spr)
	if index = -1
		buttons.insertsorted(spr)
	endif
	
endfunction

function RemoveButton(spr)
buttons.sort()
	index = buttons.find(spr)
	if index <> -1
		buttons.remove(index)
	endif
	
endfunction

function SetTweenPulse(twn, spr, impact#)
	SetTweenSpriteSizeX(twn, GetSpriteWidth(spr)*impact#, GetSpriteWidth(spr), TweenOvershoot())
	SetTweenSpriteSizeY(twn, GetSpriteHeight(spr)*impact#, GetSpriteHeight(spr), TweenOvershoot())
	SetTweenSpriteX(twn, GetSpriteMiddleX(spr)-(GetSpriteWidth(spr)*impact#)/2, GetSpriteX(spr), TweenOvershoot())
	SetTweenSpriteY(twn, GetSpriteMiddleY(spr)-(GetSpriteHeight(spr)*impact#)/2, GetSpriteY(spr), TweenOvershoot())
	
endfunction




global selectTarget = 0
global selectActive = 0
#constant LEFTS 1
#constant RIGHTS 2
#constant UPS 3
#constant DOWNS 4
#constant SPR_SELECT1 10001
#constant SPR_SELECT2 10002
#constant SPR_SELECT3 10003
#constant SPR_SELECT4 10004

function CreateSelectButtons()
	//SetFolder("/media/ui")
	img = LoadImage("select.png")
	for i = 1 to 4
		spr = SPR_SELECT1-1+i
		CreateSpriteExpressImage(spr, img, 40, 40, -99, -99, 1) 
		CreateTweenSprite(spr, .16)
		SetSpriteAngle(spr, 90 * (i-1))
	next i
	
endfunction

function MoveSelect()
	
	for i = SPR_SELECT1 to SPR_SELECT4
		SetSpriteSize(i, 40, 40)
		ClearTweenSprite(i)
	next i
	
endfunction

function TurnOffSelect()
	selectTarget = 0
	UpdateAllTweens(.4)
	for i = SPR_SELECT1 to SPR_SELECT4
		SetSpriteColorAlpha(i, 0)
	next i
endfunction

function MatchSpriteColor(spr, sprOrigin)
	SetSpriteColor(spr, GetSpriteColorRed(sprOrigin), GetSpriteColorGreen(sprOrigin), GetSpriteColorBlue(sprOrigin), GetSpriteColorAlpha(sprOrigin))
endfunction

function SetWords()
	//Water 1
	words[1, 1, 1] = "Mopey"
	words[1, 2, 1] = "Middling"
	words[1, 3, 1] = "Mighty"
	words[1, 4, 1] = "MASTerful"

	words[2, 1, 1] = "Oar-ible"
	words[2, 2, 1] = "Old-fashioned"
	words[2, 3, 1] = "On-ward"
	words[2, 4, 1] = "Oar-some"

	words[3, 1, 1] = "Dinky"
	words[3, 2, 1] = "Drippy"
	words[3, 3, 1] = "Deft"
	words[3, 4, 1] = "Dynamic"

	words[4, 1, 1] = "Error"
	words[4, 2, 1] = "Exerter"
	words[4, 3, 1] = "Epoch"
	words[4, 4, 1] = "Elegance"

	//Land 1
	words[1, 1, 2] = "Miscalibrated"
	words[1, 2, 2] = "Motor"
	words[1, 3, 2] = "MegaMotor"
	words[1, 4, 2] = "Maximum"

	words[2, 1, 2] = "OverBurdened"
	words[2, 2, 2] = "OverConfident"
	words[2, 3, 2] = "OverDrive"
	words[2, 4, 2] = "OverestDrive"

	words[3, 1, 2] = "Deficient"
	words[3, 2, 2] = "Decent"
	words[3, 3, 2] = "Dramatic"
	words[3, 4, 2] = "Deadly"

	words[4, 1, 2] = "xhaust"
	words[4, 2, 2] = "ngine"
	words[4, 3, 2] = "xciter"
	words[4, 4, 2] = "lectricity"

	//Air 1
	words[1, 1, 3] = "Moronic"
	words[1, 2, 3] = "Maladjusted"
	words[1, 3, 3] = "Marvelous"
	words[1, 4, 3] = "Magnificent"

	words[2, 1, 3] = "Orwellian"
	words[2, 2, 3] = "Obtuse"
	words[2, 3, 3] = "Ozone"
	words[2, 4, 3] = "Orvillian"

	words[3, 1, 3] = "Drab"
	words[3, 2, 3] = "Dilapidated"
	words[3, 3, 3] = "Dexterous"
	words[3, 4, 3] = "Dreamy"

	words[4, 1, 3] = "Emptiness"
	words[4, 2, 3] = "Exosuit"
	words[4, 3, 3] = "Exotica"
	words[4, 4, 3] = "Eureka!"
	
	//Starting the Duck 2 words
	//Swamp/Water 2
	words[1, 1, 4] = "Dilapidated"
	words[1, 2, 4] = "Dreary"
	words[1, 3, 4] = "Droll"
	words[1, 4, 4] = "Daring"
	
	words[2, 1, 4] = "Useless"
	words[2, 2, 4] = "Uninspiring"
	words[2, 3, 4] = "Unexpected"
	words[2, 4, 4] = "Unparalleled"
	
	words[3, 1, 4] = "Crummy"
	words[3, 2, 4] = "Clunky"
	words[3, 3, 4] = "Crushing"
	words[3, 4, 4] = "Colassal"
	
	words[4, 1, 4] = "Knematode"
	words[4, 2, 4] = "Krill"
	words[4, 3, 4] = "Krab"
	words[4, 4, 4] = "Kracken"
	
	//City/Land 2
	words[1, 1, 5] = "Dreadful"
	words[1, 2, 5] = "Dorky"
	words[1, 3, 5] = "Dashing"
	words[1, 4, 5] = "Debonair"
	
	words[2, 1, 5] = "Ugly"
	words[2, 2, 5] = "Uncouth"
	words[2, 3, 5] = "Unassuming"
	words[2, 4, 5] = "Umbral"
	
	words[3, 1, 5] = "Crumpled"
	words[3, 2, 5] = "Creepy"
	words[3, 3, 5] = "Captivating"
	words[3, 4, 5] = "Cracked"
	
	words[4, 1, 5] = "Knormie"
	words[4, 2, 5] = "Kook"
	words[4, 3, 5] = "Krunk"
	words[4, 4, 5] = "Knightmare"
	
	//Mountains/Sky 2
	words[1, 1, 6] = "Derrible"
	words[1, 2, 6] = "Dim"
	words[1, 3, 6] = "D-List"
	words[1, 4, 6] = "Deserving"
	
	words[2, 1, 6] = "Uerrible"
	words[2, 2, 6] = "Ummm..."
	words[2, 3, 6] = "Unorthodox"
	words[2, 4, 6] = "Uplifting"
	
	words[3, 1, 6] = "Cerrible"
	words[3, 2, 6] = "Curious"
	words[3, 3, 6] = "Crazy"
	words[3, 4, 6] = "Cerebral"
	
	words[4, 1, 6] = "Kerrible"
	words[4, 2, 6] = "Knacker"
	words[4, 3, 6] = "Kleptomaniac"
	words[4, 4, 6] = "Knice!"
	
	//Space 2
	words[1, 1, 7] = "Doomed"
	words[1, 2, 7] = "Desperate"
	words[1, 3, 7] = "Destined"
	words[1, 4, 7] = "Defending"
	
	words[2, 1, 7] = "Usurped"
	words[2, 2, 7] = "Unraveled"
	words[2, 3, 7] = "Ultimate"
	words[2, 4, 7] = "Universal"
	
	words[3, 1, 7] = "Catasprohic"
	words[3, 2, 7] = "Collapsed"
	words[3, 3, 7] = "Colossal"
	words[3, 4, 7] = "Candescent"
	
	words[4, 1, 7] = "Knave"
	words[4, 2, 7] = "Knight"
	words[4, 3, 7] = "King"
	words[4, 4, 7] = "King of Kings"
endfunction

function SetPowers()
	//Water 1
	powers[1, 1, 1] = "x1 Base Speed"
	powers[1, 2, 1] = "x1.8 Base Speed"
	powers[1, 3, 1] = "x3.5 Base Speed"
	powers[1, 4, 1] = "x6 Base Speed"
	
	powers[2, 1, 1] = "x1 Row Boost"
	powers[2, 2, 1] = "x1.5 Row Boost"
	powers[2, 3, 1] = "x2 Row Boost"
	powers[2, 4, 1] = "x2.8 Row Boost"
	
	powers[3, 1, 1] = "x1 Row Charge"
	powers[3, 2, 1] = "x1.2 Row Charge"
	powers[3, 3, 1] = "x1.5 Row Charge"
	powers[3, 4, 1] = "x2 Row Charge"
	
	powers[4, 1, 1] = "x1 Movement"
	powers[4, 2, 1] = "x1.3 Movement"
	powers[4, 3, 1] = "x1.6 Movement"
	powers[4, 4, 1] = "x2.1 Movement"
	
	//Land 1
	powers[1, 1, 2] = "x1 Base Speed"
	powers[1, 2, 2] = "x1.5 Base Speed"	//V5 1.5
	powers[1, 3, 2] = "x2 Base Speed"	//V5 2.6
	powers[1, 4, 2] = "x2.5 Base Speed"	//V5 4
	
	powers[2, 1, 2] = "3 Boosts"
	powers[2, 2, 2] = "+1 Boost Amt."
	powers[2, 3, 2] = "+2 Boost Amt."
	powers[2, 4, 2] = "+4 Boost Amt."
	
	powers[3, 1, 2] = "Hazard Slowdown"
	powers[3, 2, 2] = "x0.75 Slowdown"
	powers[3, 3, 2] = "x0.5 Slowdown"
	powers[3, 4, 2] = "x0.1 Slowdown"
	
	powers[4, 1, 2] = "x1 Boost Speed"
	powers[4, 2, 2] = "x1.6 Boost Speed"
	powers[4, 3, 2] = "x2.8 Boost Speed"
	powers[4, 4, 2] = "x6 Boost Speed"
	
	//Air 1
	powers[1, 1, 3] = "x1 Base Speed"
	powers[1, 2, 3] = "x2 Base Speed"
	powers[1, 3, 3] = "x3 Base Speed"
	powers[1, 4, 3] = "x5 Base Speed"
	
	powers[2, 1, 3] = "Tornado Damage"
	powers[2, 2, 3] = "Tornado Boost"
	powers[2, 3, 3] = "x1.5 Boost"
	powers[2, 4, 3] = "x2.2 Boost"
	
	powers[3, 1, 3] = "x1 Side Speed"
	powers[3, 2, 3] = "x1.3 Side Speed"
	powers[3, 3, 3] = "x1.7 Side Speed"
	powers[3, 4, 3] = "x2.2 Side Speed"
	
	powers[4, 1, 3] = "x1 Verticality"
	powers[4, 2, 3] = "x1.2 Verticality"
	powers[4, 3, 3] = "x1.5 Verticality"
	powers[4, 4, 3] = "x1.9 Verticality"
	
	//Starting the Duck 2 words
	//Swamp/Water 2
	powers[1, 1, 4] = "x1 Base Speed"
	powers[1, 2, 4] = "x1.75 Base Speed"
	powers[1, 3, 4] = "x3 Base Speed"
	powers[1, 4, 4] = "x5 Base Speed"
	
	powers[2, 1, 4] = "x1 Feather Boost"
	powers[2, 2, 4] = "x2 Feather Boost"
	powers[2, 3, 4] = "x3.5 Feather Boost"
	powers[2, 4, 4] = "x5.5 Feather Boost"
	
	powers[3, 1, 4] = "Normal Dive Depth"
	powers[3, 2, 4] = "Deep Dive Depth"
	powers[3, 3, 4] = "Deeper Dive Depth"
	powers[3, 4, 4] = "Full Dive Depth"
	
	powers[4, 1, 4] = "x1 Water Movement"
	powers[4, 2, 4] = "x1.4 Water Movement"
	powers[4, 3, 4] = "x1.9 Water Movement"
	powers[4, 4, 4] = "x3 Water Movement"
	
	//City/Land 2
	powers[1, 1, 5] = ""
	powers[1, 2, 5] = ""
	powers[1, 3, 5] = ""
	powers[1, 4, 5] = ""
	
	powers[2, 1, 5] = ""
	powers[2, 2, 5] = ""
	powers[2, 3, 5] = ""
	powers[2, 4, 5] = ""
	
	powers[3, 1, 5] = ""
	powers[3, 2, 5] = ""
	powers[3, 3, 5] = ""
	powers[3, 4, 5] = ""
	
	powers[4, 1, 5] = ""
	powers[4, 2, 5] = ""
	powers[4, 3, 5] = ""
	powers[4, 4, 5] = ""
	
	//Mountains/Air 2
	powers[1, 1, 6] = ""
	powers[1, 2, 6] = ""
	powers[1, 3, 6] = ""
	powers[1, 4, 6] = ""
	
	powers[2, 1, 6] = ""
	powers[2, 2, 6] = ""
	powers[2, 3, 6] = ""
	powers[2, 4, 6] = ""
	
	powers[3, 1, 6] = ""
	powers[3, 2, 6] = ""
	powers[3, 3, 6] = ""
	powers[3, 4, 6] = ""
	
	powers[4, 1, 6] = ""
	powers[4, 2, 6] = ""
	powers[4, 3, 6] = ""
	powers[4, 4, 6] = ""
	
	//Space 2
	powers[1, 1, 7] = "x1 Start Speed"
	powers[1, 2, 7] = "x1.5 Start Speed"
	powers[1, 3, 7] = "x_ Start Speed"
	powers[1, 4, 7] = "x_ Start Speed"
	
	powers[2, 1, 7] = ""
	powers[2, 2, 7] = ""
	powers[2, 3, 7] = ""
	powers[2, 4, 7] = ""
	
	powers[3, 1, 7] = "No Mistakes"
	powers[3, 2, 7] = "Second Chance"
	powers[3, 3, 7] = "Third Chance"
	powers[3, 4, 7] = "5 "
	
	powers[4, 1, 7] = "Normal Combo"
	powers[4, 2, 7] = "Big Combo"
	powers[4, 3, 7] = "Bigger Combo"
	powers[4, 4, 7] = "B"


//Space 2
	words[1, 1, 7] = "Doomed"
	words[1, 2, 7] = "Desperate"
	words[1, 3, 7] = "Destined"
	words[1, 4, 7] = "Defending"
	
	words[2, 1, 7] = "Usurped"
	words[2, 2, 7] = "Unraveled"
	words[2, 3, 7] = "Ultimate"
	words[2, 4, 7] = "Universal"
	
	words[3, 1, 7] = "Catasprohic"
	words[3, 2, 7] = "Collapsed"
	words[3, 3, 7] = "Colossal"
	words[3, 4, 7] = "Candescent"
	
	words[4, 1, 7] = "Knave"
	words[4, 2, 7] = "Knight"
	words[4, 3, 7] = "King"
	words[4, 4, 7] = "King of Kings"

powers[1, 1, 5] = ""
powers[1, 2, 5] = "+1 Available Lane"
powers[1, 3, 5] = "+2 Available Lanes"
powers[1, 4, 5] = "+3 Available Lanes"

powers[2, 1, 5] = ""
powers[2, 2, 5] = "x1.2 Base Speed"
powers[2, 3, 5] = "x1.4 Base Speed"
powers[2, 4, 5] = "x1.6 Base Speed"

powers[3, 1, 5] = ""
powers[3, 2, 5] = "x1.5 Boost Time"
powers[3, 3, 5] = "x2 Boost Time"
powers[3, 4, 5] = "x2.5 Boost Time"

powers[4, 1, 5] = ""
powers[4, 2, 5] = "x1.2 Boost Spawn Rate"
powers[4, 3, 5] = "x1.6 Boost Spawn Rate"
powers[4, 4, 5] = "x2 Boost Spawn Rate"

endfunction
