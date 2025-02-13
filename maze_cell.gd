class_name MazeCell
extends Node3D

@export var up:Node3D
@export var down:Node3D
@export var left:Node3D
@export var right:Node3D

var visited:bool = false
var backtrack:int = 0

const SET:int = 2
const BACKTRACK:int = 3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()


func reset() -> void:
	on(right)
	on(down)
	off(left)
	off(up)
	visited = false
	backtrack = 0


func off_right():
	off(right, false)


func off_down():
	off(down, false)


func seti(wat:Node3D, i:int, visit:bool=false) -> void:
	setw(wat, bool(i), visit)


func setw(wat:Node3D, value:bool=true, visit:bool=false):
	if visit:
		visited = true
	wat.visible = value
	_set_collisions(wat, value)


func on(wat:Node3D, visit:bool=true):
	setw(wat, true, visit)


func off(wat:Node3D, visit:bool=true):
	setw(wat, false, visit)


func iv(wat:Node3D) -> int:
	return int(wat.visible)
	#if wat.visible:
		#return 1
	#return 0


func _set_collisions(node:Node, value:bool=false) -> void:
	if node is CollisionShape3D:
		node.disabled = value
	for kid in node.get_children():
		_set_collisions(kid, value)
