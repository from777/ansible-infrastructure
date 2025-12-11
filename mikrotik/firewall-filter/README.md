# Firewall Filter Playbooks

Плейбуки для настройки firewall на MikroTik роутерах.

## Структура файлов

```
firewall-full.yml       — главный, вызывает все по порядку

0x — подготовка и структура
00-safe-access.yml      — защита доступа с IP 212.20.46.209
01-cleanup.yml          — удаляет ВСЕ старые правила
02-input-jumps.yml      — jump правила для chain=input
03-forward-jumps.yml    — jump правила для chain=forward

1x — Input chains (трафик К роутеру)
10-brute-force.yml      — защита от перебора паролей
11-lan-input.yml        — LAN → роутер
12-isp-input.yml        — WAN → роутер
13-guest-input.yml      — GUEST → роутер (пропустит если нет GUEST)
14-vpn-input.yml        — VPN → роутер (пропустит если нет VPN-OUT)

2x — Forward chains (трафик ЧЕРЕЗ роутер)
20-lan-forward.yml      — LAN → наружу
21-isp-forward.yml      — WAN → внутрь
22-guest-forward.yml    — GUEST → наружу (пропустит если нет GUEST)
23-vpn-forward.yml      — VPN → наружу (пропустит если нет VPN-OUT)
```

## Как запускать

### Полная настройка (удалит старые правила!)

В Semaphore:

```
Name: MikroTik FW: Full Setup
Path: mikrotik/firewall-filter/firewall-full.yml
Inventory: mikrotik
Vaults: Mik_Tim vault-password
Limit: Mik_mom (для теста)
```

### Только часть (без удаления старых)

```
Path: mikrotik/firewall-filter/11-lan-input.yml
```

## Автоопределение

Плейбуки 13, 14, 22, 23 сами проверяют есть ли interface-list GUEST/VPN-OUT.
Если нет — пропускают. Можно запускать на любом роутере.

## Порядок правил после выполнения

```
chain=input:
  0. SAFE-ACCESS (защита доступа)
  1. jump → LAN-Input
  2. jump → ISP-Input
  3. jump → VPN-Input (если есть)
  4. jump → GUEST-Input (если есть)
  5. drop all

chain=forward:
  1. jump → ISP-Forward
  2. jump → VPN-Forward (если есть)
  3. jump → LAN-Forward
  4. jump → GUEST-Forward (если есть)
  5. drop all
```

## ВНИМАНИЕ

`01-cleanup.yml` удаляет ВСЕ правила кроме SAFE-ACCESS!

Если нужно добавить правила к существующим — запускай отдельные файлы, НЕ firewall-full.yml.

## Добавление новых правил

Просто создай файл с нужным номером:

- `15-iot-input.yml` — новые Input правила
- `24-iot-forward.yml` — новые Forward правила

Добавь его в `firewall-full.yml`:

```yaml
- import_playbook: 15-iot-input.yml
```

Перенумеровывать остальные файлы не нужно.