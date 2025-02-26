static var _js_interface: JavaScriptObject = null

enum Type {
	TESTER,
	TEST,
	REQUIREMENT,
	REQUIREMENT_METHODS,
	REQUIREMENT_PROPERTIES,
	REQUIREMENT_SIGNALS,
	REQUIREMENT_CONSTANTS,
	REQUIREMENT_NODES,
}

enum Status {DONE, PASS, FAIL, SKIP, TITLE}

var type := Type.TESTER
var status := Status.FAIL
var path := ""
var message := ""
var requirement_context := ""
var json: Variant:
	get:
		var result: Variant = JavaScriptBridge.create_object("Object")
		result.type = Type.keys()[type].to_lower()
		result.status = Status.keys()[status].to_lower()
		result.path = path
		result.message = message
		return result


static func setup() -> void:
	if OS.has_feature("web"):
		_js_interface = JavaScriptBridge.get_interface("gdquest")


func _init(type: int, status: Status, path: String, message: String) -> void:
	if _js_interface != null:
		self.type = type
		self.status = status
		self.path = path
		self.message = message
		_js_interface.log(json)
