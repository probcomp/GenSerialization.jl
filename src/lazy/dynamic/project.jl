function Gen.project(trace::LazyDynamicTrace, selection::Selection)
    project_recurse(trace.trie, selection)
end

Gen.project(trace::LazyDynamicTrace, ::EmptySelection) = trace.noise