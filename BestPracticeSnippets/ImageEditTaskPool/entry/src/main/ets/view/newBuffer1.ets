let Workers: ESObject;
let taskNum: number = 1;
let allocation: number = 1
let index: number = 0
let messages: number[];
let n = 0;
let curTaskNum = 2
let that = this

function test() {
  // [Start buffer_test]
  let num = 0; // Number of tasks processed
  let newBuffers: ArrayBuffer[] = [];
  for (let i = 0; i < taskNum; i++) {
    newBuffers[i] = new ArrayBuffer(0); // Initialize calculation result data of each task
  }
  Workers[index].onmessage = (e: ESObject) => {
    newBuffers[e.data.index] = e.data.buffer; // The main thread receives the calculation result.
    num = num + 1; // Number of tasks completed +1
    if (allocation !== 0) { // If the total task has not been processed, reuse the sub-thread to continue processing the remaining tasks.
      Workers[index].postMessage(messages[n]);
      n += 1;
      allocation = allocation - 1;
    } else if (num === taskNum) {
      for (let i = 0; i < curTaskNum; i++) {
        Workers[i].terminate(); // When all tasks are processed, the child thread is destroyed.
      }
      const entireArrayBuffer = mergeArrayBuffers(newBuffers); // Merge all task calculation results
      that.updatePixelMap(entireArrayBuffer); // Refresh the UI according to the calculation result.
    }
  }
  // [End buffer_test]
}

// [Start buffer_test]
// Merge the calculation results of all tasks.
function mergeArrayBuffers(buffers: ArrayBuffer[]) {
  // Calculate the combined total length.
  let totalLength = buffers.reduce((length, buffer) => {
    length += buffer.byteLength;
    return length;
  }, 0);
  // Create a new ArrayBuffer.
  let mergedBuffer = new ArrayBuffer(totalLength);
  // Create a Uint8Array to operate the new ArrayBuffer.
  let mergedArray = new Uint8Array(mergedBuffer);
  // Copy the contents of each ArrayBuffer to the new ArrayBuffer in turn.
  let offset = 0;
  for (let buffer of buffers) {
    let array = new Uint8Array(buffer);
    mergedArray.set(array, offset);
    offset += array.length;
  }
  return mergedBuffer;
}

// [End buffer_test]
