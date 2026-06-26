extends CharacterBody2D

# Referencias
var player: Node2D
var player_position: Vector2

# Parámetros de órbita
@export var orbit_radius: float = 80.0  # Distancia de la órbita
@export var orbit_speed: float = 3.0    # Velocidad angular (radianes/segundo)
@export var follow_smooth: float = 0.15 # Suavidad del seguimiento (0-1, menor = más suave)

# Rotación visual
@export var rotation_speed: float = 4.0 # Velocidad de rotación del sprite
@export var enable_rotation: bool = true # Girar el sprite mientras orbita

# Estado
var orbit_angle: float = 0.0
var target_position: Vector2
var current_angle_offset: float = 0.0

func _ready() -> void:
	# Buscar el nodo del jugador en el grupo "jugador"
	player = get_tree().get_first_node_in_group("jugador")
	
	if not player:
		push_error("No se encontró nodo en grupo 'jugador'. Asegúrate de añadir el jugador a este grupo.")
		return
	
	player_position = player.global_position
	target_position = global_position
	current_angle_offset = orbit_angle

func _process(delta: float) -> void:
	if not player:
		return
	
	# Actualizar ángulo de órbita continuamente
	orbit_angle += orbit_speed * delta
	
	# Calcular posición de órbita
	var orbit_offset = Vector2(
		cos(orbit_angle) * orbit_radius,
		sin(orbit_angle) * orbit_radius
	)
	
	player_position = player.global_position
	target_position = player_position + orbit_offset
	
	# Seguimiento suave hacia la posición objetivo
	global_position = global_position.lerp(target_position, follow_smooth)
	
	# Rotación visual opcional (giro del sprite)
	if enable_rotation:
		rotation += rotation_speed * delta

func _physics_process(delta: float) -> void:
	# Aquí puedes añadir física si la necesitas
	# Por ahora dejamos que sea puramente cinemático
	pass

# Función para cambiar el radio de órbita suavemente
func set_orbit_radius_smooth(new_radius: float, transition_time: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "orbit_radius", new_radius, transition_time)

# Función para hacer que la espada gire alrededor del jugador de forma diferente
func set_orbit_speed(new_speed: float) -> void:
	orbit_speed = new_speed

# Función para pausar la órbita
func pause_orbit() -> void:
	orbit_speed = 0.0

# Función para reanudar la órbita
func resume_orbit() -> void:
	orbit_speed = 3.0