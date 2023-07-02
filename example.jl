using Gen
using GenSerialization

@gen function ss()
    q ~ bernoulli(0.1)
end

@gen function slow(n::Int)
    sleep(n)
    subchoice ~ normal(0,0.5)
    q ~ ss()
    return 1
end

@gen function model(n::Int)
    x ~ bernoulli(0.5)
    y ~ slow(n)
    return (x,y)
end

tr = simulate(model, (1,))
serialize("test.gen", tr)
realized_tr = realize("test.gen", model)
deserialized_tr = deserialize("test.gen")