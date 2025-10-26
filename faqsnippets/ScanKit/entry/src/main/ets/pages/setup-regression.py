/*
* FAQ:生成回归测试包时，如果出现“setup-regression.py 解析失败，请检查 setup-regression.py 的写法是否规范”的错误提示，应如何处理？
*/

// [Start regression]
 # setup-regression.py example of file writing
from setuptools import setup
setup(
      name='hypiumTest',
      version='1.0.0.0',
      author='xxx',
      # py_modules Specify the hypium use case py file that needs to be packaged
      py_modules=['testcases.Example'],
      include_package_data=True
      )
// [End regression]