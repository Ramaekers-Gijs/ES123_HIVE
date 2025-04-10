function CanMoveQueen(pos::Tuple{Int, Int}, board::Dict{Tuple{Int, Int}, String})
    directions = [(0, 1), (1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1)]
    possible_moves = []

    # Helper: Check if moving between from -> to is slidable (not blocked by 2 tight neighbors)
    function is_slidable(from::Tuple{Int, Int}, to::Tuple{Int, Int})
        dx = to[1] - from[1]
        dy = to[2] - from[2]
        i = findfirst(d -> d == (dx, dy), directions)

        left = directions[mod1(i - 1, 6)]
        right = directions[mod1(i + 1, 6)]

        left_pos = (from[1] + left[1], from[2] + left[2])
        right_pos = (from[1] + right[1], from[2] + right[2])

        return !(haskey(board, left_pos) && haskey(board, right_pos))
    end

    # Helper: Check if removing a piece breaks the hive
    function is_hive_connected(board::Dict{Tuple{Int, Int}, String}, exclude::Tuple{Int, Int})
        temp_board = Dict(board)
        delete!(temp_board, exclude)

        positions = collect(keys(temp_board))
        if length(positions) ≤ 1
            return true
        end

        visited = Set{Tuple{Int, Int}}()
        stack = [positions[1]]
        @show positions
        @show stack

        while !isempty(stack)
            current = pop!(stack)
            push!(visited, current)

            for gijs in directions
                neighbor = (current[1] + gijs[1], current[2] + gijs[2])
                if haskey(temp_board, neighbor) && !(neighbor in visited)
                    push!(stack, neighbor)
                end
            end
        end
        return length(visited) == length(positions)
    end

    # Main logic: check each adjacent cell
    x, y = pos
    for gijs in directions
        target = (x + gijs[1], y + gijs[2])

        # 1. Target must be empty
        if haskey(board, target)
            continue
        end

        # 2. Must have at least one neighbor (can't be isolated)
        has_neighbors = any(haskey(board, (target[1] + d[1], target[2] + d[2])) for d in directions)
        if !has_neighbors
            continue
        end

        # 3. Must be slidable into
        if !is_slidable(pos, target)
            continue
        end

        # 4. Must not break hive when moving queen
        if !is_hive_connected(board, pos)
            continue
        end

        # Valid move
        push!(possible_moves, target)
    end

    return possible_moves
end

board = Dict(
    (0, 0) => "Q",
    (0, 1) => "A",
    (1, 0) => "B",
    (2, 0) => "G",
    (3, 0) => "S"  # linear chain: removing queen disconnects (1,0)-(2,0)-(3,0)
)

CanMoveQueen((0,0),board)

function is_hive_connected(board::Dict{Tuple{Int, Int}, String}, exclude::Tuple{Int, Int})
    # Hex directions
    directions = [(0, 1), (1, 0), (1, -1), (0, -1), (-1, 0), (-1, 1)]

    # Copy board and remove the piece we're simulating as removed
    temp_board = Dict(board)
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
        @info visited 
        for (dx, dy) in directions
            neighbor = (current[1] + dx, current[2] + dy)
            @info neighbor
            if haskey(temp_board, neighbor) && !(neighbor in visited)
                push!(stack, neighbor)
            end
        end
    end
    @info visited
    @info positions
    return length(visited) == length(positions)
end

board = Dict(
    (0, 0) => "Q",
    (0, 1) => "A",
    (1, 0) => "B",
    (1,-1) => "A",
    (1,1) => "A",
    (2,1) => "A",
    (3,1) => "A",
    (3,2) => "A",
    (2, 0) => "G"
)

println(is_hive_connected(board, (2, 1)))  # Should be false (if it disconnects)
