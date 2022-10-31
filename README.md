# Dynamic-pipelined-CPU

## Introduction
  54-instruction dynamic pipeline CPU for mips architecture.

## Our work
- Used Verilog HDL to implement RAM, ALU, multiplier, divider, and other modules
- Designed the control module connecting the CPU components and data streams to facilitate 
  the increase and decrease of instructions
- Tested the CPU on ModelSim, and then implemented the CPU on the Digilent Nexys4 FPGA board
- For more information, refer to [Project report](./resources/Report.pdf).

## Dependencies
- Vivado 2016.2
- Digilent Nexys 4 DDR FPGA board
- [Mars 4.5](http://www.cs.missouristate.edu/MARS/): Mips Assembly and Runtime Simulator

## Test program
We verify cpu correctness and efficiency on a benchmark program
1) Algorithm model
- As shown in the figure, the calculation of all the following values is completed by using 
  the loop and stored in the memory. Register #16 shows the data change process of D\[i\]. 
  When the final operation is finished, the in-call interrupt break is transferred to the 
  interrupt processing subroutine, and the final value displayed is the value of D\[59\].
- <img src=".\resources\1.png" width="200"/>
3) Algorithm 54 instructions MIPS program
- The data segment reserves 240 bytes for each of the A, B, C, and D parts in the memory to 
  store intermediate variables in the operation. At the end of the final operation, the 
  in-call interrupt break is transferred to the interrupt handling subroutine, and the final
  value displayed is the value of D\[59\].
```
.data
A:.space 240
B:.space 240
C:.space 240
D:.space 240
.text
sll $0,$0,0
exc:	#exception
beq $30,$0,main
j exc
 
main:
lui $30,0xffff    #enable exception
addi $2,$0,0    #a[i]
addi $3,$0,1    #b[i]
addi $15,$0,0    #c[i]
addi $16,$0,0   #d[i]
addi $5,$0,4    #counter
addi $6,$0,0    #a[i-1]
addi $7,$0,1    #b[i-1]
addi $10,$0,0   #flag for i<20 || i<40
addi $11,$0,240 #sum counts
addi $14,$0,3
#addi $30,$0,0
 
# save 0 1 0 0 ($2,...,$16) into A B C D
lui $27,0x0000
addu $27,$27,$0
sw $2,A($27)
lui $27,0x0000
addu $27,$27,$0
sw $3,B($27)
lui $27,0x0000
addu $27,$27,$0
sw $2,C($27)
lui $27,0x0000
addu $27,$27,$0
sw $3,D($27)
 
# 循环
loop:
## $5(4) / 4 (=i) into $12
srl $12,$5,2
# $6 plus i. From now, $6 is a[i] instead of a[i-1]
add $6,$6,$12
# save a[i] into A[i] 
lui $27,0x0000
addu $27,$27,$5
sw $6,A($27)
# $14 (3) * $5/4 (i) ( = 3i )
mul $15,$14,$12
# $7 (b[i-1]) add 3i, and save into B[i]. From now, $7 is b[i] instead of b[i-1]
add $7,$7,$15
lui $27,0x0000
addu $27,$27,$5
sw $7,B($27)
# $5 < 80 (i < 20) ? save into $10
slti $10,$5,80
bne $10,1,c1
 
# (0<=i<=19)
# save $6 into C[i] (c[i] = a[i])
lui $27,0x0000
addu $27,$27,$5
sw $6,C($27)
# save $7 into D[i] (d[i] = b[i])
lui $27,0x0000
addu $27,$27,$5
sw $7,D($27)
addi $15,$6,0 # $15 $16 = c[i] d[i]
addi $16,$7,0
j endc
c1: # (20<=i<=39)
# i < 40 ？ jump c2 if not
slti $10,$5,160
addi $27,$0,1
bne $10,$27,c2
# C[i] = a[i] + b[i]
add $15,$6,$7
lui $27,0x0000
addu $27,$27,$5
sw $15,C($27)
# D[i] = a[i] * b[i]
mul $16, $15,$6
lui $27,0x0000
addu $27,$27,$5
sw $16,D($27)
j endc
c2: # (i>=40)
# C[i] = a[i] * b[i]
mul $15,$6,$7
lui $27,0x0000
addu $27,$27,$5
sw $15,C($27)
# D[i] = c[i] * b[i]
mul $16,$15,$7
lui $27,0x0000
addu $27,$27,$5
sw $16,D($27)
 
endc:
addi $5,$5,4 # i = i + 1
bne $5,$11,loop # i = 60 no jump
break
# Finally, the correctness can be verified by verifying the correctness of $16
```

## How to use
1) Include all the files in [code](./code) directory.
2) Use Vivado to synthesis, implementation, generate bitstream and program to board, 
   remember to load the [test program](./code/test.coe) file.
- <img src=".\resources\2.png" width="600"/>

3) Press button N17 to reset, and release to get the results of the program
- The final result is 9FD0B7EA, and the result is correct:
- <img src=".\resources\3.jpg" width="400"/>

4) Using the leftmost switch (V10), the final PC value is displayed and the result is correct:
- <img src=".\resources\4.jpg" width="400"/>

5) During execution, using the right-most switch (J15), the external interrupt pauses the 
  CPU to display the current D\[i\] value:
- <img src=".\resources\5.jpg" width="400"/>

6) Using the leftmost switch (V10), current PC value: (PC=004000A8, EX segment is calculating
  mul instruction, taking 32 cycles, easy to be executed just at this position during pause)
- <img src=".\resources\6.jpg" width="400"/>

7) We provide Mips cource code [here](./code/test.asm), you can alter it and generate 
   binary file(COE) of your own program with [Mars 4.5](http://www.cs.missouristate.edu/MARS/).



