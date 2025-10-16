# InfiLeite

InfiLeite é uma **DSL (domain-specific language)** projetada para scripts de jogos do tipo *idle*.  
A linguagem permite escrever rotinas que automatizam a produção, venda e compra de ativos (leite e vacas).

## Propósito
- Fornecer uma linguagem simples e legível para descrever estratégias automáticas em jogos clicker/idle.
- Permitir experimentação com lógica de automação (loops, condicionais, funções de domínio e aleatoriedade).

## Principais características da linguagem
- Sintaxe em português (palavras-chave): `enquanto`, `se`, `senao`.
- Tipos básicos: números inteiros (long).
- Operadores aritméticos: `+`, `-`, `*`, `/`, `%`.
- Variáveis por atribuição: `x = 10;`
- Condicionais: `se (cond) { ... } [senao { ... }]`
- Loops: `enquanto (cond) { ... }`
- Funções nativas do domínio (implementadas no interpretador):

  - `ordenhar();` — gera leite (quantidade aleatória dependente do número de vacas).  
  - `vender(qtd);` — converte leite em dinheiro (taxa fixa).  
  - `comprar_vaca();` — gasta dinheiro para aumentar produção.  
  - `comprar_fazenda();` — requer 30 vacas e 100 de dinheiro, aumenta a produção das vacas em 50%.  
  - `aleatorio(a,b)` — retorna um inteiro aleatório entre `a` e `b`.  
  - `print(expr);` — imprime o valor da expressão.  
  - `tomar_leite();` — consome 1 unidade de leite e exibe uma mensagem de acordo com a qualidade do copo.  
  - `acasalar();` — usa 2 vacas para criar 1 nova vaca com 80% menos produção.  
  - `cassino();` — gasta 1000 dinheiros e tem 49% de chance de retornar 1250.  
  - `maquina(x);` — configura bônus e itens do jogo, com 9 opções:  
    1. copo ruim — muda a mensagem de `tomar_leite()` para “é nutritivo!”  
    2. copo bom — “é nutritivo!!”  
    3. copo ótimo — “é bem nutritivo!!”  
    4. veículo pequeno — reduz o preço das vacas em 5%  
    5. veículo médio — reduz em 10%  
    6. veículo grande — reduz em 20%  
    7. pastagens melhores — 10% de chance de cada vaca gerar +1 leite  
    8. pastagens incríveis — 20%  
    9. paraíso vacal — 30%  
  - `resultado();` — mostra quantas operações foram realizadas, o total de dinheiro, vacas, leite e vacas geradas.

## Estrutura interna
- Gramática definida em `gramatica.ebnf`.  
- Lexer: `lexer.l` (Flex).  
- Parser: `parser.y` (Bison).  
- Interpretação: ações de jogo executadas durante a análise (execução direta).

## Compilar e rodar
Pré-requisitos: `flex`, `bison`, `gcc`, `make`.

```bash
make clean
make
./parser exemplos/demo.infi
