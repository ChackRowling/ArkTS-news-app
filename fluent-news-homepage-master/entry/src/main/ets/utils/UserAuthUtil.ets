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

import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Context } from '@kit.AbilityKit';

export interface UserInfo {
  username: string;
  password: string;
  email?: string;
}

export interface CurrentUser {
  username: string;
  email?: string;
  avatar?: string; // 头像路径
}

export interface UserInfoUpdate {
  username?: string;
  password?: string;
  email?: string;
  avatar?: string;
}

class UserAuthUtil {
  private dataPreferences: preferences.Preferences | null = null;
  private readonly PREF_NAME: string = 'userAuth';
  private readonly KEY_IS_LOGGED_IN: string = 'isLoggedIn';
  private readonly KEY_CURRENT_USER: string = 'currentUser';
  private readonly KEY_USERS: string = 'users';

  /**
   * 初始化 Preferences
   */
  async initPreferences(context: Context): Promise<void> {
    try {
      this.dataPreferences = await preferences.getPreferences(context, this.PREF_NAME);
      hilog.info(0x0000, 'UserAuthUtil', 'Preferences initialized successfully');
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(0x0000, 'UserAuthUtil', `Failed to init preferences, code: ${error.code}, message: ${error.message}`);
    }
  }

  /**
   * 注册新用户
   */
  async registerUser(context: Context, userInfo: UserInfo): Promise<boolean> {
    try {
      if (!this.dataPreferences) {
        await this.initPreferences(context);
      }

      // 获取已注册用户列表
      const usersStr = await this.dataPreferences!.get(this.KEY_USERS, '[]');
      let users: UserInfo[] = JSON.parse(usersStr as string) as UserInfo[];

      // 检查用户名是否已存在
      if (users.find(u => u.username === userInfo.username)) {
        hilog.warn(0x0000, 'UserAuthUtil', 'Username already exists');
        return false;
      }

      // 添加新用户
      users.push(userInfo);
      await this.dataPreferences!.put(this.KEY_USERS, JSON.stringify(users));
      await this.dataPreferences!.flush();
      hilog.info(0x0000, 'UserAuthUtil', 'User registered successfully');
      return true;
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(0x0000, 'UserAuthUtil', `Failed to register user, code: ${error.code}, message: ${error.message}`);
      return false;
    }
  }

  /**
   * 用户登录
   */
  async loginUser(context: Context, username: string, password: string): Promise<boolean> {
    try {
      if (!this.dataPreferences) {
        await this.initPreferences(context);
      }

      // 获取已注册用户列表
      const usersStr = await this.dataPreferences!.get(this.KEY_USERS, '[]');
      const users: UserInfo[] = JSON.parse(usersStr as string) as UserInfo[];

      // 验证用户名和密码
      const user = users.find(u => u.username === username && u.password === password);
      if (user) {
        // 保存登录状态
        await this.dataPreferences!.put(this.KEY_IS_LOGGED_IN, true);
        await this.dataPreferences!.put(this.KEY_CURRENT_USER, JSON.stringify({ username: user.username, email: user.email }));
        await this.dataPreferences!.flush();
        
        // 更新 AppStorage
        const currentUser: CurrentUser = { username: user.username, email: user.email };
        AppStorage.setOrCreate('isLoggedIn', true);
        AppStorage.setOrCreate('currentUser', currentUser);
        
        hilog.info(0x0000, 'UserAuthUtil', 'User logged in successfully');
        return true;
      } else {
        hilog.warn(0x0000, 'UserAuthUtil', 'Invalid username or password');
        return false;
      }
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(0x0000, 'UserAuthUtil', `Failed to login user, code: ${error.code}, message: ${error.message}`);
      return false;
    }
  }

  /**
   * 用户登出
   */
  async logoutUser(): Promise<void> {
    try {
      if (this.dataPreferences) {
        await this.dataPreferences.put(this.KEY_IS_LOGGED_IN, false);
        await this.dataPreferences.delete(this.KEY_CURRENT_USER);
        await this.dataPreferences.flush();
      }
      
      // 更新 AppStorage
      AppStorage.setOrCreate('isLoggedIn', false);
      AppStorage.setOrCreate('currentUser', null);
      
      hilog.info(0x0000, 'UserAuthUtil', 'User logged out successfully');
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(0x0000, 'UserAuthUtil', `Failed to logout user, code: ${error.code}, message: ${error.message}`);
    }
  }

  /**
   * 检查用户是否已登录
   */
  async checkLoginStatus(context: Context): Promise<boolean> {
    try {
      if (!this.dataPreferences) {
        await this.initPreferences(context);
      }

      const isLoggedIn = await this.dataPreferences!.get(this.KEY_IS_LOGGED_IN, false);
      
      if (isLoggedIn) {
        const userStr = await this.dataPreferences!.get(this.KEY_CURRENT_USER, '{}');
        const user: CurrentUser = JSON.parse(userStr as string) as CurrentUser;
        AppStorage.setOrCreate('isLoggedIn', true);
        AppStorage.setOrCreate('currentUser', user);
      } else {
        AppStorage.setOrCreate('isLoggedIn', false);
        AppStorage.setOrCreate('currentUser', null);
      }
      
      return isLoggedIn as boolean;
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(0x0000, 'UserAuthUtil', `Failed to check login status, code: ${error.code}, message: ${error.message}`);
      return false;
    }
  }

  /**
   * 获取当前登录用户
   */
  getCurrentUser(): CurrentUser | null {
    return AppStorage.get('currentUser') as CurrentUser | null;
  }

  /**
   * 检查是否已登录
   */
  isLoggedIn(): boolean {
    return AppStorage.get('isLoggedIn') || false;
  }

  /**
   * 更新用户信息
   */
  async updateUserInfo(context: Context, updates: UserInfoUpdate): Promise<boolean> {
    try {
      if (!this.dataPreferences) {
        await this.initPreferences(context);
      }

      const currentUser = this.getCurrentUser();
      if (!currentUser) {
        hilog.warn(0x0000, 'UserAuthUtil', 'No user logged in');
        return false;
      }

      // 获取已注册用户列表
      const usersStr = await this.dataPreferences!.get(this.KEY_USERS, '[]');
      const users: UserInfo[] = JSON.parse(usersStr as string) as UserInfo[];

      // 找到当前用户
      const userIndex = users.findIndex(u => u.username === currentUser.username);
      if (userIndex === -1) {
        hilog.warn(0x0000, 'UserAuthUtil', 'User not found in users list');
        return false;
      }

      // 如果要更新用户名，检查新用户名是否已存在
      if (updates.username && updates.username !== currentUser.username) {
        if (users.find(u => u.username === updates.username && u.username !== currentUser.username)) {
          hilog.warn(0x0000, 'UserAuthUtil', 'New username already exists');
          return false;
        }
        users[userIndex].username = updates.username;
      }

      // 更新密码
      if (updates.password) {
        users[userIndex].password = updates.password;
      }

      // 更新邮箱
      if (updates.email !== undefined) {
        users[userIndex].email = updates.email;
      }

      // 保存更新后的用户列表
      await this.dataPreferences!.put(this.KEY_USERS, JSON.stringify(users));
      await this.dataPreferences!.flush();

      // 更新当前登录用户信息
      const updatedUser: CurrentUser = {
        username: updates.username || currentUser.username,
        email: updates.email !== undefined ? updates.email : currentUser.email,
        avatar: updates.avatar !== undefined ? updates.avatar : currentUser.avatar
      };

      await this.dataPreferences!.put(this.KEY_CURRENT_USER, JSON.stringify(updatedUser));
      await this.dataPreferences!.flush();

      // 更新 AppStorage
      AppStorage.setOrCreate('currentUser', updatedUser);

      hilog.info(0x0000, 'UserAuthUtil', 'User info updated successfully');
      return true;
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(0x0000, 'UserAuthUtil', `Failed to update user info, code: ${error.code}, message: ${error.message}`);
      return false;
    }
  }
}

export const userAuthUtil = new UserAuthUtil();
