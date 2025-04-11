using GameZero, Colors

game[].location = @__DIR__

WIDTH = 1920
HEIGHT = 700
BACKGROUND = colorant"antiquewhite"
"""
struct HexCoord #overbodig
    x::Int
    y::Int
end 
"""
struct Piece
    soort::Int # 1 - 5 1:ant 2:beetle 3:grasshopper 4:queen bee 5:spider (op elkaar ziet er zo uit 123)
    player::Int #1 of 2
end

const Bord = Dict{Tuple{Int, Int}, Piece}()

const directions_even = [(0, 1), (1, 0), (1, -1), (0, -1), (-1, -1), (-1, 0)]
const directions_uneven = [(0, 1), (1, 1), (1, 0), (0, -1), (-1, 0), (-1, 1)]

function HexCoord2AbsCoord(HexCoord::Tuple{Int, Int}) #input in hexcoord #af
    x = 1035 + 75 * HexCoord.x
    iseven(HexCoord.x) ? y = trunc(Int,540 + sqrt(3)*(-50)*HexCoord.y) : y = trunc(Int,540 + sqrt(3)*25*(-2*HexCoord.y-1))
    return x,y
end

function DrawHex(center::Tuple{Int, Int}) #input in hexcoord #af
    theta = LinRange(0,2*pi,7) 

    x = trunc.(Int,HexCoord2AbsCoord(center)[1] .+ cos.(theta) .* 50)
    y = trunc.(Int,HexCoord2AbsCoord(center)[2] .+ sin.(theta) .* 50)

    for i in 1:length(x)-1
        draw(Line(x[i],y[i],x[i+1],y[i+1]))
    end
    # Connect the last point to the first to close the shape
    draw(Line(x[end],y[end],x[1],y[1]))
end

function DrawGrid(x,y)#af
    dx = floor(x/2)
    dy = floor(y/2)
    for i in -dx:dx
        for j in -dy:dy
        DrawHex(HexCoord(i,j))
        end   
    end 
end

function approx(x,y) #kanmet collide #af
    approxx = floor(Int,(x-1035+50-12)/75)
    iseven(approxx) ? approxy = floor(Int,(-y+540+sqrt(3)*25)/(50*sqrt(3))) : approxy = floor(Int,(-y+540)/(50*sqrt(3)))
    return (approxx,approxy)
end

function on_mouse_down(g::Game,pos) #can be done with squares is easier but less precise
    if pos[1] > 200 
        ap = approx(pos[1],pos[2])
        apAbs = HexCoord2AbsCoord(ap)
        dist = sqrt((pos[1]-apAbs[1])^2+(pos[2]-apAbs[2])^2)
        if  dist < 25 * sqrt(3)
            if haskey(ap, Bord)
                #move the piece
            else
                #place a piece 
            end
        end
    elseif pos[1] < 200
        #ClickOutField()
    end
end

function place(HexCoord::Tuple{Int, Int},Piece::Piece) #input in hexcoord
    a = HexCoord2AbsCoord(HexCoord)
    if mod(Piece.player, 10) == 1 
        square = Actor(Rect((a[],520),(100,100)), colorant"black",fill=true) #draw black Hex 
    else
        #draw white Hex 
    end
    pic = Actor(string(Piece.soort)*".png", scale=[1/8,1/8], position =  Rect(a[1]-32,a[2]-32,512,512)) #de ingebouwde functie center gaat kapot bij scaling
    Bord{HexCoord} = Piece
    return pic
    #draw(pic) comment export the variable so that it can be called in the draw function 
end

"""
LOGIC
"""

function is_hive_connected(exclude::Tuple{Int, Int}) #input in hexcoord
    # Copy board and remove the piece we're simulating as removed
    temp_board = Dict(Bord)
    delete!(temp_board, exclude)

    positions = collect(keys(temp_board))
    if length(positions) ≤ 1
        return true
    end

    visited = Set{Tuple{Int, Int}}()
    stack = [positions[1]]  # Start DFS from one random position

    while !isempty(stack)
        current = pop!(stack)
        push!(visited, current)
        iseven(current[1]) ? directions = directions_even : directions = directions_uneven
        for (dx, dy) in directions
            neighbor = (current[1] + dx, current[2] + dy)
            if haskey(temp_board, neighbor) && !(neighbor in visited)
                push!(stack, neighbor)
            end
        end
    end
    return length(visited) == length(positions)
end

function is_slidable(from::Tuple{Int, Int}, to::Tuple{Int, Int}) #input in hexcoord
    dx = to[1] - from[1] 
    dy = to[2] - from[2]
    iseven(from[1]) ? directions = directions_even : directions = directions_uneven
    i = findfirst(d -> d == (dx, dy), directions) #try catch

    left = directions[mod1(i - 1, 6)]
    right = directions[mod1(i + 1, 6)]

    left_pos = (from[1] + left[1], from[2] + left[2])
    right_pos = (from[1] + right[1], from[2] + right[2])

    return !(haskey(Bord, left_pos) && haskey(Bord, right_pos))
end

function CanMoveQueen(from::Tuple{Int, Int}) #input in hexcoord
    if !(is_hive_connected(from))
        return
    end
    posibilities = []
    iseven(from[1]) ? directions = directions_even : directions = directions_uneven
    for (x,y) in directions
        to = (from[1] + x, from[2] + y)
        if !(haskey(Bord, to)) && is_slidable(from,to)
            push!(posibilities, to)
        end
    end
    return posibilities
end

const Bord = Dict(
    (0, 0) => "queen",
    (0, 1) => "ant",       # target
    (-1, 0) => "beetle",   # left neighbor
    (1, 0) => "spider"     # right neighbor
)

CanMoveQueen((0,0))

function CanMove(HexCoord::Tuple{Int, Int},Piece::Piece) #input in hexcoord #check if it is your piece 
    if Piece.soort == 1
        array = CanMoveAnt(HexCoord::Tuple{Int, Int},Piece::Piece) #input in hexcoord
    elseif Piece.soort == 2
        array = CanMoveBeetle(HexCoord::Tuple{Int, Int},Piece::Piece) #input in hexcoord
    elseif Piece.soort == 3
        array = CanMoveGrasshopper(HexCoord::Tuple{Int, Int},Piece::Piece) #input in hexcoord
    elseif Piece.soort == 4
        array = CanMoveQueen(HexCoord::Tuple{Int, Int},Piece::Piece) #input in hexcoord
    elseif Piece.soort == 5
        array = CanMoveSpider(HexCoord::Tuple{Int, Int},Piece::Piece) #input in hexcoord
    end
    return array
end

# GameZero draw function
function draw(g::Game)
    DrawGrid(10,10)
    draw(Line(0,540,1920,540)) #not permantent for testing
    draw(Line(1035,0,1035,1080))#not permantent for testing
end