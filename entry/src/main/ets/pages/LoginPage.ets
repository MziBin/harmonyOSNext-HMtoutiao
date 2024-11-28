import { promptAction, router } from '@kit.ArkUI'
import { http } from '@kit.NetworkKit'
import { ResultData, TokenData } from './Model/LoginResponseDataToken'
import { PreferencesClass } from './Model/PreferencesClass'

@Entry
@Component
struct LoginPage {
  @State
  mobilePhone: string = "17628694075"
  @State
  mobileCheck: string = ""
  @State
  verificationCode: string = "发送验证码"
  @State
  delayCode: number = 60

  //登录请求
  async mobileLogin() {
    await this.sendLogin()
    // promptAction.showDialog({
    //   message: "登录成功"
    // })
  }

  //获取验证码请求
  async sendHttpVerificationCode() {
    let httpRequest = http.createHttp()
    //发出请求，拼接手机号,发生成功在执行下面的
    try {
      let req = await httpRequest.request(`https://toutiao.itheima.net/v1_0/sms/codes/${this.mobilePhone}`)
      promptAction.showToast({
        message: "验证码发生成功"
      })
    } catch (erro) {
      promptAction.showToast({
        message: "验证码发生失败"
      })
    } finally {
      //关闭资源
      httpRequest.destroy()
    }
  }

  //登录验证
  async sendLogin() {
    const req = http.createHttp()
    try {
      const result = await req.request("https://toutiao.itheima.net/v1_0/authorizations", {
        //请求方法
        method: http.RequestMethod.POST,
        //请求头
        header: {
          "Content-Type": "application/json" // 约束传入的body参数为JSON对象类型
        },
        //发送的数据
        extraData: {
          mobile: this.mobilePhone,
          code: this.mobileCheck
        }
      })

      //JSON字符串转换成对象
      const res = JSON.parse(result.result as string) as ResultData<TokenData>
      //写入磁盘   表示设置首选项  为了写入磁盘 为了进入判断
      new PreferencesClass().setToken(res.data!.token) // res.data!,感叹后后置是ts的语法，表示不为null和unsigned才调用后面的方法
      //写入内存
      AppStorage.setOrCreate<string>("token", res.data!.token) //
      // res.data?.refresh_token
      // AlertDialog.show({ message: result.result as string })
      router.replaceUrl({
        url: 'pages/HMtoutiaoMainPage'
      })

      promptAction.showDialog({
        message: "登录成功"
      })
    } catch (erro) {
      promptAction.showDialog({
        message: erro + "验证码不对"
      })
    } finally {
      //关闭资源
      req.destroy()
    }
  }

  //倒计时,注意调用时加判断，否则会出现每点击进来一次，就调用一次方法。
  getVerificationCode() {
    let setID = setInterval(() => {
      this.delayCode--
      if (this.delayCode === 0) {
        this.verificationCode = "发送验证码"
        this.delayCode = 60
        clearInterval(setID)
      } else {
        this.verificationCode = this.delayCode + "秒后获取"
      }
    }, 1000)

    //
    // promptAction.showDialog({
    //   message: "获取验证码"
    // })
  }

  build() {
    Column({ space: 30 }) {
      Image($r("sys.media.ohos_ic_public_arrow_left"))
        .width(30)
        .height(30)

      Text("短信登录")
        .fontSize(30)
      Column({ space: 20 }) {
        TextInput({ placeholder: "17628694075", text: $$this.mobilePhone })
          .backgroundColor(Color.White)
          .borderRadius(0)
          .border({
            width: {
              bottom: 1
            }
          })
        Row() {
          TextInput({ placeholder: "请输入验证码", text: $$this.mobileCheck })
            .backgroundColor(Color.White)
            .layoutWeight(1)
          //获取验证码
          Text(this.verificationCode)
            .onClick(async () => {
              if (this.delayCode === 60) {
                //正则表达式
                if (new RegExp('^1[3456789]\\d{9}$').test(this.mobilePhone)) {
                  //这里sendHttpVerificationCode是异步函数，但是要等验证码发生成功了才能传值，所以这里加个await
                  await this.sendHttpVerificationCode()
                  this.getVerificationCode()
                }
              }
            })
        }
        .border({
          width: {
            bottom: 1
          }
        })
        .width("100%")
      }

      Button("登录")
        .width("100%")
        .height(50)
        .backgroundColor("#f96535")
        .type(ButtonType.Normal)
        .borderRadius(5)
        .enabled(!!(this.mobilePhone && this.mobileCheck))
        .onClick(async () => {
          await this.mobileLogin()
        })
    }
    .alignItems(HorizontalAlign.Start)
    .height('100%')
    .width('100%')
    .padding(20)
  }
}

