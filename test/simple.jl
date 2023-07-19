using Gen
using GenSerialization

@gen function submodel(x::Int)
    subchoice ~ bernoulli(0.5)
end

@gen function model(x::Int)
    # q ~ submodel(3)
    x ~ bernoulli(0.5)
    if x == 0
        y ~ bernoulli(0.9)
    else
        z ~ bernoulli(0.1)
    end
    x
end

tr = simulate(model, (1,))
serialize("test.gen", tr)
# recovered_tr = realize("test.gen", model)
recovered_tr = deserialize("test.gen")
recovered_tr.gen_fn = model

chm = choicemap((:x,0),)
up_tr, _, _ = update(recovered_tr, (1,), (Gen.NoChange(),), chm)
get_choices(up_tr)

chm = choicemap((:x,1),)
up_tr, _, _ = update(recovered_tr, (1,), (Gen.NoChange(),), chm)
get_choices(up_tr)