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

import { CommonConstants } from '../constants/CommonConstants';
import { userAuthUtil, CurrentUser, UserInfoUpdate } from '../utils/UserAuthUtil';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct UserSettingsView {
  @StorageProp('currentUser') currentUser: CurrentUser | null = null;
  @State username: string = '';
  @State email: string = '';
  @State isLoading: boolean = false;
  onClose?: () => void; // 关闭设置页面的回调函数

  aboutToAppear() {
    if (this.currentUser) {
      this.username = this.currentUser.username || '';
      this.email = this.currentUser.email || '';
    }
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          // 用户名输入框
          Column() {
            Text($r('app.string.username_label'))
              .fontSize(15)
              .fontWeight(CommonConstants.FONT_WEIGHT_500)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 10 })

            TextInput({ placeholder: $r('app.string.username_placeholder'), text: this.username })
              .width(CommonConstants.FULL_PERCENT)
              .height(52)
              .backgroundColor(Color.White)
              .borderRadius(10)
              .padding({ left: 16, right: 16 })
              .fontSize(16)
              .onChange((value: string) => {
                this.username = value;
              })
          }
          .width(CommonConstants.NINETY_PERCENT)
          .margin({ bottom: 24 })

          // 邮箱输入框
          Column() {
            Text($r('app.string.email_label'))
              .fontSize(15)
              .fontWeight(CommonConstants.FONT_WEIGHT_500)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 10 })

            TextInput({ placeholder: $r('app.string.email_placeholder'), text: this.email })
              .width(CommonConstants.FULL_PERCENT)
              .height(52)
              .backgroundColor(Color.White)
              .borderRadius(10)
              .padding({ left: 16, right: 16 })
              .fontSize(16)
              .type(InputType.Email)
              .onChange((value: string) => {
                this.email = value;
              })
          }
          .width(CommonConstants.NINETY_PERCENT)
          .margin({ bottom: 24 })


          // 保存设置按钮（始终可点击）
          Button($r('app.string.save_settings'))
            .width(CommonConstants.NINETY_PERCENT)
            .height(52)
            .backgroundColor('#007AFF')
            .fontColor(Color.White)
            .fontSize(17)
            .fontWeight(CommonConstants.FONT_WEIGHT_500)
            .borderRadius(10)
            .shadow({ radius: 8, color: '#30007AFF', offsetX: 0, offsetY: 2 })
            .enabled(true)
            .opacity(this.isLoading ? 0.6 : 1)
            .onClick(async () => {
              if (!this.isLoading) {
                await this.handleSave();
              }
            })
            .margin({ top: 16, bottom: 40 })

          if (this.isLoading) {
            LoadingProgress()
              .color('#007AFF')
              .width(30)
              .height(30)
              .margin({ bottom: 20 })
          }
        }
        .width(CommonConstants.FULL_PERCENT)
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor('#F5F5F5')
  }

  async handleSave() {
    this.isLoading = true;
    const context = this.getUIContext().getHostContext();

    if (!context) {
      this.isLoading = false;
      // 直接关闭设置页面
      if (this.onClose) {
        this.onClose();
      }
      return;
    }

    // 准备更新数据（不包含密码，密码单独处理）
    const updates: UserInfoUpdate = {};

    if (this.username.trim() !== (this.currentUser?.username || '')) {
      updates.username = this.username.trim();
    }

    if (this.email.trim() !== (this.currentUser?.email || '')) {
      updates.email = this.email.trim();
    }


    // 如果有更新项，执行更新
    if (Object.keys(updates).length > 0) {
      await userAuthUtil.updateUserInfo(context, updates);
      
      // 更新本地状态
      const updatedUser = userAuthUtil.getCurrentUser();
      if (updatedUser) {
        this.username = updatedUser.username || '';
        this.email = updatedUser.email || '';
      }
    }
    
    this.isLoading = false;
    
    
    // 直接关闭设置页面，不显示任何提示
    if (this.onClose) {
      this.onClose();
    }
  }
}
