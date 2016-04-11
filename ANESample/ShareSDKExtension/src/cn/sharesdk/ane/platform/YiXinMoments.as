package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;

	public class YiXinMoments extends DevInfo
	{					
		public function setAppId (appId:String):void 
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["AppId"] = appId;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["app_id"] = appId;
			}
		}		
		//Android Only
		public function setBypassApproval (bypassApproval:Boolean):void 
		{
			platformConf["BypassApproval"] = bypassApproval;
		}
		//iOS Only
		public function setAppSecret (appSecret:String):void
		{
			platformConf["app_secret"] = appSecret;
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