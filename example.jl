using Gen
using GenSerialization

@gen function slow(n::Int)
    sleep(n)
    subchoice ~ normal(0,0.5)
    return 1
end

@gen function model(n::Int)
    x ~ bernoulli(0.5)
    y ~ slow(n)
    return (x,y)
end

tr = simulate(model, (10,))
serialize("test.gen", tr)
@time realized_tr = realize("test.gen", model)
@time deserialized_tr = deserialize("test.gen")