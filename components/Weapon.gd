extends Spatial

class_name Weapon

var cooldown: bool = false
var burst_cooldown: bool = false
var burst_counter: int = 0
var ammo_manager
var special_id
var iff: IffProfile

onready var world = get_tree().get_root().get_node("World")
export var projectile_scene = preload("res://projectiles/Projectile.tscn")
export var burst_count = 0
export var dupe_count = 1
export var spread: float = 0
export var world_projectile: bool = true  # Disable for beams or other things that should follow the player
export var engagement_range: float = 60


export var dmg_factor: float = 1

func _ready():
	assert($Graphics)
	assert($Emerge)

func init(iff: IffProfile, special_id=null):
	self.iff = iff
	if not iff.owner.is_player():
		print(iff.owner, " is not player, no need for an alert area")
		call_deferred("remove_child", $AlertArea)
	else:
		print(iff.owner, " is player, keep alert area")
	$Notifier.notification_source = iff.owner
	if special_id != null:
		self.special_id=special_id
		self.ammo_manager = iff.owner.get_node("AmmoManager")

func try_shoot():
	if not cooldown and not burst_cooldown:
		if special_id == null or ammo_manager.consume_special_ammo(special_id):
			_shoot()

func _shoot():
	if burst_count:
		burst_counter += 1
		if burst_counter >= burst_count:
			burst_cooldown = true
			$BurstCooldown.start()
	for i in range(dupe_count):
		_create_projectile()
	cooldown = true
	$Cooldown.start()
	$Notifier.notify()
	_effects()

func _create_projectile():
	var projectile = projectile_scene.instance()
	projectile.init(iff)
	if world_projectile:
		world.add_child(projectile)
	else:
		$Emerge.add_child(projectile)
	projectile.damage *= dmg_factor
	projectile.splash_damage *= dmg_factor
	# TODO: Also scale splash damage
	projectile.global_transform = $Emerge.global_transform
	projectile.rotate_x(rand_range(-spread/2, spread/2))
	projectile.rotate_y(rand_range(-spread/2, spread/2))
	

func _effects():
	$Emerge/MuzzleFlash.restart()
	$Emerge/MuzzleFlash.emitting = true
	$AudioStreamPlayer3D.play()

func _on_Cooldown_timeout():
	cooldown = false

func _on_BurstCooldown_timeout():
	burst_cooldown = false
	burst_counter = 0
