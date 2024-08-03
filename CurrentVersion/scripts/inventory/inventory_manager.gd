class_name InventoryManager

static var mergeDictionary = [
	{"ingredients": ["NLT", "HTR"], "result": "YT"},
	{"ingredients": ["Gloomstones", "HTR"], "result": "YS"},
	{"ingredients": ["Murkberries", "HTR"], "result": "YC"},
	{"ingredients": ["NLT", "WDM"], "result": "BT"},
	{"ingredients": ["Gloomstones", "WDM"], "result": "BS"},
	{"ingredients": ["Murkberries", "WDM"], "result": "BC"},
	{"ingredients": ["NLT", "SBD"], "result": "GT"},
	{"ingredients": ["Gloomstones", "SBD"], "result": "GS"},
	{"ingredients": ["Murkberries", "SBD"], "result": "GC"}
]

static var failed_potion = {"result": "F", "code": "F", "full": "Mysterious Potion", "effect": "???", "texture": GlobalStrings.texture_potion_failed}

static var inventory: Array[inventory_item] = []
static var inventoryUi: inventoryui = null

static var to_merge: Array[Dictionary] = []

# Returns array of recipes.		*ToDo: make Recipes their own class 
static func get_recipes_for_ingredient(ingredient: String) -> Array[Dictionary]:
	var recipes = []
	for recipe in mergeDictionary:
		if(recipe["ingredients"].has(ingredient)):
			recipes.append(recipe)
	return recipes

# Returns merge result from ingredients
static func get_merge_result(ingredients: Array[String]) -> String:
	var ings = ingredients
	for i in range(ings.size()):
		ings[i] = translate_full_string_to_code(ings[i])
		pass
	var found: bool = false
	var result = null
	for recipe in mergeDictionary:
		if(ings.size() == recipe["ingredients"].size()):
			found = true
			result = recipe["result"]
			for ingredient in ings:
				if(not recipe["ingredients"].has(ingredient)):
					found = false
					break
			if(found):
				break
	if(found):
		return result
	return failed_potion["code"]

static func translate_code_to_item(code: String, quantity: int) -> Dictionary:
	var name: String = translate_code_to_full_string(code)
	var texture: Texture2D = get_texture_for_code(code)
	# return {"type": merge_result, "quantity": quantity, "effect": merge_result, "texture": merge_item.item_texture, "name": merge_result}
	return {"type": get_type_from_code(code), "quantity": quantity, "effect": get_effect_from_code(code), "texture": texture, "name": name, "scene_path": "res://scenes/inventory_item.tscn"}

static func translate_full_string_to_code(full: String) -> String:
	var failed_full = failed_potion["full"]
	match full:
		"Nox Lily Thorns":
			return "NLT"
		"Hollow Tree Resin":
			return "HTR"
		"Weeping Dandelion Milk":
			return "WDM"
		"Silent Bog Dew":
			return "SBD"
		failed_full:
			return failed_potion["code"]
	
	if(full.split(" ").size() == 3):
		var str = ""
		var words = full.split(" ")
		match words[0]:
			"Yellow":
				str = str(str, "Y")
			"Blue":
				str = str(str, "B")
			"Green":
				str = str(str, "G")
		match words[0]:
			"Triangle":
				str = str(str, "T")
			"Square":
				str = str(str, "S")
			"Circle":
				str = str(str, "C")
		if(str.length() == 2 && words[2] == "Potion"):
			return str
		
	return full

static func translate_code_to_full_string(code: String) -> String:
	if(code == failed_potion["code"]): return failed_potion["full"]
	match code:
		"YT": return "Yellow Triangle Potion"
		"YS": return "Yellow Square Potion"
		"YC": return "Yellow Circle Potion"
		"BT": return "Blue Triangle Potion"
		"BS": return "Blue Square Potion"
		"BC": return "Blue Circle Potion"
		"GT": return "Green Triangle Potion"
		"GS": return "Green Square Potion"
		"GC": return "Green Circle Potion"
		#
		"NLT": return "Nox Lily Thorns"
		"HTR": return "Hollow Tree Resin"
		"WDN": return "Weeping Dandelion Milk"
		"SBD": return "Silent Bog Dew"
	return code

#ToDo:
static func get_effect_from_code(code: String) -> String:
	if(code.length() == 2 && "YBG".contains(code[0]) && "TSC".contains(code[1])):
		return "Cure"
	if(code == failed_potion["code"]): return failed_potion["effect"]
	return "None"

#ToDo:
static func get_type_from_code(code: String) -> String:
	if(code.length() == 2 && "YBG".contains(code[0]) && "TSC".contains(code[1])):
		return "Consumable"
	if(code == failed_potion["code"]): return "Consumable"
	return "Ingredient"

#ToDo:
static func get_texture_for_code(code: String) -> Texture2D:
	var path: String = ""
	if(code == failed_potion["code"]): path = failed_potion["texture"]
	match code:
		"YT":
			path = GlobalStrings.texture_potion_yellow_triangle
		"YS":
			path = GlobalStrings.texture_potion_yellow_square
		"YC":
			path = GlobalStrings.texture_potion_yellow_circle
		"BT":
			path = GlobalStrings.texture_potion_blue_triangle
		"BS":
			path = GlobalStrings.texture_potion_blue_square
		"BC":
			path = GlobalStrings.texture_potion_blue_circle
		"GT":
			path = GlobalStrings.texture_potion_green_triangle
		"GS":
			path = GlobalStrings.texture_potion_green_square
		"GC":
			path = GlobalStrings.texture_potion_green_circle
		#
		"NLT": path = GlobalStrings.texture_ingredient_noxLily
		"HTR": path = GlobalStrings.texture_ingredient_hollowTree
		"WDN": path = GlobalStrings.texture_ingredient_weepingDandelion
		"SBD": path = GlobalStrings.texture_ingredient_dewTree
		"Murkberries": path = GlobalStrings.texture_ingredient_murkberryBush
		"Gloomstones": path = GlobalStrings.texture_ingredient_gloomstones
		_:
			pass
	if(path.length() > 0):
		var img = Image.new()
		img.load(path)
		return ImageTexture.create_from_image(img)
		#return ImageTexture.new().create_from_image(img)
	return Texture2D.new() #return empty texture

# Handles merging (call when selecting an item to add to a merge)
static func handle_merge(merge_item: inventory_item, slot: inventory_slot):
	print("handle merge called")
	print(str("size: ", to_merge.size()))
	inventoryUi = slot.get_parent().get_parent()
	var merge_panel = inventoryUi.merge_panel
	if(to_merge.size() < 1):
		print("first item")
		to_merge.append({"item": merge_item, "slot": slot})
		#to_merge = [{"item": merge_item, "slot": slot}]
		print(str("size: ", to_merge.size()))
		if(merge_panel != null):
			var icon: Sprite2D = merge_panel.find_child("Item1", false).find_child("itemIcon")
			icon.texture = merge_item.item_texture
			adjust_texture_size(icon)
			print("show")
			merge_panel.show()
	elif(to_merge[0]["slot"] == slot):
		print("chose to merge with self. cancel merging")
		to_merge.clear()
		merge_panel.hide()
	else:
		print(str("megre ", to_merge[0]["item"].item_name, " with ", merge_item.item_name))
		# print("Can't actually merge yet. Clear merge")
		var merge_result = get_merge_result([to_merge[0]["item"].item_name, merge_item.item_name])
		#merge_result = "YT"
		if(merge_result == ""):
			print("No such recipe exists")
			pass
		else:
			print(str("Merging ", to_merge[0]["item"].item_name, " and ", merge_item.item_name, ", resulting in ", merge_result))
			Global.remove_item(to_merge[0]["item"].item_type, to_merge[0]["item"].item_name) #item_effect
			Global.remove_item(merge_item.item_type, merge_item.item_name)
			Global.add_item(translate_code_to_item(merge_result, 1))
			pass
		to_merge.clear()
		merge_panel.hide()

# Is there an active merge rn?
static func is_merging() -> bool:
	return to_merge.size() > 0

static func adjust_texture_size(icon: Sprite2D):
	var scaleFrom: float = max(icon.texture.get_height(), icon.texture.get_width())
	if(scaleFrom > 40):
		icon.scale = Vector2(40/scaleFrom, 40/scaleFrom)
		print(str("from ", scaleFrom, " by ", icon.scale, "(", 40/scaleFrom, ")"))
	else:
		icon.scale = Vector2(1, 1)
	pass

static func initialize_merge() -> void:
	to_merge = []

static func cancel_merge() -> void:
	to_merge = []
	if(inventoryUi != null and inventoryUi.merge_panel != null):
		var panel = inventoryUi.merge_panel
		panel.hide()
		for child in panel.find_children("Item[0-9]"):
			child.find_child("itemIcon").texture = Texture2D.new()
