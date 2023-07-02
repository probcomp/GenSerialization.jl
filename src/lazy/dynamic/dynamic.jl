module LazyDynamicDSL
    using Gen
    import Gen: Gen, ChoiceOrCallRecord, ChoiceRecord, CallRecord, DynamicDSLChoiceMap, Selection
    include("trace.jl")
    include("project.jl")
    include("update.jl")
    # include("regenerate.jl")
    # include("backprop.jl")
    attach_function(tr::LazyDynamicTrace, gen_fn::Function) = begin tr.gen_fn = gen_fn end
end
export LazyDynamicDSL, LazyDynamicTrace