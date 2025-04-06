using GameZero, Colors

# initialize screen

WIDTH = 1920
HEIGHT = 1080
BACKGROUND = colorant"antiquewhite"

# define initial state of actors
struct HexCoord 
    x::Int64
    y::Int64
end 

function HexCoord2AbsCoord(HexCoord::HexCoord)
    x = 1035 + 75 * HexCoord.x
    iseven(HexCoord.x) ? y = floor(Int,540 + sqrt(3)*25*2*(-1)*HexCoord.y) : y = floor(Int,540 + sqrt(3)*25*(2*(-1)*HexCoord.y+1))
    return x,y
end

function DrawHex(center::HexCoord)
    theta = LinRange(0,2*pi,7) 

    x = floor.(Int,HexCoord2AbsCoord(center)[1] .+ cos.(theta) .* 50)
    y = floor.(Int,HexCoord2AbsCoord(center)[2] .+ sin.(theta) .* 50)

    for i in 1:length(x)-1
        draw(Line(x[i],y[i],x[i+1],y[i+1]))
    end
    # Connect the last point to the first to close the shape
    draw(Line(x[end],y[end],x[1],y[1]))
end

function DrawGrid(x,y)
    dx = floor(x/2)
    dy = floor(y/2)
    for i in -dx:dx
        for j in -dy:dy
        DrawHex(HexCoord(i,j))
        end   
    end 
end

function approx(x,y)
    aproxx = trunc((x-1035+50-12)/75)
    aproxy = trunc((y-540+sqrt(3)*25)/(50*sqrt(3)))
end
#@info approx(0,540)
# GameZero draw function
function draw(g::Game)
    DrawHex(HexCoord(5,5))
end