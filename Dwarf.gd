extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal player_death
signal player_finish

var points = 0

signal update_points(point_value)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
enum {NONE = 0, UP = 1, DOWN = 2, LEFT = 4, RIGHT = 8, HACK = 16}
var primary_key = NONE
var secondary_key = NONE
var pressed_keys = NONE
var old_keys = 0
var look_direction = LEFT;
var is_running = 0
var is_hacking = 0
var direction = "left"

var tilemap : TileMap = null

func set_tilemap(map):
	tilemap = map
	
func hack(direction):
	var new_animation = "hack_" +  direction
	if new_animation != $AnimationPlayer.current_animation:
		$AnimationPlayer.play("hack_" + direction)

func idle(direction):
	var new_animation = "idle_" + direction
	if new_animation != $AnimationPlayer.current_animation:
		$AnimationPlayer.play("idle_" + direction )
		
func run(direction):
	var new_animation = "run_" + direction
	if new_animation != $AnimationPlayer.current_animation:
		$AnimationPlayer.play(new_animation)


var current_destination_x = 0
var current_destination_y = 0
var current_direction = null
var current_position_x = 0
var current_position_y = 0
var last_direction = "left"
var hack_delta = 0

func set_grid_position(x, y):
	position.x = x * 32
	position.y = y * 32
	current_position_x = x
	current_position_y = y
	current_destination_x = x
	current_destination_y = y

var my_speed = 32.0 + 15.0
func _process(delta):
	
	
	if current_direction:
		current_position_x = position.x / 32.0
		current_position_y = position.y / 32.0
	var destination_cell = -1
	if 1 == tilemap.get_cell(floor(current_position_x + .5), floor(current_position_y +.5)):
		emit_signal("player_death")
	if 7 == tilemap.get_cell(floor(current_position_x + .5), floor(current_position_y + .5)):
		emit_signal("player_finish")
	if current_position_y < 0:
		emit_signal("player_death")
		
	if current_direction:
		destination_cell = tilemap.get_cell(current_destination_x, current_destination_y)
	if current_direction and -1 != destination_cell and 1 != destination_cell and 7 != destination_cell:
		hack(current_direction)
		hack_delta += delta
		if (destination_cell == 5 or destination_cell == 6 or destination_cell == 0 and hack_delta >= 0.2 or hack_delta >= 3):
			if destination_cell == 3:
				tilemap.set_cell(current_destination_x, current_destination_y, 5)
			elif destination_cell == 4:
				tilemap.set_cell(current_destination_x, current_destination_y, 6)
			else:
				tilemap.set_cell(current_destination_x, current_destination_y, -1)
			if destination_cell == 0:
				$snd_gravel.play()
			elif destination_cell == 2 or destination_cell == 3 or destination_cell == 4:
				$snd_crumble.play()
			elif destination_cell == 5:
				points += 1
				emit_signal("update_points", points)
				$snd_pling.play()
			elif destination_cell == 6:
				points += 1
				emit_signal("update_points", points)
				$snd_pling.play()
			hack_delta = 0
			current_destination_x = current_position_x
			current_destination_y = current_position_y
			
	else:
		match current_direction:
			"up":
				position.y -= my_speed * delta
				current_position_y = position.y / 32.0
				if current_position_y <= current_destination_y:
					last_direction = current_direction
					current_direction = null;
					current_position_y = current_destination_y
					position.y = current_position_y * 32
				else:
					run(current_direction)
				pass
			"down":
				position.y += my_speed * delta
				current_position_y = position.y /32.0
				if current_position_y >= current_destination_y:
					last_direction = current_direction
					current_direction = null
					current_position_y = current_destination_y
					position.y = current_position_y * 32
				else:
					run(current_direction)
				pass
			"left":
				position.x -= my_speed * delta
				current_position_y = position.y / 32.0
				if current_position_x <= current_destination_x:
					last_direction = current_direction
					current_direction = null
					current_position_x = current_destination_x
					position.x = current_position_x * 32
				else:
					run(current_direction)
				pass
			"right":
				position.x += my_speed * delta
				if current_position_x >= current_destination_x:
					last_direction = current_direction
					current_direction = null
					current_position_x = current_destination_x
					position.x = current_position_x * 32
				else:
					run(current_direction)
				pass
			null:
				idle(last_direction)
		
	
	
	
	var keys = [{ "action" : "ui_up", "key" : UP},
				{ "action" : "ui_down", "key" : DOWN},
				{ "action" : "ui_left", "key" : LEFT},
				{ "action" : "ui_right", "key" : RIGHT},
				{ "action" : "ui_accept", "key" : HACK}]
	for k in keys:
		var action = k["action"]
		var key = k["key"]
		if (Input.is_action_pressed(action)):
			if not pressed_keys & key:
				secondary_key = primary_key
				primary_key = key
				pressed_keys |= key
		else:
			if pressed_keys & key:
				pressed_keys &= ~key
				if (secondary_key == key):
					secondary_key = NONE
				if (primary_key == key):
					primary_key = secondary_key
	var new_x = 0
	var new_y = 0
	match primary_key:
		NONE:
			direction = null
		UP:
			if current_position_y > 0:
				direction = "up"
				new_y = -1
			else:
				direction = null
		DOWN:
			if current_position_y < 11:
				direction = "down"
				new_y = 1
			else:
				direction = null
		LEFT:
			if current_position_x > 0:
				direction = "left"
				new_x = -1
			else:
				direction = null
		RIGHT:
			if current_position_x < 19:
				direction = "right"
				new_x = 1
			else:
				direction = null

	if (current_direction == null && direction != null):
		current_direction = direction
		current_destination_x += new_x
		current_destination_y += new_y
	elif (current_direction == "up" and direction == "down" or
		  current_direction == "down" and direction == "up" or
		  current_direction == "left" and direction == "right" or
		  current_direction == "right" and direction == "left"):
		current_direction = direction
		current_destination_x += new_x
		current_destination_y += new_y
	elif destination_cell != -1 && current_direction && current_direction != direction && direction != null:
		match current_direction:
			"up":
				current_destination_y += 1
				pass
			"down":
				current_destination_y -= 1
				pass
			"left":
				current_destination_x += 1
				pass
			"right":
				current_destination_x -= 1
				pass
		current_direction = direction

func _on_AnimationPlayer_animation_changed(old_name, new_name):
	print("animation changed")
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	print("animatian finish")
	pass # Replace with function body.


func _on_AnimationPlayer_animation_started(anim_name):
	print("animation start")
	pass # Replace with function body.
