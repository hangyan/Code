	.literal16
	.align	4
_caml_negf_mask:	.quad   0x8000000000000000, 0
	.align	4
_caml_absf_mask:	.quad   0x7FFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
	.data
	.globl	_camlAs__data_begin
_camlAs__data_begin:
	.text
	.globl	_camlAs__code_begin
_camlAs__code_begin:
	nop
	.data
	.quad	0
	.globl	_camlAs
_camlAs:
	.data
	.globl	_camlAs__1
	.quad	2300
_camlAs__1:
	.ascii	"hello,world\12"
	.space	3
	.byte	3
	.text
	.align	4
	.globl	_camlAs__entry
_camlAs__entry:
	.cfi_startproc
	subq	$8, %rsp
	.cfi_adjust_cfa_offset	8
.L100:
	movq	_camlAs__1@GOTPCREL(%rip), %rbx
	movq	_camlPervasives@GOTPCREL(%rip), %rax
	movq	184(%rax), %rax
	call	_camlPervasives__output_string_1174
.L101:
	movq	$1, %rax
	addq	$8, %rsp
	.cfi_adjust_cfa_offset	-8
	ret
	.cfi_adjust_cfa_offset	8
	.cfi_endproc
	.data
	.text
	nop
	.globl	_camlAs__code_end
_camlAs__code_end:
	.data
	.globl	_camlAs__data_end
_camlAs__data_end:
	.long	0
	.globl	_camlAs__frametable
_camlAs__frametable:
	.quad	1
	.quad	.L101
	.word	17
	.word	0
	.align	3
	.set	L$set$1, (.L102 - .) + 0xac000000
	.long L$set$1
	.long	0x16f150
.L102:
	.asciz	"pervasives.ml"
	.align	3
