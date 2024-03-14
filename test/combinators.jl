@testset "Map" begin
    @gen function model(p)
        x ~ bernoulli(p)
    end
    mapped_model = Map(model)
    tr = simulate(mapped_model, ([0.9,0.5,0.1],))
    roundtrip_test(tr, mapped_model)
end

@testset "Unfold" begin
    @gen model(n::Int, mu::Float64) = begin
        a ~ normal(mu,1)
        a+1
    end
    unfolded_model = Unfold(model)

    tr = simulate(unfolded_model, (3,0.0))
    roundtrip_test(tr, unfolded_model)
end

@testset "Switch" begin
    @gen function A(n::Int)
        a ~ bernoulli(1/n)
        return Float64(a)
    end
    @gen function B(n::Int)
        a ~ bernoulli(1 - 1/n)
        b ~ normal(0, 1.0)
        return a+b
    end
    ab = Switch(A, B)

    tr = simulate(ab, (1, 2))
    roundtrip_test(tr, ab)
    tr = simulate(ab, (2, 3))
    roundtrip_test(tr, ab)

end