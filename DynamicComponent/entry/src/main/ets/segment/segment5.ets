// [Start segment5_start]
// [StartExclude segment5_start]
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
      .margin({ bottom: 36 })
  }
}

// [EndExclude segment5_start]

class TextNodeController extends NodeController {
  private textNode: BuilderNode<[Params]> | null = null;
  private message: string = '';

  constructor(message: string) {
    super();
    this.message = message;
  }

  makeNode(context: UIContext): FrameNode | null {
    // With the addition of null handling, the following code is executed only when the BuilderNode is created for the first time; when replacing a node, textNode is not null
    if (this.textNode == null) {
      this.textNode = new BuilderNode(context);
      this.textNode.build(wrapBuilder<[Params]>(testBuilder), new Params(this.message));
    }

    return this.textNode.getFrameNode();
  }

  replaceBuilderNode(newNode: BuilderNode<Object[]>) {
    this.textNode = newNode;
    // The rebuild method re-calls the makeNode method.
    this.rebuild();
  }
}

// [StartExclude segment5_start]
// [EndExclude segment5_start]
// [End segment5_start]