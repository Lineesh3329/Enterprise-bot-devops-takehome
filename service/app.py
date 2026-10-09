import json
import os
import socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


def get_config(name, default):
    config_file = Path("/etc/app-config") / name
    try:
        return config_file.read_text().strip()
    except OSError:
        return os.getenv(name.upper(), default)


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/healthz":
            body = b'{"status":"ok"}'
            self.send_response(200)
        elif self.path == "/":
            body = json.dumps({
                "app": get_config("appName", "demo-app"),
                "version": get_config("version", "1.0.0"),
                "pod": socket.gethostname(),
            }).encode()
            self.send_response(200)
        else:
            self.send_error(404)
            return

        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    print("Starting app on port 8080", flush=True)
    ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
