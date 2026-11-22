extends "res://scripts/rules_base.gd"

var board: Array[int] = []
var outcome := 0 # 0 ongoing, 1 player, 2 computer, 3 draw


func _init() -> void:
	title = "Jogo da Velha"
	subtitle = "Você é X; desafie o computador"


func reset() -> void:
	super.reset()
	board.resize(9)
	board.fill(0)
	outcome = 0


func winner(state: Array) -> int:
	for line in [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]:
		if state[line[0]] != 0 and state[line[0]] == state[line[1]] and state[line[1]] == state[line[2]]:
			return state[line[0]]
	if not state.has(0):
		return 3
	return 0


func _minimax(state: Array, turn: int) -> int:
	var result := winner(state)
	if result != 0:
		return 1 if result == 2 else (-1 if result == 1 else 0)
	var best := -2 if turn == 2 else 2
	for i in range(9):
		if state[i] == 0:
			state[i] = turn
			var value := _minimax(state, 1 if turn == 2 else 2)
			state[i] = 0
			best = maxi(best, value) if turn == 2 else mini(best, value)
	return best


func ai_turn() -> void:
	if outcome != 0:
		return
	var best := -2
	var move_index := -1
	for i in range(9):
		if board[i] == 0:
			board[i] = 2
			var value := _minimax(board, 1)
			board[i] = 0
			if value > best:
				best = value
				move_index = i
	if move_index >= 0:
		board[move_index] = 2
	_finish_if_needed()


func play(index: int) -> bool:
	if index < 0 or index >= 9 or board[index] != 0 or ended:
		return false
	board[index] = 1
	_finish_if_needed()
	if not ended:
		ai_turn()
	return true


func _finish_if_needed() -> void:
	outcome = winner(board)
	if outcome != 0:
		ended = true
		message = "Você venceu!" if outcome == 1 else ("Empate!" if outcome == 3 else "Computador venceu")
		if outcome == 1:
			score = 1


func tap(p: Vector2) -> void:
	# Board is centered vertically with a short instruction above it.
	var x := int(floor(p.x * 3.0))
	var y := int(floor((p.y - 0.15) / 0.72 * 3.0))
	if x >= 0 and x < 3 and y >= 0 and y < 3:
		play(y * 3 + x)


func draw_game(canvas: CanvasItem, area: Rect2) -> void:
	label(canvas, "Sua vez: X", Vector2(area.get_center().x, area.position.y + 55), 28)
	var side := minf(area.size.x - 30, area.size.y - 170)
	var rect := Rect2(Vector2(area.get_center().x - side * 0.5, area.position.y + 115), Vector2.ONE * side)
	canvas.draw_rect(rect, Color("e4eafa"))
	for i in range(9):
		var cell := cell_rect(rect, i % 3, i / 3, 3, 3, 7)
		canvas.draw_rect(cell, Color("ffffff"))
		if board[i] != 0:
			label(canvas, "X" if board[i] == 1 else "O", cell.get_center(), 83, ACCENT if board[i] == 1 else SUCCESS)
