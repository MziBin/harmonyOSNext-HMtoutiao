import { preferences } from '@kit.ArkData'

export class PreferencesClass {
  context?: Context

  //获取仓库
  getStore() {
    //sync是同步的，非sync是异步的
    //传入上下文
    //页面(getContext()) 和UIAbility(this.context)

    return preferences.getPreferencesSync(this.context || getContext(), {
      name: 'auth_token'
    })
  }

  //写入token
  async setToken(token: string) {
    //获取仓库
    const store = this.getStore()
    //加入仓库
    store.putSync("auth", token)
    //必须flush一下，才能真正的写入磁盘
    store.flush()
  }

  //获取token
  getToken() {
    const store = this.getStore()
    return store.getSync("auth", "") as string
  }
}