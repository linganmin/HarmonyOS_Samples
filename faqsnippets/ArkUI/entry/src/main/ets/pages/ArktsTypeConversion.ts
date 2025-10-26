/**
 * FAQ:ArkTS类型转换方法，除了使用as是否有其他方法
 */
class TargetClass {
    someProperty: string = '';
    someMethod: () => void = () => {
    };
}
const anyObject = new TargetClass();

// [Start type_is]
function isTargetClass(obj: any): obj is TargetClass {
    return obj instanceof TargetClass && obj.someProperty === 'expectedValue';
}

if (isTargetClass(anyObject)) {
    // Now it is safe to use anyObject as an instance of TargetClass
} else {
    // Dealing with objects that do not conform to the TargetClass
}
// [End type_is]

// [Start type_asserts]
function assertIsTargetClass(obj: any): asserts obj is TargetClass {
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