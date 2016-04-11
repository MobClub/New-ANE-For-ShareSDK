package cn.sharesdk.ane.platform
{
	import flash.system.Capabilities;
	public class Wechat extends DevInfo
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
		public function setAppSecret (appSecret:String):void 
		{
			
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				platformConf["AppSecret"] = appSecret;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				platformConf["app_secret"] = appSecret;
			}
		}
		//Android Only
		public function setBypassApproval (bypassApproval:Boolean):void 
		{
			platformConf["BypassApproval"] = bypassApproval;
		}
		
	}
}