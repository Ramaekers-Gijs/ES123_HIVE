using GameZero, Colors

# initialize screen

WIDTH = 1920
HEIGHT = 1080
BACKGROUND = colorant"antiquewhite"

# define initial state of actors
struct HexGridPoint 
    x::Int64
    y::Int64
end 



function points_hex(center::HexGridPoint;size=50.0)
    theta = LinRange(0,2*pi,7) 
    #iseven(center.x) ? offset = 0 : offset = size 
    x = center.x .+ cos.(theta) .* size
    y = center.y .+ sin.(theta) .* size #.+ offset
    return collect(zip(x, y))  # Return as list of (x, y) tuples for drawpoly
end
pnt =  points_hex(HexGridPoint(300,300))
Line(round(pnt[1][1]),round(pnt[1][2]),round(pnt[2][1]),round(pnt[2][2]))

function drawhex(points)
    # Draw lines between each pair of points
    for i in 1:length(points)-1
        draw(Line(round(pnt[i][1]),round(pnt[i][2]),round(pnt[i+1][1]),round(pnt[i+1][2])))
    end
    # Connect the last point to the first to close the shape
    draw(Line(round(pnt[end][1]),round(pnt[end][2]),round(pnt[1][1]),round(pnt[1][2])))
end
# GameZero draw function
function draw(g::Game)
    pts = points_hex(HexGridPoint(300, 300))
    drawhex(pts)
end