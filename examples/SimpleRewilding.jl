using Revise
using EcoSISTEM
using EcoSISTEM.Units
using LandscapeDecisions
using Unitful, Unitful.DefaultSymbols
using Distributions
using DataFrames
using Plots


# Set up initial parameters for ecosystem
numSpecies = 10; grid = (10, 10); req= 10.0kJ; individuals=10_000; area = 100.0*km^2; totalK = 1000.0kJ/km^2

# Set up how much energy each species consumes
energy_vec = SolarRequirement(fill(req, numSpecies))


# Set rates for birth and death
birth = 0.6/year
death = 0.6/year
longevity = 1.0
survival = 0.0
boost = 1000.0
# Collect model parameters together
param = EqualPop(birth, death, longevity, survival, boost)

# Create kernel for movement
kernel = fill(GaussianKernel(2.0km, 10e-10), numSpecies)
movement = BirthOnlyMovement(kernel, Torus())


# Create species list, including their land cover preferences, seed abundance and native status
traits = DiscreteTrait([
    [[1], [2], fill([3, 4], 8) ...]
])
native = fill(true, numSpecies)
# abun = rand(Multinomial(individuals, numSpecies))
abun = fill(div(individuals, numSpecies), numSpecies)
sppl = SpeciesList(numSpecies, traits, abun, energy_vec,
    movement, param, native)

# Create abiotic environment - even grid of one temperature
props = [2.0, 0.0, 1.0, 1.0]
abenv = simplenicheAE(4, grid, totalK, area, props ./sum(props))
# 1 = crop
# 2 = agroforestry
# 3 = peatland
# 4 = wild


# Set relationship between species and environment (gaussian)
rel = Match{Int64}()

yield = Yield(grid, 1year, 0.8)
pay = Payout(grid, [0.0, 10.0, 10.0, 5.0])
numfarmers = 1
farmers = fill(1, grid)
price = [10.0]
econ = CropIncome(numfarmers, yield, price, pay, farmers)

# Create transition list
transitions = TransitionList()
addtransition!(transitions, UpdateEnergy(EcoSISTEM.update_energy_usage!))
addtransition!(transitions, UpdateEnvironment(update_environment!))
for spp in eachindex(sppl.species.names)
    for loc in eachindex(abenv.habitat.matrix)
        addtransition!(transitions, GenerateSeed(spp, loc, sppl.params.birth[spp]))
        addtransition!(transitions, DeathProcess(spp, loc, sppl.params.death[spp]))
        addtransition!(transitions, SeedDisperse(spp, loc))
    end
end
interest = 0.5
for loc in eachindex(abenv.habitat.matrix)
    addtransition!(transitions, Farmer(1, loc, interest))
end

#Create ecosystem
eco = LandSystem(sppl, abenv, rel, econ, transitions = transitions)

# Simulation Parameters
burnin = 5years; times = 50years; timestep = 1month; record_interval = 3months; repeats = 1
lensim = length(0years:record_interval:times)
abuns = zeros(Int64, numSpecies, prod(grid), lensim)
# Burnin
@time simulate!(eco, burnin, timestep);
@time simulate_record!(abuns, eco, times, record_interval, timestep);
