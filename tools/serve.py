#!/usr/bin/env python3
"""Local static preview. No cross-origin isolation is needed for this Web export."""
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--port", type=int, default=8060)
args = parser.parse_args()
root = Path(__file__).resolve().parent.parent / "builds" / "web"
if not (root / "index.html").exists():
    raise SystemExit("Run tools/build_web.sh first.")

class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(root), **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()

print(f"Re:boot Web: http://127.0.0.1:{args.port}", flush=True)
ThreadingHTTPServer(("127.0.0.1", args.port), Handler).serve_forever()
