package cn.sharesdk.ane.platform
{
	public class QQ extends DevInfo
	{					
		public function setAppKey (appKey:String):void 
		{
			platformConf["AppKey"] = appKey;
		}
		public function setAppId (appId:String):void 
		{
			platformConf["AppId"] = appId;
		}
		public function setShareByAppClient (shareByAppClient:Boolean):void 
		{
			platformConf["ShareByAppClient"] = shareByAppClient;
		}
	}
}