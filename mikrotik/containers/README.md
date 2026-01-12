# MikroTik Containers

Ansible плейбуки для управления Docker контейнерами на MikroTik RouterOS.

## Структура

```
containers/
├── shared/                     # Общие плейбуки (вызываются из мастер-плейбуков)
│   ├── 01_network.yml          # Bridge-Docker + NAT + DNS
│   ├── 02_smb_mount.yml        # SMB share + монтирование
│   ├── vars_common.yml         # Общие переменные
│   └── tasks/                  # Переиспользуемые tasks
│       ├── checks.yml          # Проверки USB, registry, bridge
│       ├── cleanup.yml         # Остановка и удаление контейнера
│       ├── auto_ip.yml         # Автоопределение IP
│       └── create_veth.yml     # Создание veth интерфейса
│
├── mihomo/                     # Контейнер mihomo (прокси)
│   ├── mihomo_awg.yml          # Мастер-плейбук AWG режим
│   ├── mihomo_vless.yml        # Мастер-плейбук VLESS режим
│   ├── 03_configs_awg.yml      # Конфиги для AWG
│   ├── 03_configs_vless.yml    # Конфиги для VLESS
│   ├── 04_container.yml        # Создание контейнера
│   ├── delete.yml              # Удаление
│   ├── update_subscription.yml # Обновление подписок
│   ├── vars.yml                # Переменные
│   └── configs/                # Конфиги mihomo
│
├── zapret2/                    # Контейнер zapret2 (DPI bypass)
│   ├── zapret2.yml             # Мастер-плейбук
│   ├── 03_config.yml           # Подготовка конфига
│   ├── 04_container.yml        # Создание контейнера
│   ├── 05_routing.yml          # Routing table
│   ├── delete.yml              # Удаление
│   └── vars.yml                # Переменные
│
├── configs/                    # Общие конфиги (используются разными контейнерами)
│   ├── awg/                    # AmneziaWG конфиги (*.conf)
│   ├── vless/                  # VLESS/VMess прокси
│   └── srv/                    # Серверные прокси
│
├── scripts/                    # Скрипты
│   └── parse_proxy_urls.py     # Парсер VLESS/VMess URL
│
├── container_package.yml       # Установка пакета container
├── container_mode.yml          # Включение container mode
├── usb_format.yml              # Форматирование USB в ext4
├── delete_container.yml        # Универсальное удаление
└── test_connection.yml         # Тест подключения
```

## Быстрый старт

### 1. Подготовка роутера (один раз)

```bash
# Установить пакет container
ansible-playbook container_package.yml -l Mik_Tim

# Включить container mode (требует power cycle!)
ansible-playbook container_mode.yml -l Mik_Tim

# Отформатировать USB в ext4
ansible-playbook usb_format.yml -l Mik_Tim
```

### 2. Установка mihomo (AWG режим)

```bash
ansible-playbook mihomo/mihomo_awg.yml -l Mik_Tim
```

### 3. Установка mihomo (VLESS режим)

```bash
ansible-playbook mihomo/mihomo_vless.yml -l Mik_Tim
```

### 4. Установка zapret2 (DPI bypass)

```bash
ansible-playbook zapret2/zapret2.yml -l Mik_Tim
```

## Удаление

```bash
# Удалить mihomo
ansible-playbook mihomo/delete.yml -l Mik_Tim

# Удалить zapret2
ansible-playbook zapret2/delete.yml -l Mik_Tim

# Универсальное удаление
ansible-playbook delete_container.yml -l Mik_Tim -e container_name="Имя"
```

## Принципы

1. **DRY (Don't Repeat Yourself)** — общий код в `shared/`
2. **Модульность** — мастер-плейбуки импортируют другие плейбуки
3. **Идемпотентность** — повторный запуск даёт тот же результат
