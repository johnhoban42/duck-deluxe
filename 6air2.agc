#include "main.agc"
// File: 6air2.agc
// Created: 24-10-03

#constant air2Distance 20000

function InitAir2()
	
	heroLocalDistance# = air2Distance
	
endfunction

function DoAir2()
	
	dec heroLocalDistance#, 0.1*fpsr#
	
endfunction