// [Start Custom_Components]
@Component
export struct example {
  build() {
    Column(){
      Text('Custom Component Sample Code')
      // ...
    }
  }
}
// [End Custom_Components]

// [Start Custom_Functions]
@Builder
export function example1(){
  Column(){
    Text('Sample code for customizing the constructor')
    // ...
  }
}
// [End Custom_Functions]