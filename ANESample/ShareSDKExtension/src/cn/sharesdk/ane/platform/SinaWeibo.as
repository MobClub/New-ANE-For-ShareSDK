package cn.sharesdk.ane.platform
{
	public class SinaWeibo extends DevInfo
	{					
		public function setAppKey (appKey:String):void 
		{
			platformConf["AppKey"] = appKey;
		}
		public function setAppSecret (appSecret:String):void 
		{
			platformConf["AppSecret"] = appSecret;
		}
		public function setRedirectUrl (redirectUrl:String):void 
		{
			platformConf["RedirectUrl"] = redirectUrl;
		}			
		public function setShareByAppClient (shareByAppClient:Boolean):void 
		{
			platformConf["ShareByAppClient"] = shareByAppClient;
		}
	}
}