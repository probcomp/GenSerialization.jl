# GenSerialization.jl

WIP tool to serialize Gen.jl traces using Julia's `serialization` library. Gen.jl traces often contain ephemeral data related to the generative model (a function), and this script decouples their dependency. Both traced and untraced randomness are considered.


See the example for a typical use case. The general workflow is as follows:
1. Produce traces from a dynamic DSL trace, and call the `serialize` function.
```
@gen function model(p) 
    x ~ bernoulli(p)
end

trace = simulate(model, (0.2))
serialize("coin_flip.gen", trace)
```

2. To deserialize, there are currently two options. They different in performance, but the faster one currently requires non-DRY data structures.
```
saved_trace = deserialize("coin_flip.gen") # Fast
saved_trace = realize("coin_flip.gen") # Slow
```

Warnings:
- Portability hasn't been tested. For example, machines with different endianness may fail to deserialize a given file. 