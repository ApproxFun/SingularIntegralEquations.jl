export _₂F₁

const ρ = 0.72
immutable ℤ end

Base.in(n::Integer,::Type{ℤ}) = true
Base.in(n::Number,::Type{ℤ}) = n == round(Int,n)

abeqcd(a,b,cd) = a == b == cd
abeqcd(a,b,c,d) = (a == c && b == d)

absarg(z) = abs(angle(z))

sqrtatanhsqrt(x) = x == 0 ? one(x) : (s = sqrt(-x); atan(s)/s)
sqrtasinsqrt(x) = x == 0 ? one(x) : (s = sqrt(x); asin(s)/s)
sinnasinsqrt(n,x) = x == 0 ? one(x) : (s = sqrt(x); sin(n*asin(s))/(n*s))
cosnasinsqrt(n,x) = cos(n*asin(sqrt(x)))
expnlog1pcoshatanh(n,x) = x == 0 ? one(x) : (s = sqrt(x); (exp(n*log1p(s))+exp(n*log1p(-s)))/2)
expnlog1psinhatanhsqrt(n,x) = x == 0 ? one(x) : (s = sqrt(x); (exp(n*log1p(s))-exp(n*log1p(-s)))/(2n*s))

sqrtatanhsqrt(x::Real) = x == 0 ? one(x) : x > 0 ? (s = sqrt(x); atanh(s)/s) : (s = sqrt(-x); atan(s)/s)
sqrtasinsqrt(x::Real) = x == 0 ? one(x) : x > 0 ? (s = sqrt(x); asin(s)/s) : (s = sqrt(-x); asinh(s)/s)
sinnasinsqrt(n,x::Real) = x == 0 ? one(x) : x > 0 ? (s = sqrt(x); sin(n*asin(s))/(n*s)) : (s = sqrt(-x); sinh(n*asinh(s))/(n*s))
cosnasinsqrt(n,x::Real) = x > 0 ? cos(n*asin(sqrt(x))) : cosh(n*asinh(sqrt(-x)))
expnlog1pcoshatanh(n,x::Real) = x == 0 ? one(x) : x > 0 ? exp(n/2*log1p(-x))*cosh(n*atanh(sqrt(x))) : exp(n/2*log1p(-x))*cos(n*atan(sqrt(-x)))
expnlog1psinhatanhsqrt(n,x::Real) = x == 0 ? one(x) : x > 0 ? (s = sqrt(x); exp(n/2*log1p(-x))*sinh(n*atanh(s))/(n*s)) : (s = sqrt(-x); exp(n/2*log1p(-x))*sin(n*atan(s))/(n*s))

expm1nlog1p(n,x) = x == 0 ? one(x) : expm1(n*log1p(x))/(n*x)

# The references to special cases are to Table of Integrals, Series, and Products, § 9.121, followed by NIST's DLMF.

"""
Compute the Gauss hypergeometric function `₂F₁(a,b;c;z)`.
"""
function _₂F₁(a::Real,b::Real,c::Real,z::Number)
    if a > b
        return _₂F₁(b,a,c,z) # ensure a ≤ b
    elseif a == c # 1. 15.4.6
        return exp(-b*log1p(-z))
    elseif b == c # 1. 15.4.6
        return exp(-a*log1p(-z))
    elseif c == 0.5
        if a+b == 0 # 31. 15.4.11 & 15.4.12
            return cosnasinsqrt(2b,z)
        elseif a+b == 1 # 32. 15.4.13 & 15.4.14
            return cosnasinsqrt(1-2b,z)*exp(-0.5log1p(-z))
        elseif b-a == 0.5 # 15.4.7 & 15.4.8
            return expnlog1pcoshatanh(-2a,z)
        end
    elseif c == 1.5
        if abeqcd(a,b,0.5) # 13. 15.4.4 & 15.4.5
            return sqrtasinsqrt(z)
        elseif abeqcd(a,b,1) # 14.
            return sqrtasinsqrt(z)*exp(-0.5log1p(-z))
        elseif abeqcd(a,b,0.5,1) # 15. 15.4.2 & 15.4.3
            return sqrtatanhsqrt(z)
        elseif a+b == 1 # 29. 15.4.15 & 15.4.16
            return sinnasinsqrt(1-2b,z)
        elseif a+b == 2 # 30.
            return sinnasinsqrt(2-2b,z)*exp(-0.5log1p(-z))
        elseif b-a == 0.5 # 4. 15.4.9 & 15.4.10
            return expnlog1psinhatanhsqrt(1-2a,z)
        end
    elseif c == 2
        if abeqcd(a,b,1) # 6. 15.4.1
            return (s = -z; log1p(s)/s)
        elseif a ∈ ℤ && b == 1 # 5.
            return expm1nlog1p(1-a,-z)
        elseif a == 1 && b ∈ ℤ # 5.
            return expm1nlog1p(1-b,-z)
        end
    end
    _₂F₁general(a,b,c,z) # catch-all
end
_₂F₁{T}(a::Real,b::Real,c::Real,z::AbstractArray{T}) = reshape(promote_type(typeof(a),typeof(b),typeof(c),T)[ _₂F₁(a,b,c,z[i]) for i in eachindex(z) ], size(z))

function _₂F₁general{T}(a::Real,b::Real,c::Real,z::T)
    if abs(z) ≤ ρ
        w = z
        _₂F₁taylor(a,b,c,w)
    elseif abs(z/(z-1)) ≤ ρ
        w = z/(z-1)
        _₂F₁taylor(a,c-b,c,w)*exp(-a*log1p(-z))
    elseif abs(1-z) ≤ ρ
        w = 1-z
        gamma(c)*(gamma(c-a-b)/gamma(c-a)/gamma(c-b)*_₂F₁taylor(a,b,a+b-c+1,w)+exp((c-a-b)*log1p(-z))*gamma(a+b-c)/gamma(a)/gamma(b)*_₂F₁taylor(c-a,c-b,c-a-b+1,w))
    elseif abs(inv(1-z)) ≤ ρ && absarg(1-z) < convert(real(T),π)
        w = inv(1-z)
        gamma(c)*(exp(-a*log1p(-z))*gamma(b-a)/gamma(b)/gamma(c-a)*_₂F₁taylor(a,c-b,a-b+1,w)+exp(-b*log1p(-z))*gamma(a-b)/gamma(a)/gamma(c-b)*_₂F₁taylor(b,c-a,b-a+1,w))
    elseif abs(inv(z)) ≤ ρ && absarg(1-z) < convert(real(T),π) && absarg(z) < convert(real(T),π)
        w = inv(z)
        gamma(c)*((-w)^a*gamma(b-a)/gamma(b)/gamma(c-a)*_₂F₁taylor(a,a-c+1,a-b+1,w)+(-w)^b*gamma(a-b)/gamma(a)/gamma(c-b)*_₂F₁taylor(b,b-c+1,b-a+1,w))
    elseif abs(1-inv(z)) ≤ ρ && absarg(1-z) < convert(real(T),π)
        w = 1-inv(z)
        gamma(c)*(z^(-a)*gamma(c-a-b)/gamma(c-a)/gamma(c-b)*_₂F₁taylor(a,a-c+1,a+b-c+1,w)+z^(a-c)*(1-z)^(c-a-b)*gamma(a+b-c)/gamma(a)/gamma(b)*_₂F₁taylor(c-a,1-a,c-a-b+1,w))
    elseif abs(z-0.5) > 0.5
        gamma(c)*(gamma(b-a)/gamma(b)/gamma(c-a)*(0.5-z)^(-a)*_₂F₁continuation(a,a+b,c,0.5,z) + gamma(a-b)/gamma(a)/gamma(c-b)*(0.5-z)^(-b)*_₂F₁continuation(b,a+b,c,0.5,z))
    else
        #throw(DomainError())
        zero(T)
    end
end

function _₂F₁taylor{T}(a::Real,b::Real,c::Real,z::T)
    S₀,S₁,err,j = one(T),one(T)+a*b*z/c,one(real(T)),1
    while err > 100eps2(T)
        rⱼ = (a+j)/(j+1)*(b+j)/(c+j)
        S₀,S₁ = S₁,S₁+(S₁-S₀)*rⱼ*z
        err = abs((S₁-S₀)/S₀)
        j+=1
    end
    return S₁
end

function _₂F₁continuation{T}(s::Real,t::Real,c::Real,z₀::Real,z::T)
    izz₀,d0,d1 = inv(z-z₀),one(T),s/(2s-t+one(T))*((s+1)*(1-2z₀)+(t+1)*z₀-c)
    S₀,S₁,izz₀j,err,j = one(T),one(T)+d1*izz₀,izz₀,one(real(T)),2
    while err > 100eps2(T)
        d0,d1,izz₀j = d1,(j+s-one(T))/j/(j+2s-t)*(((j+s)*(1-2z₀)+(t+1)*z₀-c)*d1 + z₀*(1-z₀)*(j+s-2)*d0),izz₀j*izz₀
        S₀,S₁ = S₁,S₁+d1*izz₀j
        err = abs((S₁-S₀)/S₀)
        j+=1
    end
    return S₁
end

function _₂F₁alt{T}(a::Real,b::Real,c::Real,z::T)
    C,S,err = one(T),one(T),one(real(T))
    j=0
    while err > eps2(T)
        C *= (a+j)/(j+1)*(b+j)/(c+j)*z
        S += C
        err = abs(C/S)
        j+=1
    end
    return S
end
