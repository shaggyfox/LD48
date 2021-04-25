extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
var noisegen= null

func get_tile_from_noise(n):
	if n > 0:
	
		if n >= 0.75 and player_points >= 30:
			return 7
		if n > 0.60:
			return 4
		elif n > 0.55:
			return 3
		
		return 2
	else:
		return 0
var how_much_down = 0
var lava_level = 0
var player_points = 0
func _ready():
	$Timer.start()
	$BG1/LB1.set("text", "0/30")
	$TileMap/Dwarf.set_grid_position(10, 6)
	noisegen = OpenSimplexNoise.new()
	noisegen.period = 4
	randomize()
	noisegen.seed = randf() * 1000
	noisegen.octaves = 1
	noisegen.persistence = 0
	noisegen.lacunarity = 2
	lava_level = 0
	how_much_down = 0
	player_points = 0
	$TileMap/Dwarf.set_tilemap($TileMap)
	for y in range(13):
		for x in range(20):
			if y == 0:
				$TileMap.set_cell(x, y, 1)
			elif y < 7:
				$TileMap.set_cell(x, y, -1)
			else:
				$TileMap.set_cell(x, y, get_tile_from_noise(noisegen.get_noise_2d(x, y)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$TileMap.position.y -= delta * lava_level * 4
	if $TileMap.position.y <= -32:
		how_much_down += 1
		# erste zeile löschen
		for y in range (12):
			for x in range (20):
				var cell_value = $TileMap.get_cell(x, y + 1)
				$TileMap.set_cell(x, y, cell_value)
		for x in range (20):
			$TileMap.set_cell(x, 12, get_tile_from_noise(noisegen.get_noise_2d(x, 9 + how_much_down)))
		$TileMap.position.y += 32
		$TileMap/Dwarf.position.y -= 32;
		$TileMap/Dwarf.current_destination_y -= 1
		$TileMap/Dwarf.current_position_y -= 1
	pass


func _on_Timer_timeout():
	var array = []
	lava_level = 0
	for yy in range(13):
		for x in range(20):
			var y = 12 - yy
			if $TileMap.get_cell(x, y) == -1 and ($TileMap.get_cell(x -1, y) == 1 or $TileMap.get_cell(x +1, y) == 1 or $TileMap.get_cell(x, y -1) == 1 or $TileMap.get_cell(x, y + 1) == 1):
				array.append({"x" : x, "y" : y})
				if lava_level == 0:
					lava_level = y
				pass
	for a in array:
		$TileMap.set_cell(a["x"], a["y"], 1)
	pass # Replace with function body.


func _on_Dwarf_update_points(point_value):
	player_points = point_value
	$BG1/LB1.set("text", str(point_value) + "/30")
	pass # Replace with function body.

func back_to_title(text):
	var root = get_tree().get_root()
	var current_scene = root.get_child(root.get_child_count() - 1)
	root.remove_child(current_scene)
	current_scene.call_deferred("free")
	var menu_rsc = load("res://Menu.tscn")
	var menu = menu_rsc.instance()
	menu.text = text

	root.add_child(menu)

func _on_Dwarf_player_death():
	#var menu = load("res://Menu.tscn")
	#menu.text = "bla"
	#get_tree().change_scene_to(menu)
	back_to_title("You were killed by lava and have collected " + str(player_points) + " magic crystals")
	pass # Replace with function body.


func _on_Dwarf_player_finish():
	back_to_title("You escaped through the magic gate! Now you can enjoy your " + str(player_points - 30) + " extra chrystals!")
	pass # Replace with function body.
