/*
 * Copyright (c) 2024-2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { arEngine, ARView, arViewController } from '@kit.AREngine';
import {
  CustomGeometry,
  Geometry,
  Image,
  Material,
  MaterialType,
  MeshResource,
  Node,
  PrimitiveTopology,
  Scene,
  SceneResourceFactory,
  Shader,
  ShaderMaterial,
  Vec3
} from '@kit.ArkGraphics3D';
import { collections } from '@kit.ArkTS';
import { Matrix4 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { Logger } from '../utils/Logger';
import { calculatePoint, createImageIndex, getImageVertices } from '../utils/Utils';

@Builder
export function ARImageByAddBuilder(): void {
  ARImageByAdd();
}

let dataBase: arEngine.ARAugmentedImageDatabase;

interface Blend {
  enabled: boolean;
}

interface CustomerMaterial extends Material {
  blend: Blend;
}

@Component
struct ARImageByAdd {
  pageInfos: NavPathStack = new NavPathStack();
  private imagePathArray: string[] = [];
  // When destroy is set to true, the addImage function is used to determine whether to continue adding images.
  private isProgramExits: boolean = false;
  private isSaveDatabase: boolean = false;
  @State arContext?: arViewController.ARViewContext = undefined;
  @State context: Context = this.getUIContext().getHostContext() as Context;
  @State totalImageCounts: number = this.imagePathArray.length;
  @State addFailedImageCounts: number = 0;
  @State succeedImageCounts: number = 0;
  @State addFailedMessage: string[] = [];

  build(): void {
    NavDestination() {
      RelativeContainer() {
        Column() {
          Text(`${this.context.resourceManager.getStringByNameSync(
            'add_image_msg_count')} ${this.succeedImageCounts +
            this.addFailedImageCounts} / ${this.totalImageCounts}`)
          Text(`${this.context.resourceManager.getStringByNameSync('add_image_msg_success') +
            this.succeedImageCounts}`)
          Text(`${this.context.resourceManager.getStringByNameSync('add_image_msg_fail') +
            this.addFailedImageCounts}`)

          if (this.addFailedMessage) {
            ForEach(this.addFailedMessage, (item: string) => {
              Text(`${item}`)
                .fontColor(Color.Red)
            }, (item: string) => item)
          }
        }
        .visibility(this.addFailedImageCounts + this.succeedImageCounts < this.totalImageCounts ? Visibility.Visible :
        Visibility.None)
        .foregroundColor(Color.Red)
        .zIndex(1)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })

        if (this.arContext) {
          ARView({ context: this.arContext })
            .height('100%')
            .width('100%')
            .alignRules({
              center: { anchor: '__container__', align: VerticalAlign.Center },
              middle: { anchor: '__container__', align: HorizontalAlign.Center }
            })
        }
      }
    }
    .onAppear(() => {
      arEngine.createARAugmentedImageDatabase()
        .then((arDataBase) => {
          dataBase = arDataBase;

          this.addImage(dataBase).then(() => {
            if (this.addFailedImageCounts === this.totalImageCounts) {
              this.ShowDialog(this.context.resourceManager.getStringByNameSync('invalid_image_added'));
            }
            if (this.totalImageCounts === this.succeedImageCounts + this.addFailedImageCounts) {
              this.initARView();
              this.isSaveDatabase = true;
            }
          })
        })
    })
    .onWillDisappear(async () => {
      this.stopARView();
    })
    .onShown(() => {
      this.resumeARView();
    })
    .onHidden(() => {
      this.pauseARView();
    })
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.imagePathArray = context.pathInfo.param as string[];
      this.totalImageCounts = this.imagePathArray.length;
    })
    .hideTitleBar(true)
    .hideBackButton(true)
    .hideToolBar(true)
  }

  private initARView(): void {
    Scene.load().then(async (scene: Scene) => {
      let viewContext: arViewController.ARViewContext = new arViewController.ARViewContext();
      viewContext.scene = scene;
      viewContext.callback = new ARViewCallbackImpl();
      viewContext.config = {
        type: arEngine.ARType.IMAGE,
        planeFindingMode: arEngine.ARPlaneFindingMode.HORIZONTAL_AND_VERTICAL,
        powerMode: arEngine.ARPowerMode.NORMAL,
        semanticMode: arEngine.ARSemanticMode.NONE,
        poseMode: arEngine.ARPoseMode.GRAVITY,
        depthMode: arEngine.ARDepthMode.AUTOMATIC,
        meshMode: arEngine.ARMeshMode.DISABLED,
        focusMode: arEngine.ARFocusMode.AUTO
      }
      viewContext.init().then(() => {
        this.arContext = viewContext;
        Logger.info('Succeeded in initting ARView.');
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to init ARView. Code is ${err.code}, message is ${err.message}.`);
      })
    })
  }

  private async stopARView(): Promise<void> {
    if (!this.arContext) {
      return;
    }
    try {
      this.isProgramExits = true;
      if (this.isSaveDatabase) {
        SaveBufferToLocal(dataBase, this.context);
      }

      await dataBase.release();
      await this.arContext?.destroy();
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to stop context. Code is ${err.code}, message is ${err.message}`);
    }
  }

  private resumeARView(): void {
    if (!this.arContext) {
      return;
    }
    try {
      this.arContext.resume();
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to resume context. Code is ${err.code}, message is ${err.message}.`);
    }
  }

  private pauseARView(): void {
    if (!this.arContext) {
      return;
    }
    try {
      this.arContext.pause();
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to pause context. Code is ${err.code}, message is ${err.message}.`);
    }
  }

  // Asynchronously execute the task of adding pictures
  async addImage(dataBase: arEngine.ARAugmentedImageDatabase): Promise<void> {
    for (let index = 0; index < this.totalImageCounts; index++) {
      const magePath: string = this.imagePathArray[index];
      let file: fileIo.File = fileIo.openSync(magePath, fileIo.OpenMode.READ_ONLY);
      let imageName: string = file.name;
      const imageSourceApi: image.ImageSource = image.createImageSource(file.fd);
      try {
        fileIo.closeSync(file);
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.error(`Failed to closeSync. Code: ${err.code}.`);
        this.addFailedImageCounts += 1;
        continue;
      }
      const imageInfo: image.ImageInfo = imageSourceApi.getImageInfoSync(0);
      if (!imageInfo) {
        Logger.error('Failed to obtain the image pixel map information.');
        this.addFailedImageCounts += 1;
        continue;
      }
      const opts: image.DecodingOptions = {
        editable: true,
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
        desiredSize: { width: imageInfo.size.width, height: imageInfo.size.height }
      }
      let pixelMap: image.PixelMap = imageSourceApi.createPixelMapSync(opts);
      const info: image.ImageInfo = pixelMap.getImageInfoSync();
      let size: number = pixelMap.getPixelBytesNumber();
      Logger.info(`The ets create pixelMap width: ${info.size.width}, height: ${info.size.height}, size: ${size}.`);

      if (this.isProgramExits) {
        break;
      }

      await dataBase.addImage(imageName, pixelMap, 10).then((result: arEngine.ARAddAugmentedImageResult) => {
        Logger.info(`The imageResult: ${result.index} ${result.stateReason}.`);
        if (result.stateReason !== arEngine.ARAddAugmentedImageReason.NONE) {
          this.addFailedImageCounts += 1;
          this.addFailedMessage.push(`${this.context.resourceManager.getStringByNameSync('image_name_by_add') +
            imageName + '\n' + this.context.resourceManager.getStringByNameSync('image_add_reason_by_add') +
          errcode.get(result.stateReason) + '\n'}`);
        } else {
          this.succeedImageCounts += 1;
        }
      }).catch(() => {
        this.addFailedImageCounts += 1;
      })

      imageSourceApi.release();
      pixelMap.release();
    }
  }

  private ShowDialog(msg: string): void {
    this.getUIContext().showAlertDialog({
      title: $r('app.string.warning'),
      message: msg,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: -20 },
      gridCount: 3,
      transition: TransitionEffect.asymmetric(TransitionEffect.OPACITY
        .animation({ duration: 1000, curve: Curve.Sharp })
        .combine(TransitionEffect.scale({ x: 1.5, y: 1.5 })
          .animation({ duration: 1000, curve: Curve.Sharp })),
        TransitionEffect.OPACITY.animation({ duration: 100, curve: Curve.Smooth })
          .combine(TransitionEffect.scale({ x: 0.5, y: 0.5 })
            .animation({ duration: 100, curve: Curve.Smooth }))),
      buttons: [{
        enabled: true,
        defaultFocus: true,
        style: DialogButtonStyle.HIGHLIGHT,
        value: $r('app.string.back'),
        action: () => {
          Logger.info('Callback when the second button is clicked.');
          this.pageInfos.pop();
          return;
        }
      }]
    })
  }
}

// Save the file locally
async function SaveBufferToLocal(dataBase: arEngine.ARAugmentedImageDatabase, context: Context): Promise<void> {
  let filesDir: string = context.filesDir;
  let file: fileIo.File = fileIo.openSync(
    filesDir + '/test.bin', fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
  let buf: ArrayBuffer = await dataBase.serialize();
  let writeLen: number = fileIo.writeSync(file.fd, buf);
  Logger.info(`The length of buffer is: ${writeLen}.`);
  fileIo.closeSync(file);
}

class ARViewCallbackImpl extends arViewController.ARViewCallback {
  geoArr: Geometry[] = [];
  scene: Scene | null = null;
  shader: Shader | null = null;
  material: ShaderMaterial | null = null;
  image: Image | null = null;
  currentGeometry: Geometry | undefined = undefined;

  clearAllNode(): void {
    let childrenNum: number | undefined = this.scene?.root?.children.count();
    if (childrenNum) {
      for (let i = 0; i < childrenNum; i++) {
        let node: Node | null | undefined = this.scene?.root?.children.get(i);
        if (node?.name === 'ARImage') {
          this.scene?.root?.children.remove(node);
          node?.destroy();
        }
      }
    }
  }

  onAnchorAdd(ctx: arViewController.ARViewContext, node: Node, anchor: arEngine.ARAnchor): void {
  }

  onAnchorUpdate(ctx: arViewController.ARViewContext, node: Node, anchor: arEngine.ARAnchor): void {
  }

  async onFrameUpdate(ctx: arViewController.ARViewContext, sysBootTs: number): Promise<void> {
    if (!ctx.session || !dataBase) {
      return;
    }

    let session: arEngine.ARSession = ctx.session;
    this.scene = ctx.scene;

    try {
      let imageNumber: number = dataBase.getImageCount();
      Logger.info(`The number of images in the database is ${imageNumber}.`);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to got image count. Code is ${err.code}, message is ${err.message}`);
    }

    let imageCapacity: number = dataBase.getCapacity();
    Logger.info(`The dataBase image capacity is: ${imageCapacity}.`);

    let trackables: arEngine.ARTrackable[] = session.getAllTrackables(arEngine.ARTrackableType.AUGMENTED_IMAGE);

    // The target image color is controlled by the file plane.shader
    let rf: SceneResourceFactory = ctx.scene.getResourceFactory();
    this.material = await rf.createMaterial({ name: 'CustomMaterial' }, MaterialType.SHADER);
    this.shader = await rf.createShader({ name: 'CustomShader', uri: $rawfile('shaders/custom_shader/plane.shader') });
    this.material.colorShader = this.shader;
    (this.material as CustomerMaterial).blend = { enabled: true };

    Logger.info(`The image trackable size: ${trackables.length}.`);
    let validImage: number = 0;
    for (let i = 0; i < trackables.length; ++i) {
      if (trackables[i].type === arEngine.ARTrackableType.AUGMENTED_IMAGE) {
        let arimage: arEngine.ARAugmentedImage = trackables[i] as arEngine.ARAugmentedImage;
        if (arEngine.ARTrackingState.TRACKING !== arimage.state) {
          continue;
        }
        validImage += 1;
        let centerPose: arEngine.ARPose = arimage.getPose();
        let modelMat: Matrix4 = centerPose.getMatrix();
        let pos: Vec3 = centerPose.translation;
        let drawPos: number[] = calculatePoint(arimage.extendX, arimage.extendZ, pos);

        Logger.info(`The image width: ${arimage.extendX}, height: ${arimage.extendZ}.`);

        if (ctx?.scene) {
          let mesh: CustomGeometry = new CustomGeometry();
          mesh.topology = PrimitiveTopology.TRIANGLE_LIST;
          mesh.vertices = getImageVertices(modelMat, drawPos);
          mesh.indices = createImageIndex(mesh.vertices);

          let meshRes: MeshResource = await rf.createMesh({ name: 'resource' }, mesh);
          let geometry: Geometry = await rf.createGeometry({ name: 'ARImage' }, meshRes);
          meshRes.destroy();
          let len: number = this.geoArr.length;

          // The node from the previous frame needs to be cleared
          for (let index = len - 1; index >= 0; index--) {
            let geo: Geometry | undefined = this.geoArr.pop();
            if (geo) {
              ctx.scene.root?.children.remove(geo);
              geo.destroy();
            }
          }

          // Adding a Plane to a Node
          ctx.scene?.root?.children.append(geometry);
          this.geoArr.push(geometry);
          this.currentGeometry = geometry;
          this.currentGeometry.mesh.materialOverride = this.material as ShaderMaterial;
        }
      }
    }
    if (validImage === 0) {
      // Clean up all ARImage nodes
      this.clearAllNode();
    }
  }
}

const errcode: collections.Map<number, string> = new collections.Map<number, string>([
  [0, 'success'],
  [1, 'size not match'],
  [2, 'too bright or too dark'],
  [3, 'image color is relatively single'],
  [4, 'other error']
])
