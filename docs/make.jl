using MultivariateBernoullis
using Documenter

DocMeta.setdocmeta!(MultivariateBernoullis, :DocTestSetup, :(using MultivariateBernoullis); recursive=true)

makedocs(;
    modules=[MultivariateBernoullis],
    authors="Charles Dufour",
    repo="https://github.com/dufourc1/MultivariateBernoullis.jl/blob/{commit}{path}#{line}",
    sitename="MultivariateBernoullis.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://dufourc1.github.io/MultivariateBernoullis.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/dufourc1/MultivariateBernoullis.jl",
    devbranch="main",
)
