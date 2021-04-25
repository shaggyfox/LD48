extends Control


# Declare member variables here. Examples:
# var a = 2
var text = null


# Called when the node enters the scene tree for the first time.

func _ready():
	if (text):
		$Panel/endgametext.set("text", text)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	root.remove_child(current_scene)
	current_scene.call_deferred("free")
	var world_rsc = load("res://World.tscn")
	var world = world_rsc.instance()
	root.add_child(world)
	pass # Replace with function body.


func _on_Button3_pressed():
	get_tree().quit();
	pass # Replace with function body.
