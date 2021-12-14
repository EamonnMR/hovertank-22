extends Spatial

var cooldown: bool = false
var parent: Node
class_name Weapon

onready var world = get_tree().get_root().get_node("World")
onready var projectile_scene = preload("res://projectiles/Projectile.tscn")

func init(parent: Node):
	parent = parent

func try_shoot():
	if not cooldown:
		_shoot()

func _shoot():
	var projectile = projectile_scene.instance()
	projectile.init(parent)
	world.add_child(projectile)
	projectile.global_transform = global_transform
	cooldown = true
	$Cooldown.start()
	_effects()

func _effects():
	pass
	# TODO: Muzzle flash, sparks, sound, etc

func _on_Cooldown_timeout():
	cooldown = false
