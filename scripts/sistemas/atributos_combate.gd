
extends Node
class_name AtributosCombate

# ==========================================
# TALES OF AURORA
# Sistema de atributos e vida
# ==========================================


# ==========================================
# SINAIS
# ==========================================

# Emitido sempre que a vida é modificada.
# Futuramente permitirá atualizar a barra de PV.
signal vida_alterada(atual: int, maxima: int)

# Emitido quando a vida chega a zero.
signal personagem_derrotado


# ==========================================
# DADOS DO PERSONAGEM
# ==========================================

# Recebe um recurso DadosPersonagem pelo Inspetor.
@export var dados: DadosPersonagem


# Guarda a quantidade de vida atual.
#
# Não usamos @export porque a vida atual
# será controlada durante a execução.
var vida_atual: int = 0


# ==========================================
# INICIALIZAÇÃO
# ==========================================

func _ready() -> void:

	# Verifica se os dados foram configurados.
	if dados == null:
		push_warning("Personagem sem atributos!")
		return

	# Começa com a vida completamente cheia.
	vida_atual = dados.vida_maxima

	# Mostra os atributos no painel Saída.
	# Utilizaremos isso apenas para os testes.
	print(
		dados.nome,
		" | PV: ", vida_atual, "/", dados.vida_maxima,
		" | ATQ: ", dados.ataque,
		" | DEF: ", dados.defesa,
		" | MOV: ", dados.movimento_tatico,
		" | ALC: ", dados.alcance_ataque
	)

	# Informa que a vida foi inicializada.
	vida_alterada.emit(vida_atual, dados.vida_maxima)


# ==========================================
# RECEBER DANO
# ==========================================

func receber_dano(ataque_recebido: int) -> void:

	# Impede a execução caso não existam dados
	# ou o personagem já esteja derrotado.
	if dados == null or vida_atual <= 0:
		return

	# Calcula o dano recebido.
	#
	# Exemplo:
	# Ataque inimigo = 10
	# Defesa do personagem = 3
	# Dano final = 7
	#
	# maxi() escolhe o maior valor entre dois.
	# Assim, o dano mínimo será 1.
	var dano_final: int = maxi(
		1,
		ataque_recebido - dados.defesa
	)

	# Subtrai o dano da vida atual.
	# A vida nunca poderá ficar abaixo de zero.
	vida_atual = maxi(
		0,
		vida_atual - dano_final
	)

	# Avisa que a vida foi alterada.
	vida_alterada.emit(vida_atual, dados.vida_maxima)

	# Verifica se o personagem foi derrotado.
	if vida_atual == 0:
		personagem_derrotado.emit()


# ==========================================
# RECUPERAR VIDA
# ==========================================

func curar(quantidade: int) -> void:

	# Não permite curar sem dados,
	# com vida zerada ou quantidade inválida.
	if dados == null or vida_atual <= 0 or quantidade <= 0:
		return

	# Recupera vida sem ultrapassar o máximo.
	#
	# mini() escolhe o menor valor entre dois.
	vida_atual = mini(
		dados.vida_maxima,
		vida_atual + quantidade
	)

	# Avisa que a vida foi alterada.
	vida_alterada.emit(vida_atual, dados.vida_maxima)


# ==========================================
# VERIFICAR SE ESTÁ VIVO
# ==========================================

func esta_vivo() -> bool:

	# Retorna true quando a vida está acima de zero.
	return vida_atual > 0
