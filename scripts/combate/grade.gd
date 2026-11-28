
extends Node2D

# ==========================================
# TALES OF AURORA
# Sistema de grade tática oblíqua
# ==========================================


# ==========================================
# TAMANHO DO TABULEIRO
# ==========================================

# Quantas casas teremos na horizontal.
@export var colunas: int = 8

# Quantas casas teremos na vertical.
@export var linhas: int = 6


# ==========================================
# FORMATO DAS CASAS
# ==========================================

# Largura de cada casa em pixels.
@export var largura_casa: float = 48.0

# Altura de cada casa em pixels.
@export var altura_casa: float = 24.0

# Inclinação lateral da grade.
#
# Quanto maior o valor, mais inclinadas
# ficarão as casas.
@export var inclinacao: float = 10.0


# ==========================================
# POSICIONAMENTO
# ==========================================

# Local onde o tabuleiro começa na tela.
#
# Poderemos alterar esses valores depois
# para centralizar a grade sobre a cidade.
@export var origem: Vector2 = Vector2(155, 155)


# ==========================================
# INICIALIZAÇÃO
# ==========================================

func _ready() -> void:

	# Coloca a grade acima do cenário.
	z_index = 2

	# Solicita o desenho do tabuleiro.
	queue_redraw()


# ==========================================
# CALCULAR A POSIÇÃO DE UMA CASA
# ==========================================

# Recebe a coluna e a linha de uma casa.
# Retorna sua posição superior esquerda.
#
# A inclinação faz com que cada linha
# comece um pouco mais à esquerda.
func posicao_casa(
	coluna: int,
	linha: int
) -> Vector2:

	var x: float = (
		origem.x
		+ coluna * largura_casa
		- linha * inclinacao
	)

	var y: float = (
		origem.y
		+ linha * altura_casa
	)

	return Vector2(x, y)


# ==========================================
# DESENHAR A GRADE
# ==========================================

func _draw() -> void:

	# Percorre as linhas do tabuleiro.
	for linha in range(linhas):

		# Percorre as colunas do tabuleiro.
		for coluna in range(colunas):

			# Localiza a casa no cenário.
			var inicio: Vector2 = (
				posicao_casa(coluna, linha)
			)

			# Define os quatro cantos da casa.
			#
			# As duas bordas laterais
			# ficam inclinadas.
			var pontos := PackedVector2Array([
				inicio,

				inicio + Vector2(
					largura_casa, 0
				),

				inicio + Vector2(
					largura_casa - inclinacao,
					altura_casa
				),

				inicio + Vector2(
					-inclinacao,
					altura_casa
				)
			])

			# Alterna suavemente a cor das casas.
			# Isso facilita identificar a grade.
			var cor: Color

			if (coluna + linha) % 2 == 0:
				cor = Color(0.2, 0.65, 1.0, 0.22)
			else:
				cor = Color(0.1, 0.45, 0.85, 0.16)

			# Desenha o interior transparente.
			draw_colored_polygon(pontos, cor)

			# Fecha o contorno da casa.
			var contorno := PackedVector2Array([
				pontos[0],
				pontos[1],
				pontos[2],
				pontos[3],
				pontos[0]
			])

			# Desenha as bordas do tabuleiro.
			draw_polyline(
				contorno,
				Color(0.85, 0.95, 1.0, 0.7),
				1.0
			)
			
			

# ==========================================
# CENTRO DE UMA CASA DO TABULEIRO
# ==========================================

# Recebe a coluna e a linha de uma casa.
# Retorna sua posição central em pixels,
# considerando a largura, a altura
# e a inclinação configuradas no Inspetor.
func centro_casa(
	coluna: int,
	linha: int
) -> Vector2:

	# Aproveita a função de posicionamento
	# que já criamos no script da grade.
	var inicio: Vector2 = posicao_casa(coluna, linha)

	# Calcula o centro do paralelogramo.
	var deslocamento: Vector2 = Vector2(
		(largura_casa - inclinacao) / 2.0,
		altura_casa / 2.0
	)

	return inicio + deslocamento
