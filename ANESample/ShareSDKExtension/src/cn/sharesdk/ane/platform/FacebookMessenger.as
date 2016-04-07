package cn.sharesdk.ane.platform
{
	public class FacebookMessenger extends DevInfo
	{					
		public function setAppId (appId:String):void 
		{
			platformConf["AppId"] = appId;
		}	
	}
}