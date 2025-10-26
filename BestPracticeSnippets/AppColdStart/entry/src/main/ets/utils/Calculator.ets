// [Start request_in_home]
// Calculator.ets
const LARGE_NUMBER: number = 100000000;

function computeTask(): number {
  let count: number = 0;
  while (count < LARGE_NUMBER) {
    count++;
  }
  return count;
}

export let number = computeTask();
// [End request_in_home]
