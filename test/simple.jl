using Gen
using GenSerialization

@gen function submodel(x::Int)
    subchoice ~ bernoulli(0.5)
end
@gen function model(x::Int)
    joe ~ normal(0, 1)
    {:mama=>:ugly} ~ normal(0, 1)
    q ~ submodel(3)
    joe
end

tr = simulate(model, (1,))
serialize("test.gen", tr)
recovered_tr = realize("test.gen", model)