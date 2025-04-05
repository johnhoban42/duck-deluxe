// File: menu.agc
// Created: 25-04-01

global menuInitialized = 0

function InitMenu()
	
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


