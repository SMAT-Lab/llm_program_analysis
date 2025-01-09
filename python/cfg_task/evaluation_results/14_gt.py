import re
from jinja2 import BaseLoader
from jinja2.sandbox import SandboxedEnvironment
class TextFormatter:

    def __init__(self):
        self.env = SandboxedEnvironment(loader=BaseLoader(), autoescape=True)
        self.env.filters.clear()
        self.env.tests.clear()
        self.env.globals.clear()

    def format_string(self, template_str: str, values=None, **kwargs) -> str:
        template_str = re.sub('(?<!{){[ a-zA-Z0-9_]+}', '{\\g<0>}', template_str)
        template = self.env.from_string(template_str)
        return template.render(values or {}, **kwargs)
def __init__(self):
    self.env = SandboxedEnvironment(loader=BaseLoader(), autoescape=True)
    self.env.filters.clear()
    self.env.tests.clear()
    self.env.globals.clear()
self.env = SandboxedEnvironment(loader=BaseLoader(), autoescape=True)
self.env.filters.clear()
self.env.tests.clear()
self.env.globals.clear()
def format_string(self, template_str: str, values=None, **kwargs) -> str:
    template_str = re.sub('(?<!{){[ a-zA-Z0-9_]+}', '{\\g<0>}', template_str)
    template = self.env.from_string(template_str)
    return template.render(values or {}, **kwargs)
template_str = re.sub('(?<!{){[ a-zA-Z0-9_]+}', '{\\g<0>}', template_str)
template = self.env.from_string(template_str)
return template.render(values or {}, **kwargs)