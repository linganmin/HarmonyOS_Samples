// [Start Counter_example1]
// The variable does not change in the subsequent process. It is recommended to declare it as a constant
let PRICE = 10000;

function getPrice() {
  return PRICE;
}

class ClassA {
  propA: string = 'propA'
}

// The variable address of the reference type is not changed in the subsequent process, only the variable property is modified. In this example, it is recommended to change the value of let to const
let classA: ClassA = new ClassA();
classA.propA = 'Property A';
// [End Counter_example1]

// [Start Case3]
// lib.ets
export interface TestA {
  sum: number
}

export function getObject(value: number): TestA {
  let obj: TestA = { sum: value };
  return obj;
}
// [End Case3]

// [Start Counter_example2]
class Time {
  static START: number = 1987;
  static INFO: number[] = [2001, 2002, 2003, 2004, 2005, 2006]
}


function getDay(year: number): number {
  let totalDays: number = 348;
  for (let index: number = 0x8000; index > 0x8; index >>= 1) {
    // The value of Time is the same as that of the value of the value of the value of the value of the time
    totalDays += ((Time.INFO[year - Time.START] & index) !== 0) ? 1 : 0;
  }
  return totalDays;
}
// [End Counter_example2]


// [Start Counter_example3]
class Counter {
  // The access modifier is not set. The default value is public
  count: number = 0;

  getCount(): number {
    return this.count;
  }
}
// When accessing
const counter:Counter = new Counter();
console.info(counter.count.toString()); // can be accessed through the instance
console.info(counter.getCount().toString());
// [End Counter_example3]


// [Start Counter_example4]
const array1 = new Array(1, 2, 3);  // For this scenario, it is recommended that you do not use new Array (1, 2, 3)
const array2 = new Array(4, 5, 6);  // For this scenario, it is recommended that new Array (4, 5, 6) be not used
const res = new Array<number>(3);
for (let i = 0; i < 3; i++) {
  res[i] = array1[i] + array2[i];
}
// [End Counter_example4]

// [Start Counter_example5]
class InfoUtil {
  getInfo(t1: string, t2: string): string {
    if (t1 === t2) {
      return "";
    }
    // The common Record object is used as the container
    let info: Record<string, string> = {};
    this.setInfo(info);
    let t3 = info[t2];
    return (t3 != null) ? t3 : "";
  }


  setInfo(info: Record<string, string>) {
    //The interface actually performs the map operation
    info.aaa = 'aaa';
    info.bbb = 'bbb';
    info.ccc = 'ccc';
  }
}
// [End Counter_example5]

// [Start Counter_example6]
// The following case will become a sparse array
// 1. Directly allocate an array with a size of 100,000, and the virtual machine processes it as a hash table to store elements
let count = 100000;
let result: number[] = new Array(count);
// 2. After allocating the array, it will become a sparse array directly, initialize at 9999
result[9999] = 0;
// [End Counter_example6]


// [Start Counter_example7]
const arr:number[] = [0, 1, 2];
function foo() {
  arr[0] = 1;
  // arr keeps the use of external variables
  return arr[0] + arr[1];
}
let aFoo = foo;
aFoo();
// [End Counter_example7]