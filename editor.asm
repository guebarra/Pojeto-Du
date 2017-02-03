section .data

	msg1	db	"Alterações salvas!",10
	msg1_L	equ $-msg1

	msg2	db	"Quantidade de palavras: "
	msg2_L	equ $-msg2

	msg3	db	"Saindo sem salvar!",10
	msg3_L	equ $-msg3

	pulalinha	db	10

section .bss
	arq 		resb 30
	new_info	resb 1000
	id_in		resb 4
	id_out		resb 4

	info 		resb 1000
	tam			resb 4

	aux 		resb 4
	caract		resb 1
	comando 	resb 5
	nro			resb 4
	res 		resb 4

section .text
	global	_start:

;**MACRO PARA CHAMADAS DO SISTEMA**
	%macro 	chamada 4
		mov eax,%1
		mov ebx,%2
		mov ecx,%3
		mov edx,%4
		int 80h
	%endmacro

;**EXIBIR CONTEÚDO DO ARQUIVO NA TELA**

	exibeArquivo:
		;le informação já contida no arquivo
		chamada 3,[id_in],info,1000

		mov [id_out],eax

		;imprime informação contida no arquivo
		chamada 4,1,info,[id_out]

		ret

;**COMANDOS**

	converteChar:
		mov ebx,0
		mov ecx,10

		.transformaCaract:
			mov edx,0
			div ecx
			add dl,'0'
			mov [res+ebx],dl
			inc ebx
			cmp eax,0
			jne .transformaCaract
			ret

	printarNro:
		dec ebx
		mov al,[res+ebx]
		mov [nro],al
		push ebx

		chamada 4,1,msg2,msg2_L

		chamada 4,1,nro,1

		pop ebx
		cmp ebx,0
		jne printarNro
		ret

	contaPalavras:
		mov ebx,-1
		mov ecx,0

		.loop:
			inc ebx
			cmp [info+ebx],byte 10
			je .conta
			cmp [info+ebx],byte ' '
			je .conta
			cmp [info+ebx],byte 0
			je .enter
			jmp .loop

		.conta:
			mov dl,[info+ebx]
			inc ebx
			cmp [info+ebx],dl
			je .conta
			dec ebx
			inc ecx
			jmp .loop

		.enter:
			mov eax,ecx
			ret

;**SALVAR NO ARQUIVO**

	salva:
		chamada 4,[id_in],new_info,[tam]

		mov eax,0
		mov edx,[id_out]

		.loop:
			mov cl,[new_info+eax]
			mov [info+edx],cl
			inc eax
			inc edx
			cmp eax,[tam]
			jne .loop

		mov ecx,0
		mov [tam],ecx

		chamada 4,1,msg1,msg1_L

		ret

;**LER NOVOS DADOS**

	lerNovoTexto:
		mov edx,0	;indice variável new_info
		mov [tam],edx
		.do:
			;lendo do terminal
			chamada 3,0,caract,1

			;se é / ele pula para a subrotina de comando
			cmp [caract],byte 47
			je .comando

			;se não é / ele continua 
			mov edx,[tam]
			mov al,[caract]
			mov [new_info+edx],al
			inc edx
			mov [tam],edx
			jmp .do

		.comando:
			chamada 3,0,comando,5

			cmp	[comando], dword "slvr"		;comando para salvar alterações
			je	.salvar

			cmp	[comando], dword "sair"		;comando para sair sem salvar
			je	.sair	

			cmp	[comando], dword "cpal"		;comando para contar palavras
			je	.palavras


			.salvar:
				call salva
				jmp .do

			.sair:
				chamada 4,1,msg3,msg3_L

				jmp encerrar

			.palavras:
				call contaPalavras
				call converteChar
				call printarNro
				jmp .do
				ret

;**CRIANDO ARQUIVO CASO N EXISTA**
	;criando arquivo
	criaArquivo:
		mov eax,8
		mov ebx,arq
		mov ecx,0777q
		int 80h

		ret

;**DEIXANDO ARQUIVO PRONTO PRA SER LIDO E ESCRITO**
	;abrindo  arquivo
	abreArquivo:
		chamada 5,arq,2,0777q
		
		cmp eax,0
		jl criaArquivo
	
		mov [id_in],eax
		ret

;**ENCERRANDO PROGRAMA**

	encerrar:					;subrotina para encerrar programa
		mov	eax,1
		mov	ebx,0
		int 80h

;**ROTINA PRINCIPAL**
	_start:

		pegaArquivo:			;subrotina para pegar nome do arquivo
			pop	eax				;quantidade de argumentos
			pop	ecx				;argumento 1 (nome do programa)
			pop ecx
			cmp ecx,0
			jz	encerrar
			mov edx,0

		strlen:
			mov al,[ecx+edx]
			mov [arq+edx],al
			cmp	[ecx+edx],byte 0
			je	continua
			inc	edx
			jmp	strlen

		continua:
			call	abreArquivo		;abre arquivo (se não existir, cria)

			call	exibeArquivo	;exibe conteudo do arquivo (se houver)

			call	lerNovoTexto	;le conteudo novo

			call encerrar