package cn.sharesdk.ane.platform
{
	public class Pinterest extends DevInfo
	{					
		public function setClientId (clientId:String):void 
		{
			platformConf["ClientId"] = clientId;
		}
	}
}