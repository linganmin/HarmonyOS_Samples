/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

/*
 * Router
 */
export interface RouterParams {
  name?: string,
  onPop?: (data: PopInfo) => void
}

export class AppRouter {
  private static instance = new AppRouter();
  private pathStack: NavPathStack = new NavPathStack();

  public static getInstance(): AppRouter {
    return AppRouter.instance;
  }

  // [Start get_path_stack]
  public getPathStack(): NavPathStack {
    return this.pathStack;
  }

  // [End get_path_stack]
  private pushPath(name: string): void {
    this.pathStack.pushPath({ name: name });
  }

  public static push(name: string): void {
    AppRouter.instance.pushPath(name);
  }

  // [Start push_path_by_name]
  private pushPathByName(name: string, param: Object, onPop: Callback<PopInfo>): void {
    this.pathStack.pushPathByName(name, param, onPop);
  }

  // [End push_path_by_name]

  // [Start push_by_name]
  public static pushByName(name: string, param: Object, onPop: Callback<PopInfo>): void {
    AppRouter.instance.pushPathByName(name, param, onPop);
  }

  // [End push_by_name]
  public static openDialog(name: string, params?: RouterParams): void {
    AppRouter.instance.pathStack.pushPath({
      name: name, param: params, onPop: (data: PopInfo) => {
        if (params?.onPop) {
          params.onPop!(data);
        }
      }
    });
  }

  public static replace(name: string, params?: RouterParams): void {
    AppRouter.instance.pathStack.replacePath({ name: name, param: params });
  }

  public static getParams(name: string): string {
    return JSON.stringify(AppRouter.instance.pathStack.getParamByName(name));
  }

  // [Start get_last_params]
  public static getLastParams(): Object {
    return AppRouter.instance.pathStack.getParamByIndex(AppRouter.instance.pathStack.size() - 1) as Object;
  }

  // [End get_last_params]
  public static getPageIndex(): number {
    return AppRouter.instance.pathStack.size() - 1;
  }

  public static pop(): void {
    AppRouter.instance.pathStack.pop();
  }

  public static popWithResult(params: RouterParams): void {
    AppRouter.instance.pathStack.pop(params);
  }

  public static popWithParam(param: object): void {
    AppRouter.instance.pathStack.pop(param);
  }
}