extends Position2D
#
# Show a Textpopup with a frame around, position is left-bottom
# parameters:   delay    : How long the text is shown and how long the fade is
#                          , so total lifetime is 2x delay
#               predelay : delay before the textbubble is shown
#                          . so total lifetime is  predelay + 2x delay
const DEFAULT_FONT_SIZE = Vector2(1, 1)
const LARGE_FONT_SIZE   = Vector2(2, 2)


func set_text(s:String , style:String="normal", delay:float=4.0 , predelay:float = 0.0) :

	if s.length() == 0 or delay == 0:
		queue_free()

	match style:
		"normal", "Normal", "":
			self.scale = DEFAULT_FONT_SIZE
		"large","Large" :
			self.scale = LARGE_FONT_SIZE

	self.visible = false
	$Label.text = s

	$Tween.interpolate_property(self,"modulate", Color("ffffff"), Color("00ffffff"), delay , Tween.TRANS_LINEAR, Tween.EASE_OUT_IN, delay )

	if predelay :
		$Timer.wait_time = predelay
		$Timer.start()
	else:
		self.visible = true
		$Tween.start()

func _on_Tween_tween_all_completed():
	queue_free()

# PreDelay timer, used to 'stack' multiple messages
func _on_Timer_timeout():
	self.visible = true
	$Tween.start()
