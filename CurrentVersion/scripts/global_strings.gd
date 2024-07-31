class_name GlobalStrings

#texture paths
const texture_path = {
	potion = {
		blue_circle = texture_potion_blue_circle,
		green_circle = texture_potion_green_circle,
		yellow_circle = texture_potion_yellow_circle,
		blue_triangle = texture_potion_blue_triangle,
		green_triangle = texture_potion_green_triangle,
		yellow_triangle = texture_potion_yellow_triangle,
		blue_square = texture_potion_blue_square,
		green_square = texture_potion_green_square,
		yellow_square = texture_potion_yellow_square,
		failed = texture_potion_failed
	},

	overwold_resource = {
		ingredient = {
			nox_lily = texture_ingredient_noxLily,
			hollow_tree = texture_ingredient_hollowTree,
			weeping_dandelion = texture_ingredient_weepingDandelion,
			dew_tree = texture_ingredient_dewTree,
			murkberry_bush = texture_ingredient_murkberryBush,
			gloomstone = texture_ingredient_gloomstones
		},
		environmental = {
			trees = {
				live = texture_environment_object_outside_tree,
				dark = texture_environment_object_outside_darkTree
			}
		},
		tileset = {
			ground = texture_tileset_ground
		}
	},
	
	npc = {
		bar_owner = {
			overworld_sprite = "res://characters/Bar_Owner_Overworld.png"
		},
		tavern_customers = {
			sprite_sheet = "res://characters/SpriteSheet.png"
		}
	},
	
	player = {
		sprite_sheet = "res://characters/mainPlayer.png"
	},
	
	enemy = {
		minion_goober = {
			sprite = "res://characters/MinionGoober.png"
		}
	},
	
	overlay = {
		npc = {
			cursed = texture_overlay_npc_shadow
		}
	},
	
	structure = {
		tavern = {
			outside = texture_structure_tavern_outside
		}
	}
}

const texture_potion_blue_circle: String = "res://objects/consumables/BlueCirclePotionAccessible.png" #"res://objects/consumables/BlueCirclePotion.png"
const texture_potion_green_circle: String = "res://objects/consumables/GreenCirclePotionAccessible.png" #"res://objects/consumables/GreenCirclePotion.png"
const texture_potion_yellow_circle: String = "res://objects/consumables/YellowCirclePotionAccessible.png" #"res://objects/consumables/YellowCirclePotion.png"
const texture_potion_blue_triangle: String = "res://objects/consumables/BlueTrianglePotion.png"
const texture_potion_green_triangle: String = "res://objects/consumables/GreenTrianglePotion.png"
const texture_potion_yellow_triangle: String = "res://objects/consumables/YellowTrianglePotion.png"
const texture_potion_blue_square: String = "res://objects/consumables/BlueSquarePotion.png"
const texture_potion_green_square: String = "res://objects/consumables/GreenSquarePotion.png"
const texture_potion_yellow_square: String = "res://objects/consumables/YellowSquarePotion.png"
const texture_potion_failed: String = "res://objects/consumables/DarkPotion.png"

const texture_ingredient_noxLily: String = "res://objects/NoxLily.png"
const texture_ingredient_hollowTree: String = "res://objects/HollowTree.png"
const texture_ingredient_weepingDandelion: String = "res://objects/WeepingDandelion.png"
const texture_ingredient_dewTree: String = "res://objects/DewTree.png"
const texture_ingredient_murkberryBush: String = "res://objects/MurkberryBush.png"
const texture_ingredient_gloomstones: String = "res://objects/Gemstones.png"

const texture_overlay_npc_shadow: String = "res://objects/Shadow.png"

const texture_structure_tavern_outside: String = "res://objects/Tavern2.png"

const texture_environment_object_outside_tree: String = "res://objects/Tree.png"
const texture_environment_object_outside_darkTree: String = "res://objects/DarkTree.png"

const texture_tileset_ground: String = "res://objects/Ground_Tileset.png"

#audio
const audio_paths = {
	background_music = {
		forest = {
			default = "res://audio/Forest (Light's End Official Score).mp3"
		},
		tavern = {
			default = "res://audio/Tavern (Light's End Official Score).mp3"
		}
	},
	sound_effects = {
		player = {
			footsteps = {
				forest_default = "res://audio/footsteps/Grass_1.wav",
				tavern_default = "res://audio/footsteps/Wood_1.wav"
			},
			actions = {
				bag_open = "res://audio/Bag Open_1.wav"
			}
		}
	}
}
