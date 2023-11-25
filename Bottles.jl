#Experiments to represent, solve and analyze the Bottled colors puzzle
#PH, nov 2023
Bottle = Vector{UInt8}
Bottles = Vector{Bottle}

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
isfull(a::Bottle) = a[1] != 0

color_format(i)= i!=0 ? string(i; base=16) : "_"#␣∅

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


a=Bottle([0,1,2])
b=Bottle([0,1,3])
c=Bottle([1,1,2])

#test show Bottle
println(a)
# Canonical order: from greatest to smallest, using lexicographic order
println(sort([a,b,c];rev=true))