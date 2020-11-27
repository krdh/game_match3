extends Position2D

# make a block layer fly(travel) from one location to another

enum BLOCKLAYER { ERROR, NONE, ICE, CHAIN, CHAINS, BOMBSMALL, BOMBLARGE, LOCK, KEYHOLE , DICE, CLOCK , KEY, END }

func _ready():
	Global.node_flyingblock = self

func _exit_tree():
	Global.node_flyingblock = null

#------------------------------------------------------------------------------
func config(frompos:Vector2 , topos:Vector2, layer:int = 1, anitime:float = 2 , startdelay:float = 0 ):
	
	self.scale = Vector2(0.40, 0.40)
	$blk_layer.frame = layer
	$Tween.interpolate_property(self, "position",    frompos, topos , anitime, Tween.TRANS_SINE, Tween.EASE_OUT_IN, startdelay)
	$Tween.interpolate_property(self, "rotation_degrees", 0 , 360, 0.25*anitime, Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, 0.5*anitime+startdelay )
	$Tween.start()
#------------------------------------------------------------------------------
func _on_Tween_tween_all_completed():
	queue_free()
	
#==============================================================================
