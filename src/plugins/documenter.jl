"""
Add a `Documenter` subtype to a template's plugins to add support for documentation
generation via [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl).
 """
abstract type Documenter <: CustomPlugin end

function gen_plugin(
    plugin::Documenter,
    template::Template,
    dir::AbstractString,
    pkg_name::AbstractString,
)
    path = joinpath(dir, pkg_name)
    docs_dir = joinpath(path, "docs", "src")
    mkpath(docs_dir)
    if !isempty(plugin.assets)
        mkpath(joinpath(docs_dir, "assets"))
        for file in plugin.assets
            cp(file, joinpath(docs_dir, "assets", basename(file)))
        end
        # We want something that looks like the following:
        # [
        #         assets/file1,
        #         assets/file2,
        #     ]
        const TAB = repeat(" ", 4)
        assets_string = "[\n"
        for asset in plugin.assets
            assets_string *= """$(TAB^2)"assets/$(basename(asset))",\n"""
        end
        assets_string *= "$TAB]"

    else
        assets_string = "[]"
    end
    text = """
        using Documenter, $pkg_name

        makedocs(;
            modules=[$pkg_name],
            format=:html,
            pages=[
                "Home" => "index.md",
            ],
            repo="https://$(template.host)/$(template.user)/$pkg_name.jl/blob/{commit}{path}#L{line}",
            sitename="$pkg_name.jl",
            authors="$(template.authors)",
            assets=$assets_string,
        )
        """

    gen_file(joinpath(dirname(docs_dir), "make.jl"), text)
    open(joinpath(docs_dir,  "index.md"), "w") do fp
        write(fp, "# $pkg_name")
    end
    readme_path = joinpath(dir, pkg_name, "README.md")
    if isfile(readme_path)
        cp(readme_path, joinpath(docs_dir, "index.md"), remove_destination=true)
    end
end

function interactive(plugin_type::Type{<:Documenter})
    plugin_name = split(string(plugin_type), ".")[end]
    print("$plugin_name: Enter any Documenter asset files (separated by spaces) []: ")
    return plugin_type(; assets=String.(split(readline())))
end
