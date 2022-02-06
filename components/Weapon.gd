extends Spatial

var cooldown: bool = false
var burst_cooldown: bool = false
var burst_counter: int = 0
var iff: IffProfile
class_name Weapon

onready var world = get_tree().get_root().get_node("World")
export var projectile_scene = preload("res://projectiles/Projectile.tscn")
export var burst_count = 0

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
	if not cooldown and not burst_cooldown:
		_shoot()

func _shoot():
	if burst_count:
		burst_counter += 1
		if burst_counter >= burst_count:
			burst_cooldown = true
			$BurstCooldown.start()
	
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

func _on_BurstCooldown_timeout():
	burst_cooldown = false
	burst_counter = 0
