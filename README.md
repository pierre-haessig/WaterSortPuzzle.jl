# Water sort puzzle solver in Julia

`WaterSortPuzzle.jl` is a Julia package to represent, analyze and solve
so-called “water sort” puzzles (sometimes also called “ball sort”) that
[got popular around 2021–2022](https://trends.google.com/trends/explore?date=today%205-y&q=water%20sort%20puzzle).

If you haven't tried this game, a version can be played free of charge on https://www.coolmathgames.com/0-lipuzz-water-sort


## Package installation

In a the Julia command line (REPL), enter the [package mode](https://docs.julialang.org/en/v1/stdlib/Pkg/) by pressing `]` and type the package installation command:

```
add https://github.com/pierre-haessig/WaterSortPuzzle.jl.git
```


## Usage

See the [demo_WaterSortPuzzle.jl](examples/demo_WaterSortPuzzle.jl) example script.

## Related programs

You can find several other Water sort puzzle solvers on Github, see https://github.com/search?q=water%20sort&type=repositories. Most popular ones seems to be written in Go. However, this solver was inspired by [Raymond Hettinger presentation at US Pycon 2019](https://rhettinger.github.io/index.html).