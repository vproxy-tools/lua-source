function pisum()
    local sum 
    for j = 1,500 do
        sum = 0.0
        for k = 1,10000 do
            sum = sum + 1.0/(k*k)
        end
    end
    return sum
end
t1 = os.clock()
assert(math.abs(pisum()-1.644834071848065) < 1e-12)
t2 = os.clock()
print("time taken ", t2-t1)
