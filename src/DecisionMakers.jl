using EcoSISTEM
import EcoSISTEM: AbstractWindDown

abstract type AbstractDecisionMaker end 

abstract type  GlobalDecisionMaker <: AbstractDecisionMaker end

mutable struct PolicyMaker <: GlobalDecisionMaker 
    index::Int64
    sustainability::Float64
end

abstract type LocalDecisionMaker <: AbstractDecisionMaker end

mutable struct Grower <: LocalDecisionMaker
    index::Int64
    location::Int64
    interest::Float64
end

mutable struct LandOwner <: LocalDecisionMaker
    index::Int64
    location::Int64
    interest::Float64
end

mutable struct Grazer <: LocalDecisionMaker
    index::Int64
    location::Int64
    interest::Float64
    intensity::Float64
end

mutable struct DecisionMaking
    update_fun::Function
end

mutable struct DecisionList{T1 <: LocalDecisionMaker, T2 <: GlobalDecisionMaker}
    loc::Vector{T1}
    glob::Vector{T2}
end

function DecisionList(specialise=false)
    if specialise
        loc = Vector{Union{rsubtypes(LocalDecisionMaker)...}}(undef,0)
        glob = Vector{Union{rsubtypes(GlobalDecisionMaker)...}}(undef,0)
    else
        loc = Vector{LocalDecisionMaker}(undef,0)
        glob = Vector{GlobalDecisionMaker}(undef,0)
    end
    return DecisionList{eltype(loc), eltype(glob)}(loc, glob)
end

"""
    adddecision!(dl::DecisionList, dec::LocalDecisionMaker)

Add a local decision maker to the `DecisionList`.
"""
function addtransition!((dl::DecisionList, dec::LocalDecisionMaker)
    push!(dl.loc, dec)
end

"""
    adddecision!(dl::DecisionList, dec::GlobalDecisionMaker)

Add a global decision maker to the `DecisionList`.
"""
function addtransition!((dl::DecisionList, dec::GlobalDecisionMaker)
    push!(dl.glob, dec)
end

