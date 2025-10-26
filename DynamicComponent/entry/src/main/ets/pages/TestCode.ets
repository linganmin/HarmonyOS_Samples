import { UIContext } from "@ohos.arkui.UIContext";

// [Start abstract_class_node_controller]
export abstract class NodeController {
  abstract makeNode(uiContext: UIContext): FrameNode | null;
  aboutToResize?(size: Size): void;
  aboutToAppear?(): void;
  aboutToDisappear?(): void;
  abstract rebuild(): void;
  onTouchEvent?(event: TouchEvent): void;
}
// [End abstract_class_node_controller]

const data: number = 0
// [Start imperative_controller]
class ImperativeController extends NodeController {
  // [StartExclude imperative_controller]
  rebuild(): void {
    throw new Error("Method not implemented.");
  }
  // [EndExclude imperative_controller]
  makeNode(uiContext: UIContext): FrameNode | null {
    return frameNodeFactory(data, uiContext);
  }
}

@Component
export struct ImperativePage {
  private controller: ImperativeController = new ImperativeController();

  build() {
    Column() {
      NodeContainer(this.controller)
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.Black)
  }
}
// [End imperative_controller]

function frameNodeFactory(data: number,
  uiContext: UIContext): import("c:/Program Files/Huawei/DevEco Studio/sdk/default/openharmony/ets/api/@ohos.arkui.node").FrameNode | null {
  throw new Error("Function not implemented.");
}
