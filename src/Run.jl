using EcoSISTEM
import EcoSISTEM; _run_rule!

function update_economics!(eco::LandSystem)
    calcYield!(eco, eco.econ.yield)
    calcQualifications!(eco.econ.payout, eco.abenv.habitat)
    for i in unique(eco.econ.cropincome.owners)
        calcIncome!(eco.econ.cropincome, i)
    end
end

function _run_rule(eco::LandSystem, rule::DecisionMaking)
    rule.update_fun(eco) 
end

function run!(eco::LandSystem, decision::Farmer, timestep::Unitful.Time)
    index = decision.index
    income = eco.econ.income[index]
end

function update!(eco::LandSystem, timestep::Unitful.Time, ::TransitionList, specialise = false)
    if specialise
        run! = _run_rule!
    else
        run! = run_generated!
    end

    Threads.@threads for su in eco.transitions.setup
        run!(eco, su, timestep)
    end

    Threads.@threads for st in eco.transitions.state
        run!(eco, st, timestep)
    end

    Threads.@threads for pl in eco.transitions.placelist
        for p in pl
            run!(eco, eco.transitions.place[p])
        end
    end

    Threads.@threads for wd in eco.transitions.winddown
        run!(eco, wd, timestep)
    end

    Threads.@threads for dc in eco.decisions
        run!(eco, dc, timestep)
    end

end
    