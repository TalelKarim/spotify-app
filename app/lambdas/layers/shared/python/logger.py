import json
import logging
import os
import sys
from datetime import datetime
from typing import Any


class StructuredLogger:
    def __init__(self, logger_name: str):
        self.logger = logging.getLogger(logger_name)
        self.logger.setLevel(logging.INFO)
        self.logger.propagate = False

        if not self.logger.handlers:
            handler = logging.StreamHandler(sys.stdout)
            handler.setFormatter(logging.Formatter("%(message)s"))
            self.logger.addHandler(handler)

        self.base_context = {
            "service": os.environ.get("SERVICE_NAME", "spotify-lambda"),
            "environment": os.environ.get("ENVIRONMENT") or os.environ.get("STAGE"),
        }
        self.runtime_context: dict[str, Any] = {}

    def set_lambda_context(self, context: Any | None):
        self.runtime_context["functionName"] = getattr(context, "function_name", None)
        self.runtime_context["awsRequestId"] = getattr(context, "aws_request_id", None)

    def set_correlation_id(self, correlation_id: str | None):
        self.runtime_context["correlationId"] = correlation_id

    def set_context(self, **context: Any):
        for key, value in context.items():
            self.runtime_context[key] = value

    def clear_context(self):
        self.runtime_context = {}

    def _build_log_entry(self, level: str, message: str, **extra: Any) -> str:
        log_entry = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "level": level,
            "message": message,
        }

        for source in (self.base_context, self.runtime_context, extra):
            for key, value in source.items():
                if value is not None:
                    log_entry[key] = value

        return json.dumps(log_entry, default=str)

    def info(self, message: str, **extra: Any):
        self.logger.info(self._build_log_entry("INFO", message, **extra))

    def error(self, message: str, **extra: Any):
        self.logger.error(self._build_log_entry("ERROR", message, **extra))

    def warning(self, message: str, **extra: Any):
        self.logger.warning(self._build_log_entry("WARNING", message, **extra))

    def debug(self, message: str, **extra: Any):
        self.logger.debug(self._build_log_entry("DEBUG", message, **extra))

    def exception(self, message: str, **extra: Any):
        self.logger.exception(self._build_log_entry("ERROR", message, **extra))