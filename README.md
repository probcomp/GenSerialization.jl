# GenSerialization.jl

WIP tool to serialize Gen.jl traces using Julia's `serialization` library. Gen.jl traces often contain ephemeral data related to the generative model (a function), and this script decouples their dependency. Both traced and untraced randomness are considered.

## Installation
In the package manager, run
```
add https://github.com/probcomp/GenSerialization.jl.git
```

## Usage
See the example for a typical use case. The general workflow is as follows:
1. Produce traces from a generative function and then call `serialize`.
```julia
using Gen
using GenSerialization

@gen function model(p) 
    x ~ bernoulli(p)
end

trace = simulate(model, (0.2))
serialize("coin_flip.gen", trace)
```

2. Read in a trace by passing in the generative function:
```julia
saved_trace = deserialize("coin_flip.gen", model)
```

## Warnings
- Portability hasn't been tested. For example, machines with different endianness may fail to deserialize a given file. 
- The generative function is dropped. 
- `Serialization.jl` is used as the backend, so this package runs into similar pitfalls. For example, if your model samples *functions*, then unfortunately there are no guarantees that serialization will work properly. 