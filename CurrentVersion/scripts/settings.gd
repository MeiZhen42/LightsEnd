# Handles the settings
class_name SettingsManager

const debug_mode: bool = true

enum Difficulty {EASY, NORMAL, HARD}
static var difficulty : Difficulty = Difficulty.NORMAL :
	get:
		return difficulty
	set (value):
		if(value == null):
			difficulty = Difficulty.NORMAL # Reset to default
		elif Difficulty.has(value):
			difficulty = Difficulty.get(value)
		else:
			difficulty = clamp(value, 0, Difficulty.size())
		adjust_sanity_rates_for_difficulty(difficulty)

static var player_speed : float = 100.0 :
	get:
		return player_speed
	set (speed):
		player_speed = clamp(speed, 10, 1000)

static var player_attack_dmg : float = 10 :
	get:
		return player_attack_dmg
	set (dmg):
		player_attack_dmg = clamp(dmg, 0, 5000)

static var player_attack_range_melee : float = 30 :
	get:
		return player_attack_range_melee
	set (range):
		player_attack_range_melee = clamp(range, 0, 5000)

static var sanity_rate_decline: float = 4.5:
	get:
		return sanity_rate_decline
	set(rate):
		sanity_rate_decline = clamp(rate, 0, 50)

static var sanity_rate_regain: float = 1:
	get:
		return sanity_rate_regain
	set(rate):
		sanity_rate_regain = clamp(rate, 0, 50)

static var sanity_base_maximum: float = 100:
	get:
		return sanity_base_maximum
	set(max):
		sanity_base_maximum = clamp(max, 20, 5000)

static func adjust_sanity_rates_for_difficulty(new_difficulty: Difficulty):
	match new_difficulty:
		Difficulty.EASY:
			sanity_rate_decline = 1.5
			sanity_rate_regain = 2
		Difficulty.NORMAL:
			sanity_rate_decline = 4.5
			sanity_rate_regain = 1
		Difficulty.HARD:
			sanity_rate_decline = 10
			sanity_rate_regain = 0.75
		_:
			pass

#volume
static var volume_master: float = 0.5:
	get:
		return volume_master
	set(vol):
		volume_master = clamp(vol, 0, 1)

static var volume_music: float = 1:
	get:
		return volume_master
	set(vol):
		volume_master = clamp(vol, 0, 1)

static var volume_sfx: float = 1:
	get:
		return volume_master
	set(vol):
		volume_master = clamp(vol, 0, 1)
