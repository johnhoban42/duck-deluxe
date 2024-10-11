// File: upgrade.agc
// Created: 24-09-27

#include "constants.agc"

function CreateUpgradePod(row, col)
	// Create a single upgrade pod.
	
	spr = upgrage1StartSpr + 200*col + row*10
	LoadSpriteExpress(spr, "shopbox" + str(col+1) + ".png", 362, 154, 10 + col*360, 80 + row*156, 20)
	
	LoadSpriteExpress(spr + 1, "shopPlate.png", 240, 75, GetSpriteX(spr) + 72, GetSpriteY(spr) + 60, 14)
	SetSpriteColor(spr+1, 110, 110, 110, 255)
	
	LoadSpriteExpress(spr + 2, "icon" + str(col+1) + "bg.png", 40, 40, GetSpriteX(spr) + 16, GetSpriteY(spr) + 92, 14)
	
	for k = 0 to 2
		if k = 0 then CreateTextExpress(spr + k, "", 96, fontMI, 1, GetSpriteX(spr) + 30, GetSpriteY(spr) + 2, 0, 15)
		if k = 1 then CreateTextExpress(spr + k, "", 48, font1I + upgrades[row+1, col+1], 0, GetSpriteX(spr) + 30 + 30, GetSpriteY(spr) + 2 + 5, -7, 15)
		if k = 2 then CreateTextExpress(spr + k, "", 24, fontMI, 1, GetSpriteMiddleX(spr+1), GetSpriteY(spr) + 73, -4, 10)
	next k
	
	areaChr$ = AREA_CHARS[col]
	upgradeChr$ = UPGRADE_CHARS[row]
	
	LoadSpriteExpress(spr + 3, Lower(areaChr$) + upgradeChr$ + ".png", 75, 75, GetSpriteX(spr)-5, GetSpriteY(spr)-10, 20)
	
	if upgrades[row+1, col+1] <> 3
		SetTextString(spr + 1, words[row+1, upgrades[row+1,col+1]+1, col+1])
		SetTextString(spr + 2, upgradeChr$ + words[row+1, upgrades[row+1,col+1]+2, col+1] + "- " + Str(GetCost(row,col)) + "~" + chr(10) + powers[row+1, upgrades[row+1,col+1]+2, col+1])
	else
		SetTextString(spr + 1, words[row+1, 4, col+1])
		SetTextString(spr + 2, "")
		SetSpriteVisible(spr+1, 0)
		IncTextY(spr+1, 40)
		IncSpriteY(spr+3, 40)
		IncSpritePosition(spr+2, 290, -38) //Icons
	endif
	SetTextFontImage(spr + 1, font1I + upgrades[row+1, col+1])

	if GetCost(row,col) > scrapTotal then SetTextColor(spr + 2, 160, 160, 160, 255)

	LoadSpriteExpress(spr + 4, areaChr$ + upgradeChr$ + str(1+upgrades[row+1,col+1]) + ".png", GetSpriteWidth(spr+2), GetSpriteHeight(spr+2), GetSPriteX(spr+2), GetSpriteY(spr+2), GetSpriteDepth(spr+2)-1)
	
endfunction


function CreateUpgrade()
	
	CreateSpriteExpress(instruct, 320, 320, w/2+180 + (areaSeen-1)*56, h/2 - 30, 60)
	img1 = LoadImage("upgradeR1.png")
	AddSpriteAnimationFrame(instruct, img1)
	img2 = LoadImage("upgradeR2.png")
	AddSpriteAnimationFrame(instruct, img2)
	trashBag.insert(img1)
	trashBag.insert(img2)
	PlaySprite(instruct, 2, 1, 1, 2)
	LoadSpriteExpress(vehicle4, "upgradeV" + str(areaSeen) + ".png", GetSpriteWidth(instruct), GetSpriteWidth(instruct), GetSpriteX(instruct), GetSpriteY(instruct), 70)
	
	for col = 0 to areaSeen - 1
		LoadSpriteExpress(vehicle1 + col, "mode" + str(1+col) + ".png", 395*0.6, 80*0.6, 70 + col*(360), 25, 30)
	next col
	
	LoadSpriteExpress(upgradeBG, "upgradebg" + str(areaSeen) + ".png", w, h, 0, 0, 99)	
	LoadSpriteExpress(startRace, "nextRace.png", 420/2.8, 165/2.8, 1100-300*(3-areaSeen), 350, 5)
	
	//TODO - Slide everything in, fade in a slightly dark layer
	for col = 0 to areaSeen - 1
		for row = 0 to 3
			CreateUpgradePod(row, col)
		next row
	next col
	
	PlayMusicOGG(upgradeM, 1)
	
	PlayTweenSprite(tweenSprFadeOut, coverS, 0)
	
endfunction


function DoUpgradePod(row, col)
	// Handle events for a single upgrade pod.
	
	spr = upgrage1StartSpr + 200*col + row*10
	
	cost = GetCost(row, col)
	if Button(spr) and scrapTotal >= cost and upgrades[row+1, col+1] <= 2
		inc upgrades[row+1, col+1], 1
		inc scrapTotal, -cost
		PlaySound(buyS, volumeS)
		PlaySound(selectS, volumeS)
		UpdateScrapText()
		
		if upgrades[row+1, col+1] <> 3
			SetTextString(spr + 1, words[row+1, upgrades[row+1,col+1]+1, col+1])
			SetTextString(spr + 2, UPGRADE_CHARS[row] + words[row+1, upgrades[row+1,col+1]+2, col+1] + "- " + Str(cost) + "~" + chr(10) + powers[row+1, upgrades[row+1,col+1]+2, col+1])
		else
			SetTextString(spr + 1, words[row+1, 4, col+1])
			SetTextString(spr + 2, "")
			SetSpriteVisible(spr+1, 0)
			IncTextY(spr+1, 40)
			IncSpriteY(spr+3, 40)
			IncSpritePosition(spr+2, 290, -38) //Icons
			IncSpritePosition(spr+4, 290, -38) //Icons
		endif
		SetTextFontImage(spr + 1, font1I + upgrades[row+1, col+1])
		SetSpriteImage(spr + 4, LoadImage(AREA_CHARS[col] + UPGRADE_CHARS[row] + str(1+upgrades[row+1,col+1]) + ".png"))
		trashBag.insert(GetSpriteImageID(spr+4))
		
	endif

	if cost > scrapTotal then SetTextColor(spr + 2, 160, 160, 160, 255)
	
endfunction


function DoUpgrade()
	
	for col = 0 to areaSeen - 1
		for row = 0 to 3
			DoUpgradePod(row, col)
		next row
	next col
	
	
	if Button(startRace)
		
		duckSpeed# = duckSpeedDefault#
		StopMusicOGG(upgradeM)
		PlaySound(selectS, volumeS)
		PlayTweenSprite(tweenSprFadeIn, coverS, 0)
		PlaySound(windMS, volumeS)
		WaitFadeTween()
		
		DeleteScene(UPGRADE)
		screen = 0
		//The next three lines are identical to the title screen - should it be combined into a little function? IDK
		SetRaceQueue(curRaceSet)
		
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
