extends CharacterBody2D


const SPEED = 100
const MAX_HEALTH = 150
enum Direction {RIGHT,LEFT,UP,DOWN}


var dir = Direction.DOWN
@onready var anim = $AnimatedSprite2D

var enemy_inattack_range = false

var health = 150
var alive = true
var attack_ip = false
var targets = []

var can_attack = true

func _physics_process(delta):
	update_healthbar()
	
	if not alive:
		return
	
	player_movement(delta)
	attack()
	
	if health <= 0:
		alive = false
		anim.play("death")
		health = 0
		self.set_collision_layer_value(2,false)
		
	
	
func player_movement(_delta):
	
	if attack_ip:
		velocity.y = 0
		velocity.x = 0
		animate("attack")
	
	elif Input.is_action_pressed("right"):
		velocity.x = SPEED
		velocity.y = 0
		animate("walk")
		dir = Direction.RIGHT
		
	elif Input.is_action_pressed("left"):
		velocity.x = -SPEED
		velocity.y = 0
		animate("walk")
		dir = Direction.LEFT
		
	elif Input.is_action_pressed("up"):
		velocity.x = 0
		velocity.y = -SPEED
		animate("walk")
		dir = Direction.UP
		
	elif Input.is_action_pressed("down"):
		velocity.x = 0
		velocity.y = SPEED
		animate("walk")
		dir = Direction.DOWN
		
	else:
		velocity.x = 0
		velocity.y = 0
		animate("idle")
	
	move_and_slide()

func _on_hitbox_body_entered(body):
	if body.has_method("take_damage") and body != self:
		targets.append(body)

func _on_hitbox_body_exited(body):
	if body.has_method("take_damage"):
		targets.erase(body)

func take_damage(damage):
	health -= damage
	$regen_timer.start(0)



func attack():
	if Input.is_action_just_pressed("attack") and can_attack:
		attack_ip = true
		for t in targets:
			t.take_damage(20)
		can_attack = false
	

func _on_animated_sprite_2d_animation_finished():
	match anim.animation:
		"death":
			self.hide()
		"side_attack","front_attack","back_attack":
			attack_ip = false
			can_attack = true


func animate(action):
	match dir:
		Direction.UP:
			anim.play("back_" + action)
		Direction.DOWN:
			anim.play("front_" + action)
		Direction.LEFT:
			anim.play("side_" + action)
			anim.flip_h = true
		Direction.RIGHT:
			anim.play("side_" + action)
			anim.flip_h = false

func getDir():
	return dir
	
func setDir(direction):
	dir = direction

func update_healthbar():
	$healthbar.value = health
	
	if health == MAX_HEALTH:
		$healthbar.hide()
	else:
		$healthbar.show()

func _on_regen_timer_timeout():
	if health < MAX_HEALTH and alive:
		health += 10

func heal(life):
	health += life
	if health > MAX_HEALTH:
		health = MAX_HEALTH
