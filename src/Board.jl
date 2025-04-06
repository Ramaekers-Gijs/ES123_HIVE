using GameZero

# initialize screen

WIDTH = 600
HEIGHT = 600
BACKGROUND = colorant"antiquewhite"

# define initial state of actors
struct point 
    x::Int64
    y::Int64
end 

function points_hex(center::point;size=1.0)
    theta = LinRange(0,2*pi,7) 
    iseven(center.x) ? offset = 0 : offset = size 
    x = center.x .+ cos.(theta) .* size
    y = center.y .+ sin.(theta) .* size .+ offset
end

function draw(g::Game)
    draw(hline, colorant"black")
    draw(vline, colorant"black")
    draw(mouse, colorant"blue", fill = true)
end
