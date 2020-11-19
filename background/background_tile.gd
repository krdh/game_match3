extends Node2D

const db:bool = false
const DEFAULT_SCALE     = Vector2(0.4375, 0.4375)
const DEFAULT_HITCOUNT  = 1

enum TILETYPE  { ERROR, NONE, NORMAL, END }
var _tiletype   : int
var hitcnt      : int
var hitcntstart : int = DEFAULT_HITCOUNT

onready var node_twinkle = preload("res://effect/twinkle.tscn")
var twinkle_timeout:float = 0.0

var __selfdestruct: bool = false


#https://docs.godotengine.org/en/stable/classes/class_color.html#class-color-method-linear-interpolate
var colorstart = Color("c8000000")  # c8000000   blackgold
var colorend   = Color("c8f2ff00")  # c8f2ff00  brightgold

#------------------------------------------------------------------------------
func _ready():
	
	self.show_behind_parent = true
	self.scale   = DEFAULT_SCALE
	set_tiletype( TILETYPE.NONE )
	

#------------------------------------------------------------------------------
func destroy(s:String="void", i:float=0.0 ):

	if s == "fade":
		$Tween.stop_all()
		$Tween.interpolate_property($tile_sprites, "modulate", colorend , Color.black , i, Tween.TRANS_LINEAR ,Tween.EASE_IN )
		$Tween.start()
		twinkle_timeout = i * 10.0                  # timer has 100ms ticks
		__selfdestruct = true
	else:
		queue_free()
	
#------------------------------------------------------------------------------
func _givecolorrampcolor() -> Color :
	var cr = 0.0
	var colorramp
	if hitcntstart == 0 :
		return ( colorend )
	cr = float(hitcnt) / float(hitcntstart)
	colorramp = colorend.linear_interpolate(colorstart, cr)
	return ( colorramp )

#------------------------------------------------------------------------------
func set_hitcount(value:int):
	if value >= 0 and value < 9 :  # sensible range
		hitcntstart = value
		hitcnt = hitcntstart
		$tile_sprites.set_modulate( _givecolorrampcolor() )
	else:
		print("ERROR set_hitcount() "+str(value) )

# set a single hit on the background tile
func set_hit():
	if hitcnt > 0:
		hitcnt -= 1
		print("set_hit "+ str(hitcnt) )
		$tile_sprites.set_modulate( _givecolorrampcolor() )

func get_hitcount():
	return ( hitcnt )

#------------------------------------------------------------------------------
func set_tiletype(value:int): #

	if value == TILETYPE.NORMAL:
		_tiletype = TILETYPE.NORMAL
		$tile_sprites.animation = "default"
		$tile_sprites.set_frame( 1 )
		set_hitcount( DEFAULT_HITCOUNT )
		self.visible = true
	
	elif value == TILETYPE.NONE:
		_tiletype = TILETYPE.NONE
		self.visible = false
		$tile_sprites.set_frame( 0 )
		set_hitcount( 0 )

	else:
		print("ERROR background_tile.gd set_tiletype: " + str(value) )

func get_tiletype():
	return ( _tiletype )

#------------------------------------------------------------------------------
func get_attention():
	# control timing, this routine might get called irregurally
	if twinkle_timeout == 0 :
		var twinkle = node_twinkle.instance()
		twinkle.position = global_position
		Global.node_creation_parent.add_child( twinkle )
		twinkle_timeout = 60.0   # 60x100ms

#------------------------------------------------------------------------------
# 100ms timertick
func _on_Timer_timeout():
	if twinkle_timeout > 0.0 :
		twinkle_timeout -= 1.0
	if __selfdestruct and twinkle_timeout == 0 :
		queue_free()

#==============================================================================


