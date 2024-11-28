
import { Channels, HomeTabBarModel } from './Model/HomeTabBarModel';
import { http } from '@kit.NetworkKit';
import { promptAction, router } from '@kit.ArkUI';
import { it } from '@ohos/hypium';
import { JSON } from '@kit.ArkTS';

@Entry
@Component
struct HMtoutiaoMainPage {
  @State message: string = 'Hello World';
  tbBarItem: ITbBarModel = new ITbBarModel({} as ITbBar)
  tbBarList: ITbBarModel[] = [
    new ITbBarModel({ image: $r("app.media.home_07"), text: "首页" }),
    new ITbBarModel({ image: $r("app.media.chat_07"), text: "问答" }),
    new ITbBarModel({ image: $r("app.media.vlog_07"), text: "视频" }),
    new ITbBarModel({ image: $r("app.media.my_07"), text: "我的" })
  ]

  str: String = ""

  aboutToAppear(): void {
    this.getHomeTabBar()
    promptAction.showToast({
      message: JSON.stringify(this.homeTabBarList)
    })
    this.str = JSON.stringify(this.homeTabBarList)
    1
  }

  async getHomeTabBar() {
    //获取http对象
    const req = http.createHttp()
    try {
      //todo 网络请求待完善
      const result = await req.request("https://toutiao.itheima.net/v1_0/user/channels",{
        //请求方法
        method: http.RequestMethod.GET,
      })
      //JSON字符串转换成对象
      const res: HomeTabBarModel = await JSON.parse(result.result as string) as HomeTabBarModel
      this.homeTabBarList = res.data

    } catch (erro) {
      promptAction.showDialog({
        message: erro + "网络错误..."
      })
    } finally {
      //关闭资源
      req.destroy()
    }
  }

  @State
  homeTabBarList: Channels[] = []

  @State
  HMIndex: number = 0

  @State
  homeIndex: number = 0

  @Builder
  tbBarS(item: ITbBarModel) {
    Column({ space: 5 }) {
      Image(item.image)
        .fillColor(this.tbBarList[this.HMIndex]!.text === item.text ? Color.Orange : Color.Black)//！不为空的情况下才能调用
        .width(20)
      Text(item.text)
        .fontColor(this.tbBarList[this.HMIndex]!.text === item.text ? Color.Orange : Color.Black)
        .fontSize(13)
    }
  }

  @Builder
  homeItemTabBar(item: Channels) {
    Row() {
      Text(item.name)
        .fontColor(this.homeTabBarList[this.homeIndex]!.name === item.name ? Color.Gray : Color.Black)
    }
    .border({
      width: {
        bottom: 2
      },
      color: Color.Orange
    })
  }

  @Builder
  homeTabBarS() {
    Tabs() {
      ForEach([1,2],(item: Channels)=>{
        TabContent() {

        }
        .tabBar(this.homeItemTabBar(item))
      })
    }
  }

  build() {
    //值的双向绑定
    Tabs({ index: $$this.HMIndex, barPosition: BarPosition.End }) {
      ForEach(this.tbBarList, (item: ITbBarModel) => {
        TabContent() {
          if (item.text === "首页") {
            this.homeTabBarS()
          }
        }.tabBar(this.tbBarS(item))

      })
    }
    .height('100%')
    .width('100%')
  }
}

interface ITbBar {
  image: ResourceStr
  text: string
}

class ITbBarModel {
  image: ResourceStr = ""
  text: string = ""

  constructor(itemModel: ITbBar) {
    this.image = itemModel.image
    this.text = itemModel.text
  }
}