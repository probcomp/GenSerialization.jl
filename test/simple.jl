
@testset "Simple" begin
    @gen function submodel(p)
        a ~ bernoulli(p)
    end

    @gen function model(p)
        x ~ bernoulli(p)
        {:y=>1} ~ normal(0.0, 0.1)
        z ~ submodel(0.9)
        x + z
    end
    tr = simulate(model, (0.5,))
    roundtrip_test(tr, model)
end