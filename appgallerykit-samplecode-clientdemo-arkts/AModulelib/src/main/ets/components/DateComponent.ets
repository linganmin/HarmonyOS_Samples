@Component
struct DateComponent {
  build() {
    Column() {
      Text('我是AModulelib中的组件')
        .margin(10)
    }
    .width(300).backgroundColor(Color.Yellow)
  }
}

@Builder
export function showDateComponent() {
  DateComponent()
}