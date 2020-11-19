extends CPUParticles2D


var tmr_selfdestruct:Timer

func _ready():
	# timeout will destoy .self node
	tmr_selfdestruct = Timer.new()
	self.add_child(tmr_selfdestruct, true)
	tmr_selfdestruct.wait_time = 2
	tmr_selfdestruct.connect("timeout", self, "_on_tmr_selfdestruct_timeout" )
	tmr_selfdestruct.start() 

	#self.color = Color("feae34")
	self.set_emitting(true)

func _on_tmr_selfdestruct_timeout():
	queue_free()
