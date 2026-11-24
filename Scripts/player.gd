extends CharacterBody2D

@onready var hook_scene = preload("res://Scenes/hook.tscn")
@onready var fishing_line = $FishingLine
@onready var biome_detector = $BiomeDetector

#ui
@onready var fish_label = $"Fishlbl"

var current_hook = null


# casting
var is_charging = false
var charge_time = 0.0

@export var max_charge_time = 1.5
@export var min_hook_speed = 100
@export var max_hook_speed = 500


# reeling

@export var reel_speed = 400.0
var reel_target_active = false


# Rope stuff

var rope_length = 0.0
@export var max_rope_length = 600.0

var rope_hit_point = Vector2.INF
var rope_hit_locked = false


# Biome

var current_biome = "lake"
var last_biome = ""


# Bite on the hook

var bite_message_shown = false



# Main stuff

func _process(delta):

	FishingManager.update(delta)

	update_biome()

	if FishingManager.fish_hooked and !bite_message_shown:

		bite_message_shown = true

		fish_label.text = "Something is biting!"
		fish_label.modulate = Color.RED

	
	# Casting
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):

		is_charging = true
		charge_time += delta
		charge_time = min(charge_time, max_charge_time)

	elif is_charging:

		is_charging = false
		shoot(charge_time)
		charge_time = 0.0

	
	# Reelingstarts
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):

		if !reel_target_active:
			reel_target_active = true

	
	# Reel in hook
	
	if reel_target_active and current_hook != null and is_instance_valid(current_hook):

		current_hook.reel_locked = true
		current_hook.floating = false

		var dir = (global_position - current_hook.global_position).normalized()

		current_hook.global_position += dir * reel_speed * delta

	
	# Catch
	
	if current_hook != null and is_instance_valid(current_hook):

		if current_hook.global_position.distance_to(global_position) < 15:

			var fish = FishingManager.resolve_fish()

			if fish != null:

				fish_label.text = "You caught: " + fish
				fish_label.modulate = Color.WHITE

			current_hook.queue_free()
			current_hook = null

			reel_target_active = false

	
	# Cleanup
	
	if current_hook == null or !is_instance_valid(current_hook):
		reel_target_active = false

	
	# Fishing line updates
	
	update_fishing_line()



# BIOME DETECTION

func update_biome():

	for area in biome_detector.get_overlapping_areas():

		if area.is_in_group("biome_area"):

			current_biome = area.biome_name
			FishingManager.current_area = current_biome

			if current_biome != last_biome:

				last_biome = current_biome
				print("Now in :", current_biome)



# FISHING LINE
func update_fishing_line():

	if current_hook != null and is_instance_valid(current_hook):

		fishing_line.visible = true
		fishing_line.clear_points()

		var start = Vector2.ZERO
		var end = to_local(current_hook.global_position)

		var segments = 10
		var distance = start.distance_to(end)

		
		var sag_strength = clamp(distance * 0.04, 2, 10)

		for i in range(segments + 1):

			var t = float(i) / segments
			var point = start.lerp(end, t)

			
			var sag_factor = sin(t * PI)
			point.y += sag_factor * sag_strength

			fishing_line.add_point(point)

	else:

		fishing_line.visible = false
		fishing_line.clear_points()



# Shoot hook

func shoot(charge_amount):

	var dir = (get_global_mouse_position() - global_position).normalized()

	var t = charge_amount / max_charge_time
	var speed = lerp(min_hook_speed, max_hook_speed, t)

	if current_hook != null and is_instance_valid(current_hook):
		current_hook.queue_free()

	var hook_instance = hook_scene.instantiate()

	hook_instance.global_position = global_position + dir * 20
	hook_instance.velocity = dir * speed

	hook_instance.attached = false
	hook_instance.reel_locked = false

	get_parent().add_child(hook_instance)

	current_hook = hook_instance

	rope_length = max_rope_length
	rope_hit_point = Vector2.INF
	rope_hit_locked = false

	
	bite_message_shown = false
	fish_label.text = ""
	fish_label.modulate = Color.WHITE

	
	FishingManager.start_fishing()
