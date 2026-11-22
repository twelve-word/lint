import asyncio
import logging
from datetime import UTC, datetime

from fastapi import Depends

logger = logging.getLogger(__name__)


class LookupFailed(Exception):
    """A typed domain error."""


def items_or_empty(items: list[str] | None = None) -> list[str]:
    return items if items is not None else []


def parse_count(text: str) -> int:
    try:
        return int(text)
    except ValueError as error:
        logger.warning("Not a count: %s", text)
        raise LookupFailed(text) from error


async def wait_a_moment() -> None:
    await asyncio.sleep(1)


def now_in_utc() -> datetime:
    return datetime.now(UTC)


def route(settings: object = Depends(now_in_utc)) -> object:  # B008 is allowed for FastAPI
    return settings
