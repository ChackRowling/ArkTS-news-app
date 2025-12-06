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
import { userAuthUtil, UserInfoUpdate } from '../utils/UserAuthUtil';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct ChangePasswordView {
  @State currentPassword: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;
  onClose?: () => void; // 关闭修改密码页面的回调函数

  build() {
    Column() {
      Scroll() {
        Column() {
          // 当前密码输入框
          Column() {
            Text($r('app.string.current_password'))
              .fontSize(15)
              .fontWeight(CommonConstants.FONT_WEIGHT_500)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 10 })

            TextInput({ placeholder: $r('app.string.current_password_placeholder'), text: this.currentPassword })
              .width(CommonConstants.FULL_PERCENT)
              .height(52)
              .backgroundColor(Color.White)
              .borderRadius(10)
              .padding({ left: 16, right: 16 })
              .fontSize(16)
              .type(InputType.Password)
              .onChange((value: string) => {
                this.currentPassword = value;
              })
          }
          .width(CommonConstants.FULL_PERCENT)
          .margin({ top: 30, bottom: 20 })

          // 新密码输入框
          Column() {
            Text($r('app.string.new_password'))
              .fontSize(15)
              .fontWeight(CommonConstants.FONT_WEIGHT_500)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 10 })

            TextInput({ placeholder: $r('app.string.new_password_placeholder'), text: this.newPassword })
              .width(CommonConstants.FULL_PERCENT)
              .height(52)
              .backgroundColor(Color.White)
              .borderRadius(10)
              .padding({ left: 16, right: 16 })
              .fontSize(16)
              .type(InputType.Password)
              .onChange((value: string) => {
                this.newPassword = value;
              })
          }
          .width(CommonConstants.FULL_PERCENT)
          .margin({ bottom: 20 })

          // 确认新密码输入框
          Column() {
            Text($r('app.string.confirm_new_password'))
              .fontSize(15)
              .fontWeight(CommonConstants.FONT_WEIGHT_500)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 10 })

            TextInput({ placeholder: $r('app.string.confirm_password_placeholder'), text: this.confirmPassword })
              .width(CommonConstants.FULL_PERCENT)
              .height(52)
              .backgroundColor(Color.White)
              .borderRadius(10)
              .padding({ left: 16, right: 16 })
              .fontSize(16)
              .type(InputType.Password)
              .onChange((value: string) => {
                this.confirmPassword = value;
              })
          }
          .width(CommonConstants.FULL_PERCENT)
          .margin({ bottom: 30 })

          // 取消和确认按钮
          Row() {
            Button($r('app.string.cancel'))
              .layoutWeight(1)
              .height(52)
              .backgroundColor('#F5F5F5')
              .fontColor('#666666')
              .fontSize(17)
              .fontWeight(CommonConstants.FONT_WEIGHT_500)
              .borderRadius(10)
              .onClick(() => {
                this.currentPassword = '';
                this.newPassword = '';
                this.confirmPassword = '';
                if (this.onClose) {
                  this.onClose();
                }
              })

            Blank().width(12)

            Button($r('app.string.confirm_change_password'))
              .layoutWeight(1)
              .height(52)
              .backgroundColor('#007AFF')
              .fontColor(Color.White)
              .fontSize(17)
              .fontWeight(CommonConstants.FONT_WEIGHT_500)
              .borderRadius(10)
              .shadow({ radius: 8, color: '#30007AFF', offsetX: 0, offsetY: 2 })
              .enabled(!this.isLoading)
              .opacity(this.isLoading ? 0.6 : 1)
              .onClick(async () => {
                if (!this.isLoading) {
                  await this.handlePasswordChange();
                }
              })
          }
          .width(CommonConstants.FULL_PERCENT)
          .margin({ bottom: 40 })

          if (this.isLoading) {
            LoadingProgress()
              .color('#007AFF')
              .width(30)
              .height(30)
              .margin({ bottom: 20 })
          }
        }
        .width(CommonConstants.NINETY_PERCENT)
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor('#F5F5F5')
  }

  async handlePasswordChange() {
    // 验证密码修改
    if (this.currentPassword.trim().length === 0) {
      try {
        await promptAction.showToast({
          message: $r('app.string.current_password_required'),
          duration: 2000
        });
      } catch (err) {
        const error = err as BusinessError;
        console.error(`showToast error: ${error.message}`);
      }
      return;
    }

    if (this.newPassword.trim().length < 6) {
      try {
        await promptAction.showToast({
          message: $r('app.string.password_length_error'),
          duration: 2000
        });
      } catch (err) {
        const error = err as BusinessError;
        console.error(`showToast error: ${error.message}`);
      }
      return;
    }

    if (this.newPassword !== this.confirmPassword) {
      try {
        await promptAction.showToast({
          message: $r('app.string.password_mismatch'),
          duration: 2000
        });
      } catch (err) {
        const error = err as BusinessError;
        console.error(`showToast error: ${error.message}`);
      }
      return;
    }

    this.isLoading = true;
    const context = this.getUIContext().getHostContext();

    if (!context) {
      this.isLoading = false;
      try {
        await promptAction.showToast({
          message: $r('app.string.save_error'),
          duration: 2000
        });
      } catch (err) {
        const error = err as BusinessError;
        console.error(`showToast error: ${error.message}`);
      }
      return;
    }

    // 准备更新密码
    const updates: UserInfoUpdate = {
      password: this.newPassword.trim()
    };

    // 执行更新
    const success = await userAuthUtil.updateUserInfo(context, updates);
    this.isLoading = false;

    if (success) {
      try {
        await promptAction.showToast({
          message: $r('app.string.password_change_success'),
          duration: 1500
        });
      } catch (err) {
        const error = err as BusinessError;
        console.error(`showToast error: ${error.message}`);
      }
      // 清空密码字段并关闭页面
      this.currentPassword = '';
      this.newPassword = '';
      this.confirmPassword = '';
      setTimeout(() => {
        if (this.onClose) {
          this.onClose();
        }
      }, 500);
    } else {
      try {
        await promptAction.showToast({
          message: $r('app.string.password_change_failed'),
          duration: 2000
        });
      } catch (err) {
        const error = err as BusinessError;
        console.error(`showToast error: ${error.message}`);
      }
    }
  }
}
