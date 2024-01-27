using WaterSortPuzzle


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

sol, trail, info = solve(L2)
println("### Level 2 ###")
display_solution(sol, info)
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

sol, trail, info = solve(L13)
println("### Level 13 ###")
display_solution(sol, info)
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

sol, trail, info = solve(L31)
println("### Level 31 ###")
display_solution(sol, info)