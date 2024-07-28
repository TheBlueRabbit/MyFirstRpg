extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.first_load:
		Global.first_load = false
	else:
		$Player.position.x = Global.player_enter_posx
		$Player.position.y = Global.player_enter_posy
		$Player.setDir(Global.player_dir)




func _on_cliff_side_exit_body_entered(body):
	if body.is_in_group("player"):
		Global.player_enter_posx = 133
		Global.player_enter_posy = 226
		Global.player_dir = $Player.getDir()
		change_scene("res://scenes/cliff_side.tscn")

func change_scene(scn):
	get_tree().change_scene_to_file(scn)
		
