package cn.sharesdk.ane.platform
{
	public class QZone extends DevInfo
	{					
		public function setAppId (appId:String):void 
		{
			platformConf["AppId"] = appId;
		}
		public function setAppKey (appKey:String):void 
		{
			platformConf["AppKey"] = appKey;
		}
		public function setShareByAppClient (shareByAppClient:Boolean):void 
		{
			platformConf["ShareByAppClient"] = shareByAppClient;
		}
	}
}