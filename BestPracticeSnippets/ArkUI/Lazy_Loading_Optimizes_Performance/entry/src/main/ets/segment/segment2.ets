interface DataChangeListener {
  onDataReloaded(): void;

  onDataAdd(index: number): void;

  onDataDelete(index: number): void;

  onDataChange(index: number): void;
}


class MyDataSource {
  private _data: string[] = [];
  private _listeners: DataChangeListener[] = [];

  pushData(item: string): void {
    this._data.push(item);
    this._listeners.forEach(listener => {
      listener.onDataAdd(this._data.length - 1);
    });
  }

  getAllData(): string[] {
    return this._data;
  }

  totalCount(): number {
    return this._data.length;
  }

  getData(index: number): string {
    return this._data[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    this._listeners.push(listener);
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this._listeners.indexOf(listener);
    if (index !== -1) {
      this._listeners.splice(index, 1);
    }
  }
}

// [Start Case2]
@Entry
@Component
struct Index {
  private data: MyDataSource = new MyDataSource();
  private scroller: Scroller = new Scroller();

  aboutToAppear() {
    for (let i = 0; i <= 30; i++) {
      this.data.pushData(`Hello ${i}`)
    }
  }

  build() {
    Column() {
      Grid(this.scroller) {
        LazyForEach(this.data, (lazyForEachItem: string) => {
          GridItem() {
            Text(lazyForEachItem)
              .fontSize(50)
              .width('100%')
          }
          .onAppear(() => {
            console.info("appear:" + lazyForEachItem)
          })
        }, (item: string) => {
          return item;
        })
      }
      .columnsTemplate('1fr')
      .enableScrollInteraction(true)
      .width('100%')
      .height(800)
      .cachedCount(5)
    }
    .width('100%')
    .height(700)
  }
}

// [End Case2]