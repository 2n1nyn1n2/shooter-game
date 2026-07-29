extends Node3D
class_name Main

@export var enemy_scene: PackedScene
@export var spawn_distance: float = 256.0

@onready var score_label: Label = $HUD/ScoreLabel
@onready var spawn_timer: Timer = $SpawnTimer
@onready var player: Player = $Player
@onready var joystick: Joystick = $Joystick

var score: int = 0


func _ready() -> void:
	player.joystick = joystick
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	update_score_ui()


func _on_spawn_timer_timeout() -> void:
	if not enemy_scene or not is_instance_valid(player):
		return

	var random_angle = randf_range(0, TAU)
	var spawn_offset = Vector2.RIGHT.rotated(random_angle) * spawn_distance

	# Fix: Map the 2D offset (x, y) to 3D ground coordinates (x, 0, z)
	var spawn_position = player.global_position + Vector3(spawn_offset.x, 0, spawn_offset.y)

	var enemy = enemy_scene.instantiate()
	enemy.died_signal.connect(_on_enemy_destroyed)

	add_child(enemy)
	enemy.global_position = spawn_position
	#print("enemy at " , spawn_position)


func _on_enemy_destroyed() -> void:
	score += 100
	update_score_ui()


func update_score_ui() -> void:
	score_label.text = "Score: %d" % score
