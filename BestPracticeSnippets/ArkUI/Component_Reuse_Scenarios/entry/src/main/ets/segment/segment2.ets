interface IDataSource {
  totalCount: () => number;
  getData: (index: number) => number;
  registerDataChangeListener: (listener: DataChangeListener) => void;
  unregisterDataChangeListener: (listener: DataChangeListener) => void;
}

// [Start Case2]
@Entry
@Component
struct ReuseType2A {
  // [StartExclude Case2]
  private dataSource: IDataSource = {
    totalCount: () => 0,
    getData: (index: number) => index,
    registerDataChangeListener: () => {
    },
    unregisterDataChangeListener: () => {
    }
  }

  // [EndExclude Case2]
  build() {
    Column() {
      List() {
        LazyForEach(this.dataSource, (item: number) => {
          ListItem() {
            if (item % 2 === 0) { // Simulate business condition judgment
              SinglePicture() // Render single image list item
            } else {
              MultiPicture() // Rendering multi-image list items
            }
          }
        }, (item: number) => item + '')
      }
    }
  }
}


// Multiplexing component 1
@Reusable
@Component
struct SinglePicture {
  // [StartExclude Case2]
  build() {
    Column() {
    }
  }

  // [EndExclude Case2]
}


// Multiplexing component 2
@Reusable
@Component
struct MultiPicture {
  // [StartExclude Case2]
  build() {
    Column() {
    }
  }

  // [EndExclude Case2]
}

// [End Case2]