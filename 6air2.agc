#include "main.agc"
// File: 6air2.agc
// Created: 24-10-03

#constant air2Distance 20000

//The slipstream sprite
global slipS as integer[5]

function InitAir2()
	
	heroLocalDistance# = air2Distance
	
	CreateSpriteExpress(hero, 100, 100, w/2, 400, 7)
	
	for i = 1 to 1
		slipS[i] = CreateSprite(0)
		//Tessalate the slipstream image
		//SetSpriteExpress(slipS[i])
	next i
	
endfunction

function DoAir2()
	
	//SetSpritePosition(hero, heroX#, 500)
	
	dec heroLocalDistance#, 0.1*fpsr#
	
endfunction