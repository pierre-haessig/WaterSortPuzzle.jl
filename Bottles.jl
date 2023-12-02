#Experiments to represent, solve and analyze the Bottled colors puzzle
#PH, nov 2023
using DataStructures

const ColorType = UInt8
"No color, i.e. empty slot"
const NC = typemax(UInt8)

const Bottle = Vector{UInt8}
const Bottles = Vector{Bottle}


"""comparison of two Bottles, based on lexicographic order"""
function Base.isless(a::Bottle, b::Bottle)
    @assert length(a) == length(b)
    for (ai, bi) in zip(a,b)
        if ai < bi
            return true
        end
    end
    return false
end

"""is Bottle a full?"""
isfull(a::Bottle) = a[1] != NC

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

color_format(i) = i!=NC ? string(i; base=16) : "_"#␣∅

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

        if c_source == NC
            continue
        end

        if c_dest != NC && c_source != c_dest
            continue
        end

        n_empty_dest = count_empty(dest)
        if n_empty_dest == 0
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

children([a,b,c,d,e])