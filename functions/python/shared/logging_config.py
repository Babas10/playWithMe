"""
Structured logging configuration for Cloud Functions.

This module provides consistent, structured logging across all Python
Cloud Functions in the PlayWithMe application.
"""

import json
import logging
import sys
from datetime import datetime
from typing import Any, Dict, Optional


class StructuredLogFormatter(logging.Formatter):
    """
    Custom log formatter that outputs structured JSON logs.

    This format is compatible with Google Cloud Logging and provides
    consistent, parseable log entries with context.
    """

    def format(self, record: logging.LogRecord) -> str:
        """Format the log record as a structured JSON object."""
        log_entry: Dict[str, Any] = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "severity": record.levelname,
            "message": record.getMessage(),
            "logger": record.name,
        }

        # Add source location
        log_entry["sourceLocation"] = {
            "file": record.filename,
            "line": record.lineno,
            "function": record.funcName,
        }

        # Add exception info if present
        if record.exc_info:
            log_entry["exception"] = self.formatException(record.exc_info)

        # Add extra context if provided
        if hasattr(record, "context") and record.context:
            log_entry["context"] = record.context

        return json.dumps(log_entry)


class ContextLogger:
    """
    Logger wrapper that adds context to all log messages.

    This provides a convenient way to include game_id, user_ids,
    and other context in every log message.
    """

    def __init__(self, name: str):
        """Initialize the context logger with a name."""
        self._logger = logging.getLogger(name)
        self._context: Dict[str, Any] = {}

    def set_context(self, **kwargs: Any) -> None:
        """Set context that will be included in all subsequent log messages."""
        self._context.update(kwargs)

    def clear_context(self) -> None:
        """Clear all context."""
        self._context = {}

    def _log(
        self,
        level: int,
        message: str,
        extra_context: Optional[Dict[str, Any]] = None,
    ) -> None:
        """Internal log method that merges context."""
        context = {**self._context}
        if extra_context:
            context.update(extra_context)

        record = self._logger.makeRecord(
            name=self._logger.name,
            level=level,
            fn="",
            lno=0,
            msg=message,
            args=(),
            exc_info=None,
        )
        record.context = context
        self._logger.handle(record)

    def debug(self, message: str, **kwargs: Any) -> None:
        """Log a debug message."""
        self._log(logging.DEBUG, message, kwargs if kwargs else None)

    def info(self, message: str, **kwargs: Any) -> None:
        """Log an info message."""
        self._log(logging.INFO, message, kwargs if kwargs else None)

    def warning(self, message: str, **kwargs: Any) -> None:
        """Log a warning message."""
        self._log(logging.WARNING, message, kwargs if kwargs else None)

    def error(self, message: str, **kwargs: Any) -> None:
        """Log an error message."""
        self._log(logging.ERROR, message, kwargs if kwargs else None)

    def exception(self, message: str, **kwargs: Any) -> None:
        """Log an exception with traceback."""
        self._logger.exception(message, extra={"context": {**self._context, **kwargs}})


def configure_logging(level: int = logging.INFO) -> None:
    """
    Configure structured logging for Cloud Functions.

    Call this at the module level in main.py to set up logging
    before any functions are executed.

    Args:
        level: The logging level (default: INFO)
    """
    # Remove any existing handlers
    root_logger = logging.getLogger()
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)

    # Create handler with structured formatter
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(StructuredLogFormatter())

    # Configure root logger
    root_logger.setLevel(level)
    root_logger.addHandler(handler)


def get_logger(name: str) -> ContextLogger:
    """
    Get a context-aware logger for the specified name.

    Args:
        name: The logger name (typically __name__)

    Returns:
        A ContextLogger instance
    """
    return ContextLogger(name)
