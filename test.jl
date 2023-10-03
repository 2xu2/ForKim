# import Distributions: Normal, cdf, pdf, median, mean, quantile, mode;
# import LinearAlgebra: norm;
import CompEcon: funfitxy, funeval, fundef, funnode, funbase, qnwnorm;
# import DelimitedFiles: writedlm, readdlm;
#import QuantEcon: MarkovChain, simulate, tauchen, gridmake;
#import Formatting: printfmt;
import Random: seed!;
import Optim: optimize, minimizer;
using UnPack;
using Plots;
using StatsBase;
using Roots;
using NonlinearSolve, StaticArrays;

# GOAL
# I'm trying to see if I can approximate a function using the CompEcon package
# and use the approximations in a nonlinear solver. 

################################################################################
# Step 1: Create a function and plot it.
# A simple function of one variable and one parameter
function f(x, p)
    return -(x .- p) .^ 2;
end

x = collect(range(-10, 10, length=100));
fx = f(x, 3);
Plots.plot(x, fx)

################################################################################
# Step 2: Find the zero of the function.
# This works. 
# The static vector stuff is just copy-pasted from the docs. I don't really 
# undertand it yet. 
x0 = @SVector[1];
p = [3]; 
prob = NonlinearProblem(f, x0, p)
sol = solve(prob, NewtonRaphson(), reltol=1e-6)

################################################################################
# Step #3: Interpolate the function. Plot it. This part looks good. 
 
function create_interp(minx, maxx, n, f, x)
    # Create the function space for a spline approximant over 
    # [xmin, xmax] at n points. Use a cubic spline.
    fspace = fundef([:spli, range(minx, maxx, n), 0, 3]);

    # Compute the basis coefficients for the function defined by x, f(x, p)
    # This returns a tuple whose first element is the coefficients
    c = funfitxy(fspace, x, f)[1];
    return fspace, c;
end

# Create the approximant.
# Note that fx contains the values of f(x, 3)
fspace, c = create_interp(-10, 10, 8, fx, x);

# Evaluate the approximation on some arbitrary points. 
y = funeval(c, fspace, range(-8, 9, 20))[1];
Plots.plot!(range(-8, 9, 20), y, seriestype=:scatter)


################################################################################
# Step 4: Use the interpolated function to find the zero. 


# Wrap the funeval to handle parameters. There are now two: the original 
# parameter and the fspace, which is needed to evaluate the approximant.
function to_max(x, paras)
    # paras[1]=c, paras[2]=fspace
    return funeval(paras[1], paras[2], x)[1]
end

# Check the to_max function. This works. 
Plots.plot(x, f(x,3))
yy = to_max(range(-8, 9, 20), [c, fspace]);
Plots.plot!(range(-8, 9, 20), yy, seriestype=:scatter)




# Now, can I find the zero using the interpolated function?
# Not with my poor Julia skills. 

x0 = @SVector[1];
p = [c, fspace];
prob = NonlinearProblem(to_max, x0, p)
sol = solve(prob, NewtonRaphson(), reltol=1e-6)





