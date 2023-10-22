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
;MATHEUS PITHON...

.MODEL SMALL

nl  MACRO   ;print new line
    MOV AH, 02

    MOV DL, 10
    INT 21h

    MOV DL, 13
    INT 21h
ENDM

space MACRO ;print space
    MOV AH, 02
    MOV DL, 32
    INT 21h
ENDM

input MACRO ;espera input do user
    MOV AH, 08h
    INT 21h
ENDM

.STACK 100h

.DATA
    NAME_LENGTH     EQU 50
    nomes           DB  NAME_LENGTH DUP (?), '$'
                    DB  NAME_LENGTH DUP (?), '$'
                    DB  NAME_LENGTH DUP (?), '$'
                    DB  NAME_LENGTH DUP (?), '$'
                    DB  NAME_LENGTH DUP (?), '$'

    notas           DB  3 DUP (?)
                    DB  3 DUP (?)
                    DB  3 DUP (?)
                    DB  3 DUP (?)
                    DB  3 DUP (?)

    medias          DB  5 DUP (?)

    menu_tabela     DB  "1. Ver tabela", 10, 13, '$'
    menu_aluno      DB  "2. Inserir aluno", 10, 13, '$'
    menu_corrigir   DB  "3. Corrigir notas", 10, 13, '$'
    menu_sair       DB  "0. Sair", 10, 13, '$'

    pede_enter      DB  "Pressione <enter>$"

    pede_nome       DB  "Digite o nome do aluno $"
    pede_p1         DB  "Digite a nota da P1: $"
    pede_p2         DB  "Digite a nota da P2: $"
    pede_p3         DB  "Digite a nota da P3: $"
    cadastros       DB  0
    cadastro_max    DB  "Ja possui 5 alunos cadastrados$"
    cadastro_ok     DB  "Cadastro realizado com sucesso!$"


.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX

    MOV AH, 08h
menu:
    CALL print_menu
    INT 21h     ;le input user
    AND AL, 0Fh ;decimal

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

print_menu PROC NEAR    ;print opcoes do menu
    PUSH AX

    nl  ;enter

    MOV AH, 09h
    MOV DX, OFFSET menu_tabela
    INT 21h

    MOV DX, OFFSET menu_aluno
    INT 21h

    MOV DX, OFFSET menu_corrigir
    INT 21h

    MOV DX, OFFSET menu_sair
    INT 21h

    POP AX
    RET
ENDP

print_tabela PROC NEAR  ;print nome, notas e media dos alunos

    RET
ENDP

inserir_dados PROC NEAR ;insere nome e notas dos alunos
    PUSH AX
    XOR AX, AX

    MOV AL, cadastros   ;checa se tem 5 alunos cadastrados
    CMP AL, 5
    JNE dados_n_cheios

    MOV AH, 09h         ;5 alunos cadastrados
    MOV DX, OFFSET cadastro_max
    INT 21h

    nl
    MOV DX, OFFSET pede_enter
    INT 21h
    input
    nl
    JMP sair_inserir_dados

dados_n_cheios:         ;ainda nao tem 5 alunos
    XOR AH, AH
    MOV DI, AX          ;alunos ja cadastrados
    MOV CX, 50          ;tamanho das string
    MUL CX              ;linha do aluno a ser cadastrado
    MOV SI, AX          ;coluna
    
    MOV AH, 09h
    MOV DX, OFFSET pede_nome    ;print pedindo nome
    INT 21h

escrever_nome:
    MOV AH, 01h                 ;le nome do aluno
    INT 21h

    CMP AL, 13
    JE terminou_nome             ;enter
    MOV nomes[SI], AL
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

    MOV AH, 01h                 
    INT 21h
    MOV notas[DI], AL        ;le nota p1
    INC DI

    nl  ;enter

    MOV AH, 09h
    MOV DX, OFFSET pede_p2      ;print pedindo p2
    INT 21h

    MOV AH, 01h  
    INT 21h
    MOV notas[DI], AL        ;le nota p2
    INC DI

    nl  ;enter

    MOV AH, 09h
    MOV DX, OFFSET pede_p3      ;print pedindo p3
    INT 21h

    MOV AH, 01h  
    INT 21h
    MOV notas[DI], AL        ;le nota p3
 
    nl  ;enter

    MOV AH, 09h
    MOV DX, OFFSET cadastro_ok
    INT 21h

    MOV AL, cadastros
    INC AL
    MOV cadastros, AL
    nl  ;enter
    
    MOV AH, 09h
    MOV DX, OFFSET pede_enter
    INT 21h
    nl  ;enter
    input
sair_inserir_dados:
    POP AX
    RET
ENDP

mudar_dados PROC NEAR   ;muda nota de 1 aluno
    
    RET
ENDP
END MAIN