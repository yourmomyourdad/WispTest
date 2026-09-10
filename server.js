const http = require("node:http");
const fs = require("node:fs");
const path = require("node:path");

const { server: wisp } = require("@mercuryworkshop/wisp-js/server");

const PORT = process.env.PORT || 5001;
const PUBLIC = path.join(__dirname, "public");

const MIME_TYPES = {
    ".html": "text/html",
    ".js": "application/javascript",
    ".css": "text/css",
    ".json": "application/json",
    ".wasm": "application/wasm",
    ".png": "image/png",
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".gif": "image/gif",
    ".svg": "image/svg+xml",
    ".ico": "image/x-icon"
};

const server = http.createServer((req, res) => {
    let urlPath = decodeURIComponent(req.url.split("?")[0]);

    // Serve the Scramjet browser
    if (urlPath === "/") {
        urlPath = "/index.html";
    }

    const filePath = path.join(PUBLIC, urlPath);

    // Prevent escaping the public directory
    if (!filePath.startsWith(PUBLIC)) {
        res.writeHead(403);
        res.end("Forbidden");
        return;
    }

    fs.readFile(filePath, (err, data) => {
        if (err) {
            res.writeHead(404, {
                "Content-Type": "text/plain"
            });

            res.end("Not found");
            return;
        }

        const ext = path.extname(filePath);

        res.writeHead(200, {
            "Content-Type": MIME_TYPES[ext] || "application/octet-stream"
        });

        res.end(data);
    });
});

// Wisp WebSocket endpoint
server.on("upgrade", (req, socket, head) => {
    console.log("WebSocket connection:", req.url);

    if (req.url.startsWith("/wisp/")) {
        wisp.routeRequest(req, socket, head);
    } else {
        socket.destroy();
    }
});

server.listen(PORT, "0.0.0.0", () => {
    console.log(`Scramjet browser + Wisp running on port ${PORT}`);
});
