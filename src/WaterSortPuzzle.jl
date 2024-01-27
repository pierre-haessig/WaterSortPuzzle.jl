module WaterSortPuzzle

export ColorType, NC, Bottle,
    isless, is_full, count_empty, top_color, count_top_color, is_unicolor, all_equal,
    is_solved, is_consistent, color_format,
    children, solve, display_solution

#Experiments to represent, solve and analyze the Bottled colors puzzle
#PH, nov 2023
using DataStructures
using Crayons

const ColorType = UInt8
"No color, i.e. empty slot"
const NC = typemax(UInt8)

const Bottle = Vector{UInt8}
const Bottles = Vector{Bottle}


palette = Dict(
    1=>166, # orange
    2=>006, # light blue
    3=>004, # blue
    4=>011, # yellow
    5=>010, # green
    6=>009, # red
    7=>008, # gray
    8=>002, # dark green
    9=>005  # purple
    )

"""comparison of two Bottles, based on lexicographic order"""
function Base.isless(a::Bottle, b::Bottle)
    @assert length(a) == length(b)
    for (ai, bi) in zip(a,b)
        if ai < bi
            return true
        elseif ai > bi
            return false
        #else ai==bi: continue to next (ai,bi) pair
        end
    end
    return false
end

"""is Bottle a full?"""
is_full(a::Bottle) = a[1] != NC

"count number of empty slots on top of Bottle a"
function count_empty(a::Bottle)
    # index of first non empty slot:
    itop = findfirst(ai -> ai != NC, a)
    if itop === nothing
        return length(a)
    else
        return itop-1
    end
end

"""color at the top of the bottle, excluding empty slots. returns NC if empty"""
function top_color(a::Bottle)
    # index of first non empty slot:
    itop = findfirst(ai -> ai != NC, a)
    if itop === nothing
        return  NC
    else
        return a[itop]
    end
end

"""color number of slots of the top color. returns bottle length if empty"""
function count_top_color(a::Bottle)
    # index of first non empty slot:
    itop = findfirst(ai -> ai != NC, a)
    if itop === nothing
        return length(a)
    else
        # top color
        c = a[itop]
        i_second = findfirst(ai -> ai != c, a[itop:end])
        if i_second === nothing
            return length(a) - (itop-1)
        else
            return i_second-1
        end
    end
end

"""test if Bottle is filled with only one color (excluding empty slots)"""
function is_unicolor(a::Bottle)
    c = top_color(a)
    for ai in a
        if ai != c && ai != NC
            return false
        end
    end
    return true
end

"""test if Bottle is exactly unicolor (i.e. full or empty)"""
all_equal(a::Bottle) = all(ai -> ai==a[1], a)

"""test if Bottles position is solved: only filled with one color or empty"""
is_solved(pos::Bottles) = all(all_equal, pos)

"""
    is_consistent(v::Bottles)

Test the consistency of the Bottles vector, i.e. whether it is a valid Water sort game.

Consistency requires that, for each color, the total number of color slots
across all bottles is equal to the Bottle length.
"""
function is_consistent(v::Bottles)
    color_counts = Dict{ColorType,Int}()
    n_bottles = length(v)
    bottle_size = length(v[1])
    for a in v
        for ai in a
            if ai == NC
                continue
            end
            # increment color counter
            color_counts[ai] = get(color_counts, ai, 0) +1
        end
    end
    consistent = all(
        n -> n== bottle_size,
        values(color_counts)
    )
    return consistent
end


function color_format(i)
    if i==NC
        return "_"#␣∅
    else
        s = string(i; base=16)
        if i in keys(palette)
            c = Crayon(background=palette[i])
            cr = Crayon(reset=true)
            s = string(c)*s*string(cr)
        end
        return s
    end
end

"single line printing of a Bottle"
function Base.show(io::IO, a::Bottle)
    print(io, "(")
    print(io, join(
            map(color_format, a),
            "|"
        ))
    print(io, ")")
end

"multi line printing of a Bottle"
function Base.show(io::IO, ::MIME"text/plain", a::Bottle)
    println(io, "Bottle:")
    for ai in a
        println(io, " │", color_format(ai) ,"│")
    end
        print(io, " └─┘")
end

"single line printing of Vector of Bottles"
function Base.show(io::IO, v::Bottles)
    print(io, "[")
    print(io, join(
            v,
            ", "
        ))
    print(io, "]")
end

"multi line printing of Vector of Bottles"
function Base.show(io::IO, ::MIME"text/plain", v::Bottles)
    nb = length(v)
    println(io, "Vector of $nb Bottles:")
    nc = length(v[1])

    for i in 1:nc
        print(io, " │")
        print(io, join(
            map(color_format, (
                v[j][i] for j in 1:nb
            )),
            "│"
        ))
        println(io, "│")
    end
    print(io,
        " └",
        join(("─" for j in 1:nb), "┴"),
        "┘")
end

"""list of children nodes of Bottles `v`"""
function children(v::Bottles)
    c = Vector{Bottles}()
    for i_source in eachindex(v), i_dest in eachindex(v)
        if i_source==i_dest
            continue
        end
        source = v[i_source]
        dest = v[i_dest]
        c_source = top_color(source)
        c_dest = top_color(dest)

        # empty source
        if c_source == NC
            continue
        end

        # destination not empty or of same color as source
        if c_dest != NC && c_dest != c_source
            continue
        end

        # no place left in destination
        n_empty_dest = count_empty(dest)
        if n_empty_dest == 0
            continue
        end

        # useless switch move
        if c_dest == NC && is_unicolor(source)
            continue
        end

        n_c_source = count_top_color(source)
        # number of slots to transfer
        n_transfer = min(n_empty_dest, n_c_source)

        #Create new Vector of Bottles with transfered colors
        child = [copy(a) for a in v]

        # index of first non empty slot:
        itop_source = findfirst(ai -> ai != NC, source)

        for k in 1:n_transfer # false: min in available color in source
            child[i_source][itop_source-1+k] = NC
            child[i_dest][(n_empty_dest-n_transfer)+k] = c_source
        end
        push!(c,child)
    end
    return c
end

"""
    solve(pos::Bottles; max_nodes_enum=-1, max_nodes_eval=-1, max_depth=-1)

solve Water sort puzzle from position `pos`

Extra optional parameters can limit the search:
- `max_nodes_enum`: maximum number of enumerated nodes
  ("enumerated" means *not yet evaluated* or dismissed for being a duplicate)
- `max_nodes_eval`: maximum number of evaluated nodes
  (should be ≤ `max_nodes_enum``)
- `max_depth`: maximal graph depth
"""
function solve(pos::Bottles; max_nodes_enum=-1, max_nodes_eval=-1, max_depth=-1)
    # Graph search data structure
    queue = Queue{Tuple{Int,Bottles}}()
    trail = Dict{Bottles,Bottles}() # backward solution trail
    solution = Queue{Bottles}() # forward solution trail (used only if success)

    # Status flags and counters
    nodes_enum_count = 1
    nodes_eval_count = 1
    depth = 0
    status = :RUNNING
    success = false

    while true # iterate on pos
        for m in children(pos) # browse of children of pos
            nodes_enum_count += 1
            if max_nodes_enum > 0 && nodes_enum_count > max_nodes_enum
                status = :MAX_NODES_ENUM
                break # for loop
            end

            # Canonicalize position
            c = sort(m)
            # Check if already visited
            if haskey(trail, c)
                continue
            end

            # Save backward shortest path:
            trail[c] = pos

            # Store the uncanonicalized position (makes solution easier to read)
            enqueue!(queue, (depth+1,m))
        end # for each children of pos

        if status == :MAX_NODES_ENUM
            break
        end

        # Move on to next to position for evaluation and children enumeration
        if length(queue) > 0
            depth, pos = dequeue!(queue)
            nodes_eval_count += 1
        else
            status = :NO_SOLUTION
            break
        end

        # Stop search early if max_* reached
        if max_depth > 0 && depth > max_depth
            status = :MAX_DEPTH
            break
        end
        if max_nodes_eval > 0 && nodes_eval_count > max_nodes_eval
            status = :MAX_NODES_EVAL
            break
        end

        if is_solved(pos)
            status = :SOLVED
            success = true
            break
        end
    end # while true (iteration on dequeued pos)

    # Build the forward `solution` path
    if status == :SOLVED
        while pos !== nothing
            enqueue!(solution, pos)
            pos = get(trail, sort(pos), nothing)
        end
        solution_list = collect(reverse_iter(solution))
    else
        solution_list = []
    end

    info = (
        success = success,
        status = status,
        depth = depth,
        nodes_enum_count = nodes_enum_count,
        nodes_eval_count = nodes_eval_count,
    )
    return solution_list, trail, info
end

"""
    display_solution(sol, info)

display puzzle solution obtained from `solve`

Parameters:
- `sol`: solution list
- `info`: information NamedTuple
"""
function display_solution(sol, info)
    println("Water sort puzzled solved in ", length(sol), " moves ",
            info.nodes_enum_count, " nodes explored:")
    for pos in sol
        println(pos)
    end
end

end # module WaterSortPuzzle