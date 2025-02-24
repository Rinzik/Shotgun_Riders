extends Area3D

@export var lift_force = 50.0
@export var tilt_speed = 1.0
@export var yaw_speed = 1.0
@export var strafe_force = 20.0
@export var mouse_sensitivity = 0.1  # Mouse sensitivity
@export var look_sensitivity = 0.001
@onready var camera = $"../Camera3D"
@onready var player_exit = $"../Player Exit"
var has_player := false
var is_flying = false
var mouse_motion = Vector2.ZERO
var pitch_rotation_accumulated = 0.0
var yaw_rotation_accumulated = 0.0
@export var roll_sensitivity = 0.01
@onready var animations:AnimationPlayer = $"../AnimationPlayer"
@onready var hud = $"../Hud"
@onready var helicopter = $".."

var current_player_name


func _ready():
	camera.current = false
	
	
func toggle_player():
	has_player = !has_player
	camera.current = has_player
	hud.visible = has_player
	
@rpc("any_peer")
func set_player_authority(current_player_name):
	if has_player:
		$"..".set_multiplayer_authority(str(current_player_name).to_int())
		set_multiplayer_authority(str(current_player_name).to_int())
		$"../MultiplayerSynchronizer".set_multiplayer_authority(str(current_player_name).to_int())
		print("heli pilot multiplayer athority ", current_player_name)


func _input(event: InputEvent) -> void:
	if not has_player:
		return
	if event is InputEventMouseMotion:
		# Accumulate yaw rotation based on mouse movement
		yaw_rotation_accumulated += event.relative.x * look_sensitivity
		pitch_rotation_accumulated += event.relative.y * -look_sensitivity


func _physics_process(delta):
	if not has_player:
		animations.stop()  # Stop animations if no player is in the helicopter
		return

	# Apply accumulated pitch and roll rotation
	if pitch_rotation_accumulated != 0.0:
		helicopter.rotate_x(pitch_rotation_accumulated)
		pitch_rotation_accumulated = 0.0
	if yaw_rotation_accumulated != 0.0:
		helicopter.rotate_y(yaw_rotation_accumulated)
		yaw_rotation_accumulated = 0.0

	# Input forces
	var lift = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	var forward = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	var lateral = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var roll = Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right")

	# Apply yaw (rotate about local Y-axis)
	if roll != 0.0:
		helicopter.rotate_z(roll * roll_sensitivity)

	# Apply lift force (relative to local Y-axis)
	if lift != 0:
		var lift_direction = helicopter.global_transform.basis.y
		helicopter.apply_central_force(lift_direction * lift * lift_force)
		
		# Play fly animation if not already playing
		if not is_flying:
			animations.play("fly")
			animations.set_speed_scale(5.0)
			is_flying = true
	else:
		# Play idle animation if not already idle
		if is_flying:
			animations.play("idle")
			animations.set_speed_scale(1.0)
			is_flying = false

	# Apply forward/backward movement (relative to local Z-axis)
	if forward != 0.0:
		var forward_direction = -helicopter.global_transform.basis.z
		helicopter.apply_central_force(forward_direction * forward * strafe_force)

		# Add tilt (pitch) for forward/backward movement
		var pitch_axis = helicopter.global_transform.basis.x
		helicopter.apply_torque_impulse(pitch_axis * -forward * tilt_speed)

	# Apply left/right strafing (relative to local X-axis)
	if lateral != 0.0:
		var lateral_direction = helicopter.global_transform.basis.x
		helicopter.apply_central_force(lateral_direction * lateral * strafe_force)

		# Add tilt (roll) for lateral movement
		var roll_axis = helicopter.global_transform.basis.z
		helicopter.apply_torque_impulse(roll_axis * -lateral * tilt_speed)

	# Stabilize the helicopter
	helicopter.angular_velocity *= 0.98
	helicopter.linear_velocity *= 0.99

	# Update HUD
	var speed = helicopter.linear_velocity.length() * 3.6  # Convert m/s to km/h
	$"../Hud/speed".text = str(round(speed)) + " MPH"
	$"../Hud/hover".text = " Hover"
