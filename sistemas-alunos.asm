;Suponha uma sala com 5 alunos, e com 3 provas.
;Supor  trabalhar  só  com  números  inteiros.

;O programa deverá permitir a inserção dos nomes dos alunos,
;de  suas  notas  e  calcular  a  média  ponderada.
;Deverá também permitir a correção das notas, através do nome e da avaliação.
;Deverá permitir a impressão da planilha  de  notas.

;Usar  conceitos  de  procedimentos,  macros,  endereçamento  de  matrizes  e  outros.
;O programa deverá ser comentado e dentro do arquivo deverá ter os nomes dos participantes.

;INTEGRANTES:
;CAIO NICOLAS MAROSTICA RANDO   RA: 23010691
;MATHEUS PITHON YAMAUCHI        RA: 23005808

.MODEL SMALL

new_line  MACRO   ;print 'enter'
    PUSH AX
    PUSH DX

    MOV AH, 02

    MOV DL, 10
    INT 21h

    MOV DL, 13
    INT 21h
    
    POP DX
    POP AX
ENDM

space MACRO ;print 'space'
    PUSH AX
    PUSH DX

    MOV AH, 02
    MOV DL, 9
    INT 21h

    POP DX
    POP AX
ENDM

input MACRO ;espera input do user
    PUSH AX
    MOV AH, 08h
    INT 21h
    POP AX
ENDM

.STACK 100h

.DATA
    NAME_LENGTH     EQU 30
    nomes           DB  NAME_LENGTH DUP (?), '$'        ;Matriz para os 5 nomes
                    DB  NAME_LENGTH DUP (?), '$'
                    DB  NAME_LENGTH DUP (?), '$'
                    DB  NAME_LENGTH DUP (?), '$'
                    DB  NAME_LENGTH DUP (?), '$'

    notas           DB  3 DUP (?)                       ;Matriz 3 notas por aluno
                    DB  3 DUP (?)
                    DB  3 DUP (?)
                    DB  3 DUP (?)
                    DB  3 DUP (?)

    medias          DB  5 DUP (?)                       ;Array para as 5 medias

    cadastros       DB  0

    menu_geral      DB  "1. Ver tabela", 10, 13
                    DB  "2. Inserir aluno", 10, 13
                    DB  "3. Corrigir notas", 10, 13
                    DB  "0. Sair", 10, 13, '$'

    pede_enter      DB  "Pressione <enter>$"

    pede_nome       DB  "Digite o nome do aluno: $"
    pede_p1         DB  "Digite a nota da P1: $"
    pede_p2         DB  "Digite a nota da P2: $"
    pede_p3         DB  "Digite a nota da P3: $"

    cadastro_max    DB  "Ja possui 5 alunos cadastrados$"
    cadastro_ok     DB  "Cadastro realizado com sucesso!$"
    cadastro_vazio  DB  "Nenhum aluno cadastrado$"


.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX

    MOV AH, 08h
menu:
    CALL print_menu
    INT 21h     ;le input user
    AND AL, 0Fh ;decimal

    new_line
    CMP AL, 1
    JE tabela   ;1. tabela
    JB sair     ;0. sair

    CMP AL, 2
    JE inserir  ;2. inserir
    JA corrigir ;3. corrigir
    JMP menu

tabela:
    CALL print_tabela
    JMP menu

inserir:
    CALL inserir_dados
    JMP menu

corrigir:
    CALL mudar_dados
    JMP menu

sair:
    MOV AH, 4Ch
    INT 21h
ENDP

print_menu PROC NEAR    ;print opcoes do menu                               PRONTO
    PUSH AX

    new_line  ;enter

    MOV AH, 09h
    MOV DX, OFFSET menu_geral
    INT 21h

    POP AX
    RET
ENDP

print_tabela PROC NEAR  ;print nome, notas e media dos alunos
    PUSH AX

    MOV CL, cadastros
    OR CL, CL
    JNZ tem_cadastro
    JMP nenhum_cadastro

tem_cadastro:
    CALL calcula_media

    XOR DI, DI              ;endereço nomes
    XOR CX, CX
    XOR SI, SI              ;endereço medias

    MOV CL, cadastros
loop_todos_alunos:
    PUSH CX                 ;guarda contador de quantos alunos tem que imprimir
    PUSH SI                 ;prox media

    MOV AH, 02h
    MOV CL, NAME_LENGTH              ;contador caracteres p/ nome
    loop_print_nome:
        MOV DL, nomes[DI]
        INT 21h
        INC DI
        DEC CL
        JNZ loop_print_nome


    XOR BX, BX              ;endereço notas
    MOV CX, 3               ;3 notas

    space
printa_notas:
    XOR AX, AX
    MOV AL, notas[BX]       ;nota em AX

    CALL print_decimal

    space
    INC BX
    LOOP printa_notas
  

    POP SI
    MOV AH, 02h
    MOV DL, medias[SI]
    OR DL, 30h
    INT 21h
    new_line


    INC BX
    INC SI
    POP CX
    DEC CX
    JZ sair_tabela
    JMP loop_todos_alunos

nenhum_cadastro:
    MOV AH, 09h
    MOV DX, OFFSET cadastro_vazio
    INT 21h

sair_tabela:
    new_line
    MOV AH, 09h
    MOV DX, OFFSET pede_enter
    INT 21h
    input
    new_line
    POP AX
    RET
ENDP

inserir_dados PROC NEAR ;insere nome e notas dos alunos                     PRONTO
    PUSH AX
    XOR AX, AX
    XOR BX, BX

    MOV AL, cadastros   ;checa se tem 5 alunos cadastrados
    CMP AL, 5
    JNE dados_n_cheios

    MOV AH, 09h         ;5 alunos cadastrados
    MOV DX, OFFSET cadastro_max
    INT 21h

    new_line
    MOV DX, OFFSET pede_enter
    INT 21h
    new_line
    input
    JMP sair_inserir_dados

dados_n_cheios:         ;ainda nao tem 5 alunos

    MOV DI, AX
    XOR SI, SI          ;coluna
    MOV CX, NAME_LENGTH          ;tamanho das string
    MUL CX
    MOV BX, AX          ;linha do aluno a ser cadastrado
    
    MOV AH, 09h
    MOV DX, OFFSET pede_nome    ;print pedindo nome
    INT 21h

escrever_nome:
    MOV AH, 01h                 ;le nome do aluno
    INT 21h

    CMP AL, 13
    JE terminou_nome             ;enter
    MOV nomes[BX+SI], AL
    INC SI
    JMP escrever_nome

terminou_nome:
    XOR AX, AX
    MOV CX, 3                   ;x3
    MOV AX, DI                  ;numero do aluno
    MUL CX                      ;linha na matriz notas - DI
    MOV DI, AX

    MOV AH, 09h
    MOV DX, OFFSET pede_p1      ;print pedindo p1
    INT 21h

    XOR CX, CX                  ;contador de numeros inseridos
    MOV BX, 10
le_p1:                          ;le p1
    MOV AH, 01h
    INT 21h
    CMP AL, 13                  ;cmp enter
    JE sair_p1

    AND AL, 0Fh

    CMP CX, 0
    JNE pilha_p1                ;nao é primeiro digito

    XOR AH, AH
    PUSH AX 
    INC CX
    JMP le_p1

pilha_p1:
    MOV DL, AL                  ;guarda AL
    POP AX                      ;pega primeiro digito
    MUL BX                      ;primeiro digito x10
    ADD AL, DL                  ;primeiro_d x10 + segundo digito
    PUSH AX                     ;salva numero
    JMP le_p1

sair_p1:                        ;digitou enter
    POP AX
    MOV notas[DI], AL           ;guarda nota p1
    INC DI                      ;endereco pra p2

    MOV AH, 09h
    MOV DX, OFFSET pede_p2      ;print pedindo p2
    INT 21h

    XOR CX, CX                  ;contador
le_p2:                          ;le p2
    MOV AH, 01h
    INT 21h
    CMP AL, 13
    JE sair_p2

    AND AL, 0Fh

    CMP CX, 0                   ;ve se eh primeiro digito
    JNE pilha_p2

    XOR AH, AH
    PUSH AX 
    INC CX
    JMP le_p2

pilha_p2:                       ;primeiro_d x 10 + segundo digito
    MOV DL, AL
    POP AX
    MUL BX
    ADD AL, DL
    PUSH AX                     ;guarda numero na pilha
    JMP le_p2
sair_p2:
    POP AX
    MOV notas[DI], AL           ;salva nota p2
    INC DI

    MOV AH, 09h
    MOV DX, OFFSET pede_p3      ;print pedindo p3
    INT 21h

    XOR CX, CX                  ;contador
le_p3:                          ;le p3
    MOV AH, 01h
    INT 21h
    CMP AL, 13
    JE sair_p3

    AND AL, 0Fh

    CMP CX, 0
    JNE pilha_p3

    XOR AH, AH
    PUSH AX 
    INC CX
    JMP le_p3

pilha_p3:                       ;primeiro_d x 10 + segundo digito
    MOV DL, AL
    POP AX
    MUL BX
    ADD AL, DL
    PUSH AX                     ;guarda nota na pilha
    JMP le_p3
sair_p3:                        ;digitou enter
    POP AX
    MOV notas[DI], AL           ;salva nota p3
    INC DI

    new_line  ;enter

    MOV AH, 09h
    MOV DX, OFFSET cadastro_ok
    INT 21h

    MOV AL, cadastros
    INC AL
    MOV cadastros, AL
    new_line  ;enter
    
    MOV AH, 09h
    MOV DX, OFFSET pede_enter
    INT 21h
    new_line  ;enter
    input
sair_inserir_dados:
    POP AX
    RET
ENDP

mudar_dados PROC NEAR   ;muda nota de 1 aluno
    PUSH AX

    POP AX
    RET
ENDP

calcula_media PROC NEAR ;calcula media dos alunos para função print_tabela  PRONTO
    PUSH AX

    XOR SI, SI  ;linha matriz das notas
    XOR BX, BX  ;coluna matriz das notas

    MOV CL, cadastros   ;contador quantidade de cadastros
    MOV CH, 3   ;contador de notas p/ aluno
    XOR AX, AX
soma_media:
    MOV AH, notas[SI][BX]
    ADD AL, AH  ;soma
    INC BX      ;prox coluna
    DEC CH
    JNZ soma_media

    XOR AH, AH 
    PUSH AX     ;salva soma das notas (invertida)
    ADD SI, 3   ;prox linha
    XOR BX, BX  ;coluna 0
    MOV CH, 3   ;contador de notas p/ aluno
    XOR AX, AX
    DEC CL      ;-1 aluno
    JNZ soma_media

    XOR CX, CX
    MOV CL, cadastros
    MOV SI, CX
    MOV BX, 3

divide_media:
    XOR DX, DX
    POP AX
    DIV BX
    DEC SI
    MOV medias[SI], AL
    LOOP divide_media

    POP AX
    RET
ENDP

print_decimal PROC NEAR ;printa decimais (numero em AX)
    PUSH BX
    PUSH CX
    PUSH DX

    XOR CX, CX
    MOV BX, 10

empilha_dec:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNZ empilha_dec

    MOV AH, 02h
desempilha_dec:
    POP DX
    OR DL, 30h
    INT 21h
    LOOP desempilha_dec

    POP DX
    POP CX
    POP BX
    RET
ENDP
END MAIN