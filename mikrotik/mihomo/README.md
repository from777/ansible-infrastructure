# Mihomo

## Файлы

```
mihomo/
├── vars.yml           ← Переменные (имя, IP)
├── mihomo_all.yml     ← Всё сразу
├── 01_network.yml     ← Сеть
├── 02_smb_mount.yml   ← SMB mount
├── 03_configs.yml     ← Копирование конфигов
├── 04_container.yml   ← Контейнер
├── 05_smb_unmount.yml ← SMB unmount
└── configs/
    ├── template/custom_config.yaml
    ├── awg/warp.conf
    └── srv/proxies.yaml
```

## Запуск

```bash
# Всё сразу
ansible-playbook mihomo_all.yml --ask-become-pass

# По шагам
ansible-playbook 01_network.yml
ansible-playbook 02_smb_mount.yml --ask-become-pass
ansible-playbook 03_configs.yml --ask-become-pass
ansible-playbook 04_container.yml
ansible-playbook 05_smb_unmount.yml --ask-become-pass
```

## Проверки

Все плейбуки проверяют существование объектов перед созданием — дублей не будет.
