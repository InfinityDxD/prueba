# Prueba Godot

Proyecto de ejemplo creado con Godot Engine 4.7.

## Descripción

Juego 2D simple con un jugador, un enemigo y una espada móvil. El proyecto incluye:

- `player.gd`: movimiento del jugador con salto, gravedad y "coyote time".
- `enemy.gd`: enemigo que patrulla, persigue al jugador y detecta bordes/paredes con raycasts.
- `sword.gd`: espada que sigue al jugador y realiza un ataque basado en el movimiento del jugador.
- `world.tscn`: escena principal del nivel que instancia al jugador, la espada y el enemigo.
- `test.tscn`: escena de ejecución configurada como escena principal del proyecto.

## Cambios recientes

- Fecha: 2026-07-13
- Se corrigió un problema en `player.tscn`: el grupo `player` se movió del nodo raíz `Node2D` al `CharacterBody2D` para que el enemigo siga la posición móvil correcta del jugador.

## Herramientas utilizadas

- Godot Engine 4.7
- GDScript para la lógica de juego
- `CharacterBody2D` para movimiento con físicas 2D
- `Sprite2D` y `CollisionShape2D` para render y colisiones
- `RayCast2D` para detección de bordes y seguimiento del jugador
- `TileMapLayer` y `TileSet` para construir el escenario
- `Input Map` para controlar entradas como `ui_left`, `ui_right`, `ui_up` y `ui_accept`

## Estructura del proyecto

- `project.godot`: configuración del proyecto.
- `test.tscn`: escena principal apuntada por el proyecto.
- `world.tscn`: escena de mundo que contiene tilemap y las instancias de los personajes.
- `player.tscn`: escena del jugador con `CharacterBody2D`, `Sprite2D`, `CollisionShape2D` y `Camera2D`.
- `enemy.tscn`: escena del enemigo con `CharacterBody2D`, `Sprite2D`, `CollisionShape2D` y dos `RayCast2D`.
- `sword.tscn`: escena de la espada con `Node2D`, `Sprite2D` y `CollisionShape2D`.
- `assets/`: recursos gráficos e imágenes importadas.

## Mecánicas principales

### Jugador (`player.gd`)

- Movimiento horizontal con velocidad constante.
- Salto con gravedad aplicada.
- Soporte para "coyote time" (gracia después de dejar el suelo).
- Wall jump cuando el jugador está en la pared.

### Enemigo (`enemy.gd`)

- Patrulla en el suelo.
- Detecta si hay bordes o paredes usando dos `RayCast2D`.
- Persigue al jugador cuando está dentro de `detection_range`.
- Cambia de dirección con un pequeño cooldown para evitar vibraciones.

### Espada (`sword.gd`)

- Sigue al jugador con una posición objetivo ajustada según su movimiento.
- Realiza un ataque cuando se presiona `ui_accept`.
- El ataque depende del movimiento del jugador para determinar la dirección y la distancia del golpe.
- Tiene cooldown entre ataques.

## Escenas clave

### `test.tscn`

Escena de prueba principal que instancia:

- `world` desde `world.tscn`
- `player` desde `player.tscn`
- `sword` desde `sword.tscn`
- `Enemy` desde `enemy.tscn`

### `world.tscn`

Contiene un `TileMapLayer` con tiles importados desde `assets/sprites/tileset/tiletest.png`.

## Controles

- `ui_left`: mover a la izquierda.
- `ui_right`: mover a la derecha.
- `ui_up`: salto.
- `ui_accept`: activar el ataque de la espada.

## Notas de configuración

- El proyecto está configurado para usar Godot 4.7 con `GL Compatibility` en Windows.
- El ícono del proyecto es `icon.svg`.

## Guía de uso

1. Abre `project.godot` en Godot Engine 4.7.
2. Asegúrate de que las entradas de acción `ui_left`, `ui_right`, `ui_up` y `ui_accept` estén definidas en el `Input Map`.
3. Ejecuta `test.tscn` como escena principal.

## Archivos importantes

- `player.gd`
- `enemy.gd`
- `sword.gd`
- `player.tscn`
- `enemy.tscn`
- `sword.tscn`
- `world.tscn`
- `test.tscn`
- `project.godot`

## Recursos

- `assets/sprites/player/player.png`
- `assets/sprites/enemy.png`
- `assets/sprites/player/bat.png`
- `assets/sprites/tileset/tiletest.png`
