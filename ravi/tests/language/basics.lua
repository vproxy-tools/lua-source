-- TEST OP_RETURN
x=function() return; end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(not x())
print('test OP_RETURN ok')

-- TEST OP_RETURN and OP_LOADK
x=function() return 42; end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x() == 42)
print('test OP_RETURN, OP_LOADK ok')

-- Test OP_RETURN, OP_LOADK, OP_MOVE
-- OP_RAVI_FORPREP_I1, OP_RAVI_FORLOOP_I1
x=function() 
  local j = 0
  for i=1,1234 do
    j = i
  end
  return j
end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x() == 1234)
print('test OP_MOVE, OP_RAVI_FORPREP_I1, OP_RAVI_FORLOOP_I1 ok')

-- Test OP_RETURN, OP_LOADK, OP_MOVE
-- OP_RAVI_FORPREP_I1, OP_RAVI_FORLOOP_I1
-- OP_RAVI_ADDFN, OP_RAVI_LOADFZ
x=function() 
  local j:number 
  for i=1,1234 do
    j = j + 1
  end
  return j
end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x() == 1234.0)
print('test 4 ok')

-- Test OP_CALL
y=function() return x(); end
ravi.dumplua(y)
assert(ravi.compile(y))
assert(y() == 1234.0)
print('test 5 ok')

-- Test OP_EQ
x=function(a,b)
  if a == b then 
    return "foo" 
  else 
    return "bar" 
  end
end

ravi.dumplua(x)
assert(ravi.compile(x))
assert(x(1,1) == "foo")
assert(x(1,2) == "bar")
print('test 6 ok')

-- Test OP_EQ
x=function(a,b)
  if a ~= b then 
    return "foo" 
  else 
    return "bar" 
  end
end

ravi.dumplua(x)
assert(ravi.compile(x))
assert(x(1,1) == "bar")
assert(x(1,2) == "foo")
print('test 7 ok')

-- Test OP_LOADBOOL
function x() return not nil; end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x())
print('test 8 Ok')


-- Test OP_LOADBOOL
function x() return not 1; end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(not x())
print('test 9 Ok')

-- test 8
x = function ()
  if 1 == 2 then
    return 5.0
  end
  return 1.0
end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x() == 1.0)
print("test 8 OK")

-- test 9
x = function (y)
  if y == 1 then
    return 1.0
  elseif y == 5 then
    return 2.0
  else
    return 3.0
  end
end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x(5) == 2.0)
assert(x(4) == 3.0)
print("test 9 OK")

-- test 10
x = function (y,z)
  if y == 1 then
    if z == 1 then
      return 99.0
    else
      return z
    end
  elseif y == 5 then
    return 2.0
  else
    return 3.0
  end
end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x(1,1) == 99.0)
assert(x(1,2) == 2)
assert(x(1,5.3) == 5.3)
assert(x(5) == 2.0)
assert(x(4) == 3.0)
print("test 10 OK")


-- test 16
function tryme(x,y)
  if x < y then
    return 1
  else
    return 0
  end
end
ravi.dumplua(tryme)
assert(ravi.compile(tryme))
assert(tryme(1,2) == 1)
assert(tryme(2,1) == 0)
print("test 16 OK")

-- test 17
function tryme(x,y)
  return x < y
end
ravi.dumplua(tryme)
assert(ravi.compile(tryme))
assert(tryme(1,2))
assert(not tryme(2,1))
print("test 17 OK")

-- test 19
function optest()
  local a,b,c = 1, 5
  c = a and b
  return c
end
ravi.dumplua(optest)
assert(ravi.compile(optest))
-- ravi.dumpllvm(optest)
assert(optest() == 5)
print("test 19 OK")

-- test 20
function optest()
  local a,b,c = 1, 5
  c = a or b
  return c
end
ravi.dumplua(optest)
assert(ravi.compile(optest))
-- ravi.dumpllvm(optest)
assert(optest() == 1)
print("test 20 OK")

-- test 21
function optest()
  local a,b = 1, 5
  if a and b then
    return b
  end
  return a
end
ravi.dumplua(optest)
assert(ravi.compile(optest))
-- ravi.dumpllvm(optest)
assert(optest() == 5)
print("test 21 OK")

-- test 22
function optest()
  local a,b = nil, 5
  if a or b then
    return b
  end
  return a
end
ravi.dumplua(optest)
assert(ravi.compile(optest))
-- ravi.dumpllvm(optest)
assert(optest() == 5)
print("test 22 OK")

-- test ADDFI
x=function() local i: integer = 5; local f: number=6.0; return f+i; end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x() == 11.0)
print("test ADDFI ok")

-- test ADDFF
x=function() local i: number = 5.0; local f: number=6.0; return f+i; end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x() == 11.0)
print("test ADDFF ok")

-- test ADDII
x=function() local i: integer = 5; local f: integer=6; return f+i; end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x() == 11)
print("test ADDII ok")

-- test ADDIN
x=function() local i: integer = 42; return i+2; end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x() == 44)
print("test ADDIN ok")

-- test SUBFF
x=function() local a: number, b:number = 42.5, 32.5; return a-b; end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x() == 10.0)
print("test SUBFF ok")

-- test SUBFI
x=function() local a: number, b:integer = 42.5, 5; return a-b; end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x() == 37.5)
print("test SUBFI ok")

-- test SUBIF
x=function() local a: number, b:integer = 42.5, 5; return b-a; end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x() == -37.5)
print("test SUBIF ok")

-- test SUBII
x=function() local a: integer, b:integer = 42, 5; return b-a; end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x() == -37)
print("test SUBII ok")

-- test SUBFN
x=function() local a: number = 42.5; return a-5; end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x() == 37.5)
print("test SUBFN ok")

-- test SUBNF
x=function() local a: number = 42.5; return 5-a; end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x() == -37.5)
print("test SUBNF ok")

-- test SUBIN
x=function() local a: integer = 42; return a-5; end
ravi.dumplua(x)
assert(ravi.compile(x))
--ravi.dumpllvm(x)
assert(x() == 37)
print("test SUBIN ok")

-- test SUBNI
x=function() local a: integer = 42; return 5-a; end
ravi.dumplua(x)
assert(ravi.compile(x))
assert(x() == -37)
print("test SUBNI ok")
