import logging
from colorama import Fore, Style
from google.cloud.logging_v2.handlers import CloudLoggingFilter, StructuredLogHandler
from .utils import remove_color_codes
class FancyConsoleFormatter(logging.Formatter):
    """
    A custom logging formatter designed for console output.

    This formatter enhances the standard logging output with color coding. The color
    coding is based on the level of the log message, making it easier to distinguish
    between different types of messages in the console output.

    The color for each level is defined in the LEVEL_COLOR_MAP class attribute.
    """
    LEVEL_COLOR_MAP = {logging.DEBUG: Fore.LIGHTBLACK_EX, logging.INFO: Fore.BLUE, logging.WARNING: Fore.YELLOW, logging.ERROR: Fore.RED, logging.CRITICAL: Fore.RED + Style.BRIGHT}

    def format(self, record: logging.LogRecord) -> str:
        if not hasattr(record, 'msg'):
            record.msg = ''
        elif type(record.msg) is not str:
            record.msg = str(record.msg)
        level_color = ''
        if record.levelno in self.LEVEL_COLOR_MAP:
            level_color = self.LEVEL_COLOR_MAP[record.levelno]
            record.levelname = f'{level_color}{record.levelname}{Style.RESET_ALL}'
        color = getattr(record, 'color', level_color)
        color_is_specified = hasattr(record, 'color')
        if color and (record.levelno != logging.INFO or color_is_specified):
            record.msg = f'{color}{record.msg}{Style.RESET_ALL}'
        return super().format(record)
'\n    A custom logging formatter designed for console output.\n\n    This formatter enhances the standard logging output with color coding. The color\n    coding is based on the level of the log message, making it easier to distinguish\n    between different types of messages in the console output.\n\n    The color for each level is defined in the LEVEL_COLOR_MAP class attribute.\n    '
LEVEL_COLOR_MAP = {logging.DEBUG: Fore.LIGHTBLACK_EX, logging.INFO: Fore.BLUE, logging.WARNING: Fore.YELLOW, logging.ERROR: Fore.RED, logging.CRITICAL: Fore.RED + Style.BRIGHT}
def format(self, record: logging.LogRecord) -> str:
    if not hasattr(record, 'msg'):
        record.msg = ''
    elif type(record.msg) is not str:
        record.msg = str(record.msg)
    level_color = ''
    if record.levelno in self.LEVEL_COLOR_MAP:
        level_color = self.LEVEL_COLOR_MAP[record.levelno]
        record.levelname = f'{level_color}{record.levelname}{Style.RESET_ALL}'
    color = getattr(record, 'color', level_color)
    color_is_specified = hasattr(record, 'color')
    if color and (record.levelno != logging.INFO or color_is_specified):
        record.msg = f'{color}{record.msg}{Style.RESET_ALL}'
    return super().format(record)
not hasattr(record, 'msg')
class AGPTFormatter(FancyConsoleFormatter):

    def __init__(self, *args, no_color: bool=False, **kwargs):
        super().__init__(*args, **kwargs)
        self.no_color = no_color

    def format(self, record: logging.LogRecord) -> str:
        if not hasattr(record, 'msg'):
            record.msg = ''
        elif type(record.msg) is not str:
            record.msg = str(record.msg)
        if record.msg and (not getattr(record, 'preserve_color', False)):
            record.msg = remove_color_codes(record.msg)
        title = getattr(record, 'title', '')
        title_color = getattr(record, 'title_color', '') or self.LEVEL_COLOR_MAP.get(record.levelno, '')
        if title and title_color:
            title = f'{title_color + Style.BRIGHT}{title}{Style.RESET_ALL}'
        record.title = f'{title} ' if title else ''
        if self.no_color:
            return remove_color_codes(super().format(record))
        else:
            return super().format(record)
def __init__(self, *args, no_color: bool=False, **kwargs):
    super().__init__(*args, **kwargs)
    self.no_color = no_color
super().__init__(*args)
self.no_color = no_color
def format(self, record: logging.LogRecord) -> str:
    if not hasattr(record, 'msg'):
        record.msg = ''
    elif type(record.msg) is not str:
        record.msg = str(record.msg)
    if record.msg and (not getattr(record, 'preserve_color', False)):
        record.msg = remove_color_codes(record.msg)
    title = getattr(record, 'title', '')
    title_color = getattr(record, 'title_color', '') or self.LEVEL_COLOR_MAP.get(record.levelno, '')
    if title and title_color:
        title = f'{title_color + Style.BRIGHT}{title}{Style.RESET_ALL}'
    record.title = f'{title} ' if title else ''
    if self.no_color:
        return remove_color_codes(super().format(record))
    else:
        return super().format(record)
not hasattr(record, 'msg')
class StructuredLoggingFormatter(StructuredLogHandler, logging.Formatter):

    def __init__(self):
        self.cloud_logging_filter = CloudLoggingFilter()
        super().__init__()

    def format(self, record: logging.LogRecord) -> str:
        self.cloud_logging_filter.filter(record)
        return super().format(record)
def __init__(self):
    self.cloud_logging_filter = CloudLoggingFilter()
    super().__init__()
self.cloud_logging_filter = CloudLoggingFilter()
super().__init__()
def format(self, record: logging.LogRecord) -> str:
    self.cloud_logging_filter.filter(record)
    return super().format(record)
self.cloud_logging_filter.filter(record)
return super().format(record)
record.msg = ''
type(record.msg) IsNot str
record.msg = ''
type(record.msg) IsNot str
record.msg = str(record.msg)
record.msg = str(record.msg)
level_color = ''
record.levelno In self.LEVEL_COLOR_MAP
record.msg and (not getattr(record, 'preserve_color', False))
level_color = self.LEVEL_COLOR_MAP[record.levelno]
record.levelname = f'{level_color}{record.levelname}{Style.RESET_ALL}'
record.msg = remove_color_codes(record.msg)
color = getattr(record, 'color', level_color)
color_is_specified = hasattr(record, 'color')
color and (record.levelno != logging.INFO or color_is_specified)
title = getattr(record, 'title', '')
title_color = getattr(record, 'title_color', '') or self.LEVEL_COLOR_MAP.get(record.levelno, '')
title and title_color
record.msg = f'{color}{record.msg}{Style.RESET_ALL}'
title = f'{title_color + Style.BRIGHT}{title}{Style.RESET_ALL}'
return super().format(record)
record.title = f'{title} ' if title else ''
self.no_color
return remove_color_codes(super().format(record))
return super().format(record)