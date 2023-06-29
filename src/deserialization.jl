function deserialize(fname::AbstractString)
    genopen(fname, "r") do f
        verify_file_header(f)
    end
end

export deserialize