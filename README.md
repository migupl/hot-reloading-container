# Hot Reloading Container

A hot reloading container for small web developments.

## Guide

This container is running a server with live reload capabilities using the [live-server](https://www.npmjs.com/package/live-server) package on a base [node:19-alpine](https://hub.docker.com/_/node) image.

If a file ~/.live-server.json exists it will be loaded and used as default options for live-server. See live-server documentation for more information.

An example ~/.live-server.json

```JSON
var liveServer = require("live-server");

var params = {
    // When false, it won't load your browser by default.
    open: false,
    // 0 = errors only, 1 = some, 2 = lots
    logLevel: 2,
    // When set, serve this file (server root relative) for every 404 (useful for single-page applications)
    file: "./index.html"
};
liveServer.start(params);
```

[Makefile](https://makefiletutorial.com/) is used to simplify the commands required for:

*Start the container*

```bash
$ make start
```

*Stop the container*

```bash
$ make stop
```

*Executing into the container*

```bash
$ make shell
```

and, *remove the container image*

```bash
$ make clean
```

To use this function you need to have either [Podman](https://podman.io/) or [Docker](https://www.docker.com/) installed.

**Makefile is configuring the container** with:
- `cwd`as working directory
- Redirect the container port 8080 (default port for live-server) to port 8000

Using http://localhost:8000/ without a .live-server.json file you get

![localhost:8000](./image/localhost_8000.webp)

Good luck, I hope you enjoy it.

## License

[MIT license](http://www.opensource.org/licenses/mit-license.php)