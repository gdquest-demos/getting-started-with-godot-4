@tool
extends PanelContainer

const TEXT := """You are viewing the [b]%s[/b] file which is part of the solution for [b]%s[/b] practice.

[b]Instead, to complete the practice[/b], you need to open the [b][url]%s[/url][/b] file.
"""

@onready var rich_text_label: RichTextLabel = %RichTextLabel


func _ready() -> void:
	rich_text_label.meta_clicked.connect(_on_rich_text_label_meta_clicked)


func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	EditorInterface.open_scene_from_path(str(meta))


func set_text(scene_path: String, practice_path: String, practice_title: String) -> void:
	rich_text_label.text = TEXT % [scene_path, practice_title, practice_path]
