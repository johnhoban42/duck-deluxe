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
	
	//The peeper! The glowing guy at the bottom who says cost, preview for affordability
	sprPeep as integer
	txtPeep as integer
	
	//Chains which move down to the next part
	sprChainL as integer
	sprChainR as integer
	
	twnSideSway as integer
	twnMainDown as integer
	twnMainUp as integer
	twnUpgradeDown as integer
	twnUpgradeUp as integer
	
	isDown as integer
	isSelected as integer
	
endtype



function CreatePod(row, col)
	pod as p
	rID = raceQueueRef[col+1]
	pod.rID = rID
	pod.row = row
	pod.column = col
	pod.lev = upgrades[row, rID]
	
	pod.sprBG = CreateSprite(LoadImage("shopbox1.png"))
	spr = pod.sprBG
	SetSpriteExpress(spr, 362, 100, 10 + col*364, 80 + row*142, 50) 
	SetSpriteColor(spr, 80, 80, 80, 255)
	//SetSpriteColorAlpha(spr, 100)
	
	//THE POSITIONS OF ALL THE BELOW ARE UPDATED EVERY FRAME IN THE 'ALIGNPOD' METHOD!!!
	
	pod.sprLetter = LoadSprite("raceLetters/let" + str(row+1) + "r" + str(rID) + ".png")
	SetSpriteExpress(pod.sprLetter, 75, 75, GetSpriteX(spr)-5, GetSpriteY(spr)-10, 20)
	
	pod.sprIconBG = LoadSprite("icon" + str(rID) + "bg.png")
	SetSpriteExpress(pod.sprIconBG, 60, 60, GetSpriteX(spr) + 285, GetSpriteY(spr) + 14, 14)
	
	//if GetImageExists
	pod.sprIconTop = LoadSprite("WD1.png")
	SetSpriteExpress(pod.sprIconTop, 60, 60, GetSpriteX(spr) + 285, GetSpriteY(spr) + 14, 13)
	
	//inc upgrades[row+1, col+1], 3
	pod.txtCurWord = CreateText("")
	SetTextExpress(pod.txtCurWord, Mid(words[row+1, upgrades[row+1,col+1]+1, rID], 2, -1), 48, font1I + upgrades[row+1, col+1], 0, GetSpriteX(spr) + 60, GetSpriteY(spr) + 7, -7, 15)
	
	pod.txtMainDesc = CreateText("")
	SetTextExpress(pod.txtMainDesc, powers[row+1, upgrades[row+1,col+1]+1, rID], 24, fontMI, 0, GetSpriteX(spr) + 70, GetSpriteY(spr) + 73, -4, 15)
	
	pod.sprUpBG = CreateSprite(0)
	SetSpriteExpress(pod.sprUpBG, GetSpriteWidth(spr)-38, 110, 0, GetSpriteY(spr)+GetSpriteHeight(spr)-80, 100)
	SetSpriteX(pod.sprUpBG, GetSpriteMiddleX(spr) - GetSpriteWidth(pod.sprUpBG)/2)
	SetSpriteColor(pod.sprUpBG, 200, 200, 200, 255)
	
	pod.sprChainL = CreateSprite(0)
	SetSpriteExpress(pod.sprChainL, 10, GetSpriteHeight(spr), GetSpriteX(spr)+5, GetSpriteMiddleY(spr), 150)
	
	pod.sprChainR = CreateSprite(0)
	SetSpriteExpress(pod.sprChainR, 10, GetSpriteHeight(spr), GetSpriteX(spr)+GetSpriteWidth(spr)-15, GetSpriteMiddleY(spr), 150)
	
	pod.twnSideSway = CreateTweenSprite(.8)
	SetTweenSpriteX(pod.twnSideSway, GetSpriteX(spr)-8, GetSpriteX(spr), TweenOvershoot())
	
	pod.twnMainDown = CreateTweenSprite(.3)
	SetTweenSpriteY(pod.twnMainDown, GetSpriteY(spr), GetSpriteY(spr)+80, TweenSmooth2())
	pod.twnMainUp = CreateTweenSprite(.3)
	SetTweenSpriteY(pod.twnMainUp, GetSpriteY(spr)+80, GetSpriteY(spr), TweenSmooth2())
	
	pod.twnUpgradeDown = CreateTweenCustom(.3)
	SetTweenCustomFloat1(pod.twnUpgradeDown, 0, 70, TweenOvershoot())
	pod.twnUpgradeUp = CreateTweenCustom(.3)
	SetTweenCustomFloat1(pod.twnUpgradeUp, 70, 0, TweenOvershoot())
endfunction pod

function CreateUpgrade2()
	
	LoadSpriteExpress(upgradeBG, "upgrade2-1.png", w, h, 0, 0, 900)
	FixSpriteToScreen(upgradeBG, 1)
	selectedPod = -1
	
	if debug
		raceQueueRef.insert(WATER)
		raceQueueRef.insert(LAND)
		raceQueueRef.insert(AIR)
		raceQueueRef.insert(SPACE2)
		//raceQueueRef.insert(WATER)
		//raceQueueRef.insert(LAND)
		//raceQueueRef.insert(AIR)
		areaSeen = raceQueueRef.length
	endif
	
	upPods.length = -1
	upPods.length = areaSeen*4
	
	curPod as p
	
	for i = 0 to areaSeen*4-1
		curPod = CreatePod(Mod(i, 4), i/4)
		upPods[i] = curPod
	next i
	
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
		triggerMove = 1
	endif
	
	curP as p
	for i = 0 to upPods.length-1
		curP = upPods[i]
		
		if ((Button(curP.sprBG) or Button(curP.sprUpBG)) and i <> selectedPod) or (triggerMove <> 0 and i = selectedPod+triggerMove)
			oldSel = selectedPod
			selectedPod = i
			upPods[i].isSelected = 1
			if oldSel <> -1 then upPods[oldSel].isSelected = 0
			
			UpdateAllTweens(1)
			
			
			//StopTweenCustom(upPods[i].twnUpgradeDown)
			//StopTweenCustom(upPods[i].twnUpgradeUp)
			
			//Moving the upgrade panel down on the selected upgrade
			PlayTweenCustom(upPods[i].twnUpgradeDown, 0)
			//PlayTweenCustom(upPods[i].twnUpgradeUp, 0)
			//UpdateAllTweens(.0001)
			//StopTweenCustom(upPods[i].twnUpgradeUp)
			if oldSel <> -1 then PlayTweenCustom(upPods[oldSel].twnUpgradeUp, 0)
			
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
			
		
	next i
	UpdateAllTweens(.0001)
	
	//TODO: If you click on the Krab upgrade, make it play Space Crab turn sound
	
	for i = 0 to upPods.length-1
		AlignPod(upPods[i])
	next i
	GlideViewOffset(((68+32*areaSeen)*(selectedPod/4)), 0, 40, 2)
	
	Print(GetSpriteHit(GetPointerX(), GetPointerY()))
endfunction
function AlignPod(curP as p)
	spr = curP.sprBG
	
	//SetTextScisscor
	
	SetSpritePosition(curP.sprLetter, GetSpriteX(spr)-5, GetSpriteY(spr)-10)
	SetSpritePosition(curP.sprUpBG, GetSpriteMiddleX(spr) - GetSpriteWidth(curP.sprUpBG)/2, GetSpriteY(spr)+GetSpriteHeight(spr)-80 + GetTweenCustomFloat1(curP.twnUpgradeUp)) //+GetTweenCustomFloat1(curP.twnUpgradeDown))
	SetSpritePosition(curP.sprIconBG, GetSpriteX(spr) + 285, GetSpriteY(spr) + 14)
	SetSpritePosition(curP.sprIconTop, GetSpriteX(spr) + 285, GetSpriteY(spr) + 14)
	
	SetTextPosition(curP.txtCurWord, GetSpriteX(spr) + 60, GetSpriteY(spr) + 7)
	SetTextPosition(curP.txtMainDesc, GetSpriteX(spr) + 82, GetSpriteY(spr) + 63)
	
	if curP.isSelected
		//Changing the positioning of the upgrade panel differently
		SetSpritePosition(curP.sprUpBG, GetSpriteMiddleX(spr) - GetSpriteWidth(curP.sprUpBG)/2, GetSpriteY(spr)+GetSpriteHeight(spr)-80 + GetTweenCustomFloat1(curP.twnUpgradeDown))
	endif
	
endfunction
function DeleteUpgrade2()
	
endfunction

function CreateUpgradePod(row, col)
	// Create a single upgrade pod.
	
	spr = upgrage1StartSpr + 200*col + row*10
	LoadSpriteExpress(spr, "shopbox" + str(raceQueueRef[col]) + ".png", 362, 154, 10 + col*360, 80 + row*156, 20)
	
	LoadSpriteExpress(spr + 1, "shopPlate.png", 240, 75, GetSpriteX(spr) + 72, GetSpriteY(spr) + 60, 14)
	SetSpriteColor(spr+1, 110, 110, 110, 255)	
	
	LoadSpriteExpress(spr + 2, "icon" + str(raceQueueRef[col]) + "bg.png", 40, 40, GetSpriteX(spr) + 16, GetSpriteY(spr) + 92, 14)
	
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
		LoadSpriteExpress(vehicle1 + col, "mode" + str(raceQueueRef[col]) + ".png", 395*0.6, 80*0.6, 70 + col*(360), 25, 30)
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
