# Firewall Filter Playbooks

Плейбуки для настройки firewall на MikroTik роутерах.

---

## ПЕРЕД ЗАПУСКОМ (ОБЯЗАТЕЛЬНО!)

### 1. Создай interface lists

```bash
ansible-playbook mikrotik/interface-lists.yml -l <router>
```

Или в Semaphore: шаблон `interface-lists`

### 2. Добавь интерфейсы в списки (НА РОУТЕРЕ!)

```
/interface list member add list=WAN interface=ether1
/interface list member add list=LAN interface=bridge
```

**Замени `ether1` и `bridge` на свои интерфейсы!**

### 3. Проверь что списки НЕ пустые

```
/interface list member print
```

Должно быть:
```
# LIST      INTERFACE
0 WAN       ether1
1 LAN       bridge
```

**Если пусто — firewall заблокирует всё!**

### 4. Проверь safe_ip

В `00-safe-access.yml` переменная `safe_ip` = твой внешний IP.
Проверь свой IP: https://2ip.ru

---

## ВОССТАНОВЛЕНИЕ ДОСТУПА

Если заблокировался:

1. Зайди через Winbox по MAC или по локальной сети
2. Удали блокирующее правило:
```
/ip firewall filter remove [find comment="Drop all other to router"]
```
3. Проверь `/interface list member print`
4. Добавь интерфейсы в списки
5. Запусти `99-drop-all.yml` отдельно

---

## Структура файлов

```
firewall-full.yml       — главный, вызывает все по порядку

=== ПОРЯДОК ВЫПОЛНЕНИЯ ===

1. Защита и очистка
   00-safe-access.yml   — защита доступа с твоего IP
   01-cleanup.yml       — удаляет ВСЕ старые правила

2. Правила В цепочках (сначала наполняем цепочки!)
   10-brute-force.yml   — защита от перебора паролей
   11-lan-input.yml     — LAN → роутер
   12-isp-input.yml     — WAN → роутер
   13-guest-input.yml   — GUEST → роутер
   14-vpn-input.yml     — VPN → роутер
   20-lan-forward.yml   — LAN → наружу
   21-isp-forward.yml   — WAN → внутрь
   22-guest-forward.yml — GUEST → наружу
   23-vpn-forward.yml   — VPN → наружу

3. Jump правила (прыгаем в заполненные цепочки)
   02-input-jumps.yml   — jump правила для chain=input
   03-forward-jumps.yml — jump правила для chain=forward

4. Финальные drop (В САМОМ КОНЦЕ!)
   99-drop-all.yml      — drop all для input и forward

=== КАСТОМНЫЕ ===
Mik_mom_firewall_custom_rules.yml — RDP к серверу 242
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

## Кастомные правила для конкретных роутеров

Для Mik_mom есть специфичные правила (RDP к серверу 242).

Порядок запуска:

1. Сначала `firewall-full.yml` с Limit: Mik_mom
2. Потом `Mik_mom_firewall_custom_rules.yml`

В Semaphore:

```
Name: MikroTik FW: Mik_mom Custom Rules
Path: mikrotik/firewall-filter/Mik_mom_firewall_custom_rules.yml
Inventory: mikrotik
Limit: Mik_mom
```

## Добавление новых правил

Просто создай файл с нужным номером:

- `15-iot-input.yml` — новые Input правила
- `24-iot-forward.yml` — новые Forward правила

Добавь его в `firewall-full.yml`:

```yaml
- import_playbook: 15-iot-input.yml
```

Перенумеровывать остальные файлы не нужно.

---

## CHECKLIST (перед запуском)

```
[ ] Interface list WAN создан
[ ] Interface list LAN создан
[ ] Интерфейс WAN добавлен в список WAN (/interface list member)
[ ] Интерфейс LAN добавлен в список LAN (/interface list member)
[ ] safe_ip в 00-safe-access.yml = мой внешний IP
[ ] Запущен firewall-full.yml
[ ] Проверен доступ из LAN
[ ] Проверен доступ с внешнего IP
```