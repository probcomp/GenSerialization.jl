# GenSerialization.jl

WIP tool to serialize Gen.jl traces using Julia's serialization library. Gen.jl traces often contain ephemeral data related to the generative model (a function), and this script decouples their dependency. Both traced and untraced randomness are considered.

## Installation

The package can be installed with the Julia package manager. From the Julia REPL, type `]` to enter the Pkg REPL mode and then run:
```
pkg> add https://github.com/probcomp/GenSerialization.jl.git
```

To test the installation locally, you can run the tests with:
```julia
using Pkg; Pkg.test("Gen")
```

## Getting Started
We can serialize a trace using the `serialize` function to a file.

```julia
using Gen
using GenSerialization

@gen function model(p) 
    x ~ bernoulli(p)
end

trace = simulate(model, (0.2))
serialize("coin_flip.gen", trace)
```

Now we can read back the trace.
```julia
saved_trace = deserialize("coin_flip.gen", model)
```