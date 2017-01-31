section .data
	salvar	db	"slvr"
	sair	db	"sair"
	words	db	"cpal"
	msg 	db 	"PASSOU AQUI"
	msg_L	equ $-msg

section .bss
	arq 		resb 10
	id_in		resd 1
	id_out		resd 2
	info 		resb 200
	new_info	resb 200

section .text
	global	_start:

	colocaFim:
		mov ebx,0
			
		.for:
			cmp [arq+ebx],byte 10
			je .retorna
			inc ebx
			jmp .for

		.retorna:
			mov [arq+ebx],byte 0
			ret		

	printaInfo:
		mov eax,4
		mov ebx,1
		mov ecx,info
		mov edx,[id_out]
		int 80h
		ret

	exibeArquivo:
		mov [id_in],eax
		mov eax,3
		mov ebx,[id_in]
		mov ecx,info
		mov edx,1024
		int 80h

		mov [id_out],eax
		call printaInfo
		cmp eax,edx
		jnb	exibeArquivo
		ret

	abreArquivo:
		mov	eax,5
		mov	ebx,arq
		mov ecx,2
		mov edx,0777q
		int 80h
		ret

	pegaArquivo:			;subrotina para pegar nome do arquivo
		pop	eax				;quantidade de argumentos
		pop	ecx				;argumento 1 (nome do programa)
		pop ecx
		cmp ecx,0
		jz	encerrar
		mov edx,0

		.strlen:
			mov al,[ecx+edx]
			mov [arq+edx],al
			cmp	[ecx+edx],byte 0
			jz	.home
			inc	edx
			jmp	.strlen

		.home:
			ret

	encerrar:					;subrotina para encerrar programa
		mov	eax,1
		mov	ebx,0

	_start:

		call	pegaArquivo		;verifica argumento recebido

		mov eax,4
		mov ebx,1
		mov ecx,msg
		mov edx,msg_L
		int 80h

		call 	colocaFim 		;coloca 0 no fim do nome do arquivo
		call	abreArquivo		;abre arquivo
		call	exibeArquivo	;exibe conteudo do arquivo
