@Component
struct DateComponent {
  build() {
    Column() {
      Text('I am a component in AModulelib ')
        .margin(10)
    }
    .width(300).backgroundColor(Color.Yellow)
  }
}

@Builder
export function showDateComponent() {
  DateComponent()
}