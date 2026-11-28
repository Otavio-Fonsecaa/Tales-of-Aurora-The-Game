
extends Node2D

# ==========================================
# TALES OF AURORA
# Posicionamento dos aliados em batalha
# ==========================================


# ==========================================
# REFERÊNCIAS
# ==========================================

# O nó Grade é irmão do nó Aliados.
#
# Usaremos suas funções para posicionar
# personagens sobre as casas inclinadas.
@onready var grade = $"../Grade"

# Referências aos quatro Sprite2D
# que criamos na árvore da cena.
@onready var personagens: Dictionary = {
	"foracio": $Foracio,
	"lin_vin": $LinVin,
	"robersvaldo": $Robersvaldo,
	"ursula": $Ursula
}


# ==========================================
# POSIÇÕES INICIAIS
# ==========================================

# Cada Vector2i representa:
# (coluna, linha)
#
# Essas posições serão usadas futuramente
# para movimentação e cálculo de alcance.
var casas: Dictionary = {
	"foracio": Vector2i(2, 4),
	"lin_vin": Vector2i(1, 5),
	"robersvaldo": Vector2i(3, 5),
	"ursula": Vector2i(2, 6)
}


# ==========================================
# INICIAIS PROVISÓRIAS
# ==========================================

# Caso um personagem ainda não tenha
# seu sprite configurado, aparecerá uma
# letra provisória em seu lugar.
const INICIAIS = {
	"foracio": "F",
	"lin_vin": "L",
	"robersvaldo": "R",
	"ursula": "U"
}


# ==========================================
# INICIALIZAÇÃO
# ==========================================

func _ready() -> void:

	# Renderiza os aliados por cima da grade.
	z_index = 3

	# Percorre os quatro personagens.
	for id in personagens:

		# Obtém o Sprite2D.
		var sprite: Sprite2D = personagens[id]

		# Obtém a casa inicial da unidade.
		var celula: Vector2i = casas[id]

		# Calcula o centro da casa usando
		# as configurações reais da Grade.
		var centro: Vector2 = grade.centro_casa(
			celula.x,
			celula.y
		)

		# Converte as coordenadas da Grade
		# para as coordenadas locais de Aliados.
		sprite.position = to_local(
			grade.to_global(centro)
		)

		# Mantém a estética pixel art.
		sprite.texture_filter = (
			CanvasItem.TEXTURE_FILTER_NEAREST
		)

		# Centraliza horizontalmente o sprite.
		sprite.centered = true

		# Se houver uma textura configurada,
		# posiciona seus pés no centro da casa.
		if sprite.texture != null:

			var altura: float = (
				sprite.get_rect().size.y
			)

			sprite.offset = Vector2(
				0.0,
				-altura / 2.0
			)

		# Se ainda não houver textura,
		# mostra um marcador provisório.
		else:
			criar_marcador(sprite, id)

		# Confirma que o membro existe
		# no gerenciador global Party.
		var atributos: AtributosCombate = (
			Party.obter_atributos(id)
		)

		if atributos != null and atributos.dados != null:
			print(
				"Aliado: ",
				atributos.dados.nome,
				" | Casa: ",
				celula
			)


# ==========================================
# MARCADORES PROVISÓRIOS
# ==========================================

func criar_marcador(
	sprite: Sprite2D,
	id: String
) -> void:

	# Escolhe a cor do personagem.
	var cor: Color = Color("#b95f4f")

	match id:
		"lin_vin":
			cor = Color("#8e70c2")

		"robersvaldo":
			cor = Color("#c4a04b")

		"ursula":
			cor = Color("#558c7e")

	# Desenha um pequeno quadrado colorido.
	var marcador := Polygon2D.new()

	marcador.polygon = PackedVector2Array([
		Vector2(-10, -23),
		Vector2(10, -23),
		Vector2(10, -3),
		Vector2(-10, -3)
	])

	marcador.color = cor

	sprite.add_child(marcador)

	# Cria uma letra sobre o marcador.
	var letra := Label.new()

	letra.text = INICIAIS[id]

	letra.position = Vector2(-10, -23)
	letra.size = Vector2(20, 20)

	letra.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	letra.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	letra.add_theme_font_size_override(
		"font_size",
		14
	)

	letra.add_theme_color_override(
		"font_color",
		Color.WHITE
	)

	sprite.add_child(letra)
