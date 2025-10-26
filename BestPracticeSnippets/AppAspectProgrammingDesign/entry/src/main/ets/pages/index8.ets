import { util } from '@kit.ArkTS';

// [Start index8]
class Test {
  foo() {}
}
util.Aspect.addBefore(Test, 'foo', false, (instance: Test) => {
  instance.foo();
});
// Infinite recursion
new Test().foo();
// [End index8]