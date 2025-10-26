import { util } from '@kit.ArkTS';

// [Start index9]
class Test {
  foo() {}
}
// Save the original method implementation first
let originalFoo = new Test().foo;
util.Aspect.addBefore(Test, 'foo', false, (instance: Test) => {
  // If the original method does not use this, you can directly call the originalFoo () method.
  // If this is used in the original method, bind should be used to bind the instance, but there will be a compilation warning originalFoo.bind (instance);
});
// [End index9]