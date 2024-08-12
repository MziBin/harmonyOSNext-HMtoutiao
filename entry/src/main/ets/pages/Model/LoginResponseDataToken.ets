export class ResultData<D> {
  message: string = ""
  //或者null，推荐问号
  data: D | null = null
  //可以是可选参数，这样就不用初始化值
  // data?: D
}

export class TokenData {
  token: string = ""
  refresh_token: string = ""
}