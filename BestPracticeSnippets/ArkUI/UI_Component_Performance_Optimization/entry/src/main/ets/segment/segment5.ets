/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

// [Start Case3]
import { util } from '@kit.ArkTS';

@Observed
class User {
  id: string;
  name: string;
  avatarImage: ResourceStr;

  constructor(id: string, name: string, avatarImage: ResourceStr) {
    this.id = id;
    this.name = name;
    this.avatarImage = avatarImage;
  }
}

//create data
const DEFAULT_BACKGROUND_COLOR = Color.Grey;
const getUsers = () => {
  return Array.from(Array(1000), (item: User, i: number) => {
    return new User(
      util.generateRandomUUID(),
      i % 2 === 0 ? '张三' : '李四',
      i % 2 === 0 ? '' : $r('app.media.startIcon')
    );
  });
}

@Component
export struct AvatarGrid {
  @State users: User[] = getUsers();

  build() {
    Grid() {
      ForEach(this.users, (u: User) => {
        GridItem() {
          Avatar({ user: u })
        }
      }, (user: User) => user.id)
    }
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
    .columnsGap(4)
    .rowsGap(4)
  }
}

// Avatar component
@Component
struct Avatar {
  @ObjectLink user: User;

  build() {
    Row() {
      if (!this.user.avatarImage) {
        Text(this.user.name.charAt(0))
          .fontSize(28)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
    }
    .backgroundImage(this.user.avatarImage)
    .backgroundImageSize(ImageSize.Cover)
    .backgroundColor(DEFAULT_BACKGROUND_COLOR)
    .justifyContent(FlexAlign.Center)
    .size({ width: 50, height: 50 })
    .borderRadius(25)

    // .padding(2)
    // .margin(2)
    // .opacity(1)
    // .clip(false)
    // .layoutWeight(1)
    // .backgroundBlurStyle(BlurStyle.NONE)
    // .alignItems(VerticalAlign.Center)
    // .borderWidth(1)
    // .borderColor(Color.Pink)
    // .borderStyle(BorderStyle.Solid)
    // .expandSafeArea([SafeAreaType.SYSTEM])
    // .rotate({angle: 5})
    // .responseRegion({x: 0})
    // .mouseResponseRegion({x: 0})
    // .constraintSize({minWidth: 25})
    // .hitTestBehavior(HitTestMode.Default)
    // .backgroundImagePosition(Alignment.Center)
    // .foregroundBlurStyle(BlurStyle.NONE)
  }
}

// [End Case3]