// [Start Case4]
// app.ets
import { getObject, TestA } from './segment';

let obj: TestA = getObject(123); // Explicitly introduce the label type
// [End Case4]

// [Start Case]
const PRICE = 10000; // When a constant is declared as a base type, its content cannot be changed

function getPrice() {
  return PRICE;
}

class ClassA {
  propA: string = 'propA'
}

// When a constant is declared as a reference type, its address cannot be changed, but its properties can be changed
const classA: ClassA = new ClassA();
classA.propA = 'Property A';

// [End Case]

// [Start Case2]
function calAddSum(addNum: number): number {
  // count is expected to be int, do not declare it as undefined/null or 0.0, directly initialize it to 0
  let count = 0;
  count += addNum;
  return count;
}
// [End Case2]

// [Start Case5]
// Code after optimization
class Time {
  static START: number = 1987;
  static INFO: number[] = [2001, 2002, 2003, 2004, 2005, 2006];
}

function getDay(year: number): number {
  let totalDays: number = 348;
  // Extract invariants from the loop
  const info = Time.INFO[year - Time.START];
  for (let index: number = 0x8000; index > 0x8; index >>= 1) {
    if ((info & index) !== 0) {
      totalDays++;
    }
  }
  return totalDays;
}
// [End Case5]

// [Start Case6]
class Counter {
  // Set the access modifier to private
  private count: number = 0;

  public getCount(): number {
    return this.count;
  }
}

// When accessing
const counter: Counter = new Counter();
let res = counter.getCount();
// [End Case6]

// [Start Case7]
const typedArray1 =
  new Int8Array([1, 2, 3]); // For this scenario, it is recommended that you do not use new Array ([1, 2, 3])
const typedArray2 =
  new Int8Array([4, 5, 6]); // For this scenario, it is recommended that you do not use new Array ([4, 5, 6])
const res1 = new Int8Array(3);
for (let i = 0; i < 3; i++) {
  res1[i] = typedArray1[i] + typedArray2[i];
}
// [End Case7]

// [Start Case9]
let arr: number[] = [0, 1, 2];

// Change to pass by parameters
function foo(array: Array<number>): number {
  array[0] = 1;
  return array[0] + array[1];
}

foo(arr);
// [End Case9]