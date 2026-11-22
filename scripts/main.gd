extends Node2D
## Portrait-first, asset-free game shell. A Play Store listing must be configured
## before an entry in the related-games menu becomes an installation link.

const GAME := preload("res://scripts/rules.gd")
const BG := Color("f4f7ff")
const INK := Color("293349")
const MUTED := Color("63718d")
const ACCENT := Color("365dca")
const CARD := Color("ffffff")
const BOARD := Rect2(34, 178, 652, 770)
const CATALOG := [
	["Pong Mobile", ""], ["Veste & Cria", ""],
	["Snake", ""], ["Breakout", ""], ["Jogo da Velha", ""],
	["2048", ""], ["Tap Fly", ""], ["Space Shooter", ""],
	["Memória", ""], ["Campo Minado", ""]
]

var rules = GAME.new()
var page := "menu"
var paused := false
var down := Vector2.ZERO
var down_time := 0
var touching := false
var active_index := -1
var press_target := ""


func _ready() -> void:
	rules.reset()
	queue_redraw()


func _process(delta: float) -> void:
	if page == "game" and not paused and not rules.ended:
		rules.tick(minf(delta, 0.05))
	queue_redraw()


func _draw() -> void:
	var viewport := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport), BG)
	var factor: float = minf(viewport.x / 720.0, viewport.y / 1280.0)
	var offset := (viewport - Vector2(720, 1280) * factor) / 2.0
	draw_set_transform(offset, 0.0, Vector2.ONE * factor)
	if page == "menu":
		_draw_menu()
	elif page == "game":
		_draw_game()
	elif page == "catalog":
		_draw_catalog()
	else:
		_draw_pro()
	draw_set_transform(Vector2.ZERO)


func _label(value: String, center: Vector2, size: int, color: Color = INK) -> void:
	var font := ThemeDB.fallback_font
	var width := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string(font, Vector2(center.x - width * 0.5, center.y + size * 0.35), value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _button(rect: Rect2, caption: String, prominent: bool = false) -> void:
	draw_rect(rect, ACCENT if prominent else CARD, true)
	draw_rect(rect, Color("d6dff5"), false, 2.0)
	_label(caption, rect.get_center(), 27, CARD if prominent else INK)


func _draw_menu() -> void:
	_label(rules.title, Vector2(360, 105), 58)
	_label(rules.subtitle, Vector2(360, 168), 27, MUTED)
	draw_rect(BOARD, CARD)
	rules.draw_game(self, BOARD.grow(-15))
	_button(Rect2(38, 985, 644, 74), "JOGAR", true)
	_button(Rect2(38, 1077, 644, 74), "CONHEÇA NOSSOS JOGOS")
	_button(Rect2(38, 1169, 644, 74), "VERSÃO PRO")


func _draw_game() -> void:
	_label(rules.title, Vector2(360, 62), 45)
	_label("Pontos: %d" % rules.score, Vector2(360, 124), 28, MUTED)
	draw_rect(BOARD, CARD)
	rules.draw_game(self, BOARD.grow(-10))
	if paused or rules.ended:
		var banner: String = "Pausado" if paused else (rules.message if not rules.message.is_empty() else "Fim de jogo")
		draw_rect(Rect2(50, 805, 620, 108), Color("293349"))
		_label(banner, Vector2(360, 858), 30, CARD)
	_button(Rect2(38, 976, 644, 74), "RECOMEÇAR", true)
	_button(Rect2(38, 1070, 310, 70), "CONTINUAR" if paused else "PAUSAR")
	_button(Rect2(372, 1070, 310, 70), "MENU")
	_label("Toque ou deslize na área do jogo", Vector2(360, 1200), 23, MUTED)


func _draw_catalog() -> void:
	_label("Conheça nossos jogos", Vector2(360, 86), 42)
	_label("Instale os jogos já publicados", Vector2(360, 143), 23, MUTED)
	var row := 0
	for entry in CATALOG:
		if entry[0] == rules.title:
			continue
		if row >= 9:
			break
		var y := 170 + row * 101
		draw_rect(Rect2(36, y, 648, 90), CARD)
		_label(String(entry[0]), Vector2(360, y + 34), 26)
		_label("EM BREVE" if String(entry[1]).is_empty() else "INSTALAR", Vector2(360, y + 70), 19, MUTED)
		row += 1
	_button(Rect2(36, 1130, 648, 78), "VOLTAR", true)


func _draw_pro() -> void:
	_label("Versão PRO", Vector2(360, 135), 56)
	_label("Um aplicativo, sem anúncios após a compra", Vector2(360, 215), 25)
	_label("Compras ainda não disponíveis nesta versão", Vector2(360, 510), 27, MUTED)
	_label("Sem anúncios durante as partidas", Vector2(360, 570), 26, MUTED)
	_label("Nenhuma compra fictícia será realizada", Vector2(360, 630), 25, MUTED)
	_button(Rect2(36, 1090, 648, 84), "VOLTAR", true)


func _normalized(event_position: Vector2) -> Vector2:
	var viewport := get_viewport_rect().size
	var factor: float = minf(viewport.x / 720.0, viewport.y / 1280.0)
	return (event_position - (viewport - Vector2(720, 1280) * factor) / 2.0) / factor


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if page == "game":
			paused = true
			page = "menu"
		else:
			page = "menu"
		queue_redraw()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT and page == "game":
		paused = true
		queue_redraw()


func _hit(pos: Vector2) -> String:
	if page == "game":
		if Rect2(38, 976, 644, 74).has_point(pos): return "restart"
		if Rect2(38, 1070, 310, 70).has_point(pos): return "pause"
		if Rect2(372, 1070, 310, 70).has_point(pos): return "menu"
		if BOARD.has_point(pos) and not paused and not rules.ended: return "board"
	return "none"


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if active_index == -1:
				active_index = event.index
				_handle_contact(_normalized(event.position), true)
		elif event.index == active_index:
			_handle_contact(_normalized(event.position), false)
			active_index = -1
	elif event is InputEventScreenDrag:
		if event.index == active_index and press_target == "board" and page == "game" and not paused:
			rules.pointer(_game_point(_normalized(event.position)))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not OS.has_feature("mobile") and active_index == -1:
		_handle_contact(_normalized(event.position), event.pressed)
	elif event is InputEventMouseMotion and touching and active_index == -1 and page == "game" and not paused:
		rules.pointer(_game_point(_normalized(event.position)))
	elif event is InputEventKey and event.pressed and not event.echo:
		if page == "game" and not paused:
			var arrows := {KEY_LEFT: Vector2.LEFT, KEY_RIGHT: Vector2.RIGHT, KEY_UP: Vector2.UP, KEY_DOWN: Vector2.DOWN}
			if arrows.has(event.keycode):
				rules.swipe(Vector2.ZERO, arrows[event.keycode])


func _game_point(pos: Vector2) -> Vector2:
	return (pos - BOARD.position) / BOARD.size


func _handle_contact(pos: Vector2, pressed: bool) -> void:
	if pressed:
		touching = true
		down = pos
		down_time = Time.get_ticks_msec()
		press_target = _hit(pos)
		if page == "game" and BOARD.has_point(pos) and not paused:
			rules.pointer(_game_point(pos))
		return
	if not touching:
		return
	touching = false
	var released_target := _hit(pos)
	if page == "menu":
		if Rect2(38, 985, 644, 74).has_point(pos):
			rules.reset()
			paused = false
			page = "game"
		elif Rect2(38, 1077, 644, 74).has_point(pos):
			page = "catalog"
		elif Rect2(38, 1169, 644, 74).has_point(pos):
			page = "pro"
	elif page == "game":
		if released_target == "restart" and press_target == "restart":
			rules.reset()
			paused = false
		elif released_target == "pause" and press_target == "pause":
			paused = not paused
		elif released_target == "menu" and press_target == "menu":
			paused = false
			page = "menu"
		elif press_target == "board" and BOARD.has_point(pos) and not paused and not rules.ended:
			var a := _game_point(down)
			var b := _game_point(pos)
			if a.distance_to(b) > 0.035:
				rules.swipe(a, b)
			elif Time.get_ticks_msec() - down_time > 480:
				rules.hold(b)
			else:
				rules.tap(b)
	elif page == "catalog":
		if pos.y > 1120:
			page = "menu"
		else:
			var row := 0
			for entry in CATALOG:
				if entry[0] == rules.title:
					continue
				var rect := Rect2(36, 170 + row * 101, 648, 90)
				var link := String(entry[1])
				if rect.has_point(pos) and link.begins_with("https://play.google.com/store/apps/details?id="):
					OS.shell_open(link)
					break
				row += 1
	elif page == "pro" and pos.y > 1040:
		page = "menu"
	queue_redraw()
