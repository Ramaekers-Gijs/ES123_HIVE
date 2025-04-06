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
    iseven(HexCoord.x) ? y = trunc(Int,540 + sqrt(3)*25*2*(-1)*HexCoord.y) : y = trunc(Int,540 + sqrt(3)*25*(2*(-1)*HexCoord.y-1))
    return x,y
end

function DrawHex(center::HexCoord)
    theta = LinRange(0,2*pi,7) 

    x = trunc.(Int,HexCoord2AbsCoord(center)[1] .+ cos.(theta) .* 50)
    y = trunc.(Int,HexCoord2AbsCoord(center)[2] .+ sin.(theta) .* 50)

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
    approxx = trunc(Int,(x-1035+50-12)/75)
    iseven(approxx) ? approxy = trunc(Int,(y-540+sqrt(3)*25)/(50*sqrt(3))) : approxy = trunc(Int,(y-540)/(50*sqrt(3)))
    return approxx,approxy
end

function on_mouse_down(g::Game,pos)
    ap = approx(pos[1],pos[2])
    AbsAp = HexCoord2AbsCoord(HexCoord(ap[1],ap[2]))
    @info AbsAp
    @info pos
    dist = sqrt((AbsAp[1]-pos[1])^2+(AbsAp[2]-pos[2])^2)
    if dist < 25*sqrt(3)
        draw(Circle(pos[1],pos[2],20))
        println(string(pos[1])*"   "*string(pos[2]))
    end
end
# GameZero draw function
function draw(g::Game)
    DrawGrid(10,10)
end