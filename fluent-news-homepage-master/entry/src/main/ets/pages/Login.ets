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
struct Login {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State showPassword: boolean = false;

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
      Text($r('app.string.login_title'))
        .fontSize(32)
        .fontWeight(CommonConstants.FONT_WEIGHT_500)
        .fontColor(Color.Black)
        .margin({ top: 80, bottom: 60 })

      // 用户名输入框
      TextInput({ placeholder: $r('app.string.username_placeholder'), text: this.username })
        .width(CommonConstants.NINETY_PERCENT)
        .height(50)
        .margin({ bottom: 20 })
        .backgroundColor(Color.White)
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.username = value;
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
      .margin({ bottom: 30 })

      // 登录按钮
      Button($r('app.string.login_button'))
        .width(CommonConstants.NINETY_PERCENT)
        .height(50)
        .backgroundColor('#007AFF')
        .fontColor(Color.White)
        .fontSize(18)
        .fontWeight(CommonConstants.FONT_WEIGHT_500)
        .borderRadius(8)
        .enabled(!this.isLoading && this.username.length > 0 && this.password.length > 0)
        .opacity((!this.isLoading && this.username.length > 0 && this.password.length > 0) ? 1 : 0.6)
        .onClick(async () => {
          await this.handleLogin();
        })
        .margin({ bottom: 20 })

      // 注册链接
      Row() {
        Text($r('app.string.no_account'))
          .fontSize(14)
          .fontColor(Color.Gray)

        Text($r('app.string.register_link'))
          .fontSize(14)
          .fontColor('#007AFF')
          .onClick(() => {
            try {
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/Register'
              });
            } catch (err) {
              const error = err as BusinessError;
              console.error(`Failed to navigate to register page: ${error.message}`);
            }
          })
      }
      .margin({ top: 20 })

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
  }

  async handleLogin() {
    if (this.username.trim().length === 0 || this.password.trim().length === 0) {
      try {
        await promptAction.showToast({
          message: $r('app.string.empty_fields'),
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
      const success = await userAuthUtil.loginUser(context, this.username.trim(), this.password.trim());
      this.isLoading = false;

      if (success) {
        try {
          await promptAction.showToast({
            message: $r('app.string.login_success'),
            duration: 2000
          });
        } catch (err) {
          const error = err as BusinessError;
          console.error(`showToast error: ${error.message}`);
        }
        // 登录成功后返回首页
        setTimeout(() => {
          try {
            this.getUIContext().getRouter().replaceUrl({
              url: 'pages/Index'
            });
          } catch (err) {
            const error = err as BusinessError;
            console.error(`Failed to navigate to index page: ${error.message}`);
          }
        }, 500);
      } else {
        try {
          await promptAction.showToast({
            message: $r('app.string.login_failed'),
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
          message: $r('app.string.login_error'),
          duration: 2000
        });
      } catch (err) {
        const error = err as BusinessError;
        console.error(`showToast error: ${error.message}`);
      }
    }
  }
}
