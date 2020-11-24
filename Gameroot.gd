extends Node2D

# TODO    create keys above  keyholes
#         transition screens between levels


#- - - - - - - - - - - - - - - - - - - - Debug
var   db: bool    = true
var tmr_tick:int  = 0

#- - - - - - - - - - - - - - - - - - - - Constants
enum            { INIT, NEWBOARD, GAME, MATCH, COLLAPSE, CLRBOARD, NEXTLEVEL, IDLE }
enum BLOCKTYPE  { ERROR, NORMAL, WALL, BLANK, KEY, BOMB, CLOCK , END }
enum BLOCKLAYER { ERROR, NONE, ICE, CHAIN, CHAINS, BOMBSMALL, BOMBLARGE, LOCK, KEYHOLE , DICE, CLOCK , END }
enum TILETYPE   { ERROR, NONE, NORMAL, END }
const BLK_ANI_SPEED:float = 0.1

#- - - - - - - - - - - - - - - - - - - - resources
onready var blk                = preload("res://blocks/blk.tscn")
onready var res_backgroundtile = preload("res://background/background_tile.tscn")
onready var res_Scoreboard     = preload("res://scoreboard/scoreboard.tscn")
onready var res_floatingtext   = preload("res://scoreboard/floatingtext.tscn")
onready var res_textbubble     = preload("res://effect/textbubble.tscn")
onready var res_dicerays       = preload("res://effect/rays.tscn")
onready var res_bombexplosion  = preload("res://effect/explosion.tscn")
onready var res_mousehandler   = preload("res://MouseHandler/MouseHandler.tscn")
onready var res_levels         = preload("res://levels/levels.tscn")

#onready var res_explodeblock = preload("res://effect/explodeblock.tscn")

#- - - - - - - - - - - - - - - - - - - - var
var b  = []                  # 2d array hold block nodes
var t  = []                  # 2d array holds background tiles (nodes)
var p  = []                  # 2d array hold positions (x,y) pixels (constant)
var fsm:int = 0              # state machine

var gameprogress = {
		nomoremoves       = false ,
		endoflevelreached = false ,
		hitalltiles       = false ,
		nomoretime        = false
}

#- - - - - - - - - - - - - - - - - - - - Signals gameprogress.nomoremoves
signal  sig_blockselfdestruct()
#signal  sig_undomove()
signal  sig_clear_animated


#------------------------------------------------------------------------------
# register with Global, connect to mouse_handler() , instance scoreboard
func _ready():
	
	randomize()
	
	Global.node_creation_parent = self
	fsm = INIT

	Global.instance_node(res_Scoreboard,   Vector2(0,0), self )
	Global.instance_node(res_levels,       Vector2(0,0), self )
	Global.instance_node(res_mousehandler, Vector2(0,0), self )

	if Global.node_levels == null :
		print("Error No level information")
		self.queue_free()
	else :
		Global.node_levels.set_level(1)

	var error = Global.node_mouse_handler.connect("mouse_event", self, "_sig_mouse_event")
	if ( error != OK ): print("Cannot connect to mouse_event signal, code:" + error);
	
	error = Global.node_mouse_handler.connect("player_idle", self, "_sig_player_idle_event")
	if ( error != OK ): print("Cannot connect to player_idle signal, code:" + error);

	error = Global.node_scoreboard.connect("out_of_time", self, "_sig_scoreboard_event")
	if ( error != OK ): print("Cannot connect to out_of_time signal, code:" + error);
	

	Global.playsound("BackgroundMusic", randi()%(60*30) ) #start somewhere in first 30minutes

func _exit_tree():
	Global.node_creation_parent = self

#------------------------------------------------------------------------------
# make new board with color randomly generated blocks, and using levels.gd info
func _create_new_board():
	
	if Global.node_levels == null:
		print("Error No level information")
		self.queue_free()
	
	gameprogress.endoflevelreached = false
	b.clear()                                 # blocks
	t.clear()                                 # background tiles
	p.clear()                                 # position Vector2's
	randomize()
	for r in range(Global.board.height):                         # rows
		b.append([])
		t.append([])
		p.append([])
		b[r].resize(Global.board.width)
		t[r].resize(Global.board.width)
		p[r].resize(Global.board.width)
		for c in range(Global.board.width):                      # columns
			b[r][c] = blk.instance()
			t[r][c] = res_backgroundtile.instance()
			add_child( b[r][c] )
			add_child( t[r][c] )
			b[r][c].position.x = Global.offset + (c * Global.grid)
			b[r][c].position.y = Global.offset + (r * Global.grid)
			t[r][c].position   = b[r][c].position
			p[r][c]            = b[r][c].position
			
			configure_block(r, c)

	# check/clear newly generated board for matches
	var nrloops=0
	while findmatch() != 0 :
		nrloops +=1
		for r in range(Global.board.height):
			for c in range(Global.board.width):
				if ( _fmvalid(r,c) ):
					if b[r][c].get_match() :
						b[r][c].clear_match()
					b[r][c].set_blockcolor( givenewblock() )

	if db: print("Createboard nrloops done:"+ str(nrloops) )

	Global.node_scoreboard.update()          # update scoreboard with new level info
	nroftilesonboard()                       # update's scoreboard with tile info

	# check for Tutorial messages for this level loaded
	if Global.board.tutorial.enabled :
		var textbubble = res_textbubble.instance()
		textbubble.position = p[5][4]
		self.add_child(textbubble)
		textbubble.set_text(Global.board.tutorial.text,"normal", 4, 0)

		if Global.board.tutorial.has("text1") :
			var textbubble1 = res_textbubble.instance()
			textbubble1.position = p[6][4]
			self.add_child(textbubble1)
			textbubble1.set_text(Global.board.tutorial.text1,"normal", 4, 8)
	
#------------------------------------------------------------------------------
# called by _create_new_board()
func configure_block(r, c):

	if Global.node_levels.border[r][c] == 0:            # check Level config for stone Wall block
		b[r][c].set_blockcolor( givenewblock() )        # normal (NON WALL) block
		t[r][c].set_tiletype(TILETYPE.NORMAL)


	elif Global.node_levels.border[r][c] == 1:            # check Level config for stone Wall block
		b[r][c].set_blocktype(BLOCKTYPE.WALL)
		#t[r][c].set_tiletype(TILETYPE.NONE)

	elif Global.node_levels.border[r][c] == 2:          # check Level config for stone Wall block
		b[r][c].set_blocktype(BLOCKTYPE.BLANK)
		#t[r][c].set_tiletype(TILETYPE.NONE)
	else:
		print("ERROR configure_block() else")

	match Global.node_levels.layer[r][c] :             #  check Level config for layers:
		0 :                                            # Normal block, no layer
			b[r][c].set_blocklayer(BLOCKLAYER.NONE)
		1 :                                             # Normal block, no layer
			b[r][c].set_blocklayer(BLOCKLAYER.NONE)
		2 :                                             # Ice over layer
			b[r][c].set_blocklayer(BLOCKLAYER.ICE)
		3 :                                             # Chain over layer
			b[r][c].set_blocklayer(BLOCKLAYER.CHAIN)
		4 :                                             # ChainS over layer
			b[r][c].set_blocklayer(BLOCKLAYER.CHAINS)
		5 :                                             # Bomb small over layer
			b[r][c].set_blocklayer(BLOCKLAYER.BOMBSMALL)
		6 :                                             # Bomb large over layer
			b[r][c].set_blocklayer(BLOCKLAYER.BOMBLARGE)
		7 :                                             # Lock
			b[r][c].set_blocklayer(BLOCKLAYER.LOCK)
		8 :                                             # Keyhole
			b[r][c].set_blocklayer(BLOCKLAYER.KEYHOLE)
		9 :                                             # Dice
			b[r][c].set_blocklayer(BLOCKLAYER.DICE)
		10:                                             # Clock
			b[r][c].set_blocklayer(BLOCKLAYER.CLOCK)
	return
#------------------------------------------------------------------------------
# Give a random normal block color , 1...NRUNIQUEBLOCKS , '0' is reserved
func givenewblock( ) -> int :
	return ( 1 + randi()%Global.board.uniqueblocks )

#------------------------------------------------------------------------------
func animateclrboard(s:String=""):
	s = "dropdown"
	if s == "":
		for r in range(Global.board.height):  
			for c in range(Global.board.width): 
				if ( b[r][c] is Node2D ):
					b[r][c].destroy("delay", (0.1 + (r*c*0.02))) 
					t[r][c].destroy("fade", 2 )

	elif s == "dropdown" :
		var dropdelay
		for r in range(Global.board.height-1, -1, -1):
			dropdelay = ( Global.board.height - r )  *  0.05
			for c in range(Global.board.width): 
				if ( b[r][c] is Node2D ):
					b[r][c].destroy("dropdown", dropdelay + rand_range(0.0, 0.6)  )
					t[r][c].destroy("fade", 2 )

#------------------------------------------------------------------------------
# scan wholeboard and mark blocks that are match3 with set_match()
# tag:bool  true  -> mark blocks for destruction   
# tag:bool  false -> just count matches
func findmatch( tag:bool = true ):
	
	var scorecard = []                    # locations for score popup text
	var matchcount: int = 0
	for r in range(Global.board.height):               # check all rows for HORIZONTAL matches
		for c in range(1, Global.board.width-1):        # check Column, one block away from edge
			if ( ( _fmvalid(r,c) ) and ( _fmvalid(r,c-1) ) and ( _fmvalid(r,c+1) ) ):
				if ( b[r][c].get_blockcolor() == b[r][c-1].get_blockcolor() ) and ( b[r][c].get_blockcolor() == b[r][c+1].get_blockcolor() ):
					if tag:
						b[r][c].set_match()
						b[r][c+1].set_match()
						b[r][c-1].set_match()
						scorecard.append( p[r][c] )
						scorecard.append( p[r][c+1] )
						scorecard.append( p[r][c-1] )
					matchcount +=1
				
	for r in range(1, Global.board.height-1):          # check rows, one block away from edge
		for c in range(Global.board.width):            # check Column for Vertical matches
			if ( ( _fmvalid(r,c) ) and ( _fmvalid(r+1,c) ) and ( _fmvalid(r-1,c) ) ):
				if ( chforkeymatches() ):                     # check if key is on top of keyhole
					matchcount +=1
				if ( b[r][c].get_blockcolor() == b[r+1][c].get_blockcolor() ) and ( b[r][c].get_blockcolor() == b[r-1][c].get_blockcolor() ):
					if tag:
						b[r][c].set_match()
						b[r-1][c].set_match()
						b[r+1][c].set_match()
						scorecard.append( p[r][c] )
						scorecard.append( p[r-1][c] )
						scorecard.append( p[r+1][c] )
					matchcount +=1
	
	if tag and (fsm != NEWBOARD):
		chkfordiceclockandsetmatches()            # check for matches on Dice
		scanboardwithbombmatches()           # check for matches on Bombs
	
	if tag and (fsm != NEWBOARD):
		for nr in scorecard.size():
			var balloon = res_floatingtext.instance()
			balloon.position = scorecard[nr]
			balloon.amount = 50
			Global.node_creation_parent.add_child(balloon) 

#	if db and (matchcount >= 8) :
#		var cba = ___copyblockarray()
#		var cma = ___copymatcharray()
##		Global.node_matchfinder.print_array( cba )
#		Global.node_matchfinder.print_array( cma )
#		Global.node_matchfinder.print_array( Global.node_matchfinder.maskarray(cba, cma) )
#		var ccma = cma.duplicate(true)
#		Global.node_matchfinder.print_array( Global.node_matchfinder.integrate(ccma,"ver") )
#		ccma = cma.duplicate(true)
#		Global.node_matchfinder.print_array( Global.node_matchfinder.integrate(ccma,"hor") )

	return ( matchcount )
#------------------------------------------------------------------------------
# test if a block is a normal movable block
func _fmvalid(r,c) -> bool :

	if not ( b[r][c] is Node2D ): return ( false );
	
	var blkinfo = b[r][c].get_blocktype()
	match blkinfo :
		BLOCKTYPE.NORMAL: return ( true )
		BLOCKTYPE.WALL:   return ( false);
		BLOCKTYPE.BLANK:  return ( false);
		BLOCKTYPE.BOMB:   return ( false);
		BLOCKTYPE.KEY:    return ( false);
	return(false)

#------------------------------------------------------------------------------
func scanboardwithbombmatches():
	var newmatchesset = true
	while newmatchesset :
		newmatchesset = false
		for r in range(Global.board.height):    
			for c in range( Global.board.width): 
				if chforbombandsetmatches(r,c):
					if ( newmatchesset == false ):   # set once, forces redo of while-loop 
						newmatchesset = true

#---------------------------------------------
# check for bomb (type) layers and set matcheS 
func chforbombandsetmatches(r,c):
	var flagmatchset:  bool = false
	
	if b[r][c].get_match() == false :        # check if block has been marked for destruction
		return ( false )
	
	var blkinfo  = b[r][c].get_blocklayer()
	match blkinfo :                          # check if marked block has bomb layer
		BLOCKLAYER.BOMBSMALL :
			Global.instance_node( res_bombexplosion, p[r][c], Global.node_creation_parent )
			var arrayofmatches = [ Vector2(r+1,c), Vector2(r-1,c), Vector2(r,c+1), Vector2(r,c-1) ]
			for nr in range( arrayofmatches.size() ) :
				var rr = arrayofmatches[nr].x
				var cc = arrayofmatches[nr].y
				if ( rr >= 0 )and( rr < Global.board.height )and( cc >= 0 )and( cc < Global.board.width  ):
					if ( _fmvalid(rr ,cc ) ):
						if b[rr][cc].get_match() == false :
							b[rr][cc].set_match()
							flagmatchset = true
			
		BLOCKLAYER.BOMBLARGE :
			Global.instance_node( res_bombexplosion, p[r][c], Global.node_creation_parent )
			var arrayofmatches = [ Vector2(r,c+1), Vector2(r+1,c+1), Vector2(r+1,c), Vector2(r+1,c-1), Vector2(r,c-1) ,Vector2(r-1,c-1) , Vector2(r-1,c), Vector2(r-1,c+1) ]
			for nr in range( arrayofmatches.size() ) :
				var rr = arrayofmatches[nr].x
				var cc = arrayofmatches[nr].y
				if ( rr >= 0 )and( rr < Global.board.height )and( cc >= 0 )and( cc < Global.board.width  ):
					if ( _fmvalid(rr ,cc ) ):
						if b[rr][cc].get_match() == false :
							b[rr][cc].set_match()
							#print( str(rr)+" "+str(cc) )
							flagmatchset = true

	return ( flagmatchset )

#---------------------------------------------
# Check for matches on DICE and randomly set 4 normal none layered blocks for destuction
# Check for matches on CLOCK and add time to players countdown timer
func chkfordiceclockandsetmatches():
	var arrayofmatches:PoolVector2Array
	for r in range(Global.board.height):    
		for c in range( Global.board.width): 
			# check for DICE blocks
			if ( b[r][c].get_blocklayer() == BLOCKLAYER.DICE )and( b[r][c].get_match() ):
				var cnt = 4                   # destroy 4 random blocks on board
				# holds [0] pos of dice, [1,2,3,4] pos of dice destroyed
				arrayofmatches = [ p[r][c] ]
				while cnt:
					var rr = randi()%Global.board.height
					var cc = randi()%Global.board.width
					if ( _fmvalid(rr ,cc ) ):
						if ( b[rr][cc].get_blocklayer() == BLOCKLAYER.NONE ):
							if b[rr][cc].get_match() == false :
								b[rr][cc].set_match()
								arrayofmatches.append( p[rr][cc] )
								cnt -= 1
			# check for CLOCK blocks
			if ( b[r][c].get_blocklayer() == BLOCKLAYER.CLOCK )and( b[r][c].get_match() ):
				var balloon = res_floatingtext.instance()
				balloon.position = p[r][c]
				balloon.amount = "Extra Time"
				balloon.moveto = Global.RISINGSUN_POS       #position RisingSun
				balloon.delay  =  3
				Global.node_creation_parent.add_child(balloon)
				Global.node_scoreboard.add_time("delay", 3)

	if arrayofmatches.size() == 5:
		Global.instance_node(res_dicerays, Vector2(0,0), self )
		Global.node_dicerays.points = arrayofmatches
		#Global.node_dicerays.set_fade(5)
		Global.node_dicerays.start()
	
#------------------------------------------------------------------------------
# check if a key hits a keyhole
func chforkeymatches() -> bool:
	for r in range(Global.board.height-1):             # check all rows
		for c in range(Global.board.width):            # check Columns
			if ( b[r][c] is Node2D ) and( b[r+1][c] is Node2D ) :
				if b[r][c].get_blocktype() == BLOCKTYPE.KEY :
					if b[r+1][c].get_blocklayer() == BLOCKLAYER.KEYHOLE :
						b[r][c].set_match()
						print("Key Hit Keyhole")  # do something !
						gameprogress.endoflevelreached = true
						return ( true )
					elif b[r+1][c].get_blocktype() == BLOCKTYPE.WALL :
						b[r][c].set_match()
						print("Key hit Wall")
						return ( true )
	return ( false )

#------------------------------------------------------------------------------
func nrofkeysonboard() -> int:
	var matchcount = 0
	for r in range(Global.board.height):               # check all rows
		for c in range(Global.board.width):            # check Columns
			if ( b[r][c] is Node2D )  :
				if b[r][c].get_blocktype() == BLOCKTYPE.KEY :
					matchcount += 1
	return ( matchcount )

#------------------------------------------------------------------------------
# count nr of un-hit tiles on board , background_tile.gd
func nroftilesonboard(attention:bool = false) -> int:
	var matchcount = 0
	var arrayofmatches:Array

	if gameprogress.hitalltiles :                      # all tiles have been hit
		return ( 0 )

	for r in range(Global.board.height):               # check all rows
		for c in range(Global.board.width):            # check Columns
			if ( t[r][c] is Node2D )  :
				if t[r][c].get_tiletype() == TILETYPE.NORMAL :
					if t[r][c].get_hitcount() != 0:
						arrayofmatches.append( Vector2(r,c) )
						matchcount += 1

	Global.node_scoreboard.update_hittiles(matchcount)

	if attention :
		if ( matchcount >= 1 )and( matchcount <= 9 ) :
			var v:Vector2
			while not arrayofmatches.empty() :
				v = arrayofmatches.pop_back()
				if v != null :
					t[v.x][v.y].get_attention()   # make last 1 to 3 un-hit tile's catch attention

	if matchcount  == 0 :            # check of ALL tiles are 'hit'
		gameprogress.hitalltiles = true
		if db:print("all tiles hit")

	return ( matchcount )

#------------------------------------------------------------------------------
# test if a location is empty aka has no object in
func _tst_empty(r,c) -> bool : 
	return ( not ( b[r][c] is Node2D ) )

# test if a location has an Node2D object
func _tst_not_empty(r,c) -> bool : 
	return ( b[r][c] is Node2D )

#------------------------------------------------------------------------------
# destroy block that have been flagged with set_match()
# blocks with layers icing, chains will be processed.
func destroyblocks() -> int :
	var matchcount: int = 0
	for r in range(Global.board.height):
		for c in range(Global.board.width):
			if ( _tst_not_empty(r,c) ) :
				if b[r][c].get_match() :
					if ( __db_layercheck( r, c) ):         # if ice,chain,chains layer on top of block ?
						b[r][c].clear_match()              #    do not destroy  
					elif ( b[r][c].destroy() == false ):
						print("destroyblocks() destroy error rc:" +str(r)+str(c) + " animation:" + str( b[r][c].get_animated() ) ) ;
					else:
						t[r][c].set_hit()
						emit_signal("sig_blockselfdestruct", b[r][c].get_blockcolor() )            #CODECHANGE
						# done in blk.gd Global.instance_node(res_explodeblock, p[r][c], self)
						matchcount +=1
	
	print("destroyblocks:"+str(matchcount) )
	return (matchcount)                                 # nr of blocks destroyed
#----------------------------
func __db_layercheck( r, c):
	var blkinfo  = b[r][c].get_blocklayer()
	match blkinfo :
		BLOCKLAYER.ICE       :   
			b[r][c].set_blocklayer(BLOCKLAYER.NONE)
			return ( true )
		BLOCKLAYER.CHAIN     :
			b[r][c].set_blocklayer(BLOCKLAYER.NONE)
			return ( true )
		BLOCKLAYER.CHAINS    :
			b[r][c].set_blocklayer(BLOCKLAYER.CHAIN)
			return ( true )
		BLOCKLAYER.BOMBSMALL : return ( false ) ;
		BLOCKLAYER.BOMBLARGE : return ( false ) ;
		BLOCKLAYER.LOCK      : return ( false ) ;
		BLOCKLAYER.KEYHOLE   : return ( true  ) ;
		BLOCKLAYER.DICE      : return ( false ) ;
		BLOCKLAYER.CLOCK     : return ( false ) ;
		
	return ( false )

#------------------------------------------------------------------------------

func findunsuportedblock() -> bool :
	for r in range(Global.board.height-2, -1, -1):   # start at row above bottom-row til row 0
		for c in range(Global.board.width):
			if ( _tst_not_empty(r,c) )and( _tst_empty(r+1,c)  ):
				dropblock(r, c )
				return(true)
			if ( r==0 )and( _tst_empty(r,c) ):        # at top row, generate new blocks
				dropblock(0 , c )
				return(true)
	return (false)

#------------------------------------------------------------------------------
# dropblock()  r is where unsuported block is,  or r=0 if top row
func dropblock(r:int, c:int ): # new:bool=false):
	if ( r==0 )and( _tst_empty(r,c) ):#- - - - - - - - - - Add New blocks at top!, does not run when toprow is WALL !
		if ( _tst_empty(r,c)  )and( _tst_empty(0,c) ) :
			r = count_empty_blocks_below(0,c)
			for nr in range(r, -1, -1):
				#print("dropblock(,,true) r" + str(nr))
				b[nr][c] = blk.instance()
				b[nr][c].set_animated(true)
				b[nr][c].position   = p[0][c]   # should be above board, now starts at top cel. tricked Tween begin pos
				add_child(b[nr][c])
				if ( rand_bool(2.5) )and( nrofkeysonboard() <= Global.board.maxkeys ) :   # add % of blocks as keys 
					b[nr][c].set_blocktype(BLOCKTYPE.KEY)                               # add key
				else:
					b[nr][c].set_blockcolor( givenewblock() )
					if ( rand_bool( Global.board.newicepct  ) ):
						b[nr][c].set_blocklayer(BLOCKLAYER.ICE) 
					if ( rand_bool(Global.board.newbombpct  ) ):
						b[nr][c].set_blocklayer(BLOCKLAYER.BOMBSMALL) 
					if ( rand_bool(Global.board.newdicepct  ) ):
						b[nr][c].set_blocklayer(BLOCKLAYER.DICE) 
					if ( rand_bool(Global.board.newclockpct ) ):
						b[nr][c].set_blocklayer(BLOCKLAYER.CLOCK) 

				$Tween.interpolate_property( b[nr][c], "position", p[0][c]+Vector2(0,-80), p[nr][c], 0.6, Tween.TRANS_BOUNCE,Tween.EASE_OUT )
			$Tween.start()

	else :     #- - - - - - - - - - - - - - - - - - - - - Drop blocks
		var ebb = count_empty_blocks_below(r,c)
		if ( _tst_not_empty(r,c) )and( _tst_empty(r+ebb,c)  ):
			#print("ebb:"+str(ebb)+" r")
			b[r+ebb][c] = blk.instance()
			b[r+ebb][c].position = p[r][c]
			add_child(b[r+ebb][c])
			
			if b[r][c].get_blocktype() == BLOCKTYPE.WALL :             # if block == stone, add new block
				#if ( rand_bool(10) and nrofkeysonboard() < Global.board.maxkeys ):    # add % of blocks as keys 
				#	b[r+ebb][c].set_blocktype(BLOCKTYPE.KEY)
				#else:
				b[r+ebb][c].set_blockcolor( givenewblock() )
					# add here optional layers..
					
			else:
				if b[r][c].get_blocktype() == BLOCKTYPE.NORMAL :
					b[r+ebb][c].set_blockcolor( b[r][c].get_blockcolor() )
				else:
					b[r+ebb][c].set_blocktype( b[r][c].get_blocktype()  )
				
				b[r+ebb][c].set_blocklayer( b[r][c].get_blocklayer() )      # copy (ice,chain,...) layer info
			
				if ( b[r][c].destroy() == false ):
					print("dropblock destroy error rc:" +str(r)+str(c)+" ebb=" +str(ebb) +" blocktype:" + str(b[r][c].get_blocktype()));

				
			b[r+ebb][c].set_animated(true)
			$Tween.interpolate_property( b[r+ebb][c]  , "position", p[r][c] , p[r+ebb][c] ,0.6 ,Tween.TRANS_BOUNCE,Tween.EASE_OUT )
			$Tween.start()

#------------------------------------------------------------------------------
# count empty blocks below
func count_empty_blocks_below(r:int,c:int)-> int:
	if (r == Global.board.height-1): return (0)
	var answ = 0       # return value
	for nr in range(r+1, Global.board.height ):  # row+1, row+2, ... height
		if ( _tst_empty(nr , c) ):
			answ += 1
		else:
			return (answ)
	return(answ)

#------------------------------------------------------------------------------
# swap two block positions and animate the movement
func swapblocks(loc:Vector2, dir:String):

	var r  : int  = int( round(loc.y) )         # rows
	var c  : int  = int( round(loc.x) )         # column
	var tr : int                                # target row
	var tc : int                                # target column
	var blkinfo                                 # holds get_blocktype() get_blocklayer() result
	
	if ( r > Global.board.height ) or ( c > Global.board.width ):
		print("ERROR swapblocks vec out of range")
		return
	
	if ( _tst_empty(r,c) ) :   # if mouse_down cell empty, skip handling
		return
	
	blkinfo = b[r][c].get_blocktype()
	match blkinfo :
		BLOCKTYPE.WALL:  return ;
		BLOCKTYPE.BLANK: return ;
		BLOCKTYPE.BOMB:  return ;
		#BLOCKTYPE.KEY:  return ;

	blkinfo  = b[r][c].get_blocklayer()
	match blkinfo :
		BLOCKLAYER.ICE       : return  ;
		BLOCKLAYER.CHAIN     : return  ;
		BLOCKLAYER.CHAINS    : return  ;
		BLOCKLAYER.BOMBSMALL : return  ;
		BLOCKLAYER.BOMBLARGE : return  ;
		BLOCKLAYER.LOCK      : return  ;
		#BLOCKLAYER.DICE      : return  ;
		#BLOCKLAYER.CLOCK     : return ;
		
	if ( b[r][c].get_animated() ): # cel is in animation,  skip handling
		return

	if    dir == "up":
		tr = r-1
		tc = c
	elif  dir == "down":
		tr = r+1
		tc = c
	elif  dir == "left":
		tr = r
		tc = c-1
	elif  dir == "right":
		tr = r
		tc = c+1
	else:
		print("error swapblocks dir string")
		return

	if ( _tst_empty(tr,tc)        ): # if cell empty, skip handling
		return
	if ( b[tr][tc].get_animated() ): # cel is in animation,  skip handling
		return

	blkinfo = b[tr][tc].get_blocktype()
	match blkinfo :
		BLOCKTYPE.WALL:  return ;
		BLOCKTYPE.BLANK: return;
		BLOCKTYPE.BOMB:  return ;
		#BLOCKTYPE.KEY:  return ;

	blkinfo  = b[tr][tc].get_blocklayer()
	match blkinfo :
		BLOCKLAYER.ICE       : return  ;
		BLOCKLAYER.CHAIN     : return  ;
		BLOCKLAYER.CHAINS    : return  ;
		BLOCKLAYER.BOMBSMALL : return  ;
		BLOCKLAYER.BOMBLARGE : return  ;
		BLOCKLAYER.LOCK      : return  ;
		#BLOCKLAYER.DICE      : return  ;
		#BLOCKLAYER.CLOCK     : return ;

	b[r][c].set_animated(true)
	b[tr][tc].set_animated(true)
	$Tween.interpolate_property( b[r][c]  , "position", p[r][c]   , p[tr][tc] ,BLK_ANI_SPEED ,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT )
	$Tween.interpolate_property( b[tr][tc], "position", p[tr][tc] , p[r][c]   ,BLK_ANI_SPEED ,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT )
	b.push_back( b[r][c] )												# swap array[][] positions
	b[r][c]   = b[tr][tc]
	b[tr][tc] = b.pop_back()
	
	if ( findmatch(false) == 0 ):    # no Match3, need to swapblocks back
			#add swapback animation
			$Tween.interpolate_property( b[r][c]  , "position", p[r][c]   , p[tr][tc] ,BLK_ANI_SPEED ,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT , BLK_ANI_SPEED)
			$Tween.interpolate_property( b[tr][tc], "position", p[tr][tc] , p[r][c]   ,BLK_ANI_SPEED ,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT , BLK_ANI_SPEED)
			b.push_back( b[r][c] )
			b[r][c]   = b[tr][tc]                                      # swap array[][] positions back
			b[tr][tc] = b.pop_back()
			Global.playsound("error")
			
	$Tween.start()                                                     # start block swapping animation
	Global.playsound("slide")
	if db: print("swapblock: "+ str(p[r][c])+" "+ str( p[tr][tc] ) )		

#------------------------------------------------------------------------------
func clear_animated():
	emit_signal("sig_clear_animated")

#------------------------------------------------------------------------------
# Give boolean true with certain percentage , 30 will give 30% of true
func rand_bool(percentagetrue:float = 50.0) -> bool:
	var f = clamp(percentagetrue, 0, 100) / 100.0      # 0  ..  0.5  ..  1.0
	if rand_range(0, 1) <= f :
		return (true)
	return (false)

#------------------------------------------------------------------------------
func _process(delta):

	$Label.text = "fsm:"+ str(fsm)   #debug

#	if not tmr_tick: 
#		return ;
#	tmr_tick = 1
		
	match fsm:
		INIT:     #----------------------------------- INIT
			fsm = NEWBOARD
		NEWBOARD: #----------------------------------- NEWBOARD
			_create_new_board()
			fsm = GAME
		GAME:     #----------------------------------- GAME

			if ( gameprogress.endoflevelreached == true ) :
				fsm = CLRBOARD
			else:
#				if ( userinputdetected.occured ):
#					userinputdetected.occured = false
#					swapblocks(userinputdetected.v, userinputdetected.s)

				if findmatch():
					fsm = MATCH
			
			if ( gameprogress.nomoremoves ) :
				pass
			if ( gameprogress.nomoretime ) :
				pass
			if ( gameprogress.hitalltiles ) :
				pass
			else :
				nroftilesonboard()


		MATCH:    #----------------------------------- MATCH
			if ( $Tween.is_active() == false ):
				#clear_animated() #needed?
				destroyblocks()
				fsm = COLLAPSE
		COLLAPSE: #----------------------------------- COLLAPSE

			if ( findunsuportedblock() == false) :
				fsm = GAME
		CLRBOARD: #----------------------------------- CLRBOARD
			if ( $Tween.is_active() == false ):
				animateclrboard()
				tmr_tick = 40            # 30x 100ms
				var balloon = res_floatingtext.instance()
				balloon.set_style("banner")
				balloon.amount = "New Level loading"
				Global.node_creation_parent.add_child(balloon) 
				fsm = NEXTLEVEL
		NEXTLEVEL:#----------------------------------- NEXTLEVEL
			if tmr_tick == 0:
				if ( Global.node_levels.set_next_level() == false ):
					print("No More New Levels, Starting Level 1 again")
					var balloon = res_floatingtext.instance()
					balloon.set_style("banner")
					balloon.amount = "No More New Levels"
					Global.node_creation_parent.add_child(balloon) 
					Global.node_levels.set_level(1)
					fsm = NEWBOARD
				else:
					fsm = NEWBOARD
		IDLE:     #----------------------------------- IDLE
			pass
		_   :     #----------------------------------- catchall
			print("Undef fsm state")

#------------------------------------------------------------------------------
func _sig_mouse_event(v,s):
	swapblocks(v, s)

#------------------------------------------------------------------------------
# signal received from mousehandler.gd that user has been inactive
func _sig_player_idle_event():

	if ( gameprogress.endoflevelreached == false )and( fsm == GAME ) :
		var nmm = Global.node_matchfinder.___find_moves( ___copyblockarray() , ___copylayerarray() ) 
		match int(nmm.z) :
			0 :
				var balloon = res_floatingtext.instance()
				balloon.set_style("banner")
				balloon.amount   = "No More Moves"
				Global.node_creation_parent.add_child(balloon) 
				gameprogress.nomoremoves = true
			1 : # nudge down
				b[nmm.x][nmm.y].nudgeblock( Vector2(0,1) )
				b[nmm.x+1][nmm.y].nudgeblock( Vector2(0,-1) )
			2 : # nudge right
				b[nmm.x][nmm.y].nudgeblock( Vector2(1,0) )
				b[nmm.x][nmm.y+1].nudgeblock( Vector2(-1,0) )
	
	nroftilesonboard(true)   # true => highlight, get attention of non hit tiles

#------------------------------------------------------------------------------
# signal received from scoreboard.gd that time has run out
func _sig_scoreboard_event(i):
	gameprogress.nomoretime = true

#------------------------------------------------------------------------------
func _on_Timer_timeout():
	if tmr_tick:  tmr_tick -= 1 ;
	
#------------------------------------------------------------------------------
func _on_Tween_tween_all_completed():
	print("Send sig_clear_animated")
	clear_animated()

#------------------------------------------------------------------------------
func _on_Button_Debug_pressed():
	gameprogress.endoflevelreached = true
	print("DEBUG .")

#------------------------------------------------------------------------------
# copy the b[][] array to a simplified va[][] with just (int) frame nr
func ___copyblockarray():
	var va:Array
	for r in range(Global.board.height):
		va.append([])
		va[r].resize(Global.board.width)
		for c in range(Global.board.width):
			if _tst_not_empty(r,c):
				if b[r][c].get_blocktype() == BLOCKTYPE.NORMAL :
					va[r][c] = int( b[r][c].get_blockcolor() )
				else:
					va[r][c] = 0
			else:
				va[r][c] = 0
	return ( va )

# copy info from the layers (ice,chains,lock,...) to simplified array
#  !!! can just Global.bode_level.layer.duplicate(true) !?
func ___copylayerarray():
	var va:Array
	for r in range(Global.board.height):
		va.append([])
		va[r].resize(Global.board.width)
		for c in range(Global.board.width):
			if _tst_not_empty(r,c):
				if b[r][c].get_blocklayer() != BLOCKLAYER.NONE :
					va[r][c] = int( b[r][c].get_blocklayer() )
				else:
					va[r][c] = 0
			else:
				va[r][c] = 0
	return ( va )

# creates array with matches found as '1',  no match '0'
func ___copymatcharray():
	var va:Array
	for r in range(Global.board.height):
		va.append([])
		va[r].resize(Global.board.width)
		for c in range(Global.board.width):
			va[r][c] = 0
			if _tst_not_empty(r,c) :
				if b[r][c].get_match():
					va[r][c] = 1
	return ( va )

#------------------------------------------------------------------------------


#==============================================================================
"""------------------------ Code Graveyard ------------------------------------

idea:
spawn in position
Fill from side with most blocks
fill from mouseswipe direction
kokeshi dolls

 row nr 0 :  5 1 4 3 6 4 2 5  8
 row nr 1 :  4 1 6 3 6 2 4 3  8
 row nr 2 :  5 1 2 5 6 4 5 5  8
 row nr 3 :  5 4 3 4 6 2 4 5  8
 row nr 4 :  6 6 4 6 2 4 4 5  8
 row nr 5 :  3 4 3 6 4 5 4 3  8
 row nr 6 :  3 6 6 3 6 1 5 2  8
		  :  7 7 7 7 7 7 7 7

 row nr 0 :  _ 1 _ _ 1 _ _ _  2
 row nr 1 :  _ 1 _ _ 1 _ _ _  2
 row nr 2 :  _ 1 _ _ 1 _ _ 1  3
 row nr 3 :  _ _ _ _ 1 _ 1 1  3
 row nr 4 :  _ _ _ _ _ _ 1 1  2
 row nr 5 :  _ _ _ _ _ _ 1 _  1
 row nr 6 :  _ _ _ _ _ _ _ _  0
		  :  0 3 0 0 4 0 3 3
 
 row nr 0 :  _ 1 _ _ 6 _ _ _  2
 row nr 1 :  _ 1 _ _ 6 _ _ _  2
 row nr 2 :  _ 1 _ _ 6 _ _ 5  3
 row nr 3 :  _ _ _ _ 6 _ 4 5  3
 row nr 4 :  _ _ _ _ _ _ 4 5  2
 row nr 5 :  _ _ _ _ _ _ 4 _  1
 row nr 6 :  _ _ _ _ _ _ _ _  0
		  :  0 3 0 0 4 0 3 3

--------------------------------------------------------------------------- """
