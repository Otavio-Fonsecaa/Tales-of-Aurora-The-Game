
extends StaticBody2D

# ==========================================
# TALES OF AURORA
# Sr. Pu Terrier — Sistema de interação
# ==========================================


# ==========================================
# RETRATOS DOS PERSONAGENS
# ==========================================

# @export permite escolher as imagens no Inspetor.
@export var retrato_pu_terrier: Texture2D
@export var retrato_foracio: Texture2D


# ==========================================
# REFERÊNCIAS AOS NÓS
# ==========================================

# Área responsável por detectar Forácio.
@onready var area_interacao: Area2D = $AreaInteracao

# Texto que indica a tecla de interação.
@onready var texto_interacao: Label = $TextoInteracao


# Indica se o jogador está próximo.
var jogador_perto: bool = false


# ==========================================
# INICIALIZAÇÃO
# ==========================================

func _ready() -> void:

	# Esconde inicialmente a indicação.
	texto_interacao.hide()

	# Conecta os sinais da área.
	area_interacao.body_entered.connect(ao_entrar_area)
	area_interacao.body_exited.connect(ao_sair_area)


# ==========================================
# VERIFICAR INTERAÇÃO
# ==========================================

func _process(_delta: float) -> void:

	# Verifica se Forácio está próximo e
	# se nenhuma conversa está acontecendo.
	if jogador_perto and not DialogoUI.em_dialogo:

		texto_interacao.text = "E - Conversar"
		texto_interacao.show()

		# Detecta a tecla de interação.
		if Input.is_action_just_pressed("interagir"):

			texto_interacao.hide()

			# Inicia a conversa.
			iniciar_conversa()

	else:

		texto_interacao.hide()


# ==========================================
# CONVERSA DO SR. PU TERRIER
# ==========================================

func iniciar_conversa() -> void:

	# Cada Dictionary representa uma etapa.
	#
	# nome: personagem que está falando.
	# texto: frase apresentada.
	# retrato: imagem exibida.
	# opcoes: respostas disponíveis.
	# proximo: índice da próxima etapa.
	#
	# Um índice -1 encerra a conversa.

	var conversa: Array[Dictionary] = [

		# Etapa 0 — Saudação.
		{
			"nome": "Sr. Pu Terrier",
			"texto": "Boa tarde, Forácio!",
			"retrato": retrato_pu_terrier
		},

		# Etapa 1 — Escolha do jogador.
		{
			"nome": "Sr. Pu Terrier",
			"texto": "Gostaria de alguma coisa?",
			"retrato": retrato_pu_terrier,

			"opcoes": [
				{
					"texto": "Um chá, por favor.",
					"proximo": 2
				},
				{
					"texto": "Só estou olhando.",
					"proximo": 4
				}
			]
		},

		# Etapa 2 — Resposta do Forácio.
		{
			"nome": "Forácio",
			"texto": "Um chá, por favor.",
			"retrato": retrato_foracio
		},

		# Etapa 3 — Resposta do garçom.
		{
			"nome": "Sr. Pu Terrier",
			"texto": "Excelente escolha! Já vou preparar.",
			"retrato": retrato_pu_terrier,
			"proximo": -1
		},

		# Etapa 4 — Resposta alternativa.
		{
			"nome": "Sr. Pu Terrier",
			"texto": "Fique à vontade!",
			"retrato": retrato_pu_terrier,
			"proximo": -1
		}
	]

	# Envia a conversa ao sistema global,
	# que pode ser usado por qualquer NPC.
	DialogoUI.iniciar_dialogo(conversa)

# ==========================================
# DETECTAR PROXIMIDADE
# ==========================================

func ao_entrar_area(corpo: Node2D) -> void:

	# Verifica se quem entrou é o jogador.
	if corpo.name == "Jogador":

		jogador_perto = true


func ao_sair_area(corpo: Node2D) -> void:

	if corpo.name == "Jogador":

		jogador_perto = false
		texto_interacao.hide()
