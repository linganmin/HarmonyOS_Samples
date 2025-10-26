/*
* FAQ:模块间循环依赖导致运行时未初始化异常问题定位
*/

// [Start CircularDependencies2]
// page.ets
import { foo } from './index'

export function bar() {
  foo()
}
bar()
// [End CircularDependencies2]
