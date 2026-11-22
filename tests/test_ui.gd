extends SceneTree

const App := preload("res://scripts/main.gd")
var failures := 0


func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)


func press_at(app: Node, position: Vector2) -> void:
	app._handle_contact(position, true)
	app._handle_contact(position, false)


func _initialize() -> void:
	var app = App.new()
	root.add_child(app)
	await process_frame
	check(app.page == "menu", "inicia no menu")
	press_at(app, Vector2(300, 1110))
	check(app.page == "catalog", "catálogo acessível")
	press_at(app, Vector2(300, 1160))
	check(app.page == "menu", "catálogo retorna")
	press_at(app, Vector2(300, 1200))
	check(app.page == "pro", "página Pro acessível")
	press_at(app, Vector2(300, 1130))
	check(app.page == "menu", "página Pro retorna")
	press_at(app, Vector2(300, 1020))
	check(app.page == "game", "inicia partida")
	press_at(app, Vector2(200, 1100))
	check(app.paused, "pausa partida")
	press_at(app, Vector2(200, 1100))
	check(not app.paused, "retoma partida")
	press_at(app, Vector2(500, 1100))
	check(app.page == "menu", "retorna ao menu")
	app.queue_free()
	print("UI: %s" % ("OK" if failures == 0 else "%d falhas" % failures))
	quit(0 if failures == 0 else 1)
