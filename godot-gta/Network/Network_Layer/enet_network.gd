extends Node

const SERVER_PORT = 8124
const SERVER_IP = "127.0.0.1"
# Called when the node enters the scene tree for the first time.
func create_server_peer():
	var entet_network_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	entet_network_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = entet_network_peer
func create_client_peer():
	var entet_network_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	entet_network_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = entet_network_peer
