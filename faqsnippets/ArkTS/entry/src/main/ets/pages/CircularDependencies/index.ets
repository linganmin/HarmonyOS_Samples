/*
* FAQ:模块间循环依赖导致运行时未初始化异常问题定位
*/

// [Start CircularDependencies1]
// index.ets
import { bar } from './page'

export function foo() {
  bar()
}
// [End CircularDependencies1]
