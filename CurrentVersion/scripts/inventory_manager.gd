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

static var inventory: Array[inventory_item] = []
static var inventoryUi: inventory_ui = null

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
	var found: bool = false
	var result = null
	for recipe in mergeDictionary:
		if(ingredients.size() == recipe["ingredients"].size()):
			found = true
			result = recipe["result"]
			for ingredient in ingredients:
				if(not recipe["ingredients"].has(ingredient)):
					found = false
					break
			if(found):
				break
	if(found):
		return result
	return ""

static func translate_code_to_item(code: String, quantity: int) -> Dictionary:
	var name: String = translate_code_to_full_string(code)
	var texture: Texture2D = get_texture_for_code(code)
	# return {"type": merge_result, "quantity": quantity, "effect": merge_result, "texture": merge_item.item_texture, "name": merge_result}
	return {"type": name, "quantity": quantity, "effect": name, "texture": texture, "name": name}

static func translate_full_string_to_code(full: String) -> String:
	match full:
		"Nox Lily Thorns":
			return "NLT"
		"Hollow Tree Resin":
			return "HTR"
		"Weeping Dandelion Milk":
			return "WDM"
		"Silent Bog Dew":
			return "SBD"
	if(full.split(" ").size() == 2):
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
		if(str.length() == 2):
			return str
		
	return full

static func translate_code_to_full_string(code: String) -> String:
	match code:
		"YT": return "Yellow Triangle"
		"YS": return "Yellow Square"
		"YC": return "Yellow Circle"
		"BT": return "Blue Triangle"
		"BS": return "Blue Square"
		"BC": return "Blue Circle"
		"GT": return "Green Triangle"
		"GS": return "Green Square"
		"GC": return "Green Circle"
		#
		"NLT": return "Nox Lily Thorns"
		"HTR": return "Hollow Tree Resin"
		"WDN": return "Weeping Dandelion Milk"
		"SBD": return "Silent Bog Dew"
	return code

#ToDo:
static func get_effect_from_code(code: String) -> String:
	return code

#ToDo:
static func get_type_from_code(code: String) -> String:
	return code

#ToDo:
static func get_texture_for_code(code: String) -> Texture2D:
	return Texture2D.new()

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
		if(merge_result == ""):
			print("No such recipe exists")
			pass
		else:
			print(str("Merging ", to_merge[0]["item"].item_name, " and ", merge_item.item_name, ", resulting in ", merge_result))
			Global.remove_item(to_merge[0]["item"].item_type, to_merge[0]["item"].item_effect)
			Global.remove_item(merge_item.item_type, merge_item.item_effect)
			Global.add_item(translate_code_to_item(merge_result, 1))
			pass
		to_merge.clear()
		merge_panel.hide()

# Is there an active merge rn?
static func is_merging() -> bool:
	return to_merge.size() > 0

