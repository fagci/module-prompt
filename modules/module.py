class Module:
    def __init__(self):
        print('Init', self.__class__)

    def test(self, arg):
        '''Makes test'''
        print('Test', arg)
