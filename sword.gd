extends CharacterBody2D

# Referencias
var player: Node2D
var player_position: Vector2

# Parámetros de órbita
@export var orbit_radius: float = 80.0  # Distancia de la órbita
@export var orbit_speed: float = 3.0    # Velocidad angular (radianes/segundo)
@export var follow_smooth: float = 0.15 # Suavidad del seguimiento (0-1, menor = más suave)

# Rotación visual
@export var rotation_speed: float = 6.0 # Velocidad de rotación cuando cambia dirección
@export var max_rotation_angle: float = PI  # Máximo ángulo de rotación (180 grados)

# Estado
var orbit_angle: float = 0.0
var target_position: Vector2
var last_player_direction: float = 0.0  # Última dirección del jugador (-1, 0, 1)
var target_rotation: float = 0.0  # Rotación objetivo
var is_player_in_air: bool = false  # Si el jugador está saltando/en aire
var rotation_active: bool = false  # Si está rotando actualmente

func _ready() -> void:
	# Buscar el nodo del jugador en el grupo "jugador"
	player = get_tree().get_first_node_in_group("jugador")
	
	if not player:
		push_error("No se encontró nodo en grupo 'jugador'. Asegúrate de añadir el jugador a este grupo.")
		return
	
	player_position = player.global_position
	target_position = global_position
	target_rotation = rotation

func _process(delta: float) -> void:
	if not player:
		return
	
	player_position = player.global_position
	
	# Seguimiento simple (sin órbita, solo sigue la posición)
	target_position = player_position
	
	# Seguimiento suave hacia la posición objetivo
	global_position = global_position.lerp(target_position, follow_smooth)
	
	# Detectar dirección del jugador y estado de aire
	_check_player_state()
	
	# Rotar solo cuando cambia de dirección o está en el aire
	_update_rotation(delta)

func _check_player_state() -> void:
	# Obtener velocidad del jugador
	if not player.is_in_group("jugador"):
		return
	
	var player_velocity = player.velocity if player.has_meta("velocity") or "velocity" in player else Vector2.ZERO
	
	# Detectar si el jugador está en aire (velocidad Y es diferente de 0)
	is_player_in_air = player_velocity.y != 0
	
	# Detectar cambio de dirección horizontal
	var current_direction: float = 0.0
	if player_velocity.x > 0.1:
		current_direction = 1.0
	elif player_velocity.x < -0.1:
		current_direction = -1.0
	
	# Si cambió de dirección, activar rotación
	if current_direction != 0.0 and current_direction != last_player_direction:
		rotation_active = true
		# Espada rota hacia la dirección del movimiento
		target_rotation = max_rotation_angle if current_direction > 0 else -max_rotation_angle
		last_player_direction = current_direction
	
	# También rotar si está en el aire
	if is_player_in_air:
		rotation_active = true

func _update_rotation(delta: float) -> void:
	if rotation_active:
		# Interpolar suavemente hacia la rotación objetivo
		rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)
		
		# Cuando se acerca al objetivo, desactivar la rotación
		if abs(rotation - target_rotation) < 0.05:
			rotation = target_rotation
			if not is_player_in_air:
				rotation_active = false

func _physics_process(delta: float) -> void:
	# Aquí puedes añadir física si la necesitas
	# Por ahora dejamos que sea puramente cinemático
	pass

# Función para cambiar el radio de seguimiento suavemente
func set_radius_smooth(new_radius: float, transition_time: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "orbit_radius", new_radius, transition_time)

# Función para cambiar velocidad de rotación
func set_rotation_speed(new_speed: float) -> void:
	rotation_speed = new_speed