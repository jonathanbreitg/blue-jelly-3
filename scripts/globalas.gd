extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var id = "-1"
var player_num = -1
var color = {"r":1.0, "g":1.0,"b":1.0}
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	color.r = rand_range(0.0,1.0)
	color.g = rand_range(0.0,1.0)
	color.b = rand_range(0.0,1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
