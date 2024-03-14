function test_trie(expected::Gen.Trie, given::Gen.Trie)
    for (addr, expected_record) in expected.leaf_nodes
        given_record = given.leaf_nodes[addr]
        @test isequal(expected_record.score, given_record.score)
        @test isequal(expected_record.noise, given_record.noise)
        @test isequal(expected_record.is_choice, given_record.is_choice)

        if expected_record.is_choice
            @test isequal(expected_record.subtrace_or_retval,
                        given_record.subtrace_or_retval)
        else
            test_equality(
                expected_record.subtrace_or_retval,
                given_record.subtrace_or_retval
            )
        end
    end

    for (addr, rec) in expected.internal_nodes
        test_trie(rec, given.internal_nodes[addr])
    end
end

function test_equality(expected::T, given::T) where T <: Gen.DynamicDSLTrace
    @test isequal(expected.score, given.score)
    @test isequal(expected.args, given.args)
    @test isequal(expected.retval, given.retval)

    expected_addrs = Set{Symbol}(keys(expected.trie.leaf_nodes))
    given_addrs = Set{Symbol}(keys(given.trie.leaf_nodes))
    @test isequal(expected_addrs, given_addrs)

    expected_addrs = Set{Symbol}(keys(expected.trie.internal_nodes))
    given_addrs = Set{Symbol}(keys(given.trie.internal_nodes))
    @test isequal(expected_addrs, given_addrs)

    test_trie(expected.trie, given.trie)
end

function test_equality(expected::T, given::T) where T<:Gen.VectorTrace
    @test isequal(expected.retval, given.retval)
    @test isequal(expected.args, given.args)
    @test isequal(expected.len, given.len)
    @test isequal(expected.num_nonempty, given.num_nonempty)
    @test isequal(expected.score, given.score)
    @test isequal(expected.noise, given.noise)
   
    expected_subtraces = expected.subtraces
    given_subtraces = given.subtraces
    @test isequal(length(expected_subtraces), length(given_subtraces))
    for (tr1, tr2) in zip(expected_subtraces, given_subtraces)
        test_equality(tr1, tr2)
    end
end

function test_equality(expected::T, given::T) where T<:Gen.SwitchTrace
    @test isequal(expected.retval, given.retval)
    @test isequal(expected.args, given.args)
    @test isequal(expected.score, given.score)
    @test isequal(expected.noise, given.noise)
    test_equality(expected.branch, given.branch)
end

function test_equality(expected::T, given::T) where T<:Gen.RecurseTrace
    @test isequal(expected.max_branch, given.max_branch)
    @test isequal(expected.max_branch, given.max_branch)
    @test isequal(expected.score, given.score)
    @test isequal(expected.root_idx, given.root_idx)
    @test isequal(expected.num_has_choices, given.num_has_choices)

    # Production traces
    # Aggregation traces
end