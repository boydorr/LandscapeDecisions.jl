import EcoSISTEM: AbstractEcosystem, AbstractLandscape, AbstractAbiotic, AbstractSpeciesList, 
AbstractTraitRelationship, AbstractLookup, AbstractCache, TransitionList, emptygridlandscape,
SpeciesLookup, create_cache, TransitionList, genlookups, getkernels

mutable struct LandSystem{L <: AbstractLandscape, Part <: AbstractAbiotic, SL <: AbstractSpeciesList,
    TR <: AbstractTraitRelationship, LU <: AbstractLookup, C <: AbstractCache, TL <: TransitionList, DL <: DecisionList, EC <: AbstractEconomics} <: AbstractEcosystem{L, Part, SL, TR, LU, C}
  abundances::L
  spplist::SL
  abenv::Part
  econ::EC
  ordinariness::Union{Matrix{Float64}, Missing}
  relationship::TR
  lookup::LU
  cache::C
  transitions::TL
  decisions::DL
end

function LandSystem(popfun::F, spplist::SpeciesList{T, Req}, abenv::GridAbioticEnv,
    rel::AbstractTraitRelationship, econ::E, transitions::TransitionList, decisions::DecisionList) where {F<:Function, T, Req, E <:AbstractEconomics}
 
     # Create matrix landscape of zero abundances
   ml = emptygridlandscape(abenv, spplist)
   # Populate this matrix with species abundances
   popfun(ml, spplist, abenv, rel)
   # Create lookup table of all moves and their probabilities
   lookup = SpeciesLookup(collect(map(k -> genlookups(abenv.habitat, k), getkernels(spplist.species.movement))))
   cache = create_cache(spplist, ml)
   return LandSystem{typeof(ml), typeof(abenv), typeof(spplist), typeof(rel), typeof(lookup), typeof(cache), typeof(transitions), typeof(decisions), typeof(econ)}(ml, spplist, abenv,
   econ, missing, rel, lookup, cache, transitions, decisions)
 end
 function LandSystem(spplist::SpeciesList, abenv::GridAbioticEnv,
    rel::AbstractTraitRelationship, econ::E, transitions::TransitionList, decisions::DecisionList) where E <: AbstractEconomics
    return LandSystem(populate!, spplist, abenv, rel, econ, transitions, decisions)
 end