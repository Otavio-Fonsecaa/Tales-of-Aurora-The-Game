
extends CanvasLayer

# ==========================================
# TALES OF AURORA
# Sistema avançado de diálogos
# ==========================================


# Velocidade com que as letras aparecem.
# O valor representa caracteres por segundo.
# Pode ser alterado diretamente no Inspetor.
@export var letras_por_segundo: float = 35.0


# ==========================================
# REFERÊNCIAS AOS ELEMENTOS DA INTERFACE
# ==========================================

@onready var painel: Panel = $Painel
@onready var nome_label: Label = $Painel/Nome
@onready var fala_label: Label = $Painel/Fala
@onready var instrucao: Label = $Painel/Instrucao

# Mostra o retrato de quem está falando.
@onready var retrato: TextureRect = $Painel/Retrato

# Organiza os botões com as respostas disponíveis.
@onready var opcoes: VBoxContainer = $Painel/Opcoes


# ==========================================
# VARIÁVEIS DE CONTROLE
# ==========================================

# Armazena as falas e escolhas da conversa.
var roteiro: Array[Dictionary] = []

# Indica qual etapa da conversa está ativa.
var indice_atual: int = 0

# Controla os estados do diálogo.
var em_dialogo: bool = false
var digitando: bool = false
var escolhendo: bool = false

# Conta o progresso da exibição das letras.
var progresso_letras: float = 0.0


# ==========================================
# INICIALIZAÇÃO
# ==========================================

func _ready() -> void:

	# Esconde toda a interface inicialmente.
	painel.hide()
	opcoes.hide()


# ==========================================
# INICIAR CONVERSA
# ==========================================

# Recebe uma lista de etapas do diálogo.
# Cada etapa é um Dictionary com nome, texto,
# retrato e, opcionalmente, escolhas.
func iniciar_dialogo(novo_roteiro: Array[Dictionary]) -> void:

	# Impede conversas simultâneas ou vazias.
	if em_dialogo or novo_roteiro.is_empty():
		return

	roteiro = novo_roteiro
	em_dialogo = true

	# Mostra a caixa de diálogo.
	painel.show()

	# Inicia na primeira etapa.
	mostrar_etapa(0)


# ==========================================
# MOSTRAR ETAPA
# ==========================================

func mostrar_etapa(novo_indice: int) -> void:

	# Remove as escolhas da etapa anterior.
	limpar_opcoes()

	# Um índice negativo ou fora do roteiro
	# indica que a conversa terminou.
	if novo_indice < 0 or novo_indice >= roteiro.size():
		encerrar_dialogo()
		return

	indice_atual = novo_indice

	# Obtém os dados da etapa atual.
	var etapa: Dictionary = roteiro[indice_atual]

	# Atualiza o nome e o texto.
	nome_label.text = str(etapa.get("nome", ""))
	fala_label.text = str(etapa.get("texto", ""))

	# Atualiza o retrato do personagem.
	retrato.texture = etapa.get("retrato", null)

	# Esconde o retrato caso não exista imagem.
	retrato.visible = retrato.texture != null

	# Esconde inicialmente todas as letras.
	fala_label.visible_characters = 0

	# Reinicia o efeito de digitação.
	progresso_letras = 0.0
	digitando = true
	escolhendo = false

	instrucao.text = "Enter / Espaço: revelar"
	instrucao.show()


# ==========================================
# EFEITO DE TEXTO PROGRESSIVO
# ==========================================

# Executada a cada quadro do jogo.
func _process(delta: float) -> void:

	# Não faz nada se não estiver digitando.
	if not em_dialogo or not digitando:
		return

	# Aumenta o progresso com base no tempo.
	# delta mantém a velocidade consistente.
	progresso_letras += delta * letras_por_segundo

	# Revela gradualmente os caracteres.
	fala_label.visible_characters = mini(
		int(progresso_letras),
		fala_label.text.length()
	)

	# Verifica se a frase inteira foi exibida.
	if fala_label.visible_characters >= fala_label.text.length():
		finalizar_digitacao()


# ==========================================
# FINALIZAR DIGITAÇÃO
# ==========================================

func finalizar_digitacao() -> void:

	if not digitando:
		return

	digitando = false

	# -1 significa mostrar todos os caracteres.
	fala_label.visible_characters = -1

	var etapa: Dictionary = roteiro[indice_atual]

	# Verifica se a fala oferece respostas.
	var alternativas: Array = etapa.get("opcoes", [])

	if not alternativas.is_empty():

		# Exibe as opções após a frase terminar.
		criar_opcoes(alternativas)

	else:

		instrucao.text = "Enter / Espaço: continuar"


# ==========================================
# CRIAR OPÇÕES DE RESPOSTA
# ==========================================

func criar_opcoes(alternativas: Array) -> void:

	escolhendo = true

	# Esconde a instrução de continuar.
	instrucao.hide()

	# Mostra a área dos botões.
	opcoes.show()

	# Percorre todas as respostas disponíveis.
	for item in alternativas:

		var alternativa: Dictionary = item

		# Cria um botão por resposta.
		var botao: Button = Button.new()

		# Define o texto exibido no botão.
		botao.text = str(alternativa.get("texto", "..."))

		# Permite navegar usando o teclado.
		botao.focus_mode = Control.FOCUS_ALL

		# Faz o botão ocupar a largura disponível.
		botao.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Adiciona o botão à interface.
		opcoes.add_child(botao)

		# Obtém a próxima etapa dessa resposta.
		var destino: int = int(
			alternativa.get("proximo", -1)
		)

		# Conecta o clique à função de resposta.
		botao.pressed.connect(
			selecionar_opcao.bind(destino)
		)

		# Seleciona automaticamente o primeiro botão.
		if opcoes.get_child_count() == 1:
			botao.call_deferred("grab_focus")


# ==========================================
# SELECIONAR UMA RESPOSTA
# ==========================================

func selecionar_opcao(destino: int) -> void:

	if not em_dialogo or not escolhendo:
		return

	# Segue para a etapa correspondente à escolha.
	mostrar_etapa(destino)


# ==========================================
# LIMPAR OPÇÕES ANTERIORES
# ==========================================

func limpar_opcoes() -> void:

	# Remove todos os botões da conversa anterior.
	for botao in opcoes.get_children():

		opcoes.remove_child(botao)
		botao.queue_free()

	opcoes.hide()
	escolhendo = false


# ==========================================
# CONTROLES DO DIÁLOGO
# ==========================================

func _unhandled_input(event: InputEvent) -> void:

	# Não processa comandos fora de uma conversa.
	if not em_dialogo:
		return

	# Enquanto existem escolhas, os próprios
	# botões recebem os comandos de confirmação.
	if escolhendo:
		return

	# Verifica se Enter ou Espaço foi pressionado.
	if event.is_action_pressed("confirmar") and not event.is_echo():

		# Marca o comando como processado.
		get_viewport().set_input_as_handled()

		# Se as letras ainda estão aparecendo,
		# revela a frase inteira.
		if digitando:

			finalizar_digitacao()

		# Caso contrário, avança a conversa.
		else:

			var etapa: Dictionary = roteiro[indice_atual]

			# Procura a próxima etapa do roteiro.
			# Se não houver um destino específico,
			# segue para a etapa seguinte.
			var proximo: int = int(
				etapa.get("proximo", indice_atual + 1)
			)

			mostrar_etapa(proximo)


# ==========================================
# ENCERRAR CONVERSA
# ==========================================

func encerrar_dialogo() -> void:

	# Libera o jogador para voltar a se movimentar.
	em_dialogo = false
	digitando = false

	# Remove as escolhas e esconde a interface.
	limpar_opcoes()
	painel.hide()
