#!/usr/bin/env python3
"""
Парсер VLESS/VMess URL в формат mihomo proxies.yaml
Использование: python parse_proxy_urls.py input.txt output.yaml
"""

import sys
import json
import base64
import re
from urllib.parse import urlparse, parse_qs, unquote


def parse_vless_url(url):
    """Парсит vless:// URL в dict для mihomo"""
    # vless://uuid@server:port?params#name
    url = url.strip()
    if not url.startswith('vless://'):
        return None

    # Убираем vless://
    rest = url[8:]

    # Разделяем по #
    if '#' in rest:
        rest, name = rest.rsplit('#', 1)
        name = unquote(name)
    else:
        name = None

    # Разделяем по ?
    if '?' in rest:
        rest, params_str = rest.split('?', 1)
        params = parse_qs(params_str)
    else:
        params = {}

    # uuid@server:port
    if '@' not in rest:
        return None
    uuid, server_port = rest.split('@', 1)

    if ':' in server_port:
        server, port = server_port.rsplit(':', 1)
        # Убираем мусор из порта (иногда бывает "443/" или "443,")
        port = ''.join(c for c in port if c.isdigit())
    else:
        server = server_port
        port = '443'

    # Проверка валидности
    if not port or not server:
        return None

    # Получаем параметры
    network = params.get('type', ['tcp'])[0]
    security = params.get('security', [''])[0]
    sni = params.get('sni', [''])[0]
    host = params.get('host', [''])[0]
    path = unquote(params.get('path', [''])[0])
    fp = params.get('fp', [''])[0]
    pbk = params.get('pbk', [''])[0]
    sid = params.get('sid', [''])[0]
    flow = params.get('flow', [''])[0]

    # Генерируем имя если не задано
    if not name or name == 'none':
        name = f"vless-{server}:{port}"

    # Базовая структура
    proxy = {
        'name': name,
        'type': 'vless',
        'server': server,
        'port': int(port),
        'uuid': uuid,
        'network': network,
        'udp': True
    }

    # TLS/Reality
    if security == 'tls':
        proxy['tls'] = True
        if sni:
            proxy['servername'] = sni
        if fp:
            proxy['client-fingerprint'] = fp
    elif security == 'reality':
        proxy['tls'] = True
        proxy['reality-opts'] = {
            'public-key': pbk
        }
        if sid:
            proxy['reality-opts']['short-id'] = sid
        if sni:
            proxy['servername'] = sni
        if fp:
            proxy['client-fingerprint'] = fp
        if flow:
            proxy['flow'] = flow
    else:
        proxy['tls'] = False

    # Network specific options
    if network == 'ws':
        ws_opts = {}
        if path:
            ws_opts['path'] = path
        if host:
            ws_opts['headers'] = {'Host': host}
        if ws_opts:
            proxy['ws-opts'] = ws_opts
    elif network == 'grpc':
        if path:
            proxy['grpc-opts'] = {'grpc-service-name': path}

    return proxy


def parse_vmess_url(url):
    """Парсит vmess:// URL в dict для mihomo"""
    url = url.strip()
    if not url.startswith('vmess://'):
        return None

    # vmess://base64
    b64 = url[8:]

    # Добавляем padding если нужно
    padding = 4 - len(b64) % 4
    if padding != 4:
        b64 += '=' * padding

    try:
        data = json.loads(base64.b64decode(b64).decode('utf-8'))
    except Exception as e:
        print(f"Error decoding vmess: {e}", file=sys.stderr)
        return None

    server = data.get('add', '')
    port = int(data.get('port', 443))
    uuid = data.get('id', '')
    network = data.get('net', 'tcp')
    path = data.get('path', '')
    host = data.get('host', '')
    tls = data.get('tls', '') == 'tls'
    sni = data.get('sni', '')
    ps = data.get('ps', '')
    aid = int(data.get('aid', 0))
    scy = data.get('scy', 'auto')

    # Генерируем имя
    name = ps if ps else f"vmess-{server}:{port}"

    proxy = {
        'name': name,
        'type': 'vmess',
        'server': server,
        'port': port,
        'uuid': uuid,
        'alterId': aid,
        'cipher': scy,
        'network': network,
        'tls': tls,
        'udp': True
    }

    if tls and sni:
        proxy['servername'] = sni

    if network == 'ws':
        ws_opts = {}
        if path:
            ws_opts['path'] = path
        if host:
            ws_opts['headers'] = {'Host': host}
        if ws_opts:
            proxy['ws-opts'] = ws_opts

    return proxy


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} input.txt output.yaml")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    proxies = []
    seen_names = set()

    with open(input_file, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue

            proxy = None
            try:
                if line.startswith('vless://'):
                    proxy = parse_vless_url(line)
                elif line.startswith('vmess://'):
                    proxy = parse_vmess_url(line)
            except Exception as e:
                print(f"Warning: failed to parse: {line[:50]}... ({e})", file=sys.stderr)
                continue

            if proxy:
                # Уникализируем имена
                base_name = proxy['name']
                counter = 1
                while proxy['name'] in seen_names:
                    proxy['name'] = f"{base_name}-{counter}"
                    counter += 1
                seen_names.add(proxy['name'])
                proxies.append(proxy)

    # Генерируем YAML вручную для правильного форматирования
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("proxies:\n")
        for p in proxies:
            f.write(f"  - name: \"{p['name']}\"\n")
            f.write(f"    type: {p['type']}\n")
            f.write(f"    server: {p['server']}\n")
            f.write(f"    port: {p['port']}\n")
            f.write(f"    uuid: {p['uuid']}\n")

            if p['type'] == 'vmess':
                f.write(f"    alterId: {p.get('alterId', 0)}\n")
                f.write(f"    cipher: {p.get('cipher', 'auto')}\n")

            f.write(f"    network: {p['network']}\n")
            f.write(f"    tls: {str(p.get('tls', False)).lower()}\n")
            f.write(f"    udp: true\n")

            if p.get('flow'):
                f.write(f"    flow: {p['flow']}\n")

            if p.get('servername'):
                f.write(f"    servername: {p['servername']}\n")

            if p.get('client-fingerprint'):
                f.write(f"    client-fingerprint: {p['client-fingerprint']}\n")

            if p.get('reality-opts'):
                f.write("    reality-opts:\n")
                f.write(f"      public-key: {p['reality-opts']['public-key']}\n")
                if p['reality-opts'].get('short-id'):
                    f.write(f"      short-id: {p['reality-opts']['short-id']}\n")

            if p.get('ws-opts'):
                f.write("    ws-opts:\n")
                if p['ws-opts'].get('path'):
                    f.write(f"      path: {p['ws-opts']['path']}\n")
                if p['ws-opts'].get('headers'):
                    f.write("      headers:\n")
                    for k, v in p['ws-opts']['headers'].items():
                        f.write(f"        {k}: {v}\n")

            if p.get('grpc-opts'):
                f.write("    grpc-opts:\n")
                f.write(f"      grpc-service-name: {p['grpc-opts']['grpc-service-name']}\n")

            f.write("\n")

    print(f"Parsed {len(proxies)} proxies to {output_file}")


if __name__ == '__main__':
    main()
