const Plain = Union{Int16,Int32,Int64,Int128,UInt16,UInt32,UInt64,UInt128,Float16,Float32,
                    Float64}
const PlainType = Union{Type{Int16},Type{Int32},Type{Int64},Type{Int128},Type{UInt16},
                        Type{UInt32},Type{UInt64},Type{UInt128},Type{Float16},
                        Type{Float32},Type{Float64}}
  
# WriteDataspace() = WriteDataspace(DS_NULL, (), ())
# WriteDataspace(::JLDFile, ::Any, odr::Nothing) = WriteDataspace()
# WriteDataspace(::JLDFile, ::Any, ::Any) = WriteDataspace(DS_SCALAR, (), ())

# # Ghost type array
# WriteDataspace(f::JLDFile, x::Array{T}, ::Nothing) where {T} =
#    WriteDataspace(DS_NULL, (),
#              (WrittenAttribute(f, :dimensions, collect(Int64, reverse(size(x)))),))

# # Reference array
# WriteDataspace(f::JLDFile, x::Array{T,N}, ::Type{RelOffset}) where {T,N} =
#     WriteDataspace(DS_SIMPLE, convert(Tuple{Vararg{Length}}, reverse(size(x))),
#               (WrittenAttribute(f, :julia_type, write_ref(f, T, f.datatype_wsession)),))

# # isbitstype array
# WriteDataspace(f::JLDFile, x::Array, ::Any) =
#     WriteDataspace(DS_SIMPLE, convert(Tuple{Vararg{Length}}, reverse(size(x))), ())

# # Zero-dimensional arrays need an empty dimensions attribute
# WriteDataspace(f::JLDFile, x::Array{T,0}, ::Nothing) where {T} =
#     WriteDataspace(DS_NULL, (Length(1),),
#               (WrittenAttribute(f, :dimensions, EMPTY_DIMENSIONS)))
# WriteDataspace(f::JLDFile, x::Array{T,0}, ::Type{RelOffset}) where {T} =
#     WriteDataspace(DS_SIMPLE, (Length(1),),