extends CharacterBody2D

const SPEED = 50
enum Direction {UP,DOWN,LEFT,RIGHT}

var player_chase = false
var player = null
var dir = Direction.DOWN
var state = 0

@onready var idle_target = $idle_target


@onready var anim = $AnimatedSprite2D

var health = 100
var alive = true
var player_inattack_range = false
var can_attack = true

func _physics_process(delta):
	update_healthbar()
	if not alive:
		return
	if player_inattack_range and can_attack:
		attack()
	if player_chase:
		make_path(player)
		move(global_position.direction_to($NavigationAgent2D.get_next_path_position()).normalized() * SPEED * delta)
	else:
		if state == 1:
			move(velocity.normalized()*delta*SPEED/2)
		else:
			match dir:
			
				Direction.DOWN:
					anim.play("front_idle")
				Direction.UP:
					anim.play("back_idle")
				Direction.LEFT, Direction.RIGHT:
					anim.play("side_idle")


func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_chase = true
		$state_cooldown.stop()
		state = 0

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		player_chase = false
		player = null
		$state_cooldown.start()
		


func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		player_inattack_range = true
		
		

func _on_hitbox_body_exited(body):
	if body.is_in_group("player"):
		player_inattack_range = false



func attack():
	player.take_damage(20)
	$attack_cooldown.start()
	can_attack = false

func take_damage(damage):
	health -= damage
	if health <= 0:
		alive = false
		anim.play("death")

func _on_animated_sprite_2d_animation_finished():
	match anim.animation:
		"death":
			Global.on_slime_death(global_position)
			queue_free() # Replace with function body.
			
	
func update_healthbar():
	$healthbar.value = health
	if health == 100:
		$healthbar.hide()
	else:
		$healthbar.show()

func _on_attack_cooldown_timeout():
	can_attack = true

func move(movement):
	move_and_collide(movement)
	if movement.y > 0 and movement.y > abs(movement.x):
		dir = Direction.DOWN
		anim.play("front_walk")
	elif movement.y < 0 and abs(movement.y) > abs(movement.x):
		dir = Direction.UP
		anim.play("back_walk")
	elif movement.x > 0 and movement.x > abs(movement.y):
		dir = Direction.RIGHT
		anim.play("side_walk")
		anim.flip_h = false
	elif movement.x < 0 and abs(movement.x) > abs(movement.y):
		dir = Direction.LEFT
		anim.play("side_walk")
		anim.flip_h = true



func _on_state_cooldown_timeout():
	state = randi_range(0,1)
	
	if state == 0:
		state = 1
		
	if state == 1:
		idle_target.position.x = randf_range(position.x-100,position.x+100)
		idle_target.position.y = randf_range(position.y -100,position.y + 100)
		state = 0

func make_path(target):
	$NavigationAgent2D.target_position = target.global_position
