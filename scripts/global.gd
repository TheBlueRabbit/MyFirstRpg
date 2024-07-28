extends Node

var current_scene = "world"
var player_enter_posx = 0
var player_enter_posy = 0
var player_dir
var first_load = true

	
func on_slime_death(slimepos):
	var dice = randi_range(0,100)
	if dice >= 50:
		var potion_scn = load("res://scenes/potion.tscn")
		var potion = potion_scn.instantiate()
		potion.global_position = slimepos
		get_tree().root.add_child(potion)
