package cn.sharesdk.ane.platform
{
	public class VKontakte extends DevInfo
	{					
		public function setApplicationId (applicationId:String):void 
		{
			platformConf["ApplicationId"] = applicationId;
		}
	}
}