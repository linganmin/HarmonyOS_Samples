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

/**
 * Color Model
 */
export class ColorModel {
  id: string;
  text: string;
  color: Color | string;

  constructor(id: string, text: string, color: Color) {
    this.id = id;
    this.text = text;
    this.color = color;
  }
}

/**
 * List data Color source.
 */
export class ColorData implements IDataSource {
  private listeners: DataChangeListener[] = [];
  textColorData: Array<ColorModel> = [];

  /**
   * Total data count.
   */
  public totalCount(): number {
    return this.textColorData.length;
  }

  /**
   * Return the data of index.
   */
  public getData(index: number): ColorModel | void {
    if (index === this.textColorData.length - 1) {
      this.getColorData();
    }
    return this.textColorData[index];
  }

  /**
   * Add data.
   */
  public pushData(data: ColorModel): void {
    this.textColorData.push(data);
    this.notifyDataAdd(this.textColorData.length - 1);
  }

  /**
   * Set and Get data color.
   */
  public async getColorData(): Promise<void> {
    const uiContext: UIContext | undefined = AppStorage.get('uiContext');
    let color: Array<Color | string> =
      [Color.Black, '#46B1E3', '#61CFBE', '#64BB5C', '#A5D61D', Color.Black, '#46B1E3', '#61CFBE', '#64BB5C',
        '#A5D61D'];
    for (let i = 0; i < color.length; i++) {
      let colorModel: ColorModel = new ColorModel('', '', Color.White);
      colorModel.id = Math.floor(this.totalCount() / color.length) + i.toString();
      colorModel.text =
        uiContext!.getHostContext()!
          .resourceManager
          .getStringSync($r('app.string.Update_component_title'), parseInt(colorModel.id) + 1);
      colorModel.color = color[i];
      this.pushData(colorModel);
    }
  }

  /**
   * Register data change listener.
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  /**
   * Unregister data change listener.
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos > 0) {
      this.listeners.splice(pos, 1);
    }
  }

  /**
   * Data of listener added.
   */
  notifyDataAdd(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataAdd(index);
    })
  }
}

