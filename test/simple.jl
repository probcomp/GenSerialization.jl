@gen function submodel(x::Int)
    subchoice ~ bernoulli(0.5)
end

@gen function model(x::Int)
    x ~ bernoulli(0.5)
    if x == 0
        y ~ bernoulli(0.9)
    else
        z ~ bernoulli(0.1)
    end
    x
end

@testset "Simple" begin
    tr = simulate(model, (1,))
    serialize("test.gen", tr)

    # Realization
    recovered_tr = realize("test.gen", model)
    @test test_equality(tr, recovered_tr)

    # Deserialization
    recovered_tr = deserialize("test.gen")
    recovered_tr.gen_fn = model
    @test test_equality(tr, recovered_tr)
end