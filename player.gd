extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -400.0
# Variables para el Wall Jump
const WALL_JUMP_VELOCITY = -450.0
const WALL_PUSH_BACK = 350.0

# --- COYOTE TIME (SIN TIMER EXTERNO) ---
const COYOTE_DURATION: float = 0.15  # 150ms
var coyote_time_remaining: float = 0.0
func _ready() -> void:
	add_to_group("jugador")  # En _ready() del jugador

func _physics_process(delta: float) -> void:
	print("JUGADOR: pos=", position, " | gpos=", global_position, " | vel=", velocity)
	# Guardamos el estado de si estaba en el suelo ANTES de movernos
	var was_on_floor = is_on_floor()
	
	# Aplicar gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Movimiento horizontal
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Guardamos el estado de si saltó en este frame
	var did_jump = false
	
	# --- LÓGICA DE SALTO ---
	if Input.is_action_just_pressed("ui_up"):
		# Salta si está en el suelo O si el coyote time está disponible
		if is_on_floor() or coyote_time_remaining > 0:
			velocity.y = JUMP_VELOCITY
			coyote_time_remaining = 0.0  # Consumimos el coyote time
			did_jump = true
		# Wall Jump
		elif is_on_wall_only():
			velocity.y = WALL_JUMP_VELOCITY
			velocity.x = get_wall_normal().x * WALL_PUSH_BACK
			did_jump = true
	
	move_and_slide()
	
	
	# --- MANEJO DEL COYOTE TIME ---
	# Si acaba de dejar el suelo (transición de piso a aire)
	if was_on_floor and not is_on_floor() and not did_jump:
		coyote_time_remaining = COYOTE_DURATION
	
	# Si está en el suelo, resetea el coyote time
	if is_on_floor():
		coyote_time_remaining = COYOTE_DURATION  # Llena el "tanque" de gracia
	
	# Si está en una pared, resetea coyote time
	if is_on_wall():
		coyote_time_remaining = 0.0
	
	# Decrementar el coyote time cada frame
	if coyote_time_remaining > 0:
		coyote_time_remaining -= delta
