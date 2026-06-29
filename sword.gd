# espada.gd
extends Node2D

@export var velocidad_seguimiento: float = 8.0
@export var distancia_offset: float = 35.0
@export var velocidad_rotacion: float = 12.0
@export var altura_offset: float = -20.0
@export var altura_walljump: float = -60.0  # Más arriba cuando salta de pared

var jugador: Node2D
var velocidad_jugador: Vector2 = Vector2.ZERO
var posicion_anterior: Vector2 = Vector2.ZERO

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
	
	# Calcular velocidad del jugador
	velocidad_jugador = jugador.global_position - posicion_anterior
	posicion_anterior = jugador.global_position
	
	# === DETECTAR ESTADO DEL JUGADOR ===
	var en_pared = jugador.is_on_wall() if "is_on_wall" in jugador else false
	var en_suelo = jugador.is_on_floor() if "is_on_floor" in jugador else false
	var velocidad_horizontal = abs(velocidad_jugador.x)
	
	# === LÓGICA DE POSICIÓN ===
	var offset_x: float
	var offset_y: float
	
	# Si está en wall jump o saltando desde pared
	if en_pared and not en_suelo:
		offset_x = 0  # Centro
		offset_y = altura_walljump  # Más arriba
	# Si NO se mueve horizontalmente
	elif velocidad_horizontal < 1.0:  # Umbral para "no se mueve"
		offset_x = 0  # Arriba en el centro
		offset_y = altura_offset
	# Sistema NIER normal: lado opuesto al movimiento
	else:
		var direccion_movimiento = sign(velocidad_jugador.x)
		offset_x = -distancia_offset * direccion_movimiento
		offset_y = altura_offset
	
	var posicion_objetivo = jugador.global_position + Vector2(offset_x, offset_y)
	
	# POSICIÓN - sigue constantemente
	global_position = global_position.lerp(posicion_objetivo, velocidad_seguimiento * delta)
	
	# ROTACIÓN - rota hacia la posición objetivo
	var direccion_rotacion = (posicion_objetivo - global_position).angle()
	rotation = lerp_angle(rotation, direccion_rotacion, velocidad_rotacion * delta)
	
	# Debug
	print("Estado: Pared=", en_pared, " Suelo=", en_suelo, " VelX=", velocidad_horizontal, " OffsetX=", offset_x)