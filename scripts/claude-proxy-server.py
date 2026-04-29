#!/usr/bin/env python3
"""
HTTP proxy server that bridges Avante.nvim to Claude CLI
Listens on http://localhost:51001 and forwards requests to Claude CLI
"""

import json
import subprocess
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse
import threading

class ClaudeProxyHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        # Log the incoming request path
        print(f"[Claude Proxy] Received POST request to: {self.path}", flush=True)

        # Parse the request
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8')

        try:
            request_data = json.loads(body)
            print(f"[Claude Proxy] Request data: {json.dumps(request_data, indent=2)[:200]}", flush=True)
        except json.JSONDecodeError as e:
            print(f"[Claude Proxy] JSON decode error: {e}", flush=True)
            self.send_error(400, "Invalid JSON")
            return

        # Extract messages from request
        messages = request_data.get('messages', [])
        model = request_data.get('model', 'claude-sonnet-4.5')
        stream = request_data.get('stream', True)

        # Build prompt from messages
        prompt = self._build_prompt_from_messages(messages)
        print(f"[Claude Proxy] Built prompt: {prompt[:100]}...", flush=True)

        if not prompt:
            self.send_error(400, "No prompt provided")
            return

        # Prepare headers for streaming response
        self.send_response(200)
        self.send_header('Content-Type', 'text/event-stream')
        self.send_header('Cache-Control', 'no-cache')
        self.send_header('Connection', 'keep-alive')
        self.end_headers()

        # Call Claude CLI with prompt as argument
        try:
            print(f"[Claude Proxy] Calling Claude CLI...", flush=True)
            process = subprocess.Popen(
                ['claude', '--print', '--output-format', 'stream-json', '--verbose', '--allowed-tools', '', prompt],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1
            )

            # Stream the output
            for line in process.stdout:
                line = line.strip()
                if not line:
                    continue

                try:
                    # Parse Claude CLI output
                    claude_response = json.loads(line)
                    response_type = claude_response.get('type')

                    print(f"[Claude Proxy] Received type: {response_type}", flush=True)

                    # Convert to OpenAI-compatible format for Avante
                    if response_type == 'assistant':
                        # Extract text from message content
                        message = claude_response.get('message', {})
                        content_blocks = message.get('content', [])

                        print(f"[Claude Proxy] Message content blocks: {len(content_blocks)}", flush=True)

                        for block in content_blocks:
                            if block.get('type') == 'text':
                                text = block.get('text', '')
                                print(f"[Claude Proxy] Sending text: {text[:100]}...", flush=True)
                                if text:
                                    sse_data = {
                                        'id': 'chatcmpl-claude',
                                        'object': 'chat.completion.chunk',
                                        'created': 0,
                                        'model': model,
                                        'choices': [{
                                            'index': 0,
                                            'delta': {'content': text},
                                            'finish_reason': None
                                        }]
                                    }
                                    self.wfile.write(f"data: {json.dumps(sse_data)}\n\n".encode())
                                    self.wfile.flush()
                                    print(f"[Claude Proxy] Sent SSE data", flush=True)

                    elif response_type == 'result':
                        # Send final message
                        sse_data = {
                            'id': 'chatcmpl-claude',
                            'object': 'chat.completion.chunk',
                            'created': 0,
                            'model': model,
                            'choices': [{
                                'index': 0,
                                'delta': {},
                                'finish_reason': 'stop'
                            }]
                        }
                        self.wfile.write(f"data: {json.dumps(sse_data)}\n\n".encode())
                        self.wfile.write(b"data: [DONE]\n\n")
                        self.wfile.flush()

                except json.JSONDecodeError as e:
                    print(f"[Claude Proxy] JSON decode error: {e}", flush=True)
                    continue

            process.wait()

        except Exception as e:
            error_msg = f"Error calling Claude CLI: {str(e)}"
            print(error_msg, file=sys.stderr)
            self.wfile.write(f"data: {json.dumps({'error': error_msg})}\n\n".encode())

    def _build_prompt_from_messages(self, messages):
        """Build a prompt string from message array"""
        prompt_parts = []
        for msg in messages:
            role = msg.get('role', 'user')
            content = msg.get('content', '')

            if role == 'system':
                prompt_parts.append(f"System: {content}")
            elif role == 'user':
                prompt_parts.append(content)
            elif role == 'assistant':
                prompt_parts.append(f"Assistant: {content}")

        return '\n\n'.join(prompt_parts)

    def log_message(self, format, *args):
        """Custom logging"""
        print(f"[Claude Proxy] {format % args}")

def run_server(port=51001):
    server_address = ('127.0.0.1', port)
    httpd = HTTPServer(server_address, ClaudeProxyHandler)
    print(f"Claude proxy server running on http://127.0.0.1:{port}")
    print("Press Ctrl+C to stop")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server...")
        httpd.shutdown()

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 51001
    run_server(port)
