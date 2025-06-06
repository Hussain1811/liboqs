/*
 * Copyright (c) The mlkem-native project authors
 * SPDX-License-Identifier: Apache-2.0 OR ISC OR MIT
 */

/* References
 * ==========
 *
 * - [REF_AVX2]
 *   CRYSTALS-Kyber optimized AVX2 implementation
 *   Bos, Ducas, Kiltz, Lepoint, Lyubashevsky, Schanck, Schwabe, Seiler, Stehlé
 *   https://github.com/pq-crystals/kyber/tree/main/avx2
 */

/*
 * This file is derived from the public domain
 * AVX2 Kyber implementation @[REF_AVX2].
 */

#include "../../../common.h"

#if defined(MLK_ARITH_BACKEND_X86_64_DEFAULT) && \
    !defined(MLK_CONFIG_MULTILEVEL_NO_SHARED)

/*
 * WARNING: This file is auto-derived from the mlkem-native source file
 *   dev/x86_64/src/ntttobytes.S using scripts/simpasm. Do not modify it directly.
 */


.text
.balign 4
.global MLK_ASM_NAMESPACE(ntttobytes_avx2)
MLK_ASM_FN_SYMBOL(ntttobytes_avx2)

        vmovdqa	(%rdx), %ymm0
        callq	ntttobytes_avx2_core
        addq	$0x100, %rsi            # imm = 0x100
        addq	$0xc0, %rdi
        callq	ntttobytes_avx2_core
        retq

ntttobytes_avx2_core:
        vmovdqa	(%rsi), %ymm5
        vmovdqa	0x20(%rsi), %ymm6
        vmovdqa	0x40(%rsi), %ymm7
        vmovdqa	0x60(%rsi), %ymm8
        vmovdqa	0x80(%rsi), %ymm9
        vmovdqa	0xa0(%rsi), %ymm10
        vmovdqa	0xc0(%rsi), %ymm11
        vmovdqa	0xe0(%rsi), %ymm12
        vpsllw	$0xc, %ymm6, %ymm4
        vpor	%ymm4, %ymm5, %ymm4
        vpsrlw	$0x4, %ymm6, %ymm5
        vpsllw	$0x8, %ymm7, %ymm6
        vpor	%ymm5, %ymm6, %ymm5
        vpsrlw	$0x8, %ymm7, %ymm6
        vpsllw	$0x4, %ymm8, %ymm7
        vpor	%ymm6, %ymm7, %ymm6
        vpsllw	$0xc, %ymm10, %ymm7
        vpor	%ymm7, %ymm9, %ymm7
        vpsrlw	$0x4, %ymm10, %ymm8
        vpsllw	$0x8, %ymm11, %ymm9
        vpor	%ymm8, %ymm9, %ymm8
        vpsrlw	$0x8, %ymm11, %ymm9
        vpsllw	$0x4, %ymm12, %ymm10
        vpor	%ymm9, %ymm10, %ymm9
        vpslld	$0x10, %ymm5, %ymm3
        vpblendw	$0xaa, %ymm3, %ymm4, %ymm3 # ymm3 = ymm4[0],ymm3[1],ymm4[2],ymm3[3],ymm4[4],ymm3[5],ymm4[6],ymm3[7],ymm4[8],ymm3[9],ymm4[10],ymm3[11],ymm4[12],ymm3[13],ymm4[14],ymm3[15]
        vpsrld	$0x10, %ymm4, %ymm4
        vpblendw	$0xaa, %ymm5, %ymm4, %ymm5 # ymm5 = ymm4[0],ymm5[1],ymm4[2],ymm5[3],ymm4[4],ymm5[5],ymm4[6],ymm5[7],ymm4[8],ymm5[9],ymm4[10],ymm5[11],ymm4[12],ymm5[13],ymm4[14],ymm5[15]
        vpslld	$0x10, %ymm7, %ymm4
        vpblendw	$0xaa, %ymm4, %ymm6, %ymm4 # ymm4 = ymm6[0],ymm4[1],ymm6[2],ymm4[3],ymm6[4],ymm4[5],ymm6[6],ymm4[7],ymm6[8],ymm4[9],ymm6[10],ymm4[11],ymm6[12],ymm4[13],ymm6[14],ymm4[15]
        vpsrld	$0x10, %ymm6, %ymm6
        vpblendw	$0xaa, %ymm7, %ymm6, %ymm7 # ymm7 = ymm6[0],ymm7[1],ymm6[2],ymm7[3],ymm6[4],ymm7[5],ymm6[6],ymm7[7],ymm6[8],ymm7[9],ymm6[10],ymm7[11],ymm6[12],ymm7[13],ymm6[14],ymm7[15]
        vpslld	$0x10, %ymm9, %ymm6
        vpblendw	$0xaa, %ymm6, %ymm8, %ymm6 # ymm6 = ymm8[0],ymm6[1],ymm8[2],ymm6[3],ymm8[4],ymm6[5],ymm8[6],ymm6[7],ymm8[8],ymm6[9],ymm8[10],ymm6[11],ymm8[12],ymm6[13],ymm8[14],ymm6[15]
        vpsrld	$0x10, %ymm8, %ymm8
        vpblendw	$0xaa, %ymm9, %ymm8, %ymm9 # ymm9 = ymm8[0],ymm9[1],ymm8[2],ymm9[3],ymm8[4],ymm9[5],ymm8[6],ymm9[7],ymm8[8],ymm9[9],ymm8[10],ymm9[11],ymm8[12],ymm9[13],ymm8[14],ymm9[15]
        vmovsldup	%ymm4, %ymm8    # ymm8 = ymm4[0,0,2,2,4,4,6,6]
        vpblendd	$0xaa, %ymm8, %ymm3, %ymm8 # ymm8 = ymm3[0],ymm8[1],ymm3[2],ymm8[3],ymm3[4],ymm8[5],ymm3[6],ymm8[7]
        vpsrlq	$0x20, %ymm3, %ymm3
        vpblendd	$0xaa, %ymm4, %ymm3, %ymm4 # ymm4 = ymm3[0],ymm4[1],ymm3[2],ymm4[3],ymm3[4],ymm4[5],ymm3[6],ymm4[7]
        vmovsldup	%ymm5, %ymm3    # ymm3 = ymm5[0,0,2,2,4,4,6,6]
        vpblendd	$0xaa, %ymm3, %ymm6, %ymm3 # ymm3 = ymm6[0],ymm3[1],ymm6[2],ymm3[3],ymm6[4],ymm3[5],ymm6[6],ymm3[7]
        vpsrlq	$0x20, %ymm6, %ymm6
        vpblendd	$0xaa, %ymm5, %ymm6, %ymm5 # ymm5 = ymm6[0],ymm5[1],ymm6[2],ymm5[3],ymm6[4],ymm5[5],ymm6[6],ymm5[7]
        vmovsldup	%ymm9, %ymm6    # ymm6 = ymm9[0,0,2,2,4,4,6,6]
        vpblendd	$0xaa, %ymm6, %ymm7, %ymm6 # ymm6 = ymm7[0],ymm6[1],ymm7[2],ymm6[3],ymm7[4],ymm6[5],ymm7[6],ymm6[7]
        vpsrlq	$0x20, %ymm7, %ymm7
        vpblendd	$0xaa, %ymm9, %ymm7, %ymm9 # ymm9 = ymm7[0],ymm9[1],ymm7[2],ymm9[3],ymm7[4],ymm9[5],ymm7[6],ymm9[7]
        vpunpcklqdq	%ymm3, %ymm8, %ymm7 # ymm7 = ymm8[0],ymm3[0],ymm8[2],ymm3[2]
        vpunpckhqdq	%ymm3, %ymm8, %ymm3 # ymm3 = ymm8[1],ymm3[1],ymm8[3],ymm3[3]
        vpunpcklqdq	%ymm4, %ymm6, %ymm8 # ymm8 = ymm6[0],ymm4[0],ymm6[2],ymm4[2]
        vpunpckhqdq	%ymm4, %ymm6, %ymm4 # ymm4 = ymm6[1],ymm4[1],ymm6[3],ymm4[3]
        vpunpcklqdq	%ymm9, %ymm5, %ymm6 # ymm6 = ymm5[0],ymm9[0],ymm5[2],ymm9[2]
        vpunpckhqdq	%ymm9, %ymm5, %ymm9 # ymm9 = ymm5[1],ymm9[1],ymm5[3],ymm9[3]
        vperm2i128	$0x20, %ymm8, %ymm7, %ymm5 # ymm5 = ymm7[0,1],ymm8[0,1]
        vperm2i128	$0x31, %ymm8, %ymm7, %ymm8 # ymm8 = ymm7[2,3],ymm8[2,3]
        vperm2i128	$0x20, %ymm3, %ymm6, %ymm7 # ymm7 = ymm6[0,1],ymm3[0,1]
        vperm2i128	$0x31, %ymm3, %ymm6, %ymm3 # ymm3 = ymm6[2,3],ymm3[2,3]
        vperm2i128	$0x20, %ymm9, %ymm4, %ymm6 # ymm6 = ymm4[0,1],ymm9[0,1]
        vperm2i128	$0x31, %ymm9, %ymm4, %ymm9 # ymm9 = ymm4[2,3],ymm9[2,3]
        vmovdqu	%ymm5, (%rdi)
        vmovdqu	%ymm7, 0x20(%rdi)
        vmovdqu	%ymm6, 0x40(%rdi)
        vmovdqu	%ymm8, 0x60(%rdi)
        vmovdqu	%ymm3, 0x80(%rdi)
        vmovdqu	%ymm9, 0xa0(%rdi)
        retq

#endif /* MLK_ARITH_BACKEND_X86_64_DEFAULT && !MLK_CONFIG_MULTILEVEL_NO_SHARED \
        */
