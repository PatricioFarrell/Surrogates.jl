abstract type SamplingAlgorithm end
struct GridSample{T} <: SamplingAlgorithm
    dx::T
end
struct UniformSample <: SamplingAlgorithm end
struct SobolSample <: SamplingAlgorithm end
struct LatinHypercubeSample <: SamplingAlgorithm end

function sample(n,lb,ub,S::GridSample)
    dx = S.dx
    if lb isa Number
        return vec(rand(lb:S.dx:ub,n))
    else
        d = length(lb)
        x = [[rand(lb[j]:dx[j]:ub[j]) for j = 1:d] for i in 1:n]
        return x
    end
end

"""
sample(n,lb,ub,::UniformRandom)
returns a nxd Array containing uniform random numbers
"""
function sample(n,lb,ub,::UniformSample)
    if lb isa Number
        return rand(Uniform(lb,ub),n)
    else
        d = length(lb)
        x = [[rand(Uniform(lb[j],ub[j])) for j in 1:d] for i in 1:n]
        return x
    end
end

"""
sample(n,lb,ub,::SobolSampling)

Sobol
"""
function sample(n,lb,ub,::SobolSample)
    s = SobolSeq(lb,ub)
    skip(s,n)
    if lb isa Number
        return [next!(s)[1] for i = 1:n]
    else
        return [next!(s) for i = 1:n]
    end
end

"""
sample(n,lb,ub,::LatinHypercube)

Latin hypercube sapling
"""
function sample(n,lb,ub,::LatinHypercubeSample)
    d = length(lb)
    if lb isa Number
        x = vec(LHCoptim(n,d,1)[1])
        # x∈[0,n], so affine transform
        return @. (ub-lb) * x/(n) - lb
    else
        x = LHCoptim(n,d,1)[1]
        # TODO: scale into the box
        return x
    end
end
