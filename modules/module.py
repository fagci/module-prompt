class Module:
    '''Example module'''

    def __init__(self):
        print('Init', self.__class__.__name__)

    def test(self, arg=None):
        '''Makes some test'''
        print('Test', arg)
