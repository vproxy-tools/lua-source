==========================
Lua 5.3 Bytecode Reference
==========================

This is my attempt to bring up to date the Lua bytecode reference. Note that this is work in progress.
Following copyrights are acknowledged:

:: 

  A No-Frills Introduction to Lua 5.1 VM Instructions
    by Kein-Hong Man, esq. <khman AT users.sf.net>
    Version 0.1, 2006-03-13

`A No-Frills Introduction to Lua 5.1 VM Instructions <http://luaforge.net/docman/83/98/ANoFrillsIntroToLua51VMInstructions.pdf>`_ is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike License 2.0. You are free to copy, distribute and display the work, and make derivative works as long as you give the original author credit, you do not use this work for commercial purposes, and if you alter, transform, or build upon this work, you distribute the resulting work only under a license identical to this one. See the following URLs for more information::

    http://creativecommons.org/licenses/by-nc-sa/2.0/
    http://creativecommons.org/licenses/by-nc-sa/2.0/legalcode


Lua Stack and Registers
=======================
Lua employs two stacks.
The ``Callinfo`` stack tracks activation frames. 
There is the secondary stack ``L->stack`` that is an array of ``TValue`` objects. 
The ``Callinfo`` objects index into this array. Registers are basically slots in 
the ``L->stack`` array.

When a function is called - the stack is setup as follows::

  stack
  |            function reference
  |            var arg 1
  |            ... 
  |            var arg n
  | base->     fixed arg 1
  |            ...
  |            fixed arg n
  |            local 1
  |            ...
  |            local n
  |            temporaries 
  |            ...
  |  top->     
  |  
  V

So ``top`` is just past the registers needed by the function. 
The number of registers is determined based on parameters, locals and temporaries.

For each Lua function, the ``base`` of the stack is set to the first fixed parameter or local.
All register addressing is done as offset from ``base`` - so ``R(0)`` is at ``base+0`` on the stack. 

.. figure:: Drawing_Lua_Stack.jpg
   :alt: Drawing of Lua Stack

   The figure above shows how the stack is related to other Lua objects.

When the function returns the return values are copied to location starting at the function reference.

Instruction Notation
====================

R(A)
  Register A (specified in instruction field A)
R(B)
  Register B (specified in instruction field B)
R(C)
  Register C (specified in instruction field C)
PC
  Program Counter
Kst(n)
  Element n in the constant list
Upvalue[n]
  Name of upvalue with index n
Gbl[sym]
  Global variable indexed by symbol sym
RK(B)
  Register B or a constant index
RK(C)
  Register C or a constant index
sBx
  Signed displacement (in field sBx) for all kinds of jumps

Instruction Summary
===================

Lua bytecode instructions are 32-bits in size. 
All instructions have an opcode in the first 6 bits.
Instructions can have the following fields::

  'A' : 8 bits
  'B' : 9 bits
  'C' : 9 bits
  'Ax' : 26 bits ('A', 'B', and 'C' together)
  'Bx' : 18 bits ('B' and 'C' together)
  'sBx' : signed Bx

A signed argument is represented in excess K; that is, the number
value is the unsigned value minus K. K is exactly the maximum value
for that argument (so that -max is represented by 0, and +max is
represented by 2*max), which is half the maximum for the corresponding  
unsigned argument.

Note that B and C operands need to have an extra bit compared to A.
This is because B and C can reference registers or constants, and the
extra bit is used to decide which one. But A always references registers
so it doesn't need the extra bit.

+------------+-------------------------------------------------------------+
| Opcode     | Description                                                 |
+============+=============================================================+
| MOVE       | Copy a value between registers                              |
+------------+-------------------------------------------------------------+
| LOADK      | Load a constant into a register                             |
+------------+-------------------------------------------------------------+
| LOADKX     | Load a constant into a register                             |
+------------+-------------------------------------------------------------+
| LOADBOOL   | Load a boolean into a register                              |
+------------+-------------------------------------------------------------+
| LOADNIL    | Load nil values into a range of registers                   |
+------------+-------------------------------------------------------------+
| GETUPVAL   | Read an upvalue into a register                             |
+------------+-------------------------------------------------------------+
| GETTABUP   | Read a value from table in up-value into a register         |
+------------+-------------------------------------------------------------+
| GETTABLE   | Read a table element into a register                        |
+------------+-------------------------------------------------------------+
| SETTABUP   | Write a register value into table in up-value               |
+------------+-------------------------------------------------------------+
| SETUPVAL   | Write a register value into an upvalue                      |
+------------+-------------------------------------------------------------+
| SETTABLE   | Write a register value into a table element                 |
+------------+-------------------------------------------------------------+
| NEWTABLE   | Create a new table                                          |
+------------+-------------------------------------------------------------+
| SELF       | Prepare an object method for calling                        |
+------------+-------------------------------------------------------------+
| ADD        | Addition operator                                           |
+------------+-------------------------------------------------------------+
| SUB        | Subtraction operator                                        |
+------------+-------------------------------------------------------------+
| MUL        | Multiplication operator                                     |
+------------+-------------------------------------------------------------+
| MOD        | Modulus (remainder) operator                                |
+------------+-------------------------------------------------------------+
| POW        | Exponentation operator                                      |
+------------+-------------------------------------------------------------+
| DIV        | Division operator                                           |
+------------+-------------------------------------------------------------+
| IDIV       | Integer division operator                                   |
+------------+-------------------------------------------------------------+
| BAND       | Bit-wise AND operator                                       |
+------------+-------------------------------------------------------------+
| BOR        | Bit-wise OR operator                                        |
+------------+-------------------------------------------------------------+
| BXOR       | Bit-wise Exclusive OR operator                              |
+------------+-------------------------------------------------------------+
| SHL        | Shift bits left                                             |
+------------+-------------------------------------------------------------+
| SHR        | Shift bits right                                            |
+------------+-------------------------------------------------------------+
| UNM        | Unary minus                                                 |
+------------+-------------------------------------------------------------+
| BNOT       | Bit-wise NOT operator                                       |
+------------+-------------------------------------------------------------+
| NOT        | Logical NOT operator                                        |
+------------+-------------------------------------------------------------+
| LEN        | Length operator                                             |
+------------+-------------------------------------------------------------+
| CONCAT     | Concatenate a range of registers                            |
+------------+-------------------------------------------------------------+
| JMP        | Unconditional jump                                          |
+------------+-------------------------------------------------------------+
| EQ         | Equality test, with conditional jump                        |
+------------+-------------------------------------------------------------+
| LT         | Less than test, with conditional jump                       |
+------------+-------------------------------------------------------------+
| LE         | Less than or equal to test, with conditional jump           |
+------------+-------------------------------------------------------------+
| TEST       | Boolean test, with conditional jump                         |
+------------+-------------------------------------------------------------+
| TESTSET    | Boolean test, with conditional jump and assignment          |
+------------+-------------------------------------------------------------+
| CALL       | Call a closure                                              |
+------------+-------------------------------------------------------------+
| TAILCALL   | Perform a tail call                                         |
+------------+-------------------------------------------------------------+
| RETURN     | Return from function call                                   |
+------------+-------------------------------------------------------------+
| FORLOOP    | Iterate a numeric for loop                                  |
+------------+-------------------------------------------------------------+
| FORPREP    | Initialization for a numeric for loop                       |
+------------+-------------------------------------------------------------+
| TFORLOOP   | Iterate a generic for loop                                  |
+------------+-------------------------------------------------------------+
| TFORCALL   | Initialization for a generic for loop                       |
+------------+-------------------------------------------------------------+
| SETLIST    | Set a range of array elements for a table                   |
+------------+-------------------------------------------------------------+
| CLOSURE    | Create a closure of a function prototype                    |
+------------+-------------------------------------------------------------+
| VARARG     | Assign vararg function arguments to registers               |
+------------+-------------------------------------------------------------+


OP_CALL instruction
===================

Syntax
------

::

  CALL A B C    R(A), ... ,R(A+C-2) := R(A)(R(A+1), ... ,R(A+B-1))

Description
-----------

Performs a function call, with register R(A) holding the reference to the function object to be called. 
Parameters to the function are placed in the registers following R(A). If B is 1, the function has no 
parameters. If B is 2 or more, there are (B-1) parameters. If B >= 2, then upon entry to the called 
function, R(A+1) will become the ``base``. 

If B is 0, then B = 'top', i.e., the function parameters range from R(A+1) to the top of the stack. 
This form is used when the number of parameters to pass is set by the previous VM instruction, 
which has to be one of ``OP_CALL`` or ``OP_VARARG``. 

If C is 1, no return results are saved. If C is 2 or more, (C-1) return values are saved. 
If C == 0, then 'top' is set to last_result+1, so that the next open instruction 
(``OP_CALL``, ``OP_RETURN``, ``OP_SETLIST``) can use 'top'.

Examples
--------

Example of ``OP_VARARG`` followed by ``OP_CALL``::

  function y(...) print(...) end

  1 [1] GETTABUP  0 0 -1  ; _ENV "print"
  2 [1] VARARG    1 0     ; VARARG will set L->top
  3 [1] CALL      0 0 1   ; B=0 so L->top set by previous instruction
  4 [1] RETURN    0 1

Example of ``OP_CALL`` followed by ``OP_CALL``::

  function z1() y(x()) end

  1 [1] GETTABUP  0 0 -1  ; _ENV "y"
  2 [1] GETTABUP  1 0 -2  ; _ENV "x"
  3 [1] CALL      1 1 0   ; C=0 so return values indicated by L->top
  4 [1] CALL      0 0 1   ; B=0 so L->top set by previous instruction
  5 [1] RETURN    0 1

Thus upon entry to a function ``base`` is always the location of the first fixed parameter if any or else ``local`` if any. The three possibilities are shown below.

::

                                       Two variable args and 1     Two variable args and no 
  Caller   One fixed arg               fixed arg                   fixed args
  R(A)     CI->func  [ function    ]   CI->func  [ function    ]   CI->func [ function   ]
  R(A+1)   CI->base  [ fixed arg 1 ]             [ var arg 1   ]            [ var arg 1  ]
  R(A+2)             [ local 1     ]             [ var arg 2   ]            [ var arg 2  ]
  R(A+3)                               CI->base  [ fixed arg 1 ]   CI->base [ local 1    ]
  R(A+4)                                         [ local 1     ]
                                        
Results returned by the function call are placed in a range of registers starting from ``CI->func``. 
If ``C`` is ``1``, no return results are saved. If ``C`` is 2 or more, ``(C-1)`` return values are saved. 
If ``C`` is ``0``, then multiple return results are saved. In this case the number of values to save is 
determined by one of following ways:

* A C function returns an integer value indicating number of results returned so for C function calls
  this is used (see the value of ``n`` passed to 
  `luaD_poscall() <http://www.lua.org/source/5.3/ldo.c.html#luaD_poscall>`_ 
  in `luaD_precall() <http://www.lua.org/source/5.3/ldo.c.html#luaD_precall>`_)
* For Lua functions, the results are saved by the called function's ``OP_RETURN`` instruction.

More examples
-------------

::

  x=function() y() end

Produces::

  function <stdin:1,1> (3 instructions at 000000CECB2BE040)
  0 params, 2 slots, 1 upvalue, 0 locals, 1 constant, 0 functions
    1       [1]     GETTABUP        0 0 -1  ; _ENV "y"
    2       [1]     CALL            0 1 1
    3       [1]     RETURN          0 1
  constants (1) for 000000CECB2BE040:
    1       "y"
  locals (0) for 000000CECB2BE040:
  upvalues (1) for 000000CECB2BE040:
    0       _ENV    0       0

In line [2], the call has zero parameters (field B is 1), zero results are retained (field C is 1), 
while register 0 temporarily holds the reference to the function object from global y. Next we see a 
function call with multiple parameters or arguments::

  x=function() z(1,2,3) end

Generates::

  function <stdin:1,1> (6 instructions at 000000CECB2D7BC0)
  0 params, 4 slots, 1 upvalue, 0 locals, 4 constants, 0 functions
    1       [1]     GETTABUP        0 0 -1  ; _ENV "z"
    2       [1]     LOADK           1 -2    ; 1
    3       [1]     LOADK           2 -3    ; 2
    4       [1]     LOADK           3 -4    ; 3
    5       [1]     CALL            0 4 1
    6       [1]     RETURN          0 1
  constants (4) for 000000CECB2D7BC0:
    1       "z"
    2       1
    3       2
    4       3
  locals (0) for 000000CECB2D7BC0:
  upvalues (1) for 000000CECB2D7BC0:
    0       _ENV    0       0


Lines [1] to [4] loads the function reference and the arguments in order, then line [5] makes the 
call with an operand B value of 4, which means there are 3 parameters. Since the call statement is 
not assigned to anything, no return results need to be retained, hence field C is 1. Here is an 
example that uses multiple parameters and multiple return values::


  x=function() local p,q,r,s = z(y()) end

Produces::

  function <stdin:1,1> (5 instructions at 000000CECB2D6CC0)
  0 params, 4 slots, 1 upvalue, 4 locals, 2 constants, 0 functions
    1       [1]     GETTABUP        0 0 -1  ; _ENV "z"
    2       [1]     GETTABUP        1 0 -2  ; _ENV "y"
    3       [1]     CALL            1 1 0
    4       [1]     CALL            0 0 5
    5       [1]     RETURN          0 1
  constants (2) for 000000CECB2D6CC0:
    1       "z"
    2       "y"
  locals (4) for 000000CECB2D6CC0:
    0       p       5       6
    1       q       5       6
    2       r       5       6
    3       s       5       6
  upvalues (1) for 000000CECB2D6CC0:
    0       _ENV    0       0

First, the function references are retrieved (lines [1] and [2]), then function y is called 
first (temporary register 1). The CALL has a field C of 0, meaning multiple return values are accepted. 
These return values become the parameters to function z, and so in line [4], field B of the CALL 
instruction is 0, signifying multiple parameters. After the call to function z, 4 results are 
retained, so field C in line [4] is 5. Finally, here is an example with calls to standard library functions::

  x=function() print(string.char(64)) end

Leads to::

  function <stdin:1,1> (7 instructions at 000000CECB2D6220)
  0 params, 3 slots, 1 upvalue, 0 locals, 4 constants, 0 functions
    1       [1]     GETTABUP        0 0 -1  ; _ENV "print"
    2       [1]     GETTABUP        1 0 -2  ; _ENV "string"
    3       [1]     GETTABLE        1 1 -3  ; "char"
    4       [1]     LOADK           2 -4    ; 64
    5       [1]     CALL            1 2 0
    6       [1]     CALL            0 0 1
    7       [1]     RETURN          0 1
  constants (4) for 000000CECB2D6220:
    1       "print"
    2       "string"
    3       "char"
    4       64
  locals (0) for 000000CECB2D6220:
  upvalues (1) for 000000CECB2D6220:
    0       _ENV    0       0

When a function call is the last parameter to another function call, the former 
can pass multiple return values, while the latter can accept multiple parameters.

OP_TAILCALL instruction
=======================

Syntax
------

::

  TAILCALL  A B C return R(A)(R(A+1), ... ,R(A+B-1))

Description
-----------

Performs a tail call, which happens when a return statement has a single function call as the expression, e.g. return foo(bar). A tail call results in the function being interpreted within the same call frame as the caller - the stack is replaced and then a 'goto' executed to start at the entry point in the VM. Only Lua functions can be tailcalled. Tailcalls allow infinite recursion without growing the stack.

Like ``OP_CALL``, register R(A) holds the reference to the function object to be called. B encodes the number of parameters in the same manner as a ``OP_CALL`` instruction.

C isn’t used by TAILCALL, since all return results are significant. In any case, Lua always generates a 0 for C, to denote multiple return results.

Examples
--------
An ``OP_TAILCALL`` is used only for one specific return style, described above. Multiple return results are always produced by a tail call. Here is an example:


::

  function y() return x('foo', 'bar') end

Generates::

  function <stdin:1,1> (6 instructions at 000000C3C24DE4A0)
  0 params, 3 slots, 1 upvalue, 0 locals, 3 constants, 0 functions
    1       [1]     GETTABUP        0 0 -1  ; _ENV "x"
    2       [1]     LOADK           1 -2    ; "foo"
    3       [1]     LOADK           2 -3    ; "bar"
    4       [1]     TAILCALL        0 3 0
    5       [1]     RETURN          0 0
    6       [1]     RETURN          0 1
  constants (3) for 000000C3C24DE4A0:
    1       "x"
    2       "foo"
    3       "bar"
  locals (0) for 000000C3C24DE4A0:
  upvalues (1) for 000000C3C24DE4A0:
    0       _ENV    0       0


Arguments for a tail call are handled in exactly the same way as arguments for a normal call, so in line [4], the tail call has a field B value of 3, signifying 2 parameters. Field C is 0, for multiple returns; this due to the constant LUA_MULTRET in lua.h. In practice, field C is not used by the virtual machine (except as an assert) since the syntax guarantees multiple return results.
Line [5] is a ``OP_RETURN`` instruction specifying multiple return results. This is required when the function called by ``OP_TAILCALL`` is a C function. In the case of a C function, execution continues to line [5] upon return, thus the RETURN is necessary. Line [6] is redundant. When Lua functions are tailcalled, the virtual machine does not return to line [5] at all.

OP_RETURN instruction
=====================

Syntax
------

::

  RETURN  A B return R(A), ... ,R(A+B-2)

Description
-----------

Returns to the calling function, with optional return values. 

First ``OP_RETURN`` closes any open upvalues by calling `luaF_close() <http://www.lua.org/source/5.3/lfunc.c.html#luaF_close>`_.

If B is 1, there are no return values. If B is 2 or more, there are (B-1) return values, located in consecutive registers from R(A) onwards. If B is 0, the set of values range from R(A) to the top of the stack. 

It is assumed that if the VM is returning to a Lua function then it is within the same invocation of the ``luaV_execute()``. Else it is assumed that ``luaV_execute()`` is being invoked from a C function.

If B is 0 then the previous instruction (which must be either ``OP_CALL`` or ``OP_VARARG`` ) would have set ``L->top`` to indicate how many values to return. The number of values to be returned in this case is R(A) to L->top. 

If B > 0 then the number of values to be returned is simply B-1.

``OP_RETURN`` calls `luaD_poscall() <http://www.lua.org/source/5.3/ldo.c.html#luaD_poscall>`_ which is responsible for copying return values to the caller - the first result is placed at the current ``closure``'s address. ``luaD_poscall()`` leaves ``L->top`` just past the last result that was copied.

If ``OP_RETURN`` is returning to a Lua function and if the number of return values expected was indeterminate - i.e. ``OP_CALL`` had operand C = 0, then ``L->top`` is left where ``luaD_poscall()`` placed it - just beyond the top of the result list. This allows the ``OP_CALL`` instruction to figure out how many results were returned. If however ``OP_CALL`` had invoked with a value of C > 0 then the expected number of results is known, and in that case, ``L->top`` is reset to  the calling function's ``C->top``.

If ``luaV_execute()`` was called externally then ``OP_RETURN`` leaves ``L->top`` unchanged - so it will continue to be just past the top of the results list. This is because luaV_execute() does not have a way of informing callers how many values were returned; so the caller can determine the number of results by inspecting ``L->top``.

Examples
--------

Example of ``OP_VARARG`` followed by ``OP_RETURN``::

  function x(...) return ... end

  1 [1]  VARARG          0 0
  2 [1]  RETURN          0 0

Suppose we call ``x(1,2,3)``; then, observe the setting of ``L->top`` when ``OP_RETURN`` executes::

  (LOADK A=1 Bx=-2)      L->top = 4, ci->top = 4
  (LOADK A=2 Bx=-3)      L->top = 4, ci->top = 4
  (LOADK A=3 Bx=-4)      L->top = 4, ci->top = 4
  (TAILCALL A=0 B=4 C=0) L->top = 4, ci->top = 4
  (VARARG A=0 B=0)       L->top = 2, ci->top = 2  ; we are in x()
  (RETURN A=0 B=0)       L->top = 3, ci->top = 2

Observe that ``OP_VARARG`` set ``L->top`` to ``base+3``.

But if we call ``x(1)`` instead::

  (LOADK A=1 Bx=-2)      L->top = 4, ci->top = 4
  (LOADK A=2 Bx=-3)      L->top = 4, ci->top = 4
  (LOADK A=3 Bx=-4)      L->top = 4, ci->top = 4
  (TAILCALL A=0 B=4 C=0) L->top = 4, ci->top = 4
  (VARARG A=0 B=0)       L->top = 2, ci->top = 2 ; we are in x()
  (RETURN A=0 B=0)       L->top = 1, ci->top = 2

Notice that this time ``OP_VARARG`` set ``L->top`` to ``base+1``.

OP_JMP instruction
==================

Syntax
------

::

  JMP A sBx   pc+=sBx; if (A) close all upvalues >= R(A - 1)

Description
-----------

Performs an unconditional jump, with sBx as a signed displacement. sBx is added to the program counter (PC), which points to the next instruction to be executed. If sBx is 0, the VM will proceed to the next instruction.

If R(A) is not 0 then all upvalues >= R(A-1) will be closed by calling `luaF_close() <http://www.lua.org/source/5.3/lfunc.c.html#luaF_close>`_.

``OP_JMP`` is used in loops, conditional statements, and in expressions when a boolean true/false need to be generated.

Examples
--------

For example, since a relational test instruction makes conditional jumps rather than generate a boolean result, a JMP is used in the code sequence for loading either a true or a false::

  function x() local m, n; return m >= n end

Generates::

  function <stdin:1,1> (7 instructions at 00000034D2ABE340)
  0 params, 3 slots, 0 upvalues, 2 locals, 0 constants, 0 functions
    1       [1]     LOADNIL         0 1
    2       [1]     LE              1 1 0   ; to 4 if false    (n <= m)
    3       [1]     JMP             0 1     ; to 5
    4       [1]     LOADBOOL        2 0 1
    5       [1]     LOADBOOL        2 1 0
    6       [1]     RETURN          2 2
    7       [1]     RETURN          0 1
  constants (0) for 00000034D2ABE340:
  locals (2) for 00000034D2ABE340:
    0       m       2       8
    1       n       2       8
  upvalues (0) for 00000034D2ABE340:

Line[2] performs the relational test. In line [3], the JMP skips over the false path (line [4]) to the true path (line [5]). The result is placed into temporary local 2, and returned to the caller by RETURN in line [6].

OP_VARARG instruction
=====================

Syntax
------

::

  VARARG  A B R(A), R(A+1), ..., R(A+B-1) = vararg

Description
-----------

``VARARG`` implements the vararg operator ``...`` in expressions. ``VARARG`` copies B-1 parameters into a number of registers starting from R(A), padding with nils if there aren’t enough values. If B is 0, ``VARARG`` copies as many values as it can based on the number of parameters passed. If a fixed number of values is required, B is a value greater than 1. If any number of values is required, B is 0.


Examples
--------

The use of VARARG will become clear with the help of a few examples::

  local a,b,c = ...

Generates::

  main <(string):0,0> (2 instructions at 00000029D9FA8310)
  0+ params, 3 slots, 1 upvalue, 3 locals, 0 constants, 0 functions
        1       [1]     VARARG          0 4
        2       [1]     RETURN          0 1
  constants (0) for 00000029D9FA8310:
  locals (3) for 00000029D9FA8310:
        0       a       2       3
        1       b       2       3
        2       c       2       3
  upvalues (1) for 00000029D9FA8310:
        0       _ENV    1       0  

Note that the main or top-level chunk is a vararg function. In this example, the left hand side of the assignment statement needs three values (or objects.) So in instruction [1], the operand B of the ``VARARG`` instruction is (3+1), or 4. ``VARARG`` will copy three values into a, b and c. If there are less than three values available, nils will be used to fill up the empty places.

::

  local a = function(...) local a,b,c = ... end

This gives::

  main <(string):0,0> (2 instructions at 00000029D9FA72D0)
  0+ params, 2 slots, 1 upvalue, 1 local, 0 constants, 1 function
        1       [1]     CLOSURE         0 0     ; 00000029D9FA86D0
        2       [1]     RETURN          0 1
  constants (0) for 00000029D9FA72D0:
  locals (1) for 00000029D9FA72D0:
        0       a       2       3
  upvalues (1) for 00000029D9FA72D0:
        0       _ENV    1       0

  function <(string):1,1> (2 instructions at 00000029D9FA86D0)
  0+ params, 3 slots, 0 upvalues, 3 locals, 0 constants, 0 functions
        1       [1]     VARARG          0 4
        2       [1]     RETURN          0 1
  constants (0) for 00000029D9FA86D0:
  locals (3) for 00000029D9FA86D0:
        0       a       2       3
        1       b       2       3
        2       c       2       3
  upvalues (0) for 00000029D9FA86D0:


Here is an alternate version where a function is instantiated and assigned to local a. The old-style arg is retained for compatibility purposes, but is unused in the above example.

::

  local a; a(...)

Leads to::

  main <(string):0,0> (5 instructions at 00000029D9FA6D30)
  0+ params, 3 slots, 1 upvalue, 1 local, 0 constants, 0 functions
        1       [1]     LOADNIL         0 0
        2       [1]     MOVE            1 0
        3       [1]     VARARG          2 0
        4       [1]     CALL            1 0 1
        5       [1]     RETURN          0 1
  constants (0) for 00000029D9FA6D30:
  locals (1) for 00000029D9FA6D30:
        0       a       2       6
  upvalues (1) for 00000029D9FA6D30:
        0       _ENV    1       0

When a function is called with ``...`` as the argument, the function will accept a variable number of parameters or arguments. On instruction [3], a ``VARARG`` with a B field of 0 is used. The ``VARARG`` will copy all the parameters passed on to the main chunk to register 2 onwards, so that the ``CALL`` in the next line can utilize them as parameters of function ``a``. The function call is set to accept a multiple number of parameters and returns zero results.

::

  local a = {...}

Produces::

  main <(string):0,0> (4 instructions at 00000029D9FA8130)
  0+ params, 2 slots, 1 upvalue, 1 local, 0 constants, 0 functions
        1       [1]     NEWTABLE        0 0 0
        2       [1]     VARARG          1 0
        3       [1]     SETLIST         0 0 1   ; 1
        4       [1]     RETURN          0 1
  constants (0) for 00000029D9FA8130:
  locals (1) for 00000029D9FA8130:
        0       a       4       5
  upvalues (1) for 00000029D9FA8130:
        0       _ENV    1       0

And::

  return ...

Produces::

  main <(string):0,0> (3 instructions at 00000029D9FA8270)
  0+ params, 2 slots, 1 upvalue, 0 locals, 0 constants, 0 functions
        1       [1]     VARARG          0 0
        2       [1]     RETURN          0 0
        3       [1]     RETURN          0 1
  constants (0) for 00000029D9FA8270:
  locals (0) for 00000029D9FA8270:
  upvalues (1) for 00000029D9FA8270:
        0       _ENV    1       0

Above are two other cases where ``VARARG`` needs to copy all passed parameters 
over to a set of registers in order for the next operation to proceed. Both the above forms of 
table creation and return accepts a variable number of values or objects.

OP_LOADBOOL instruction
=======================

Syntax
------

::

  LOADBOOL A B C    R(A) := (Bool)B; if (C) pc++      

Description
-----------

Loads a boolean value (true or false) into register R(A). true is usually encoded as an integer 1, false is always 0. If C is non-zero, then the next instruction is skipped (this is used when you have an assignment statement where the expression uses relational operators, e.g. M = K>5.)
You can use any non-zero value for the boolean true in field B, but since you cannot use booleans as numbers in Lua, it’s best to stick to 1 for true.

``LOADBOOL`` is used for loading a boolean value into a register. It’s also used where a boolean result is supposed to be generated, because relational test instructions, for example, do not generate boolean results – they perform conditional jumps instead. The operand C is used to optionally skip the next instruction (by incrementing PC by 1) in order to support such code. For simple assignments of boolean values, C is always 0.

Examples
--------

The following line of code::

  f=load('local a,b = true,false')

generates::

  main <(string):0,0> (3 instructions at 0000020F274C2610)
  0+ params, 2 slots, 1 upvalue, 2 locals, 0 constants, 0 functions
        1       [1]     LOADBOOL        0 1 0
        2       [1]     LOADBOOL        1 0 0
        3       [1]     RETURN          0 1
  constants (0) for 0000020F274C2610:
  locals (2) for 0000020F274C2610:
        0       a       3       4
        1       b       3       4
  upvalues (1) for 0000020F274C2610:
        0       _ENV    1       0

This example is straightforward: Line [1] assigns true to local a (register 0) while line [2] assigns false to local b (register 1). In both cases, field C is 0, so PC is not incremented and the next instruction is not skipped.

Next, look at this line::

  f=load('local a = 5 > 2')

This leads to following bytecode::

  main <(string):0,0> (5 instructions at 0000020F274BAE00)
  0+ params, 2 slots, 1 upvalue, 1 local, 2 constants, 0 functions
        1       [1]     LT              1 -2 -1 ; 2 5
        2       [1]     JMP             0 1     ; to 4
        3       [1]     LOADBOOL        0 0 1
        4       [1]     LOADBOOL        0 1 0
        5       [1]     RETURN          0 1
  constants (2) for 0000020F274BAE00:
        1       5
        2       2
  locals (1) for 0000020F274BAE00:
        0       a       5       6
  upvalues (1) for 0000020F274BAE00:
        0       _ENV    1       0

This is an example of an expression that gives a boolean result and is assigned to a variable. Notice that Lua does not optimize the expression into a true value; Lua does not perform compile-time constant evaluation for relational operations, but it can perform simple constant evaluation for arithmetic operations.

Since the relational operator ``LT``  does not give a boolean result but performs a conditional jump, ``LOADBOOL`` uses its C operand to perform an unconditional jump in line [3] – this saves one instruction and makes things a little tidier. The reason for all this is that the instruction set is simply optimized for if...then blocks. Essentially, ``local a = 5 > 2`` is executed in the following way::

  local a 
  if 2 < 5 then  
    a = true 
  else  
    a = false 
  end

In the disassembly listing, when ``LT`` tests 2 < 5, it evaluates to true and doesn’t perform a conditional jump. Line [2] jumps over the false result path, and in line [4], the local a (register 0) is assigned the boolean true by the instruction ``LOADBOOL``. If 2 and 5 were reversed, line [3] will be followed instead, setting a false, and then the true result path (line [4]) will be skipped, since ``LOADBOOL`` has its field C set to non-zero.

So the true result path goes like this (additional comments in parentheses)::

        1       [1]     LT              1 -2 -1 ; 2 5       (if 2 < 5)
        2       [1]     JMP             0 1     ; to 4     
        4       [1]     LOADBOOL        0 1 0   ;           (a = true)           
        5       [1]     RETURN          0 1

and the false result path (which never executes in this example) goes like this::

        1       [1]     LT              1 -2 -1 ; 2 5       (if 2 < 5)
        3       [1]     LOADBOOL        0 0 1               (a = false)
        5       [1]     RETURN          0 1

The true result path looks longer, but it isn’t, due to the way the virtual machine is implemented. This will be discussed further in the section on relational and logic instructions.


OP_EQ, OP_LT and OP_LE Instructions
===================================

Relational and logic instructions are used in conjunction with other instructions to implement control 
structures or expressions. Instead of generating boolean results, these instructions conditionally perform 
a jump over the next instruction; the emphasis is on implementing control blocks. Instructions are arranged 
so that there are two paths to follow based on the relational test.

::

  EQ  A B C if ((RK(B) == RK(C)) ~= A) then PC++
  LT  A B C if ((RK(B) <  RK(C)) ~= A) then PC++
  LE  A B C if ((RK(B) <= RK(C)) ~= A) then PC++

Description
-----------

Compares RK(B) and RK(C), which may be registers or constants. If the boolean result is not A, 
then skip the next instruction. Conversely, if the boolean result equals A, continue with the 
next instruction.

``EQ`` is for equality. ``LT`` is for “less than” comparison. ``LE`` is for “less than or equal to” 
comparison. The boolean A field allows the full set of relational comparison operations to be 
synthesized from these three instructions. The Lua code generator produces either 0 or 1 for the boolean A.

For the fall-through case, a `OP_JMP instruction`_ is always expected, in order to optimize execution in the 
virtual machine. In effect, ``EQ``, ``LT`` and ``LE`` must always be paired with a following ``JMP`` 
instruction. 

Examples
--------
By comparing the result of the relational operation with A, the sense of the comparison can 
be reversed. Obviously the alternative is to reverse the paths taken by the instruction, but that 
will probably complicate code generation some more. The conditional jump is performed if the comparison 
result is not A, whereas execution continues normally if the comparison result matches A. 
Due to the way code is generated and the way the virtual machine works, a ``JMP`` instruction is 
always expected to follow an ``EQ``, ``LT`` or ``LE``. The following ``JMP`` is optimized by 
executing it in conjunction with ``EQ``, ``LT`` or ``LE``.

::

  local x,y; return x ~= y

Generates::

  main <(string):0,0> (7 instructions at 0000001BC48FD390)
  0+ params, 3 slots, 1 upvalue, 2 locals, 0 constants, 0 functions
        1       [1]     LOADNIL         0 1
        2       [1]     EQ              0 0 1
        3       [1]     JMP             0 1     ; to 5
        4       [1]     LOADBOOL        2 0 1
        5       [1]     LOADBOOL        2 1 0
        6       [1]     RETURN          2 2
        7       [1]     RETURN          0 1
  constants (0) for 0000001BC48FD390:
  locals (2) for 0000001BC48FD390:
        0       x       2       8
        1       y       2       8
  upvalues (1) for 0000001BC48FD390:
        0       _ENV    1       0

In the above example, the equality test is performed in instruction [2]. However, since the 
comparison need to be returned as a result, ``LOADBOOL`` instructions are used to set a 
register with the correct boolean value. This is the usual code pattern generated if the expression 
requires a boolean value to be generated and stored in a register as an intermediate value or 
a final result.

It is easier to visualize the disassembled code as::

  if x ~= y then
    return true
  else
    return false
  end

The true result path (when the comparison result matches A) goes like this::

  1  [1] LOADNIL    0   1      
  2  [1] EQ         0   0   1    ; to 4 if true    (x ~= y)
  3  [1] JMP        1            ; to 5
  5  [1] LOADBOOL   2   1   0    ; true            (true path)
  6  [1] RETURN     2   2      

While the false result path (when the comparison result does not match A) goes like this::

  1  [1] LOADNIL    0   1      
  2  [1] EQ         0   0   1    ; to 4 if true    (x ~= y)
  4  [1] LOADBOOL   2   0   1    ; false, to 6     (false path)
  6  [1] RETURN     2   2      

Comments following the ``EQ`` in line [2] lets the user know when the conditional jump 
is taken. The jump is taken when “the value in register 0 equals to the value in register 1” 
(the comparison) is not false (the value of operand A). If the comparison is x == y, 
everything will be the same except that the A operand in the ``EQ`` instruction will be 1, 
thus reversing the sense of the comparison. Anyway, these are just the Lua code generator’s 
conventions; there are other ways to code x ~= y in terms of Lua virtual machine instructions.

For conditional statements, there is no need to set boolean results. Lua is optimized for 
coding the more common conditional statements rather than conditional expressions.

::

  local x,y; if x ~= y then return "foo" else return "bar" end

Results in::

  main <(string):0,0> (9 instructions at 0000001BC4914D50)
  0+ params, 3 slots, 1 upvalue, 2 locals, 2 constants, 0 functions
        1       [1]     LOADNIL         0 1
        2       [1]     EQ              1 0 1   ; to 4 if false    (x ~= y)
        3       [1]     JMP             0 3     ; to 7
        4       [1]     LOADK           2 -1    ; "foo"            (true block)
        5       [1]     RETURN          2 2
        6       [1]     JMP             0 2     ; to 9
        7       [1]     LOADK           2 -2    ; "bar"            (false block)
        8       [1]     RETURN          2 2
        9       [1]     RETURN          0 1
  constants (2) for 0000001BC4914D50:
        1       "foo"
        2       "bar"
  locals (2) for 0000001BC4914D50:
        0       x       2       10
        1       y       2       10
  upvalues (1) for 0000001BC4914D50:
        0       _ENV    1       0

In the above conditional statement, the same inequality operator is used in the source, 
but the sense of the ``EQ`` instruction in line [2] is now reversed. Since the ``EQ`` 
conditional jump can only skip the next instruction, additional ``JMP`` instructions 
are needed to allow large blocks of code to be placed in both true and false paths. 
In contrast, in the previous example, only a single instruction is needed to set a 
boolean value. For ``if`` statements, the true block comes first followed by the false 
block in code generated by the code generator. To reverse the positions of the true and 
false paths, the value of operand A is changed.

The true path (when ``x ~= y`` is true) goes from [2] to [4]–[6] and on to [9]. Since 
there is a ``RETURN`` in line [5], the ``JMP`` in line [6] and the ``RETURN`` in [9] 
are never executed at all; they are redundant but does not adversely affect performance 
in any way. The false path is from [2] to [3] to [7]–[9] onwards. So in a disassembly 
listing, you should see the true and false code blocks in the same order as in the 
Lua source.

The following is another example, this time with an ``elseif``::

  if 8 > 9 then return 8 elseif 5 >= 4 then return 5 else return 9 end

Generates::

  main <(string):0,0> (13 instructions at 0000001BC4913770)
  0+ params, 2 slots, 1 upvalue, 0 locals, 4 constants, 0 functions
        1       [1]     LT              0 -2 -1 ; 9 8
        2       [1]     JMP             0 3     ; to 6
        3       [1]     LOADK           0 -1    ; 8
        4       [1]     RETURN          0 2
        5       [1]     JMP             0 7     ; to 13
        6       [1]     LE              0 -4 -3 ; 4 5
        7       [1]     JMP             0 3     ; to 11
        8       [1]     LOADK           0 -3    ; 5
        9       [1]     RETURN          0 2
        10      [1]     JMP             0 2     ; to 13
        11      [1]     LOADK           0 -2    ; 9
        12      [1]     RETURN          0 2
        13      [1]     RETURN          0 1
  constants (4) for 0000001BC4913770:
        1       8
        2       9
        3       5
        4       4
  locals (0) for 0000001BC4913770:
  upvalues (1) for 0000001BC4913770:
        0       _ENV    1       0

This example is a little more complex, but the blocks are structured in the same order 
as the Lua source, so interpreting the disassembled code should not be too hard.

OP_TEST and OP_TESTSET instructions
===================================

Syntax
------

::

  TEST        A C     if (boolean(R(A)) != C) then PC++
  TESTSET     A B C   if (boolean(R(B)) != C) then PC++ else R(A) := R(B)
  
  where boolean(x) => ((x == nil || x == false) ? 0 : 1)

Description
-----------
These two instructions used for performing boolean tests and implementing Lua’s logical operators.

Used to implement ``and`` and ``or`` logical operators, or for testing a single register in a conditional statement.

For ``TESTSET``, register ``R(B)`` is coerced into a boolean (i.e. ``false`` and ``nil`` evaluate to ``0`` and any other value to ``1``) and 
compared to the boolean field ``C`` (``0`` or ``1``). If ``boolean(R(B))`` does not match ``C``, the next instruction is skipped, 
otherwise ``R(B)`` is assigned to ``R(A)`` and the VM continues with the next instruction. The ``and`` operator uses a ``C`` of ``0`` (false) while 
``or`` uses a C value of ``1`` (true).

``TEST`` is a more primitive version of ``TESTSET``. ``TEST`` is used when the assignment operation is not needed, otherwise it is the same as ``TESTSET`` 
except that the operand slots are different.

For the fall-through case, a ``JMP`` is always expected, in order to optimize execution in the virtual machine. In effect, ``TEST`` and ``TESTSET`` 
must always be paired with a following ``JMP`` instruction.

Examples
--------

``TEST`` and ``TESTSET`` are used in conjunction with a following ``JMP`` instruction, while ``TESTSET`` has an addditional conditional assignment. Like ``EQ``, ``LT`` and ``LE``, the following ``JMP`` instruction is compulsory, as the virtual machine will execute the ``JMP`` together with ``TEST`` or ``TESTSET``. The two instructions are used to implement short-circuit LISP-style logical operators that retains and propagates operand values instead of booleans. First, we’ll look at how and and or behaves::

  f=load('local a,b,c; c = a and b')

Generates::

  main <(string):0,0> (5 instructions at 0000020F274CF1A0)
  0+ params, 3 slots, 1 upvalue, 3 locals, 0 constants, 0 functions
        1       [1]     LOADNIL         0 2
        2       [1]     TESTSET         2 0 0   ; to 4 if true 
        3       [1]     JMP             0 1     ; to 5
        4       [1]     MOVE            2 1
        5       [1]     RETURN          0 1
  constants (0) for 0000020F274CF1A0:
  locals (3) for 0000020F274CF1A0:
        0       a       2       6
        1       b       2       6
        2       c       2       6
  upvalues (1) for 0000020F274CF1A0:
        0       _ENV    1       0

An ``and`` sequence exits on ``false`` operands (which can be ``false`` or ``nil``) because any ``false`` operands in a string of ``and`` operations 
will make the whole boolean expression ``false``. If operands evaluates to ``true``, evaluation continues. When a string of ``and`` operations 
evaluates to ``true``, the result is the last operand value.

In line [2], ``C`` is ``0``. Since ``B`` is ``0``, therefore ``R(B)`` refers to the local ``a``. Since ``R(B)`` is ``nil`` then ``boolean(R(B))`` evaluates to ``0``.
Thus ``C`` matches ``boolean(R(B))``. Therefore the value of ``a`` is assigned to ``c`` and the next instruction which is a ``JMP`` is executed. This is equivalent to::

  if a then  
    c = b      -- executed by MOVE on line [4] 
  else  
    c = a      -- executed by TESTSET on line [2] 
  end

The ``c = a`` portion is done by ``TESTSET`` itself, while ``MOVE`` performs ``c = b``. Now, if the result is already set with one of the possible values, 
a ``TEST`` instruction is used instead::

  f=load('local a,b; a = a and b')

Generates::

  main <(string):0,0> (5 instructions at 0000020F274D0A70)
  0+ params, 2 slots, 1 upvalue, 2 locals, 0 constants, 0 functions
        1       [1]     LOADNIL         0 1
        2       [1]     TEST            0 0     ; to 4 if true 
        3       [1]     JMP             0 1     ; to 5
        4       [1]     MOVE            0 1
        5       [1]     RETURN          0 1
  constants (0) for 0000020F274D0A70:
  locals (2) for 0000020F274D0A70:
        0       a       2       6
        1       b       2       6
  upvalues (1) for 0000020F274D0A70:
        0       _ENV    1       0

Here ``C`` is ``0``, and ``boolean(R(A))`` is ``0`` too, so that the ``TEST`` instruction on line [2] does not skip the next instruction which is a ``JMP``.
The ``TEST`` instruction does not perform an assignment operation, since ``a = a`` is redundant. This makes ``TEST`` a little faster. This is equivalent to::

  if a then  
    a = b 
  end

Next, we will look at the or operator::

  f=load('local a,b,c; c = a or b')

Generates::

  main <(string):0,0> (5 instructions at 0000020F274D1AB0)
  0+ params, 3 slots, 1 upvalue, 3 locals, 0 constants, 0 functions
        1       [1]     LOADNIL         0 2
        2       [1]     TESTSET         2 0 1   ; to 4 if false 
        3       [1]     JMP             0 1     ; to 5
        4       [1]     MOVE            2 1
        5       [1]     RETURN          0 1
  constants (0) for 0000020F274D1AB0:
  locals (3) for 0000020F274D1AB0:
        0       a       2       6
        1       b       2       6
        2       c       2       6
  upvalues (1) for 0000020F274D1AB0:
        0       _ENV    1       0

An ``or`` sequence exits on ``true`` operands, because any operands evaluating to ``true`` in a string of or operations will make the whole boolean 
expression ``true``. If operands evaluates to ``false``, evaluation continues. When a string of or operations evaluates to ``false``, 
all operands must have evaluated to ``false``.

In line [2], ``C`` is ``1``. Since ``B`` is ``0``, therefore ``R(B)`` refers to the local ``a``. Since ``R(B)`` is ``nil`` then ``boolean(R(B))`` evaluates to ``0``.
Thus ``C`` does not match ``boolean(R(B))``. Therefore, the next instruction which is a ``JMP`` is skipped and execution continues on line [4]. This is equivalent to::

  if a then  
    c = a      -- executed by TESTSET on line [2] 
  else  
    c = b      -- executed by MOVE on line [4] 
  end

Like the case of ``and``, ``TEST`` is used when the result already has one of the possible values, saving an assignment operation::

  f=load('local a,b; a = a or b')

Generates::

  main <(string):0,0> (5 instructions at 0000020F274D1010)
  0+ params, 2 slots, 1 upvalue, 2 locals, 0 constants, 0 functions
        1       [1]     LOADNIL         0 1
        2       [1]     TEST            0 1     ; to 4 if false
        3       [1]     JMP             0 1     ; to 5
        4       [1]     MOVE            0 1
        5       [1]     RETURN          0 1
  constants (0) for 0000020F274D1010:
  locals (2) for 0000020F274D1010:
        0       a       2       6
        1       b       2       6
  upvalues (1) for 0000020F274D1010:
        0       _ENV    1       0

Short-circuit logical operators also means that the following Lua code does not require the use of a boolean operation::

  f=load('local a,b,c; if a > b and a > c then return a end')

Leads to::

  main <(string):0,0> (7 instructions at 0000020F274D1150)
  0+ params, 3 slots, 1 upvalue, 3 locals, 0 constants, 0 functions
        1       [1]     LOADNIL         0 2
        2       [1]     LT              0 1 0   ; to 4 if true
        3       [1]     JMP             0 3     ; to 7
        4       [1]     LT              0 2 0   ; to 6 if true
        5       [1]     JMP             0 1     ; to 7
        6       [1]     RETURN          0 2
        7       [1]     RETURN          0 1
  constants (0) for 0000020F274D1150:
  locals (3) for 0000020F274D1150:
        0       a       2       8
        1       b       2       8
        2       c       2       8
  upvalues (1) for 0000020F274D1150:
        0       _ENV    1       0

With short-circuit evaluation, ``a > c`` is never executed if ``a > b`` is false, so the logic of the Lua statement can be readily implemented using the normal conditional structure. If both ``a > b`` and ``a > c`` are true, the path followed is [2] (the ``a > b`` test) to [4] (the ``a > c`` test) and finally to [6], returning the value of ``a``. A ``TEST`` instruction is not required. This is equivalent to::

  if a > b then  
    if a > c then    
      return a  
    end 
  end

For a single variable used in the expression part of a conditional statement, ``TEST`` is used to boolean-test the variable::

  f=load('if Done then return end')

Generates::

  main <(string):0,0> (5 instructions at 0000020F274D13D0)
  0+ params, 2 slots, 1 upvalue, 0 locals, 1 constant, 0 functions
        1       [1]     GETTABUP        0 0 -1  ; _ENV "Done"
        2       [1]     TEST            0 0     ; to 4 if true
        3       [1]     JMP             0 1     ; to 5
        4       [1]     RETURN          0 1
        5       [1]     RETURN          0 1
  constants (1) for 0000020F274D13D0:
        1       "Done"
  locals (0) for 0000020F274D13D0:
  upvalues (1) for 0000020F274D13D0:
        0       _ENV    1       0

In line [2], the ``TEST`` instruction jumps to the ``true`` block if the value in temporary register 0 (from the global ``Done``) is ``true``. The ``JMP`` at line [3] jumps over the ``true`` block, which is the code inside the if block (line [4]).

If the test expression of a conditional statement consist of purely boolean operators, then a number of TEST instructions will be used in the usual short-circuit evaluation style::

  f=load('if Found and Match then return end')

Generates::

  main <(string):0,0> (8 instructions at 0000020F274D1C90)
  0+ params, 2 slots, 1 upvalue, 0 locals, 2 constants, 0 functions
        1       [1]     GETTABUP        0 0 -1  ; _ENV "Found"
        2       [1]     TEST            0 0     ; to 4 if true
        3       [1]     JMP             0 4     ; to 8
        4       [1]     GETTABUP        0 0 -2  ; _ENV "Match"
        5       [1]     TEST            0 0     ; to 7 if true
        6       [1]     JMP             0 1     ; to 8
        7       [1]     RETURN          0 1
        8       [1]     RETURN          0 1
  constants (2) for 0000020F274D1C90:
        1       "Found"
        2       "Match"
  locals (0) for 0000020F274D1C90:
  upvalues (1) for 0000020F274D1C90:
        0       _ENV    1       0

In the last example, the true block of the conditional statement is executed only if both ``Found`` and ``Match`` evaluate to ``true``. The path is from [2] (test for ``Found``) to [4] to [5] (test for ``Match``) to [7] (the true block, which is an explicit ``return`` statement.)

If the statement has an ``else`` section, then the ``JMP`` on line [6] will jump to the false block (the ``else`` block) while an additional ``JMP`` will be added to the true block to jump over this new block of code. If ``or`` is used instead of ``and``, the appropriate C operand will be adjusted accordingly.

Finally, here is how Lua’s ternary operator (:? in C) equivalent works::

  f=load('local a,b,c; a = a and b or c')

Generates::

  main <(string):0,0> (7 instructions at 0000020F274D1A10)
  0+ params, 3 slots, 1 upvalue, 3 locals, 0 constants, 0 functions
        1       [1]     LOADNIL         0 2
        2       [1]     TEST            0 0     ; to 4 if true
        3       [1]     JMP             0 2     ; to 6
        4       [1]     TESTSET         0 1 1   ; to 6 if false
        5       [1]     JMP             0 1     ; to 7
        6       [1]     MOVE            0 2
        7       [1]     RETURN          0 1
  constants (0) for 0000020F274D1A10:
  locals (3) for 0000020F274D1A10:
        0       a       2       8
        1       b       2       8
        2       c       2       8
  upvalues (1) for 0000020F274D1A10:
        0       _ENV    1       0

The ``TEST`` in line [2] is for the ``and`` operator. First, local ``a`` is tested in line [2]. If it is false, then execution continues in [3], jumping to line [6]. Line [6] assigns local ``c`` to the end result because since if ``a`` is false, then ``a and b`` is ``false``, and ``false or c`` is ``c``.

If local ``a`` is ``true`` in line [2], the ``TEST`` instruction makes a jump to line [4], where there is a ``TESTSET``, for the ``or`` operator. If ``b`` evaluates to ``true``, then the end result is assigned the value of ``b``, because ``b or c`` is ``b`` if ``b`` is ``not false``. If ``b`` is also ``false``, the end result will be ``c``.

For the instructions in line [2], [4] and [6], the target (in field A) is register 0, or the local ``a``, which is the location where the result of the boolean expression is assigned. The equivalent Lua code is::

  if a then  
    if b then    
      a = b  
    else    
      a = c  
    end 
  else  
    a = c 
  end

The two ``a = c`` assignments are actually the same piece of code, but are repeated here to avoid using a ``goto`` and a label. Normally, if we assume ``b`` is ``not false`` and ``not nil``, we end up with the more recognizable form::

  if a then  
    a = b     -- assuming b ~= false 
  else  
    a = c 
  end


OP_FORPREP and OP_FORLOOP instructions
======================================

Syntax
------
::

  FORPREP    A sBx   R(A)-=R(A+2); pc+=sBx
  FORLOOP    A sBx   R(A)+=R(A+2);
                     if R(A) <?= R(A+1) then { pc+=sBx; R(A+3)=R(A) }


Description
-----------
Lua has dedicated instructions to implement the two types of ``for`` loops, while the other two types of loops uses traditional test-and-jump.

``FORPREP`` initializes a numeric for loop, while ``FORLOOP`` performs an iteration of a numeric for loop.

A numeric for loop requires 4 registers on the stack, and each register must be a number. R(A) holds the initial value and doubles as the internal loop variable (the internal index); R(A+1) is the limit; R(A+2) is the stepping value; R(A+3) is the actual loop variable (the external index) that is local to the for block.

``FORPREP`` sets up a for loop. Since ``FORLOOP`` is used for initial testing of the loop condition as well as conditional testing during the loop itself, ``FORPREP`` performs a negative step and jumps unconditionally to ``FORLOOP`` so that ``FORLOOP`` is able to correctly make the initial loop test. After this initial test, ``FORLOOP`` performs a loop step as usual, restoring the initial value of the loop index so that the first iteration can start.

In ``FORLOOP``, a jump is made back to the start of the loop body if the limit has not been reached or exceeded. The sense of the comparison depends on whether the stepping is negative or positive, hence the “<?=” operator. Jumps for both instructions are encoded as signed displacements in the ``sBx`` field. An empty loop has a ``FORLOOP`` ``sBx`` value of -1.

``FORLOOP`` also sets R(A+3), the external loop index that is local to the loop block. This is significant if the loop index is used as an upvalue (see below.) R(A), R(A+1) and R(A+2) are not visible to the programmer.

The loop variable ends with the last value before the limit is reached (unlike C) because it is not updated unless the jump is made. However, since loop variables are local to the loop itself, you should not be able to use it unless you cook up an implementation-specific hack.

Examples
--------
For the sake of efficiency, ``FORLOOP`` contains a lot of functionality, so when a loop iterates, only one instruction, ``FORLOOP``, is needed. Here is a simple example::

  f=load('local a = 0; for i = 1,100,5 do a = a + i end')

Generates::

  main <(string):0,0> (8 instructions at 000001E9F0DF52F0)
  0+ params, 5 slots, 1 upvalue, 5 locals, 4 constants, 0 functions
        1       [1]     LOADK           0 -1    ; 0
        2       [1]     LOADK           1 -2    ; 1
        3       [1]     LOADK           2 -3    ; 100
        4       [1]     LOADK           3 -4    ; 5
        5       [1]     FORPREP         1 1     ; to 7
        6       [1]     ADD             0 0 4
        7       [1]     FORLOOP         1 -2    ; to 6
        8       [1]     RETURN          0 1
  constants (4) for 000001E9F0DF52F0:
        1       0
        2       1
        3       100
        4       5
  locals (5) for 000001E9F0DF52F0:
        0       a       2       9
        1       (for index)     5       8
        2       (for limit)     5       8
        3       (for step)      5       8
        4       i       6       7
  upvalues (1) for 000001E9F0DF52F0:
        0       _ENV    1       0

In the above example, notice that the ``for`` loop causes three additional local pseudo-variables (or internal variables) to be defined, apart from the external loop index, ``i``. The three pseudovariables, named ``(for index)``, ``(for limit)`` and ``(for step)`` are required to completely specify the state of the loop, and are not visible to Lua source code. They are arranged in consecutive registers, with the external loop index given by R(A+3) or register 4 in the example.

The loop body is in line [6] while line [7] is the ``FORLOOP`` instruction that steps through the loop state. The ``sBx`` field of ``FORLOOP`` is negative, as it always jumps back to the beginning of the loop body.

Lines [2]–[4] initialize the three register locations where the loop state will be stored. If the loop step is not specified in the Lua source, a constant 1 is added to the constant pool and a ``LOADK`` instruction is used to initialize the pseudo-variable ``(for step)`` with the loop step.

``FORPREP`` in lines [5] makes a negative loop step and jumps to line [7] for the initial test. In the example, at line [5], the internal loop index (at register 1) will be (1-5) or -4. When the virtual machine arrives at the ``FORLOOP`` in line [7] for the first time, one loop step is made prior to the first test, so the initial value that is actually tested against the limit is (-4+5) or 1. Since 1 < 100, an iteration will be performed. The external loop index ``i`` is then set to 1 and a jump is made to line [6], thus starting the first iteration of the loop.

The loop at line [6]–[7] repeats until the internal loop index exceeds the loop limit of 100. The conditional jump is not taken when that occurs and the loop ends. Beyond the scope of the loop body, the loop state (``(for index)``, ``(for limit)``, ``(for step)`` and ``i``) is not valid. This is determined by the parser and code generator. The range of PC values for which the loop state variables are valid is located in the locals list. 

Here is another example::

  f=load('for i = 10,1,-1 do if i == 5 then break end end')

This leads to::

  main <(string):0,0> (8 instructions at 000001E9F0DEC110)
  0+ params, 4 slots, 1 upvalue, 4 locals, 4 constants, 0 functions
        1       [1]     LOADK           0 -1    ; 10
        2       [1]     LOADK           1 -2    ; 1
        3       [1]     LOADK           2 -3    ; -1
        4       [1]     FORPREP         0 2     ; to 7
        5       [1]     EQ              1 3 -4  ; - 5
        6       [1]     JMP             0 1     ; to 8
        7       [1]     FORLOOP         0 -3    ; to 5
        8       [1]     RETURN          0 1
  constants (4) for 000001E9F0DEC110:
        1       10
        2       1
        3       -1
        4       5
  locals (4) for 000001E9F0DEC110:
        0       (for index)     4       8
        1       (for limit)     4       8
        2       (for step)      4       8
        3       i       5       7
  upvalues (1) for 000001E9F0DEC110:
        0       _ENV    1       0

In the second loop example above, except for a negative loop step size, the structure of the loop is identical. The body of the loop is from line [5] to line [7]. Since no additional stacks or states are used, a break translates simply to a ``JMP`` instruction (line [6]). There is nothing to clean up after a ``FORLOOP`` ends or after a ``JMP`` to exit a loop.


OP_TFORCALL and OP_TFORLOOP instructions
========================================

Syntax
------
::

  TFORCALL    A C        R(A+3), ... ,R(A+2+C) := R(A)(R(A+1), R(A+2))
  TFORLOOP    A sBx      if R(A+1) ~= nil then { R(A)=R(A+1); pc += sBx }

Description
-----------
Apart from a numeric ``for`` loop (implemented by ``FORPREP`` and ``FORLOOP``), Lua has a generic ``for`` loop, implemented by ``TFORCALL`` and ``TFORLOOP``.

The generic ``for`` loop keeps 3 items in consecutive register locations to keep track of things. R(A) is the iterator function, which is called once per loop. R(A+1) is the state, and R(A+2) is the control variable. At the start, R(A+2) has an initial value. R(A), R(A+1) and R(A+2) are internal to the loop and cannot be accessed by the programmer.

In addition to these internal loop variables, the programmer specifies one or more loop variables that are external and visible to the programmer. These loop variables reside at locations R(A+3) onwards, and their count is specified in operand C. Operand C must be at least 1. They are also local to the loop body, like the external loop index in a numerical for loop.

Each time ``TFORCALL`` executes, the iterator function referenced by R(A) is called with two arguments: the state and the control variable (R(A+1) and R(A+2)). The results are returned in the local loop variables, from R(A+3) onwards, up to R(A+2+C).

Next, the ``TFORLOOP`` instruction tests the first return value, R(A+3). If it is nil, the iterator loop is at an end, and the ``for`` loop block ends by simply moving to the next instruction.

If R(A+3) is not nil, there is another iteration, and R(A+3) is assigned as the new value of the control variable, R(A+2). Then the ``TFORLOOP`` instruction sends execution back to the beginning of the loop (the ``sBx`` operand specifies how many instructions to move to get to the start of the loop body). 


Examples
--------
This example has a loop with one additional result (``v``) in addition to the loop enumerator (``i``)::

  f=load('for i,v in pairs(t) do print(i,v) end')

This produces::

  main <(string):0,0> (11 instructions at 0000014DB7FD2610)
  0+ params, 8 slots, 1 upvalue, 5 locals, 3 constants, 0 functions
        1       [1]     GETTABUP        0 0 -1  ; _ENV "pairs"
        2       [1]     GETTABUP        1 0 -2  ; _ENV "t"
        3       [1]     CALL            0 2 4
        4       [1]     JMP             0 4     ; to 9
        5       [1]     GETTABUP        5 0 -3  ; _ENV "print"
        6       [1]     MOVE            6 3
        7       [1]     MOVE            7 4
        8       [1]     CALL            5 3 1
        9       [1]     TFORCALL        0 2
        10      [1]     TFORLOOP        2 -6    ; to 5
        11      [1]     RETURN          0 1
  constants (3) for 0000014DB7FD2610:
        1       "pairs"
        2       "t"
        3       "print"
  locals (5) for 0000014DB7FD2610:
        0       (for generator) 4       11
        1       (for state)     4       11
        2       (for control)   4       11
        3       i       5       9
        4       v       5       9
  upvalues (1) for 0000014DB7FD2610:
        0       _ENV    1       0


The iterator function is located in register 0, and is named ``(for generator)`` for debugging purposes. The state is in register 1, and has the name ``(for state)``. The control variable, ``(for control)``, is contained in register 2. These correspond to locals R(A), R(A+1) and R(A+2) in the ``TFORCALL`` description. Results from the iterator function call is placed into register 3 and 4, which are locals ``i`` and ``v``, respectively. On line [9], the operand C of ``TFORCALL`` is 2, corresponding to two iterator variables (``i`` and ``v``).

Lines [1]–[3] prepares the iterator state. Note that the call to the ``pairs()`` standard library function has 1 parameter and 3 results. After the call in line [3], register 0 is the iterator function (which by default is the Lua function ``next()`` unless ``__pairs`` meta method has been overriden), register 1 is the loop state, register 2 is the initial value of the control variable (which is ``nil`` in the default case). The iterator variables ``i`` and ``v`` are both invalid at the moment, because we have not entered the loop yet.

Line [4] is a ``JMP`` to ``TFORCALL`` on line [9]. The ``TFORCALL`` instruction calls the iterator function, generating the first set of enumeration results in locals ``i`` and ``v``. 

The ``TFORLOOP`` insruction executes and checks whether ``i`` is ``nil``. If it is not ``nil``, then the internal control variable (register 2) is set to the value in ``i`` and control goes back to to the start of the loop body (lines [5]–[8]).

The body of the generic ``for`` loop executes (``print(i,v)``) and then ``TFORCALL`` is encountered again, calling the iterator function to get the next iteration state. Finally, when the ``TFORLOOP`` finds that the first result from the iterator is ``nil``, the loop ends, and execution continues on line [11].


OP_CLOSURE instruction
======================

Syntax
------

::

  CLOSURE A Bx    R(A) := closure(KPROTO[Bx])

Description
-----------
Creates an instance (or closure) of a function prototype. The ``Bx`` parameter
identifies the entry in the parent function's table of closure prototypes (the field ``p``
in the struct ``Proto``). The indices start from 0, i.e., a parameter of Bx = 0 references the first
closure prototype in the table.

The ``OP_CLOSURE`` instruction also sets up the ``upvalues`` for the closure being defined. This
is an involved process that is worthy of detailed discussion, and will be described through examples.

Examples
--------
Let's start with a simple example of a Lua function::

  f=load('function x() end; function y() end')

Here we are creating two Lua functions/closures within the main chunk.
The bytecodes for the chunk look this::

  main <(string):0,0> (5 instructions at 0000020E8A352930)
  0+ params, 2 slots, 1 upvalue, 0 locals, 2 constants, 2 functions
        1       [1]     CLOSURE         0 0     ; 0000020E8A352A70
        2       [1]     SETTABUP        0 -1 0  ; _ENV "x"
        3       [1]     CLOSURE         0 1     ; 0000020E8A3536A0
        4       [1]     SETTABUP        0 -2 0  ; _ENV "y"
        5       [1]     RETURN          0 1
  constants (2) for 0000020E8A352930:
        1       "x"
        2       "y"
  locals (0) for 0000020E8A352930:
  upvalues (1) for 0000020E8A352930:
        0       _ENV    1       0

  function <(string):1,1> (1 instruction at 0000020E8A352A70)
  0 params, 2 slots, 0 upvalues, 0 locals, 0 constants, 0 functions
        1       [1]     RETURN          0 1
  constants (0) for 0000020E8A352A70:
  locals (0) for 0000020E8A352A70:
  upvalues (0) for 0000020E8A352A70:

  function <(string):1,1> (1 instruction at 0000020E8A3536A0)
  0 params, 2 slots, 0 upvalues, 0 locals, 0 constants, 0 functions
        1       [1]     RETURN          0 1
  constants (0) for 0000020E8A3536A0:
  locals (0) for 0000020E8A3536A0:
  upvalues (0) for 0000020E8A3536A0:

What we observe is that the first ``CLOSURE`` instruction has parameter
``Bx`` set to 0, and this is the reference to the closure 0000020E8A352A70
which appears at position 0 in the table of closures within the main chunk's
``Proto`` structure.

Similarly the second ``CLOSURE`` instruction has parameter ``Bx`` set to 1,
and this references the closure at position 1 in the table, which is 
0000020E8A3536A0.

Other things to notice is that the main chunk got an automatic upvalue
named ``_ENV``::

  upvalues (1) for 0000020E8A352930:
        0       _ENV    1       0

The first ``0`` is the index of the upvalue in the main chunk. The ``1``
following the name is a boolean indicating that the upvalue is located on the
stack, and the last ``0`` is identifies the register location on the stack.
So the Lua Parser has setup the ``upvalue`` reference for ``_ENV``. However 
note that there is no actual local in this case; the ``_ENV`` upvalue is
special and is setup by the Lua `lua_load() <http://www.lua.org/source/5.3/lapi.c.html#lua_load>`_
API function. 

Now let's look at an example that creates a local up-value::

  f=load('local u,v; function p() return v end')

We get following bytecodes::

  main <(string):0,0> (4 instructions at 0000022149BBA3B0)
  0+ params, 3 slots, 1 upvalue, 2 locals, 1 constant, 1 function
        1       [1]     LOADNIL         0 1
        2       [1]     CLOSURE         2 0     ; 0000022149BBB7B0
        3       [1]     SETTABUP        0 -1 2  ; _ENV "p"
        4       [1]     RETURN          0 1
  constants (1) for 0000022149BBA3B0:
        1       "p"
  locals (2) for 0000022149BBA3B0:
        0       u       2       5
        1       v       2       5
  upvalues (1) for 0000022149BBA3B0:
        0       _ENV    1       0

  function <(string):1,1> (3 instructions at 0000022149BBB7B0)
  0 params, 2 slots, 1 upvalue, 0 locals, 0 constants, 0 functions
        1       [1]     GETUPVAL        0 0     ; v
        2       [1]     RETURN          0 2
        3       [1]     RETURN          0 1
  constants (0) for 0000022149BBB7B0:
  locals (0) for 0000022149BBB7B0:
  upvalues (1) for 0000022149BBB7B0:
        0       v       1       1

In the function 'p' the upvalue list contains::

  upvalues (1) for 0000022149BBB7B0:
        0       v       1       1

This says that the up-value is in the stack (first '1') and is located at register '1' of
the parent function. Access to this upvalue is indirectly obtained via the ``GETUPVAL``
instruction on line 1.

Now, lets look at what happens when the upvalue is not directly within the parent
function::

  f=load('local u,v; function p() u=1; local function q() return v end end')

In this example, we have 1 upvalue reference in function 'p', which is 'u'. Function 'q' has
one upvalue reference 'v' but this is not a variable in 'p', but is in the grand-parent. 
Here are the resulting bytecodes::

  main <(string):0,0> (4 instructions at 0000022149BBFE40)
  0+ params, 3 slots, 1 upvalue, 2 locals, 1 constant, 1 function
        1       [1]     LOADNIL         0 1
        2       [1]     CLOSURE         2 0     ; 0000022149BBFC60
        3       [1]     SETTABUP        0 -1 2  ; _ENV "p"
        4       [1]     RETURN          0 1
  constants (1) for 0000022149BBFE40:
        1       "p"
  locals (2) for 0000022149BBFE40:
        0       u       2       5
        1       v       2       5
  upvalues (1) for 0000022149BBFE40:
        0       _ENV    1       0

  function <(string):1,1> (4 instructions at 0000022149BBFC60)
  0 params, 2 slots, 2 upvalues, 1 local, 1 constant, 1 function
        1       [1]     LOADK           0 -1    ; 1
        2       [1]     SETUPVAL        0 0     ; u
        3       [1]     CLOSURE         0 0     ; 0000022149BC06B0
        4       [1]     RETURN          0 1
  constants (1) for 0000022149BBFC60:
        1       1
  locals (1) for 0000022149BBFC60:
        0       q       4       5
  upvalues (2) for 0000022149BBFC60:
        0       u       1       0
        1       v       1       1

  function <(string):1,1> (3 instructions at 0000022149BC06B0)
  0 params, 2 slots, 1 upvalue, 0 locals, 0 constants, 0 functions
        1       [1]     GETUPVAL        0 0     ; v
        2       [1]     RETURN          0 2
        3       [1]     RETURN          0 1
  constants (0) for 0000022149BC06B0:
  locals (0) for 0000022149BC06B0:
  upvalues (1) for 0000022149BC06B0:
        0       v       0       1

We see that 'p' got the upvalue 'u' as expected, but it also got the
upvalue 'v', and both are marked as 'instack' of the parent function::

  upvalues (2) for 0000022149BBFC60:
        0       u       1       0
        1       v       1       1

The reason for this is that any upvalue references in the inmost nested
function will also appear in the parent functions up the chain until the
function whose stack contains the variable being referenced. So although the
function 'p' does not directly reference 'v', but because its child function
'q' references 'v', 'p' gets the upvalue reference to 'v' as well.

Observe the upvalue list of 'q' now::

  upvalues (1) for 0000022149BC06B0:
        0       v       0       1

'q' has one upvalue reference as expected, but this time the upvalue is
not marked 'instack', which means that the reference is to an upvalue and not a local in 
the parent function (in this case 'p') and the upvalue index is '1' (i.e. the 
second upvalue in 'p').

Upvalue setup by OP_CLOSURE
---------------------------
When the ``CLOSURE`` instruction is executed, the up-values referenced by the
prototype are resolved. So that means the actual resolution if upvalues occurs at
runtime. This is done in the function `pushclosure() <http://www.lua.org/source/5.3/lvm.c.html#pushclosure>`_.

Caching of closures
-------------------
The Lua VM maintains a cache of closures within each function prototype at runtime.
If a closure is required that has the same set of upvalues as referenced by an existing
closure then the VM reuses the existing closure rather than creating a new one. This is
illustrated in this contrived example::

  f=load('local v; local function q() return function() return v end end; return q(), q()')

When the statement ``return q(), q()`` is executed it will end up returning two closures that
are really the same instance, as shown by the result of executing this code::

  > f()
  function: 000001E1E2F007E0      function: 000001E1E2F007E0

OP_GETUPVAL and OP_SETUPVAL instructions
========================================

Syntax
------
::

  GETUPVAL  A B     R(A) := UpValue[B]  
  SETUPVAL  A B     UpValue[B] := R(A)

Description
-----------

``GETUPVAL`` copies the value in upvalue number ``B`` into register ``R(A)``. Each Lua function may have its own upvalue list. This upvalue list is internal to the virtual machine; the list of upvalue name strings in a prototype is not mandatory.

``SETUPVAL`` copies the value from register ``R(A)`` into the upvalue number ``B`` in the upvalue list for that function.

Examples
--------
``GETUPVAL`` and ``SETUPVAL`` instructions use internally-managed upvalue lists. The list of upvalue name strings that are found in a function prototype is for debugging purposes; it is not used by the Lua virtual machine and can be stripped by ``luac``.
During execution, upvalues are set up by a ``CLOSURE``, and maintained by the Lua virtual machine. In the following example, function ``b`` is declared inside the main chunk, and is shown in the disassembly as a function prototype within a function prototype. The indentation, which is not in the original output, helps to visually separate the two functions.

::

  f=load('local a; function b() a = 1 return a end')

Leads to::

  main <(string):0,0> (4 instructions at 000002853D5177F0)
  0+ params, 2 slots, 1 upvalue, 1 local, 1 constant, 1 function
        1       [1]     LOADNIL         0 0
        2       [1]     CLOSURE         1 0     ; 000002853D517920
        3       [1]     SETTABUP        0 -1 1  ; _ENV "b"
        4       [1]     RETURN          0 1
  constants (1) for 000002853D5177F0:
        1       "b"
  locals (1) for 000002853D5177F0:
        0       a       2       5
  upvalues (1) for 000002853D5177F0:
        0       _ENV    1       0

    function <(string):1,1> (5 instructions at 000002853D517920)
    0 params, 2 slots, 1 upvalue, 0 locals, 1 constant, 0 functions
          1       [1]     LOADK           0 -1    ; 1
          2       [1]     SETUPVAL        0 0     ; a
          3       [1]     GETUPVAL        0 0     ; a
          4       [1]     RETURN          0 2
          5       [1]     RETURN          0 1
    constants (1) for 000002853D517920:
          1       1
    locals (0) for 000002853D517920:
    upvalues (1) for 000002853D517920:
          0       a       1       0

In the main chunk, the local ``a`` starts as a ``nil``. The ``CLOSURE`` instruction in line [2] then instantiates a function closure with a single upvalue, ``a``. In line [3] the closure is assigned to global ``b`` via the ``SETTABUP`` instruction.

In function ``b``, there is a single upvalue, `a`. In Pascal, a variable in an outer scope is found by traversing stack frames. However, instantiations of Lua functions are first-class values, and they may be assigned to a variable and referenced elsewhere. Moreover, a single prototype may have multiple instantiations. Managing upvalues thus becomes a little more tricky than traversing stack frames in Pascal. The Lua virtual machine solution is to provide a clean interface to access upvalues via ``GETUPVAL`` and ``SETUPVAL``, while the management of upvalues is handled by the virtual machine itself.

Line [2] in function ``b`` sets upvalue a (upvalue number 0 in the upvalue table) to a number value of ``1`` (held in temporary register ``0``.) In line [3], the value in upvalue ``a`` is retrieved and placed into register ``0``, where the following ``RETURN`` instruction will use it as a return value. The ``RETURN`` in line [5] is unused.



OP_NEWTABLE instruction
=======================

Syntax
------

::

  NEWTABLE A B C   R(A) := {} (size = B,C)

Description
-----------
Creates a new empty table at register R(A). B and C are the encoded size information for the 
array part and the hash part of the table, respectively. Appropriate values for B and C are set 
in order to avoid rehashing when initially populating the table with array values or hash 
key-value pairs.

Operand B and C are both encoded as a 'floating point byte' (so named in lobject.c)
which is ``eeeeexxx`` in binary, where x is the mantissa and e is the exponent. 
The actual value is calculated as ``1xxx*2^(eeeee-1)`` if ``eeeee`` is greater than ``0`` 
(a range of ``8`` to ``15*2^30``). If ``eeeee`` is ``0``, the actual value is ``xxx`` 
(a range of ``0`` to ``7``.)

If an empty table is created, both sizes are zero. If a table is created with a number of 
objects, the code generator counts the number of array elements and the number of hash elements. 
Then, each size value is rounded up and encoded in B and C using the floating point byte format.

Examples
--------
Creating an empty table forces both array and hash sizes to be zero::

  f=load('local q = {}')

Leads to::

  main <(string):0,0> (2 instructions at 0000022C1877A220)
  0+ params, 2 slots, 1 upvalue, 1 local, 0 constants, 0 functions
        1       [1]     NEWTABLE        0 0 0
        2       [1]     RETURN          0 1
  constants (0) for 0000022C1877A220:
  locals (1) for 0000022C1877A220:
        0       q       2       3
  upvalues (1) for 0000022C1877A220:
        0       _ENV    1       0

More examples are provided in the description of ``OP_SETLIST`` instruction.


OP_SETLIST instruction
======================

Syntax
------

::

  SETLIST A B C   R(A)[(C-1)*FPF+i] := R(A+i), 1 <= i <= B

Description
-----------
Sets the values for a range of array elements in a table referenced by R(A). Field B is the 
number of elements to set. Field C encodes the block number of the table to be initialized. 
The values used to initialize the table are located in registers R(A+1), R(A+2), and so on.

The block size is denoted by FPF. FPF is 'fields per flush', defined as ``LFIELDS_PER_FLUSH`` 
in the source file lopcodes.h, with a value of 50. For example, for array locations 1 to 20, 
C will be 1 and B will be 20.

If B is 0, the table is set with a variable number of array elements, from register R(A+1) 
up to the top of the stack. This happens when the last element in the table constructor is 
a function call or a vararg operator.

If C is 0, the next instruction is cast as an integer, and used as the C value. This happens 
only when operand C is unable to encode the block number, i.e. when C > 511, equivalent to an 
array index greater than 25550.

Examples
--------

We’ll start with a simple example::

  f=load('local q = {1,2,3,4,5,}')

This generates::

  main <(string):0,0> (8 instructions at 0000022C18756E50)
  0+ params, 6 slots, 1 upvalue, 1 local, 5 constants, 0 functions
        1       [1]     NEWTABLE        0 5 0
        2       [1]     LOADK           1 -1    ; 1
        3       [1]     LOADK           2 -2    ; 2
        4       [1]     LOADK           3 -3    ; 3
        5       [1]     LOADK           4 -4    ; 4
        6       [1]     LOADK           5 -5    ; 5
        7       [1]     SETLIST         0 5 1   ; 1
        8       [1]     RETURN          0 1
  constants (5) for 0000022C18756E50:
        1       1
        2       2
        3       3
        4       4
        5       5
  locals (1) for 0000022C18756E50:
        0       q       8       9
  upvalues (1) for 0000022C18756E50:
        0       _ENV    1       0

A table with the reference in register 0 is created in line [1] by NEWTABLE. Since we are 
creating a table with no hash elements, the array part of the table has a size of 5, 
while the hash part has a size of 0.

Constants are then loaded into temporary registers 1 to 5 (lines [2] to [6]) before the SETLIST 
instruction in line [7] assigns each value to consecutive table elements. The start of the 
block is encoded as 1 in operand C. The starting index is calculated as (1-1)*50+1 or 1. 
Since B is 5, the range of the array elements to be set becomes 1 to 5, while the objects used 
to set the array elements will be R(1) through R(5).

Next is a larger table with 55 array elements. This will require two blocks to initialize. 
Some lines have been removed and ellipsis (...) added to save space::

> f=load('local q = {1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0, \
>> 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0, \
>> 1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,}')

The generated code is::

  main <(string):0,0> (59 instructions at 0000022C187833C0)
  0+ params, 51 slots, 1 upvalue, 1 local, 10 constants, 0 functions
        1       [1]     NEWTABLE        0 30 0
        2       [1]     LOADK           1 -1    ; 1
        3       [1]     LOADK           2 -2    ; 2
        4       [1]     LOADK           3 -3    ; 3
        ...
        51      [3]     LOADK           50 -10  ; 0
        52      [3]     SETLIST         0 50 1  ; 1
        53      [3]     LOADK           1 -1    ; 1
        54      [3]     LOADK           2 -2    ; 2
        55      [3]     LOADK           3 -3    ; 3
        56      [3]     LOADK           4 -4    ; 4
        57      [3]     LOADK           5 -5    ; 5
        58      [3]     SETLIST         0 5 2   ; 2
        59      [3]     RETURN          0 1
  constants (10) for 0000022C187833C0:
        1       1
        2       2
        3       3
        4       4
        5       5
        6       6
        7       7
        8       8
        9       9
        10      0
  locals (1) for 0000022C187833C0:
        0       q       59      60
  upvalues (1) for 0000022C187833C0:
        0       _ENV    1       0        

Since FPF is 50, the array will be initialized in two blocks. The first block is 
for index 1 to 50, while the second block is for index 51 to 55. Each array block to be 
initialized requires one ``SETLIST`` instruction. On line [1], ``NEWTABLE`` has a field 
B value of 30, or 00011110 in binary. From the description of ``NEWTABLE``, ``xxx`` is ``1102``, 
while ``eeeee`` is ``112``. Thus, the size of the array portion of the table is ``(1110)*2^(11-1)`` 
or ``(14*2^2)`` or ``56``. 

Lines [2] to [51] sets the values used to initialize the first block. On line [52], 
``SETLIST`` has a B value of 50 and a C value of 1. So the block is from 1 to 50. 
Source registers are from R(1) to R(50). 

Lines [53] to [57] sets the values used to initialize the second block. On line [58], 
``SETLIST`` has a B value of 5 and a C value of 2. So the block is from 51 to 55. 
The start of the block is calculated as ``(2-1)*50+1`` or ``51``. Source registers are 
from R(1) to R(5).

Here is a table with hashed elements::

  > f=load('local q = {a=1,b=2,c=3,d=4,e=5,f=6,g=7,h=8,}')

This results in::

  main <(string):0,0> (10 instructions at 0000022C18783D20)
  0+ params, 2 slots, 1 upvalue, 1 local, 16 constants, 0 functions
        1       [1]     NEWTABLE        0 0 8
        2       [1]     SETTABLE        0 -1 -2 ; "a" 1
        3       [1]     SETTABLE        0 -3 -4 ; "b" 2
        4       [1]     SETTABLE        0 -5 -6 ; "c" 3
        5       [1]     SETTABLE        0 -7 -8 ; "d" 4
        6       [1]     SETTABLE        0 -9 -10        ; "e" 5
        7       [1]     SETTABLE        0 -11 -12       ; "f" 6
        8       [1]     SETTABLE        0 -13 -14       ; "g" 7
        9       [1]     SETTABLE        0 -15 -16       ; "h" 8
        10      [1]     RETURN          0 1
  constants (16) for 0000022C18783D20:
        1       "a"
        2       1
        3       "b"
        4       2
        5       "c"
        6       3
        7       "d"
        8       4
        9       "e"
        10      5
        11      "f"
        12      6
        13      "g"
        14      7
        15      "h"
        16      8
  locals (1) for 0000022C18783D20:
        0       q       10      11
  upvalues (1) for 0000022C18783D20:
        0       _ENV    1       0

In line [1], ``NEWTABLE`` is executed with an array part size of 0 and a hash part size of 8. 

On lines [2] to line [9], key-value pairs are set using ``SETTABLE``. The ``SETLIST`` instruction 
is only for initializing array elements. Using ``SETTABLE`` to initialize the key-value pairs of 
a table in the above example is quite efficient as it can reference the constant pool directly.

If there are both array elements and hash elements in a table constructor, both ``SETTABLE`` 
and ``SETLIST`` will be used to initialize the table after the initial ``NEWTABLE``. In addition, 
if the last element of the table constructor is a function call or a vararg operator, then the 
B operand of ``SETLIST`` will be 0, to allow objects from R(A+1) up to the top of the stack 
to be initialized as array elements of the table.

::

  > f=load('return {1,2,3,a=1,b=2,c=3,foo()}')

Leads to::

  main <(string):0,0> (12 instructions at 0000022C18788430)
  0+ params, 5 slots, 1 upvalue, 0 locals, 7 constants, 0 functions
        1       [1]     NEWTABLE        0 3 3
        2       [1]     LOADK           1 -1    ; 1
        3       [1]     LOADK           2 -2    ; 2
        4       [1]     LOADK           3 -3    ; 3
        5       [1]     SETTABLE        0 -4 -1 ; "a" 1
        6       [1]     SETTABLE        0 -5 -2 ; "b" 2
        7       [1]     SETTABLE        0 -6 -3 ; "c" 3
        8       [1]     GETTABUP        4 0 -7  ; _ENV "foo"
        9       [1]     CALL            4 1 0
        10      [1]     SETLIST         0 0 1   ; 1
        11      [1]     RETURN          0 2
        12      [1]     RETURN          0 1
  constants (7) for 0000022C18788430:
        1       1
        2       2
        3       3
        4       "a"
        5       "b"
        6       "c"
        7       "foo"
  locals (0) for 0000022C18788430:
  upvalues (1) for 0000022C18788430:
        0       _ENV    1       0

In the above example, the table is first created in line [1] with its reference 
in register 0, and it has both array and hash elements to be set. The size of the 
array part is 3 while the size of the hash part is also 3.

Lines [2]–[4] loads the values for the first 3 array elements. Lines [5]–[7] set 
the 3 key-value pairs for the hash part of the table. In lines [8] and [9], 
the call to function ``foo`` is made, and then in line [10], the ``SETLIST`` instruction sets 
the first 3 array elements (in registers 1 to 3) plus whatever additional results 
returned by the ``foo`` function call (from register 4 onwards). This is accomplished by 
setting operand B in ``SETLIST`` to 0. For the first block, operand C is 1 as usual. 
If no results are returned by the function, the top of stack is at register 3 
and only the 3 constant array elements in the table are set.

Finally::

  > f=load('local a; return {a(), a(), a()}')

This gives::

  main <(string):0,0> (11 instructions at 0000022C18787AD0)
  0+ params, 5 slots, 1 upvalue, 1 local, 0 constants, 0 functions
        1       [1]     LOADNIL         0 0
        2       [1]     NEWTABLE        1 2 0
        3       [1]     MOVE            2 0
        4       [1]     CALL            2 1 2
        5       [1]     MOVE            3 0
        6       [1]     CALL            3 1 2
        7       [1]     MOVE            4 0
        8       [1]     CALL            4 1 0
        9       [1]     SETLIST         1 0 1   ; 1
        10      [1]     RETURN          1 2
        11      [1]     RETURN          0 1
  constants (0) for 0000022C18787AD0:
  locals (1) for 0000022C18787AD0:
        0       a       2       12
  upvalues (1) for 0000022C18787AD0:
        0       _ENV    1       0

Note that only the last function call in a table constructor retains all results. 
Other function calls in the table constructor keep only one result. This is shown in the 
above example. For vararg operators in table constructors, please see the discussion for the 
``VARARG`` instruction for an example.

OP_GETTABLE and OP_SETTABLE instructions
========================================

Syntax
------

::

  GETTABLE A B C   R(A) := R(B)[RK(C)]
  SETTABLE A B C   R(A)[RK(B)] := RK(C)

Description
-----------
``OP_GETTABLE`` copies the value from a table element into register R(A). 
The table is referenced by register R(B), while the index to the table is given 
by RK(C), which may be the value of register R(C) or a constant number.

``OP_SETTABLE`` copies the value from register R(C) or a constant into a table element. 
The table is referenced by register R(A), while the index to the table is given by 
RK(B), which may be the value of register R(B) or a constant number.

All 3 operand fields are used, and some of the operands can be constants. A 
constant is specified by setting the MSB of the operand to 1. If RK(C) need to 
refer to constant 1, the encoded value will be (256 | 1) or 257, where 256 is the 
value of bit 8 of the operand. Allowing constants to be used directly reduces 
considerably the need for temporary registers.

Examples
--------
::

  f=load('local p = {}; p[1] = "foo"; return p["bar"]')

This compiles to::

  main <(string):0,0> (5 instructions at 000001FA06FCC3F0)
  0+ params, 2 slots, 1 upvalue, 1 local, 3 constants, 0 functions
        1       [1]     NEWTABLE        0 0 0
        2       [1]     SETTABLE        0 -1 -2 ; 1 "foo"
        3       [1]     GETTABLE        1 0 -3  ; "bar"
        4       [1]     RETURN          1 2
        5       [1]     RETURN          0 1
  constants (3) for 000001FA06FCC3F0:
        1       1
        2       "foo"
        3       "bar"
  locals (1) for 000001FA06FCC3F0:
        0       p       2       6
  upvalues (1) for 000001FA06FCC3F0:
        0       _ENV    1       0

In line [1], a new empty table is created and the reference placed in local p (register 0). 
Creating and populating new tables is discussed in detail elsewhere.
Table index 1 is set to 'foo' in line [2] by the ``SETTABLE`` instruction. 

The R(A) value of 0 points to the new table that was defined in line [1].
In line [3], the value of the table element indexed by the string 'bar' is copied into 
temporary register 1, which is then used by RETURN as a return value. 

OP_SELF instruction
===================

Syntax
------

::

  SELF  A B C   R(A+1) := R(B); R(A) := R(B)[RK(C)]

Description
-----------
For object-oriented programming using tables. Retrieves a function reference 
from a table element and places it in register R(A), then a reference to the table 
itself is placed in the next register, R(A+1). This instruction saves some messy 
manipulation when setting up a method call.

R(B) is the register holding the reference to the table with the method. 
The method function itself is found using the table index RK(C), which may be 
the value of register R(C) or a constant number.

Examples
--------
A ``SELF`` instruction saves an extra instruction and speeds up the calling of 
methods in object oriented programming. It is only generated for method calls 
that use the colon syntax. In the following example::

  f=load('foo:bar("baz")')

We can see ``SELF`` being generated::

  main <(string):0,0> (5 instructions at 000001FA06FA7830)
  0+ params, 3 slots, 1 upvalue, 0 locals, 3 constants, 0 functions
        1       [1]     GETTABUP        0 0 -1  ; _ENV "foo"
        2       [1]     SELF            0 0 -2  ; "bar"
        3       [1]     LOADK           2 -3    ; "baz"
        4       [1]     CALL            0 3 1
        5       [1]     RETURN          0 1
  constants (3) for 000001FA06FA7830:
        1       "foo"
        2       "bar"
        3       "baz"
  locals (0) for 000001FA06FA7830:
  upvalues (1) for 000001FA06FA7830:
        0       _ENV    1       0

The method call is equivalent to: ``foo.bar(foo, "baz")``, except that the global ``foo`` 
is only looked up once. This is significant if metamethods have been set. The ``SELF`` in 
line [2] is equivalent to a ``GETTABLE`` lookup (the table is in register 0 and the 
index is constant 1) and a ``MOVE`` (copying the table reference from register 0 to 
register 1.)

Without ``SELF``, a ``GETTABLE`` will write its lookup result to register 0 (which the 
code generator will normally do) and the table reference will be overwritten before a ``MOVE`` 
can be done. Using ``SELF`` saves roughly one instruction and one temporary register slot.

After setting up the method call using ``SELF``, the call is made with the usual ``CALL`` 
instruction in line [4], with two parameters. The equivalent code for a method lookup is 
compiled in the following manner::

  f=load('foo.bar(foo, "baz")')

And generated code::

  main <(string):0,0> (6 instructions at 000001FA06FA6960)
  0+ params, 3 slots, 1 upvalue, 0 locals, 3 constants, 0 functions
        1       [1]     GETTABUP        0 0 -1  ; _ENV "foo"
        2       [1]     GETTABLE        0 0 -2  ; "bar"
        3       [1]     GETTABUP        1 0 -1  ; _ENV "foo"
        4       [1]     LOADK           2 -3    ; "baz"
        5       [1]     CALL            0 3 1
        6       [1]     RETURN          0 1
  constants (3) for 000001FA06FA6960:
        1       "foo"
        2       "bar"
        3       "baz"
  locals (0) for 000001FA06FA6960:
  upvalues (1) for 000001FA06FA6960:
        0       _ENV    1       0

The alternative form of a method call is one instruction longer, and the user 
must take note of any metamethods that may affect the call. The ``SELF`` in the previous example 
replaces the ``GETTABLE`` on line [2] and the ``GETTABUP`` on line [3]. If ``foo`` is a local variable, 
then the equivalent code is a ``GETTABLE`` and a ``MOVE``.

OP_GETTABUP and OP_SETTABUP instructions
========================================

Syntax
------

::

  GETTABUP A B C   R(A) := UpValue[B][RK(C)]
  SETTABUP A B C   UpValue[A][RK(B)] := RK(C)

Description
-----------
``OP_GETTABUP`` and ``OP_SETTABUP`` instructions are similar to the 
``OP_GETTABLE`` and ``OP_SETTABLE`` instructions except that the table
is referenced as an upvalue. These instructions are used to access global
variables, which since Lua 5.2 are accessed via the upvalue named ``_ENV``.

Examples
--------
::

  f=load('a = 40; local b = a')

Results in::

  main <(string):0,0> (3 instructions at 0000028D955FEBF0)
  0+ params, 2 slots, 1 upvalue, 1 local, 2 constants, 0 functions
        1       [1]     SETTABUP        0 -1 -2 ; _ENV "a" 40
        2       [1]     GETTABUP        0 0 -1  ; _ENV "a"
        3       [1]     RETURN          0 1
  constants (2) for 0000028D955FEBF0:
        1       "a"
        2       40
  locals (1) for 0000028D955FEBF0:
        0       b       3       4
  upvalues (1) for 0000028D955FEBF0:
        0       _ENV    1       0

From the example, we can see that 'b' is the name of the local variable 
while 'a' is the name of the global variable. 

Line [1] assigns the number 40 to global 'a'. Line [2] assigns the value in global 'a' 
to the register 0 which is the local 'b'.

OP_CONCAT instruction
=====================

Syntax
------

::

  CONCAT A B C   R(A) := R(B).. ... ..R(C)

Description
-----------
Performs concatenation of two or more strings. In a Lua source, this is equivalent 
to one or more concatenation operators ('..') between two or more expressions. 
The source registers must be consecutive, and C must always be greater than B. 
The result is placed in R(A).

Examples
--------
``CONCAT`` accepts a range of registers. Doing more than one string concatenation 
at a time is faster and more efficient than doing them separately::

  f=load('local x,y = "foo","bar"; return x..y..x..y')

Generates::

  main <(string):0,0> (9 instructions at 0000028D9560B290)
  0+ params, 6 slots, 1 upvalue, 2 locals, 2 constants, 0 functions
        1       [1]     LOADK           0 -1    ; "foo"
        2       [1]     LOADK           1 -2    ; "bar"
        3       [1]     MOVE            2 0
        4       [1]     MOVE            3 1
        5       [1]     MOVE            4 0
        6       [1]     MOVE            5 1
        7       [1]     CONCAT          2 2 5
        8       [1]     RETURN          2 2
        9       [1]     RETURN          0 1
  constants (2) for 0000028D9560B290:
        1       "foo"
        2       "bar"
  locals (2) for 0000028D9560B290:
        0       x       3       10
        1       y       3       10
  upvalues (1) for 0000028D9560B290:
        0       _ENV    1       0

In this example, strings are moved into place first (lines [3] to [6]) in 
the concatenation order before a single ``CONCAT`` instruction is executed 
in line [7]. The result is left in temporary local 2, which is then used as 
a return value by the ``RETURN`` instruction on line [8].

::

  f=load('local a = "foo".."bar".."baz"')

Compiles to::

  main <(string):0,0> (5 instructions at 0000028D9560EE40)
  0+ params, 3 slots, 1 upvalue, 1 local, 3 constants, 0 functions
        1       [1]     LOADK           0 -1    ; "foo"
        2       [1]     LOADK           1 -2    ; "bar"
        3       [1]     LOADK           2 -3    ; "baz"
        4       [1]     CONCAT          0 0 2
        5       [1]     RETURN          0 1
  constants (3) for 0000028D9560EE40:
        1       "foo"
        2       "bar"
        3       "baz"
  locals (1) for 0000028D9560EE40:
        0       a       5       6
  upvalues (1) for 0000028D9560EE40:
        0       _ENV    1       0

In the second example, three strings are concatenated together. Note that 
there is no string constant folding. Lines [1] through [3] loads the three 
constants in the correct order for concatenation; the ``CONCAT`` on line [4] 
performs the concatenation itself and assigns the result to local 'a'.

OP_LEN instruction
==================

Syntax
------

::

  LEN A B     R(A) := length of R(B)

Description
-----------
Returns the length of the object in R(B). For strings, the string length is 
returned, while for tables, the table size (as defined in Lua) is returned. 
For other objects, the metamethod is called. The result, which is a number, 
is placed in R(A).

Examples
--------

The ``LEN`` operation implements the # operator. If # operates on a constant,
then the constant is loaded in advance using ``LOADK``. The ``LEN`` instruction 
is currently not optimized away using compile time evaluation, even if it is 
operating on a constant string or table::

  f=load('local a,b; a = #b; a= #"foo"')

Results in::

  main <(string):0,0> (5 instructions at 000001DC21778C60)
  0+ params, 3 slots, 1 upvalue, 2 locals, 1 constant, 0 functions
        1       [1]     LOADNIL         0 1
        2       [1]     LEN             0 1
        3       [1]     LOADK           2 -1    ; "foo"
        4       [1]     LEN             0 2
        5       [1]     RETURN          0 1
  constants (1) for 000001DC21778C60:
        1       "foo"
  locals (2) for 000001DC21778C60:
        0       a       2       6
        1       b       2       6
  upvalues (1) for 000001DC21778C60:
        0       _ENV    1       0

In the above example, ``LEN`` operates on local b in line [2], leaving the result in 
local a. Since ``LEN`` cannot operate directly on constants, line [3] first loads the 
constant “foo” into a temporary local, and only then ``LEN`` is executed.

OP_MOVE instruction
===================

Syntax
------

::

  MOVE A B     R(A) := R(B)

Description
-----------
Copies the value of register R(B) into register R(A). If R(B) holds a table, 
function or userdata, then the reference to that object is copied. ``MOVE`` is often used 
for moving values into place for the next operation.

Examples
--------
The most straightforward use of MOVE is for assigning a local to another local::

  f=load('local a,b = 10; b = a')

Produces::

  main <(string):0,0> (4 instructions at 000001DC217566D0)
  0+ params, 2 slots, 1 upvalue, 2 locals, 1 constant, 0 functions
        1       [1]     LOADK           0 -1    ; 10
        2       [1]     LOADNIL         1 0
        3       [1]     MOVE            1 0
        4       [1]     RETURN          0 1
  constants (1) for 000001DC217566D0:
        1       10
  locals (2) for 000001DC217566D0:
        0       a       3       5
        1       b       3       5
  upvalues (1) for 000001DC217566D0:
        0       _ENV    1       0

You won’t see ``MOVE`` instructions used in arithmetic expressions 
because they are not needed by arithmetic operators. All arithmetic operators are 
in 2- or 3-operand style: the entire local stack frame is already visible 
to operands R(A), R(B) and R(C) so there is no need for any extra 
``MOVE`` instructions.

Other places where you will see ``MOVE`` are:

* When moving parameters into place for a function call.
* When moving values into place for certain instructions where stack order is important, e.g. ``GETTABLE``, ``SETTABLE`` and ``CONCAT``.
* When copying return values into locals after a function call.

OP_LOADNIL instruction
======================

Syntax
------

::
 
  LOADNIL A B     R(A), R(A+1), ..., R(A+B) := nil

Description
-----------
Sets a range of registers from R(A) to R(B) to nil. If a single register is to 
be assigned to, then R(A) = R(B). When two or more consecutive locals need to 
be assigned nil values, only a single ``LOADNIL`` is needed.

Examples
--------
``LOADNIL`` uses the operands A and B to mean a range of register locations. 
The example for ``MOVE`` earlier shows ``LOADNIL`` used to set a single register to ``nil``.

::

  f=load('local a,b,c,d,e = nil,nil,0')

Generates::

  main <(string):0,0> (4 instructions at 000001DC21780390)
  0+ params, 5 slots, 1 upvalue, 5 locals, 1 constant, 0 functions
        1       [1]     LOADNIL         0 1
        2       [1]     LOADK           2 -1    ; 0
        3       [1]     LOADNIL         3 1
        4       [1]     RETURN          0 1
  constants (1) for 000001DC21780390:
        1       0
  locals (5) for 000001DC21780390:
        0       a       4       5
        1       b       4       5
        2       c       4       5
        3       d       4       5
        4       e       4       5
  upvalues (1) for 000001DC21780390:
        0       _ENV    1       0

Line [1] nils locals a and b.  
Local c is explicitly initialized with the value 0. 
Line [3] nils d and e.


OP_LOADK instruction
====================
Syntax
------

::
  
  LOADK A Bx    R(A) := Kst(Bx)

Description
-----------
Loads constant number Bx into register R(A). Constants are usually numbers 
or strings. Each function prototype has its own constant list, or pool.

Examples
--------
``LOADK`` loads a constant from the constant list into a register or local. 
Constants are indexed starting from 0. Some instructions, such as arithmetic 
instructions, can use the constant list without needing a ``LOADK``. 
Constants are pooled in the list, duplicates are eliminated. The list can 
hold nils, booleans, numbers or strings.

::
  
  f=load('local a,b,c,d = 3,"foo",3,"foo"')


Leads to::

  main <(string):0,0> (5 instructions at 000001DC21780B50)
  0+ params, 4 slots, 1 upvalue, 4 locals, 2 constants, 0 functions
        1       [1]     LOADK           0 -1    ; 3
        2       [1]     LOADK           1 -2    ; "foo"
        3       [1]     LOADK           2 -1    ; 3
        4       [1]     LOADK           3 -2    ; "foo"
        5       [1]     RETURN          0 1
  constants (2) for 000001DC21780B50:
        1       3
        2       "foo"
  locals (4) for 000001DC21780B50:
        0       a       5       6
        1       b       5       6
        2       c       5       6
        3       d       5       6
  upvalues (1) for 000001DC21780B50:
        0       _ENV    1       0

The constant 3 and the constant “foo” are both written twice in the source 
snippet, but in the constant list, each constant has a single location. 


Binary operators
================
Lua 5.3 implements a bunch of binary operators for arithmetic and bitwise
manipulation of variables. These insructions have a common form.

Syntax
------

::

  ADD   A B C   R(A) := RK(B) + RK(C)
  SUB   A B C   R(A) := RK(B) - RK(C)
  MUL   A B C   R(A) := RK(B) * RK(C)
  MOD   A B C   R(A) := RK(B) % RK(C)
  POW   A B C   R(A) := RK(B) ^ RK(C)
  DIV   A B C   R(A) := RK(B) / RK(C)
  IDIV  A B C   R(A) := RK(B) // RK(C)
  BAND  A B C   R(A) := RK(B) & RK(C)
  BOR   A B C   R(A) := RK(B) | RK(C)
  BXOR  A B C   R(A) := RK(B) ~ RK(C)
  SHL   A B C   R(A) := RK(B) << RK(C)
  SHR   A B C   R(A) := RK(B) >> RK(C)

Description
-----------
Binary operators (arithmetic operators and bitwise operators with two inputs.) 
The result of the operation between RK(B) and RK(C) is placed into R(A). 
These instructions are in the classic 3-register style. 

RK(B) and RK(C) may be either registers or constants in the constant pool.

+------------+-------------------------------------------------------------+
| Opcode     | Description                                                 |
+============+=============================================================+
| ADD        | Addition operator                                           |
+------------+-------------------------------------------------------------+
| SUB        | Subtraction operator                                        |
+------------+-------------------------------------------------------------+
| MUL        | Multiplication operator                                     |
+------------+-------------------------------------------------------------+
| MOD        | Modulus (remainder) operator                                |
+------------+-------------------------------------------------------------+
| POW        | Exponentation operator                                      |
+------------+-------------------------------------------------------------+
| DIV        | Division operator                                           |
+------------+-------------------------------------------------------------+
| IDIV       | Integer division operator                                   |
+------------+-------------------------------------------------------------+
| BAND       | Bit-wise AND operator                                       |
+------------+-------------------------------------------------------------+
| BOR        | Bit-wise OR operator                                        |
+------------+-------------------------------------------------------------+
| BXOR       | Bit-wise Exclusive OR operator                              |
+------------+-------------------------------------------------------------+
| SHL        | Shift bits left                                             |
+------------+-------------------------------------------------------------+
| SHR        | Shift bits right                                            |
+------------+-------------------------------------------------------------+

The source operands, RK(B) and RK(C), may be constants. If a constant is out 
of range of field B or field C, then the constant will be loaded into a 
temporary register in advance.

Examples
--------

::

  f=load('local a,b = 2,4; a = a + 4 * b - a / 2 ^ b % 3')

Generates::

  main <(string):0,0> (9 instructions at 000001DC21781DD0)
  0+ params, 4 slots, 1 upvalue, 2 locals, 3 constants, 0 functions
        1       [1]     LOADK           0 -1    ; 2
        2       [1]     LOADK           1 -2    ; 4
        3       [1]     MUL             2 -2 1  ; 4 -      (loc2 = 4 * b)
        4       [1]     ADD             2 0 2              (loc2 = A + loc2) 
        5       [1]     POW             3 -1 1  ; 2 -      (loc3 = 2 ^ b) 
        6       [1]     DIV             3 0 3              (loc3 = a / loc3) 
        7       [1]     MOD             3 3 -3             (loc3 = loc3 % 3) 
        8       [1]     SUB             0 2 3              (a = loc2 – loc3) 
        9       [1]     RETURN          0 1
  constants (3) for 000001DC21781DD0:
        1       2
        2       4
        3       3
  locals (2) for 000001DC21781DD0:
        0       a       3       10
        1       b       3       10
  upvalues (1) for 000001DC21781DD0:
        0       _ENV    1       0

In the disassembly shown above, parts of the expression is shown as additional 
comments in parentheses. Each arithmetic operator translates into a single instruction.
This also means that while the statement ``count = count + 1`` is verbose, it translates 
into a single instruction if count is a local. If count is a global, then two 
extra instructions are required to read and write to the global (``GETTABUP`` and ``SETTABUP``), 
since arithmetic operations can only be done on registers (locals) only.

The Lua parser and code generator can perform limited constant expression folding 
or evaluation. Constant folding only works for binary arithmetic operators and the unary 
minus operator (``UNM``, which will be covered next.) There is no equivalent 
optimization for relational, boolean or string operators.

The optimization rule is simple: If both terms of a subexpression are numbers, the 
subexpression will be evaluated at compile time. However, there are exceptions. 
One, the code generator will not attempt to divide a number by 0 for DIV and MOD, 
and two, if the result is evaluated as a NaN (Not a Number) then the optimization 
will not be performed.

Also, constant folding is not done if one term is in the form of a string that need 
to be coerced. In addition, expression terms are not rearranged, so not all optimization 
opportunities can be recognized by the code generator. This is intentional; the Lua 
code generator is not meant to perform heavy duty optimizations, as Lua is a lightweight 
language. Here are a few examples to illustrate how it works (additional comments 
in parentheses)::

  f=load('local a = 4 + 7 + b; a = b + 4 * 7; a = b + 4 + 7')

Generates::

  main <(string):0,0> (8 instructions at 000001DC21781650)
  0+ params, 2 slots, 1 upvalue, 1 local, 5 constants, 0 functions
        1       [1]     GETTABUP        0 0 -1  ; _ENV "b"
        2       [1]     ADD             0 -2 0  ; 11 -            (a = 11 + b) 
        3       [1]     GETTABUP        1 0 -1  ; _ENV "b"
        4       [1]     ADD             0 1 -3  ; - 28            (a = b + 28) 
        5       [1]     GETTABUP        1 0 -1  ; _ENV "b"
        6       [1]     ADD             1 1 -4  ; - 4             (loc1 = b + 4) 
        7       [1]     ADD             0 1 -5  ; - 7             (a = loc1 + 7) 
        8       [1]     RETURN          0 1
  constants (5) for 000001DC21781650:
        1       "b"
        2       11
        3       28
        4       4
        5       7
  locals (1) for 000001DC21781650:
        0       a       3       9
  upvalues (1) for 000001DC21781650:
        0       _ENV    1       0

For the first assignment statement, ``4+7`` is evaluated, thus 11 is added to b in line [2]. 
Next, in line [3] and [4], ``b`` and ``28`` are added together and assigned to a because multiplication 
has a higher precedence and ``4*7`` is evaluated first. Finally, on lines [5] to [7], 
there are two addition operations. Since addition is left-associative, code is generated for 
``b+4`` first, and only after that, ``7`` is added. So in the third example, 
Lua performs no optimization. This can be fixed using parentheses to explicitly change the precedence 
of a subexpression::

  f=load('local a = b + (4 + 7)')

And this leads to::

  main <(string):0,0> (3 instructions at 000001DC21781EC0)
  0+ params, 2 slots, 1 upvalue, 1 local, 2 constants, 0 functions
        1       [1]     GETTABUP        0 0 -1  ; _ENV "b"
        2       [1]     ADD             0 0 -2  ; - 11
        3       [1]     RETURN          0 1
  constants (2) for 000001DC21781EC0:
        1       "b"
        2       11
  locals (1) for 000001DC21781EC0:
        0       a       3       4
  upvalues (1) for 000001DC21781EC0:
        0       _ENV    1       0

Now, the ``4+7`` subexpression can be evaluated at compile time. If the 
statement is written as::

  local a = 7 + (4 + 7)

the code generator will generate a single ``LOADK`` instruction; Lua first evaluates 
``4+7``, then ``7`` is added, giving a total of ``18``. The arithmetic expression is completely 
evaluated in this case, thus no arithmetic instructions are generated.

In order to make full use of constant folding in Lua, the user just need to remember 
the usual order of evaluation of an expression’s elements and apply parentheses where 
necessary. The following are two expressions which will not be evaluated at compile time::

  f=load('local a = 1 / 0; local b = 1 + "1"')

This produces::

  main <(string):0,0> (3 instructions at 000001DC21781380)
  0+ params, 2 slots, 1 upvalue, 2 locals, 3 constants, 0 functions
        1       [1]     DIV             0 -2 -1 ; 1 0
        2       [1]     ADD             1 -2 -3 ; 1 "1"
        3       [1]     RETURN          0 1
  constants (3) for 000001DC21781380:
        1       0
        2       1
        3       "1"
  locals (2) for 000001DC21781380:
        0       a       2       4
        1       b       3       4
  upvalues (1) for 000001DC21781380:
        0       _ENV    1       0

The first is due to a divide-by-0, while the second is due to a string 
constant that needs to be coerced into a number. In both cases, constant folding is 
not performed, so the arithmetic instructions needed to perform the operations 
at run time are generated instead.

TODO - examples of bitwise operators.

Unary operators
===============
Lua 5.3 implements following unary operators in addition to ``OP_LEN``.

Syntax
------

::

  UNM   A B     R(A) := -R(B)
  BNOT  A B     R(A) := ~R(B)
  NOT   A B     R(A) := not R(B)

Description
-----------
The unary operators perform an operation on R(B) and store the result in
R(A).

+------------+-------------------------------------------------------------+
| Opcode     | Description                                                 |
+============+=============================================================+
| UNM        | Unary minus                                                 |
+------------+-------------------------------------------------------------+
| BNOT       | Bit-wise NOT operator                                       |
+------------+-------------------------------------------------------------+
| NOT        | Logical NOT operator                                        |
+------------+-------------------------------------------------------------+

Examples
--------

::

  f=load('local p,q = 10,false; q,p = -p,not q')

Results in::

  main <(string):0,0> (6 instructions at 000001DC21781290)
  0+ params, 3 slots, 1 upvalue, 2 locals, 1 constant, 0 functions
        1       [1]     LOADK           0 -1    ; 10
        2       [1]     LOADBOOL        1 0 0
        3       [1]     UNM             2 0
        4       [1]     NOT             0 1
        5       [1]     MOVE            1 2
        6       [1]     RETURN          0 1
  constants (1) for 000001DC21781290:
        1       10
  locals (2) for 000001DC21781290:
        0       p       3       7
        1       q       3       7
  upvalues (1) for 000001DC21781290:
        0       _ENV    1       0

As ``UNM`` and ``NOT`` do not accept a constant as a source operand, making the 
``LOADK`` on line [1] and the ``LOADBOOL`` on line [2] necessary. When an unary minus 
is applied to a constant number, the unary minus is optimized away. Similarly, when a 
not is applied to true or false, the logical operation is optimized away.

In addition to this, constant folding is performed for unary minus, if the term is 
a number. So, the expression in the following is completely evaluated at compile time::

  f=load('local a = - (7 / 4)')

Results in::

  main <(string):0,0> (2 instructions at 000001DC217810B0)
  0+ params, 2 slots, 1 upvalue, 1 local, 1 constant, 0 functions
        1       [1]     LOADK           0 -1    ; -1.75
        2       [1]     RETURN          0 1
  constants (1) for 000001DC217810B0:
        1       -1.75
  locals (1) for 000001DC217810B0:
        0       a       2       3
  upvalues (1) for 000001DC217810B0:
        0       _ENV    1       0

Constant folding is performed on ``7/4`` first. Then, since the unary minus 
operator is applied to the constant ``1.75``, constant folding can be performed 
again, and the code generated becomes a simple ``LOADK`` (on line [1]).

TODO - example of ``BNOT``.
