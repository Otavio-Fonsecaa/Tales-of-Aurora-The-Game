
extends Node

# ==========================================
# TALES OF AURORA
# Gerenciador global da Party
# ==========================================


# ==========================================
# SINAIS
# ==========================================

# Informa que a vida de um integrante mudou.
# Futuramente será utilizado pela interface.
signal vida_membro_alterada(
	id: String,
	atual: int,
	maxima: int
)

# Informa que um integrante foi derrotado.
signal membro_derrotado(id: String)


# ==========================================
# REFERÊNCIAS AOS PERSONAGENS
# ==========================================

# Dictionary é uma estrutura que associa
# uma chave a um valor.
#
# Aqui cada chave identifica um integrante,
# enquanto o valor aponta para seu nó de atributos.
#
# @onready garante que os nós já existam
# quando as referências forem inicializadas.
@onready var membros: Dictionary = {
	"foracio": $Foracio,
	"lin_vin": $LinVin,
	"robersvaldo": $Robersvaldo,
	"ursula": $Ursula
}


# ==========================================
# INICIALIZAÇÃO
# ==========================================

func _ready() -> void:

	# Percorre todos os integrantes da equipe.
	for chave in membros:

		# Converte a chave para String.
		var id: String = str(chave)

		# Obtém o componente de atributos.
		var atributos: AtributosCombate = obter_atributos(id)

		if atributos == null:
			continue

		# Conecta os sinais individuais dos personagens
		# aos sinais globais do gerenciador.
		#
		# bind(id) acrescenta o identificador
		# do personagem aos argumentos recebidos.
		atributos.vida_alterada.connect(
			_ao_mudar_vida.bind(id)
		)

		atributos.personagem_derrotado.connect(
			_ao_derrotar.bind(id)
		)

	# Exibe os dados iniciais para conferência.
	imprimir_resumo()


# ==========================================
# CONSULTAR PERSONAGEM
# ==========================================

# Retorna os atributos de um integrante
# pelo seu identificador.
func obter_atributos(id: String) -> AtributosCombate:

	# Verifica se o identificador existe.
	if not membros.has(id):
		push_warning("Personagem não encontrado: " + id)
		return null

	# Converte o nó para AtributosCombate.
	return membros[id] as AtributosCombate


# ==========================================
# CONSULTAR VIDA
# ==========================================

func obter_vida(id: String) -> int:

	var personagem: AtributosCombate = obter_atributos(id)

	# Retorna zero caso o integrante não exista.
	if personagem == null:
		return 0

	return personagem.vida_atual


# ==========================================
# APLICAR DANO
# ==========================================

# ataque_bruto representa o valor de ataque
# antes de aplicar a defesa do alvo.
func causar_dano(id: String, ataque_bruto: int) -> void:

	var personagem: AtributosCombate = obter_atributos(id)

	if personagem == null:
		return

	# Reutiliza a função que já programamos.
	# Ela calcula a defesa e reduz a vida.
	personagem.receber_dano(ataque_bruto)


# ==========================================
# RECUPERAR VIDA
# ==========================================

func curar_membro(id: String, quantidade: int) -> void:

	var personagem: AtributosCombate = obter_atributos(id)

	if personagem == null:
		return

	# Recupera PV respeitando a vida máxima.
	personagem.curar(quantidade)


# ==========================================
# VERIFICAR SE ESTÁ VIVO
# ==========================================

func membro_esta_vivo(id: String) -> bool:

	var personagem: AtributosCombate = obter_atributos(id)

	if personagem == null:
		return false

	return personagem.esta_vivo()


# ==========================================
# RECEBER EVENTOS DOS PERSONAGENS
# ==========================================

# Executada quando qualquer membro perde
# ou recupera pontos de vida.
func _ao_mudar_vida(
	atual: int,
	maxima: int,
	id: String
) -> void:

	# Repassa o evento para outros sistemas.
	vida_membro_alterada.emit(id, atual, maxima)


# Executada quando um integrante é derrotado.
func _ao_derrotar(id: String) -> void:

	membro_derrotado.emit(id)

	print("Personagem derrotado: ", id)


# ==========================================
# MOSTRAR RESUMO NO CONSOLE
# ==========================================

func imprimir_resumo() -> void:

	print("========== PARTY ==========")

	for chave in membros:

		var id: String = str(chave)
		var personagem: AtributosCombate = obter_atributos(id)

		if personagem == null or personagem.dados == null:
			continue

		print(
			personagem.dados.nome,
			" | PV: ",
			personagem.vida_atual,
			"/",
			personagem.dados.vida_maxima
		)

	print("===========================")
