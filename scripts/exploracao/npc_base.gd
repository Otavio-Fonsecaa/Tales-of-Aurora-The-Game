
extends StaticBody2D

# ==========================================
# TALES OF AURORA
# Sistema reutilizável de NPCs
# ==========================================


# ==========================================
# INFORMAÇÕES DO PERSONAGEM
# ==========================================

# Nome exibido durante as conversas.
# Pode ser alterado pelo Inspetor.
@export var nome_npc: String = "NPC"


# Retrato exibido na caixa de diálogo.
# Aceita imagens PNG importadas pelo Godot.
@export var retrato: Texture2D


# Falas do personagem.
#
# @export_multiline cria um campo de texto
# com várias linhas no Inspetor.
#
# Cada linha será uma fala diferente.
@export_multiline var falas: String = "Olá, Forácio!"


# ==========================================
# REFERÊNCIAS AOS NÓS
# ==========================================

# Área responsável por detectar o jogador.
@onready var area_interacao: Area2D = $AreaInteracao

# Texto mostrado quando Forácio se aproxima.
@onready var texto_interacao: Label = $TextoInteracao


# ==========================================
# ESTADO DO NPC
# ==========================================

# Indica se Forácio está próximo.
var jogador_perto: bool = false


# ==========================================
# INICIALIZAÇÃO
# ==========================================

func _ready() -> void:

	# Esconde a indicação de interação.
	texto_interacao.hide()

	# Conecta os sinais da área de interação.
	# Eles são emitidos quando um corpo entra ou sai.
	area_interacao.body_entered.connect(ao_entrar_area)
	area_interacao.body_exited.connect(ao_sair_area)


# ==========================================
# VERIFICAR INTERAÇÃO
# ==========================================

func _process(_delta: float) -> void:

	# A interação só estará disponível quando:
	#
	# 1. Forácio estiver próximo do NPC.
	# 2. Nenhuma conversa estiver acontecendo.
	var pode_interagir: bool = (
		jogador_perto and not DialogoUI.em_dialogo
	)

	# Exibe ou esconde a indicação.
	texto_interacao.visible = pode_interagir

	# Verifica se o jogador pressionou E.
	if pode_interagir and Input.is_action_just_pressed("interagir"):

		# Esconde o texto antes de iniciar o diálogo.
		texto_interacao.hide()

		# Inicia a conversa deste NPC.
		iniciar_conversa()


# ==========================================
# INICIAR CONVERSA
# ==========================================

func iniciar_conversa() -> void:

	# Lista que armazenará as etapas da conversa.
	# Cada etapa será um Dictionary.
	var roteiro: Array[Dictionary] = []

	# Divide o texto em linhas.
	# O caractere "\n" representa uma quebra de linha.
	#
	# Cada linha digitada no Inspetor
	# se transformará em uma fala independente.
	for linha in falas.split("\n", false):

		# Remove espaços desnecessários
		# do início e do fim da frase.
		var fala: String = linha.strip_edges()

		# Ignora linhas que estiverem vazias.
		if fala.is_empty():
			continue

		# Adiciona a fala ao roteiro.
		# Todas as falas pertencem a este NPC.
		roteiro.append({
			"nome": nome_npc,
			"texto": fala,
			"retrato": retrato
		})

	# Impede iniciar uma conversa sem falas.
	if roteiro.is_empty():
		return

	# Envia o roteiro ao sistema global.
	# DialogoUI controla a digitação, os retratos
	# e a passagem entre as falas.
	DialogoUI.iniciar_dialogo(roteiro)


# ==========================================
# DETECTAR ENTRADA DO JOGADOR
# ==========================================

func ao_entrar_area(corpo: Node2D) -> void:

	# Verifica se o corpo pertence ao grupo "jogador".
	# Isso evita depender do nome exato do nó.
	if corpo.is_in_group("jogador"):

		jogador_perto = true


# ==========================================
# DETECTAR SAÍDA DO JOGADOR
# ==========================================

func ao_sair_area(corpo: Node2D) -> void:

	if corpo.is_in_group("jogador"):

		# Indica que o jogador se afastou.
		jogador_perto = false

		# Esconde a indicação de conversa.
		texto_interacao.hide()
