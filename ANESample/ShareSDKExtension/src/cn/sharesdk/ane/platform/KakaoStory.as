package cn.sharesdk.ane.platform
{
	public class KakaoStory extends DevInfo
	{					
		public function setAppKey (appKey:String):void 
		{
			platformConf["AppKey"] = appKey;
		}
	}
}