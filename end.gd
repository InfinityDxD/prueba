extends Area2D  # Cambia a Area3D si tu juego es en 3D

func _on_body_entered(body: Node2D) -> void:
	# Verificamos si el cuerpo que entró es el jugador
	if body.is_in_group("jugador"):
		print("¡Ganaste! Fin del juego")
		get_tree().quit()