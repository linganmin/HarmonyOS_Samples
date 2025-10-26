// [Start Case11]
import lazy { A } from "./A"

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
    .height('100%')
    .width('100%')
  }
}
// [End Case11]