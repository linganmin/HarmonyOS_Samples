// [Start use_node_controller]
// Use the Page page of NodeController.
// Index.ets
import {getNWeb} from './common';

@Entry
@Component
struct Index {
  build() {
    Row() {
      Column() {
        // NodeContainer is used to bind with NodeController node, and rebuild will trigger makeNode.
        // Page page is bound to NodeController through NodeContainer interface to realize dynamic component page display.
        NodeContainer(getNWeb('https://www.example.com'))
          .height('90%')
          .width('100%')
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End use_node_controller]