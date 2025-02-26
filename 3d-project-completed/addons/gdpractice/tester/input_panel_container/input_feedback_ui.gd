extends Control

enum State { SAFE, NOTE, WARN }

const COLOR_YELLOW := Color("ffd500")
const COLOR_GREEN := Color("63cc5f")
const COLOR_GRAY := Color("887c9d")

const COLORS := {true: COLOR_YELLOW, false: COLOR_GRAY}

@export var state := State.SAFE:
	set(new_state):
		if state == new_state:
			return

		state = new_state
		if not is_inside_tree():
			await ready

		var is_enabled := state == State.WARN
		set_process(is_enabled)
		set_process_input(is_enabled)
		if state == State.SAFE:
			_circle_panel.self_modulate = COLOR_GREEN
			for texture_rect: TextureRect in _arrow_texture_rects:
				texture_rect.self_modulate = Color.WHITE
		else:
			for ui: Control in _arrow_texture_rects + [_circle_panel]:
				ui.self_modulate = COLOR_GRAY

@onready var _arrow_right_texture_rect: TextureRect = %ArrowRightTextureRect
@onready var _arrow_up_texture_rect: TextureRect = %ArrowUpTextureRect
@onready var _arrow_left_texture_rect: TextureRect = %ArrowLeftTextureRect
@onready var _arrow_down_texture_rect: TextureRect = %ArrowDownTextureRect
@onready var _circle_panel: Panel = %CirclePanel
@onready var _key_panel_container: PanelContainer = %KeyPanelContainer
@onready var _key_label: Label = %KeyLabel
@onready var _mouse_texture_rect: TextureRect = %MouseTextureRect
@onready var _mouse_button_texture_rect: TextureRect = %MouseButtonTextureRect

@onready var _arrow_texture_rects := [
	_arrow_right_texture_rect,
	_arrow_up_texture_rect,
	_arrow_left_texture_rect,
	_arrow_down_texture_rect,
]

func _ready() -> void:
	_arrow_right_texture_rect.visible = InputMap.has_action("move_right")
	_arrow_up_texture_rect.visible = InputMap.has_action("move_up")
	_arrow_left_texture_rect.visible = InputMap.has_action("move_left")
	_arrow_down_texture_rect.visible = InputMap.has_action("move_down")


func _process(_delta: float) -> void:
	_arrow_right_texture_rect.self_modulate = COLORS[_arrow_right_texture_rect.visible and Input.is_action_pressed("move_right")]
	_arrow_up_texture_rect.self_modulate = COLORS[_arrow_up_texture_rect.visible and Input.is_action_pressed("move_up")]
	_arrow_left_texture_rect.self_modulate = COLORS[_arrow_left_texture_rect.visible and Input.is_action_pressed("move_left")]
	_arrow_down_texture_rect.self_modulate = COLORS[_arrow_down_texture_rect.visible and Input.is_action_pressed("move_down")]


func _input(event: InputEvent) -> void:
	var is_direction := false
	if _arrow_right_texture_rect.visible and event.is_action("move_right"):
		_arrow_right_texture_rect.self_modulate = COLORS[event.is_pressed()]
		is_direction = true

	if _arrow_up_texture_rect.visible and event.is_action("move_up"):
		_arrow_up_texture_rect.self_modulate = COLORS[event.is_pressed()]
		is_direction = true

	if _arrow_left_texture_rect.visible and event.is_action("move_left"):
		_arrow_left_texture_rect.self_modulate = COLORS[event.is_pressed()]
		is_direction = true

	if _arrow_down_texture_rect.visible and event.is_action("move_down"):
		_arrow_down_texture_rect.self_modulate = COLORS[event.is_pressed()]
		is_direction = true

	if (
		not is_direction
		and event is InputEventKey
		and KEY_SPACE <= event.key_label
		and event.key_label <= KEY_Z
	):
		_key_panel_container.visible = event.pressed
		if event.key_label == KEY_SPACE:
			_key_panel_container.custom_minimum_size.x = 28
			_key_label.text = "SB"
		else:
			_key_panel_container.custom_minimum_size.x = 18
			_key_label.text = event.as_text_key_label()

	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		_mouse_texture_rect.visible = event.pressed
		_mouse_button_texture_rect.flip_h = (
			event.button_index != MOUSE_BUTTON_LEFT and event.button_index == MOUSE_BUTTON_RIGHT
		)
