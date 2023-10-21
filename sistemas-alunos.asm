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
.STACK 100h

.DATA
    tabela_alunos   DB  ?, ?, ?, ?, ?   ;aluno, p1, p2, p3, media
                    DB  ?, ?, ?, ?, ?
                    DB  ?, ?, ?, ?, ?
                    DB  ?, ?, ?, ?, ?
                    DB  ?, ?, ?, ?, ?

    menu_tabela     DB  "1. Ver tabela$"
    menu_aluno      DB  "2. Inserir aluno$"
    menu_corrigir   DB  "3. Corrigir notas$"
    menu_sair       DB  "0. Sair$"


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
    PUSH DX

    MOV AH, 09h
    MOV DX, OFFSET menu_tabela
    INT 21h

    PUSH AX
    nl
    POP AX

    MOV DX, OFFSET menu_aluno
    INT 21h

    PUSH AX
    nl
    POP AX

    MOV DX, OFFSET menu_corrigir
    INT 21h

    PUSH AX
    nl
    POP AX

    MOV DX, OFFSET menu_sair
    INT 21h

    PUSH AX
    nl
    POP AX

    POP DX
    POP AX
    RET
ENDP

print_tabela PROC NEAR  ;print nome, notas e media dos alunos

    RET
ENDP

inserir_dados PROC NEAR ;insere nome e notas dos alunos
    
    RET
ENDP

mudar_dados PROC NEAR   ;muda nota de 1 aluno
    
    RET
ENDP
END MAIN