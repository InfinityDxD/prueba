extends CharacterBody2D

## --- Configuración ---
@export var speed: float = 80.0
@export var gravity: float = 900.0
@export var detection_range: float = 150.0  ## Distancia a la que empieza a perseguir al player
@export var stop_distance: float = -10.0  ## Distancia mínima antes de dejar de perseguir/acercarse

## --- Referencias a nodos ---
@onready var raycast_left: RayCast2D = $"RayCast2D Left side"
@onready var raycast_right: RayCast2D = $"RayCast2D2 Right Side"
@onready var sprite: Sprite2D = $Sprite2D

## --- Estado interno ---
var direction: int = 1  ## 1 = derecha, -1 = izquierda
var player: Node2D = null

## --- Anti-vibración ---
@export var turn_cooldown_time: float = 0.4  ## Segundos que debe esperar antes de poder girar de nuevo
var turn_cooldown: float = 0.0


func _ready() -> void:
	# El player debe estar en el grupo "player" (Nodo -> Grupos -> agregar "player")
	# IMPORTANTE: el grupo debe estar en el CharacterBody2D que se mueve, no en un Node2D contenedor
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("ADVERTENCIA: no se encontró ningún nodo en el grupo 'player'")
	else:
		print("Player encontrado: ", player.name)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if turn_cooldown > 0.0:
		turn_cooldown -= delta

	if player and global_position.distance_to(player.global_position) < detection_range:
		_chase_player()
	else:
		_patrol()

	move_and_slide()
	_check_player_collision()


func _chase_player() -> void:
	var dist_x: float = player.global_position.x - global_position.x

	# Si ya estamos lo bastante cerca en X, no seguimos empujando el movimiento
	if abs(dist_x) < stop_distance:
		velocity.x = 0
		return

	direction = sign(dist_x)

	var front_ray: RayCast2D = raycast_right if direction > 0 else raycast_left

	if front_ray.is_colliding() and _is_wall(front_ray.get_collider()):
		velocity.x = 0
	else:
		velocity.x = direction * speed

	_update_facing()


func _patrol() -> void:
	# Elegimos el raycast que mira "hacia adelante" según la dirección actual
	var front_ray: RayCast2D = raycast_right if direction > 0 else raycast_left

	# Si el raycast de adelante NO detecta piso (borde) o detecta una pared, damos la vuelta
	var hay_pared := front_ray.is_colliding() and _is_wall(front_ray.get_collider())
	var hay_borde := not front_ray.is_colliding()

	if (hay_pared or hay_borde) and turn_cooldown <= 0.0:
		direction *= -1
		turn_cooldown = turn_cooldown_time
		_update_facing()

	velocity.x = direction * speed


func _is_wall(collider: Object) -> bool:
	# Si tenés capas separadas para "pared" podés filtrar acá por collision_layer.
	# El player NO cuenta como pared, o el enemigo se frenaría al detectarlo.
	if collider == null:
		return false
	if collider == player:
		return false
	return true


func _update_facing() -> void:
	sprite.flip_h = direction < 0
	# Si usás RayCast2D con target_position fijo, no hace falta rotarlos:
	# alcanza con que sus posiciones ya estén a izquierda y derecha del enemigo.


## --- Detección de "toque" con el jugador ---
func _check_player_collision() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		if collision.get_collider() == player:
			_catch_player()


func _catch_player() -> void:
	print("¡El enemigo atrapó al jugador! Cerrando el juego...")
	get_tree().quit()