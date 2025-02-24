class_name Player extends CharacterBody3D


@onready var camera: Camera3D = $"Camera3D"  # Direct child of root node
@onready var mesh = $MeshInstance3D
@export var speed = 1.0
@export var walk_speed = 1.0
@export var run_speed = 3.0
@export var jump_velocity = 5.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var driving_area: Area3D
var detected_area: Area3D
var player_id: int

@export var look_sensitivity: float = 0.1  # Mouse look sensitivity
@export var move_speed: float = 5.0        # Movement speed
@export var jump_strength: float = 10.0   # Jump strength

# Internal state
var rotation_x: float = 0.0  # To track up/down camera rotation

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	player_id = str(name).to_int()
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if multiplayer.get_unique_id() == str($".".name).to_int():
		camera.current = true

func _unhandled_input(event):
	# Mouse look
	if event is InputEventMouseMotion:
		# Rotate character horizontally
		rotate_y(-event.relative.x * look_sensitivity * 0.01)

		# Rotate camera vertically
		rotation_x -= event.relative.y * look_sensitivity * 0.01
		rotation_x = clamp(rotation_x, deg_to_rad(-80), deg_to_rad(80))
		$Camera3D.rotation.x = rotation_x

func _physics_process(delta: float):
	# Process vehicle mounting
	if Input.is_action_just_pressed("enter"):
		if driving_area:
			position = driving_area.player_exit.global_position
			driving_area.toggle_player()
			detected_area = driving_area
			driving_area = null
			camera.current = true
		elif detected_area:
			position.y = -100
			mesh.position = position - Vector3(0, 0.05, 0)
			velocity = Vector3.ZERO
			driving_area = detected_area
			detected_area = null
			camera.current = false
			driving_area.toggle_player()
			#driving_area.set_player_authority(name)

			$Camera3D/CanvasLayer/vehicle_indicator.hide()
			
			
	# Handle movement
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_backward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_forward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_right"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_left"):
		direction += transform.basis.x

	# Normalize and apply movement
	direction = direction.normalized() * move_speed
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_strength
	else:
		velocity.y += -gravity * delta

	velocity.x = direction.x
	velocity.z = direction.z

	move_and_slide()


func _on_Vehicle_Detector_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	if  driving_area: return
	detected_area = area
	$Camera3D/CanvasLayer/vehicle_indicator.show()

func _on_Vehicle_Detector_area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	if driving_area: return
	detected_area = null
	$Camera3D/CanvasLayer/vehicle_indicator.hide()
