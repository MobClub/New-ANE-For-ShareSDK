package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class QQ extends DevInfo
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
		public function setShareByAppClient (shareByAppClient:Boolean):void 
		{
			platformConf["ShareByAppClient"] = shareByAppClient;
		}
		//iOS Only
		public function setAuthType (authType:String):void
		{
			platformConf["auth_type"] = authType;
		}
	}
}