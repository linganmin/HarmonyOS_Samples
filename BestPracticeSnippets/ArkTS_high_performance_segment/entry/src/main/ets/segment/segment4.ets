// [Start Case10]
// A is any ets file that can be imported
import { A } from "./A"


@Entry
@Component
struct Index {
  build() {
    RelativeContainer() {
      Button('Click to perform A')
        .onClick(() => {
          console.log('Perform A' + A)
        })
    }
    // ...
  }
}
// [End Case10]
