extends Node2D

const db:bool = false
const DEFAULT_CRATESCALE     = Vector2(0.4375, 0.4375)
const DEFAULT_SCALE     = Vector2(0.40, 0.40)
const DEFAULT_SCALE_POP = ( 1.1 * DEFAULT_SCALE )

onready var res_explodeblock = preload("res://effect/explodeblock.tscn")

var matched:bool        = false
var _in_animation:bool  = false      # flag if block in an animation currently

enum BLOCKTYPE  { ERROR, NORMAL, WALL, BLANK, KEY, BOMB, CLOCK , END }
var _blocktype:int

enum BLOCKLAYER { ERROR, NONE, ICE, CHAIN, CHAINS, BOMBSMALL, BOMBLARGE, LOCK, KEYHOLE , DICE, CLOCK , KEY, END }
var _blocklayer:int

# blk_sprites
var BLOCKCOLOR = [ Color("ffffff"),  # white
				   Color("b55088"),  # purple:b55088
				   Color("0095e9"),  # darkblue:0095e9
				   Color("e43b44"),  # red: e43b44
				   Color("fee761"),  # yellow:fee761
				   Color("3e8948"),  # green:3e8948
				   Color("2ce8f5"),  # lightblue:2ce8f5
				   Color("feae34"),  # orange:feae34
				   Color("b86f50"),  # brown:b86f50
				   Color("3a4466"),  # drarkgrey:3a4466
				   Color("c0cbdc"),  # grey:c0cbdc 
				   Color("f6757a") ] # pink:f6757a
											  


# Note Z-index layer order:
# 0 - Normal blocks blk_sprites."default" and "special"
#      "special" block WALL is set to Z-index 1
# 2 - blk_layer

#------------------------------------------------------------------------------
func _ready():

	if Global.node_creation_parent != null :
		Global.node_creation_parent.connect("sig_clear_animated", self, "_sig_clear_animated")
	
	var k = $blk_sprites.get_sprite_frames().get_frame_count("default")
	#var r = $blk_sprites.get_sprite_frames().get_frame_count("special")
	if ( Global.NRUNIQUEBLOCKS > k ):
		print("Err blk.gd not enough sprites")
	
	$lab.visible = db  # debug label on top of blocks
	
	self.scale  = DEFAULT_SCALE
	set_blocktype(BLOCKTYPE.NORMAL)
	set_blocklayer(BLOCKLAYER.NONE)
	
#------------------------------------------------------------------------------

func _sig_clear_animated():
	if _in_animation :
		#print("blk.gd _sig_clear_animated received")
		_in_animation = false
		$lab.set("custom_colors/font_color" , Color(0,1,0) )

#------------------------------------------------------------------------------
#called from Gameroot: destroyblocks() and dropblock()
func destroy(s:String="void", i:float=0.0 ):

	if s == "delay":
		Global.node_creation_parent.disconnect("sig_clear_animated", self, "_sig_clear_animated")
		$Timer_selfdestruct.wait_time = i
		$Tween.stop_all()
		$Timer_selfdestruct.start()

	elif s == "dropdown":
		Global.node_creation_parent.disconnect("sig_clear_animated", self, "_sig_clear_animated")
		$Timer_selfdestruct.wait_time = 2.1 + i
		if ( _blocktype == BLOCKTYPE.NORMAL ) :
			$Tween.stop_all()
			$Tween.interpolate_property(self, "position", position, position + Vector2(0,1600) , 2, Tween.TRANS_EXPO,Tween.EASE_IN, i)
			$Tween.start()
		$Timer_selfdestruct.start()

	else:
		if (_blocktype == BLOCKTYPE.WALL )or( _blocktype == BLOCKTYPE.BLANK ) :
			return ( false )
		if not _in_animation :
			if matched :  # only blocks with match flag explode, because dropblock() also calls destroy()
				# setup explosion is color of block
				var node_instance = res_explodeblock.instance()
				node_instance.color = BLOCKCOLOR[ $blk_sprites.get_frame() ]
				node_instance.position = global_position
				Global.node_creation_parent.add_child(node_instance)
			queue_free()
			return ( true )
		else:
			return ( false )

func _on_Timer_selfdestruct_timeout():
	queue_free()

#------------------------------------------------------------------------------
# flag to mark if block is moving(falling) on screen by Tween
func set_animated(input:bool):
	if input:
		_in_animation = input
		$lab.set("custom_colors/font_color" , Color(1,0,0) )
	else:
		_in_animation = input
		$lab.set("custom_colors/font_color" , Color(0,1,0) )

func get_animated():
	return ( _in_animation )
#------------------------------------------------------------------------------
func set_txt(t:String):
	$lab.text = t

func txt_visible(input:bool):
	$lab.visible = input
#------------------------------------------------------------------------------
func set_blockcolor(value:int):
	if _blocktype == BLOCKTYPE.NORMAL:
		$blk_sprites.animation = "default"
		$blk_sprites.set_frame( value )
	else:
		print("blk.gd set_blockcolor called on non NORMAL")

# returns 'color' of a normal block,  returns '0' when block is not normal
func get_blockcolor():
	if _blocktype != BLOCKTYPE.NORMAL :
		return ( 0 )
	else:
		return ( $blk_sprites.get_frame() )

func dbget_frame():
	return ( $blk_sprites.get_frame() )

func get_blocktype():
	return ( _blocktype )

func set_blocktype( value:int ):

	clear_match()

	match value :
		BLOCKTYPE.NORMAL:
			$blk_sprites.animation = "default"
			$blk_sprites.set_frame( 10 )
			_blocktype = BLOCKTYPE.NORMAL
		BLOCKTYPE.WALL :
			$blk_sprites.animation = "crates"
			self.scale  = DEFAULT_CRATESCALE
			$blk_sprites.set_frame( 1+randi()%6 )
			$blk_sprites.set_z_index(1)
			_blocktype = BLOCKTYPE.WALL
		BLOCKTYPE.BLANK:
			$blk_sprites.animation = "crates"
			$blk_sprites.set_frame( 0 )
			$blk_sprites.set_z_index(1)
			_blocktype = BLOCKTYPE.WALL                       # !!!!
		BLOCKTYPE.BOMB :
			$blk_sprites.animation = "special"
			$blk_sprites.set_frame( 2 )
			_blocktype = BLOCKTYPE.BOMB
		BLOCKTYPE.KEY :
			$blk_sprites.animation = "special"
			$blk_sprites.set_frame( 4 )
			_blocktype = BLOCKTYPE.KEY
		_ :
			print("set_blocktype match catchall"+str(value) )
			return ( false )

	return ( true )

#------------------------------------------------------------------------------
func set_match():
	if ( _blocktype == BLOCKTYPE.NORMAL )or( _blocktype == BLOCKTYPE.KEY ):
		matched = true
		self.modulate = Color(1, 1, 1, 0.3)
		self.scale = DEFAULT_SCALE * 0.7

func get_match():
	return matched
	
func clear_match():
	matched = false
	self.modulate = ( Color(1, 1, 1, 1) )
	self.scale = DEFAULT_SCALE
#------------------------------------------------------------------------------
#enum BLOCKLAYER { ERROR, NONE, ICE, CHAIN, CHAINS, BOMBSMALL, BOMBLARGE, LOCK, KEYHOLE ,END }
func set_blocklayer(value:int):
	match value :
		BLOCKLAYER.NONE:
			$blk_layer.visible = false
			_blocklayer = BLOCKLAYER.NONE
		BLOCKLAYER.ICE :
			$blk_layer.set_frame( 0 )
			$blk_layer.visible = true
			_blocklayer = BLOCKLAYER.ICE
		BLOCKLAYER.CHAIN :
			$blk_layer.set_frame( 1 )
			$blk_layer.visible = true
			_blocklayer = BLOCKLAYER.CHAIN
		BLOCKLAYER.CHAINS :
			$blk_layer.set_frame( 2 )
			$blk_layer.visible = true
			_blocklayer = BLOCKLAYER.CHAINS
		BLOCKLAYER.BOMBSMALL :
			$blk_layer.set_frame( 3 )
			$blk_layer.visible = true
			_blocklayer = BLOCKLAYER.BOMBSMALL
		BLOCKLAYER.BOMBLARGE :
			$blk_layer.set_frame( 4 )
			$blk_layer.visible = true
			_blocklayer = BLOCKLAYER.BOMBLARGE
		BLOCKLAYER.LOCK :
			$blk_layer.set_frame( 5 )
			$blk_layer.visible = true
			_blocklayer = BLOCKLAYER.LOCK
		BLOCKLAYER.KEYHOLE :
			$blk_layer.set_frame( 5 )
			$blk_layer.visible = true
			_blocklayer = BLOCKLAYER.KEYHOLE
		BLOCKLAYER.DICE :
			$blk_layer.set_frame( 7 )
			$blk_layer.visible = true
			_blocklayer = BLOCKLAYER.DICE
		BLOCKLAYER.CLOCK :
			$blk_layer.set_frame( 9 )
			$blk_layer.visible = true
			_blocklayer = BLOCKLAYER.CLOCK
		_ :
			print("set_layer match catchall" + str(value) )
			return ( false )

func get_blocklayer():
	return ( _blocklayer )
	
#------------------------------------------------------------------------------
# nudge a block in a certain direction as a hint, or mouse follow ?
func nudgeblock(dir:Vector2):
	if _in_animation:    # when in animation, ignore
		return
	var ww = dir.normalized() * 5      # 5 pixels
	if ww :
		$Tween.interpolate_property(self, "position", position , position + ww, 0.2, Tween.TRANS_SINE,Tween.EASE_IN)
		$Tween.interpolate_property(self, "position", position + ww, position , 0.2, Tween.TRANS_SINE,Tween.EASE_IN, 0.2)
		$Tween.start()

#------------------------------------------------------------------------------
func _on_Area2D_mouse_entered():
	if _blocktype != BLOCKTYPE.NORMAL:
		return
	$Tween.interpolate_property(self, "scale", DEFAULT_SCALE,     DEFAULT_SCALE_POP, 0.05, Tween.TRANS_SINE,Tween.EASE_IN)
	#$Tween.interpolate_property(self, "scale", DEFAULT_SCALE_POP ,DEFAULT_SCALE,     0.05, Tween.TRANS_SINE,Tween.EASE_IN, 0.08)
	$Tween.start()

func _on_Area2D_mouse_exited():
	if _blocktype != BLOCKTYPE.NORMAL:
		return
	$Tween.interpolate_property(self, "scale", DEFAULT_SCALE_POP ,DEFAULT_SCALE,     0.05, Tween.TRANS_SINE,Tween.EASE_IN, 0.08)
	$Tween.start()
	
#==============================================================================
# block color nr 
# 1:white: 				2:orange:feae34
# 3:geyblue:3a4466		4:brown:b86f50
# 5:red: e43b44			6:yellow:fee761
# 7:green:3e8948		8:lblue: 2ce8f5
# 8:purple:b55088		9:grey:c0cbdc
# A:pink:f6757a			B:dblue:0095e9
