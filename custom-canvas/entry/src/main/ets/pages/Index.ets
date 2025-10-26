/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { display } from '@kit.ArkUI';
import DrawInvoker from '../viewmodel/DrawInvoker';
import DrawPath from '../viewmodel/IDraw';
import { IBrush } from '../viewmodel/IBrush';
import NormalBrush from '../viewmodel/IBrush';
import Paint from '../viewmodel/Paint';
import { CommonConstants } from '../common/CommonConstants';
import { myPaintSheet } from '../view/myPaintSheet';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct DrawCanvas {
  @State @Watch('createDraw') isDrawing: boolean = false;
  @State unDoDraw: boolean = false;
  @State redoDraw: boolean = false;
  @State isPaint: boolean = true;
  @State isShow: boolean = false;
  @State isMarker: boolean = false;
  @State scaleValueX: number = 1;
  @State scaleValueY: number = 1;
  @State pinchValueX: number = 1;
  @State pinchValueY: number = 1;
  @State strokeWidth: number = 3;
  @State alpha: number = 1;
  @State color: string = '#000000';
  @State thicknessesValue: number = 3;
  @State index: number = -1;
  @State clean: boolean = false;
  @State percent: string = '100';
  @Provide mPaint: Paint = new Paint(0, '', 1);
  @Provide mBrush: IBrush = new NormalBrush();
  private setting: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.setting);
  private drawInvoker: DrawInvoker = new DrawInvoker();
  private path2Db: Path2D = new Path2D();
  private mPath: DrawPath = new DrawPath(this.mPaint, this.path2Db);
  private arr: number[] = [];

  aboutToAppear(): void {
    this.mPaint = new Paint(CommonConstants.ZERO, CommonConstants.COLOR_STRING, CommonConstants.ONE);
    this.mPaint.setStrokeWidth(CommonConstants.THREE);
    this.mPaint.setColor(CommonConstants.BLACK);
    this.mPaint.setGlobalAlpha(CommonConstants.ONE);
    this.mBrush = new NormalBrush();
    try {
      display.on('foldStatusChange', (data: display.FoldStatus) => {
        if (data === 2) {
          this.scaleValueX = 0.5;
          this.pinchValueX = 0.5;
          this.scaleValueY = 1;
          this.pinchValueY = 1;
          this.context.clearRect(0, 0, this.context.width, this.context.height);
          this.drawInvoker.execute(this.context);
        } else if (data === 1) {
          this.scaleValueX = 1;
          this.scaleValueY = 1;
          this.pinchValueX = 1;
          this.pinchValueY = 1;
          this.context.clearRect(0, 0, this.context.width, this.context.height);
          this.drawInvoker.execute(this.context);
        }
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'Index', `listen foldStatusChange failed. code=${err.code}, message=${err.message}`);
    }
  }

  createDraw() {
    if (this.isDrawing) {
      this.context.fillStyle = Color.White;
      this.context.fillRect(CommonConstants.ZERO, CommonConstants.ZERO, this.context.width, this.context.height);
      this.drawInvoker.execute(this.context);
      this.isDrawing = false;
    }
  }

  /**
   * Add a sketch path.
   */
  add(path: DrawPath): void {
    this.drawInvoker.add(path);
  }

  /**
   * Toggle weight, color, transparency.
   */
  ToggleThicknessColor(): void {
    this.mPaint = new Paint(CommonConstants.ZERO, CommonConstants.COLOR_STRING, CommonConstants.ONE);
    this.mPaint.setStrokeWidth(this.strokeWidth);
    this.mPaint.setColor(this.color);
    this.mPaint.setGlobalAlpha(this.alpha);
    this.mBrush = new NormalBrush();
  }

  /**
   * Undo operation.
   */
  drawOperateUndo(): void {
    this.drawInvoker.undo();
    this.isDrawing = true;
    if (!this.drawInvoker.canUndo()) {
      this.unDoDraw = false;
    }
    this.redoDraw = true;
  }

  /**
   * Redo operation.
   */
  drawOperateRedo(): void {
    this.drawInvoker.redo();
    this.isDrawing = true;
    if (!this.drawInvoker.canRedo()) {
      this.redoDraw = false;
    }
    this.unDoDraw = true;
  }

  /**
   * Clear operation.
   */
  clear(): void {
    this.drawInvoker.clear();
    this.isDrawing = true;
    this.redoDraw = false;
    this.unDoDraw = false;
  }

  @Builder
  myPaintSheet() {
    Column() {
      myPaintSheet({
        isMarker: this.isMarker,
        alpha: this.alpha,
        percent: this.percent,
        color: this.color,
        thicknessesValue: this.thicknessesValue,
        strokeWidth: this.strokeWidth
      })
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Canvas(this.context)
        .width(CommonConstants.CANVAS_WIDTH)
        .height(CommonConstants.CANVAS_WIDTH)
        .backgroundColor($r('sys.color.white'))
        .onTouch((event: TouchEvent) => {
          this.clean = false;
          if (this.index === 1 || event.touches.length > 1) {
            return;
          }
          this.arr.push(event.touches[0].x + event.touches[0].y);
          if (event.touches.length === 1 && event.touches[0].id === 0 && event.type === TouchType.Down) {
            this.mPath = new DrawPath(this.mPaint, this.path2Db);
            this.mPath.paint = this.mPaint;
            this.mPath.path = new Path2D();
            this.mBrush.down(this.mPath.path, event.touches[0].x, event.touches[0].y);
          }
          if (event.touches.length === 1 && event.touches[0].id === 0 && event.type === TouchType.Move) {
            this.mBrush.move(this.mPath.path, event.touches[0].x, event.touches[0].y);
            this.context.clearRect(0, 0, this.context.width, this.context.height);
            this.drawInvoker.execute(this.context);
            if (this.arr.length > 4) {
              this.mPath.draw(this.context);
            }
          }
          if (event.touches.length === 1 && event.touches[0].id === 0 && event.type === TouchType.Up) {
            this.add(this.mPath);
            this.arr = [];
            this.redoDraw = false;
            this.unDoDraw = true;
            this.isDrawing = true;
            this.context.clearRect(0, 0, this.context.width, this.context.height);
            this.drawInvoker.execute(this.context);
          }
        })
        .scale({
          x: this.scaleValueX,
          y: this.scaleValueY,
          z: CommonConstants.ONE
        })
        .gesture(
          PinchGesture()
            .onActionStart(() => {
              this.index = 1;
            })
            .onActionUpdate((event: GestureEvent) => {
              this.context.clearRect(0, 0, this.context.width, this.context.height);
              this.drawInvoker.execute(this.context);
              if (event) {
                this.scaleValueX = this.pinchValueX * event.scale;
                this.scaleValueY = this.pinchValueY * event.scale;
              }
            })
            .onActionEnd(() => {
              this.pinchValueX = this.scaleValueX;
              this.pinchValueY = this.scaleValueY;
              this.context.clearRect(0, 0, this.context.width, this.context.height);
              this.drawInvoker.execute(this.context);
            })
        )
      Column()
        .width(CommonConstants.ONE_HUNDRED_PERCENT)
        .height(CommonConstants.ONE_HUNDRED_PERCENT)
        .backgroundColor(Color.Transparent)
        .zIndex(this.index)
        .gesture(
          PinchGesture()
            .onActionStart(() => {
              this.index = 1;
            })
            .onActionUpdate((event: GestureEvent) => {
              this.context.clearRect(0, 0, this.context.width, this.context.height);
              this.drawInvoker.execute(this.context);
              if (event) {
                this.scaleValueX = this.pinchValueX * event.scale;
                this.scaleValueY = this.pinchValueY * event.scale;
              }
            })
            .onActionEnd(() => {
              this.context.clearRect(0, 0, this.context.width, this.context.height);
              this.drawInvoker.execute(this.context);
              this.pinchValueX = this.scaleValueX;
              this.pinchValueY = this.scaleValueY;
            })
        )
      Row() {
        Stack() {
          Column() {
            Image(this.isPaint && this.index === CommonConstants.NEGATIVE_ONE ? $r('app.media.paintbrush_active') :
            $r('app.media.paintbrush'))
              .width($r('app.float.image_width'))
              .height($r('app.float.image_width'))
              .margin({ bottom: $r('app.float.bottom') })
            Text($r('app.string.paint'))
              .fontSize($r('app.float.font_size_m'))
              .fontColor(this.isPaint && this.index === CommonConstants.NEGATIVE_ONE ? $r('app.color.theme_color') :
              $r('sys.color.mask_secondary'))
          }
          .width(CommonConstants.ONE_HUNDRED_PERCENT)
          .height(CommonConstants.ONE_HUNDRED_PERCENT)

          Button({ type: ButtonType.Normal })
            .backgroundColor(Color.Transparent)
            .width(CommonConstants.ONE_HUNDRED_PERCENT)
            .height(CommonConstants.ONE_HUNDRED_PERCENT)
            .onClick(() => {
              this.ToggleThicknessColor();
              this.isPaint = true;
              this.isShow = !this.isShow;
              this.index = -1;
              this.arr = [];
            })
        }
        .bindSheet($$this.isShow, this.myPaintSheet(), {
          height: $r('app.float.height'),
          backgroundColor: Color.White,
          title: {
            title: $r('app.string.paint')
          },
          detents: CommonConstants.DETENTS
        })
        .width($r('app.float.paint_width'))
        .height($r('app.float.paint_height'))

        Stack() {
          Column() {
            Image(this.isPaint || this.index === CommonConstants.ONE ? $r('app.media.rubbers') :
            $r('app.media.rubbers_active'))
              .width($r('app.float.image_width'))
              .height($r('app.float.image_width'))
              .margin({ bottom: $r('app.float.bottom') })
            Text($r('app.string.rubber'))
              .fontSize($r('app.float.font_size_m'))
              .fontColor(this.isPaint || this.index === CommonConstants.ONE ? $r('sys.color.mask_secondary') :
              $r('app.color.theme_color'))

          }
          .width(CommonConstants.ONE_HUNDRED_PERCENT)
          .height(CommonConstants.ONE_HUNDRED_PERCENT)

          Button({ type: ButtonType.Normal })
            .backgroundColor(Color.Transparent)
            .width(CommonConstants.ONE_HUNDRED_PERCENT)
            .height(CommonConstants.ONE_HUNDRED_PERCENT)
            .onClick(() => {
              this.mPaint = new Paint(CommonConstants.ZERO, CommonConstants.COLOR_STRING, CommonConstants.ONE);
              this.mPaint.setStrokeWidth(CommonConstants.TEN);
              this.mPaint.setColor(CommonConstants.WHITE);
              this.mPaint.setGlobalAlpha(CommonConstants.ONE);
              this.isPaint = false;
            })
        }
        .width($r('app.float.paint_width'))
        .height($r('app.float.paint_height'))

        Stack() {
          Column() {
            Image(this.unDoDraw ? $r('app.media.recall_active') : $r('app.media.recall'))
              .width($r('app.float.image_width'))
              .height($r('app.float.image_width'))
              .margin({ bottom: $r('app.float.bottom') })
            Text($r('app.string.redo'))
              .fontSize($r('app.float.font_size_m'))
              .fontColor(this.unDoDraw ? $r('app.color.theme_color') : $r('sys.color.mask_secondary'))
          }
          .width(CommonConstants.ONE_HUNDRED_PERCENT)
          .height(CommonConstants.ONE_HUNDRED_PERCENT)

          Button({ type: ButtonType.Normal })
            .backgroundColor(Color.Transparent)
            .enabled(this.unDoDraw)
            .width(CommonConstants.ONE_HUNDRED_PERCENT)
            .height(CommonConstants.ONE_HUNDRED_PERCENT)
            .onClick(async () => {
              this.drawOperateUndo();
              this.context.clearRect(0, 0, this.context.width, this.context.height);
              this.drawInvoker.execute(this.context);
            })
        }
        .width($r('app.float.paint_width'))
        .height($r('app.float.paint_height'))

        Stack() {
          Column() {
            Image(this.redoDraw ? $r('app.media.redo_active') : $r('app.media.redo'))
              .width($r('app.float.image_width'))
              .height($r('app.float.image_width'))
              .margin({ bottom: $r('app.float.bottom') })
            Text($r('app.string.undo'))
              .fontSize($r('app.float.font_size_m'))
              .fontColor(this.redoDraw ? $r('app.color.theme_color') : $r('sys.color.mask_secondary'))
          }
          .width(CommonConstants.ONE_HUNDRED_PERCENT)
          .height(CommonConstants.ONE_HUNDRED_PERCENT)

          Button({ type: ButtonType.Normal })
            .backgroundColor(Color.Transparent)
            .enabled(this.redoDraw)
            .width(CommonConstants.ONE_HUNDRED_PERCENT)
            .height(CommonConstants.ONE_HUNDRED_PERCENT)
            .onClick(async () => {
              this.drawOperateRedo();
              this.context.clearRect(0, 0, this.context.width, this.context.height);
              this.drawInvoker.execute(this.context);
            })
        }
        .width($r('app.float.paint_width'))
        .height($r('app.float.paint_height'))

        Stack() {
          Column() {
            Image(this.clean ? $r('app.media.clear_active') : $r('app.media.clear'))
              .width($r('app.float.image_width'))
              .height($r('app.float.image_width'))
              .margin({ bottom: $r('app.float.bottom') })
            Text($r('app.string.clear'))
              .fontSize($r('app.float.font_size_m'))
              .fontColor(this.clean ? $r('app.color.theme_color') : $r('sys.color.mask_secondary'))
          }
          .width(CommonConstants.ONE_HUNDRED_PERCENT)
          .height(CommonConstants.ONE_HUNDRED_PERCENT)

          Button({ type: ButtonType.Normal })
            .backgroundColor(Color.Transparent)
            .width(CommonConstants.ONE_HUNDRED_PERCENT)
            .height(CommonConstants.ONE_HUNDRED_PERCENT)
            .onClick(async () => {
              this.clear();
              this.context.clearRect(0, 0, this.context.width, this.context.height);
              this.drawInvoker.execute(this.context);
              this.clean = true;
            })
        }
        .width($r('app.float.paint_width'))
        .height($r('app.float.paint_height'))
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .zIndex(CommonConstants.TEN)
    }
    .backgroundColor($r('sys.color.comp_background_focus'))
    .width(CommonConstants.ONE_HUNDRED_PERCENT)
    .height(CommonConstants.ONE_HUNDRED_PERCENT)
  }
}