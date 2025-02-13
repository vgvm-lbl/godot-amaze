extends Node3D

@export var amaze:Amaze

func _ready() -> void:
	amaze.makeRoom(4, 4, 8, 6)
	amaze.get_cell(4, 4).visited = false # this will let the maze carve into the room
	amaze.build()
