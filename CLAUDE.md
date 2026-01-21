# Lessons Learned - Ошибки и решения

## Общие правила

### 16. Отвечать на ВСЕ вопросы пользователя

**Правило:** ВСЕГДА отвечать на КАЖДЫЙ вопрос пользователя. Если пользователь задал несколько вопросов в одном сообщении — ответить на все, ни один не пропускать.

**Неправильно:**
```
Пользователь: "Путь \\192.168.0.1\usb1\docker\ правильный? И как запустить контейнер?"
Ответ: "Вот команда для запуска контейнера..."  # НЕ ответил про путь!
```

**Правильно:**
```
Пользователь: "Путь \\192.168.0.1\usb1\docker\ правильный? И как запустить контейнер?"
Ответ: "Да, путь правильный. Команда для запуска: ..."  # Ответил на ОБА вопроса
```

---

### 15. Всегда писать на русском языке

**Правило:** Все ответы, объяснения и комментарии писать на русском языке. Код и команды — на английском (синтаксис), но пояснения к ним — на русском.

---

## Архитектурные принципы

### Inventory = Single Source of Truth

**Принцип:** `inventory.yml` — единственный источник правды для всей инфраструктуры.

**Правила:**
1. Все внешние системы (Zabbix, ELK, и т.д.) должны **синхронизироваться ИЗ inventory**, а не накапливать данные
2. Если хост/ресурс есть в inventory с флагом `true` — он должен существовать в системе
3. Если хост/ресурс имеет флаг `false` или удалён из inventory — он должен быть **удалён из системы**
4. Playbooks реализуют модель **желаемого состояния** (desired state), а не аддитивную модель

**Структура флагов в inventory:**
```yaml
mikrotik:
  hosts:
    Router_Name:
      ansible_host: 192.168.0.1
      zabbix_monitor: true    # sync → Zabbix hosts
      monitor_socks: true     # sync → Zabbix SOCKS template
      monitor_users: true     # sync → Zabbix Users template
      elk_logging: true       # sync → ELK/Filebeat (будущее)
```

**Playbook должен:**
1. Получить желаемое состояние из inventory (флаги)
2. Получить текущее состояние из внешней системы
3. **Создать** то, чего нет
4. **Удалить** то, чего не должно быть (orphans)
5. **Обновить** то, что изменилось

**Пример синхронизации:**
```yaml
# 1. Получаем что ДОЛЖНО быть (из inventory)
- name: Build hosts to ADD
  set_fact:
    hosts_to_add: "{{ hosts_to_add + [item] }}"
  loop: "{{ groups['mikrotik'] }}"
  when: hostvars[item].zabbix_monitor | default(false)

# 2. Получаем что ЕСТЬ в системе
- name: Get all hosts from Zabbix
  uri:
    method: POST
    body:
      method: "host.get"
  register: zabbix_hosts

# 3. Находим orphans (есть в системе, но нет в inventory)
- name: Find orphan hosts
  set_fact:
    orphan_hosts: "{{ orphan_hosts + [item.host] }}"
  loop: "{{ zabbix_hosts.json.result }}"
  when: item.host not in groups['mikrotik']

# 4. Удаляем orphans
- name: Delete orphan hosts
  include_tasks: delete-host.yml
  loop: "{{ orphan_hosts }}"
```

---

## MikroTik RouterOS + Ansible

### 1. Кавычки в командах [find ...]

**Проблема:** Команды с `[find name="{{ variable }}"]` не работают через Ansible.

**Неправильно:**
```yaml
- community.routeros.command:
    commands:
      - /container remove [find name="{{ container_name }}"]
      - /interface bridge port remove [find interface="{{ container_name }}"]
```

**Правильно:**
```yaml
- community.routeros.command:
    commands:
      - /container remove [find name={{ container_name }}]
      - /interface bridge port remove [find interface={{ container_name }}]
```

**Причина:** MikroTik RouterOS не требует кавычек внутри `[find ...]` для значений без пробелов. Двойные кавычки от Ansible + кавычки в команде создают конфликт.

---

### 2. Порядок удаления контейнера в MikroTik

**Правильный порядок (проверено):**
1. `/container stop [find name=xxx]` - остановить
2. `/container remove [find name=xxx]` - удалить контейнер
3. `/interface bridge port remove [find interface=xxx]` - удалить порт из bridge
4. `/interface veth remove [find name=xxx]` - удалить veth
5. `/container mounts remove [find name=xxx_conf]` - удалить mount
6. `/container envs remove [find list=xxx_env]` - удалить envlist

**Важно:**
- Порт из bridge удалять ПОСЛЕ удаления контейнера (не до!)
- Если удалить раньше - порт станет "unknown" и потеряет имя
- veth удалять последним из сетевых компонентов

---

### 3. Не использовать сложные условия when с count-only

**Проблема:** Проверки типа `when: result.stdout[0] | int > 0` могут не срабатывать корректно.

**Лучше:** Просто выполнять команду с `ignore_errors: yes` - если объект не существует, MikroTik просто ничего не сделает.

```yaml
- name: Удалить что-то
  community.routeros.command:
    commands:
      - /container remove [find name={{ container_name }}]
  ignore_errors: yes
```

---

### 4. Геобаза geoip.metadb для новых контейнеров

**Проблема:** Новый контейнер mihomo не может скачать geoip.metadb если нет интернета (DNS не работает при первом запуске).

**Решение:** В плейбуке 03_configs*.yml автоматически:
1. Искать geoip.metadb в папках других контейнеров
2. Копировать в новый контейнер
3. Если нигде нет - скачивать с GitHub заранее

---

### 5. Не хардкодить IP адреса в playbooks

**Проблема:** IP адреса прописанные напрямую в playbook усложняют поддержку и переиспользование.

**Неправильно:**
```yaml
vars:
  zabbix_url: "http://192.168.0.68/api_jsonrpc.php"
  elk_server: "192.168.0.82"
```

**Правильно:**
```yaml
# IP берётся из inventory
hosts: zabbix
vars:
  zabbix_url: "http://{{ ansible_host }}/api_jsonrpc.php"

# Или из host_vars
vars:
  elk_url: "http://{{ elk_server }}:9200"  # elk_server определён в inventory
```

**Правило:** Все IP адреса должны быть в:
- `inventory.yml` → `ansible_host`
- `host_vars/*.yml` → дополнительные IP (elk_server и т.д.)
- `group_vars/*.yml` → общие для группы

---

### 6. Debug playbooks - один файл на папку

**Правило:** Все debug tasks для одной папки (например `zabbix/`) писать в ОДИН файл `debug.yml`, а не создавать отдельные файлы для каждой проверки.

**Неправильно:**
```
zabbix/debug-alerts.yml
zabbix/debug-host-group.yml
zabbix/debug-telegram.yml
```

**Правильно:**
```
zabbix/debug.yml  # все debug tasks в одном файле
```

---

### 7. Task Template в Semaphore - указывать параметры

**Правило:** Когда просишь создать Task Template, ВСЕГДА указывать параметры:
- Name
- Playbook (полный путь)
- Inventory
- Vault (нужен или нет)
- Environment (если нужно)

---

### 8. Всегда указывать изменённые файлы

**Правило:** В конце ответа ВСЕГДА указывать список изменённых/добавленных/удалённых playbooks:

```
**Изменённые файлы:**
- ✏️ Изменён: zabbix/setup-telegram.yml
- ➕ Добавлен: zabbix/new-playbook.yml
- ❌ Удалён: zabbix/old-playbook.yml (удали Task Template в Semaphore!)
```

Если удалён playbook — напомнить удалить Task Template в Semaphore.

---

### 9. Идемпотентность playbooks - удалять и создавать заново

**Правило:** Все playbooks должны работать по принципу идемпотентности — при повторном запуске результат должен быть одинаковым. Для ресурсов которые нельзя обновить через API — **удалять и создавать заново**.

**Неправильно:**
```yaml
- name: Create trigger
  when: trigger_check.json.result | length == 0  # только создаёт новый
```

**Правильно:**
```yaml
- name: Delete existing trigger
  when: trigger_check.json.result | length > 0
  # удаляем существующий

- name: Create trigger
  # создаём с новыми параметрами
```

---

### 10. Минимизировать ручную работу пользователя

**Правило:** Пользователь НЕ должен делать что-либо вручную в UI (Zabbix, Semaphore и т.д.). Всё должно делаться через playbooks.

**Плохо:** "Удали trigger вручную в Zabbix и запусти playbook"
**Хорошо:** Playbook сам удаляет старый trigger и создаёт новый

Исключение: создание Task Templates в Semaphore (пока нет API).

---

### 11. ВСЕГДА пушить изменения в GitHub

**Правило:** После ЛЮБЫХ изменений файлов — ОБЯЗАТЕЛЬНО делать `git add`, `git commit` и `git push`.

**Пользователь НЕ должен делать git push вручную!**

Если есть проблемы с git (конфликты, ошибки push, и т.д.) — писать об этом **отдельным блоком красным цветом**:

```
> **⚠️ ПРОБЛЕМА С GIT:** описание проблемы и что нужно сделать
```

---

### 12. Контейнеры MikroTik — искать по interface, не по name

**Проблема:** При создании контейнера без параметра `name=`, MikroTik присваивает ему имя образа (например `wiktorbgu/nfqws2-mikrotik:latest`), а не имя интерфейса.

**Неправильно:**
```yaml
- /container stop [find name={{ container_name }}]    # НЕ найдёт!
- /container remove [find name={{ container_name }}]  # НЕ найдёт!
```

**Правильно:**
```yaml
- /container stop [find interface={{ container_name }}]
- /container remove [find interface={{ container_name }}]
```

**Правило:** Всегда искать контейнеры по `interface=`, т.к. interface всегда соответствует имени veth который мы создаём.

---

### 13. При ошибках — СНАЧАЛА запросить логи

**Правило:** Если playbook или контейнер завершился с ошибкой — НЕ гадать причину, а СНАЧАЛА попросить пользователя предоставить логи.

**Неправильно:**
```
Контейнер упал. Возможно проблема в X, исправляю...
[делает изменения не видя реальной ошибки]
```

**Правильно:**
```
Контейнер упал. Покажи логи:
/log print where topics~"container"

[после получения логов]
Вижу ошибку: "wget: bad address 'api.github.com'" — проблема с DNS.
Исправляю...
```

**Какие логи запрашивать:**
- Контейнеры MikroTik: `/log print where topics~"container"`
- Ansible ошибки: полный вывод failed task
- Zabbix API: response body из ошибки
- Общие логи: `/log print count=50`

---

### 14. Inventory указывается в настройках Task, не в playbook

**Правило:** Путь к inventory файлу НЕ прописывается в playbook. Он указывается в **настройках Task** (Task Template) в Semaphore.

**Если playbook не находит хосты** (ошибка "No inventory was parsed", "Could not match supplied host pattern"):
- Проблема НЕ в playbook
- Проблема в настройках Task в Semaphore → поле **Inventory**
- Нужно указать правильный путь к `inventory.yml`

**Неправильно говорить:** "Измени настройки Semaphore"
**Правильно говорить:** "Измени настройки Task в Semaphore → поле Inventory"

---

### 15. Всегда указывать ГДЕ выполнять команды

**Правило:** При выдаче команд ВСЕГДА указывать где их выполнять:
- На роутере MikroTik
- Внутри контейнера (какого именно)
- На локальной машине
- На сервере Semaphore

**Неправильно:**
```
/opt/zapret2/init.d/sysv/zapret2 stop
./blockcheck2.sh --hosts=www.youtube.com
```

**Правильно:**
```
# Внутри контейнера NFQWS2:
/opt/zapret2/init.d/sysv/zapret2 stop
./blockcheck2.sh --hosts=www.youtube.com
```

или

```
# На роутере MikroTik:
/container shell [find interface=NFQWS2]

# Затем внутри контейнера:
/opt/zapret2/init.d/sysv/zapret2 stop
```

---

### 17. Повторное использование кода в playbooks (DRY)

**Правило:** ПЕРЕД написанием нового playbook — ОБЯЗАТЕЛЬНО проверить существующие playbooks на наличие похожего функционала. Если функционал уже реализован — использовать `import_playbook` или `include_tasks`.

**Неправильно:**
```yaml
# zapret2.yml — 333 строки, дублирует код из 04_container.yml
- name: Проверка USB
  # ... 10 строк кода (уже есть в 01b_network.yml)

- name: Создание veth
  # ... 20 строк кода (уже есть в 04_container.yml)
```

**Правильно:**
```yaml
# zapret2.yml — импортирует общие плейбуки
- import_playbook: ../shared/checks.yml
- import_playbook: ../shared/create_veth.yml
- import_playbook: container.yml  # только уникальная логика
```

**Обязательные действия:**
1. При создании нового плейбука — поискать похожий код в папке
2. Если найден похожий код (>10 строк) — вынести в shared/ или использовать существующий
3. Монолитные плейбуки (>100 строк) разбивать на модули

**Структура папки containers/:**
```
containers/
├── shared/              ← Общие плейбуки для всех контейнеров
│   ├── checks.yml       ← Проверки USB, registry, bridge
│   ├── cleanup.yml      ← Остановка и удаление контейнера
│   └── create_veth.yml  ← Создание veth + bridge port
├── mihomo/              ← Специфичное для mihomo
├── zapret2/             ← Специфичное для zapret2
└── delete_container.yml ← Универсальный плейбук удаления
```

---

### 18. Отчёт о повторном использовании кода

**Правило:** В конце каждого ответа, где создаётся/изменяется код, добавлять секцию:

```
**Повторное использование кода:**
- ✅ Использован существующий: shared/checks.yml (проверка USB)
- ✅ Использован существующий: 04_container.yml:67-90 (автоопределение IP)
- ⚠️ Дублирование: 20 строк совпадают с delete_container.yml — рекомендуется вынести в shared/
- ❌ Новый код: routing.yml (нет аналогов)
```

Это позволяет отслеживать дублирование и поддерживать DRY принцип.

---

### 19. ВСЕГДА читать документацию перед изменениями

**Правило:** ПЕРЕД любыми изменениями в playbook — ОБЯЗАТЕЛЬНО прочитать документацию связанных компонентов:

**Что читать:**
- Docker образы → Docker Hub (README, требования к версиям)
- Ansible модули → Ansible Galaxy / официальная документация
- RouterOS функции → MikroTik Wiki
- API → официальная документация API

**Неправильно:**
```
Контейнер упал с ошибкой "nftables not supported"
→ Сразу меняю INIT_APPLY_FW=0 (без чтения документации)
```

**Правильно:**
```
Контейнер упал с ошибкой "nftables not supported"
→ Читаю документацию на Docker Hub
→ Вижу: "Supported only on Mikrotik ROS >= 7.21rc1"
→ Сообщаю пользователю о требованиях к версии RouterOS
```

**Обязательные действия:**
1. При использовании Docker образа — читать README на Docker Hub
2. При ошибках — сначала проверить документацию на требования/ограничения
3. НЕ делать предположений о причинах ошибок без проверки документации

**Пример для nfqws2-mikrotik:**
- Docker Hub: https://hub.docker.com/r/wiktorbgu/nfqws2-mikrotik
- Требование: RouterOS >= 7.21rc1
- Без этой версии nftables в контейнерах НЕ работает

---

---

## Windows + Ansible (WinRM)

### 20. Для команд всегда указывать где выполнять

**Правило:** При выдаче команд для консоли ВСЕГДА указывать:
- Какой сервер (IP или имя)
- Под каким пользователем (Администратор, root, vagrant)
- Какая консоль (PowerShell, cmd, bash)

**Формат:**
```
**На Windows сервере (176.9.141.234) от Администратора:**
```powershell
команда
```

**На Semaphore (vagrant@semaphore):**
```bash
команда
```
```

---

### 21. Windows WinRM — использовать raw модуль

**Проблема:** Модули `win_ping`, `win_command`, `win_shell` используют PSRP (PowerShell Remoting Protocol), который может не работать на старых Windows Server (2012 R2) или при сетевых ограничениях.

**Решение:** Использовать модуль `raw` с PowerShell командами:

```yaml
# Вместо win_ping:
- raw: hostname
  register: result

# Вместо win_shell:
- raw: powershell -Command "Get-Service"
  register: result
```

**Когда использовать raw:**
- Windows Server 2012 / 2012 R2
- Таймауты при использовании win_* модулей
- Ошибки PSRP / InvalidSelectors

---

### 22. Windows WinRM — настройки подключения

**Рабочая конфигурация для старых Windows:**
```yaml
windows_servers:
  hosts:
    176.9.141.234:
  vars:
    ansible_connection: winrm
    ansible_winrm_transport: basic
    ansible_winrm_port: 5985        # HTTP (не HTTPS!)
    ansible_winrm_scheme: http
```

**На Windows сервере обязательно:**
```powershell
winrm quickconfig -transport:http -force
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
```

---

### 23. Windows Firewall — ограничить доступ по IP

**Правило:** После настройки WinRM ОБЯЗАТЕЛЬНО ограничить доступ только для своих IP.

**Важные IP пользователя:**
- 109.174.1.142 (Semaphore/основной)
- 212.20.46.209 (домашний)

**Команда:**
```powershell
netsh advfirewall firewall add rule name="WinRM HTTP Restricted" dir=in action=allow protocol=TCP localport=5985 remoteip=109.174.1.142,212.20.46.209
```

---

### 24. PowerShell — использовать точку с запятой

**Правило:** В PowerShell для выполнения нескольких команд использовать `;` (не `&`).

**Неправильно:**
```powershell
command1 & command2   # Ошибка: Амперсанд не разрешен
```

**Правильно:**
```powershell
command1; command2
```

---

### 25. Пароли со спецсимволами в bash

**Проблема:** Символы `!!` в пароле интерпретируются bash как history expansion.

**Решение:** Использовать одинарные кавычки или файл inventory:

```bash
# Неправильно (!! заменится на последнюю команду):
-e "ansible_password='pass!!word'"

# Правильно (через inventory файл):
cat > inv.yml << 'EOF'
all:
  hosts:
    server:
      ansible_password: "pass!!word"
EOF
ansible-playbook -i inv.yml playbook.yml
```

---

### 26. Хосты НЕ фильтровать в playbook — использовать Limit в Task

**Принцип:** Playbook НЕ должен сам решать на каких хостах работать. Список хостов задаётся в настройках Task в Semaphore через поле **Limit** (это `--limit` в ansible-playbook).

**Неправильно:**
```yaml
# Плейбук сам фильтрует хосты по флагу
- name: Build hosts to link
  set_fact:
    hosts_to_link: "{{ hosts_to_link + [item] }}"
  loop: "{{ groups['windows_servers'] }}"
  when: hostvars[item].monitor_kaspersky | default(false)  # ← НЕПРАВИЛЬНО
```

**Правильно:**
```yaml
# Плейбук работает со ВСЕМИ хостами которые ему передали
# Фильтрация — через Limit в настройках Task
- name: Process all hosts
  loop: "{{ groups['windows_servers'] }}"  # или ansible_play_hosts
```

**Как работает:**
1. Playbook: `hosts: windows_servers` (указывает группу)
2. Task в Semaphore: Limit = `192.168.0.248,192.168.0.90` (ограничивает хосты)
3. Ansible запускается с `--limit 192.168.0.248,192.168.0.90`
4. Playbook работает ТОЛЬКО с указанными хостами

**Исключение:** Плейбуки синхронизации (sync) которые должны удалять orphans — им нужен полный список из inventory. Такие плейбуки помечать в названии: `sync-*.yml`

**Зачем:**
- Гибкость: можно запустить на одном хосте для теста
- Единообразие: один плейбук, разные Task Templates с разными Limit
- Безопасность: случайно не затронешь лишние хосты

---

### 27. Путь к плейбуку определяет Limit в Semaphore

**Правило:** Имена папок в пути к плейбуку определяют какие группы хостов доступны в Limit. Каждая папка в пути, совпадающая с группой в inventory, добавляет свои хосты.

**Примеры:**

| Путь к плейбуку | Папки-группы в пути | Limit показывает хосты |
|-----------------|---------------------|------------------------|
| `mikrotik/backup.yml` | mikrotik | группа `mikrotik` |
| `zabbix/provision.yml` | zabbix | группа `zabbix` |
| `zabbix/mikrotik/setup-hosts.yml` | zabbix, mikrotik | группы `zabbix` + `mikrotik` |
| `zabbix/windows/setup-hosts.yml` | zabbix, windows | группы `zabbix` + `windows` |

**Логика:**
- Папка `mikrotik/` — плейбуки выполняются **на** роутерах MikroTik
- Папка `zabbix/` — плейбуки выполняются **на** Zabbix сервере
- Папка `zabbix/mikrotik/` — настройка мониторинга MikroTik **в** Zabbix (нужны оба: Zabbix API + данные из mikrotik)

**Если папка не соответствует группе в inventory — она служебная:**
- `backups/` — бэкапы, нет группы
- `host_vars/` — переменные хостов, нет группы
- `shared/` — общие таски, нет группы
- `tasks/` — переиспользуемые таски, нет группы

**При создании новой папки с плейбуками:**
1. Если имя папки = группа в inventory → хосты этой группы будут в Limit
2. Вложенные папки добавляют свои группы к Limit
3. Служебные папки (shared, tasks) не влияют на Limit

---

### 28. Описание в начале каждого playbook

**Правило:** Каждый playbook ОБЯЗАТЕЛЬНО должен начинаться с комментария-описания:

```yaml
# имя-файла.yml
# Краткое описание что делает плейбук (1-2 строки)
#
# Зависимости: какие плейбуки запустить ДО этого (если есть)
# Хосты: на каких хостах выполняется (группа из inventory)
# Переменные: какие переменные нужны (vault, extra vars, и т.д.)
---
```

**Пример:**
```yaml
# monitoring-kaspersky.yml
# Создаёт template для мониторинга Kaspersky и привязывает к Windows хостам
#
# Зависимости: setup-telegram.yml, setup-alert-action.yml
# Хосты: zabbix (выполняется на Zabbix сервере)
# Переменные: zabbix_user, zabbix_password (из group_vars/all.yml)
---
```

**Минимальный вариант для простых плейбуков:**
```yaml
# backup.yml
# Создаёт бэкап конфигурации роутера
---
```

---

### 29. Креды для API выносить в group_vars

**Правило:** Логины/пароли/токены для API НЕ хардкодить в каждом плейбуке. Выносить в `group_vars/all.yml` или использовать Vault.

**Неправильно:**
```yaml
# В каждом плейбуке повторяется:
vars:
  zabbix_user: "Admin"
  zabbix_password: "zabbix"
```

**Правильно:**
```yaml
# group_vars/all.yml:
zabbix_user: "Admin"
zabbix_password: "zabbix"  # или через Vault

# В плейбуке — без vars, берётся автоматически из group_vars
```

**Где хранить креды:**
- `group_vars/all.yml` — общие для всех (zabbix_user, tg_token)
- `group_vars/<group>.yml` — специфичные для группы
- Ansible Vault — для production (зашифрованные)

---

## Дата обновления: 2026-01-21
