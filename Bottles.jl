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

"""color at the top of the bottle, excluding empty slots. returns NC if empty"""
function top_color(a::Bottle)
    itop = findfirst(ai -> ai != NC, a)
    if itop === nothing
        return  NC
    else
        return a[itop]
    end
end

"number of empty slots on top of Bottle a"
function n_empty(a::Bottle)
    c = 0
    for ai in a
        if ai == NC
            c += 1
        else
            break
        end
    end
    return c
end

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
println("Bottles:", sort([a,b,c,d,e]), "sorted")

"""list of children nodes of Bottles `v`"""
function children(v::Bottles)
    c = Vector{Bottles}()
    for i in eachindex(v), j in eachindex(v)
        if i==j
            continue
        end
        source = v[i]
        dest = v[j]
        top_source = top_color(source)
        top_dest = top_color(dest)

        if top_dest != NC && top_source != top_dest
            continue
        end

        n_empty_dest = n_empty(dest)
        if n_empty_dest == 0
            continue
        end

        #Create new Vector of Bottles with transfered colors
        child = [copy(a) for a in v]
        for k in 1:n_empty_dest # false: min in available color in source
            child[i][k] = NC # false: add offest of n_empty_source
            child[j][k] = top_source
        end
        push!(c,child)
    end
    return c
end

children([a,b,c,d,e])