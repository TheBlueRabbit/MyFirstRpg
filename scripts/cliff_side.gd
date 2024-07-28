extends Node2D

func _ready():
	$Player.position.x = Global.player_enter_posx
	$Player.position.y = Global.player_enter_posy
	$Player.setDir(Global.player_dir)


func _on_world_exit_body_entered(body):
	if body.is_in_group("player"):
		Global.player_enter_posx = 81
		Global.player_enter_posy = -10
		Global.player_dir = $Player.getDir()
		change_scene("res://scenes/world.tscn")



func change_scene(scn):
	get_tree().change_scene_to_file(scn)
