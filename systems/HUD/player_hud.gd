extends CanvasLayer

@onready var WhiteBar = %WhiteBar
@onready var BarChaser = %BarChaser
var style

func _ready():
	style = BarChaser.get_theme_stylebox("fill") as StyleBoxFlat
	Events.player_fuel_updated.connect(_on_player_fuel_updated)

func _on_player_fuel_updated(current_fuel: float, max_fuel: float):
	WhiteBar.max_value = max_fuel
	WhiteBar.value = current_fuel
	
	style.bg_color = Color.RED.lerp(Color.CYAN, current_fuel / max_fuel)
	var tween = create_tween()
	tween.tween_property(BarChaser, "value", WhiteBar.value, 0.5).set_trans(Tween.TRANS_SINE)
	
	if BarChaser.value < 3:
		BarChaser.value = 0
	
	if WhiteBar.value < 25:
		var tween2 = create_tween()
		tween2.tween_property($BarContainer, "modulate:a", 1, 0.5)
	else:
		var tween3 = create_tween()
		tween3.tween_property($BarContainer, "modulate:a", 1, 0.5)
