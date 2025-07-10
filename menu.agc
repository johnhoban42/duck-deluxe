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


