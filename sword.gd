extends Node2D

@export var velocidad_seguimiento: float = 500.0
@export var distancia_offset: Vector2 = Vector2(30, 0)  # Separación de la espada

@onready var jugador = get_tree().get_first_node_in_group("jugador")

func _process(delta: float) -> void:
	if jugador:
		var posicion_destino = jugador.global_position + distancia_offset
		global_position = global_position.lerp(posicion_destino, velocidad_seguimiento * delta)
