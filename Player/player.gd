extends CharacterBody2D

const ACCELERATION = 500
const MAX_SPEED = 100
const ROLL_SPEED = 125
const FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var last_vector = Vector2.LEFT

@onready var animationPlayer = $AnimationPlayer
@onready var animationTree = $AnimationTree
@onready var animationState = animationTree.get("parameters/playback")
@onready var swordHitbox = $HitboxPivot/SwordHitbox

func _ready():
	swordHitbox.knockback_vector = last_vector
	animationTree.active = true

func _physics_process(delta: float):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')
	input_vector.y = Input.get_action_strength('ui_down') - Input.get_action_strength('ui_up')
	input_vector.normalized()
	
	if(input_vector != Vector2.ZERO):
		last_vector = input_vector
		swordHitbox.knockback_vector = last_vector
		
		animationTree.set('parameters/Idle/blend_position', input_vector)
		animationTree.set('parameters/Run/blend_position', input_vector)
		animationTree.set('parameters/Attack/blend_position', input_vector)
		animationTree.set('parameters/Roll/blend_position', input_vector)
		animationState.travel('Run')
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel('Idle')
		velocity = velocity.move_toward(Vector2.ZERO, delta * FRICTION)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
func roll_state(delta):
	velocity = last_vector * ROLL_SPEED
	move_and_slide()
	animationState.travel('Roll')
	
func attack_state(delta):
	animationState.travel("Attack")
	
func attack_animation_finished():
	velocity = Vector2.ZERO
	state = MOVE
	
func roll_animation_finished():
	velocity /= 2
	state = MOVE
	
func shoot_bullet():
	var Bullet = load("res://World/Bullet/bullet.tscn")
	var bullet = Bullet.instantiate()
	bullet.bullet_direction = last_vector
	var world = get_tree().current_scene
	bullet.global_position = global_position
	world.add_child(bullet)
	
