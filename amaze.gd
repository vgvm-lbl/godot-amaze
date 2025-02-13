class_name Amaze
extends Node3D

const CHARACTERS:Array = [' ','╶','╷','┌','╴','─','┐','┬','╵','└','│','├','┘','┴','┤','┼']

@export var width:int=13
@export var height:int=11
@export var start_x:int=1
@export var start_y:int=1
@export var build_on_load:bool=false
@export var maze_celler:PackedScene

var at_x:int = start_x
var at_y:int = start_y
var backtrack:int = 0

func _ready() -> void:
	_create()
	reset()
	if build_on_load:
		build()
		

func _create() -> void:
	var f:float = 1.5
	for x in range(width):
		var column:Node3D = Node3D.new()
		add_child(column)
		column.transform.origin = Vector3(x * f, 0, 0)
		if x == width - 1:
			column.visible = false # kinda nuts
		for y in range(height):
			var maze_cell:MazeCell = maze_celler.instantiate()
			column.add_child(maze_cell)
			maze_cell.transform.origin = Vector3(0, 0, y * f)
			if y == height - 1:
				maze_cell.visible = false
	pass


func inbounds(x:int, y:int) -> bool:
	return x > -1 and y > -1 and x < width and y < height


func get_cell(x:int, y:int) -> MazeCell:
	if inbounds(x, y):
		return get_child(x).get_child(y)
	return null


func get_cella(a:Array) -> MazeCell:
	return get_cell(a[0], a[1])


func reset() -> void:
	at_x = start_x
	at_y = start_y
	backtrack = 0
	var maxX = width - 1
	var maxY = height - 1
	for column in get_children():
		for cell in column.get_children():
			(cell as MazeCell).reset()

	# for left and right of map: set down to false
	for y in range(height):
		for x in [0,maxX]:
			var cell:MazeCell = get_cell(x, y)
			cell.off(cell.down)
	# for top and bottom of map: set right to false
	for x in range(width):
		for y in [0, maxY]:
			var cell:MazeCell = get_cell(x, y)
			cell.off(cell.right)
	pass


func build() -> void:
	for i in range(3 * width * height):
		if _iterate():
			print("Built after %d iterations" % [i])
			break
	_finalize()


func _iterate() -> bool:
	var cell:MazeCell = get_cell(at_x, at_y)
	cell.visited = true
	cell.backtrack = backtrack

	var neighbors = _neighbors(at_x, at_y)
	var possibilities = neighbors.filter(func(at): return not get_cella(at).visited)
	
	if possibilities.size():
		return _move(cell, possibilities.pick_random())
	
	# time to backtrack
	
	cell.backtrack = 0
	backtrack -= 1
	if not backtrack:
		print("done backtracking")
		return true

	var fck = []
	for neighbor in neighbors:
		var bt:int = get_cella(neighbor).backtrack
		if bt == backtrack:
			at_x = neighbor[0]
			at_y = neighbor[1]
			return false
		fck.append([neighbor, bt])
	print("can't backtrack from (%d, %d): %d vs %s" % [at_x, at_y, backtrack, fck])
	return true # nowhere else to go


func _move(cell:MazeCell, to:Array) -> bool:
	var nx:int = to[0]
	var ny:int = to[1]
	var next:MazeCell = get_cell(nx, ny)
	if nx < at_x:
		next.off_right()
	elif nx > at_x:
		cell.off_right()
	if ny < at_y:
		next.off_down()
	elif ny > at_y:
		cell.off_down()
	at_x = nx
	at_y = ny
	backtrack += 1
	return false


func _neighbors(x:int, y:int) -> Array:
	return [[x+1,y], [x-1,y], [x,y+1], [x,y-1]].filter(
		func(a): return inbounds(a[0], a[1])
	)


func _finalize() -> void:
	var s = ""
	for y in range(height - 1):
		for x in range(width - 1):
			var cc:MazeCell = get_cell(x, y)
			var cd:MazeCell = get_cell(x, y+1)
			var cr:MazeCell = get_cell(x+1, y)
			
			var u:int = cc.iv(cc.right)
			var l:int = cc.iv(cc.down)
			
			var d:int = cd.iv(cd.right)
			var r:int = cr.iv(cr.down)
			var lul:int = u * 8 + l * 4 + d * 2 + r
			
			cc.seti(cc.up, u)
			cc.seti(cc.left, l)
			cc.seti(cc.down, d)
			cc.seti(cc.right, r)
			
			var m:String = CHARACTERS[lul]
			s += m + ' ─'[r] 
		s += "\n"
	print(s)



func makeRoom(x:int, y:int, w:int, h:int, visit:bool = true):
	var r = x + w - 1
	var d = y + h - 1
	for a in range(x, x + w):
		for b in range(y, y +h):
			var cell:MazeCell = get_cell(a, b)
			if r == a:
				cell.on(cell.right, visit)
			else:
				cell.off(cell.right, visit)
			if d == b:
				cell.on(cell.down, visit)
			else:
				cell.off(cell.down, visit)
	pass
