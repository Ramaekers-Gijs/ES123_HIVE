""" this_file = split(basename(@__FILE__), '#')[1]
import Pkg
Pkg.activate(io = IOBuffer())
deps = [pair.second for pair in Pkg.dependencies()]
direct_deps = filter(p -> p.is_direct_dep, deps)
pkgs = [x.name for x in direct_deps]
if "GLMakie" ∉ pkgs
    Pkg.add(GLMakie)
end"""

using GLMakie 
using Revise

include("Board.jl")
include("Piece.jl")
include("UI.jl")

using .board 
using .piece
using .ui