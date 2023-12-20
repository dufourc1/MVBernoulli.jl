using MultivariateBernoulli
using Documenter

DocMeta.setdocmeta!(MultivariateBernoulli, :DocTestSetup, :(using MultivariateBernoulli); recursive=true)

makedocs(;
    modules=[MultivariateBernoulli],
    authors="Charles Dufour",
    repo="https://github.com/dufourc1/MultivariateBernoulli.jl/blob/{commit}{path}#{line}",
    sitename="MultivariateBernoulli.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://dufourc1.github.io/MultivariateBernoulli.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/dufourc1/MultivariateBernoulli.jl",
    devbranch="main",
)
