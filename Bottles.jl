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

# tests
@assert count_top_color(Bottle([NC,1,1,2])) == 2
@assert count_top_color(Bottle([NC,1,1,1])) == 3
@assert count_top_color(Bottle([NC,NC,NC])) == 3

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

# tests
@assert is_unicolor(Bottle([NC,NC]))
@assert is_unicolor(Bottle([NC,1,1]))
@assert ! is_unicolor(Bottle([NC,1,1,2]))

"""test if Bottle is exactly unicolor (i.e. full or empty)"""
all_equal(a::Bottle) = all(ai -> ai==a[1], a)
# tests
@assert all_equal(Bottle([NC,NC]))
@assert all_equal(Bottle([1,1]))
@assert !all_equal(Bottle([NC,1]))

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


a=Bottle([NC,1,2])
b=Bottle([NC,1,3])
c=Bottle([1,1,2])
d=Bottle([2,1,3])
e=Bottle([1,3,2])


#test show Bottle
println(a)
# Canonical order: from smallest to greatest, using lexicographic order
println("Bottles:", [a,b,c,d,e])
println("Bottles:", sort([a,b,c,d,e]), " after sort")

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


        while not pos.isgoal():
            for m in pos:
                c = m.canonical()
                if c in trail:
                    continue
                trail[intern(c)] = pos
                load(m)
            pos = queue.pop()

        while pos:
            solution.appendleft(pos)
            pos = trail[pos.canonical()]

        return list(solution)
"""
function solve(pos::Bottles)
    queue = Queue{Bottles}()
    #enqueue!(queue, pos)
    trail = Dict{Bottles,Bottles}() # backward solution trail
    solution = Queue{Bottles}() # forward solution trail

    node_count = 0
    while ! is_solved(pos)
        for m in children(pos)
            node_count += 1
            c = sort(m)
            if haskey(trail, c)  # already visited
                continue
            end
            # save backward shortest path:
            trail[c] = pos
            enqueue!(queue, m) # not canonical position
        end
        #println(pos, length(queue))
        pos = dequeue!(queue)
    end

    # build forward solution path
    while pos !== nothing
        enqueue!(solution, pos)
        pos = get(trail, sort(pos), nothing)
    end

    return solution, node_count
end

function display_solution(sol, node_count)
    println("Water sort puzzled solved in ", length(sol), " moves ", node_count, " nodes explored:")
    for pos in reverse_iter(sol)
        println(pos)
    end
end

children([a,b,c,d,e])

children([Bottle([1,1]),Bottle([NC,1])]) # remove other useless move?

# Game example: Level 2 from Lipuzz
const L2 = [
    #1: yellow, 2 brown, 3: purple,
    Bottle([1,2,3,1]),
    Bottle([1,2,3,3]),
    Bottle([3,1,2,2]),
    #Bottle([NC,NC,NC,NC]),  2nd empty bottle not necessary
    Bottle([NC,NC,NC,NC])
]
@assert is_consistent(L2) "Puzzle L2 is not valid"

sol, node_count = solve(L2)
println("### Level 2 ###")
display_solution(sol, node_count)
println()


# Game example: Level 13 from Lipuzz
const L13 = [
    #1: orange, 2 gray, 3: yellow, 4: green, 5: blue
    #6: light blue, 7: purple
    Bottle([1,2,3,3]),
    Bottle([1,4,5,2]),
    Bottle([6,1,5,6]),
    Bottle([7,4,7,6]),
    Bottle([7,1,5,2]),
    Bottle([3,4,2,3]),
    Bottle([5,7,6,4]),
    Bottle([NC,NC,NC,NC]),
    Bottle([NC,NC,NC,NC])
]
@assert is_consistent(L13) "Puzzle L13 is not valid"

sol, node_count = solve(L13)
println("### Level 13 ###")
display_solution(sol, node_count)
println()

# Game example: Level 31 from Lipuzz
const L31 = [
    #1: orange, 2 light blue, 3: blue, 4: yellow, 5: green
    #6: red, 7: gray, 8: dark green, 9 purple
    Bottle([1,2,2,3]),
    Bottle([4,4,3,5]),
    Bottle([6,2,3,7]),
    Bottle([4,8,9,1]),
    Bottle([1,6,2,5]),
    Bottle([9,9,6,1]),
    Bottle([3,8,7,8]),
    Bottle([7,6,8,4]),
    Bottle([9,7,5,5]),
    Bottle([NC,NC,NC,NC]),
    Bottle([NC,NC,NC,NC])
]
@assert is_consistent(L31) "Puzzle L31 is not valid"

sol, node_count = solve(L31)
println("### Level 31 ###")
display_solution(sol, node_count)