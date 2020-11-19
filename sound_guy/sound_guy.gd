extends Node2D

func _ready():
	Global.node_sound_guy = self

func _exit_tree():
	Global.node_sound_guy = null
#==============================================================================
#func playsound(sound):
#	if node_sound_guy != null :
#		if node_sound_guy.has_node(sound):
#			node_sound_guy.get_node(sound).play()
#			print("playing sound")
#example Global.playsound("Shoot")
#example Global.playsound("Hit")
#------------------------------------------------------------------------------
