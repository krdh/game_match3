extends CPUParticles2D

const ANILENGTH          = 2       # time in seconds the animation lasts
const ANIRANDSTARTDELAY  = 1       # animation random startdelay range 0...

var tmr_selfdestruct:Timer
var startdelay = true

#------------------------------------------------------------------------------
func _ready():
	# timeout will destoy .self node
	tmr_selfdestruct = Timer.new()
	self.add_child(tmr_selfdestruct, true)
	tmr_selfdestruct.wait_time = rand_range(0, ANIRANDSTARTDELAY)
	tmr_selfdestruct.connect("timeout", self, "_on_tmr_selfdestruct_timeout" )
	tmr_selfdestruct.start() 

#------------------------------------------------------------------------------
func _on_tmr_selfdestruct_timeout():
	
	if startdelay :
		tmr_selfdestruct.wait_time = ANILENGTH
		tmr_selfdestruct.start() 
		self.set_emitting(true)
		startdelay = false
	else:
		queue_free()

#==============================================================================
	#self.color = Color("feae34")
	#self.set_emitting(true)
