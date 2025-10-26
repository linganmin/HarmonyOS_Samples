// [Start Params_start]
import { BuilderNode, FrameNode, NodeController } from '@kit.ArkUI';

class Params {
  text: string = 'Hello World';
  constructor(text: string) {
    this.text = text;
  }
}

@Builder
function testBuilder(params: Params) {
  Column() {
    Text(params.text)
      .fontSize(50)
      .fontWeight(FontWeight.Bold)
      .margin({bottom: 36})
  }
}
// [StartExclude Params_start]
// [EndExclude Params_start]
// [End Params_start]

// [Start TextNodeController_start]
// ...
class TextNodeController extends NodeController {
  private textNode: BuilderNode<[Params]> | null = null;
  private message: string = '';

  constructor(message: string) {
    super();
    this.message = message;
  }

  makeNode(context: UIContext): FrameNode | null {
    return null;
  }
}
// [End TextNodeController_start]




