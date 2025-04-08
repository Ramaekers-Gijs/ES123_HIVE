using GameZero, Colors

game[].location = @__DIR__

WIDTH = 1920
HEIGHT = 700
BACKGROUND = colorant"antiquewhite"

struct HexCoord #overbodig
    x::Int
    y::Int
end 

struct Piece
    soort::Int # 1 - 5 1:ant 2:beetle 3:grasshopper 4:queen bee 5:spider (op elkaar ziet er zo uit 123)
    player::Int #1 of 2
end

Bord = Dict{HexCoord, Piece}()

function HexCoord2AbsCoord(HexCoord::HexCoord)
    x = 1035 + 75 * HexCoord.x
    iseven(HexCoord.x) ? y = trunc(Int,540 + sqrt(3)*(-50)*HexCoord.y) : y = trunc(Int,540 + sqrt(3)*25*(-2*HexCoord.y-1))
    return x,y
end

function DrawHex(center::HexCoord) #kijken of gaat zoals in package
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

function approx(x,y) #kanmet collide
    approxx = floor(Int,(x-1035+50-12)/75)
    iseven(approxx) ? approxy = floor(Int,(-y+540+sqrt(3)*25)/(50*sqrt(3))) : approxy = floor(Int,(-y+540)/(50*sqrt(3)))
    return HexCoord(approxx,approxy)
end


function on_mouse_down(g::Game,pos) #can be done with squares is easier but less precise
    if pos[1] > 200 
        #ClickInField(pos)
    elseif pos[1] < 200
        #ClickOutField()
    end
end

function ClickInField(pos)
    ap = approx(pos[1],pos[2])
    apAbs = HexCoord2AbsCoord(ap)
    dist = sqrt((pos[1]-apAbs[1])^2+(pos[2]-apAbs[2])^2)
    if dist < 25 * sqrt(3)
        if haskey(Bord,ap)
            Move(ap,key(ap)) #if there is a piece there
        else 
            EmptySpaceUI(ap) #if there is no piece there 
        end
    end
end

function Move(HexCoord::HexCoord,Piece::Piece)
    PosMoves = CanMove(HexCoord::HexCoord,Piece::Piece)
    EndPos = makeclickable(PosMoves)
    place(EndPos,Piece)
end

function place(HexCoord::HexCoord,Piece::Piece)
    if mod(Piece.player, 10) == 1 
        draw(Rect((1000,520),(100,100)), colorant"red",fill=true) #draw black Hex 
    else
        #draw white Hex 
    end
    a = HexCoord2AbsCoord(HexCoord)
    pic = Actor(string(Piece.soort)*".png", scale=[1/8,1/8], position =  Rect(a[1]-32,a[2]-32,512,512)) #de ingebouwde functie center gaat kapot bij scaling
    Bord{HexCoord} = Piece
    return pic
    #draw(pic) comment export the variable so that it can be called in the draw function 
end

# GameZero draw function
function draw(g::Game)
    place(HexCoord(0,0),Piece(1,1))
    DrawGrid(10,10)
    draw(Line(0,540,1920,540)) #not permantent for testing
    draw(Line(1035,0,1035,1080))#not permantent for testing
end