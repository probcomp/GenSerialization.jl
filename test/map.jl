using Gen
using GenSerialization
@gen function sub()
    q ~ bernoulli(0.5)
end
@gen function model(n::Int)
    x ~ bernoulli(0.5)
    for i=1:n
        {:y=>i} ~ normal(0,1)
    end
    q ~ sub()
    return x
end

mapped_model = Map(model)

tr = simulate(mapped_model, ([2,3,4],))
n = serialize("test.gen", tr)

realized_tr = realize("test.gen", mapped_model)