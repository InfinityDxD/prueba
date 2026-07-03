extends CharacterBody2D


func _physics_process(delta: float) -> void:
	
	if is_on_floor():
		velocity.y = 0
	else:
		velocity.y += 100 * delta
	move_and_slide()
	pass
