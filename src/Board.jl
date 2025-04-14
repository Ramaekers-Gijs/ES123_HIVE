using GameZero, Colors

game[].location = @__DIR__

WIDTH = 1920
HEIGHT = 700
BACKGROUND = colorant"antiquewhite"

pic1 = Actor("1.png", scale=[1/8,1/8])
pic2 = Actor("2.png", scale=[1/8,1/8])
pic3 = Actor("3.png", scale=[1/8,1/8])
pic4 = Actor("4.png", scale=[1/8,1/8])
pic5 = Actor("5.png", scale=[1/8,1/8])


struct Piece
    soort::Int # 1 - 5 1:ant 2:beetle 3:grasshopper 4:queen bee 5:spider (op elkaar ziet er zo uit 123)
    player::Int #1 white of 2 black
end

mutable struct selected
    bool::Bool
    HexCoord::Tuple{Int,Int}
end

const BordOpt = Dict{Tuple{Int, Int}, Piece}()

const Bord = Dict{Tuple{Int, Int}, Piece}(
    (0, 0)   => Piece(4, 1),  # Queen Bee for Player 1
    (1, 0)   => Piece(1, 1),  # Ant for Player 1
    (-1, 0)  => Piece(3, 1),  # Grasshopper for Player 1
    (0, 1)   => Piece(2, 2),  # Beetle for Player 2
    (1, 1)   => Piece(5, 2),  # Spider for Player 2
    (-1, -1) => Piece(3, 2),  # Grasshopper for Player 2
    (2, 0)   => Piece(1, 1),  # Another Ant for Player 1
    (0, -1)  => Piece(2, 1),  # Beetle for Player 1
    (1, -1)  => Piece(5, 2),  # Spider for Player 2
    (-2, 0)  => Piece(4, 2)   # Queen Bee for Player 2
)

const directions_even = [(0, 1), (1, 0), (1, -1), (0, -1), (-1, -1), (-1, 0)]
const directions_uneven = [(0, 1), (1, 1), (1, 0), (0, -1), (-1, 0), (-1, 1)]

is_selected = selected(false,(0,0))

function HexPoints(center::Tuple{Int,Int})
    theta = LinRange(0,2*pi,7) 

    x = trunc.(Int,HexCoord2AbsCoord(center)[1] .+ cos.(theta) .* 50)
    y = trunc.(Int,HexCoord2AbsCoord(center)[2] .- sin.(theta) .* 50)

    return x,y
end

function DrawHex(center::Tuple{Int, Int}) #input in hexcoord #af
    x,y = HexPoints(center)

    for i in 1:length(x)-1
        draw(Line(x[i],y[i],x[i+1],y[i+1]))
    end
    # Connect the last point to the first to close the shape
    draw(Line(x[end],y[end],x[1],y[1]))
end

function DrawGrid(x,y)#af
    dx = floor(Int,x/2)
    dy = floor(Int,y/2)
    for i in -dx:dx
        for j in -dy:dy
            DrawHex((i,j))
        end   
    end 
end

function place(HexCoord::Tuple{Int, Int},Piece::Piece) #input in hexcoord
    Abs = HexCoord2AbsCoord(HexCoord)
    x,y = HexPoints(HexCoord)
    square = Rect(x[3],y[3],50,87) #87 = round(Int,sqrt(3)*50)
    triangle1 = Triangle((x[3],y[3]),(x[4],y[4]),(x[5],y[5]))
    triangle2 = Triangle((x[6],y[6]),(x[1],y[1]),(x[2],y[2]))
    if Piece.player == 1 
        draw(square, colorant"white", fill = true)
        draw(triangle1,colorant"white", fill = true)
        draw(triangle2,colorant"white", fill = true)
    elseif Piece.player == 2
        draw(square, colorant"black", fill = true)
        draw(triangle1,colorant"black", fill = true)
        draw(triangle2,colorant"black", fill = true)
    end
    if Piece.soort == 1 
        pic1.position = Rect(Abs[1]-32,Abs[2]-32,512,512)
        draw(pic1)
    elseif Piece.soort == 2 
        pic2.position = Rect(Abs[1]-32,Abs[2]-32,512,512)
        draw(pic2)
    elseif Piece.soort == 3 
        pic3.position = Rect(Abs[1]-32,Abs[2]-32,512,512)
        draw(pic3)
    elseif Piece.soort == 4 
        pic4.position = Rect(Abs[1]-32,Abs[2]-32,512,512)
        draw(pic4)
    elseif Piece.soort == 5 
        pic5.position = Rect(Abs[1]-32,Abs[2]-32,512,512)
        draw(pic5)
    elseif Piece.soort == 6
        DrawHex(HexCoord)
    end
    #pic = Actor(string(Piece.soort)*".png", scale=[1/8,1/8], position =  Rect(Abs[1]-32,Abs[2]-32,512,512)) #de ingebouwde functie center gaat kapot bij scaling
end

function DrawBoard(Board::Dict{Tuple{Int, Int}, Piece})
    for (key, value) in Board
        place(key, value)
    end
end

"""
LOGIC"""

function approx(x,y) #kanmet collide #af
    approxx = floor(Int,(x-1035+50-12)/75)
    iseven(approxx) ? approxy = floor(Int,(-y+540+sqrt(3)*25)/(50*sqrt(3))) : approxy = floor(Int,(-y+540)/(50*sqrt(3)))
    return (approxx,approxy)
end

function Reset()
    empty!(BordOpt)
    global is_selected
    is_selected.bool = false
end


function HexCoord2AbsCoord(HexCoord::Tuple{Int, Int}) #input in hexcoord #af
    x = 1035 + 75 * HexCoord[1]
    iseven(HexCoord[1]) ? y = trunc(Int,540 + sqrt(3)*(-50)*HexCoord[2]) : y = trunc(Int,540 + sqrt(3)*25*(-2*HexCoord[2]-1))
    return x,y
end

function is_hive_connected(exclude::Tuple{Int, Int},include::Tuple{Int, Int} = nothing) #input in hexcoord
    # Copy board and remove the piece we're simulating as removed
    temp_board = Dict(Bord)
    delete!(temp_board, exclude)
    
    if include !== nothing
        temp_board[include] = Piece(1,1)
    end

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
    posibilities = []
    iseven(from[1]) ? directions = directions_even : directions = directions_uneven
    for (x,y) in directions
        to = (from[1] + x, from[2] + y)
        if !(haskey(Bord, to)) && is_slidable(from,to) && is_hive_connected(from, to)
            push!(posibilities, to)
        end
    end
    return posibilities
end

function CanMoveAnt(pos::Tuple{Int, Int})#input in hexcoord
    visited = Set{Tuple{Int, Int}}()
    queue = [pos]

    while !isempty(queue)
        current = popfirst!(queue)
        iseven(current[1]) ? directions = directions_even : directions = directions_uneven

        for (dx, dy) in directions
            neighbor = (current[1] + dx, current[2] + dy)
            if !haskey(Bord, neighbor) && !(neighbor in visited) && is_slidable(current, neighbor) && is_hive_connected(pos, neighbor)
                    push!(queue, neighbor)
                    push!(visited, neighbor)
            end
        end
    end
 
    return visited
end

function CanMoveGrasshopper(pos::Tuple{Int, Int})#input in hexcoord #miss kapot door niet hive connected check maar ik denk dat die werkt
    possible_targets = Tuple{Int, Int}[]

    for i in 1:6
        dir = iseven(pos[1]) ? directions_even[i] : directions_uneven[i]
        current = (pos[1] + dir[1], pos[2] + dir[2])

        jumped = false

        while haskey(Bord, current)
            jumped = true
            dir = iseven(current[1]) ? directions_even[i] : directions_uneven[i]
            current = (current[1] + dir[1], current[2] + dir[2])
        end

        if jumped && !haskey(Bord, current)
            push!(possible_targets, current)
        end
    end

    return possible_targets
end

function CanMoveBeetle(from::Tuple{Int, Int})
    posibilities = []
    iseven(from[1]) ? directions = directions_even : directions = directions_uneven
    for (x,y) in directions
        to = (from[1] + x, from[2] + y)
        if !(haskey(Bord, to)) 
            if is_slidable(from,to) && is_hive_connected(from, to)
                push!(posibilities, to)
            end
        else 
            push!(posibilities, to)
        end
    end
    return posibilities  
end

function CanMoveSpider(pos::Tuple{Int, Int})

    valid_end_positions = Set{Tuple{Int, Int}}()

    function dfs(current::Tuple{Int, Int}, path::Vector{Tuple{Int, Int}})
        if length(path) == 3
            push!(valid_end_positions, current)
            return
        end

        iseven(current[1]) ? directions = directions_even : directions = directions_uneven
        for (dx, dy) in directions
            next = (current[1] + dx, current[2] + dy)
            if !haskey(Bord, next) && !(next in path) && is_slidable(current, next) && is_hive_connected(pos,next) #moet voldoen aan lege plek - niet terug gaan in path- slidable zijn - en the hive connected houden
                new_path = copy(path)
                push!(new_path, next)
                dfs(next, new_path) 
            end
        end
    end

    dfs(pos,Vector{Tuple{Int, Int}}())

    return collect(valid_end_positions)
end

function CanMove(HexCoord::Tuple{Int, Int},Piece::Piece) #input in hexcoord #check if it is your piece 
    if Piece.soort == 1
        array = CanMoveAnt(HexCoord::Tuple{Int, Int}) #input in hexcoord
    elseif Piece.soort == 2
        array = CanMoveBeetle(HexCoord::Tuple{Int, Int}) #input in hexcoord
    elseif Piece.soort == 3
        array = CanMoveGrasshopper(HexCoord::Tuple{Int, Int}) #input in hexcoord
    elseif Piece.soort == 4
        array = CanMoveQueen(HexCoord::Tuple{Int, Int}) #input in hexcoord
    elseif Piece.soort == 5
        array = CanMoveSpider(HexCoord::Tuple{Int, Int}) #input in hexcoord
    end
    return array
end

function Move(from::Tuple{Int,Int},to::Tuple{Int,Int})
    Bord[to] = Bord[from]
    delete!(Bord, from)
end

# GameZero draw function
function draw(g::Game)
    DrawBoard(Bord)
    DrawBoard(BordOpt)
    #not permantent for testing
end

function on_mouse_down(g::Game,pos) #can be done with squares is easier but less precise
    if pos[1] > 200 
        ap = approx(pos[1],pos[2])
        apAbs = HexCoord2AbsCoord(ap)
        dist = sqrt((pos[1]-apAbs[1])^2+(pos[2]-apAbs[2])^2)
        if  dist < 25 * sqrt(3)
            if haskey(Bord, ap) || haskey(BordOpt, ap)
                if  is_selected.bool
                    if haskey(BordOpt, ap)
                        Move(is_selected.HexCoord,ap)
                        Reset()
                    elseif is_selected.HexCoord == ap
                        Reset()
                    end
                else
                    array = CanMove(ap, Bord[ap])
                    if !(array == []) 
                        global is_selected
                        is_selected.bool = true 
                        is_selected.HexCoord = ap
                    end 
                    for possibilities in array
                        BordOpt[possibilities] = Piece(6,0)
                    end
                end
            else
                #place a piece 
            end
        end
    elseif pos[1] < 200
        #ClickOutField()
    end
end
