# use snake_case for module name
# and CamelCase for module class
# with same name as module name
class Module:
    '''Example module'''

    def __init__(self):
        print('Init', self.__class__.__name__)

    def test(self, arg=None):
        '''Available command for module'''
        print('Test', arg)
