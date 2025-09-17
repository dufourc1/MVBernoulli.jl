# MVBernoulli.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://dufourc1.github.io/MVBernoulli.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://dufourc1.github.io/MVBernoulli.jl/dev/)
[![Build Status](https://github.com/dufourc1/MVBernoulli.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/dufourc1/MVBernoulli.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/dufourc1/MVBernoulli.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/dufourc1/MVBernoulli.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

A Julia package for working with **multivariate Bernoulli distributions**. This package provides a complete implementation of multivariate Bernoulli distributions as a `DiscreteMultivariateDistribution` from [Distributions.jl](https://juliastats.org/Distributions.jl/stable/), with support for multiple internal representations and comprehensive statistical operations.

## What is a Multivariate Bernoulli Distribution?

A multivariate Bernoulli distribution is a discrete probability distribution for a vector of binary random variables (X₁, X₂, ..., Xₘ), where each Xᵢ ∈ {0, 1}. Unlike independent Bernoulli variables, the components can be correlated.

For *m* variables, there are 2^m possible outcomes, each with its own probability. For example, with 2 variables, the possible outcomes are:
- (0,0) with probability P₀₀
- (0,1) with probability P₀₁  
- (1,0) with probability P₁₀
- (1,1) with probability P₁₁

where P₀₀ + P₀₁ + P₁₀ + P₁₁ = 1.

## Installation

```julia
using Pkg
Pkg.add("https://github.com/dufourc1/MVBernoulli.jl")
```

## Quick Start

```julia
using MVBernoulli
using Random

# Create a 2D multivariate Bernoulli distribution
# Probabilities: P(0,0)=0.1, P(0,1)=0.2, P(1,0)=0.3, P(1,1)=0.4
probabilities = [0.1, 0.2, 0.3, 0.4]
d = from_tabulation(probabilities)

# Generate samples
Random.seed!(42)
samples = rand(d, 5)
println("Samples: ", samples)

# Calculate marginal probabilities
marginals_prob = marginals(d)
println("P(X₁=1) = ", marginals_prob[1])  # 0.7
println("P(X₂=1) = ", marginals_prob[2])  # 0.6
```

## Key Features

### Multiple Representations

The package supports three equivalent representations of multivariate Bernoulli distributions:

1. **Tabulation**: Direct specification of outcome probabilities
2. **Ordinary moments**: Expected values of variable products
3. **Normalized moments**: Centered moments (deviations from means)

```julia
using MVBernoulli

# Create from tabulation
d1 = from_tabulation([0.1, 0.2, 0.3, 0.4])

# Create from ordinary moments  
d2 = from_ordinary_moments(d1.ordinary_moments)

# Both representations are equivalent
d1.tabulation.p ≈ d2.tabulation.p  # true
```

### Statistical Analysis

Calculate various statistical properties:

```julia
using MVBernoulli, Distributions

d = from_tabulation([0.1, 0.2, 0.3, 0.4])

# Marginal probabilities
marg = marginals(d)

# Correlation matrix
corr_matrix = correlation_matrix(d)

# Covariance matrix  
cov_matrix = covariance_matrix(d)

# Probability mass function
prob = exp(logpdf(d, [1, 0]))  # P(X₁=1, X₂=0) = 0.2
```

### Maximum Likelihood Estimation

Fit distributions from observed data:

```julia
using MVBernoulli, Random

# Generate synthetic data
Random.seed!(123)
true_dist = from_tabulation([0.2, 0.3, 0.1, 0.4])
data = rand(true_dist, 1000)  # 1000 samples

# Fit using MLE
estimated_dist = fit_mle(true_dist, data)
println("Original:  ", true_dist.tabulation.p)
println("Estimated: ", estimated_dist.tabulation.p)
```

## Examples

### Example 1: Independent Variables

Create a distribution where variables are independent:

```julia
using MVBernoulli

# For independent variables: P(X₁,X₂) = P(X₁) × P(X₂)  
p1, p2 = 0.3, 0.7
independent_probs = [
    (1-p1)*(1-p2),  # P(0,0)
    (1-p1)*p2,      # P(0,1)
    p1*(1-p2),      # P(1,0)
    p1*p2           # P(1,1)
]

d_indep = from_tabulation(independent_probs)
corr = correlation_matrix(d_indep)
println("Correlation for independent variables: ", corr[1,2])  # ≈ 0
```

### Example 2: Positively Correlated Variables

```julia
using MVBernoulli

# Variables that tend to have the same value
correlated_probs = [0.4, 0.1, 0.1, 0.4]  # High prob for (0,0) and (1,1)
d_corr = from_tabulation(correlated_probs)

corr = correlation_matrix(d_corr)
println("Correlation: ", corr[1,2])  # Positive correlation

# Marginals are still balanced
marg = marginals(d_corr)
println("Marginals: ", marg)  # Both ≈ 0.5
```

### Example 3: Working with Missing Values

The package supports conditional probabilities with missing values:

```julia
using MVBernoulli

d = from_tabulation([0.1, 0.2, 0.3, 0.4])

# P(X₁=1 | X₂=1) - probability that X₁=1 given X₂=1
cond_prob = conditional_proba(d, [1, missing], [missing, 1])
println("P(X₁=1 | X₂=1) = ", cond_prob)

# Marginal probability with missing values
marg_prob = pmf(d, [1, missing])  # P(X₁=1)
println("P(X₁=1) = ", marg_prob)
```

### Example 4: Higher-Dimensional Distributions

```julia
using MVBernoulli

# 3D multivariate Bernoulli (8 possible outcomes)
probs_3d = [0.1, 0.05, 0.1, 0.15, 0.1, 0.15, 0.2, 0.15]
d_3d = from_tabulation(probs_3d)

println("Number of variables: ", length(d_3d))  # 3
println("Marginals: ", marginals(d_3d))

# Sample from 3D distribution
samples_3d = rand(d_3d, 3)
println("3D samples: ", samples_3d)
```

## API Reference

### Distribution Creation
- `from_tabulation(p::Vector)`: Create from outcome probabilities
- `from_ordinary_moments(moments::Vector)`: Create from ordinary moments

### Statistical Properties  
- `marginals(d)`: Marginal probabilities P(Xᵢ=1)
- `correlation_matrix(d)`: Correlation matrix between variables
- `covariance_matrix(d)`: Covariance matrix between variables

### Distribution Functions
- `rand(d, n)`: Generate n random samples
- `logpdf(d, x)`: Log probability density
- `pmf(d, x)`: Probability mass function (supports missing values)

### Estimation
- `fit_mle(d, data)`: Maximum likelihood estimation from data

### Utilities
- `conditional_proba(d, x, y)`: Conditional probability P(x|y)
- `length(d)`: Number of variables
- `insupport(d, x)`: Check if x is in the support of the distribution

## Mathematical Background

The package handles the mathematical complexities of multivariate Bernoulli distributions, including:

- **Moment conversions**: Efficient transformation between tabulation and moment representations using Kronecker products
- **Correlation analysis**: Proper handling of degenerate cases (when marginal probabilities are 0 or 1)
- **Missing value handling**: Marginalization over unobserved variables
- **Parameter estimation**: Maximum likelihood estimation with proper normalization

## Related Packages

- [Distributions.jl](https://github.com/JuliaStats/Distributions.jl): General probability distributions framework
- [Kronecker.jl](https://github.com/MichielStock/Kronecker.jl): Efficient Kronecker product operations
