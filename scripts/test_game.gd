extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ids = []
onready var enemy = preload("res://scenes/enemy.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _process_data(data):
	print("got data is :",data)

func start_game():
	for id in ids:
		var inst = enemy.instance()
		inst.global_transform = $Node2D/KinematicBody2D.global_transform
		inst.name = id
		
