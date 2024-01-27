using WaterSortPuzzle
using Test

@testset "WaterSortPuzzle.jl" begin
    a=Bottle([NC,1,2])
    b=Bottle([NC,1,3])
    c=Bottle([1,1,2])
    d=Bottle([2,1,3])
    e=Bottle([1,3,2])

    @test sort([a,b,c,d,e])==[c,e,d,a,b]

    @test count_top_color(Bottle([NC,1,1,2])) == 2
    @test count_top_color(Bottle([NC,1,1,1])) == 3
    @test count_top_color(Bottle([NC,NC,NC])) == 3

    @test is_unicolor(Bottle([NC,NC]))
    @test is_unicolor(Bottle([NC,1,1]))
    @test ! is_unicolor(Bottle([NC,1,1,2]))

    @test all_equal(Bottle([NC,NC]))
    @test all_equal(Bottle([1,1]))
    @test !all_equal(Bottle([NC,1]))
end