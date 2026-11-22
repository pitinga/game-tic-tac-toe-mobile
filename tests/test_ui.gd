extends SceneTree

const App := preload("res://scripts/main.gd")
var failures := 0


func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)


func tap_at(app: Node, pos: Vector2) -> void:
	app._handle_contact(pos, true)
	app._handle_contact(pos, false)


func touch(app: Node, index: int, pos: Vector2, pressed: bool, canceled := false) -> void:
	var viewport: Vector2 = app.get_viewport_rect().size
	var factor: float = minf(viewport.x / 720.0, viewport.y / 1280.0)
	var offset: Vector2 = (viewport - Vector2(720, 1280) * factor) * 0.5
	var event := InputEventScreenTouch.new()
	event.index = index
	event.position = pos * factor + offset
	event.pressed = pressed
	event.canceled = canceled
	app._unhandled_input(event)


func start(app: Node) -> void:
	app.page = "menu"
	tap_at(app, Vector2(300, 1020))
	check(app.page == "game", "partida iniciada")


func _initialize() -> void:
	var app = App.new()
	app.set_meta("test_mode", true)
	root.add_child(app)
	await process_frame

	check(app.page == "menu", "abre no menu")
	tap_at(app, Vector2(300, 1110))
	check(app.page == "catalog", "catálogo acessível")
	app._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(app.page == "menu", "voltar do catálogo")
	tap_at(app, Vector2(300, 1200))
	check(app.page == "pro", "página Pro acessível")
	app._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(app.page == "menu", "voltar do Pro")
	app._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(app.exit_requested, "voltar do menu solicita saída")
	app.exit_requested = false

	start(app)
	tap_at(app, Vector2(200, 1100))
	check(app.paused, "pausa partida")
	tap_at(app, Vector2(200, 1100))
	check(not app.paused, "retoma partida")

	# Oráculo observável: o código antigo reiniciava a partida ao soltar
	# na área RECOMEÇAR, embora página e pausa não mudassem.
	app.rules.score = 7
	app._handle_contact(Vector2(360, 900), true)
	app._handle_contact(Vector2(360, 1000), false)
	check(app.rules.score == 7, "arraste tabuleiro → RECOMEÇAR conserva estado")
	app._handle_contact(Vector2(360, 900), true)
	app._handle_contact(Vector2(200, 1100), false)
	check(not app.paused, "arraste tabuleiro → PAUSAR não pausa")
	app._handle_contact(Vector2(360, 900), true)
	app._handle_contact(Vector2(500, 1100), false)
	check(app.page == "game", "arraste tabuleiro → MENU não navega")

	# Caminho real _unhandled_input, incluindo cancelamento e segundo dedo.
	app.rules.score = 7
	touch(app, 2, Vector2(360, 1000), true)
	touch(app, 3, Vector2(360, 1000), true)
	check(app.active_index == 2, "segundo dedo não assume captura")
	touch(app, 2, Vector2(360, 1000), false, true)
	check(app.active_index == -1 and not app.touching, "cancelamento solta captura")
	check(app.rules.score == 7, "cancelamento não reinicia")
	touch(app, 4, Vector2(360, 1000), true)
	app._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(app.active_index == -1 and not app.touching and app.press_target == "", "perda de foco limpa captura")
	touch(app, 5, Vector2(500, 1100), true)
	touch(app, 5, Vector2(500, 1100), false)
	check(app.page == "menu", "toque após perda de foco responde")
	start(app)
	touch(app, 0, Vector2(200, 1100), true)
	app._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
	check(app.active_index == -1 and not app.touching and app.paused, "pausa Android limpa captura e pausa jogo")
	tap_at(app, Vector2(500, 1100))
	check(app.page == "menu", "menu acessível após pausa")

	start(app)
	app.rules.ended = true
	app.rules.message = "Fim"
	tap_at(app, Vector2(200, 1100))
	check(not app.paused, "PAUSAR não encobre fim de jogo")
	app._notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	check(app.page == "menu" and app.paused, "voltar da partida para menu")

	if app.rules.title == "Snake":
		start(app)
		app._handle_contact(Vector2(400, 500), true)
		app._handle_contact(Vector2(400, 120), false)
		check(app.rules.next_heading == Vector2i.UP, "swipe Snake vale fora do quadro")
	elif app.rules.title == "2048":
		start(app)
		app.rules.board.fill(0)
		app.rules.board[0] = 2
		app._handle_contact(Vector2(400, 500), true)
		app._handle_contact(Vector2(700, 500), false)
		check(app.rules.board[3] == 2, "swipe 2048 vale fora do quadro")

	app.queue_free()
	print("UI: %s" % ("OK" if failures == 0 else "%d falhas" % failures))
	quit(0 if failures == 0 else 1)
