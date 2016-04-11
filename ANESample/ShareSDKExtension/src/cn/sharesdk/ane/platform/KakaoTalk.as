package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class KakaoTalk extends DevInfo
	{					
		public function setAppKey (appKey:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["AppKey"] = appKey;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["app_key"] = appKey;
			}
		}
		//iOS Only
		public function setRestApiKey (restApiKey:String):void
		{
			platformConf["rest_api_key"] = restApiKey;
		}
		//iOS Only
		public function setRedirectUri (redirectUri:String):void
		{
			platformConf["redirect_uri"] = redirectUri;
		}
		//iOS Only
		public function setAuthType (authType:String):void
		{
			platformConf["auth_type"] = authType;
		}
	}
}