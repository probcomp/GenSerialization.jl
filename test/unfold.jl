using Gen
using GenSerialization

@gen model(n::Int, arr) = begin
    a ~ normal(0,1)
    x ~ bernoulli(0.5)
    hcat(arr, a)
end
unfolded_model = Unfold(model)

tr = simulate(unfolded_model, (1,[0.0,]))
serialize("test.gen", tr)

realized_tr = deserialize("test.gen", unfolded_model)

