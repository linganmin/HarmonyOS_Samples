// [Start application_events8]
import testNapi from 'libentry.so';

// [StartExclude application_events8]
@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Row() {
      // [EndExclude application_events8]
      Button("button_click").onClick(() => {
        testNapi.writeAppEvent();
      })
      // [StartExclude application_events8]
    }
    .height('100%')
  }
}

// [EndExclude application_events8]
// [End application_events8]
