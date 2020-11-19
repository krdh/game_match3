extends Node2D

const MAXLEVEL = 3

var _level:int = 0

var layer
var border
var levelconf

func _ready():
	Global.node_levels = self

func _exit_tree():
	Global.node_levels = null

func set_level(value:int) -> bool :
	if ( value > MAXLEVEL )or( value < 0):
		return false
	_level = value
	match _level:
		1:
			layer  = layer1.duplicate(true)
			border = border1.duplicate(true)
			Global.board.clear()
			Global.board = levelconf_1.duplicate(true)
			return ( true )
		2:
			layer  = layer2.duplicate(true)
			border = border2.duplicate(true)
			Global.board = levelconf_2.duplicate(true)
			return ( true )
		3:
			layer  = layer3.duplicate(true)
			border = border3.duplicate(true)
			Global.board = levelconf_3.duplicate(true)
			return ( true )
		_:
			print("Error levels.gd set_level")

	return ( false )

func get_level():     return ( _level   ) ;
func get_max_level(): return ( MAXLEVEL ) ;
	
func get_next_level():
	if _level == MAXLEVEL :
		return ( -1 )
	_level += 1
	return ( _level )

func set_next_level():
	if _level == MAXLEVEL :
		return ( false )
	_level += 1
	return ( set_level( _level ) )


#------------------------------------------------------------------- Level 1
# What layers and configuration need to be applied for this level:
var dict_tutorial_1 = { 
					enabled    = true ,
					text       = "This level contains small and large bombs:\nSmall bombs destroy 4 surrounding blocks.\nLarge bombs destroy 8 surrounding blocks.\nBomb blocks can not be swapped." ,
					text1      = "To complete the level :\n Drop the key on top of a lock.\n Make a match on all squares at least once." ,
					blocklayer = Global.BLOCKLAYER.BOMBSMALL }

var levelconf_1 = {
	level        = 1 ,
	height       = int(10)  ,
	width        = int(12)  ,
	clock        = 5*60    ,
	uniqueblocks = 4 ,
	newicepct    = 0 ,
	newbombpct   = 1 ,
	newdicepct   = 0 ,
	newclockpct  = 0 ,
	maxkeys      = 2 ,                   # max nr of keys on board
	tutorial     = dict_tutorial_1
	}
#                     0      1    2     3      4        5           6       7       8       9
# enum BLOCKLAYER { ERROR, NONE, ICE, CHAIN, CHAINS, BOMBSMALL, BOMBLARGE, LOCK, KEYHOLE , DICE, CLOCK , END }
var layer1      = [ [ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 6 , 0 , 0 , 0 , 0 , 6 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 5 , 0 , 0 , 5 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 8 , 8 , 8 , 8 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ] ]

var border1     = [ [ 2 , 1 , 1 , 1 , 0 , 0 , 0 , 0 , 1 , 1 , 1 , 2 ],
					[ 2 , 1 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 1 , 2 ],
					[ 2 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 2 ],
					[ 2 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 2 ],
					[ 2 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 2 ],
					[ 2 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 2 ],
					[ 2 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 2 ],
					[ 2 , 2 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 2 , 2 ],
					[ 2 , 2 , 2 , 1 , 1 , 1 , 1 , 1 , 1 , 2 , 2 , 2 ],
					[ 2 , 2 , 2 , 2 , 1 , 1 , 1 , 1 , 2 , 2 , 2 , 2 ] ]

#------------------------------------------------------------------- Level 2
# What layers and configuration need to be applied for this level:
var dict_tutorial_2 = { 
					enabled    = true ,
					text       = "This level contains chains and ice:\n make a match to clear the chains and ice.\nChains and ice blocks can not be swapped." ,
					text1      = "Make sure you watch your countdown clock.",
					blocklayer = Global.BLOCKLAYER.BOMBSMALL }

var levelconf_2 = {
	level        = 2,
	height       = int(10) ,
	width        = int(12) ,
	clock        = 5*60    ,
	uniqueblocks = 5 ,
	newicepct    = 1 ,
	newbombpct   = 2 ,
	newdicepct   = 0 ,
	newclockpct  = 0 ,
	maxkeys      = 2 ,
	tutorial     = dict_tutorial_2
	}

#                     0      1    2     3      4        5           6       7       8       9
# enum BLOCKLAYER { ERROR, NONE, ICE, CHAIN, CHAINS, BOMBSMALL, BOMBLARGE, LOCK, KEYHOLE , DICE, CLOCK , END }
var layer2      = [ [ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 4 , 4 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 3 , 0 , 0 , 3 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 2 , 0 , 0 , 0 , 0 , 2 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 8 , 8 , 0 , 0 , 0 , 0 , 0 ] ]

var border2     = [ [ 2 , 1 , 1 , 1 , 0 , 0 , 0 , 0 , 1 , 1 , 1 , 2 ],
					[ 1 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 1 ],
					[ 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 ],
					[ 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 ],
					[ 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 ],
					[ 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 ],
					[ 2 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 2 ],
					[ 2 , 2 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 2 , 2 ],
					[ 2 , 2 , 2 , 1 , 0 , 0 , 0 , 0 , 1 , 2 , 2 , 2 ],
					[ 2 , 2 , 2 , 2 , 1 , 1 , 1 , 1 , 2 , 2 , 2 , 2 ] ]

#------------------------------------------------------------------- Level 3
# What layers and configuration need to be applied for this level:
var dict_tutorial_3 = { 
					enabled    = true ,
					text       = "This level contains dice\n dice destroy 4 random blocks on the board.\nYou can move dice." ,
					text1      = "This level contains clocks \nthat give you more time to clear the board.\nYou can move clocks." ,
					blocklayer = Global.BLOCKLAYER.BOMBSMALL }

var levelconf_3 = {
	level        = 3,
	height       = int(11)  ,
	width        = int(12) ,
	clock        = 3*60    ,
	uniqueblocks = 5 ,
	newicepct    = 1 ,
	newbombpct   = 1 ,
	newdicepct   = 2 ,
	newclockpct  = 2 ,
	maxkeys      = 3 ,
	tutorial     = dict_tutorial_3
	}
#                     0      1    2     3      4        5           6       7       8       9
# enum BLOCKLAYER { ERROR, NONE, ICE, CHAIN, CHAINS, BOMBSMALL, BOMBLARGE, LOCK, KEYHOLE , DICE, CLOCK , END }
var layer3      = [ [ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ], #1
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 ,10 , 0 , 0 , 0 , 0 ,10 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 5 , 5 , 0 , 0 , 0 , 0 , 0 ], #5
					[ 0 , 0 , 0 , 0 , 4 , 0 , 0 , 4 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 9 , 0 , 0 , 0 , 0 , 9 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ],
					[ 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ], #9
					[ 0 , 0 , 0 , 0 , 8 , 0 , 0 , 8 , 0 , 0 , 0 , 0 ] ]

var border3     = [ [ 2 , 1 , 1 , 1 , 0 , 0 , 0 , 0 , 1 , 1 , 1 , 2 ], #1
					[ 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 ],
					[ 2 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 2 ],
					[ 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 ],
					[ 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 ], #5
					[ 2 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 2 ],
					[ 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 ],
					[ 2 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 2 ],
					[ 2 , 2 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 1 , 2 , 2 ], #9
					[ 2 , 2 , 2 , 1 , 0 , 0 , 0 , 0 , 1 , 2 , 2 , 2 ],
					[ 2 , 2 , 2 , 2 , 1 , 1 , 1 , 1 , 2 , 2 , 2 , 2 ] ] #11


