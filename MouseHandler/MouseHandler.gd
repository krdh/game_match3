extends Node2D

const PLAYERIDLETIME = 5.0

var mouse_drag:bool    = false
var mouse_cor:Vector2  
var player_idle:float = 0

signal mouse_event()
signal player_idle()

func _ready():
	Global.node_mouse_handler = self
	
func _exit_tree():
	Global.node_mouse_handler = null

#------------------------------------------------------------------------------
func _input(event):
	if event is InputEventMouseButton:  
		if ( event.pressed ): 
			player_idle = 0
			mouse_drag  = true
			mouse_cor   = event.position 
			#$bug.text = str( event.position ) + " bla "
		else :
			mouse_drag = false
			var v:Vector2 = ( event.position - mouse_cor)
			var loc = location(mouse_cor)
			var dir = direction(v)
			print("mousehandler: "+ str( mouse_cor ) + " " + str( event.position ) + " " + str( v ) + direction(v) + " " + str( loc ) )
			if ( loc.y > Global.board.height ) or ( loc.x > Global.board.width ) or dir == "err":
				pass #print("error _input out of range")
			else:
				emit_signal("mouse_event",loc, dir)

#------------------------------------------------------------------------------
func location(vec:Vector2) -> Vector2:
	var r = floor( (vec.y ) / Global.grid )
	var c = floor( (vec.x ) / Global.grid )
	return ( Vector2(c,r) )
#------------------------------------------------------------------------------
func direction(vec:Vector2) -> String:
	if vec.length() <= 20:       #require minimum drag length (in pixels??)
		return ("err")
	var r:String = ""
	if   abs(vec.x) > abs(vec.y) :  # left or right
		r = "left"
		if   vec.x > 0: r = "right"
	else :                         # up or down
		r = "up"
		if   vec.y > 0: r = "down"
	return ( r )
#==============================================================================


func _on_Timer_timeout():
	player_idle += $Timer.get_wait_time()
	if player_idle > PLAYERIDLETIME :
		emit_signal("player_idle")
		player_idle = 0
