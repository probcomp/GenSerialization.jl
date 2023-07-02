import Gen: AddressVisitor, DynamicDSLTrace
mutable struct GFLazyUpdateState{S<:LazyDynamicTrace, T<:Trace, U}
    prev_trace::S
    trace::T
    constraints::Any
    weight::Float64
    visitor::AddressVisitor
    params::Dict{Symbol,Any}
    discard::U
end

function GFLazyUpdateState(gen_fn, args, prev_trace, constraints, params)
    visitor = AddressVisitor()
    discard = choicemap()
    trace = DynamicDSLTrace(gen_fn, args)
    GFLazyUpdateState(prev_trace, trace, constraints,
        0., visitor, params, discard)
end

function Gen.traceat(state::GFLazyUpdateState, dist::Distribution{T},
                 args::Tuple, key) where {T}

    local prev_retval::T
    local retval::T

    # check that key was not already visited, and mark it as visited
    Gen.visit!(state.visitor, key)

    # check for previous choice at this key
    has_previous = Gen.has_choice(state.prev_trace, key)
    if has_previous
        prev_choice = Gen.get_choice(state.prev_trace, key)
        prev_retval = prev_choice.retval
        prev_score = prev_choice.score
    end

    # check for constraints at this key
    constrained = has_value(state.constraints, key)
    !constrained && Gen.check_no_submap(state.constraints, key)

    # record the previous value as discarded if it is replaced
    if constrained && has_previous
        set_value!(state.discard, key, prev_retval)
    end

    # get return value
    if constrained
        retval = get_value(state.constraints, key)
    elseif has_previous
        retval = prev_retval
    else
        retval = random(dist, args...)
    end

    # compute logpdf
    score = logpdf(dist, retval, args...)

    # update the weight
    if has_previous
        state.weight += score - prev_score
    elseif constrained
        state.weight += score
    end

    # add to the trace
    Gen.add_choice!(state.trace, key, retval, score)

    retval
end

function Gen.traceat(state::GFLazyUpdateState, gen_fn::GenerativeFunction{T,U},
                 args::Tuple, key) where {T,U}

    local prev_subtrace
    local subtrace
    local retval

    # check key was not already visited, and mark it as visited
    Gen.visit!(state.visitor, key)

    # check for constraints at this key
    Gen.check_no_value(state.constraints, key)
    constraints = get_submap(state.constraints, key)

    # get subtrace
    has_previous = Gen.has_call(state.prev_trace, key)
    if has_previous
        prev_call = Gen.get_call(state.prev_trace, key)
        prev_subtrace = prev_call.subtrace
        # println("Prev subtrace: ", typeof(prev_subtrace))
        @show Gen.get_gen_fn(prev_subtrace)
        if isa(prev_subtrace, LazyDynamicTrace)
            if Gen.get_gen_fn(prev_subtrace) !== nothing
                Gen.get_gen_fn(prev_subtrace) == gen_fn || Gen.gen_fn_changed_error(key)
            else
                println("Update refresh gen_fn $(key)")
                prev_subtrace.gen_fn = gen_fn
            end
        end
        Gen.get_gen_fn(prev_subtrace) == gen_fn || Gen.gen_fn_changed_error(key)
        (subtrace, weight, _, discard) = update(prev_subtrace,
            args, map((_) -> UnknownChange(), args), constraints)
    else
        (subtrace, weight) = generate(gen_fn, args, constraints)
    end

    # update the weight
    state.weight += weight

    # update discard
    if has_previous
        set_submap!(state.discard, key, discard)
    end

    # add to the trace
    Gen.add_call!(state.trace, key, subtrace)

    # get return value
    retval = get_retval(subtrace)

    retval
end

function Gen.splice(state::GFLazyUpdateState, gen_fn::DynamicDSLFunction,
                args::Tuple)
    prev_params = state.params
    state.params = gen_fn.params
    retval = exec(gen_fn, state, args)
    state.params = prev_params
    retval
end

function Gen.update(trace::LazyDynamicTrace, arg_values::Tuple, arg_diffs::Tuple,
                constraints::ChoiceMap)
    gen_fn = trace.gen_fn
    gen_fn === nothing && throw("Generative function is nothing. Attach function to dynamic trace")
    state = GFLazyUpdateState(gen_fn, arg_values, trace, constraints, gen_fn.params)
    retval = Gen.exec(gen_fn, state, arg_values)
    Gen.set_retval!(state.trace, retval)
    visited = Gen.get_visited(state.visitor)
    state.weight -= Gen.update_delete_recurse(trace.trie, visited)
    Gen.add_unvisited_to_discard!(state.discard, visited, get_choices(trace))
    if !Gen.all_visited(visited, constraints)
        error("Did not visit all constraints")
    end
    (state.trace, state.weight, UnknownChange(), state.discard)
end