extends CharacterBody2D

# Referencias
var player: Node2D

# Parámetros de seguimiento
@export var follow_smooth: float = 0.12

# Parámetros de rotación
@export var rotation_speed: float = 8.0
@export var max_rotation_angle: float = PI

# Estado
var target_position: Vector2
var last_player_direction: float = 0.0
var target_rotation: float = 0.0
var is_player_in_air: bool = false
var rotation_active: bool = false

func _ready() -> void:
	player = get_parent().get_node("player")
	
	if not player:
		push_error("No se encontró nodo 'player' en la escena padre.")
		return
	
	target_position = global_position
	target_rotation = rotation

func _process(delta: float) -> void:
	if not player:
		return
	
	target_position = player.global_position
	global_position = global_position.lerp(target_position, follow_smooth)
	
	_update_player_state()
	_update_rotation(delta)

func _update_player_state() -> void:
	var player_velocity = player.velocity
	
	is_player_in_air = not player.is_on_floor()
	
	var current_direction: float = 0.0
	if player_velocity.x > 0.1:
		current_direction = 1.0
	elif player_velocity.x < -0.1:
		current_direction = -1.0
	
	if current_direction != 0.0 and current_direction != last_player_direction:
		rotation_active = true
		target_rotation = max_rotation_angle if current_direction > 0 else -max_rotation_angle
		last_player_direction = current_direction
	
	if is_player_in_air:
		rotation_active = true

func _update_rotation(delta: float) -> void:
	if rotation_active:
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
		
		if abs(rotation - target_rotation) < 0.05 and not is_player_in_air:
			rotation = target_rotation
			rotation_active = false

func _physics_process(_delta: float) -> void:
	pass
