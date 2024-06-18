extends Node3D

#Current Weapon Scene
var steamPunk_rifle: PackedScene = load("res://Scenes/Rifle.tscn")

#An array of weapons/items acting as an inventory 
var weapon_stack: Array = []
var current_weapon_index: int = 0
var current_weapon: Node = null

func _ready():
	#Initialize weapon stack
	print("steamPunk_rifle type:", typeof(steamPunk_rifle))  # Debug type
	if steamPunk_rifle is PackedScene:
		print("steamPunk_rifle is a PackedScene")
		weapon_stack.append(steamPunk_rifle)
		equip_weapon(current_weapon_index)
	else:
		print("Error: steamPunk_rifle is not a PackedScene")


func equip_weapon(index: int):
	#Unequip current weapon if there is one
	if get_child_count() > 0:
		var current_weapon = get_child(0)
		remove_child(current_weapon)

		
	#Equip new weapon
	current_weapon_index = index
	if weapon_stack[current_weapon_index] is PackedScene:
		var new_weapon = weapon_stack[current_weapon_index].instantiate()
		new_weapon.transform = Transform3D()  # Reset transform to avoid unexpected transformations
		add_child(new_weapon)
	# Debugging
		print("Equipped weapon:", new_weapon.name)
	else:
		print("Error: weapon_stack item is not a PackedScene")

	
func switch_weapon(direction: int):
	#Cycle through the weapons
	current_weapon_index = (current_weapon_index + direction) % weapon_stack.size()
	if(current_weapon_index < 0):
		current_weapon_index = weapon_stack.size() - 1
	equip_weapon(current_weapon_index)
