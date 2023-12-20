using multivarBernoulli
using Documenter

DocMeta.setdocmeta!(multivarBernoulli, :DocTestSetup, :(using multivarBernoulli); recursive=true)

makedocs(;
    modules=[multivarBernoulli],
    authors="Charles Dufour",
    repo="https://github.com/dufourc1/multivarBernoulli.jl/blob/{commit}{path}#{line}",
    sitename="multivarBernoulli.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://dufourc1.github.io/multivarBernoulli.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/dufourc1/multivarBernoulli.jl",
    devbranch="main",
)
