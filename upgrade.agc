// File: upgrade.agc
// Created: 24-09-27

// Hi Andy
// Hi John! - From Andy, 3/2/25

#include "constants.agc"

function InitializeFromRaceQueue()
	// Fetch upgrade properties for the areas defined by the race queue.
	SetRaceQueue(curRaceSet)

endfunction

//Upgrade pod
type p
	//The info on the upgraded
	rID as integer //Race ID
	lev as integer //The current level of upgrade
	
	//Physical position
	column as integer
	row as integer
	
	//The main background element
	sprBG as integer
	sprLetter as integer
	sprIconTop as integer
	sprIconBG as integer
	txtCurWord as integer
	txtMainDesc as integer
	
	//The upgrade box
	sprUpBG as integer
	txtUpgrade as integer
	sprBuy as integer
	
	//Chains which move down to the next part
	sprChainL as integer
	sprChainR as integer
	
	twnSideSway as integer
	twnMainDown as integer
	twnMainUp as integer
	twnUpgradeDown as integer
	twnUpgradeUp as integer
	
	sprCover as integer
	twnBuyWhite as integer
	twnBuyClear as integer
	twnBuyTuck as integer
	
	isDown as integer
	isSelected as integer
	
endtype



function CreatePod(row, col)
	pod as p
	rID = raceQueueRef[col]
	pod.rID = rID
	pod.row = row
	pod.column = col
	pod.lev = upgrades[row, rID]
	
	pod.sprBG = CreateSprite(LoadImage("upgrade/shopboxNew" + str(rID) + ".png"))
	spr = pod.sprBG
	//SetSpriteExpress(spr, 362, 100, 10 + col*364, 80 + row*142, 50) //Pre-making them longer
	SetSpriteExpress(spr, 372, 100, 10 + col*374, 80 + row*142, 50) 
	//SetSpriteColor(spr, 80, 80, 80, 255)
	//SetSpriteColorAlpha(spr, 100)
	
	//THE POSITIONS OF ALL THE BELOW ARE UPDATED EVERY FRAME IN THE 'ALIGNPOD' METHOD!!!
	
	pod.sprLetter = LoadSprite("raceLetters/let" + str(row+1) + "r" + str(rID) + ".png")
	SetSpriteExpress(pod.sprLetter, 75, 75, GetSpriteX(spr)-5, GetSpriteY(spr)-10, 3)
	
	pod.sprIconBG = LoadSprite("upgrade/icon" + str(rID) + "bg.png")
	SetSpriteExpress(pod.sprIconBG, 60, 60, GetSpriteX(spr) + 285, GetSpriteY(spr) + 14, 14)
	
	//if GetImageExists
	pod.sprIconTop = LoadSprite("WD1.png")
	SetSpriteExpress(pod.sprIconTop, 60, 60, GetSpriteX(spr) + 285, GetSpriteY(spr) + 14, 13)
	
	//inc upgrades[row+1, col+1], 3
	pod.txtCurWord = CreateText("")
	SetTextExpress(pod.txtCurWord, Mid(words[row+1, upgrades[row+1,rID]+1, rID], 2, -1), 48, font1I + upgrades[row+1, rID], 0, GetSpriteX(spr) + 60, GetSpriteY(spr) + 7, -7, 15)
	
	pod.txtMainDesc = CreateText("")
	SetTextExpress(pod.txtMainDesc, powers[row+1, upgrades[row+1,rID]+1, rID], 24, fontMI, 0, GetSpriteX(spr) + 70, GetSpriteY(spr) + 73, -5, 15)
	
	//Starting the upgrade pod
	pod.sprUpBG = LoadSprite("upgrade/upgradeBG.png")
	SetSpriteExpress(pod.sprUpBG, GetSpriteWidth(spr)-38, 110, 0, GetSpriteY(spr)+GetSpriteHeight(spr)-80, 100)
	SetSpriteX(pod.sprUpBG, GetSpriteMiddleX(spr) - GetSpriteWidth(pod.sprUpBG)/2)
	//SetSpriteColor(pod.sprUpBG, 10, 80, 10, 255)
	//SetSpriteColor(pod.sprUpBG, 150, 150, 150, 255)
	
	pod.txtUpgrade = CreateText("")
	SetTextExpress(pod.txtUpgrade, "", 24, fontMI, 0, GetSpriteX(pod.sprUpBG) + 10, GetSpriteY(pod.sprUpBG) + 13, -4, 90)
	SetPodUpgradeText2(pod)
	SetTextLineSpacing(pod.txtUpgrade, 3)
	SetTextColor(pod.txtUpgrade, 0, 255, 0, 255)
	
	pod.sprBuy = LoadSprite("upgrade/buy.png")
	SetSpriteExpress(pod.sprBuy, 98*.7, 42*.7, GetSpriteX(spr)+275, GetSpriteY(pod.sprUpBG)+GetSpriteHeight(pod.sprUpBG)-67, 80)
	SetPodBuyColor(pod)
	
	pod.sprChainL = CreateSprite(0)
	SetSpriteExpress(pod.sprChainL, 10, GetSpriteHeight(spr), GetSpriteX(spr)+5, GetSpriteMiddleY(spr), 150)
	
	pod.sprChainR = CreateSprite(0)
	SetSpriteExpress(pod.sprChainR, 10, GetSpriteHeight(spr), GetSpriteX(spr)+GetSpriteWidth(spr)-15, GetSpriteMiddleY(spr), 150)
	
	pod.twnSideSway = CreateTweenSprite(.8)
	SetTweenSpriteX(pod.twnSideSway, GetSpriteX(spr)-8, GetSpriteX(spr), TweenOvershoot())
	
	pod.twnMainDown = CreateTweenSprite(.3)
	SetTweenSpriteY(pod.twnMainDown, GetSpriteY(spr), GetSpriteY(spr)+70, TweenSmooth2())
	pod.twnMainUp = CreateTweenSprite(.3)
	SetTweenSpriteY(pod.twnMainUp, GetSpriteY(spr)+70, GetSpriteY(spr), TweenSmooth2())
	
	pod.twnUpgradeDown = CreateTweenCustom(.3)
	SetTweenCustomFloat1(pod.twnUpgradeDown, 0, 60, TweenOvershoot())
	pod.twnUpgradeUp = CreateTweenCustom(.3)
	SetTweenCustomFloat1(pod.twnUpgradeUp, 60, 0, TweenOvershoot())
	
	pod.sprCover = LoadSprite("upgrade/shopboxCover.png")
	MatchSpriteSize(pod.sprCover, spr)
	MatchSpritePosition(pod.sprCover, spr)
	SetSpriteDepth(pod.sprCover, 4)
	SetSpriteColorAlpha(pod.sprCover, 0)
	
	pod.twnBuyWhite = CreateTweenSprite(.45)
	SetTweenSpriteAlpha(pod.twnBuyWhite, 0, 255, TweenSmooth2())
	pod.twnBuyClear = CreateTweenSprite(.25)
	SetTweenSpriteAlpha(pod.twnBuyWhite, 255, 0, TweenSmooth2())
	
	pod.twnBuyTuck = CreateTweenCustom(.2)
	SetTweenCustomFloat1(pod.twnBuyTuck, 0, -200, TweenSmooth2())
	
endfunction pod
function SetPodTextIcon2(pod as p)
	
	SetTextString(pod.txtCurWord, Mid(words[pod.row+1, upgrades[pod.row+1,pod.rID]+1, pod.rID], 2, -1))
	SetTextFontImage(pod.txtCurWord, font1I + upgrades[pod.row+1, pod.rID])
	SetTextString(pod.txtMainDesc, powers[pod.row+1, upgrades[pod.row+1,pod.rID]+1, pod.rID])
	
	//TODO - update the upgrade icon
endfunction
function SetPodUpgradeText2(pod as p)
	if upgrades[pod.row+1, pod.rID] < 3
		SetTextString(pod.txtUpgrade, chr(10) + "Next -> " + Upper(words[pod.row+1, upgrades[pod.row+1,pod.rID]+2, pod.rID]) + chr(10) + powers[pod.row+1, upgrades[pod.row+1,pod.rID]+2, pod.rID] + chr(10) + "Upgrade: " + Str(GetCost2(pod.row, pod.column, pod.rID)) + " ~")
	else
		SetTextString(pod.txtUpgrade, chr(10) + chr(10) + chr(10) + "FULLY UPGRADED")
	endif
endfunction
function SetPodBuyColor(pod as p)
	if scrapTotal >= GetCost2(pod.row, pod.column, pod.rID)
		SetSpriteColor(pod.sprBuy, 255, 255, 255, 255)
	else
		SetSpriteColor(pod.sprBuy, 50, 50, 50, 255)
	endif
endfunction
function CreateUpgrade2()
	
	//areaSeen = 4
	if curRaceSet = 2
		if areaSeen = 1
			LoadMusicOGG(upgrade2M, "music/upgrade2-1.ogg")
			SetMusicLoopTimesOGG(upgrade2M, 3.692, -1)
		endif
		if areaSeen = 2 then LoadMusicOGG(upgrade2M, "music/upgrade2-2.ogg")
		if areaSeen = 3 then LoadMusicOGG(upgrade2M, "music/upgrade2-3.ogg")
		if areaSeen >= 4 then LoadMusicOGG(upgrade2M, "music/upgrade2-4.ogg")
	endif
	if GetMusicExistsOGG(upgrade2M) = 0 then LoadMusicOGG(upgrade2M, "music/upgrade.ogg")
	
	PlayMusicOGG(upgrade2M, 1)
	PlayMusicOGG(ambUpgrade2, 1)
	SetMusicVolumeOGG(ambUpgrade2, ambVol*.2)
	//General upgrade music, for duck 3/DX/challenge mode
	
	
	LoadSpriteExpress(upgradeBG, "upgrade2-1.png", w, h, 0, 0, 900)
	FixSpriteToScreen(upgradeBG, 1)
	selectedPod = -1
	
	SetRaceQueue(curRaceSet)
	
	if debug
		raceQueueRef.length = -1
		raceQueueRef.insert(WATER2)
		raceQueueRef.insert(LAND2)
		raceQueueRef.insert(AIR2)
		raceQueueRef.insert(SPACE2)
		raceQueueRef.insert(WATER)
		raceQueueRef.insert(LAND)
		raceQueueRef.insert(AIR)
		areaSeen = raceQueueRef.length +1
	endif
	
	upPods.length = -1
	upPods.length = areaSeen*4
	
	curPod as p
	
	for i = 0 to areaSeen*4-1
		curPod = CreatePod(Mod(i, 4), i/4)
		upPods[i] = curPod
	next i
	
	for col = 0 to areaSeen - 1
		upCols[col] = LoadSprite("upgrade/mode" + str(raceQueueRef[col]) + ".png")
		SetSpriteSize(upCols[col], 395*0.6, 80*0.6)
		SetSpritePosition(upCols[col], GetSpriteMiddleX(upPods[0+4*col].sprUpBG)-GetSpriteWidth(upCols[col])/2, 25)
		SetSpriteDepth(upCols[col], 30)
	next col
	
	IncTextY(scrapText, -16)
	scrapBG = LoadSprite("upgrade/scrapBG.png")
	SetSpriteExpress(scrapBG, GetTextTotalWidth(scrapText)*1.2, GetTextTotalHeight(scrapText)*1.2, GetTextX(scrapText) - GetTextTotalWidth(scrapText)*.1, GetTextY(scrapText) - GetTextTotalHeight(scrapText)*.1, GetTextDepth(scrapText)+1)
	SetSpriteColorAlpha(scrapBG, 170)
	FixSpriteToScreen(scrapBG, 1)
	
	LoadSpriteExpress(startRace, "nextRace.png", 420/2.5, 165/2.5, GetSpriteX(upPods[areaSeen*4-1].sprBG)+500, 350, 5)
	
	PlayTweenSprite(tweenSprFadeOut, coverS, 0)
	
endfunction
function DoUpgrade2()
	
	triggerMove = 0
	if inputLeft then triggerMove = -4
	if inputRight then triggerMove = 4
	if inputUp then triggerMove = -1
	if inputUp and Mod(selectedPod, 4) = 0 then triggerMove = 3
	if inputDown then triggerMove = 1
	if inputDown and Mod(selectedPod, 4) = 3 then triggerMove = -3
	if selectedPod = -1 and (inputLeft or inputRight or inputUp or inputDown)
		//This is for the first selected pod when pressing left/right. It should default to the cheapest/lowest availible upgrade
		for i = 0 to upPods.length-1
			if upgrades[upPods[i].row+1, upPods[i].rID] < 3
				triggerMove = i+1
				i = upPods.length
			endif
		next i
		if triggerMove = 0 then selectedPod = startRace
	endif
	
	
	
	//This craziness is for moving on and moving off of the start race button
	if (inputLeft and selectedPod/4 = 0) or (inputRight and selectedPod/4 = areaSeen-1 and selectedPod > -1)
		if selectedPod <> -1
			upPods[selectedPod].isSelected = 0
			PlayTweenCustom(upPods[selectedPod].twnUpgradeUp, 0)
			//Normalizing the pods that aren't the selected one, this happens to all of them at the start
			for j = 0 to upPods.length-1
				if (upPods[j].isDown = 1)
					PlayTweenSprite(upPods[j].twnMainUp, upPods[j].sprBG, 0)
					upPods[j].isDown = 0
				endif	
			next j
		endif
		selectedPod = startRace
		triggerMove = 0
	elseif (inputRight and selectedPod = startRace)
		//if selectedPod <> -1 then PlayTweenCustom(upPods[selectedPod].twnUpgradeUp, 0)
		selectedPod = -98
		triggerMove = 99
	elseif (inputLeft and selectedPod = startRace)
		//if selectedPod <> -1 then PlayTweenCustom(upPods[selectedPod].twnUpgradeUp, 0)
		selectedPod = upPods.length-3 - 99
		triggerMove = 99
	endif
	
	curP as p
	for i = 0 to upPods.length-1
		curP = upPods[i]
		
		if ((Button(curP.sprBG) or Button(curP.sprUpBG)) and i <> selectedPod) or (triggerMove <> 0 and i = selectedPod+triggerMove)
			oldSel = selectedPod
			selectedPod = i
			upPods[i].isSelected = 1
			if oldSel > -1 then upPods[oldSel].isSelected = 0
			//if oldSel <> startRace then upPods[oldSel].isSelected = 0
			
			PlaySound(chainShakeS, volumeS*0.04)
			PlaySound(boxSlideS, volumeS*0.08)
			
			UpdateAllTweens(1)
			
			//Updating the buy button on that panel
			SetPodBuyColor(curP)
			
			//Moving the upgrade panel down on the selected upgrade
			PlayTweenCustom(upPods[i].twnUpgradeDown, 0)
			if oldSel > -1 and oldSel <> startRace then PlayTweenCustom(upPods[oldSel].twnUpgradeUp, 0)
			
			
			PlaySound(screenSlideS, volumeS*0.1)
			
			for j = 0 to upPods.length-1
				//Normalizing the pods that aren't the selected one, this happens to all of them at the start
				if (upPods[j].isDown = 1 and j <= i) or (upPods[j].column <> upPods[i].column and upPods[j].isDown = 1)
					PlayTweenSprite(upPods[j].twnMainUp, upPods[j].sprBG, 0)
					upPods[j].isDown = 0
				endif
				
				//Moving pods down that are in the same row
				if upPods[j].column = upPods[i].column and j > i and upPods[j].isDown = 0
					if GetTweenSpritePlaying(upPods[j].twnMainUp,upPods[j].sprBG) then StopTweenSprite(upPods[j].twnMainUp,upPods[j].sprBG)
					PlayTweenSprite(upPods[j].twnMainDown, upPods[j].sprBG, 0)
					PlayTweenSprite(upPods[j].twnSideSway, upPods[j].sprBG, (j-i)*.03)
				
					upPods[j].isDown = 1
				endif
				if upPods[j].column = upPods[i].column
					//Still sways things, even when they are already down
					PlayTweenSprite(upPods[j].twnSideSway, upPods[j].sprBG, Abs((j-i))*.02)
				endif
			next j
			i = upPods.length
		endif
		
		
		//Buying an upgrade
		if ((((Button(curP.sprBG) or Button(curP.sprUpBG) or inputSelect) and i = selectedPod)) and upgrades[curP.row+1, curP.rID] < 3) and scrapTotal >= GetCost2(curP.row, curP.column, curP.rID)
			PlayTweenSprite(curP.twnBuyWhite, curP.sprCover, 0)
			PlayTweenSprite(curP.twnBuyClear, curP.sprCover, .45)
			PlayTweenCustom(curP.twnBuyTuck, 0)
			PlayTweenCustom(curP.twnUpgradeDown, GetTweenCustomEndTime(curP.twnBuyTuck))
			
			PlaySound(screenSlideS, volumeS*0.15)
			PlaySound(buyS, volumeS)
			
			dec scrapTotal, GetCost2(curP.row, curP.column, curP.rID)
			UpdateScrapText()
			
			inc upgrades[curP.row+1, curP.rID], 1
			
			if upgrades[curP.row+1, curP.rID] = 2 and curP.rID = WATER2 and curP.row+1 = 4 then PlaySound(crabS, volumeS*0.4)
			
			inc curP.lev, 1
			
			SetPodTextIcon2(curP)
			UpdateAllTweens(.0001)
		endif
		
		if ((((Button(curP.sprBG) or Button(curP.sprUpBG) or inputSelect) and i = selectedPod)) and upgrades[curP.row+1, curP.rID] < 3) and scrapTotal < GetCost2(curP.row, curP.column, curP.rID)
			PlaySound(haltS, volumeS*0.5)
		endif
		
		//Update main panel text
		if GetSpriteColorAlpha(curP.sprCover) > 230
			SetPodTextIcon2(curP)
		endif
		//Update upgrade text
		if GetTweenCustomFloat1(curP.twnBuyTuck) < -100
			SetPodUpgradeText2(curP)
			SetPodBuyColor(curP)
		endif
		
		SetTextColor(curP.txtUpgrade, 0, 255, 0, 255)
		//Making the upgrade cost glow if it's affordable
		if scrapTotal >= GetCost2(curP.row, curP.column, curP.rID) and upgrades[curP.row+1, curP.rID] < 3
			str$ = GetTextString(curP.txtUpgrade)
			for j = FindString(str$, "Upgrade:")-1 to Len(str$)-1
				SetTextCharColor(curP.txtUpgrade, j, 127 + 127*sin(gameTime#*.6), 255, 127 + 127*sin(gameTime#*.6), 255)
			next j 
		endif
		
	next i
	UpdateAllTweens(.0001)
	
	//TODO: If you click on the Krab upgrade, make it play Space Crab turn sound
	
	//Making sure all pieces of the pod (and the screen view) are set correctly
	for i = 0 to upPods.length-1
		AlignPod(upPods[i])
	next i
	if selectedPod <> startRace 
		GlideViewOffset(((78+32*areaSeen)*(selectedPod/4)), 0, 40, 2)
	else
		GlideViewOffset(((78+32*areaSeen)*((upPods.length-1)/4)), 0, 40, 2)
	endif
	
	//Adjusting the start race button, pulses if it's highlighted
	SetSpriteSize(startRace, 420/2.5, 165/2.5)
	SetSpritePosition(startRace, GetSpriteX(upPods[areaSeen*4-1].sprBG)+500, 350)
	if selectedPod = startRace
		SetSpriteSize(startRace, GetSpriteWidth(startRace) + sin(gameTime#)*14, GetSpriteHeight(startRace) + sin(gameTime#)*14)
		SetSpritePosition(startRace, GetSpriteX(startRace) - sin(gameTime#)*7, GetSpriteY(startRace) - sin(gameTime#)*7)
		if inputSelect then StartRace2()
	endif
	if Button(startRace) then StartRace2()
	
	Print(GetSpriteHit(GetPointerX(), GetPointerY()))
endfunction
function AlignPod(curP as p)
	spr = curP.sprBG
	
	decUpgradeY = 0
	if upgrades[curP.row+1, curP.rID] = 3 then decUpgradeY = 55
	
	SetSpritePosition(curP.sprCover, GetSpriteX(spr), GetSpriteY(spr))
	SetSpritePosition(curP.sprLetter, GetSpriteX(spr)-5, GetSpriteY(spr)-10)
	SetSpritePosition(curP.sprIconBG, GetSpriteX(spr) + 305, GetSpriteY(spr) + 14)
	SetSpritePosition(curP.sprIconTop, GetSpriteX(spr) + 305, GetSpriteY(spr) + 14)
	
	SetTextPosition(curP.txtCurWord, GetSpriteX(spr) + 60, GetSpriteY(spr) + 7)
	SetTextPosition(curP.txtMainDesc, GetSpriteX(spr) + 82, GetSpriteY(spr) + 63)
	
	SetSpriteScissor(curP.sprUpBG, 0, GetSpriteY(spr)+GetSpriteHeight(spr)-20, w, h)
	SetTextScissor(curP.txtUpgrade, 0, GetSpriteY(spr)+GetSpriteHeight(spr)-20, w, h)
	SetSpriteScissor(curP.sprBuy, 0, GetSpriteY(spr)+GetSpriteHeight(spr)+40, w, h)
	
	SetSpritePosition(curP.sprUpBG, GetSpriteMiddleX(spr) - GetSpriteWidth(curP.sprUpBG)/2, GetSpriteY(spr)+GetSpriteHeight(spr)-80 + GetTweenCustomFloat1(curP.twnUpgradeUp) - decUpgradeY) //+GetTweenCustomFloat1(curP.twnUpgradeDown))
	if curP.isSelected
		//Changing the positioning of the upgrade panel differently
		SetSpritePosition(curP.sprUpBG, GetSpriteMiddleX(spr) - GetSpriteWidth(curP.sprUpBG)/2, GetSpriteY(spr)+GetSpriteHeight(spr)-80 + GetTweenCustomFloat1(curP.twnUpgradeDown) - decUpgradeY)
		
	endif
	if GetTweenCustomPlaying(curP.twnBuyTuck) then SetSpritePosition(curP.sprUpBG, GetSpriteMiddleX(spr) - GetSpriteWidth(curP.sprUpBG)/2, GetSpriteY(spr)+GetSpriteHeight(spr)-80 + GetTweenCustomFloat1(curP.twnUpgradeDown) + GetTweenCustomFloat1(curP.twnBuyTuck))
	
	SetTextPosition(curP.txtUpgrade, GetSpriteX(curP.sprUpBG) + 15, GetSpriteY(curP.sprUpBG) - 4)
	SetSpritePosition(curP.sprBuy, GetSpriteX(spr)+266, GetSpriteY(curP.sprUpBG)+GetSpriteHeight(curP.sprUpBG)-GetSpriteHeight(curP.sprBuy)-9)
	
	
endfunction
function StartRace2()
	duckSpeed# = duckSpeedDefault#
	StopMusicOGG(upgrade2M)
	PlaySound(selectS, volumeS)
	PlayTweenSprite(tweenSprFadeIn, coverS, 0)
	PlaySound(windMS, volumeS)
	WaitFadeTween()
	
	DeleteUpgrade2()
	screen = 0
	
	SetRaceQueue(curRaceSet)
endfunction
function DeleteUpgrade2()
	
	for i = 0 to upPods.length
		DeleteSprite(upPods[i].sprBG)
		DeleteSprite(upPods[i].sprLetter)
		DeleteSprite(upPods[i].sprIconTop)
		DeleteSprite(upPods[i].sprIconBG)
		DeleteText(upPods[i].txtCurWord)
		DeleteText(upPods[i].txtMainDesc)
		
		DeleteSprite(upPods[i].sprUpBG)
		DeleteSprite(upPods[i].sprBuy)
		DeleteText(upPods[i].txtUpgrade)
		DeleteSprite(upPods[i].sprChainL)
		DeleteSprite(upPods[i].sprChainR)
		DeleteSprite(upPods[i].sprCover)
		
		DeleteTween(upPods[i].twnSideSway)
		DeleteTween(upPods[i].twnMainDown)
		DeleteTween(upPods[i].twnMainUp)
		DeleteTween(upPods[i].twnUpgradeDown)
		DeleteTween(upPods[i].twnUpgradeUp)
		DeleteTween(upPods[i].twnBuyWhite)
		DeleteTween(upPods[i].twnBuyClear)
		DeleteTween(upPods[i].twnBuyTuck)
	next i
	
	for i = 0 to raceQueueRef.length-1
		DeleteSprite(upCols[i])
	next i
	
	upPods.length = -1
	
	DeleteSprite(startRace)
	DeleteSprite(upgradeBG)
	DeleteSprite(scrapBG)
	if GetTextExists(scrapText) then DeleteText(scrapText)		
	
	StopAmbientMusic()
	EmptyTrashBag()
endfunction

function CreateUpgradePod(row, col)
	// Create a single upgrade pod.
	
	spr = upgrage1StartSpr + 200*col + row*10
	LoadSpriteExpress(spr, "upgrade/shopbox" + str(raceQueueRef[col]) + ".png", 362, 154, 10 + col*360, 80 + row*156, 20)
	
	LoadSpriteExpress(spr + 1, "shopPlate.png", 240, 75, GetSpriteX(spr) + 72, GetSpriteY(spr) + 60, 14)
	SetSpriteColor(spr+1, 110, 110, 110, 255)	
	
	LoadSpriteExpress(spr + 2, "upgrade/icon" + str(raceQueueRef[col]) + "bg.png", 40, 40, GetSpriteX(spr) + 16, GetSpriteY(spr) + 92, 14)
	
	for k = 0 to 2
		if k = 0 then CreateTextExpress(spr + k, "", 96, fontMI, 1, GetSpriteX(spr) + 30, GetSpriteY(spr) + 2, 0, 15)
		if k = 1 then CreateTextExpress(spr + k, "", 48, font1I + upgrades[row+1, col+1], 0, GetSpriteX(spr) + 30 + 30, GetSpriteY(spr) + 2 + 5, -7, 15)
		if k = 2 then CreateTextExpress(spr + k, "", 24, fontMI, 1, GetSpriteMiddleX(spr+1), GetSpriteY(spr) + 73, -4, 10)
	next k
	
	areaChr$ = AREA_CHARS[raceQueueRef[col] - 1]
	upgradeChr$ = UPGRADE_CHARS[row]
	
	// upgrade letter sprite
	LoadSpriteExpress(spr + 3, Lower(areaChr$) + upgradeChr$ + ".png", 75, 75, GetSpriteX(spr)-5, GetSpriteY(spr)-10, 20)
	
	if upgrades[row+1, col+1] <> 3
		SetTextString(spr + 1, words[row+1, upgrades[row+1,col+1]+1, raceQueueRef[col]])
		SetTextString(spr + 2, upgradeChr$ + words[row+1, upgrades[row+1,col+1]+2, raceQueueRef[col]] + "- " + Str(GetCost(row,col)) + "~" + chr(10) + powers[row+1, upgrades[row+1,col+1]+2, raceQueueRef[col]])
	else
		SetTextString(spr + 1, words[row+1, 4, raceQueueRef[col]])
		SetTextString(spr + 2, "")
		SetSpriteVisible(spr+1, 0)
		IncTextY(spr+1, 40)
		IncSpriteY(spr+3, 40)
		IncSpritePosition(spr+2, 290, -38) //Icons
	endif
	SetTextFontImage(spr + 1, font1I + upgrades[row+1, col+1])

	if GetCost(row,col) > scrapTotal then SetTextColor(spr + 2, 160, 160, 160, 255)

	// upgrade part sprite
	LoadSpriteExpress(spr + 4, areaChr$ + upgradeChr$ + str(1+upgrades[row+1,col+1]) + ".png", GetSpriteWidth(spr+2), GetSpriteHeight(spr+2), GetSPriteX(spr+2), GetSpriteY(spr+2), GetSpriteDepth(spr+2)-1)
	
endfunction


function CreateUpgrade()

	InitializeFromRaceQueue()
	
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
		LoadSpriteExpress(vehicle1 + col, "upgrade/mode" + str(raceQueueRef[col]) + ".png", 395*0.6, 80*0.6, 70 + col*(360), 25, 30)
	next col
	
	LoadSpriteExpress(upgradeBG, "upgradebg" + str(areaSeen) + ".png", w, h, 0, 0, 99)	
	//SetSpritePhysicsOn(upgradeBG, 1)
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
			SetTextString(spr + 1, words[row+1, upgrades[row+1,col+1]+1, raceQueueRef[col]])
			mStr$ = words[row+1, upgrades[row+1,col+1]+2, raceQueueRef[col]]
			SetTextString(spr + 2, Mid(mStr$, 2, -1) + "- " + Str(cost) + "~" + chr(10) + powers[row+1, upgrades[row+1,col+1]+2, col+1])
		else
			SetTextString(spr + 1, words[row+1, 4, raceQueueRef[col]])
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
		
	elseif Button(spr)
		//Physics event
		//SetSpritePhysicsImpulse(spr+1, GetPointerX(), GetPointerY(), 2100*(-GetPointerX()+GetSpriteMiddleX(spr+1)), 2100*(-GetPointerY()+GetSpriteMiddleY(spr+1)))
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
		
		SetViewOffset(0, 0)
		
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

function GetCost2(row, col, rID)
	cost = 0
	up = upgrades[row+1, rID]
	
	if col = 0
		if up = 0 then cost = 5
		if up = 1 then cost = 20
		if up = 2 then cost = 80
	elseif col = 1
		if up = 0 then cost = 20
		if up = 1 then cost = 55
		if up = 2 then cost = 130
	elseif col = 2
		if up = 0 then cost = 40
		if up = 1 then cost = 110
		if up = 2 then cost = 250
	elseif col = 3
		if up = 0 then cost = 65
		if up = 1 then cost = 200
		if up = 2 then cost = 500
	endif
endfunction cost
