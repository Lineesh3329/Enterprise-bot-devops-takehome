import json
import os
import socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


def get_config(env_name, file_name, default):
    # Support live ConfigMap updates through mounted files.
    config_file = Path("/etc/app-config") / file_name
    try:
        return config_file.read_text().strip()
    except OSError:
        return os.environ.get(env_name, default)


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/healthz":
            body = b'{"status":"ok"}'
            self.send_response(200)
        elif self.path == "/":
            response = {
                "app": get_config("APP_NAME", "appName", "demo-app"),
                "version": get_config("VERSION", "version", "1.0.0"),
                "pod": socket.gethostname(),
            }
            body = json.dumps(response).encode()
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
