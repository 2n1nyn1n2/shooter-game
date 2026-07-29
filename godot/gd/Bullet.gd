extends Area3D
class_name Bullet

@export var speed: float = 50.0
@export var damage: int = 10
@export var lifetime: float = 3.0

var direction: Vector3 = Vector3.FORWARD


func _ready() -> void:
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
