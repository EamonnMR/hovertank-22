extends Spatial

var cooldown: bool = false
var iff: IffProfile
class_name Weapon

onready var world = get_tree().get_root().get_node("World")
export var projectile_scene = preload("res://projectiles/Projectile.tscn")

func _ready():
	assert($Graphics)
	assert($Emerge)

func init(iff: IffProfile):
	self.iff = iff
	if not iff.owner.is_player():
		print(iff.owner, " is not player, no need for an alert area")
		call_deferred("remove_child", $AlertArea)
	else:
		print(iff.owner, " is player, keep alert area")
	$Notifier.notification_source = iff.owner

func try_shoot():
	if not cooldown:
		_shoot()

func _shoot():
	var projectile = projectile_scene.instance()
	projectile.init(iff)
	world.add_child(projectile)
	projectile.global_transform = $Emerge.global_transform
	cooldown = true
	$Cooldown.start()
	$Notifier.notify()
	_effects()

func _effects():
	print("bang")
	$AudioStreamPlayer3D.play()

func _on_Cooldown_timeout():
	cooldown = false
