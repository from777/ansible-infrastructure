# Lessons Learned - Ошибки и решения

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

## Дата обновления: 2026-01-08
