# CLAUDE.md

Циферблат Garmin Connect IQ `mh-balance`: Body Battery (синий) и Stress (красный) как концентрические орбиты, плюс шаги, пульс, уведомления и Bluetooth.

## Стек

- Язык: **Monkey C** (Connect IQ SDK, `minSdkVersion 3.1.0`).
- Тип приложения: `watchface`, entry `MHBalanceApp` (см. `manifest.xml`).
- Поддерживаемые разрешения круглых экранов (по `resources-round-*`): 218x218, 240x240, 260x260, 280x280, 360x360, 390x390, 416x416, 454x454.
- Целевые устройства: широкий список в `manifest.xml` (Forerunner 165/245/255/265/570/645/745/935/945/955/965/970, Fenix 5–8, Epix 2, Venu, Vivoactive 3–6, MARQ, Descent, Enduro и др.).
- Локализации: `eng` (по умолчанию, `resources/strings/`), `deu` (`resources-deu/`), `fre` (`resources-fre/`).
- Permissions: `Background`, `SensorHistory`, `UserProfile`.

## Сборка

Команда сборки под Forerunner 965 (из README):

```bash
JAVA_TOOL_OPTIONS='-Duser.home=/Users/bronxtc52' \
monkeyc -f monkey.jungle -d fr965 -o bin/mh-balance-fr965.prg -y ../garmin/keys/developer_key.der -w
```

Запуск в симуляторе Connect IQ:

```bash
connectiq monkeydo bin/mh-balance-fr965.prg fr965
```

Ключ разработчика лежит **вне репозитория**: `../garmin/keys/developer_key.der`. Из-за правил изоляции (см. ниже) этот путь сам не открывать — если нужен другой ключ или путь, спросить пользователя явно.

## Структура

- `manifest.xml` — список поддерживаемых устройств, permissions, языки, app_id.
- `monkey.jungle` — конфигурация сборки (ссылается на `manifest.xml`).
- `source/` — Monkey C:
  - `MHBalanceApp.mc`, `MHBalanceView.mc`, `Background.mc`, `SleepModeServiceDelegate.mc` — приложение и view.
  - `DrawHelper.mc`, `Log.mc`, `Settings.mc` — утилиты.
  - `source/datafield/` — `OrbitDataField.mc`, `RingDataField.mc`, `DataFieldDrawable.mc`, `SecondaryDataField.mc`, `DateAndTime.mc`, `IconDrawable.mc`, `DataFieldInfo.mc`.
  - `source/settingsMenu/` — `MHBalanceSettingsMenu.mc`, `OptionsMenu2.mc`, `ValueHolder.mc`.
- `resources/` — общие layouts, drawables, settings, strings (eng).
- `resources-round-<WxH>/` — раскладки/ресурсы под конкретные разрешения круглых экранов.
- `resources-deu/`, `resources-fre/` — переводы строк.
- `README.md`, `UPLOAD.md`, `LICENSE` (GPL-3.0), `garmin.jpg` — превью.

## Деплой

Подробности — в `UPLOAD.md`: сборка `.prg`, отправка на часы через MTP-хелпер `../garmin/bronxtc_design/scripts/mtp_send_to_apps` в `GARMIN/Apps/MHBAL.PRG`. Публикация — через Connect IQ Store.

## Не трогать без явного разрешения

- `../garmin/keys/developer_key.der` — приватный ключ разработчика (вне репо).
- `manifest.xml` — `iq:application id` (`a6504e02-...`), список `iq:product`, permissions.
- `LICENSE` (GPL-3.0) и атрибуции upstream шрифтов/иконок.

## Секреты

**Где искать:** Key Vault `kv-bronxtc-dev` (RG `bronxtc_group`, RBAC, northeurope). **У этого репо нет своего namespace** — Connect IQ watch face не использует env-переменных; единственный «секрет» — `developer_key.der` (живёт в `../garmin/keys/` вне репо).

**Правило:** если в будущем понадобится какой-то токен (например для CI-загрузки в Connect IQ Store) — **сначала проверяю vault**, потом спрашиваю пользователя. Не придумывать.

## Изоляция проекта

- **Запрещено** читать, просматривать или изменять файлы за пределами корневой папки текущего проекта
- **Запрещено** переходить в другие директории (`cd ../`, `cd ~`, `cd /home/...` и т.п.)
- **Запрещено** обращаться к файлам соседних проектов, даже для чтения
- Все операции — только внутри текущей рабочей директории и её поддиректорий
- Если задача требует данных извне — запросить у пользователя явно, не идти за ними самому
