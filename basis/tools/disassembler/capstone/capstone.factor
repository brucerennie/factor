! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data
alien.destructors alien.libraries alien.strings alien.syntax
arrays classes.struct combinators destructors hex-strings kernel
math namespaces sequences specialized-arrays system
tools.disassembler.private tools.memory ;
IN: tools.disassembler.capstone

C-LIBRARY: libcapstone {
    { windows "libcapstone.dll" }
    { macos "libcapstone.dylib" }
    { unix "libcapstone.so" }
}

LIBRARY: libcapstone

TYPEDEF: size_t csh

ENUM: cs_arch
    CS_ARCH_ARM
    CS_ARCH_ARM64
    CS_ARCH_MIPS
    CS_ARCH_X86
    CS_ARCH_PPC
    CS_ARCH_SPARC
    CS_ARCH_SYSZ
    CS_ARCH_XCORE
    CS_ARCH_M68K
    CS_ARCH_TMS320C64X
    CS_ARCH_M680X
    CS_ARCH_EVM
    CS_ARCH_WASM
    CS_ARCH_BPF
    CS_ARCH_RISCV
    CS_ARCH_SH
    CS_ARCH_TRICORE
    CS_ARCH_MAX
    { CS_ARCH_ALL 0xFFFF }
;

ENUM: cs_mode
    { CS_MODE_LITTLE_ENDIAN 0 }
    { CS_MODE_ARM 0 }
    { CS_MODE_16 0x2 }
    { CS_MODE_32 0x4 }
    { CS_MODE_64 0x8 }
    { CS_MODE_THUMB 0x10 }
    { CS_MODE_MCLASS 0x20 }
    { CS_MODE_V8 0x40 }
    { CS_MODE_MICRO 0x20 }
    { CS_MODE_MIPS3 0x40 }
    { CS_MODE_MIPS32R6 0x80 }
    { CS_MODE_MIPS2 0x100 }
    { CS_MODE_V9 0x10 }
    { CS_MODE_QPX 0x10 }
    { CS_MODE_M68K_000 0x02 }
    { CS_MODE_M68K_010 0x04 }
    { CS_MODE_M68K_020 0x08 }
    { CS_MODE_M68K_030 0x10 }
    { CS_MODE_M68K_040 0x20 }
    { CS_MODE_M68K_060 0x40 }
    { CS_MODE_BIG_ENDIAN 0x80000000 }
    { CS_MODE_MIPS32 0x4 }
    { CS_MODE_MIPS64 0x8 }
    { CS_MODE_M680X_6301 0x02 }
    { CS_MODE_M680X_6309 0x04 }
    { CS_MODE_M680X_6800 0x08 }
    { CS_MODE_M680X_6801 0x10 }
    { CS_MODE_M680X_6805 0x20 }
    { CS_MODE_M680X_6808 0x40 }
    { CS_MODE_M680X_6809 0x80 }
    { CS_MODE_M680X_6811 0x100 }
    { CS_MODE_M680X_CPU12 0x200 }
    { CS_MODE_M680X_HCS08 0x400 }
    { CS_MODE_BPF_CLASSIC 0 }
    { CS_MODE_BPF_EXTENDED 1 }
    { CS_MODE_RISCV32 1 }
    { CS_MODE_RISCV64 2 }
    { CS_MODE_RISCVC 4 }
    { CS_MODE_MOS65XX_6502 2 }
    { CS_MODE_MOS65XX_65C02 4 }
    { CS_MODE_MOS65XX_W65C02 8 }
    { CS_MODE_MOS65XX_65816 16 }
    { CS_MODE_MOS65XX_65816_LONG_M 32 }
    { CS_MODE_MOS65XX_65816_LONG_X 64 }
    { CS_MODE_MOS65XX_65816_LONG_MX 96 }
    { CS_MODE_SH2 2 }
    { CS_MODE_SH2A 4 }
    { CS_MODE_SH3 8 }
    { CS_MODE_SH4 16 }
    { CS_MODE_SH4A 32 }
    { CS_MODE_SHFPU 64 }
    { CS_MODE_SHDSP 128 }
    { CS_MODE_TRICORE_110 2 }
    { CS_MODE_TRICORE_120 4 }
    { CS_MODE_TRICORE_130 8 }
    { CS_MODE_TRICORE_131 16 }
    { CS_MODE_TRICORE_160 32 }
    { CS_MODE_TRICORE_161 64 }
    { CS_MODE_TRICORE_162 128 }
;

TYPEDEF: void cs_detail

STRUCT: cs_insn_4
    { id uint }
    { address uint64_t }
    { size uint16_t }
    { bytes uint8_t[16] }
    { mnemonic char[32] }
    { op_str char[160] }
    { detail cs_detail* }
;

STRUCT: cs_insn_5
    { id uint }
    { address uint64_t }
    { size uint16_t }
    { bytes uint8_t[24] }
    { mnemonic char[32] }
    { op_str char[160] }
    { detail cs_detail* }
;

TYPEDEF: void cs_insn

ENUM: cs_err
    CS_ERR_OK
    CS_ERR_MEM
    CS_ERR_ARCH
    CS_ERR_HANDLE
    CS_ERR_CSH
    CS_ERR_MODE
    CS_ERR_OPTION
    CS_ERR_DETAIL
    CS_ERR_MEMSETUP
    CS_ERR_VERSION
    CS_ERR_DIET
    CS_ERR_SKIPDATA
    CS_ERR_X86_ATT
    CS_ERR_X86_INTEL
    CS_ERR_X86_MASM
;

FUNCTION: uint cs_version ( int* major, int* minor )
FUNCTION: bool cs_support ( int query )
FUNCTION: cs_err cs_open ( cs_arch arch, cs_mode mode, csh* handle )
FUNCTION: cs_err cs_close ( csh* handle )
FUNCTION: cs_err cs_errno ( csh handle )
FUNCTION: c-string cs_strerror ( cs_err code )
FUNCTION: size_t cs_disasm ( csh handle, uint8_t* code, size_t code_size, uint64_t address, size_t count, cs_insn** insn )
FUNCTION: size_t cs_disasm_iter ( csh handle, uint8_t** code, size_t* size, uint64_t* address, size_t count, cs_insn* insn )
FUNCTION: void* cs_malloc ( csh handle )
FUNCTION: void cs_free ( cs_insn* insn, size_t count )
FUNCTION: c-string cs_reg_name ( csh handle, uint reg_id )
FUNCTION: c-string cs_insn_name ( csh handle, uint insn_id )
FUNCTION: c-string cs_group_name ( csh handle, uint group_id )

DESTRUCTOR: cs_close

: cs-version ( -- major minor )
    { int int } [ cs_version drop ] with-out-parameters ;

: <csh> ( -- csh )
    \ cpu get {
        { x86.32 [ CS_ARCH_X86 CS_MODE_32 ] }
        { x86.64 [ CS_ARCH_X86 CS_MODE_64 ] }
        { arm.32 [ CS_ARCH_ARM CS_MODE_ARM ] }
        { arm.64 [ CS_ARCH_ARM64 CS_MODE_ARM ] }
    } case 0 csh <ref> [ cs_open CS_ERR_OK assert= ] keep ;

: with-csh ( ..a quot: ( ..a csh -- ..b ) -- ..b )
    '[ <csh> &cs_close @ ] with-destructors ; inline

<PRIVATE

SPECIALIZED-ARRAY: cs_insn_4
SPECIALIZED-ARRAY: cs_insn_5

: <direct-cs_insn-array> ( alien len -- specialized-array )
    cs-version drop {
        { 4 [ <direct-cs_insn_4-array> ] }
        { 5 [ <direct-cs_insn_5-array> ] }
    } case ;

: buf/len/start ( from to -- buf len from )
    [ drop <alien> ] [ swap - ] [ drop ] 2tri ;

: make-insn ( cs_insn -- seq )
    {
        [ address>> ]
        [ [ bytes>> ] [ size>> ] bi head-slice bytes>hex-string ]
        [ mnemonic>> alien>native-string ]
        [ op_str>> alien>native-string " " glue ]
    } cleave 3array ;

: make-disassembly ( from len address -- lines )
    '[
        csh deref _ _ _ 0
        { void* } [ cs_disasm ] with-out-parameters swap
        [ <direct-cs_insn-array> [ make-insn ] { } map-as ]
        [ cs_free ] 2bi
    ] with-csh ;

PRIVATE>

SINGLETON: capstone-disassembler

M: capstone-disassembler disassemble*
    [ buf/len/start make-disassembly write-disassembly ] with-code-blocks ;

capstone-disassembler disassembler-backend set-global
