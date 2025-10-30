# time_system.gd
# A modular, non-node class for handling game time.
# It is instantiated and "ticked" by the SimulationManager.

class_name TimeSystem
extends RefCounted # Use RefCounted so it's auto-managed

# --- Signals ---
signal minute_passed(current_minute: int, current_hour: int)
signal hour_passed(current_hour: int, current_day: int)
signal day_passed(current_day: int, current_season: int)
signal season_passed(current_season: int)

# --- Time State ---
enum Season { SPRING, SUMMER, FALL, WINTER }

var current_minute: int = 0
var current_hour: int = 6 # Start at 6 AM
var current_day: int = 1
var current_season: Season = Season.SPRING

# --- Config ---
# How many real-world seconds per game minute?
var seconds_per_minute: float = 0.7
var _time_accumulator: float = 0.0

# --- Public API ---

## This is the "tick" function called by SimulationManager.
func update(delta: float):
	_time_accumulator += delta
	
	if _time_accumulator >= seconds_per_minute:
		_time_accumulator -= seconds_per_minute
		_advance_minute()

func _advance_minute():
	current_minute += 1
	
	if current_minute >= 60:
		current_minute = 0
		_advance_hour()
		
	minute_passed.emit(current_minute, current_hour)
	# print("Time: %s:%s" % [current_hour, str(current_minute).pad_zeros(2)]) # Uncomment for debugging

func _advance_hour():
	current_hour += 1
	
	if current_hour >= 24:
		current_hour = 0
		_advance_day()
		
	hour_passed.emit(current_hour, current_day)

func _advance_day():
	# In Stardew, time "stops" at 2 AM (which is hour 26)
	# This logic would be more complex to handle that.
	# For now, a simple 24-hour clock.
	current_day += 1
	
	if current_day > 28:
		current_day = 1
		_advance_season()
		
	day_passed.emit(current_day, current_season)
	
	# This is where you trigger "end of day" logic
	# (e.g., save game, grow crops, process machines).

func _advance_season():
	current_season = (current_season + 1) % 4 # Loop back to SPRING
	season_passed.emit(current_season)

# --- Getters ---
func get_time_string() -> String:
	return "%s:%s" % [current_hour, str(current_minute).pad_zeros(2)]
