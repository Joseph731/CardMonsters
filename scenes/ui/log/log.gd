extends Control
class_name LogText

@onready var scroll_container: ScrollContainer = $PanelContainer/VBoxContainer/ScrollContainer
@onready var label: Label = $PanelContainer/VBoxContainer/ScrollContainer/VBoxContainer/Label
@onready var input_box: LineEdit = $PanelContainer/VBoxContainer/InputBox

func _ready() -> void:
	input_box.text_submitted.connect(_on_text_submitted)
	label.text = ""

@rpc("any_peer", "call_local", "reliable")
func add_message(new_text: String) -> void:	
	if label.text == "":
		label.text = new_text
	else :
		label.text += "\n" + new_text
	scroll_to_bottom()

func scroll_to_bottom() -> void:
	var v_scrollbar: VScrollBar = scroll_container.get_v_scroll_bar()
	if !v_scrollbar.changed.is_connected(_on_scrollbar_changed):
		v_scrollbar.changed.connect(_on_scrollbar_changed, CONNECT_ONE_SHOT)
	label.update_minimum_size()

func _on_scrollbar_changed() -> void:
	var v_scrollbar = scroll_container.get_v_scroll_bar()
	v_scrollbar.value = v_scrollbar.max_value

func _on_text_submitted(new_text: String) -> void:
	if new_text.strip_edges() == "":
		return
	add_message.rpc("Player: " + new_text)
	input_box.text = "" 

func _input(event: InputEvent) -> void:
	if event is InputEventMouse && event.is_pressed():
		if input_box.has_focus():
			if !input_box.get_global_rect().has_point(event.global_position):
				input_box.release_focus()
