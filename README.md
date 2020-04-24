# Makie.jl on Julia OCI Image

Julia OCI image with precompiled Makie.jl on top of it.

*Didn't have the chance to test it with Docker's tools yet, only with buildah/podman.*

## Build image

```
$ buildah bud -t makie-on-julia:1.4.1 .
```

*For docker, replace `buildah bud` by `docker build`.*

## Run

Julia REPL:
```
$ podman run -it --rm -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ -v /dev/dri:/dev/dri -v "$PWD":/mnt -w /mnt makie-on-julia:1.4.1 julia -J /MakieSys.so
```

Specific Julia script:
```
$ podman run -it --rm -e DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix/ -v /dev/dri:/dev/dri -v "$PWD":/mnt -w /mnt makie-on-julia:1.4.1 julia -J /MakieSys.so <script.jl>
```

We mount `$PWD`, so we can access its files.

If you want the container to be kept, remove `--rm` and give it a `--name <container name>`.

*For docker, replace `podman` by `docker`.*

## Side note

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

## Links

* The Julia Language: https://julialang.org/
* Makie.jl: http://makie.juliaplots.org/