
extends Resource
class_name DadosPersonagem

# ==========================================
# TALES OF AURORA
# Dados básicos dos personagens
# ==========================================

# Resource é uma classe usada para armazenar dados.
# Diferentemente de um Node, ela não precisa
# existir diretamente na árvore de cenas.
#
# class_name registra nossa classe no Godot,
# permitindo criar recursos DadosPersonagem
# diretamente pelo editor.


# ==========================================
# IDENTIFICAÇÃO
# ==========================================

# Nome do personagem.
@export var nome: String = "Personagem"


# ==========================================
# ATRIBUTOS DE COMBATE
# ==========================================

# Vida máxima que o personagem pode possuir.
@export_range(1, 999, 1)
var vida_maxima: int = 30


# Força utilizada para calcular dano físico.
@export_range(0, 999, 1)
var ataque: int = 8


# Redução aplicada ao dano recebido.
@export_range(0, 999, 1)
var defesa: int = 3


# Quantidade de casas que o personagem
# poderá percorrer durante seu turno.
#
# Não altera a velocidade da exploração.
@export_range(1, 20, 1)
var movimento_tatico: int = 4


# Distância máxima para realizar ataques.
# Um valor de 1 representa ataque adjacente.
@export_range(1, 20, 1)
var alcance_ataque: int = 1
