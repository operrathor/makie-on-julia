# Makie.jl on Julia OCI Image

[Julia](https://julialang.org/) OCI image with precompiled [Makie.jl](http://makie.juliaplots.org/) on top of it.

## <a name="screenshot"></a>Screenshot

![Makie.jl scene with terminal in background](screenshot.png)

## Build image

```shell
$ git clone https://github.com/operrathor/makie-on-julia.git
$ cd makie-on-julia
$ buildah bud -t makie-on-julia:1.4.1 .
```

This can take quite a while.

## Run

### Option 1: Julia REPL

```shell
$ podman run -it --rm -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ -v /dev/dri:/dev/dri \
    -v "$PWD":/mnt -w /mnt makie-on-julia:1.4.1 julia -J /MakieSys.so
```

If you want to `include(…)` a Julia script that displays a Makie.jl scene, call `AbstractPlotting.__init__()` after `using Makie`.

### Option 2: Run a specific Julia script

```shell
$ podman run -it --rm -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ -v /dev/dri:/dev/dri \
    -v "$PWD":/mnt -w /mnt makie-on-julia:1.4.1 julia -J /MakieSys.so \
    <script.jl>
```

#### Side note

No matter if you run a Julia script with a Makie.jl scene via `julia <script.jl>` natively or in a container,
you want the window to stay open after `display(scene)`.

I found a nice way on how to achieve that:
```julia
window_closed = Condition()
Observables.on(window_open -> if !window_open[] notify(window_closed) end, scene.events.window_open)
display(scene)
wait(window_closed)
```

### Notes

* We mount `$PWD`, so we can access its files
* If you want the container to be kept, remove `--rm` and give it a `--name <container name>`

## Examples

_Both options produce the same output, see [screenshot at the top](#screenshot)_.

### Option 1: `include(…)` in Julia REPL

Sample script `test.jl`:
```julia
using Makie

AbstractPlotting.__init__() # very important!

x = rand(10)
y = rand(10)
colors = rand(10)
scene = scatter(x, y, color = colors)

display(scene)
```

Start REPL and run `test.jl`:
```shell
$ podman run -it --rm -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ -v /dev/dri:/dev/dri \
    -v "$PWD":/mnt -w /mnt makie-on-julia:1.4.1 julia -J /MakieSys.so

julia> 1 + 2
3

julia> include("test.jl")
```

### Option 2: Run a specific Julia script directly

Sample script `test.jl`:
```julia
using Makie
import Observables

x = rand(10)
y = rand(10)
colors = rand(10)
scene = scatter(x, y, color = colors)

window_closed = Condition()
Observables.on(window_open -> if !window_open[] notify(window_closed) end, scene.events.window_open)
display(scene)
wait(window_closed)
```

Run it:
```shell
$ podman run -it --rm -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ -v /dev/dri:/dev/dri \
    -v "$PWD":/mnt -w /mnt makie-on-julia:1.4.1 julia -J /MakieSys.so \
    test.jl
```
