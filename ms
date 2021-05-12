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
        self.modules = modules
        self.module = None
        self.module_name = ''
        self.completer = MCompleter(modules)

    def message(self):
        return f'{self.module_name}> '

    def on_cmd(self, cmd):
        if cmd.startswith('use'):
            _, m = cmd.split(None, 1)
            if self.modules.get(m):
                c_name = ''.join(p[0].upper()+p[1:] for p in m.split('_'))
                self.module_name = m
                self.module = getattr(getattr(__import__(f'modules.{m}'), m), c_name)()
                self.completer = MCompleter(self.modules, self.module)
            else:
                print('No module named', m)
            return

        cmd, *args = cmd.split()

        if self.module:
            if hasattr(self.module, cmd):
                try:
                    getattr(self.module, cmd)(*args)
                except Exception as e:
                    print(e)
            else:
                print('O_o')
        else:
            print(cmd)


    def loop(self):
        while True:
            try:
                cmd = self.prompt().strip()
            except KeyboardInterrupt:
                continue
            except EOFError:
                break
            else:
                if cmd:
                    self.on_cmd(cmd)

if __name__ == '__main__':
    modules = {}
    for _, m, _ in pkgutil.iter_modules(['modules']):
        if m.startswith('_'):
            continue
        modules[m] = object()
    Shell(modules).loop()
