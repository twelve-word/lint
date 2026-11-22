# Each block breaks one shared rule. check_rules.sh expects Ruff to report every code below.
import time
from datetime import datetime


def mutable_default(items=[]):  # B006
    return items


def blind_except():
    try:
        return 1
    except Exception:  # BLE001
        return 0


def swallowed_error():
    try:
        return 1
    except BaseException:  # S110: only a broad except counts, by Ruff's default
        pass


def untyped_raise():
    raise Exception("no type")  # TRY002


async def blocking_sleep():
    time.sleep(1)  # ASYNC251


def naive_datetime():
    return datetime.now()  # DTZ005


def bare_noqa():
    return 1  # noqa  (PGH004)


def bare_except():
    try:
        return 1
    except:  # E722
        return 0
