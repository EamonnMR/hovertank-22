extends Spatial

var cooldown: bool = false
var iff: IffProfile
class_name Weapon
var alert_group = []

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
	for body in alert_group:
		body.alert(iff.owner)
	_effects()

func _effects():
	pass
	# TODO: Muzzle flash, sparks, sound, etc

func _on_Cooldown_timeout():
	cooldown = false


func _on_AlertArea_body_entered(body):
	if body.has_method("alert"):
		print("Entered Alert Area for gun", body)
		alert_group.append(body)


func _on_AlertArea_body_exited(body):
	alert_group.erase(body)
