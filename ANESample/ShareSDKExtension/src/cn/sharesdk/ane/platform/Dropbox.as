package cn.sharesdk.ane.platform
{
	public class Dropbox extends DevInfo
	{					
		public function setAppKey (appKey:String):void 
		{
			platformConf["AppKey"] = appKey;
		}
		public function setAppSecret (appSecret:String):void 
		{
			platformConf["AppSecret"] = appSecret;
		}
		public function setRedirectUri (redirectUri:String):void 
		{
			platformConf["RedirectUri"] = redirectUri;
		}	
	}
}