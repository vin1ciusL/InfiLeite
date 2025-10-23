# InfiLeite 

InfiLeite🐄 é uma DSL (domain-specific language) voltada para simular e automatizar rotinas de uma fazenda 🐄leiteira🐄 em um estilo idle game.  
Ela permite escrever programas em português que controlam produção, compra, venda e eventos aleatórios de forma automatizada.

🐄 - Propósito - 🐄

- Criar uma linguagem simples e legível para descrever estratégias automáticas em jogos tipo clicker/idle.
- Servir como exemplo educacional de construção de uma linguagem com Flex, Bison, C e uma VM própria.
- Demonstrar o pipeline completo: análise léxica, análise sintática, geração de código assembly e execução em máquina virtual.
🐄🐄🐄
Características principais da linguagem

- Sintaxe em português (`enquanto`, `se`, `senao`).
- Tipos básicos: números inteiros (long).
- Operadores aritméticos: `+`, `-`, `*`, `/`, `%`.

Estruturas fundamentais:

Atribuição (🐄!):
```
x = 10;
```

Condicional (🐄?):
```
se (x > 5) {
  vender(2);
} senao {
  comprar_vaca();
}
```

Loop (1🐄2🐄3🐄4🐄5🐄6🐄7🐄8🐄 ... N🐄):
```
enquanto (leite < 100) {
  ordenhar();
}
```

🐄 Funções nativas do domínio 🐄

- `ordenhar();` — Gera leite proporcional ao número de vacas.  
- `vender(qtd);` — Vende leite e converte em dinheiro.  
- `comprar_vaca();` — Compra vaca se houver dinheiro suficiente.  
- `comprar_fazenda();` — Requer 30 vacas e 100 de dinheiro; aumenta produção em 50%.  
- `aleatorio(a,b)` — Retorna número inteiro aleatório no intervalo.  
- `tomar_leite();` — Consome leite e exibe mensagem com base na qualidade.  
- `acasalar();` — Usa 2 vacas e cria 1 nova vaca.  (🐄 ❤️ 🐄)
- `cassino();` — Gasta 1000 dinheiros e pode retornar 1250 com 49% de chance.  
- `maquina(x);` — Ativa bônus (1–9) como copos, veículos e pastagens melhores.  
- `resultado();` — Exibe o estado atual (dinheiro, vacas, leite e operações).  
- `comprar_ate(n);` — Compra vacas até atingir n.  
- `tomar_tudo();` — Bebe todo o leite disponível.  
- `criar_vicio();` — Realiza várias apostas no cassino seguidas.

Estrutura interna do projeto 🐄🐄🐄🐄🐄🐄

- `gramatica.ebnf` — Definição da gramática formal da linguagem (EBNF).  
- `lexer.l` — Analisador léxico (Flex).  
- `parser.y` — Analisador sintático (Bison).  
- `ast.h` — Estruturas de dados da árvore sintática abstrata (AST).  
- `codegen.c` — Gera assembly textual para a VM (PUSH, ADD, JZ, etc).  
- `vm_interpreter.c` — Implementa a máquina virtual InfiVM — com pilha, variáveis e saltos.  
- `runtime.c` — Implementa as funções nativas e o "mundo das vacas".  
- `exec.c` — Executor direto do AST (modo interpretado).  
- `main.c` — Programa principal: integra parser, execução e limpeza de memória.  
- `Makefile` — Scripts de build automatizados.

🐄 Pipeline 🐄 de 🐄 compilação 🐄

.código fonte (.infi)  
    │  
    ▼  
[Flex] → Tokens  
    │  
    ▼  
[Bison] → Árvore Sintática (AST)  
    │  
    ├── Execução direta (interpretação)  
    └── Geração de código assembly → InfiVM  
        │  
        ▼  
       Execução final

Compilar e 🐄rodar🐄

Pré-requisitos: `flex`, `bison`, `gcc`, `make`.

```bash
make clean
make
./parser exemplos/demo.infi
```

Para testar o assembly gerado e a VM manualmente: (🐄🐄🐄)
```bash
./parser exemplos/demo.infi > out.asm
./vm out.asm
```

🐄🐄🐄

Exemplo de programa
```c
dinheiro = 0;
leite = 0;

enquanto (dinheiro < 1000) {
  ordenhar();
  vender(10);
  se (dinheiro > 50) {
    comprar_vaca();
  }
}

resultado();
```
🐄🐄🐄🐄
Créditos

Desenvolvido como parte da Atividade Prática Supervisionada (APS)  
Disciplina: Linguagens Formais e Compiladores  
Ferramentas: Flex, Bison, C, Make, VM própria (InfiVM)

🐄🐄🐄🐄