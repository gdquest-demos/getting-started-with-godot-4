extends MarginContainer

const ICON_PATH := "../../assets/icons/%s.svg"
const ICON_WIDTH := {"fail": 15, "pass": 20}

@onready var panel_container: PanelContainer = %PanelContainer
@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var extra_rich_text_label: RichTextLabel = %ExtraRichTextLabel
@onready var report_texture_rect: TextureRect = %ReportTextureRect

@onready var _variations := {
	check_default =
	{
		self: {theme_type_variation = &"MarginContainerTesterCheck"},
		panel_container: {theme_type_variation = &"PanelContainerTesterCheck"},
		rich_text_label: {theme_type_variation = &"RichTextLabelTesterDefault"},
		extra_rich_text_label: {theme_type_variation = &"RichTextLabelTesterCheckHint", visible = false},
		report_texture_rect: {modulate = Color.TRANSPARENT},
	},
	check_fail =
	{
		self: {theme_type_variation = &"MarginContainerTesterCheck"},
		panel_container: {theme_type_variation = &"PanelContainerTesterCheck"},
		rich_text_label: {theme_type_variation = &"RichTextLabelTesterFail"},
		extra_rich_text_label: {theme_type_variation = &"RichTextLabelTesterCheckHint", visible = false},
		report_texture_rect:
		{
			texture = preload(ICON_PATH % "fail"),
			modulate = Color.WHITE,
			custom_minimum_size = ICON_WIDTH.fail * Vector2.RIGHT
		},
	},
	check_pass =
	{
		self: {theme_type_variation = &"MarginContainerTesterCheck"},
		panel_container: {theme_type_variation = &"PanelContainerTesterCheck"},
		rich_text_label: {theme_type_variation = &"RichTextLabelTesterPass"},
		extra_rich_text_label: {theme_type_variation = &"RichTextLabelTesterCheckHint", visible = false},
		report_texture_rect:
		{
			texture = preload(ICON_PATH % "pass"),
			modulate = Color.WHITE,
			custom_minimum_size = ICON_WIDTH.pass * Vector2.RIGHT
		},
	},
	check_no_subchecks_fail =
	{
		self: {theme_type_variation = &"MarginContainerTesterCheck"},
		panel_container: {theme_type_variation = &"PanelContainerTesterCheck"},
		rich_text_label: {theme_type_variation = &"RichTextLabelTesterFail"},
		extra_rich_text_label: {theme_type_variation = &"RichTextLabelTesterCheckHint", visible = true},
		report_texture_rect:
		{
			texture = preload(ICON_PATH % "fail"),
			modulate = Color.WHITE,
			custom_minimum_size = ICON_WIDTH.fail * Vector2.RIGHT
		},
	},
	check_no_subchecks_pass =
	{
		self: {theme_type_variation = &"MarginContainerTesterCheck"},
		panel_container: {theme_type_variation = &"PanelContainerTesterCheck"},
		rich_text_label: {theme_type_variation = &"RichTextLabelTesterPass"},
		extra_rich_text_label: {theme_type_variation = &"RichTextLabelTesterCheckHint", visible = false},
		report_texture_rect:
		{
			texture = preload(ICON_PATH % "pass"),
			modulate = Color.WHITE,
			custom_minimum_size = ICON_WIDTH.pass * Vector2.RIGHT
		},
	},
	subcheck_default =
	{
		self: {theme_type_variation = &"MarginContainerTesterSubCheck"},
		panel_container: {theme_type_variation = &"PanelContainerTesterCheck"},
		rich_text_label: {theme_type_variation = &"RichTextLabelTesterDefault"},
		extra_rich_text_label: {theme_type_variation = &"RichTextLabelTesterCheckHint", visible = false},
		report_texture_rect: {modulate = Color.TRANSPARENT},
	},
	subcheck_fail =
	{
		self: {theme_type_variation = &"MarginContainerTesterSubCheck"},
		panel_container: {theme_type_variation = &"PanelContainerTesterCheck"},
		rich_text_label: {theme_type_variation = &"RichTextLabelTesterFail"},
		extra_rich_text_label: {theme_type_variation = &"RichTextLabelTesterCheckHint", visible = true},
		report_texture_rect:
		{
			texture = preload(ICON_PATH % "fail"),
			modulate = Color.WHITE,
			custom_minimum_size = ICON_WIDTH.fail * Vector2.RIGHT
		},
	},
	subcheck_pass =
	{
		self: {theme_type_variation = &"MarginContainerTesterSubCheck"},
		panel_container: {theme_type_variation = &"PanelContainerTesterCheck"},
		rich_text_label: {theme_type_variation = &"RichTextLabelTesterPass"},
		extra_rich_text_label: {theme_type_variation = &"RichTextLabelTesterCheckHint", visible = false},
		report_texture_rect:
		{
			texture = preload(ICON_PATH % "pass"),
			modulate = Color.WHITE,
			custom_minimum_size = ICON_WIDTH.pass * Vector2.RIGHT
		},
	},
	requirement =
	{
		self: {theme_type_variation = &"MarginContainerTesterCheck"},
		panel_container: {theme_type_variation = &""},
		rich_text_label: {theme_type_variation = &"RichTextLabelTesterFail"},
		extra_rich_text_label: {theme_type_variation = &"RichTextLabelTesterRequirementHint", visible = true},
		report_texture_rect:
		{
			texture = preload(ICON_PATH % "fail"),
			modulate = Color.WHITE,
			custom_minimum_size = ICON_WIDTH.fail * Vector2.RIGHT
		},
	}
}


func get_variation(key: String) -> Dictionary:
	return _variations[key].duplicate(true)
