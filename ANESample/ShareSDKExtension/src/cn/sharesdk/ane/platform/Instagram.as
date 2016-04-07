package cn.sharesdk.ane.platform
{
	public class Instagram extends DevInfo
	{					
		public function setClientId (clientId:String):void 
		{
			platformConf["ClientId"] = clientId;
		}
		public function setClientSecret (clientSecret:String):void 
		{
			platformConf["ClientSecret"] = clientSecret;
		}
		public function setRedirectUri (redirectUri:String):void 
		{
			platformConf["RedirectUri"] = redirectUri;
		}	
	}
}