"""
    Coveralls(; config_file::Union{AbstractString, Void}="") -> Coveralls

Add `Coveralls` to a template's plugins to optionally add a `.coveralls.yml` configuration
file to generated repositories, and an appropriate badge to the README. Also updates the
`.gitignore` accordingly.

# Keyword Arguments:
* `config_file::Union{AbstractString, Void}=nothing`: Path to a custom `.coveralls.yml`.
  If left unset, no file will be generated.
"""
@auto_hash_equals struct Coveralls <: GenericPlugin
    gitignore::Vector{AbstractString}
    src::Nullable{AbstractString}
    dest::AbstractString
    badges::Vector{Badge}
    view::Dict{String, Any}

    function Coveralls(; config_file::Union{AbstractString, Void}=nothing)
        if config_file != nothing && !isfile(config_file)
            throw(ArgumentError("File $(abspath(config_file)) does not exist"))
        end
        new(
            ["*.jl.cov", "*.jl.*.cov", "*.jl.mem"],
            config_file,
            ".coveralls.yml",
            [
                Badge(
                    "Coveralls",
                    "https://coveralls.io/repos/github/{{USER}}/{{PKGNAME}}.jl/badge.svg?branch=master",
                    "https://coveralls.io/github/{{USER}}/{{PKGNAME}}.jl?branch=master",
                ),
            ],
            Dict{String, Any}(),
        )
    end
end

interactive(plugin_type::Type{Coveralls}) = interactive(plugin_type; file=nothing)
