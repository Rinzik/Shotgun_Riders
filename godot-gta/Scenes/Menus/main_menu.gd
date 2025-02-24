extends Control

const GAME_SCENE = "res://Scenes/Levels/test_level.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		print("Calling host game...")
		NetworkManager.host_game()
		get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func host_game() -> void:
	#print("Host game pressed")
	NetworkManager.host_game()
	get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))
	
	
func join_game() -> void:
	#print("Join game pressed")
	NetworkManager.join_game()
	get_tree().call_deferred(&"change_scene_to_packed", preload(GAME_SCENE))
func exit_game() -> void:
	get_tree().quit(0)
