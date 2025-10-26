/**
 * FAQ:ArkTS类型转换方法，除了使用as是否有其他方法
 */
class TargetClass {
  someProperty?: string;
  someMethod: () => void = () => {
  };
}

function testFn(anyObject: object): void {
  // [Start type_instanceof]
  if (anyObject instanceof TargetClass) {
    // Safely use anyObject as an instance of TargetClass
    const targetObject = anyObject as TargetClass;
    // Now it is safe to call the methods of TargetClass
  } else {
    // Handling cases where the object is not a targetClass instance
  }
  // [End type_instanceof]
}

const anyObject = new TargetClass();

// [Start type_is]
function isTargetClass(obj: object): boolean {
  return obj instanceof TargetClass && obj.someProperty === 'expectedValue';
}

if (isTargetClass(anyObject)) {
  // Now it is safe to use anyObject as an instance of TargetClass
} else {
  // Dealing with objects that do not conform to the TargetClass
}

// [End type_is]


// [Start type_as]
function testFn2(anyObject: object): void {
  try {
    const targetObject = anyObject as TargetClass;
    // Attempt to call a method that is only available for the targetClass
    targetObject.someMethod();
  } catch (error) {
    // Dealing with situations where type conversion fails or method calls are incorrect
  }
}

// [End type_as]

// [Start type_asserts]
function assertIsTargetClass(obj: object): void {
  if (!(obj instanceof TargetClass)) {
    throw new Error('Object is not an instance of TargetClass');
  }
}

try {
  assertIsTargetClass(anyObject);
  // Now it is safe to use anyObject as an instance of TargetClass
} catch (error) {
  // Failure to handle type assertion
}
// [End type_asserts]