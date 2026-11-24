extends Area2D

var velocity = Vector2.ZERO
var gravity_force = 500

var start_position = Vector2.ZERO

@export var max_distance = 200

#water level
@export var water_level = 303.0

var floating = false
var bob_time = 0.0
@export var bob_height = 4.0
@export var bob_speed = 2.0

var float_base_y = 0.0


var reel_locked = false
var attached = false


func _ready():
	start_position = global_position
	monitoring = true


func _process(delta):

	
	if attached:
		global_position = get_parent().global_position
		velocity = Vector2.ZERO
		return


	
	if reel_locked:
		return


	#floating bob
	if floating:

		bob_time += delta
		global_position.y = float_base_y + sin(bob_time * bob_speed) * bob_height
		global_position.x += velocity.x * delta
		return


	
	velocity.y += gravity_force * delta
	global_position += velocity * delta


	#water
	if global_position.y >= water_level:
		enter_water()


	#range of hook
	if global_position.distance_to(start_position) > max_distance:
		queue_free()


func enter_water():

	if floating:
		return

	floating = true
	float_base_y = water_level

	velocity = Vector2.ZERO


# collision
func _on_body_entered(body: Node2D) -> void:

	if floating:
		return

	velocity = Vector2.ZERO
