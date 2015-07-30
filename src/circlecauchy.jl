

## cauchy

function cauchyS(s::Bool,cfs::Vector,z::Number)
    ret=zero(Complex{Float64})

    if s
        zm = one(Complex{Float64})

        #odd coefficients are pos
        @simd for k=1:2:length(cfs)
            @inbounds ret += cfs[k]*zm
            zm *= z
        end
    else
        z=1./z
        zm = z

        #even coefficients are neg
        @simd for k=2:2:length(cfs)
            @inbounds ret -= cfs[k]*zm
            zm *= z
        end
    end

    ret
end

cauchyS(s::Bool,d::Circle,cfs::Vector,z::Number)=cauchyS(s,cfs,mappoint(d,Circle(),z))


function cauchy(d::Circle,cfs::Vector,z::Number)
    z=mappoint(d,Circle(),z)
    cauchyS(abs(z) < 1,cfs,z)
end

cauchy(d::Circle,cfs::Vector,z::Vector)=[cauchy(d,cfs,zk) for zk in z]

function cauchy(s::Bool,d::Circle,cfs::Vector,z::Number)
    @assert in(z,d)

    cauchyS(s,d,cfs,z)
end



cauchy(s::Bool,f::Fun{Laurent},z::Number)=cauchy(s,domain(f),coefficients(f),z)
cauchy(f::Fun{Laurent},z::Number)=cauchy(domain(f),coefficients(f),z)

cauchy(s::Bool,f::Fun{Fourier},z::Number)=cauchy(s,Fun(f,Laurent(domain(f))),z)
cauchy(f::Fun{Fourier},z::Number)=cauchy(Fun(f,Laurent(domain(f))),z)



# we implement cauchy ±1 as canonical
hilbert(f::Fun{Laurent},z)=im*(cauchy(true,f,z)+cauchy(false,f,z))



## mapped Cauchy


# pseudo cauchy is not normalized at infinity
function pseudocauchy{C<:Curve}(f::Fun{MappedSpace{Laurent,C,Complex{Float64}}},z::Number)
    fcirc=Fun(f.coefficients,f.space.space)  # project to circle
    c=domain(f)  # the curve that f lives on
    @assert domain(fcirc)==Circle()

    sum(cauchy(fcirc,complexroots(c.curve-z)))
end

function cauchy{C<:Curve}(f::Fun{MappedSpace{Laurent,C,Complex{Float64}}},z::Number)
    fcirc=Fun(f.coefficients,f.space.space)  # project to circle
    c=domain(f)  # the curve that f lives on
    @assert domain(fcirc)==Circle()
    # subtract out value at infinity, determined by the fact that leading term is poly
    # we find the
    sum(cauchy(fcirc,complexroots(c.curve-z)))-div(length(domain(f).curve),2)*cauchy(fcirc,0.)
end

function cauchy{C<:Curve}(s::Bool,f::Fun{MappedSpace{Laurent,C,Complex{Float64}}},z::Number)
    fcirc=Fun(f.coefficients,f.space.space)  # project to circle
    c=domain(f)  # the curve that f lives on
    @assert domain(fcirc)==Circle()
    rts=complexroots(c.curve-z)


    ret=-div(length(domain(f).curve),2)*cauchy(fcirc,0.)

    for k=2:length(rts)
        ret+=in(rts[k],Circle())?cauchy(s,fcirc,rts[k]):cauchy(fcirc,rts[k])
    end
    ret
end


function hilbert{C<:Curve}(f::Fun{MappedSpace{Laurent,C,Complex{Float64}}},z::Number)
    fcirc=Fun(f.coefficients,f.space.space)  # project to circle
    c=domain(f)  # the curve that f lives on
    @assert domain(fcirc)==Circle()
    rts=complexroots(c.curve-z)


    ret=-2im*div(length(domain(f).curve),2)*cauchy(fcirc,0.)

    for k=2:length(rts)
        ret+=in(rts[k],Circle())?hilbert(fcirc,rts[k]):2im*cauchy(fcirc,rts[k])
    end
    ret
end




## cauchyintegral and logkernel


function stieltjesintegral(f::Fun{Laurent},z::Number)
    d=domain(f)
    @assert d==Circle()  #TODO: radius
    ζ=Fun(d)
    r=stieltjes(integrate(f-f.coefficients[2]/ζ),z)
    abs(z)<1?r:r+2π*im*f.coefficients[2]*log(z)
end

function stieltjesintegral(s,f::Fun{Laurent},z::Number)
    d=domain(f)
    @assert d==Circle()  #TODO: radius
    ζ=Fun(d)
    r=stieltjes(s,integrate(f-f.coefficients[2]/ζ),z)
    s?r:r+2π*im*f.coefficients[2]*log(z)
end

stieltjesintegral(f::Fun{Fourier},z::Number)=stieltjesintegral(Fun(f,Laurent),z)

function logkernel(g::Fun{Fourier},z::Number)
    d=domain(g)
    c,r=d.center,d.radius
    z=z-c
    if abs(z) ≤r
        ret=2r*log(r)*g.coefficients[1]
        for j=2:2:length(g)
            k=div(j,2)
            ret+=-g.coefficients[j]*sin(k*angle(z))*abs(z)^k/(k*r^(k-1))
        end
        for j=3:2:length(g)
            k=div(j,2)
            ret+=-g.coefficients[j]*cos(k*angle(z))*abs(z)^k/(k*r^(k-1))
        end
        ret
    else
        ret=2r*logabs(z)*g.coefficients[1]
        for j=2:2:length(g)
            k=div(j,2)
            ret+=-g.coefficients[j]*sin(k*angle(z))*r^(k+1)/(k*abs(z)^k)
        end
        for j=3:2:length(g)
            k=div(j,2)
            ret+=-g.coefficients[j]*cos(k*angle(z))*r^(k+1)/(k*abs(z)^k)
        end
        ret
    end
end
logkernel(g::Fun{Fourier},z::Vector) = promote_type(eltype(g),eltype(z))[logkernel(g,zk) for zk in z]
logkernel(g::Fun{Fourier},z::Matrix) = reshape(promote_type(eltype(g),eltype(z))[logkernel(g,zk) for zk in z],size(z))

logkernel(g::Fun{Laurent},z)=logkernel(Fun(g,Fourier),z)
