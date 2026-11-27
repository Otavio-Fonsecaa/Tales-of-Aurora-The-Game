
extends CharacterBody2D

# ==========================================
# TALES OF AURORA
# Script de movimentação do Forácio
# ==========================================


# Define a velocidade do personagem em pixels por segundo.
# @export permite modificar esse valor pelo Inspetor do Godot.
@export var velocidade: float = 90.0


# Referência ao nó responsável pelas animações do Forácio.
# @onready inicializa a variável quando o nó estiver pronto.
@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D


# ==========================================
# MOVIMENTAÇÃO E ANIMAÇÕES
# ==========================================

# Executada automaticamente a cada atualização da física.
func _physics_process(_delta: float) -> void:

	# ======================================
	# BLOQUEIO DE MOVIMENTO DURANTE DIÁLOGOS
	# ======================================

	# Verifica se existe uma conversa acontecendo.
	# Verifica se existe uma conversa ativa
	# no sistema global de diálogos.
	if DialogoUI.em_dialogo:

		# Impede que o personagem continue andando.
		velocity = Vector2.ZERO

		# Interrompe a animação de caminhada.
		animacao.stop()

		# Retorna ao sprite 0 da última direção.
		animacao.frame = 0

		# Encerra a função enquanto houver diálogo.
		return


	# ======================================
	# CAPTURA DA MOVIMENTAÇÃO
	# ======================================

	# Captura as teclas de movimentação.
	# Retorna um Vector2 com os valores dos eixos X e Y.
	# Também evita que o personagem ande mais rápido
	# quando duas direções são pressionadas juntas.
	var direcao: Vector2 = Input.get_vector(
		"mover_esquerda",
		"mover_direita",
		"mover_cima",
        "mover_baixo"
	)

	# Multiplica a direção pela velocidade configurada.
	velocity = direcao * velocidade

	# Movimenta o personagem respeitando as colisões.
	move_and_slide()


	# ======================================
	# PERSONAGEM PARADO
	# ======================================

	# Verifica se nenhuma tecla de movimento está pressionada.
	if direcao == Vector2.ZERO:

		# Interrompe a animação atual.
		animacao.stop()

		# Mostra o primeiro quadro (sprite 0)
		# da última direção utilizada.
		animacao.frame = 0

		# Encerra esta atualização da função.
		return


	# ======================================
	# PERSONAGEM EM MOVIMENTO
	# ======================================

	# Guarda o nome da animação que será reproduzida.
	var nova_animacao: String = "andar_baixo"

	# Verifica se o movimento predominante é horizontal.
	if abs(direcao.x) > abs(direcao.y):

		# Movimento para a direita.
		if direcao.x > 0:
			nova_animacao = "andar_direita"

		# Movimento para a esquerda.
		else:
			nova_animacao = "andar_esquerda"

	# Se não for horizontal, utiliza o eixo vertical.
	else:

		# Movimento para baixo.
		if direcao.y > 0:
			nova_animacao = "andar_baixo"

		# Movimento para cima.
		else:
			nova_animacao = "andar_cima"


	# ======================================
	# REPRODUÇÃO DA ANIMAÇÃO
	# ======================================

	# Reproduz a animação correspondente à direção.
	# Se ela já estiver sendo reproduzida,
	# o Godot não reinicia os quadros desnecessariamente.
	animacao.play(nova_animacao)
