// File: constants.agc
// Created: 24-10-03

global UPGRADE_CHARS as string[4] = ["M", "O", "D", "E"]
// todo - we'll need new chars for water 2, land 2, etc. if we want new letter sprites
global AREA_CHARS as string[7] = ["W", "L", "S", "W", "L", "S", "Z"]


#constant WATER 1
#constant LAND 2
#constant AIR 3
#constant WATER2 4
#constant LAND2 5
#constant AIR2 6
#constant SPACE2 7

#constant UPGRADE 8
#constant TITLE 9
#constant FINISH 10

global heroImg1
global heroImg2
global heroImg3

global hero2Img1
global hero2Img2
global hero2Img3
global hero2Img4
global hero2Img5
global hero2Img6

global featherImg1
global featherImg2
global featherImg3
global featherImg4

//ScrapNum, FrameNum, SetNum
global scrapImgs as integer[3,4,4]
function LoadScrapImages()
	for i = 1 to 3	//ScrapNum
		for j = 1 to 4	//FrameNum
			for k = 1 to 4	//SetNum
				scrapImgs[i,j,k] = LoadImageR("scrap" + str(i) + "_" + str(k) + "_" + str(j) + ".png")
			next k
		next j
	next i
endfunction
global fish1I
global fish2I
global fish3I

//Sprite/Image/Audio constants
#constant hero 1001
#constant hero2 1002

#constant scrapText 1010

#constant progFront 1011
#constant progBack 1012
#constant heroIcon 1013
#constant duckIcon 1014
#constant flag1 1015
#constant flag2 1016
#constant flag3 1017
#constant cutsceneSpr 1018
#constant coverS 1019

#constant waterBarFront 1021
#constant waterBarBack 1022


#constant logo 1023
#constant startRace 1024
#constant finishS 1025
#constant restartS 1026

#constant cutsceneSpr2 1027 //Endig
#constant cutsceneSpr3 1028	//Intro

#constant landBoost1 1031
#constant landBoost2 1032
#constant landBoost3 1033
#constant landBoost4 1034
#constant landBoost5 1035
#constant landBoost6 1036
#constant landBoost7 1037
#constant scvs 1038
#constant rail1 1039
#constant rail2 1040




#constant duck 1201

#constant instruct 1202
#constant vehicle1 1203
#constant vehicle2 1204
#constant vehicle3 1205
#constant vehicle4 1206

#constant superStart 1601

#constant bg 2001
#constant waterS 2002
#constant landS 2003
#constant airS 2004
#constant bg2 2005
#constant bg3 2006

#constant water2S 2007
#constant water2BG 2008

//#constant land2S 2008
//#constant air2S 2009
//#constant space2S 2009

#constant upgradeBG 3000
#constant upgrage1StartSpr 3001
#constant upgrage2StartSpr 3201
#constant upgrage3StartSpr 3401

//The NEW upgrade system - these are IDs for the pod sets
global upPods as p[0]

//The start point for the extra sprites to make water tiles in the swamp
#constant water2TileS = 4001
global water2TileE
global numCross	//The number of tiles across that the water texture tiles will go
global tileEH	//Tile extra height, expanded to make them look connected together
#constant diveVisAngle 50
#constant waterTileAlpha 200
#constant water2Trees 4051


#constant land2sprStreet 5000  // 5000 - 5004 for 5 lanes
#constant land2sprBuildings 5010  // reserved 5010 - 5019 for building sprites
#constant land2sprBoostMeter 5100
#constant land2sprCones 5700  // reserved 5700 - 5799 for cone sprites
#constant land2sprBoostPanels 5800  // reserved 5800 - 5999 for boost panel sprites

#constant air2BG 6001

global tileI1
global tileI2

#constant spawnStartS 10001
global spawnS = spawnStartS


//Start point for extra space sprites: mash inputs
#constant mashSprS 7001
global arrowI

//Particles
#constant lightP 1
#constant splashP 2
#constant featherP 3


#constant GOOD 1
#constant BAD 2
#constant SCRAP 3
#constant RAMP 4