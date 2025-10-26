interface MemoInfo {
  id: string;
  title: string;
  content: string;
  imageSrc: string;
}

interface IDataSource {
  totalCount: () => number;
  getData: (index: number) => MemoInfo;
  registerDataChangeListener: (listener: DataChangeListener) => void;
  unregisterDataChangeListener: (listener: DataChangeListener) => void;
}

const MEMO_DATA: MemoInfo[] = [
  {
    id: '1',
    title: '',
    content: '',
    imageSrc: ''
  },
  {
    id: '2',
    title: '',
    content: '',
    imageSrc: 'example.jpg'
  }
];

// [Start Case3]
@Entry
@Component
struct ReuseType2B {
  // [StartExclude Case3]
  private dataSource: IDataSource = {
    totalCount: () => MEMO_DATA.length,
    getData: (index: number) => MEMO_DATA[index],
    registerDataChangeListener: () => {
    },
    unregisterDataChangeListener: () => {
    }
  }

  // [EndExclude Case3]
  build() {
    Column() {
      List() {
        LazyForEach(this.dataSource, (item: MemoInfo) => {
          ListItem() {
            MemoItem({ memoItem: item })// Control of component reuse using reuseId
              .reuseId((item.imageSrc !== '') ? 'withImage' : 'noImage')
          }
        }, (item: MemoInfo) => JSON.stringify(item))
      }
    }
  }
}


@Reusable
@Component
export default struct MemoItem {
  @State memoItem: MemoInfo = MEMO_DATA[0];

  aboutToReuse(params: Record<string, Object>) {
    this.memoItem = params.memoItem as MemoInfo;
  }

  build() {
    Row() {
      // ...
      if (this.memoItem.imageSrc !== '') {
        Image($r(this.memoItem.imageSrc))
          .width(90)
          .aspectRatio(1)
          .borderRadius(10)
      }
    }

    // ...
  }
}

// [End Case3]