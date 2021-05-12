#!/usr/bin/env python
import pkgutil

from prompt_toolkit.completion.base import CompleteEvent, Completer, Completion
from prompt_toolkit.document import Document
from prompt_toolkit.shortcuts.prompt import PromptSession

class MCompleter(Completer):
    def __init__(self, modules, module=None):
        self.modules = modules
        self.module = module
        self.methods = []
        if module:
            self.methods = [m for m in dir(self.module) if not m.startswith('_')]

    def get_completions(self, document: Document, complete_event: CompleteEvent):
        text = document.text
        start = -len(text)

        for m in self.modules:
            c = f'use {m}'
            if c.startswith(text):
                yield Completion(c, start)

        for m in self.methods:
            if m.startswith(text):
                yield Completion(m, start)

class Shell(PromptSession):
    def __init__(self, modules):
        super().__init__(self.message)
        self.ret = None
        self.modules = modules
        self.module = None
        self.module_name = ''
        self.completer = MCompleter(modules)

    def message(self):
        ret = f'{self.ret} ' if self.ret else ''
        return f'{ret}{self.module_name}> '

    def on_cmd(self, cmd):

        cmd, *args = cmd.split()

        if cmd in ('q', 'exit', 'quit'):
            raise EOFError

        if cmd in ('?', 'help'):
            if self.module:
                if self.module.__doc__:
                    print(self.module.__doc__)
                for f in dir(self.module):
                    if not f.startswith('_'):
                        print(f, '--', getattr(self.module, f).__doc__)
            else:
                print('Available modules:')
                for m in self.modules.keys():
                    print('•', m)
                print()
                print('Use module: use <module_name>')
            return

        if cmd == 'use':
            m = args[0]
            if self.modules.get(m):
                # snake_case to CamelCase
                c_name = ''.join(p[0].upper()+p[1:] for p in m.split('_'))
                self.module_name = m
                self.module = getattr(getattr(__import__(f'modules.{m}'), m), c_name)()
                self.completer = MCompleter(self.modules, self.module)
            else:
                print('No module named', m)
            return

        if self.module:
            if hasattr(self.module, cmd):
                return getattr(self.module, cmd)(*args)

        raise ValueError('No such command')


    def loop(self):
        while True:
            try:
                cmd = self.prompt().strip()
                self.ret = None
                if cmd:
                    self.ret = self.on_cmd(cmd)
            except KeyboardInterrupt:
                continue
            except EOFError:
                break
            except Exception as e:
                print(e)
                self.ret = e.errno if hasattr(e, 'errno') else 255


if __name__ == '__main__':
    modules = {}
    for _, m, _ in pkgutil.iter_modules(['modules']):
        if m.startswith('_'):
            continue
        modules[m] = object()
    Shell(modules).loop()
