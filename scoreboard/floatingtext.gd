extends Position2D

onready var label = get_node("Label")
onready var tween = get_node("Tween")
var amount 
var delay = 0.3
var color = Color.white
var moveto = Vector2.ZERO
var popupscale = Vector2(2 , 2)

func _ready():
	if amount == null:
		print("Warning: FloatingText amount==null")
		amount = "Bazinga"
	label.modulate = color
	label.set_text( str(amount) )
	tween.interpolate_property(self, "scale", scale,        popupscale     , 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, "scale", popupscale, Vector2(0.2, 0.2), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT, delay)
	if moveto != Vector2.ZERO :
		tween.interpolate_property(self,"position", position , moveto    , delay - 0.2 , Tween.TRANS_EXPO,Tween.EASE_IN )
	tween.start()
	#print("popuptext: " + str(position) + "    Globalpos: " + str(self.get_global_position() ) )

func set_style(s:String="score"):
	
	if   s == "score" :
		delay = 0.3
		color = Color.white
		moveto = Vector2.ZERO
	elif s == "banner" :
		popupscale = Vector2(4,4)
		delay = 4
		position = Global.CENTERSCREEN
	pass


func _on_Tween_tween_all_completed():
	self.queue_free()
#==============================================================================
