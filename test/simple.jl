using Gen
using GenSerialization

@gen function submodel(x::Int)
    subchoice ~ bernoulli(0.5)
end

@gen function model(x::Int)
    A = rand(1000,1000)
    joe ~ normal(0, 1)
    {:mama=>:ugly} ~ normal(0, 1)
    q ~ submodel(3)
    A
end

tr = simulate(model, (1,))
serialize("test.gen", tr)
# recovered_tr = realize("test.gen", model)
recovered_tr = deserialize("test.gen")
recovered_tr.gen_fn = model

chm = choicemap((:joe,-0.5),)
chm = EmptyChoiceMap()
up_tr, _, _ = update(recovered_tr, (1,), (Gen.NoChange(),), chm)
get_choices(up_tr)