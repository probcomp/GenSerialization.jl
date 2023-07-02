import Gen: Gen, ChoiceOrCallRecord, ChoiceRecord, CallRecord, DynamicDSLChoiceMap, DynamicDSLTrace, Selection
include("dynamic/dynamic.jl")
include("vector/vector.jl")
function convert_to_lazy(tr::Trace) end
attach_function(tr::LazyDynamicTrace, gen_fn::Function) = begin tr.gen_fn = gen_fn end
export LazyDynamicTrace, LazyDynamicTrace