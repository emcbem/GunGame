extends Node2D

var bullet_direction = Vector2.ZERO

const BULLET_SPEED = 200

@onready var bulletHitbox = $Hitbox

func _ready():
	bulletHitbox. knockback_vector = bullet_direction / 2

func _physics_process(delta: float):
	translate(bullet_direction * delta * BULLET_SPEED)

func _on_hitbox_area_entered(area: Area2D) -> void:
	queue_free()
