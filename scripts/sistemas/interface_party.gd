
extends CanvasLayer

# ==========================================
# TALES OF AURORA
# Interface de atributos da Party
# ==========================================


# ==========================================
# IDENTIFICAÇÃO DOS PERSONAGENS
# ==========================================

# Define a ordem em que os membros aparecerão.
# Os identificadores são os mesmos usados no
# gerenciador global chamado Party.
const ORDEM = [
	"foracio",
	"lin_vin",
	"robersvaldo",
    "ursula"
]

# Guarda a classe de cada integrante.
# Dictionary associa um identificador a um valor.
const CLASSES = {
	"foracio": "Guerreiro",
	"lin_vin": "Mago",
	"robersvaldo": "Ladino",
	"ursula": "Tanque"
}


# ==========================================
# REFERÊNCIAS AOS NÓS DA INTERFACE
# ==========================================

@onready var raiz: Control = $Raiz

@onready var fundo: ColorRect = $Raiz/Fundo

@onready var janela: PanelContainer = (
	$Raiz/Centralizador/Janela
)

@onready var conteudo: VBoxContainer = (
	$Raiz/Centralizador/Janela/Conteudo
)

@onready var titulo: Label = (
	$Raiz/Centralizador/Janela/Conteudo/Titulo
)

@onready var grade: GridContainer = (
	$Raiz/Centralizador/Janela/Conteudo/Grade
)

@onready var botao_fechar: Button = (
	$Raiz/Centralizador/Janela/Conteudo/BotaoFechar
)


# Indica se o menu está aberto.
var aberto: bool = false


# ==========================================
# INICIALIZAÇÃO
# ==========================================

func _ready() -> void:

	# Permite que este menu continue recebendo
	# comandos mesmo com o jogo pausado.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Mantém a interface acima do cenário.
	layer = 10

	# O menu começa escondido.
	raiz.hide()

	# Fundo escuro semitransparente.
	fundo.color = Color(0, 0, 0, 0.75)

	# Dimensões da janela principal.
	janela.custom_minimum_size = Vector2(608, 320)

	# Configura os textos.
	titulo.text = "Equipe"
	botao_fechar.text = "Fechar — Tab / Esc"

	# Define duas colunas de personagens.
	grade.columns = 2

	# Ajusta os espaçamentos.
	grade.add_theme_constant_override(
		"h_separation", 8
	)
	grade.add_theme_constant_override(
		"v_separation", 8
	)
	conteudo.add_theme_constant_override(
		"separation", 8
	)

	# Estiliza o painel principal.
	var estilo: StyleBoxFlat = criar_estilo(
		Color("#292535"), 12
	)

	# Adiciona uma borda dourada.
	estilo.border_color = Color("#d2b882")
	estilo.border_width_left = 2
	estilo.border_width_right = 2
	estilo.border_width_top = 2
	estilo.border_width_bottom = 2

	janela.add_theme_stylebox_override(
		"panel", estilo
	)

	titulo.add_theme_font_size_override(
		"font_size", 20
	)

	titulo.add_theme_color_override(
		"font_color", Color("#f0d9ad")
	)

	# O botão fecha o menu ao ser pressionado.
	botao_fechar.pressed.connect(fechar_menu)

	# Escuta alterações de vida dos integrantes.
	# Dessa forma, o menu utiliza dados reais.
	Party.vida_membro_alterada.connect(
		ao_alterar_vida
	)


# ==========================================
# CRIAÇÃO DE ESTILOS
# ==========================================

# StyleBoxFlat permite criar caixas com
# cores, bordas e cantos arredondados.
func criar_estilo(
	cor: Color,
	margem: int
) -> StyleBoxFlat:

	var estilo: StyleBoxFlat = StyleBoxFlat.new()

	# Cor de fundo.
	estilo.bg_color = cor

	# Cantos arredondados.
	estilo.corner_radius_top_left = 7
	estilo.corner_radius_top_right = 7
	estilo.corner_radius_bottom_left = 7
	estilo.corner_radius_bottom_right = 7

	# Espaçamento interno.
	estilo.content_margin_left = margem
	estilo.content_margin_right = margem
	estilo.content_margin_top = margem
	estilo.content_margin_bottom = margem

	return estilo


# ==========================================
# CONTROLES DO MENU
# ==========================================

# _input recebe os eventos do teclado.
func _input(event: InputEvent) -> void:

	# Ignora repetições automáticas de teclas.
	if event is InputEventKey and event.is_echo():
		return

	# Verifica se Tab foi pressionado.
	if event.is_action_pressed("abrir_party"):

		# Se o menu já está aberto, fecha.
		if aberto:
			fechar_menu()

		# Se está fechado, tenta abrir.
		else:

			# Não permite abrir durante conversas.
			if not DialogoUI.em_dialogo:
				abrir_menu()

		# Impede que a tecla seja processada
		# novamente por outros elementos.
		get_viewport().set_input_as_handled()
		return

	# Esc também fecha o menu.
	if aberto and event.is_action_pressed("cancelar"):

		fechar_menu()
		get_viewport().set_input_as_handled()


# ==========================================
# ABRIR MENU
# ==========================================

func abrir_menu() -> void:

	if aberto:
		return

	# Atualiza os valores antes de mostrar.
	atualizar_cartoes()

	# Exibe a interface.
	aberto = true
	raiz.show()

	# Pausa a exploração do cenário.
	get_tree().paused = true


# ==========================================
# FECHAR MENU
# ==========================================

func fechar_menu() -> void:

	if not aberto:
		return

	# Esconde a interface.
	aberto = false
	raiz.hide()

	# Retoma a execução normal do jogo.
	get_tree().paused = false


# ==========================================
# ATUALIZAR OS CARTÕES
# ==========================================

func atualizar_cartoes() -> void:

	# Remove os cartões antigos.
	# Isso evita informações duplicadas.
	for cartao in grade.get_children():

		grade.remove_child(cartao)
		cartao.queue_free()

	# Cria novamente um cartão para cada membro.
	for id in ORDEM:

		criar_cartao(id)


# ==========================================
# CRIAR CARTÃO DE UM PERSONAGEM
# ==========================================

func criar_cartao(id: String) -> void:

	# Obtém os atributos reais pelo gerenciador.
	var atributos: AtributosCombate = (
		Party.obter_atributos(id)
	)

	# Impede tentar acessar dados inexistentes.
	if atributos == null or atributos.dados == null:
		return

	# Referência ao arquivo DadosPersonagem.
	var dados: DadosPersonagem = atributos.dados

	# Cria o fundo do cartão.
	var cartao: PanelContainer = PanelContainer.new()

	cartao.custom_minimum_size = Vector2(276, 104)

	cartao.add_theme_stylebox_override(
		"panel",
		criar_estilo(Color("#383344"), 9)
	)

	# Organiza as informações verticalmente.
	var coluna: VBoxContainer = VBoxContainer.new()

	coluna.add_theme_constant_override(
		"separation", 3
	)

	cartao.add_child(coluna)

	# ======================================
	# NOME E CLASSE
	# ======================================

	var nome_label: Label = Label.new()

	nome_label.text = "%s — %s" % [
		dados.nome,
		CLASSES.get(id, "Classe")
	]

	nome_label.add_theme_font_size_override(
		"font_size", 13
	)

	nome_label.add_theme_color_override(
		"font_color", Color("#f0d9ad")
	)

	coluna.add_child(nome_label)

	# ======================================
	# VIDA ATUAL
	# ======================================

	var vida_label: Label = Label.new()

	vida_label.text = "PV: %d / %d" % [
		atributos.vida_atual,
		dados.vida_maxima
	]

	vida_label.add_theme_font_size_override(
		"font_size", 12
	)

	coluna.add_child(vida_label)

	# ======================================
	# BARRA DE VIDA
	# ======================================

	var barra: ProgressBar = ProgressBar.new()

	# Define os limites e o valor atual.
	barra.min_value = 0
	barra.max_value = dados.vida_maxima
	barra.value = atributos.vida_atual

	# Esconde a porcentagem padrão.
	barra.show_percentage = false

	# Define a altura da barra.
	barra.custom_minimum_size = Vector2(0, 12)

	barra.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	# Fundo da barra de vida.
	barra.add_theme_stylebox_override(
		"background",
		criar_estilo(Color("#5a5062"), 0)
	)

	# Preenchimento verde da barra.
	barra.add_theme_stylebox_override(
		"fill",
		criar_estilo(Color("#68b981"), 0)
	)

	coluna.add_child(barra)

	# ======================================
	# ATRIBUTOS DE COMBATE
	# ======================================

	var atributos_label: Label = Label.new()

	atributos_label.text = (
        "ATQ %d   DEF %d   MOV %d   ALC %d"
	) % [
		dados.ataque,
		dados.defesa,
		dados.movimento_tatico,
		dados.alcance_ataque
	]

	atributos_label.add_theme_font_size_override(
		"font_size", 12
	)

	atributos_label.add_theme_color_override(
		"font_color", Color("#d8cce2")
	)

	coluna.add_child(atributos_label)

	# Adiciona o cartão à grade principal.
	grade.add_child(cartao)


# ==========================================
# ATUALIZAR AO MODIFICAR A VIDA
# ==========================================

# Esta função recebe os sinais do Party.
#
# Os argumentos começam com _ porque não
# precisamos utilizá-los diretamente:
# consultamos todos os dados atualizados.
func ao_alterar_vida(
	_id: String,
	_atual: int,
	_maxima: int
) -> void:

	# Atualiza apenas se o menu estiver visível.
	if aberto:
		atualizar_cartoes()
