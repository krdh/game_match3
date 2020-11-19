extends Node2D

var tst= [ [ 0, 3, 4, 1, 4, 3, 2, 3, 0 ],
		   [ 0, 8, 2, 6, 2, 5, 1, 1, 0 ],
		   [ 0, 5, 5, 3, 3, 5, 1, 6, 0 ],
		   [ 0, 4, 8, 4, 2, 8, 3, 2, 0 ],
		   [ 0, 1, 2, 5, 0, 4, 5, 1, 0 ],
		   [ 0, 4, 2, 3, 8, 3, 8, 4, 0 ],
		   [ 0, 3, 5, 3, 2, 4, 1, 2, 0 ],
		   [ 0, 0, 5, 4, 6, 5, 3, 0, 0 ],
		   [ 0, 0, 0, 0, 0, 0, 0, 0, 0 ] ]


#------------------------------------------------------------------------------
func _ready():
	Global.node_matchfinder = self

func _exit_tree():
	Global.node_matchfinder = null

#------------------------------------------------------------------------------
# debug routine, prints array[][]
func print_array(va):
	var rcnt = 0
	var s = ""
	var ccnt = []
	for i in range(Global.board.width):
		ccnt.append(0)
		
	for r in range(Global.board.height):
		rcnt = 0
		for c in range(Global.board.width):
			if va[r][c] != 0 :
				s += " " + str(va[r][c]) 
				rcnt += 1
				ccnt[c] += 1
			else:
				s += " 0"
			if ( c == Global.board.width-1): # last element in c
				s += "  " + str(rcnt)           # print nr of hit in this row

		print(" row nr "+str(r)+" : " + s)
		s = ""

	s = ""
	for i in range(Global.board.width):
		s += " " + str(ccnt[i])
	print(    "          : " + s )
#------------------------------------------------------------------------------
# va is 'mask array'
func maskarray(va, vm) -> Array:
	for r in range(Global.board.height):
		for c in range(Global.board.width):
			if vm[r][c] == 0 :
				va[r][c] = 0
	return ( va )
#------------------------------------------------------------------------------
# analysis of matches on board, finds groupings
func integrate(va, dir:String) -> Array:
	if "or" in dir :                            # strings: Hor horizontal horiz
		for r in range(Global.board.height):
			var sum = 0
			var t
			for c in range(Global.board.width):
				t   = va[r][c]                   #    t = va[][]  t=0 or t=1
				va[r][c] = (va[r][c] + sum) * t  #    va[][] = 0 or va[][] = va[][]+sum
				sum      = va[r][c]              #    sum = 0    or sum = va[][] 
	elif  "er" in dir :                          # ------------------------
		for c in range(Global.board.width):
			var sum = 0
			var t
			for r in range(Global.board.height):
				t   = va[r][c]                   #    t = va[][]  t=0 or t=1
				va[r][c] = (va[r][c] + sum) * t  #    va[][] = 0 or va[][] = va[][]+sum
				sum      = va[r][c]              #    sum = 0    or sum = va[][] 
	elif  "omb" in dir :                         #  combine? Hor and Ver result
		pass
	else:
		print("error integrate()")
	
	return ( va )
#------------------------------------------------------------------------------
# find a possible move, returns Vector3(row, column, hit)   hit=0 is no hit
# starts at the top-left, swipes down/right
#   ___find_moves(va:Array holds normal blocks, vl:Array holds layer info (ice chain etc)
func ___find_moves(va, vl) -> Vector3 :
	var t
														# moving block down
	for r in range(Global.board.height-1):              # check all rows-1 for HORIZONTAL matches
		for c in range(1, Global.board.width):          # check Column
			if ( vl[r][c] == 0 )and( vl[r+1][c] == 0 ): # check for 'layers' like ice,chains,...
				if ( va[r][c] != 0 )and( va[r+1][c] != 0 ):
					t = va[r][c]
					va[r][c] = va[r+1][c]
					va[r+1][c] = t
					if ( __findmatch(va) ) :    # hit
						return ( Vector3(r,c,1) )
					else:                       # no hit , swap back positions
						t = va[r][c]
						va[r][c] = va[r+1][c]
						va[r+1][c] = t
														# moving block right
	for r in range(Global.board.height):                # check all rows-1 for HORIZONTAL matches
		for c in range(1, Global.board.width-1):        # check Column
			if ( vl[r][c] == 0 )and( vl[r][c+1] == 0 ): # check for 'layers' like ice,chains,...
				if ( va[r][c] != 0)and( va[r][c+1] != 0 ):
					t = va[r][c]
					va[r][c] = va[r][c+1]
					va[r][c+1] = t
					if ( __findmatch(va) ) :    # hit
						return ( Vector3(r,c,2) )
					else:                       # no hit , swap back positions
						t = va[r][c]
						va[r][c] = va[r][c+1]
						va[r][c+1] = t

	return ( Vector3(0,0,0) )

#------------------------------------------------------------------------------
func __findmatch(va:Array):
	var matchcount: int = 0
	for r in range(Global.board.height):                # check all rows for HORIZONTAL matches
		for c in range(1, Global.board.width-1):        # check Column, one block away from edge
			if ( ( va[r][c] ) and ( va[r][c-1] ) and ( va[r][c+1] ) ):
				if ( va[r][c] == va[r][c-1] ) and ( va[r][c] == va[r][c+1] ):
					matchcount +=1
					return ( matchcount )
					
	for r in range(1, Global.board.height-1):          # check rows, one block away from edge
		for c in range(Global.board.width):            # check Column for Vertical matches
			if ( ( va[r][c] ) and ( va[r+1][c] ) and ( va[r-1][c] ) ):
				if ( va[r][c] == va[r+1][c] ) and ( va[r][c] == va[r-1][c] ):
					matchcount +=1
					return ( matchcount ) 
					
	return ( matchcount )
#------------------------------------------------------------------------------
func __findmatch5(va:Array):
	var matchcount: int = 0
	for r in range(Global.board.height):                # check all rows for HORIZONTAL matches
		for c in range(2, Global.board.width-2):        # check Column, two block away from edge
			if ( ( va[r][c] ) and ( va[r][c-1] ) and ( va[r][c+1] ) and ( va[r][c-2] ) and ( va[r][c+2] ) ):
				if ( va[r][c] == va[r][c-1] ) and ( va[r][c] == va[r][c+1] ) and ( va[r][c] == va[r][c-2] ) and ( va[r][c] == va[r][c+2] ) :
					matchcount +=1
					return ( Vector2(r,c) )
					
	for r in range(2, Global.board.height-2):          # check rows, two block away from edge
		for c in range(Global.board.width):            # check Column for Vertical matches
			if ( ( va[r][c] ) and ( va[r+1][c] ) and ( va[r-1][c] ) and ( va[r+2][c] ) and ( va[r-2][c] ) ):
				if ( va[r][c] == va[r+1][c] ) and ( va[r][c] == va[r-1][c] ) and ( va[r][c] == va[r+2][c] ) and ( va[r][c] == va[r-2][c] ) :
					matchcount +=1
					return ( Vector2(r,c) ) 
					
	return ( matchcount )
#==============================================================================
