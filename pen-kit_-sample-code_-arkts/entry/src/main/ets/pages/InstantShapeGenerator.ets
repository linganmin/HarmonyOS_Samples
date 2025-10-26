import { InstantShapeGenerator, ShapeInfo} from '@kit.Penkit';

@Entry
@Component
struct InstantShapeDemo {
  private instantShapeGenerator: InstantShapeGenerator = new InstantShapeGenerator();

  private points: DrawPathPointModel[] = [];
  // draw path
  private drawPath = new Path2D();

  private shapePath = new Path2D();

  private mShapeSuccess = false;

  private settings: RenderingContextSettings = new RenderingContextSettings(true);

  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  // Get the recognition result through the callback method
  private shapeInfoCallback = (shapeInfo: ShapeInfo) => {
    this.shapePath = shapeInfo.shapePath;
    this.mShapeSuccess = true;
    this.context.beginPath();
    this.context.reset();
    this.drawCurrentPathModel(this.shapePath);
  }

  aboutToAppear() {
    console.info('InstantShapeGenerator aboutToAppear');
    // Set the pause time for trigger recognition.
    try {
      this.instantShapeGenerator?.setPauseTime(280);
    } catch (err) {
      console.error(`setPauseTime failed. Code is ${err.code}, message is ${err.message}`)
    }
    // Callback method when registration is completed.
    this.instantShapeGenerator?.onShapeRecognized(this.shapeInfoCallback);
  }
  aboutToDisappear(){
    console.info('InstantShapeGenerator aboutToDisappear')
    this.instantShapeGenerator?.release();
  }
  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .onAreaChange((oldValue: Area, newValue: Area) => {
          // Notifies the component size change. The size of the shape (e.g., the radius of the circle) varies according to the size of the assembly.
          try {
            this.instantShapeGenerator?.notifyAreaChange(Number(newValue.width), Number(newValue.height));
          } catch (err) {
            console.error(`notifyAreaChange failed. Code is ${err.code}, message is ${err.message}`)
          }
        }).onTouch((event: TouchEvent) => {
        // Passing a Touch Event
        try {
          this.instantShapeGenerator?.processTouchEvent(event);
        } catch (err) {
          console.error(`processTouchEvent failed. Code is ${err.code}, message is ${err.message}`)
        }
        switch (event.type) {
          case TouchType.Down:
            this.moveStart(event.touches[0]?.x, event.touches[0]?.y);
            break;
          case TouchType.Move:
            this.moveUpdate(event.touches[0]?.x, event.touches[0]?.y);
            break;
          case TouchType.Up:
            this.moveEnd();
            break;
        }
      })
    }.height('100%').width('100%')
  }

  moveStart(x: number, y: number) {
    this.points.push({x: x, y: y})
    this.drawPath.moveTo(x, y);
    this.drawCurrentPathModel(this.drawPath);
    this.mShapeSuccess = false;
  }

  moveUpdate(x: number, y: number) {
    let lastPoint = this.points[this.points.length - 1];
    this.points.push({x: x, y: y});
    this.drawPath.quadraticCurveTo((x + lastPoint?.x) / 2, (y + lastPoint?.y) / 2, x, y);
    if (!this.mShapeSuccess) {
      this.drawCurrentPathModel(this.drawPath);
    }
  }

  moveEnd() {
    this.points = [];
    this.drawPath = new Path2D();
    this.shapePath = new Path2D();
  }

  private drawCurrentPathModel(path : Path2D) {
    this.context.globalCompositeOperation = 'source-over';
    this.context.lineWidth = 8;
    this.context.strokeStyle = "#ED1B1B";
    this.context.lineJoin = 'round';
    this.context.stroke(path);
  }
}

export class DrawPathPointModel {
  x: number = 0;
  y: number = 0;
}