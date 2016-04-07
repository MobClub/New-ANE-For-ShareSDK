package cn.sharesdk.ane.platform
{
	public class FourSquare extends DevInfo
	{					
		public function setClientID (clientID:String):void 
		{
			platformConf["ClientID"] = clientID;
		}
		public function setClientSecret (clientSecret:String):void 
		{
			platformConf["ClientSecret"] = clientSecret;
		}
		public function setRedirectUrl (redirectUrl:String):void 
		{
			platformConf["RedirectUrl"] = redirectUrl;
		}	
	}
}