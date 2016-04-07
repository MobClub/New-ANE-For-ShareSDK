package cn.sharesdk.ane.platform
{
	public class WechatFavorites extends DevInfo
	{					
		public function setAppId (appId:String):void 
		{
			platformConf["AppId"] = appId;
		}
		public function setAppSecret (appSecret:String):void 
		{
			platformConf["AppSecret"] = appSecret;
		}
	}
}