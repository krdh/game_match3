extends Node2D

onready var blk             = preload("res://blocks/blk.tscn")
onready var node_blk_sprite = preload("res://blocks/blk_sprites.tscn")

var count_timer:float

var _blockscore      = []          # howmany block of each color/type destroyed
var _blocktypes      = []
var _blockscoreLabel = []

#------------------------------------------------------------------------------ 
func _ready():
	Global.node_scoreboard = self
	$Label_score.text = "000"

	var error = Global.node_creation_parent.connect("sig_blockselfdestruct", self, "_on_sig_blockselfdestruct")
	if ( error != OK ):
		print("Cannot connect to sig_blockselfdestruct, code:" + error)


func _exit_tree():
	Global.node_scoreboard = null

#------------------------------------------------------------------------------ 
func update():

	if Global.board.empty():
		print("scoreboard update() Global.board dict is empty")
		return

	count_timer = Global.board.clock
	$TextureProgress.max_value = Global.board.clock
	$TextureProgress.value     = 0

	
	# clear all arrays	
	for i in range( _blocktypes.size() )      : _blocktypes[i].queue_free() ;
	for i in range( _blockscoreLabel.size() ) : _blockscoreLabel[i].queue_free() ;
	_blockscore.clear()
	_blocktypes.clear()
	_blockscoreLabel.clear()

	var pos = Vector2(950 , 200)
	for i in range( Global.board.uniqueblocks + 1 ):
		_blockscore.append(0)
		_blocktypes.append(Node2D)
		_blockscoreLabel.append(Label)
		
		_blockscore[i]           = 0
		_blocktypes[i]           = node_blk_sprite.instance()
		_blocktypes[i].position  = pos + Vector2(0, (i*30) )
		_blocktypes[i].scale     = Vector2(0.2, 0.2)
		_blocktypes[i].animation = "default"
		_blocktypes[i].set_frame( i )
		
		_blockscoreLabel[i] = Label.new()
		_blockscoreLabel[i].text =  str( _blockscore[i] )
		_blockscoreLabel[i].set_position(  pos + Vector2(20, (i*30) )  )
		
		add_child( _blocktypes[i] )
		add_child( _blockscoreLabel[i] )
	
	if ( _blocktypes.size() != _blockscoreLabel.size() ) or ( _blocktypes.size() != _blockscore.size() ):
		print("Error scoreboard arraysize")

#------------------------------------------------------------------------------
# called by gameroot.gd chkforclkanddices**()
func add_time( s:String = "void" , i = 0.0):

	if s == "delay":
		$Timer_funcaddtime.wait_time = i
		$Timer_funcaddtime.start()
	else:
		count_timer = count_timer * 0.5

func _on_Timer_funcaddtime_timeout():
	count_timer = count_timer * 0.5

#------------------------------------------------------------------------------
func _on_Timer_1sec_timeout():
	if count_timer <= Global.board.clock :
		count_timer += 1 ;
		$TextureProgress.value = count_timer

#------------------------------------------------------------------------------
# receives .frame (block color/type as value:int
func _on_sig_blockselfdestruct(value):
	if value != null :
		if _blockscore.size() > value:
			_blockscore[value] += 1
			_blockscore[0]     += 1
			Global.scoreboard.blocksdestroyed += int(value)
			$Label_score.text = str(Global.scoreboard.blocksdestroyed)
			
		for i in range( _blockscore.size() ):
			_blockscoreLabel[i].text = str( _blockscore[i] )

#------------------------------------------------------------------------------
func update_hittiles(i:int):
	$Label_tiles.text = str(i)
	#var colorstart = Color("c8000000")  # c8000000   blackgold
	var colorend   = Color("c8f2ff00")  # c8f2ff00  brightgold
	if i == 0:
		$Label_tiles.text = ""
		$TextureRect.set_modulate( colorend )


#------------------------------------------------------------------------------






