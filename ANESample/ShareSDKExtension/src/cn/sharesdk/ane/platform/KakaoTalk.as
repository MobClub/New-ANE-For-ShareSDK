package cn.sharesdk.ane.platform
{
	public class KakaoTalk extends DevInfo
	{					
		public function setAppKey (appKey:String):void 
		{
			platformConf["AppKey"] = appKey;
		}
	}
}