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

tab MACRO ;print 'tab'
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

limpa_tela MACRO
    PUSH AX

    MOV AX, 03h
    INT 10h

    XOR AX, AX      ;AL - Numero de linhas de Scroll -> 0 = Toda Tela
    XOR BX, BX      ;BH - Cor
    XOR CX, CX
    MOV DH, 18h     ;numero de linhas a limpar
    MOV DL, 4Fh     ;numero de colunas a limpar
    MOV AH, 06h     ;funcao de scroll up pra limpar tela
    INT 10h
    
    XOR DX, DX
    MOV AH, 02h
    INT 10h

    MOV AX, 03h
    INT 10h

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


    cadastros       DB  0                               ;qnt de alunos cadastrados

    pesos_provas    DB  3 DUP (1)                       ;peso de cada prova (1 como padrao)
    pede_pesos      DB  'Digite o peso da P1: $'        ;22 caracteres
                    DB  'Digite o peso da P2: $'        ;22 caracteres
                    DB  'Digite o peso da P3: $'        ;22 caracteres 

    header_tabela   DB  'NOMES', 4 DUP (9), 'P1', 9, 'P2', 9, 'P3', 4 DUP (' '), 'MEDIAS', 10, 13, '$'
    separa_tabela   DB  69 DUP ('-'), '$'

    menu_geral      DB  '1. Ver tabela', 10, 13
                    DB  '2. Inserir aluno', 10, 13
                    DB  '3. Corrigir notas', 10, 13
                    DB  '4. Definir peso', 10, 13
                    DB  '0. Sair', 10, 13, '$'

    pede_enter      DB  'Pressione <enter>$'

    pede_nome       DB  'Digite o nome do aluno: $'
    pede_provas     DB  'Digite a nota da P1: $'        ;22 caracteres
                    DB  'Digite a nota da P2: $'        ;22 caracteres
                    DB  'Digite a nota da P3: $'        ;22 caracteres

    cadastro_max    DB  'Ja possui 5 alunos cadastrados$'
    cadastro_ok     DB  'Cadastro realizado com sucesso!$'
    cadastro_vazio  DB  'Nenhum aluno cadastrado$'

    ask_nome_mudar  DB  'Deseja alterar a nota de qual aluno?', 10, 13, '$'
    checar_nome     DB  NAME_LENGTH DUP (?)
    nome_nao_existe DB  'Nome digitado nao existe$'
    confirmar_nome  DB  'Escolha qual prova alterar do aluno - $'
    
    opcoes_provas   DB  '1. Alterar P1', 10, 13
                    DB  '2. Alterar P2', 10, 13
                    DB  '3. Alterar P3', 10, 13
                    DB  '0. Voltar ao Menu', 10, 13, '$'

    ask_nova_nota   DB  'Digite a nota da P$'
    nota_alterada   DB  'Nota alterada com sucesso!$'

.CODE
main PROC
    MOV AX, @DATA
    MOV DS, AX


    MOV AH, 08h
menu:
    limpa_tela
    CALL print_menu
    INT 21h     ;le input user
    AND AL, 0Fh ;decimal

    limpa_tela
    CMP AL, 1
    JB sair     ;0. sair
    JE tabela   ;1. tabela

    CMP AL, 3
    JB inserir  ;2. inserir
    JE corrigir ;3. corrigir

    CMP AL, 4
    JE pesos    ;4. pesos
    JMP menu

tabela:
    CALL print_tabela
    PUSH AX

    new_line    ;enter
    MOV AH, 09h
    MOV DX, OFFSET pede_enter   ;pede input
    INT 21h
    input       ;espera input
    new_line    ;enter
    POP AX
    JMP menu

inserir:
    CALL inserir_dados
    JMP menu

corrigir:
    CALL mudar_dados
    JMP menu

pesos:
    CALL inserir_pesos
    JMP menu

sair:
    MOV AH, 4Ch
    INT 21h
ENDP

print_menu PROC     ;print opcoes do menu
    PUSH AX

    MOV AH, 09h
    MOV DX, OFFSET menu_geral
    INT 21h

    POP AX
    RET
ENDP

print_tabela PROC   ;print nome, notas e media dos alunos
    PUSH AX

    MOV CL, cadastros
    OR CL, CL
    JNZ da_para_cadastrar
    JMP nenhum_cadastro_tabela

da_para_cadastrar:
    CALL calcula_media


    MOV AH, 09h
    MOV DX, OFFSET header_tabela   ;printa cabeçalho
    INT 21H


    XOR DI, DI              ;endereço nomes
    XOR CX, CX
    XOR SI, SI              ;endereço medias
    XOR BX, BX              ;endereço notas

    MOV CL, cadastros       ;contador de alunos
loop_todos_alunos:
    PUSH CX                 ;guarda contador de quantos alunos tem que imprimir

    MOV AH, 09h
    MOV DX, OFFSET separa_tabela
    INT 21h
    new_line    ;enter

    MOV AH, 02h
    MOV CL, NAME_LENGTH     ;contador caracteres por nome
    loop_print_nome:
        MOV DL, nomes[DI]
        INT 21h
        INC DI              ;prox caracter
        DEC CL
        JNZ loop_print_nome

    MOV CX, 3               ;3 notas

    tab
printa_notas:
    XOR AX, AX
    MOV AL, notas[BX]       ;nota em AX

    CALL print_decimal      ;printa as notas

    tab         ;printa tab
    INC BX
    LOOP printa_notas
  

    XOR AX, AX
    MOV AL, medias[SI]      ;media em AX
    CALL print_decimal      ;print

    new_line    ;enter

    INC SI                  ;prox media
    POP CX
    DEC CX                  ;qnt de alunos - 1
    JZ sair_tabela          ;jmp if qnt de alunos = 0
    JMP loop_todos_alunos

nenhum_cadastro_tabela:
    MOV AH, 09h
    MOV DX, OFFSET cadastro_vazio   ;printa aviso
    INT 21h

sair_tabela:

    POP AX
    RET
ENDP

inserir_dados PROC  ;insere nome e notas dos alunos
    PUSH AX

    XOR AX, AX
    XOR BX, BX

    MOV AL, cadastros   ;checa se tem 5 alunos cadastrados
    CMP AL, 5
    JNE dados_n_cheios
    ;aviso de cadastro cheio e volta para o menu
    MOV AH, 09h         ;5 alunos cadastrados
    MOV DX, OFFSET cadastro_max
    INT 21h

    new_line
    MOV DX, OFFSET pede_enter
    INT 21h
    new_line
    input
    JMP sair_inserir_dados

    ;cadastro nao esta cheio
dados_n_cheios:

    MOV DI, AX              ;quantidade de alunos cadastrados
    XOR SI, SI              ;coluna do nome

    MOV CX, NAME_LENGTH     ;tamanho das string
    MUL CX                  ;qnt de alunos cadastrados x30
    MOV BX, AX              ;linha do aluno a ser cadastrado
    
    MOV AH, 09h
    MOV DX, OFFSET pede_nome    ;print pedindo nome
    INT 21h

escrever_nome:                  ;le nome do aluno
    MOV AH, 01h                 
    INT 21h                     ;le caracter

    CMP AL, 13
    JE terminou_nome            ;enter
    CMP AL, 8
    JNE n_backspace_insere      ;backspace

;nao permite apagar o que voce nao digitou
    OR SI, SI
    JNZ backspace_insere
    MOV AH, 02h
    MOV DL, ' '
    INT 21h
    JMP escrever_nome 

backspace_insere:
    DEC SI
    INC CX
    MOV DL, ?
    MOV nomes[BX+SI], DL        ;salva 'nada'
    MOV AH, 02h                 
    INT 21h                     ;printa 'nada'
    MOV DL, 8                   ;printa 'backspace' para mandar o cursor para a esquerda
    INT 21h
    JMP escrever_nome

n_backspace_insere:
    MOV nomes[BX+SI], AL        ;salva caracter
    INC SI
    LOOP escrever_nome          ;30 caracteres

terminou_nome:

    MOV AX, DI                  ;numero do aluno
    MOV CX, 3                   ;x3
    MUL CX                      
    MOV DI, AX                  ;linha na matriz notas - DI

    MOV DX, OFFSET pede_provas  ;end pedindo provas
le_notas:
    new_line  ;enter
    MOV AH, 09h
    INT 21h                     ;printa pedindo provas

    CALL le_decimal             ;le nota
    MOV notas[DI], AL           ;guarda nota
    INC DI                      ;endereco pra prox prova

    ADD DX, 22                  ;+22 caracteres para printar pedindo a prox prova
    LOOP le_notas

    new_line  ;enter

    MOV AH, 09h
    MOV DX, OFFSET cadastro_ok  ;printa aviso de cadastro realizado
    INT 21h

    MOV AL, cadastros
    INC AL
    MOV cadastros, AL
    new_line    ;enter
    
    MOV AH, 09h
    MOV DX, OFFSET pede_enter
    INT 21h
    new_line    ;enter
    input       ;espera input
sair_inserir_dados:
    POP AX
    RET
ENDP

mudar_dados PROC    ;muda nota de 1 aluno
    PUSH AX

    MOV CL, cadastros
    OR CL, CL
    JNZ tem_cadastro_p_mudar
    JMP nenhum_cadastro_dados
tem_cadastro_p_mudar:
    CALL print_tabela
    
    new_line
    MOV AH, 09h
    MOV DX, OFFSET ask_nome_mudar   ;pede nome p/ mudar
    INT 21h
    
    ;le nome
    MOV CX, NAME_LENGTH
    XOR DI, DI      ;posicao array checar_nome
le_nome_p_checar:
    MOV AH, 01h
    INT 21h

    CMP AL, 13
    JE sai_le_nome_p_checar ;enter
    CMP AL, 8
    JNE n_backspace_checa   ;backspace

;nao permite apagar o que voce nao digitou
    OR DI, DI
    JNZ backspace_checa
    MOV AH, 02h
    MOV DL, 13
    INT 21h
    JMP le_nome_p_checar

backspace_checa:
    INC CX
    DEC DI
    MOV DL, ?
    MOV checar_nome[DI], DL ;salva 'nada'
    MOV AH, 02h
    INT 21h                 ;printa 'nada'
    MOV DL, 8
    INT 21h                 ;printa 'backspace' para mandar o cursor para a esquerda
    JMP le_nome_p_checar

n_backspace_checa:
    MOV checar_nome[DI], AL ;salva nome
    INC DI
    LOOP le_nome_p_checar

sai_le_nome_p_checar:
;checar se nome existe
    XOR CX, CX
    MOV CL, cadastros   ;quantidade de nomes a checar

    MOV DH, NAME_LENGTH      ;checar todos caracteres
    XOR DL, DL      ;contador linha notas

    XOR SI, SI      ;linha na matriz dos nomes

    XOR BX, BX      ;coluna no array checar_nome e na matriz dos nomes
checar_nomes_loop:
    MOV AL, checar_nome[BX] ;caracter do nome digitado
    MOV AH, nomes[SI][BX]   ;caracter da matriz de nomes

    CMP AL, AH
    JE caracter_igual       ;se forem iguais
    
    ADD DL, 3               ;contador linha das notas
    MOV BX, NAME_LENGTH     ;caracteres diferentes
    ADD SI, BX      ;prox nome

    XOR BX, BX
    MOV DH, NAME_LENGTH       ;contador de caracteres iguais
    LOOP checar_nomes_loop

;nome nao existe
    new_line
    MOV AH, 09h
    MOV DX, OFFSET nome_nao_existe
    INT 21h
    new_line
    JMP  pedir_input

caracter_igual:         ;+1 caracter igual
    INC BX              ;prox caracter
    DEC DH              ;contador = 0?
    JNZ checar_nomes_loop

    PUSH DX             ;push linha matriz de notas
    new_line
    MOV AH, 09h
    MOV DX, OFFSET confirmar_nome
    INT 21h

    XOR BX, BX
    MOV AH, 02h
    MOV CX, NAME_LENGTH
print_nome_confirmar:
    MOV DL, nomes[SI][BX]
    INT 21h
    INC BX
    LOOP print_nome_confirmar
    
;perguntar qual nota mudar  *************************
    new_line
    MOV AH, 09h
    MOV DX, OFFSET opcoes_provas
    INT 21h

    MOV AH, 08h
    INT 21h
    AND AL, 0Fh
    MOV CL, AL      ;salva temporariamente prova selecionada

    new_line
    CMP AL, 1
    JE alterar_p1   ;1. alterar p1
    JB nao_alterar  ;0. menu

    CMP AL, 3
    JB alterar_p2   ;2. alterar p2
    JE alterar_p3   ;3. alterar p3
nao_alterar:
    POP SI
    JMP sair_alteracao

;mudar nota                 *************************
alterar_p1:
    MOV AH, 09h
    MOV DX, OFFSET ask_nova_nota
    INT 21h
;printa qual prova mudar
    MOV AH, 02h
    MOV AL, CL
    OR AL, 30h
    MOV DL, AL
    INT 21h
    new_line
    MOV DL, ' '
    INT 21h
    CALL le_decimal
    POP SI              ;contador linha notas
    MOV BX, 0
    MOV notas[SI][BX], AL

    JMP sair_mudar_dados
alterar_p2:
    MOV AH, 09h
    MOV DX, OFFSET ask_nova_nota
    INT 21h
;printa qual prova mudar
    MOV AH, 02h
    MOV AL, CL
    OR AL, 30h
    MOV DL, AL
    INT 21h
    new_line
    MOV DL, ' '
    INT 21h

    CALL le_decimal
    POP SI              ;contador linha notas
    MOV BX, 1
    MOV notas[SI][BX], AL

    JMP sair_mudar_dados
alterar_p3:
    MOV AH, 09h
    MOV DX, OFFSET ask_nova_nota
    INT 21h
;printa qual prova mudar
    MOV AH, 02h
    MOV AL, CL
    OR AL, 30h
    MOV DL, AL
    INT 21h
    new_line
    MOV DL, ' '
    INT 21h

    CALL le_decimal
    POP SI              ;contador linha notas
    MOV BX, 2
    MOV notas[SI][BX], AL

    JMP sair_mudar_dados
nenhum_cadastro_dados:
    MOV AH, 09h
    MOV DX, OFFSET cadastro_vazio   ;printa aviso
    INT 21h
    new_line    ;enter
    JMP pedir_input
sair_mudar_dados:
    MOV AH, 09h
    MOV DX, OFFSET nota_alterada
    INT 21h
    new_line    ;enter

pedir_input:
    MOV DX, OFFSET pede_enter   ;pede input
    INT 21h
    input       ;espera input
    new_line    ;enter

sair_alteracao:
    POP AX
    RET
ENDP

inserir_pesos PROC  ;inserir o peso das 3 provas
    PUSH AX

    XOR SI, SI
    MOV DX, OFFSET pede_pesos
    MOV CX, 3

le_pesos:
    MOV AH, 09h
    INT 21h
    CALL le_decimal
    MOV pesos_provas[SI], AL
    ADD DX, 22
    new_line
    INC SI
    LOOP le_pesos

    POP AX
    RET
ENDP

calcula_media PROC  ;calcula media dos alunos para função print_tabela
    PUSH AX

    XOR SI, SI  ;linha matriz das notas
    XOR BX, BX  ;coluna matriz das notas

    MOV CL, cadastros   ;contador quantidade de cadastros
    MOV CH, 3   ;contador de notas p/ aluno
    XOR DX, DX

soma_media:
    MOV AL, notas[SI][BX]
    MOV AH, pesos_provas[BX]
    MUL AH
    ADD DL, AL  ;soma
    INC BX      ;prox coluna
    DEC CH
    JNZ soma_media


    PUSH DX     ;salva soma das notas (invertida)
    ADD SI, 3   ;prox linha
    XOR BX, BX  ;coluna 0
    MOV CH, 3   ;contador de notas p/ aluno
    XOR DX, DX
    DEC CL      ;-1 aluno
    JNZ soma_media


    MOV CX, 3
    XOR AX, AX
    XOR BX, BX
soma_pesos:
    MOV AH, pesos_provas[BX]
    ADD AL, AH
    INC BX
    LOOP soma_pesos
    XOR BX, BX
    MOV BL, AL

    XOR CX, CX
    MOV CL, cadastros
    MOV SI, CX


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

le_decimal PROC     ;le numeros decimais e coloca em AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX, 10      ;multiplicacao
    XOR AX, AX      ;soma
    XOR CX, CX

le_numero:
    PUSH AX         ;salva na pilha a soma (0 no primeiro numero)
    MOV AH, 01h
    INT 21h         ;le caracter

    CMP AL, 13
    JE sai_le_decimal
    CMP AL, 8
    JNE n_backspace_dec
    
;nao permite apagar o que voce nao digitou
    OR BH, BH
    JNZ backspace_dec
    MOV AH, 02h
    MOV DL, ' '
    INT 21h
    POP AX
    XOR AX, AX
    JMP le_numero

backspace_dec:
    MOV AH, 02h
    MOV DL, ?
    INT 21h
    MOV DL, 8
    INT 21h
    XOR DX, DX
    DEC BH          ;contador 'backspace'
    POP AX
    SUB AX, CX
    DIV BL
    JMP le_numero

n_backspace_dec:
    XOR DX, DX
    AND AL, 0Fh     ;transforma em numero
    MOV CL, AL      ;guarda numero temporariamente
    POP AX          ;pega resultado da soma anterior (ou 0)
    MUL BL
    ADD AX, CX      ;soma em AX
    INC BH          ;contador 'backspace'
    JMP le_numero

sai_le_decimal:
    POP AX          ;resultado em AX

    POP DX
    POP CX
    POP BX
    RET
ENDP

print_decimal PROC  ;printa decimais (numero em AX)
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