
# Define que este script pertence a um CharacterBody2D.
# Esse tipo de nó é usado para personagens que se movimentam
# e podem colidir com paredes, objetos e outros elementos.
extends CharacterBody2D


# Define a velocidade de movimentação do personagem.
# @export permite alterar esse valor diretamente no Inspetor
# do Godot, sem precisar modificar o código.
# O valor é medido em pixels por segundo.
@export var velocidade: float = 90.0


# Função executada automaticamente pelo Godot
# a cada atualização da física do jogo.
# _delta representa o tempo passado desde a última atualização.
func _physics_process(_delta: float) -> void:

	# Verifica quais teclas de movimentação estão pressionadas.
	# Input.get_vector() combina quatro ações do Mapa de Entrada:
	# esquerda, direita, cima e baixo.
	#
	# Retorna um Vector2, que possui dois valores:
	# X = movimento horizontal
	# Y = movimento vertical
	#
	# O vetor é limitado a comprimento 1, evitando
	# que o personagem ande mais rápido na diagonal.
	var direcao = Input.get_vector(
		"mover_esquerda",
		"mover_direita",
		"mover_cima",
        "mover_baixo"
	)

	# Calcula a velocidade do personagem.
	# Multiplicamos a direção pela velocidade configurada.
	#
	# Exemplo:
	# Direção (1, 0) * 90 = (90, 0)
	# O personagem se move para a direita a 90 pixels/s.
	#
	# Se nenhuma tecla estiver pressionada,
	# a direção será (0, 0) e o personagem ficará parado.
	velocity = direcao * velocidade

	# Movimenta o personagem utilizando a velocidade calculada.
	# Também processa as colisões com objetos físicos,
	# impedindo que atravesse obstáculos configurados.
	move_and_slide()
