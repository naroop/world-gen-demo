extends Area2D

var MAX_SPEED = 100
var ACCELERATION = 50
var FLOAT_AMPLITUDE = 0.02
var FLOAT_SPEED = 3

var player = null
var velocity = Vector2.ZERO
var isBeingPickedUp = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	spriteFloat()
		
	if isBeingPickedUp:
		var direction = global_position.direction_to(player.global_position)
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
		
		var distance = global_position.distance_to(player.global_position)
		if distance < 13:
			queue_free() # replace this with adding to inventory
			
		global_position += velocity
			
func spriteFloat():
	var y_offset = sin(Time.get_unix_time_from_system() * FLOAT_SPEED) * FLOAT_AMPLITUDE
	position.y += y_offset
	
func goToPlayer(body):
	player = body
	isBeingPickedUp = true

	
	
