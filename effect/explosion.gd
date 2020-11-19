extends Position2D


func _ready():
	pass # Replace with function body.

func _on_AudioStreamPlayer_finished():
	queue_free()
