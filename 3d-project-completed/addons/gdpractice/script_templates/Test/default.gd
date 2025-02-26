extends "res://addons/gdpractice/tester/test.gd"


func _setup_state() -> void:
	if not _practice.velocity.is_zero_approx():
		_solution.velocity = _practice.velocity


func _setup_populate_test_space() -> void:
	await _connect_timed(1.0, get_tree().process_frame, _populate_test_space)


func _populate_test_space() -> void:
	_test_space.append({
		practice_position = _practice.position,
		solution_position = _solution.position,
		delta = get_process_delta_time(),
	})


func _test_velocity_is_not_zero() -> String:
	if _practice.velocity.is_zero_approx():
		return "velocity shouldn't be zero"
	return ""


func _test_position_changes_every_frame() -> String:
	var fail_predicate := func(x: Dictionary, y: Dictionary) -> bool:
		return x.practice_position.is_equal_approx(y.practice_position)
	if not _is_sliding_window_pass(fail_predicate):
		return "position doesn't change every frame"
	return ""


func _test_movement_takes_delta_into_account() -> String:
	var fail_predicate := func(x: Dictionary, y: Dictionary) -> bool:
		return not is_zero_approx(
			y.practice_position.distance_to(x.practice_position)
			/ _practice.velocity.length()
			- x.delta
		)
	if not _is_sliding_window_pass(fail_predicate):
		return "movement computation doesn't take delta into account"
	return ""


func _test_position_is_computed_correctly() -> String:
	var predicate := func(x: Dictionary) -> bool: return x.practice_position == x.solution_position
	if not _test_space.all(predicate):
		return "practice position doesn't match solution position"
	return ""
