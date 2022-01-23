extends Control

onready var vehicle_dd: OptionButton = $VBoxContainer/Selection/VehicleSelect/MenuButton
onready var primary_dd: OptionButton = $VBoxContainer/Selection/PrimaryWeaponSelect/MenuButton
onready var secondary_dd: OptionButton = $VBoxContainer/Selection/SecondaryWeaponSelect/MenuButton
onready var pilot_dd: OptionButton = $VBoxContainer/Selection/PilotSelect/MenuButton
onready var controller_dd: OptionButton = $VBoxContainer/LaunchOptions/ControllerOption

func _ready():
	for i in Client.VEHICLES:
		vehicle_dd.add_item(Client.VEHICLES[i].name)
	
	for i in Client.CONTROLLERS:
		controller_dd.add_item(i)
	
	for i in [
		"Autocannon",
		"120 Smooth"
	]:
		for j in [primary_dd, secondary_dd]:
			j.add_item(i)
	for i in [
		"Ranger",
		"Zero",
		"Gardner",
	]:
		pilot_dd.add_item(i)


func _on_StartButton_pressed():
	get_tree().change_scene("res://World.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_MenuButton_item_selected(index):
	Client.set_vehicle_selection(index)


func _on_ControllerOption_item_selected(index):
	Client.set_controller_selection(index)
