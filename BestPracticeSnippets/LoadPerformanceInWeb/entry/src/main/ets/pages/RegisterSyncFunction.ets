// [Start register_sync_function]
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';
// Define ETS side objects and functions
class TestObj {
  constructor() {}
  test(testStr:string): string {
    let start: number = Date.now();
    // Simulate time-consuming operations
    for(let i = 0; i < 500000; i++) {}
    let end: number = Date.now();
    console.log('objName.test start: ' + start);
    return 'objName.test Sync function took ' + (end - start) + 'ms';
  }
  asyncTestBool(testBol:boolean): Promise<string> {
    return new Promise((resolve, reject) => {
      let start: number = Date.now();
      // Simulate time-consuming operation (asynchronous)
      setTimeout(() => {
        for(let i = 0; i < 500000; i++) {}
        let end: number = Date.now();
        console.log('objAsyncName.asyncTestBool start: ' + start);
        resolve('objName.asyncTestBool Async function took ' + (end - start) + 'ms');
      }, 0); // Use 0 ms delay to simulate an asynchronous operation that starts immediately
    });
  }
}

class WebObj {
  constructor() {}
  webTest(): string {
    let start: number = Date.now();
    // Simulate time-consuming operations
    for(let i = 0; i < 500000; i++) {}
    let end: number = Date.now();
    console.log('objTestName.webTest start: ' + start);
    return 'objTestName.webTest Sync function took ' + (end - start) + 'ms';
  }
  webString(): string {
    let start: number = Date.now();
    // Simulate time-consuming operations
    for(let i = 0; i < 500000; i++) {}
    let end: number = Date.now();
    console.log('objTestName.webString start: ' + start);
    return 'objTestName.webString Sync function took ' + (end - start) + 'ms';
  }
}

class AsyncObj {
  constructor() {
  }

  asyncTest(): Promise<string> {
    return new Promise((resolve, reject) => {
      let start: number = Date.now();
      // Simulate time-consuming operation (asynchronous)
      setTimeout(() => {
        for (let i = 0; i < 500000; i++) {
        }
        let end: number = Date.now();
        console.log('objAsyncName.asyncTest start: ' + start);
        resolve('objAsyncName.asyncTest Async function took ' + (end - start) + 'ms');
      }, 0); // Use 0 ms delay to simulate an asynchronous operation that starts immediately
    });
  }

  asyncString(testStr:string): Promise<string> {
    return new Promise((resolve, reject) => {
      let start: number = Date.now();
      // Simulate time-consuming operation (asynchronous)
      setTimeout(() => {
        for (let i = 0; i < 500000; i++) {
        }
        let end: number = Date.now();
        console.log('objAsyncName.asyncString start: ' + start);
        resolve('objAsyncName.asyncString Async function took ' + (end - start) + 'ms');
      }, 0); // Use 0 millisecond delay to simulate immediate asynchronous operation
    });
  }
}

@Entry
@Component
struct Index {
  controller: webview.WebviewController = new webview.WebviewController();
  @State testObjtest: TestObj = new TestObj();
  @State webTestObj: WebObj = new WebObj();
  @State asyncTestObj: AsyncObj = new AsyncObj();
  build() {
    Column() {
      Button('refresh')
        .onClick(()=>{
          try{
            this.controller.refresh();
          } catch (error) {
            console.error(`ErrorCode:${(error as BusinessError).code},Message:${(error as BusinessError).message}`);
          }
        })
      Button('Register JavaScript To Window')
        .onClick(()=>{
          try {
            // Only register synchronization functions
            this.controller.registerJavaScriptProxy(this.webTestObj,"objTestName",["webTest","webString"]);
          } catch (error) {
            console.error(`ErrorCode:${(error as BusinessError).code},Message:${(error as BusinessError).message}`);
          }
        })
      Web({src: $rawfile('index.html'),controller: this.controller}).javaScriptAccess(true)
    }
  }
}
// [End register_sync_function]