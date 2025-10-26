@Component
struct FlowListStruct {
  build() {
  }
}

// [Start Counter_example3]
@Component
export struct example {
  build() {
    Column() {
      Row() {
        // Custom Components
        FlowListStruct(
          // Custom Component Passing Parameters
          // ...
        )
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }
}

// [End Counter_example3]
// [Start Case3]
@Component
export struct example2 {
  build() {
    Column() {
      // Custom Components
      FlowListStruct(
        // Custom Component Passing Parameters
        // ...
      )
    }
    .width('100%')
    .height('100%')
  }
}

// [End Case3]

// [Start Counter_example4]
@Entry
@Component
struct StackNesting {
  build() {
    Column() {
      Stack() {
        Image($r('app.media.startIcon'))
          .objectFit(ImageFit.Contain)
        Text('fragmentary text')
          .fontSize(20)
          .fontColor(Color.Black)
      }
    }
  }
}

// [End Counter_example4]