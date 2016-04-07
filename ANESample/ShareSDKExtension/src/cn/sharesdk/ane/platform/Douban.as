package cn.sharesdk.ane.platform
{
	public class Douban extends DevInfo
	{					
		public function setApiKey (apiKey:String):void 
		{
			platformConf["ApiKey"] = apiKey;
		}
		public function setSecret (secret:String):void 
		{
			platformConf["Secret"] = secret;
		}
		public function setRedirectUri (redirectUri:String):void 
		{
			platformConf["RedirectUri"] = redirectUri;
		}	
	}
}