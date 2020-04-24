FROM julia:1.4.1-buster

RUN apt-get update && apt-get install -y libglfw3 gcc

ENV DISPLAY=:0

RUN julia -e 'import Pkg; \
    Pkg.add("Makie"); \
    Pkg.add("GLMakie"); \
    Pkg.add("Observables"); \
    Pkg.add("SymPy"); \
    Pkg.add("QuadGK")'

# Required packages for precompilation of Makie
RUN julia -e 'import Pkg; \
    Pkg.add("AbstractPlotting"); \
    Pkg.add("MakieGallery")';

# See https://github.com/JuliaPlots/Makie.jl#precompilation
RUN julia -e 'using Makie; \
    using Pkg; \
    pkg"add PackageCompiler#master"; \
    using PackageCompiler; \
    PackageCompiler.create_sysimage( \
        :Makie; \
        sysimage_path="MakieSys.so", \
        precompile_execution_file=joinpath(pkgdir(Makie), "test", "test_for_precompile.jl") \
    )'