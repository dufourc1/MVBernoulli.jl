using MVBernoulli
using Documenter

DocMeta.setdocmeta!(MVBernoulli, :DocTestSetup, :(using MVBernoulli); recursive=true)

makedocs(;
    modules=[MVBernoulli],
    authors="Charles Dufour",
    repo="https://github.com/dufourc1/MVBernoulli.jl/blob/{commit}{path}#{line}",
    sitename="MVBernoulli.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://dufourc1.github.io/MVBernoulli.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/dufourc1/MVBernoulli.jl",
    devbranch="main",
)
