extends Node


var loading_scene = preload("res://Scenes/Menus/loading.tscn")
var active_loading_scene
var enet_network = preload("res://Network/Network_Layer/enet_network.tscn")
var is_hosting_game = false

func host_game():
	print("host game (network manager)")
	show_loading()
	is_hosting_game = true
	var active_network = enet_network.instantiate()
	add_child(active_network)
	active_network.create_server_peer()
	
	
	
	
func join_game():
	print("join game (network manager)")
	show_loading()
	
	var active_network = enet_network.instantiate()
	add_child(active_network)
	active_network.create_client_peer()

	
	
func show_loading():
	print("show loading (network manager)")
	active_loading_scene = loading_scene.instantiate()
	add_child(active_loading_scene)

	
func hide_loading():
	print("hide loading (network manager)")
	if active_loading_scene != null:
		remove_child(active_loading_scene)
		active_loading_scene.queue_free()
