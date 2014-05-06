0000000530733c80: 89057ad3e7fe          mov [rip-0x1182c86], eax
0000000530733c86: 4883ec38              sub rsp, 0x38

# bb 1
0000000530733c8a: 4983c610              add r14, 0x10
0000000530733c8e: 49c746f840060000      mov qword [r14-0x8], 0x640
0000000530733c96: 49c70610020000        mov qword [r14], 0x210

# bb 2
0000000530733c9d: e8fe5e09ff            call 0x52f7c9ba0 (<array>)

# bb 3
0000000530733ca2: 4983c610              add r14, 0x10
0000000530733ca6: 498b4ef0              mov rcx, [r14-0x10]
0000000530733caa: 498b5ee8              mov rbx, [r14-0x18]
0000000530733cae: 4831c0                xor rax, rax
0000000530733cb1: 49895ef0              mov [r14-0x10], rbx
0000000530733cb5: 49894ee8              mov [r14-0x18], rcx
0000000530733cb9: 49894ef8              mov [r14-0x8], rcx

# bb 4
0000000530733cbd: e98f000000            jmp 0x530733d51 (run-test + 0xd1)

0000000530733cc2: 48b80100000000000000  mov rax, 0x1
0000000530733ccc: 4885c9                test rcx, rcx
0000000530733ccf: 0f842e000000          jz dword 0x530733d03 (run-test + 0x83)
0000000530733cd5: 498d5d10              lea rbx, [r13+0x10]
0000000530733cd9: 488b03                mov rax, [rbx]
0000000530733cdc: 48c70018000000        mov qword [rax], 0x18
0000000530733ce3: 4883c806              or rax, 0x6
0000000530733ce7: 48830330              add qword [rbx], 0x30
0000000530733ceb: 48c7400201000000      mov qword [rax+0x2], 0x1
0000000530733cf3: 48c7400a01000000      mov qword [rax+0xa], 0x1
0000000530733cfb: 48894812              mov [rax+0x12], rcx
0000000530733cff: 4889481a              mov [rax+0x1a], rcx
0000000530733d03: 48894c2430            mov [rsp+0x30], rcx
0000000530733d08: 498b4e10              mov rcx, [r14+0x10]
0000000530733d0c: 498b5e08              mov rbx, [r14+0x8]
0000000530733d10: 48c1fb04              sar rbx, 0x4
0000000530733d14: 488944d90e            mov [rcx+rbx*8+0xe], rax
0000000530733d19: 488d44d90e            lea rax, [rcx+rbx*8+0xe]
0000000530733d1e: 48c1e808              shr rax, 0x8
0000000530733d22: 49bcb069131d05000000  mov r12, 0x51d1369b0
0000000530733d2c: 4ac60420c0            mov byte [rax+r12], 0xc0
0000000530733d31: 48c1e80a              shr rax, 0xa
0000000530733d35: 49bca250342205000000  mov r12, 0x5223450a2
0000000530733d3f: 4ac60420c0            mov byte [rax+r12], 0xc0
0000000530733d44: 498b06                mov rax, [r14]
0000000530733d47: 4883c010              add rax, 0x10
0000000530733d4b: 8905afd2e7fe          mov [rip-0x1182d51], eax

# bb 5
0000000530733d51: 4881f840060000        cmp rax, 0x640
0000000530733d58: 0f8de0000000          jge dword 0x530733e3e (run-test + 0x1be)

# bb 6
0000000530733d5e: 4983c708              add r15, 0x8
0000000530733d62: 4983c618              add r14, 0x18
0000000530733d66: 498b4ed8              mov rcx, [r14-0x28]
0000000530733d6a: 49890e                mov [r14], rcx
0000000530733d6d: 498946e8              mov [r14-0x18], rax
0000000530733d71: 498907                mov [r15], rax
0000000530733d74: 498b4ee0              mov rcx, [r14-0x20]
0000000530733d78: 49894ef8              mov [r14-0x8], rcx
0000000530733d7c: 498946f0              mov [r14-0x10], rax

# bb 7
0000000530733d80: e88bfe7cff            call 0x52ff03c10 (>c-ptr)

# bb 8
0000000530733d85: 4983ef08              sub r15, 0x8
0000000530733d89: 4983ee18              sub r14, 0x18
0000000530733d8d: 498b4d00              mov rcx, [r13+0x0]
0000000530733d91: 488d5c24f8            lea rbx, [rsp-0x8]
0000000530733d96: 488919                mov [rcx], rbx
0000000530733d99: 4c897110              mov [rcx+0x10], r14
0000000530733d9d: 4c897918              mov [rcx+0x18], r15
0000000530733da1: 498b4e18              mov rcx, [r14+0x18]
0000000530733da5: 4831db                xor rbx, rbx
0000000530733da8: 4883f901              cmp rcx, 0x1
0000000530733dac: 0f8419000000          jz dword 0x530733dcb (run-test + 0x14b)
0000000530733db2: 4889cb                mov rbx, rcx
0000000530733db5: 4883e30f              and rbx, 0xf
0000000530733db9: 4883fb06              cmp rbx, 0x6
0000000530733dbd: 488d5907              lea rbx, [rcx+0x7]
0000000530733dc1: 0f8504000000          jnz dword 0x530733dcb (run-test + 0x14b)
0000000530733dc7: 488b591a              mov rbx, [rcx+0x1a]
0000000530733dcb: 48895c2420            mov [rsp+0x20], rbx
0000000530733dd0: 498b4708              mov rax, [r15+0x8]
0000000530733dd4: 48c1f804              sar rax, 0x4
0000000530733dd8: 4889442428            mov [rsp+0x28], rax
0000000530733ddd: 488b4c2420            mov rcx, [rsp+0x20]
0000000530733de2: 488b542428            mov rdx, [rsp+0x28]
0000000530733de7: 4831c0                xor rax, rax
0000000530733dea: 49bb0010d488f8070000  mov r11, 0x7f888d41000
0000000530733df4: 49ffd3                call r11
0000000530733df7: 4889442430            mov [rsp+0x30], rax
0000000530733dfc: 498d5d10              lea rbx, [r13+0x10]
0000000530733e00: 488b0b                mov rcx, [rbx]
0000000530733e03: 4883c130              add rcx, 0x30
0000000530733e07: 483b4b10              cmp rcx, [rbx+0x10]
0000000530733e0b: 0f8f0a000000          jg dword 0x530733e1b (run-test + 0x19b)

# bb 9
0000000530733e11: 488b4c2430            mov rcx, [rsp+0x30]
0000000530733e16: e9a7feffff            jmp 0x530733cc2 (run-test + 0x42)

# bb 10
0000000530733e1b: 498b5d00              mov rbx, [r13+0x0]
0000000530733e1f: 488d4c24f8            lea rcx, [rsp-0x8]
0000000530733e24: 48890b                mov [rbx], rcx
0000000530733e27: 4c897310              mov [rbx+0x10], r14
0000000530733e2b: 4c897b18              mov [rbx+0x18], r15
0000000530733e2f: e84c213eff            call 0x52fb15f80 (minor-gc)
0000000530733e34: 488b4c2430            mov rcx, [rsp+0x30]
0000000530733e39: e984feffff            jmp 0x530733cc2 (run-test + 0x42)
0000000530733e3e: 4983ee18              sub r14, 0x18
0000000530733e42: 8905b8d1e7fe          mov [rip-0x1182e48], eax
0000000530733e48: 4883c438              add rsp, 0x38
0000000530733e4c: c3                    ret
0000000530733e4d: 0000                  add [rax], al
0000000530733e4f: 0000                  add [rax], al
0000000530733e51: 0000                  add [rax], al
0000000530733e53: 0000                  add [rax], al
0000000530733e55: 0000                  add [rax], al
0000000530733e57: 0000                  add [rax], al
0000000530733e59: 0000                  add [rax], al
0000000530733e5b: 0000                  add [rax], al
0000000530733e5d: 0000                  add [rax], al
0000000530733e5f: 00                    invalid
