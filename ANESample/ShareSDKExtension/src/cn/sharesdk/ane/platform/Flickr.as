package cn.sharesdk.ane.platform
{
	public class Flickr extends DevInfo
	{					
		public function setApiKey (apiKey:String):void 
		{
			platformConf["ApiKey"] = apiKey;
		}
		public function setApiSecret (apiSecret:String):void 
		{
			platformConf["ApiSecret"] = apiSecret;
		}
		public function setRedirectUri (redirectUri:String):void 
		{
			platformConf["RedirectUri"] = redirectUri;
		}		
	}
}