extends CharacterBody3D
class_name Enemy

signal died_signal

@export var max_health: int = 30
@export var speed: float = 60.0

var current_health: int
var player: Node3D = null

@onready var anim_player: AnimationPlayer = $QuaterniusModel/AnimationPlayer


func _ready() -> void:
	current_health = max_health
	# Find player in the main scene tree
	player = get_tree().get_first_node_in_group("player")


func _physics_process(_delta: float) -> void:
	if player:
		# Chase the player
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		look_at(player.global_position)
		move_and_slide()
		#print("enemy at " , global_position)

	if not anim_player.is_playing():
		anim_player.play("Walk")


func take_damage(amount: int) -> void:
	anim_player.play("HitReact")
	current_health -= amount
	if current_health <= 0:
		die()


func die() -> void:
	anim_player.play("Death")
	died_signal.emit()
	queue_free()
