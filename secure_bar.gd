extends Node2D
# CONSTANTS AND VARIABLES
# The maximum health value of the bar
const MAX_HEALTH = 100

# Current health value (initially set to max)
var health = MAX_HEALTH

# References to UI nodes in the scene
@onready var bar = $HealthBar              # The health/progress bar
@onready var timer = $HealthTimer          # Timer that reduces health over time
@onready var increase_button = $Increase   # Button to increase health
@onready var pause_button = $Pause         # Button to pause health decrease
@onready var decrease_button = $Decrease   # Button to decrease health

#  STYLE DEFINITIONS
# Style for flashing white effect
var white_flash_style := StyleBoxFlat.new()

# Styles to represent different health levels
var full_style := StyleBoxFlat.new()
var green_style := StyleBoxFlat.new()
var yellow_style := StyleBoxFlat.new()
var orange_style := StyleBoxFlat.new()
var red_style := StyleBoxFlat.new()
var dark_red_style := StyleBoxFlat.new()

# Boolean to track if the health decrease is paused
var is_paused = false

#  INITIALIZATION 
func _ready() -> void:
	# Set colors for each health level
	full_style.bg_color = Color("1ec1f1")
	green_style.bg_color = Color("58ce3b")
	yellow_style.bg_color = Color("e7f50e")
	orange_style.bg_color = Color("f5a10e")
	red_style.bg_color = Color("ff3535")
	dark_red_style.bg_color = Color("810000")
	white_flash_style.bg_color = Color("ffffff")

	# Set the maximum value of the progress bar and apply starting visuals
	bar.max_value = MAX_HEALTH
	set_health_bar()

	# Connect the timer to a function that decreases health over time
	timer.timeout.connect(_on_HealthTimer_timeout)

	# Define button styles: dark gray by default, white on hover
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color("#1F1F1F")  # Dark gray
	#changed hex code
	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color("ffffff")    # White

	# Apply styles to all three buttons
	for button in [increase_button, pause_button, decrease_button]:
		button.add_theme_stylebox_override("normal", normal_style)
		button.add_theme_stylebox_override("hover", hover_style)

#  BAR COLOR UPDATE BASED ON HEALTH 
func set_health_bar() -> void:
	bar.value = health

	# Calculate percentage and change color based on health range
	var percentage: float = float(health) * 100.0 / MAX_HEALTH

	if percentage == 100:
		bar.add_theme_stylebox_override("fill", full_style)
	elif percentage > 75:
		bar.add_theme_stylebox_override("fill", green_style)
	elif percentage > 50:
		bar.add_theme_stylebox_override("fill", yellow_style)
	elif percentage > 25:
		bar.add_theme_stylebox_override("fill", orange_style)
	elif percentage > 5:
		bar.add_theme_stylebox_override("fill", red_style)
	else:
		bar.add_theme_stylebox_override("fill", dark_red_style)

#  VISUAL FLASH EFFECT 
func flash_bar() -> void:
	# Briefly flash the bar white twice for visual feedback
	for i in range(2):
		bar.add_theme_stylebox_override("fill", white_flash_style)
		await get_tree().create_timer(0.1).timeout
		set_health_bar()
		await get_tree().create_timer(0.1).timeout

#  HEALTH LOGIC 
func damage(amount := 1) -> void:
	# Subtract health and update visuals
	health -= amount
	health = max(health, 0)
	set_health_bar()

func heal(amount := 10) -> void:
	# Add health and update visuals
	health += amount
	health = min(health, MAX_HEALTH)
	set_health_bar()

#  TIMER EVENT: AUTOMATIC DAMAGE 
func _on_HealthTimer_timeout() -> void:
	# Only apply damage if not paused
	if not is_paused:
		damage()

#  BUTTON FUNCTIONS 
# Increase button: adds 10 health and flashes the bar
func _on_increase_pressed() -> void:
	heal(10)
	flash_bar()

# Decrease button: subtracts 15 health and flashes the bar
func _on_decrease_pressed() -> void:
	damage(15)
	flash_bar()

# Pause button: pauses auto-damage for 3 seconds and flashes the bar
func _on_pause_pressed() -> void:
	if not is_paused:
		is_paused = true
		await get_tree().create_timer(3.0).timeout
		is_paused = false
	flash_bar()
