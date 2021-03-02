;; CALL FAR DEFINES
%define JUMP_DIST 0x7100
%define CALL_AMOUNT 0x80
%define CALL_DIST (CALL_AMOUNT * 0x4)
%define MAGIC_SEG 0x1002
%define ADD_SP (JUMP_DIST + CALL_DIST)
%define ZOMB_COUNTER 0x515
%define SHARE_LOC 0x39AC
%define ROWS_GAP 0x2
;;
;; ZOMBIE DEFINES
%define DELTA_FROM_ZOMBSTART 0x72
%define CALL_DI 0x95FF
%define ZOMB_JUMPLOC 0x8346
%define ZOMB_JUMP_OPCODE (((@zomb_land - @zomb_jump - 0x2) * 0x100) + 0xEB)
%define ZOMB_NOP_JUMP_OPCODE (((@create_zombie_delta - @write_nop - 0x2) * 0x100) + 0xEB)
;;
;; INT 87, 86 DEFINES
%define INT87_OPCODE_1 0xA5A5
%define INT87_OPCODE_2 0xA5A5
;;


@start:
jmp short @our_start

@zomb_wait_value:
db 0x1

@zomb_start:
call @call_here
@call_here:
pop ax
sub ax,(@call_here - @start)

mov si,ax

@zomb_wait:
xchg bl,[si + @zomb_wait_value]
cmp bl,0x1
jnz @zomb_wait

mov byte [si+@zomb_wait_value],bl

@our_start:

push ss
pop es

xchg si,ax
add si,@copy
mov cl,(@copy_end - @copy)/0x2
rep movsw

mov al,0xA8
@write_nop:
xchg [SHARE_LOC],ah
@create_zombie_delta:
add ah,((JUMP_DIST/0x100) + ROWS_GAP + 0x2)

add byte [si - @copy_end + @create_zombie_delta + 0x2],(ROWS_GAP + 0x2)

push ss
pop ds

mov bx,di
stosw
mov word [di],MAGIC_SEG

mov word [bx+di-0x4],ADD_SP

push cs
pop es

mov di,ax
add di,0x2000

mov ax,0xCCCC
mov dx,ax
mov bx,INT87_OPCODE_1
mov cx,INT87_OPCODE_2

int 0x86
int 0x86

xchg ax,bx
xchg cx,dx

int 0x87

@zomb_jump:
push es
pop ds

mov cx,0x3
@reppppp:
cbw
cwd
loop @reppppp
nop

mov word [si-@copy_end+@write_nop],ZOMB_NOP_JUMP_OPCODE

lea dx,[si-@copy_end+@zomb_start]
mov bx,si
mov cl,0x4
mov bp,CALL_DI
mov si,ZOMB_JUMPLOC
mov word [bx - @array + @zomb_jump],ZOMB_JUMP_OPCODE

push word [0x8400]
push word [0x8200]
push word [0x8600]
push word [0x8700]

@zomb_loop:
pop ax
xlatb
xchg al,ah
xlatb
xor ah,al
mov di,ax
mov [si],dx
mov [di+DELTA_FROM_ZOMBSTART],bp
loop @zomb_loop

jmp short @skip_zomb_counter

@zomb_land:
mov bp,ZOMB_COUNTER

@skip_zomb_counter:
push ss
pop ds

mov si,(@loop_end - @copy)
lea bx,[si+0x2]

mov dx,JUMP_DIST
mov al,0xA5

les di,[bx]

push cs
pop ss

mov sp,[bx]
add sp,(CALL_DIST + 0x20)
mov cx,(@loop_end - @loop)/0x2

movsw
xor si,si
dec di

call far [bx]

@copy:
rep movsw

@loop:
add [bx],dx
les di,[bx]
add sp,[bx+si]
mov cl,(@loop_end - @loop)/0x2
movsw
xor si,si
dec di
dec bp
db 0x75
db 0xFF
db 0x1F

@loop_end:
call far [bx]
@copy_end:


@array:
db 0x00
db 0x2e
db 0x88
db 0xa6
db 0x2b
db 0x05
db 0xa3
db 0x8d
db 0x93
db 0xbd
db 0x1b
db 0x35
db 0xb8
db 0x96
db 0x30
db 0x1e
db 0x4e
db 0x60
db 0xc6
db 0xe8
db 0x65
db 0x4b
db 0xed
db 0xc3
db 0xdd
db 0xf3
db 0x55
db 0x7b
db 0xf6
db 0xd8
db 0x7e
db 0x50
db 0xfa
db 0xd4
db 0x72
db 0x5c
db 0xd1
db 0xff
db 0x59
db 0x77
db 0x69
db 0x47
db 0xe1
db 0xcf
db 0x42
db 0x6c
db 0xca
db 0xe4
db 0xb4
db 0x9a
db 0x3c
db 0x12
db 0x9f
db 0xb1
db 0x17
db 0x39
db 0x27
db 0x09
db 0xaf
db 0x81
db 0x0c
db 0x22
db 0x84
db 0xaa
db 0x6a
db 0x44
db 0xe2
db 0xcc
db 0x41
db 0x6f
db 0xc9
db 0xe7
db 0xf9
db 0xd7
db 0x71
db 0x5f
db 0xd2
db 0xfc
db 0x5a
db 0x74
db 0x24
db 0x0a
db 0xac
db 0x82
db 0x0f
db 0x21
db 0x87
db 0xa9
db 0xb7
db 0x99
db 0x3f
db 0x11
db 0x9c
db 0xb2
db 0x14
db 0x3a
db 0x90
db 0xbe
db 0x18
db 0x36
db 0xbb
db 0x95
db 0x33
db 0x1d
db 0x03
db 0x2d
db 0x8b
db 0xa5
db 0x28
db 0x06
db 0xa0
db 0x8e
db 0xde
db 0xf0
db 0x56
db 0x78
db 0xf5
db 0xdb
db 0x7d
db 0x53
db 0x4d
db 0x63
db 0xc5
db 0xeb
db 0x66
db 0x48
db 0xee
db 0xc0
db 0x80
db 0xae
db 0x08
db 0x26
db 0xab
db 0x85
db 0x23
db 0x0d
db 0x13
db 0x3d
db 0x9b
db 0xb5
db 0x38
db 0x16
db 0xb0
db 0x9e
db 0xce
db 0xe0
db 0x46
db 0x68
db 0xe5
db 0xcb
db 0x6d
db 0x43
db 0x5d
db 0x73
db 0xd5
db 0xfb
db 0x76
db 0x58
db 0xfe
db 0xd0
db 0x7a
db 0x54
db 0xf2
db 0xdc
db 0x51
db 0x7f
db 0xd9
db 0xf7
db 0xe9
db 0xc7
db 0x61
db 0x4f
db 0xc2
db 0xec
db 0x4a
db 0x64
db 0x34
db 0x1a
db 0xbc
db 0x92
db 0x1f
db 0x31
db 0x97
db 0xb9
db 0xa7
db 0x89
db 0x2f
db 0x01
db 0x8c
db 0xa2
db 0x04
db 0x2a
db 0xea
db 0xc4
db 0x62
db 0x4c
db 0xc1
db 0xef
db 0x49
db 0x67
db 0x79
db 0x57
db 0xf1
db 0xdf
db 0x52
db 0x7c
db 0xda
db 0xf4
db 0xa4
db 0x8a
db 0x2c
db 0x02
db 0x8f
db 0xa1
db 0x07
db 0x29
db 0x37
db 0x19
db 0xbf
db 0x91
db 0x1c
db 0x32
db 0x94
db 0xba
db 0x10
db 0x3e
db 0x98
db 0xb6
db 0x3b
db 0x15
db 0xb3
db 0x9d
db 0x83
db 0xad
db 0x0b
db 0x25
db 0xa8
db 0x86
db 0x20
db 0x0e
db 0x5e
db 0x70
db 0xd6
db 0xf8
db 0x75
db 0x5b
db 0xfd
db 0xd3
db 0xcd
db 0xe3
db 0x45
db 0x6b
db 0xe6
db 0xc8
db 0x6e
db 0x40
@end:
