extends Position2D
#


var points:PoolVector2Array   #

func _ready():
	Global.node_dicerays        = self
	set_fade()

func _exit_tree():
	Global.node_dicerays        = null

func start():
	Global.node_dicerays        = null   # i know everything, release var in Global
	
	var dest1:PoolVector2Array
	var dest2:PoolVector2Array
	
	if points.size() != 5 :
		queue_free()
		return ( false )
	
	dest1.append( points[1] )
	dest1.append( points[0] )
	dest1.append( points[2] )

	dest2.append( points[3] )
	dest2.append( points[0] )
	dest2.append( points[4] )
	
	$Line1.set_points(dest1)
	$Line2.set_points(dest2)
	
	$Tween.interpolate_property($Line1, "width", 6 , 0 , $Timer.get_wait_time() , Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.interpolate_property($Line2, "width", 6 , 0 , $Timer.get_wait_time() , Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	$Timer.start()

func set_fade(t : float = 0.5):
	$Timer.wait_time =  t

func _on_Timer_timeout():
	$Tween.stop_all()
	queue_free()
