extends Node

var multiplayer_scene = preload("res://Scenes/Player/Player.tscn")
@export var player_spawn_point: Node3D
var players_in_game: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#need this line to allow time for the callbacks to be established
	await get_tree().process_frame
	
	if NetworkManager.is_hosting_game:
		multiplayer.peer_connected.connect(client_connected)
		multiplayer.peer_disconnected.connect(client_disconnected)
		
		if not OS.has_feature("dedicated_server"):
			add_player_to_game(1)

	NetworkManager.hide_loading()





func add_player_to_game(network_id: int):
	print("Adding Player to game %s" % network_id)
	# spawn player in game
	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.name = str(network_id)
	ready_player(player_to_add)
	
	players_in_game[network_id] = player_to_add
	player_spawn_point.add_child(player_to_add)
	
	
func remove_player_from_game(network_id: int):
	print("Removing Player to game %s" % network_id)
	# Remove player
	if players_in_game.has(network_id):
		var player_to_remove = players_in_game[network_id]
		if player_to_remove:
			player_to_remove.queue_free()
			#player_to_remove.remove()
			players_in_game.erase(network_id)
func ready_player(player: Player):
	player.position = Vector3(randi_range(-2,2), 1, randi_range(-2,2))

#connection lifecycle
func client_connected(network_id: int):
	print("client connected %s" % network_id)
	add_player_to_game(network_id)

	
	
func client_disconnected(network_id):
	print("client disconnected %s" % network_id)
	remove_player_from_game(network_id)
	
