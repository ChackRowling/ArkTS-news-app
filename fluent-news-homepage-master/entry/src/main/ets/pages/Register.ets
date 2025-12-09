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
import { userAuthUtil } from '../utils/UserAuthUtil';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Register {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State email: string = '';
  @State isLoading: boolean = false;
  @State showPassword: boolean = false;
  @State showConfirmPassword: boolean = false;

  aboutToAppear() {
    // 初始化用户认证工具
    const context = this.getUIContext().getHostContext();
    if (context) {
      userAuthUtil.initPreferences(context);
    }
  }

  build() {
    Column() {
      // 标题
      Text($r('app.string.register_title'))
        .fontSize(32)
        .fontWeight(CommonConstants.FONT_WEIGHT_500)
        .fontColor(Color.Black)
        .margin({ top: 60, bottom: 40 })

      // 用户名输入框
      TextInput({ placeholder: $r('app.string.username_placeholder'), text: this.username })
        .width(CommonConstants.NINETY_PERCENT)
        .height(50)
        .margin({ bottom: 16 })
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.username = value;
        })

      // 邮箱输入框
      TextInput({ placeholder: $r('app.string.email_placeholder'), text: this.email })
        .width(CommonConstants.NINETY_PERCENT)
        .height(50)
        .margin({ bottom: 16 })
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .type(InputType.Email)
        .onChange((value: string) => {
          this.email = value;
        })

      // 密码输入框
      Row() {
        TextInput({ 
          placeholder: $r('app.string.password_placeholder'), 
          text: this.password 
        })
          .layoutWeight(1)
          .type(this.showPassword ? InputType.Normal : InputType.Password)
          .backgroundColor(Color.Transparent)
          .onChange((value: string) => {
            this.password = value;
          })

        Text(this.showPassword ? '隐藏' : '显示')
          .fontSize(14)
          .fontColor('#007AFF')
          .onClick(() => {
            this.showPassword = !this.showPassword;
          })
      }
      .width(CommonConstants.NINETY_PERCENT)
      .height(50)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 16 })

      // 确认密码输入框
      Row() {
        TextInput({ 
          placeholder: $r('app.string.confirm_password_placeholder'), 
          text: this.confirmPassword 
        })
          .layoutWeight(1)
          .type(this.showConfirmPassword ? InputType.Normal : InputType.Password)
          .backgroundColor(Color.Transparent)
          .onChange((value: string) => {
            this.confirmPassword = value;
          })

        Text(this.showConfirmPassword ? '隐藏' : '显示')
          .fontSize(14)
          .fontColor('#007AFF')
          .onClick(() => {
            this.showConfirmPassword = !this.showConfirmPassword;
          })
      }
      .width(CommonConstants.NINETY_PERCENT)
      .height(50)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 24 })

      // 注册按钮
      Button($r('app.string.register_button'))
        .width(CommonConstants.NINETY_PERCENT)
        .height(50)
        .backgroundColor('#007AFF')
        .fontColor(Color.White)
        .fontSize(18)
        .fontWeight(CommonConstants.FONT_WEIGHT_500)
        .borderRadius(8)
        .enabled(!this.isLoading && this.isFormValid())
        .opacity(this.isFormValid() && !this.isLoading ? 1 : 0.6)
        .onClick(async () => {
          await this.handleRegister();
        })
        .margin({ bottom: 20 })

      // 登录链接
      Row() {
        Text($r('app.string.have_account'))
          .fontSize(14)
          .fontColor(Color.Gray)

        Text($r('app.string.login_link'))
          .fontSize(14)
          .fontColor('#007AFF')
          .onClick(() => {
            try {
              this.getUIContext().getRouter().back();
            } catch (err) {
              const error = err as BusinessError;
              console.error(`Failed to go back: ${error.message}`);
            }
          })
      }
      .margin({ top: 10 })

      if (this.isLoading) {
        LoadingProgress()
          .color('#007AFF')
          .width(30)
          .height(30)
          .margin({ top: 20 })
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor('#F5F5F5')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
    .padding({ bottom: 20 })
  }

  isFormValid(): boolean {
    return this.username.trim().length > 0 &&
           this.password.trim().length >= 6 &&
           this.confirmPassword.trim().length > 0 &&
           this.password === this.confirmPassword;
  }

  async handleRegister() {
    // 验证必填字段
    if (this.username.trim().length === 0) {
      try {
        await promptAction.showToast({
          message: $r('app.string.username_required'),
          duration: 2000
        });
      } catch (err) {
        const error = err as BusinessError;
        console.error(`showToast error: ${error.message}`);
      }
      return;
    }

    if (this.password.trim().length < 6) {
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

    if (this.password !== this.confirmPassword) {
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
    
    if (context) {
      const success = await userAuthUtil.registerUser(context, {
        username: this.username.trim(),
        password: this.password.trim(),
        email: this.email.trim()
      });
      this.isLoading = false;

      if (success) {
        try {
          await promptAction.showToast({
            message: $r('app.string.register_success'),
            duration: 2000
          });
        } catch (err) {
          const error = err as BusinessError;
          console.error(`showToast error: ${error.message}`);
        }
        // 注册成功后跳转到登录页
        setTimeout(() => {
          try {
            this.getUIContext().getRouter().back();
          } catch (err) {
            const error = err as BusinessError;
            console.error(`Failed to go back: ${error.message}`);
          }
        }, 500);
      } else {
        try {
          await promptAction.showToast({
            message: $r('app.string.register_failed'),
            duration: 2000
          });
        } catch (err) {
          const error = err as BusinessError;
          console.error(`showToast error: ${error.message}`);
        }
      }
    } else {
      this.isLoading = false;
      try {
        await promptAction.showToast({
          message: $r('app.string.register_error'),
          duration: 2000
        });
      } catch (err) {
        const error = err as BusinessError;
        console.error(`showToast error: ${error.message}`);
      }
    }
  }
}
