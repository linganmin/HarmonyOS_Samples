/**
 * FAQ: 如何导出C++自定义类，导出后如何在ArkTS侧进行类方法调用
 */
// [Start native_class_dts]
declare namespace testNapi {
  const add: (a: number, b: number) => number;
  const sub: (a: number, b: number) => number;
  // Defining the ArkTS Interface
  class MyDemo {
    constructor(name:string)
    name: string
    add(a: number, b: number): number
    sub(a: number, b: number): number
  }
}
export default testNapi;
// [End native_class_dts]