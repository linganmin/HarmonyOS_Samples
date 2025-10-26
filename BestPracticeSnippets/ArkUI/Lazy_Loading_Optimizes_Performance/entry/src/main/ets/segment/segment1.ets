interface DataChangeListener {
  onDataReloaded(): void;

  onDataAdd(index: number): void;

  onDataDelete(index: number): void;

  onDataChange(index: number): void;
}


export class MyDataSource {
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

// [Start Case1]
@Entry
@Component
struct Index {
  private data: MyDataSource = new MyDataSource();

  aboutToAppear() {
    for (let i = 0; i <= 30; i++) {
      this.data.pushData(`Hello ${i}`)
    }
  }

  build() {
    List({ space: 3 }) {
      LazyForEach(this.data, (lazyForEachItem: string) => {
        ListItem() {
          Column() {
            ForEach(this.data.getAllData(), (forEachItem: string) => {
              ListItem() {
                Row() {
                  Text(lazyForEachItem + forEachItem).fontSize(50)
                    .onAppear(() => {
                      console.info("appear:" + lazyForEachItem)
                    })
                }.margin({ left: 10, right: 10 })
              }
            }, (item: string) => item)
          }
        }
      }, (item: string) => item)
    }.cachedCount(5)
  }
}

// [End Case1]