using EcoSISTEM
using Unitful

abstract type AbstractEconomics end

mutable struct Yield 
    matrix::Matrix{Float64}
    percentage::Float64
    timespan::Unitful.Time
end
function Yield(dimensions::Tuple{Int64, Int64}, timespan::Unitful.Time, percentage::Float64 = 1.0)
    mat = zeros(Float64, dimensions)
    return Yield(mat, percentage, timespan)
end
function calcYield!(yield::Yield)

end

mutable struct Payout
    matrix::Matrix{Float64}
    price::Vector{Float64}
end
function Payout(dimensions::Tuple{Int64, Int64}, price::Vector{Float64})
    mat = zeros(Float64, dimensions)
    return Payout(mat, price)
end

function calcQualifications!(po::Payout, hab::DiscreteHab)
    for i in eachindex(price)
        locs = findall(hab.matrix .== i)
        po.matrix[locs] .= po.price[i]
    end
end

mutable struct CropIncome <: AbstractEconomics 
    yield::Yield
    price::Vector{Float64}
    payouts::Payout
    owners::Matrix{Int64}
    income::Vector{Float64}
end

function CropIncome(numowners::Int64, yield::Yield, price::Vector{Float64}, payouts::Payout, owners::Matrix{Int64})
    income = zeros(Float64, numowners)
    return CropIncome(yield, price, payouts, owners, income)
end

function calcIncome!(ci::CropIncome, owner::Int64)
    payout = ci.payouts
    yield = ci.yield
    locs = findall(ci.owners .== owner)
    cropincome = yield.matrix[:, locs]  .* ci.price
    aescheme = payout.matrix[:, locs] .* qualify[:, locs]
    ci.income[owner] = sum(aescheme) + sum(cropincome)
end

