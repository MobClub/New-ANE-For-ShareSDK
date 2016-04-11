package cn.sharesdk.ane.platform
{
	public class GooglePlus extends DevInfo
	{
		//iOS Only
		public function setClientId (clientId:String):void
		{
			platformConf["client_id"] = setClientId;
		}
		//iOS Only
		public function setClientSecret (clientSecret:String):void
		{
			platformConf["client_secret"] = clientSecret;
		}
		//iOS Only
		public function setRedirectUri (redirectUri:String):void
		{
			platformConf["redirect_uri"] = redirectUri;
		}
	
	}
}