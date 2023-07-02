
mutable struct LazyDynamicTrace <: Gen.Trace
    gen_fn::Any
    trie::Trie{Any,ChoiceOrCallRecord}
    isempty::Bool
    score::Float64
    noise::Float64
    args::Tuple
    retval::Any

    function LazyDynamicTrace(trie::Trie, isempty::Bool, score::Float64, noise::Float64, args::Tuple, retval::Any)
        new(nothing,trie, isempty, score, noise, args, retval)
    end
    function LazyDynamicTrace(isempty::Bool, score::Float64, noise::Float64, args::Tuple, retval::Any)
        trie = Trie{Any,ChoiceOrCallRecord}()
        new(nothing, trie, isempty, score, noise, args, retval)
    end
    function LazyDynamicTrace(args)
        trie = Trie{Any,ChoiceOrCallRecord}()
        # retval is not known yet
        new(nothing, trie, true, 0, 0, args)
    end
end

Gen.set_retval!(trace::LazyDynamicTrace, retval) = (trace.retval = retval)

function Gen.has_choice(trace::LazyDynamicTrace, addr)
    haskey(trace.trie, addr) && trace.trie[addr].is_choice
end

function Gen.has_call(trace::LazyDynamicTrace, addr)
    haskey(trace.trie, addr) && !trace.trie[addr].is_choice
end

function Gen.get_choice(trace::LazyDynamicTrace, addr)
    choice = trace.trie[addr]
    if !choice.is_choice
        throw(KeyError(addr))
    end
    ChoiceRecord(choice)
end

function Gen.get_call(trace::LazyDynamicTrace, addr)
    call = trace.trie[addr]
    if call.is_choice
        throw(KeyError(addr))
    end
    CallRecord(call)
end

function Gen.add_choice!(trace::LazyDynamicTrace, addr, retval, score)
    if haskey(trace.trie, addr)
        error("Value or subtrace already present at address $addr.
            The same address cannot be reused for multiple random choices.")
    end
    trace.trie[addr] = ChoiceOrCallRecord(retval, score, NaN, true)
    trace.score += score
    trace.isempty = false
end

function Gen.add_call!(trace::LazyDynamicTrace, addr, subtrace)
    if haskey(trace.trie, addr)
        error("Value or subtrace already present at address $addr.
            The same address cannot be reused for multiple random choices.")
    end
    score = get_score(subtrace)
    noise = project(subtrace, EmptySelection())
    submap = get_choices(subtrace)
    trace.isempty = trace.isempty && isempty(submap)
    trace.trie[addr] = ChoiceOrCallRecord(subtrace, score, noise, false)
    trace.score += score
    trace.noise += noise
end

###############
# GFI methods #
###############

Gen.get_args(trace::LazyDynamicTrace) = trace.args
Gen.get_retval(trace::LazyDynamicTrace) = trace.retval
Gen.get_score(trace::LazyDynamicTrace) = trace.score
Gen.get_gen_fn(trace::LazyDynamicTrace) = trace.gen_fn

## get_choices ##

function Gen.get_choices(trace::LazyDynamicTrace)
    if !trace.isempty
        DynamicDSLChoiceMap(trace.trie) # see below
    else
        EmptyChoiceMap()
    end
end

## Base.getindex ##

function Gen._getindex(trace::LazyDynamicTrace, trie::Trie, addr::Pair)
    (first, rest) = addr
    if haskey(trie.leaf_nodes, first)
        choice_or_call = trie.leaf_nodes[first]
        if choice_or_call.is_choice
            error("Unknown address $addr; random choice at $first")
        else
            subtrace = choice_or_call.subtrace_or_retval
            return subtrace[rest]
        end
    elseif haskey(trie.internal_nodes, first)
        return _getindex(trace, trie.internal_nodes[first], rest)
    else
        error("No random choice or generative function call at address $addr")
    end
end

function Gen._getindex(trace::LazyDynamicTrace, trie::Trie, addr)
    if haskey(trie.leaf_nodes, addr)
        choice_or_call = trie.leaf_nodes[addr]
        if choice_or_call.is_choice
            # the value of the random choice
            return choice_or_call.subtrace_or_retval
        else
            # the return value of the generative function call
            return get_retval(choice_or_call.subtrace_or_retval)
        end
    else
        error("No random choice or generative function call at address $addr")
    end
end

function Base.getindex(trace::LazyDynamicTrace, addr)
    _getindex(trace, trace.trie, addr)
end