import { util } from '@kit.ArkTS';

// [Start index10]
// Counterexample
@Component
struct Index {
  foo() {}
  build() {};
}

util.Aspect.replace(Index, 'foo', false, () => {
  // ...
});
util.Aspect.replace(Index, 'build', false, () => {
  // ...
});

// [End index10]

// [Start index11]
// Example of unrecommended usage:
class Test {
  foo(): string {
    return 'hello';
  }
}

util.Aspect.addAfter(Test, 'foo', false, () => {
  console.log('execute foo');
});

// The correct usage example is as follows:
class Test1 {
  foo(): string {
    return 'hello';
  }
}

util.Aspect.addAfter(Test1, 'foo', false, (instance: Test, ret: string) => {
  console.log('execute foo');
  return ret; // Return the return value of the original method
})
// [End index11]