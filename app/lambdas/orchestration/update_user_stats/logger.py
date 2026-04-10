import json
import logging
import sys
from datetime import datetime
from typing import Any, Optional

class StructuredLogger:
    """Structured logging with correlation ID support"""
    
    def __init__(self, logger_name: str):
        self.logger = logging.getLogger(logger_name)
        self.logger.setLevel(logging.INFO)
        
        # JSON formatter
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(logging.Formatter('%(message)s'))
        self.logger.addHandler(handler)
        
        self.correlation_id: Optional[str] = None
        self.user_id: Optional[str] = None
        self.track_id: Optional[str] = None
    
    def set_correlation_id(self, correlation_id: str):
        """Set correlation ID for tracking"""
        self.correlation_id = correlation_id
    
    def set_context(self, correlation_id: Optional[str] = None, user_id: Optional[str] = None, track_id: Optional[str] = None):
        """Set logging context"""
        if correlation_id:
            self.correlation_id = correlation_id
        if user_id:
            self.user_id = user_id
        if track_id:
            self.track_id = track_id
    
    def _build_log_entry(self, level: str, message: str, **extra) -> str:
        """Build structured log entry as JSON"""
        log_entry = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "level": level,
            "message": message,
        }
        
        if self.correlation_id:
            log_entry["correlationId"] = self.correlation_id
        if self.user_id:
            log_entry["userId"] = self.user_id
        if self.track_id:
            log_entry["trackId"] = self.track_id
        
        # Add extra fields
        log_entry.update(extra)
        
        return json.dumps(log_entry)
    
    def info(self, message: str, **extra):
        """Log info level"""
        self.logger.info(self._build_log_entry("INFO", message, **extra))
    
    def error(self, message: str, **extra):
        """Log error level"""
        self.logger.error(self._build_log_entry("ERROR", message, **extra))
    
    def warning(self, message: str, **extra):
        """Log warning level"""
        self.logger.warning(self._build_log_entry("WARNING", message, **extra))
    
    def debug(self, message: str, **extra):
        """Log debug level"""
        self.logger.debug(self._build_log_entry("DEBUG", message, **extra))
