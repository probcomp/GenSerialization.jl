using Gen
using GenSerialization

@gen function A(n::Int)
    a ~ bernoulli(1/n)
end
@gen function B(n::Int)
    b ~ bernoulli(1 - 1/n)
end
ab = Switch(A, B)

tr = simulate(ab, (1,4))