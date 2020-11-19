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

# block color nr 
# 1:white: 				2:orange:feae34
# 3:geyblue:3a4466		4:brown:b86f50
# 5:red: e43b44			6:yellow:fee761
# 7:green:3e8948		8:lblue: 2ce8f5
# 8:purple:b55088		9:grey:c0cbdc
# A:pink:f6757a			B:dblue:0095e9
