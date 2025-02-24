extends Area3D

@export var mouse_sensitivity = 0.1  # Mouse sensitivity
@export var look_sensitivity = 0.001  # Sensitivity for mouse movement
@export var max_left_angle = -PI / 1.9 # Maximum left rotation limit
@export var max_right_angle = PI / 1.9 # Maximum right rotation limit
@export var max_up_angle = -PI / 3 # Maximum upward rotation limit
@export var max_down_angle = PI / 4.5 # Maximum downward rotation limit

@onready var camera = $"../Camera3D"
@onready var player_exit = $"../Player Exit"
@onready var hud = $"../Hud"
var has_player := false

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
		print(current_player_name)
		
		
		
func _input(event: InputEvent) -> void:
	if not has_player:
		return

	if event is InputEventMouseMotion:
		# Rotate the camera horizontally (left/right) and vertically (up/down)
		var horizontal_rotation = event.relative.x * -look_sensitivity
		var vertical_rotation = event.relative.y * -look_sensitivity
		
		camera.rotate_y(horizontal_rotation)  # Rotate camera horizontally
		camera.rotation.x += vertical_rotation  # Adjust vertical rotation directly
		
		# Clamp horizontal rotation (y-axis rotation)
		camera.rotation.y = clamp(camera.rotation.y, max_left_angle, max_right_angle)
		
		# Clamp vertical rotation (x-axis rotation)
		camera.rotation.x = clamp(camera.rotation.x, max_up_angle, max_down_angle)

func _physics_process(delta):
	if not has_player:
		return

	$"../Hud/hover".text = " Hover"
