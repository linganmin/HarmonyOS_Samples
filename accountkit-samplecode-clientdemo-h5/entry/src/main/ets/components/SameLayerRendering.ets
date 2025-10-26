/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { UIContext, NodeController, BuilderNode, NodeRenderType, FrameNode } from "@kit.ArkUI";
import { loginComponentManager } from '@kit.AccountKit';
import { LoginButton } from './LoginButton';
import { ConstantValue } from '../common/Constants';

@Builder
function LoginBuilder($$: Params) {
  LoginButton({ loginController: $$.loginController }).height($$.height).width($$.width)
}

@Observed
declare class Params {
  width: number
  height: number
  loginController: loginComponentManager.LoginWithHuaweiIDButtonController
}

declare class nodeControllerParams {
  surfaceId: string
  type: string
  renderType: NodeRenderType
  width: number
  height: number
}

// Used to control and report the behavior of the corresponding node in NodeContainer. This function must be used together with NodeContainer.
export class LoginComponentNodeController extends NodeController {
  private rootNode: BuilderNode<[Params]> | undefined | null; // Custom declarative node, on which system components can be mounted.
  private surfaceId: string = ""; // ID of the texture (UI) receiver.
  private renderType: NodeRenderType = NodeRenderType.RENDER_TYPE_DISPLAY; // Rendering type of the node.
  private width: number = 0; // Width of the one-tap sign-in component.
  private height: number = 0; // Height of the one-tap sign-in component.
  private type: string = ""; // Match the type of the embed tag.
  private isDestroy: boolean = false; // Indicate whether the one-tap sign-in component is uninstalled.
  loginController: loginComponentManager.LoginWithHuaweiIDButtonController

  constructor(loginController: loginComponentManager.LoginWithHuaweiIDButtonController) {
    super();
    this.loginController = loginController;
  }

  setRenderOption(params: nodeControllerParams) {
    this.surfaceId = params.surfaceId;
    this.renderType = params.renderType;
    this.width = params.width;
    this.height = params.height;
    this.type = params.type;
  }

  // Method that must be overridden. It is used to build a node tree. The returned node tree will be mounted to the corresponding NodeContainer.
  makeNode(uiContext: UIContext): FrameNode | null {
    // If isDestroy is true, an empty value will be returned.
    if (this.isDestroy) {
      return null;
    }
    // Initialize rootNode.
    this.rootNode = new BuilderNode(uiContext, { surfaceId: this.surfaceId, type: this.renderType });
    // The type of embed for the HTML5 page is sign-in button.
    if (this.type === ConstantValue.LOGIN_BUTTON_EMBED_TYPE) {
      this.rootNode.build(
        wrapBuilder(LoginBuilder),
        {
          width: this.width,
          height: this.height,
          loginController: this.loginController
        }
      );
    } else {
      // Other components can be added at the same layer.
    }
    // Return FrameNode.
    return this.rootNode.getFrameNode();
  }

  // Modify isDestroy. If isDestroy is true, clear rootNode to free up memory.
  setDestroy(isDestroy: boolean): void {
    this.isDestroy = isDestroy;
    if (this.isDestroy) {
      this.rootNode = null;
    }
  }

  // Send the touch event to the target element node (one-tap sign-in component).
  postEvent(event: TouchEvent | undefined): boolean {
    return this.rootNode?.postTouchEvent(event) as boolean;
  }
}
