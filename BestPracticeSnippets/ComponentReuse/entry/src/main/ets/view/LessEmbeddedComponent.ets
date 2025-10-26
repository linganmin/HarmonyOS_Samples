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

// [Start less_embedded_component]
@Entry
@Component
struct lessEmbeddedComponent {
  getFriendMomentFromRawfile(): void {

  }
  aboutToAppear(): void {
    this.getFriendMomentFromRawfile()
  }


  build() {
    Column() {
      List() {
      }
    }
  }
}


@Reusable
@Component
export struct OneMomentNoBuilder {



  // There is no need to assign aboutToReuse values to variables modified with @ Prop, as these variables are passed from the parent component to the child component. If these variables are reassigned in sub components, it will cause the content of the reused component to trigger a state refresh, thereby reducing the reuse performance of the component.
  build() {
    // Nesting custom components within reusable components
    Row() {
    }
  }
}


@Component
export struct InteractiveButton {

  @State imageStr: ResourceStr = '';
  @State text: ResourceStr  = '';


  // Nesting custom components within reusable components
  aboutToReuse(params: Record<string, Object>): void {
    this.imageStr = params.imageStr as ResourceStr;
    this.text = params.text as ResourceStr;
  }


  build() {
    Row() {
      Image(this.imageStr)
      Text(this.text)
    }
    .alignItems(VerticalAlign.Center)
  }
}
// [End less_embedded_component]


// [Start one_moment_no_modifier]
@Component
export struct LessEmbeddedComponent {
  aboutToAppear(): void {

  }

  build() {
    Column() {
      Text('use nothing')
      List() {
      }
      .width("100%")
      .height("100%")
      .cachedCount(5)
    }
  }
}


@Reusable
@Component
export struct OneMomentNoModifier {
  @State color: string | number | Resource = "";


  aboutToReuse(params: Record<string, Object>): void {
    this.color = params.color as number;
  }


  build() {
    Column() {
      Text('This is the title')
      Text('This is internal text')
        .fontColor(this.color)// Using properties to refresh directly here will cause all properties of Text to be refreshed
        .textAlign(TextAlign.Center)
        .fontStyle(FontStyle.Normal)
        .fontSize(13)
        .lineHeight(30)
        .opacity(0.6)
        .margin({ top: 10 })
        .fontWeight(30)
        .clip(false)
        .backgroundBlurStyle(BlurStyle.NONE)
        .foregroundBlurStyle(BlurStyle.NONE)
        .borderWidth(1)
        .borderColor(Color.Pink)
        .borderStyle(BorderStyle.Solid)
        .alignRules({
          'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
          'left': { 'anchor': 'image', 'align': HorizontalAlign.End }
        })
    }
  }
}
// [End one_moment_no_modifier]

