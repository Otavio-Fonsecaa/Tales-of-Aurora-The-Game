# Tales of Aurora — Projeto unificado

**Projeto Godot 4.5.1 (renderizador Compatibilidade), configurado em português (Brasil).**

Para abrir: Godot → Gerenciador de Projetos → Importar → selecione `project.godot` nesta pasta. Aguarde a reimportação das imagens na primeira abertura (a pasta `.godot` de cache não foi incluída). Execute com **F5**.

## O que já está implementado

- Mapa `cenas/exploracao/mundo.tscn` com camadas de terreno e objetos, TileSet, colisões e pedra.
- Forácio: andar em 8 direções, animações de caminhar, pose 0 ao parar, câmera e colisões.
- Grupo `jogador` cadastrado na cena `jogador.tscn`.
- Sr. Pu Terrier: sprite estático, área de interação e diálogo com escolhas, retratos de Forácio e do garçom.
- `DialogoUI` registrado em **Autoload**, com efeito de digitação, retratos e respostas selecionáveis.
- `npc_base.tscn` + `npc_base.gd`: NPCs básicos configuráveis por nome, retrato e linhas de diálogo.
- Cenas herdadas de Hayate e Sota com sprites e falas provisórias.

## Exatamente onde o desenvolvimento parou

As cenas `hayate.tscn` e `sota.tscn` já existem, mas **não foram colocadas no mapa `mundo.tscn`**, acompanhando a etapa em que o desenvolvimento parou. Os retratos específicos desses dois NPCs ainda **não foram atribuídos**; suas falas funcionam sem imagem. O NPC Sr. Pu Terrier continua com a implementação especial de múltipla escolha.

A cena `jogador.tscn` guarda o nó-base e o grupo; os filhos gráficos, câmera e script de movimentação foram montados na instância dentro de `mundo.tscn`, exatamente como nos arquivos de origem. Não altere essa estrutura sem atualizar a cena do jogador.

## Notas da unificação

- Base: `Tales-of-Aurora-The-Game-main.zip` (ramificação com o sistema de diálogos, Autoload, retratos e NPCs reutilizáveis).
- Inclusões de `Tales-of-Aurora-The-Game-main (1).zip`: imagens Hayate e Sota com variantes de arte, além de uma cópia histórica em `.txt` do diálogo anterior.
- `hayate.tscn` teve o caminho de textura inexistente corrigido para o sprite da segunda origem (`assets/personagens/Hayate/Hayate-sprite-estatico.png`).
- As alternativas artísticas `Hayato-sprite-estatico.png` e `Sota-sprite-estatico.png` da ramificação principal foram mantidas nos caminhos originais, evitando perder qualquer variação.
- Recursos PNG idênticos sob nomes diferentes não foram duplicados.
- A pasta de cache `.godot/` dos projetos originais foi excluída; o Godot a reconstrói automaticamente.
- Os sistemas de exploração e diálogos não tiveram seus comportamentos alterados na mesclagem.

## Teste de aceitação no Godot

1. Confirme que o projeto inicia com **F5** e mostra o mapa.
2. Mova o Forácio usando WASD/setas; verifique animação, pose parada, câmera e colisões.
3. Aproxime-se do Sr. Pu Terrier, pressione **E**, avance com Enter/Espaço, verifique os retratos e as opções.
4. Após encerrar o diálogo, verifique que o Forácio volta a andar.
5. Para testar Hayate e Sota, instancie `hayate.tscn` e `sota.tscn` dentro do mapa e coloque-os em pontos acessíveis.
