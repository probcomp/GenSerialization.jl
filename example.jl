using Gen
using GenSerialization
using BenchmarkTools

@gen function slow(n::Int)
    sleep(n)
    subchoice ~ normal(0,0.5)
    return 1
end

@gen function model(n::Int)
    x ~ bernoulli(0.5)
    y ~ slow(n)
    {:k=>1} ~ bernoulli(0.5)
    return (x,y)
end

tr = simulate(model, (1,))
serialize("test.gen", tr)
@time realized_tr = realize("test.gen", model)
@time deserialized_tr = deserialize("test.gen")

@gen function model(n::Int)
    for i=1:n
        {:k=>i} ~ mvnormal([0.0,0.0], [1.0 0.0; 0.0 1.0])
    end
    n
end
@btime simulate($model,(1000,))
tr = simulate(model, (1000,))
@btime coarse_serialize("test.gen", $tr)

@btime coarse_deserialize("test.gen")