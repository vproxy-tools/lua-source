f = compiler.load("return 1, 'hello', 5.6, true")
assert(f and type(f) == 'function')
local x = 4.3
local a,b,c,d,e = f()
assert(a == 1)
assert(b == 'hello')
assert(c == 5.6)
assert(d == true)
assert(x == 4.3)
assert(e == nil)
print 'Ok'