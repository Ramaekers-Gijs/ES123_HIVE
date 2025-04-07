using GameZero

game[].location = @__DIR__

WIDTH = 1920
HEIGHT = 700
BACKGROUND = colorant"antiquewhite"

struct HexCoord 
    x::Int
    y::Int
end 

mutable struct Piece
    soort::Int # 1 - 5 1:ant 2:beetle 3:grasshopper 4:queen bee 5:spider (op elkaar ziet er zo uit 123)
    player::Int #1 of 2
end

function HexCoord2AbsCoord(HexCoord::HexCoord)
    x = 1035 + 75 * HexCoord.x
    iseven(HexCoord.x) ? y = trunc(Int,540 + sqrt(3)*(-50)*HexCoord.y) : y = trunc(Int,540 + sqrt(3)*25*(-2*HexCoord.y-1))
    return x,y
end

stuk = Piece(1,1)

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
    approxx = floor(Int,(x-1035+50-12)/75)
    iseven(approxx) ? approxy = floor(Int,(-y+540+sqrt(3)*25)/(50*sqrt(3))) : approxy = floor(Int,(-y+540)/(50*sqrt(3)))
    return approxx,approxy
end

function on_mouse_down(g::Game,pos)
    ap = approx(pos[1],pos[2])
    AbsAp = HexCoord2AbsCoord(HexCoord(ap[1],ap[2])) #approximation can be wrong because of the hexagonal shape of the tiles 
    dist = sqrt((AbsAp[1]-pos[1])^2+(AbsAp[2]-pos[2])^2) 
    if dist < 25*sqrt(3)
        println(string(ap[1])*" "*string(ap[2]))
        stuk.soort = ap[1]
        stuk.player = ap[2]
    end
end

# GameZero draw function
function draw(g::Game)
    DrawGrid(10,10)
    draw(Line(0,540,1920,540)) #not permantent for testing
    draw(Line(1035,0,1035,1080))#not permantent for testing
    txt = TextActor("soort = $(stuk.soort) | player = $(stuk.player)", "fa";
        font_size = 36, color = Int[0, 0, 0, 255]
    )
    txt.pos = (10, 10)
    draw(txt)
end