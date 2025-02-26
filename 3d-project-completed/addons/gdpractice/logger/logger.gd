const CheckRichTextLabel := preload("check_rich_text_label.gd")

static var _js_interface: JavaScriptObject = null
static var _title_rich_text_label: RichTextLabel = null
static var _checks_v_box_container: VBoxContainer = null


static func setup(
	title_rich_text_label: RichTextLabel, checks_v_box_container: VBoxContainer
) -> void:
	if is_instance_valid(title_rich_text_label):
		_title_rich_text_label = title_rich_text_label

	if is_instance_valid(checks_v_box_container):
		_checks_v_box_container = checks_v_box_container

	if OS.has_feature("web"):
		_js_interface = JavaScriptBridge.get_interface("gdquest")


static func log_title(message: String) -> void:
	print_rich("\n%s" % message)

	if _title_rich_text_label == null:
		return
	_title_rich_text_label.text = message


static func log(message: String) -> void:
	print_rich(message)
	if _checks_v_box_container == null:
		return
	var check_rich_text_label := CheckRichTextLabel.new()
	_checks_v_box_container.add_child(check_rich_text_label)
	check_rich_text_label.text = message


static func add_separator() -> void:
	if _checks_v_box_container == null:
		return
	_checks_v_box_container.add_child(HSeparator.new())
