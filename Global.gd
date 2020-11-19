extends Node
# singletons , every node can access this
# [project]-project settings-> autoload-> path set to 'Global.gd' -> Add


# Positions of things in the game
const ZEROVECTOR       = Vector2(0,0)
const CENTERSCREEN     = Vector2(400,300)
const RISINGSUN_POS    = Vector2(960, 30)

const NRUNIQUEBLOCKS      = 8

enum BLOCKLAYER { ERROR, NONE, ICE, CHAIN, CHAINS, BOMBSMALL, BOMBLARGE, LOCK, KEYHOLE , DICE, CLOCK , END }

const grid   = 56         # correct for scaling blk.gd : 128pixel * scale(0.25) = 64
const offset = 1 + ( grid / 2.0 )

# value's overwritten bij levels.gd
var board = {
#	level        = 0 ,
#	height       = int(9) ,
#	width        = int(9) ,
#	clock        = 3 * 60 ,
#	uniqueblocks = NRUNIQUEBLOCKS ,
#	newicepct    = 0 ,
#	newbombpct   = 0 ,
#	newdicepct   = 0 , 
#	newclockpct  = 0 ,
#	maxkeys      = 4
	}

var node_creation_parent = null
var node_mouse_handler   = null
var node_sound_guy       = null
var node_scoreboard      = null
var node_background      = null
var node_matchfinder     = null
var node_levels          = null
var node_dicerays        = null

#- - - - - - - - - - - - - - - - - - - - -  node_scoreboard
var node_scoreboard_config = {
	enabled        = true,
}

var scoreboard = {
	blocksdestroyed    = int( 0 )  ,
}

#------------------------------------------------------------------------------
# https://www.youtube.com/watch?v=6e9I_e8aHD4
# usage example: var bullet = instance_node( bullet_instance, global_position, get_parent() )
func instance_node(node, location , parent ):
	var node_instance = node.instance()
	parent.add_child(node_instance)
	if location == null:
		node_instance.global_position = ZEROVECTOR
	else:
		node_instance.global_position = location
	return node_instance

#------------------------------------------------------------------------------
func playsound(sound, frompos:float = 0.0):
	if node_sound_guy != null :
		if node_sound_guy.has_node(sound):
			node_sound_guy.get_node(sound).play( frompos )
			print("playing sound")
#example Global.playsound("slide")
#example Global.playsound("")

#==============================================================================
