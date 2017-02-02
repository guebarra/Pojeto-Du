section .data

	msg1	db	"Conteúdo salvo!",10
	msg1_L	equ $-msg1

	msg2	db	"Quantidade de palavras: "
	msg2_L	equ $-msg2

	msg3	db	"Deseja salvar? (s ou n): "
	msg3_L	equ $-msg3

	msg4	db	"Saindo sem salvar!",10
	msg4_L	equ $-msg4

	pulalinha	db	10

section .bss
	id_in		resb 4
	tam			resb 4
	arq 		resb 30
	id_out		resb 4
	aux 		resb 4
	caract		resb 1
	comando 	resb 5
	opcao		resb 1
	nro			resb 4
	res 		resb 4
	info 		resb 1000
	new_info	resb 1000

section .text
	global	_start:

;**EXIBIR CONTEÚDO DO ARQUIVO NA TELA**

	exibeArquivo:
		;le informação já contida no arquivo
		mov eax,3
		mov ebx,[id_in]
		mov ecx,info
		mov edx,1000
		int 80h

		mov [id_out],eax

		;imprime informação contida no arquivo
		mov eax,4
		mov ebx,1
		mov ecx,info
		mov edx,[id_out]
		int 80h

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

		mov eax,4
		mov ebx,1
		mov ecx,msg2
		mov edx,msg2_L
		int 80h

		mov eax,4
		mov ebx,1
		mov ecx,nro
		mov edx,1
		int 80h

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

	salva:
		mov eax,4
		mov ebx,[id_in]
		mov ecx,new_info
		mov edx,[tam]
		int 80h

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

		mov eax,4
		mov ebx,1
		mov ecx,msg1
		mov edx,msg1_L
		int 80h

		ret

;**LER NOVOS DADOS**

	lerNovoTexto:
		mov edx,0	;indice variável new_info
		mov [tam],edx
		.do:
			;lendo do terminal
			mov eax,3
			mov ebx,0
			mov ecx,caract
			mov edx,1
			int 80h

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
			mov eax,3
			mov ebx,0
			mov ecx,comando
			mov edx,5
			int 80h

			cmp	[comando], dword "slvr"
			je	.salvar

			cmp	[comando], dword "sair"
			je	.sair

			cmp	[comando], dword "cpal"
			je	.palavras


			.salvar:
				call salva
				jmp .do

			.sair:

				mov eax,4
				mov ebx,1
				mov ecx,msg3
				mov edx,msg3_L
				int 80h

				mov eax,3
				mov ebx,0
				mov ecx,opcao
				mov edx,5
				int 80h

				cmp	[opcao], dword "s"
				je .salvar

				mov eax,4
				mov ebx,1
				mov ecx,msg4
				mov edx,msg4_L
				int 80h

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
		mov	eax,5
		mov	ebx,arq
		mov ecx,2
		mov edx,0777q
		int 80h
		
		cmp eax,0
		jl criaArquivo
	
		mov [id_in],eax
		ret

;**PEGANDO NOME DO ARQUIVO PELA PASSAGEM DE ARGUMENTOS**

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

			call	lerNovoTexto		;le conteudo novo



;			call	fechaArquivo	;fecha arquivo
;			jmp .do
			call encerrar