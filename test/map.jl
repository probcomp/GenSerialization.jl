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

@testset "Map" begin
    tr = simulate(mapped_model, ([2,3,4],))
    serialize("test.gen", tr)

    recovered_tr = realize("test.gen", model)
    # @test test_equality(tr, recovered_tr)

    # Deserialization
    # recovered_tr = deserialize("test.gen")
    # recovered_tr.gen_fn = model
    # @test test_equality(tr, recovered_tr)
    # realized_tr = realize("test.gen", mapped_model)
end
