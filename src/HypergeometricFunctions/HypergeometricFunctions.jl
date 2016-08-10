"""
This module calculates (generalized) hypergeometric functions:

    mFn(a;b;z) = ∑_{k=0}^∞ (a_1,k) ⋯ (a_m,k) / (b_1,k) ⋯ (b_n,k) zᵏ/k!
"""
module HypergeometricFunctions

using DualNumbers
import ApproxFun: @clenshaw, real, eps
import FastTransforms: pochhammer

export _₂F₁, _₃F₂, mFn

include("Gauss.jl")
include("specialfunctions.jl")

end #module

using .HypergeometricFunctions

export _₂F₁, _₃F₂, mFn