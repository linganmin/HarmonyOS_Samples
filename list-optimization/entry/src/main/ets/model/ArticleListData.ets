import { LearningResource } from '../model/LearningResource';

export default class ArticleListData implements IDataSource {
  private dataArray: LearningResource[];
  private listeners: DataChangeListener[] = [];

  constructor(dataArray: LearningResource[]) {
    this.dataArray = dataArray;
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }


  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): LearningResource {
    return this.dataArray[index];
  }

  public addData(index: number, data: LearningResource): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: LearningResource): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }
}