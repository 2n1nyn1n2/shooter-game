extends CharacterBody3D
class_name Player

@export var joystick: Joystick
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.4  # Seconds between shots

@export_group("Movement")
@export var SPEED := 1.0
@export var SPRINT_SPEED := 8.0
@export var JUMP_VELOCITY := 4.5
@export var ROTATION_SPEED := 1.0

@export_group("Camera Leash")
@export var CAMERA_LEASH_SPEED := 10.0  # Speed at which camera follows behind player

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var muzzle: Marker3D = $Muzzle
@onready var cam_origin: Node3D = $CamOrigin
@onready var spring_arm: SpringArm3D = $CamOrigin/SpringArm3D
@onready var camera: Camera3D = $CamOrigin/SpringArm3D/Camera3D
@onready var model: Node3D = $QuaterniusModel
@onready var anim_player: AnimationPlayer = $QuaterniusModel/AnimationPlayer

var can_shoot: bool = true


func _unhandled_input(event: InputEvent) -> void:
	# Press ESC to toggle mouse visibility
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Read input vector from Joystick or Keyboard fallback
	var input_vector := Vector2.ZERO
	if joystick:
		input_vector = joystick.output

	# Determine direction relative to the camera frame
	var move_dir := (
		(cam_origin.global_transform.basis * Vector3(input_vector.x, 0, input_vector.y))
		. normalized()
	)
	var current_speed = SPEED

	var walking = false
	if move_dir:
		walking = true
		velocity.x = move_dir.x * current_speed
		velocity.z = move_dir.z * current_speed

		# Smoothly turn character model toward movement vector
		var target_angle = atan2(-move_dir.x, -move_dir.z)
		model.rotation.y = lerp_angle(model.rotation.y, target_angle, delta * 12.0)

		if is_on_floor():
			if not anim_player.is_playing():
				anim_player.play("Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		if is_on_floor():
			if not anim_player.is_playing():
				anim_player.play("Idle")

	move_and_slide()
	shoot(walking)

	cam_origin.rotation.y = lerp_angle(
		cam_origin.rotation.y, model.rotation.y + PI, delta * CAMERA_LEASH_SPEED
	)


func shoot(walking: bool) -> void:
	if not bullet_scene:
		print("Warning: No bullet_scene assigned to Player!")
		return
	if not muzzle:
		return
	if not can_shoot:
		return

	can_shoot = false

	# Instantiate the bullet
	var bullet = bullet_scene.instantiate() as Bullet

	# Spawn bullet in the root scene (Main) so it doesn't move with the player
	get_tree().current_scene.add_child(bullet)

	# Position the bullet at the muzzle position
	bullet.global_position = muzzle.global_position

	# Match the bullet's rotation to the character model's rotation
	bullet.rotation.y = model.rotation.y

	# Set bullet direction facing forward relative to where the player model is looking
	bullet.direction = model.global_transform.basis.z.normalized()

	if walking:
		anim_player.play("Walk_Shoot")
	else:
		anim_player.play("Idle_Shoot")

	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
