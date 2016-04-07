package cn.sharesdk.ane.platform
{
	public class DevInfo 
	{	
		protected var platformConf:Object = new Object();			
		public function setId (id:String):void 
		{
			platformConf["Id"] = id;
		}			
		public function setSortId (sortId:String):void 
		{
			platformConf["SortId"] =sortId;
		}
		public function setEnable (enable:String):void 
		{
			platformConf["Enable"] = enable;
		}
		public function getPlatformConf():Object
		{
			return platformConf;
		}
	}
}