extends Control
class_name ToTopOrBottomMenu

signal choice_selected(choice)

enum Choice{Top, Bottom}

@onready var background_detector: Button = $BackgroundDetector
@onready var center_container: CenterContainer = $CenterContainer
@onready var move_to_top_button: Button = %MoveToTopButton
@onready var move_to_bottom_button: Button = %MoveToBottomButton

func _ready() -> void:
	background_detector.pressed.connect(_on_background_detector_pressed)
	move_to_top_button.pressed.connect(_on_move_to_top_button_pressed)
	move_to_bottom_button.pressed.connect(_on_move_to_bottom_button_pressed)

func _on_move_to_top_button_pressed() -> void:
	choice_selected.emit(Choice.Top)
	queue_free()

func _on_move_to_bottom_button_pressed()-> void:
	choice_selected.emit(Choice.Bottom)
	queue_free()

func _on_background_detector_pressed() -> void:
	choice_selected.emit(null)
	queue_free()
