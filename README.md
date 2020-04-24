# Makie.jl on Julia OCI Image

Julia OCI image with precompiled Makie.jl on top of it.

*Didn't have the chance to test it with Docker's tools yet, only with buildah/podman.*

## Build image

*For docker, replace `buildah bud` by `docker build`.*

```
$ git clone https://github.com/operrathor/makie-on-julia.git
$ cd makie-on-julia
$ buildah bud -t makie-on-julia:1.4.1 .
```

This can take quite a while.

## Run

*For docker, replace `podman` by `docker`.*

### Option 1: Julia REPL

```
$ podman run -it --rm -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ -v /dev/dri:/dev/dri \
-v "$PWD":/mnt -w /mnt makie-on-julia:1.4.1 julia -J /MakieSys.so
```

If you want to `include(…)` a Julia script that displays a Makie.jl scene, call `AbstractPlotting.__init__()` after `using Makie`.

### Option 2: Run a specific Julia script

```
$ podman run -it --rm -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ -v /dev/dri:/dev/dri \
-v "$PWD":/mnt -w /mnt makie-on-julia:1.4.1 julia -J /MakieSys.so <script.jl>
```

#### Side note

No matter if you run a Julia script with a Makie.jl scene via `julia <script.jl>` natively or in a container,
you want the window to stay open after `display(scene)`.

I found a nice way on how to achieve that:
```
Observables.on(o -> if !o[] exit() end, scene.events.window_open)
display(scene)
readline()
```

* `readline()` makes sure the script doesn't exit immediately
* An additional listener keeps track of the window state. Once you close it, the program exits

### Notes

* We mount `$PWD`, so we can access its files
* If you want the container to be kept, remove `--rm` and give it a `--name <container name>`

## Examples

### Option 1: Julia REPL

Our `test.jl`:
```
using Makie

AbstractPlotting.__init__() # very important!

x = rand(10)
y = rand(10)
colors = rand(10)
scene = scatter(x, y, color = colors)

display(scene)
```

Start REPL and run `test.jl`:
```
$ podman run -it --rm -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ -v /dev/dri:/dev/dri \
-v "$PWD":/mnt -w /mnt makie-on-julia:1.4.1 julia -J /MakieSys.so test.jl

julia> 1 + 2
3

julia> include("test.jl")
```

### Option 2: Run a specific Julia script directly

Our `test.jl`:
```
using Makie
import Observables

x = rand(10)
y = rand(10)
colors = rand(10)
scene = scatter(x, y, color = colors)

Observables.on(o -> if !o[] exit() end, scene.events.window_open)
display(scene)
readline()
```

Run `test.jl`:
```
$ podman run -it --rm -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ -v /dev/dri:/dev/dri \
-v "$PWD":/mnt -w /mnt makie-on-julia:1.4.1 julia -J /MakieSys.so test.jl
```

### Screenshot

![Makie.jl scene with terminal in background](screenshot.png)

## Links

* The Julia Language: https://julialang.org/
* Makie.jl: http://makie.juliaplots.org/