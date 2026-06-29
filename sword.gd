# espada.gd
extends Node2D

# === SEGUIMIENTO ===
@export var velocidad_seguimiento: float = 8.0
@export var distancia_offset: float = 35.0
@export var velocidad_rotacion: float = 12.0
@export var altura_offset: float = -20.0
@export var altura_walljump: float = -60.0

# === ATAQUE ===
@export var tecla_ataque: String = "ui_accept"
@export var tiempo_ataque: float = 0.4
@export var velocidad_rotacion_ataque: float = 30.0
@export var rotacion_ataque: float = PI
@export var cooldown_ataque: float = 0.6

# === ESPADAZO (NUEVO) ===
@export var distancia_espadazo: float = 80.0  # Qué tan lejos se lanza
@export var velocidad_espadazo_forward: float = 20.0  # Qué tan rápido sale
@export var velocidad_espadazo_retorno: float = 15.0  # Qué tan rápido vuelve

var jugador: Node2D
var velocidad_jugador: Vector2 = Vector2.ZERO
var posicion_anterior: Vector2 = Vector2.ZERO

# Estado de ataque
var atacando: bool = false
var tiempo_ataque_actual: float = 0.0
var cooldown_actual: float = 0.0
var rotacion_inicial_ataque: float = 0.0
var posicion_base_ataque: Vector2 = Vector2.ZERO  # Posición inicial del ataque
var direccion_espadazo: Vector2 = Vector2.RIGHT  # Dirección del golpe

func _ready() -> void:
	jugador = get_node_or_null("../player/CharacterBody2D")
	
	if not jugador:
		push_error("ERROR: No encontré el jugador en ../player")
	else:
		print("✓ Jugador encontrado: ", jugador.name)
		posicion_anterior = jugador.global_position

func _process(delta: float) -> void:
	if not jugador:
		return
	
	# === ENTRADA DE ATAQUE ===
	if Input.is_action_just_pressed(tecla_ataque) and cooldown_actual <= 0:
		_iniciar_ataque()
	
	# Decrementar cooldown
	if cooldown_actual > 0:
		cooldown_actual -= delta
	
	# === LÓGICA PRINCIPAL ===
	if atacando:
		_actualizar_ataque(delta)
	else:
		_actualizar_seguimiento(delta)

func _iniciar_ataque() -> void:
	atacando = true
	tiempo_ataque_actual = 0.0
	cooldown_actual = cooldown_ataque
	rotacion_inicial_ataque = rotation
	posicion_base_ataque = global_position
	
	# Calcular dirección del espadazo basada en velocidad jugador
	velocidad_jugador = jugador.global_position - posicion_anterior
	var direccion_horizontal = sign(velocidad_jugador.x)
	
	# Si no se mueve, golpear hacia la derecha por defecto
	if abs(velocidad_jugador.x) < 1.0:
		direccion_espadazo = Vector2.RIGHT
	else:
		# En sistema Nier: la espada está al lado opuesto, así que golpea hacia ese lado
		direccion_espadazo = Vector2(-direccion_horizontal, 0)
	
	print("⚔️ ¡ESPADAZO! Dirección: ", direccion_espadazo)

func _actualizar_ataque(delta: float) -> void:
	"""Durante el ataque: rotación + empuje del golpe"""
	tiempo_ataque_actual += delta
	
	# Progreso del ataque (0.0 a 1.0)
	var progreso = tiempo_ataque_actual / tiempo_ataque
	
	if progreso >= 1.0:
		# Ataque terminado
		atacando = false
		tiempo_ataque_actual = 0.0
		return
	
	# Calcular velocidad del jugador
	velocidad_jugador = jugador.global_position - posicion_anterior
	posicion_anterior = jugador.global_position
	
	# POSICIÓN BASE: sigue al jugador
	var en_pared = jugador.is_on_wall() if "is_on_wall" in jugador else false
	var en_suelo = jugador.is_on_floor() if "is_on_floor" in jugador else false
	var velocidad_horizontal = abs(velocidad_jugador.x)
	
	var offset_x: float
	var offset_y: float
	
	if en_pared and not en_suelo:
		offset_x = 0
		offset_y = altura_walljump
	elif velocidad_horizontal < 1.0:
		offset_x = 0
		offset_y = altura_offset
	else:
		var direccion_movimiento = sign(velocidad_jugador.x)
		offset_x = -distancia_offset * direccion_movimiento
		offset_y = altura_offset
	
	var posicion_objetivo = jugador.global_position + Vector2(offset_x, offset_y)
	
	# === ESPADAZO: Movimiento hacia adelante ===
	# Primera mitad: sale hacia adelante
	# Segunda mitad: vuelve a la posición normal
	var distancia_actual: float
	if progreso < 0.5:
		# Sale: 0.0 → 1.0 en la primera mitad
		var progreso_forward = (progreso / 0.5)
		distancia_actual = distancia_espadazo * progreso_forward
	else:
		# Vuelve: 1.0 → 0.0 en la segunda mitad
		var progreso_retorno = 1.0 - ((progreso - 0.5) / 0.5)
		distancia_actual = distancia_espadazo * progreso_retorno
	
	# Aplicar empuje en la dirección del espadazo
	var empuje = direccion_espadazo * distancia_actual
	var posicion_con_empuje = posicion_objetivo + empuje
	
	# POSICIÓN FINAL
	global_position = global_position.lerp(posicion_con_empuje, velocidad_espadazo_forward * delta)
	
	# ROTACIÓN DURANTE ATAQUE: giro completo suave
	var rotacion_objetivo = rotacion_inicial_ataque + (rotacion_ataque * progreso)
	rotation = lerp_angle(rotation, rotacion_objetivo, velocidad_rotacion_ataque * delta)
	
	print("Espadazo: ", int(progreso * 100), "% | Distancia: ", int(distancia_actual))

func _actualizar_seguimiento(delta: float) -> void:
	"""Modo normal: sigue al jugador sin atacar"""
	
	# Calcular velocidad del jugador
	velocidad_jugador = jugador.global_position - posicion_anterior
	posicion_anterior = jugador.global_position
	
	# Detectar estado
	var en_pared = jugador.is_on_wall() if "is_on_wall" in jugador else false
	var en_suelo = jugador.is_on_floor() if "is_on_floor" in jugador else false
	var velocidad_horizontal = abs(velocidad_jugador.x)
	
	var offset_x: float
	var offset_y: float
	
	if en_pared and not en_suelo:
		offset_x = 0
		offset_y = altura_walljump
	elif velocidad_horizontal < 1.0:
		offset_x = 0
		offset_y = altura_offset
	else:
		var direccion_movimiento = sign(velocidad_jugador.x)
		offset_x = -distancia_offset * direccion_movimiento
		offset_y = altura_offset
	
	var posicion_objetivo = jugador.global_position + Vector2(offset_x, offset_y)
	
	# POSICIÓN
	global_position = global_position.lerp(posicion_objetivo, velocidad_seguimiento * delta)
	
	# ROTACIÓN: solo pequeños ajustes
	var direccion_rotacion = (posicion_objetivo - global_position).angle()
	rotation = lerp_angle(rotation, direccion_rotacion, velocidad_rotacion * delta)