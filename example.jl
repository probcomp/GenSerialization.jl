using Gen
using GenSerialization

# A simple model
@gen function coin_model(p)
    x ~ bernoulli(p)
    return 1-x
end

tr = simulate(coin_model,(0.5,))
serialize("test.gen", tr)
saved_tr = deserialize("test.gen", coin_model)
update(saved_tr, choicemap(:x=>0))

# Works for combinators

vector_coin_model = Map(coin_model)
coins = simulate(vector_coin_model, ([0.25,0.5,0.75],))
serialize("test.gen", coins)
deserialized_tr = deserialize("test.gen", vector_coin_model)
tr, _ = update(deserialized_tr, ([0.1, 0.1, 0.1], ), (UnknownChange,), choicemap())
