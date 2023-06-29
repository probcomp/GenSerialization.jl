using Gen
using GenSerialization
using BenchmarkTools

# A simple model
@gen function coin_model(p)
    x ~ bernoulli(p)
    return 1-x
end
tr = simulate(coin_model,(0.5,))
serialize("test.gen", tr)
saved_tr = deserialize("test.gen")
# Attached the generative model
saved_tr.gen_fn = coin_model
update(saved_tr, choicemap(:x=>0))

# `realize()` is simpler but a slower alternative.
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
@time realized_tr = realize("test.gen", model) # Slow
@time deserialized_tr = deserialize("test.gen") # Fast

# Works for combinators

vector_coin_model = Map(coin_model)
coins = simulate(vector_coin_model, ([0.25,0.5,0.75],))
serialize("test.gen", coins)
deserialized_tr = realize("test.gen", vector_coin_model)
deserialized_tr = deserialize("test.gen")
t, _ = update(deserialized_tr, ([0.1, 0.1, 0.1], ), (UnknownChange,), choicemap())