using FastTransforms, Base.Test

@testset "Nonuniform fast Fourier transforms" begin

    FFTW.set_num_threads(Base.Sys.CPU_CORES)

    function nudft1{T<:AbstractFloat}(c::AbstractVector, ω::AbstractVector{T})
        # Nonuniform discrete Fourier transform of type I

        N = size(ω, 1)
        output = zeros(c)
        for j = 1:N
        	output[j] = dot(exp.(2*T(π)*im*(j-1)/N*ω), c)
        end

        return output
    end

    function nudft2{T<:AbstractFloat}(c::AbstractVector, x::AbstractVector{T})
        # Nonuniform discrete Fourier transform of type II

        N = size(x, 1)
        output = zeros(c)
        ω = collect(0:N-1)
        for j = 1:N
        	output[j] = dot(exp.(2*T(π)*im*x[j]*ω), c)
        end

        return output
    end

    function nudft3{T<:AbstractFloat}(c::AbstractVector, x::AbstractVector{T}, ω::AbstractVector{T})
        # Nonuniform discrete Fourier transform of type III

        N = size(x, 1)
        output = zeros(c)
        for j = 1:N
            output[j] = dot(exp.(2*T(π)*im*x[j]*ω), c)
        end

        return output
    end

    N = round.([Int],logspace(1,3,10))

    for n in N, ϵ in (1e-4,1e-8,1e-12,eps(Float64))
        c = complex(rand(n))
        err_bnd = 500*ϵ*n*norm(c)

        ω = collect(0:n-1) + 0.25*rand(n)
        exact = nudft1(c, ω)
        fast = nufft1(c, ω, ϵ)
        @test norm(exact - fast, Inf) < err_bnd

        d = inufft1(fast, ω, ϵ)
        @test norm(c - d, Inf) < err_bnd

        x = (collect(0:n-1) + 0.25*rand(n))/n
        exact = nudft2(c, x)
        fast = nufft2(c, x, ϵ)
        @test norm(exact - fast, Inf) < err_bnd

        d = inufft2(fast, x, ϵ)
        @test norm(c - d, Inf) < err_bnd

        exact = nudft3(c, x, ω)
        fast = nufft3(c, x, ω, ϵ)
        @test norm(exact - fast, Inf) < err_bnd
    end

    function nudft2{T<:AbstractFloat}(C::Matrix{Complex{T}}, x::AbstractVector{T}, y::AbstractVector{T})
        # Nonuniform discrete Fourier transform of type II-II

        M, N = size(C)
        output = zeros(C)
        @inbounds for j1 = 1:M, j2 = 1:N
            for k1 = 1:M, k2 = 1:N
                output[j1,j2] += exp(-2*T(π)*im*(x[j1]*(k1-1)+y[j2]*(k2-1)))*C[k1,k2]
            end
        end
        return output
    end

    N = round.([Int],logspace(1,1.7,5))

    for n in N, ϵ in (1e-4,1e-8,1e-12,eps(Float64))
        C = complex(rand(n,n))
        err_bnd = 500*ϵ*n*norm(C)

        x = (collect(0:n-1) + 0.25*rand(n))/n
        y = (collect(0:n-1) + 0.25*rand(n))/n
        exact = nudft2(C, x, y)
        fast = nufft2(C, x, y, ϵ)
        @test norm(exact - fast, Inf) < err_bnd
    end
end
