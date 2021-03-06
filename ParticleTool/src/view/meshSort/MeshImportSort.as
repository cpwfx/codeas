package view.meshSort
{
	import flash.display3D.Context3D;
	
	import _Pan3D.base.MeshData;
	import _Pan3D.base.ObjectBone;
	import _Pan3D.base.ObjectTri;
	import _Pan3D.base.ObjectUv;
	import _Pan3D.base.ObjectWeight;
	import _Pan3D.role.MeshDataManager;
	
	import _me.Scene_data;

	/**
	 * mesh导入时的预处理类
	 * </br>处理骨骼排序问题 
	 * </br>把所有的骨骼按照先bip后weapon最后bone的序列排序 
	 * @author liuyanfei QQ:421537900
	 * 
	 */	
	public class MeshImportSort
	{
		private var _context:Context3D;
		public function MeshImportSort()
		{
			_context = Scene_data.context3D;
		}
		/**
		 * 处理mesh的对应的骨骼顺序问题
		 * @param meshData
		 * 
		 */
		public function processMesh(meshData:MeshData):void{
			var weightAry:Vector.<ObjectWeight> = new Vector.<ObjectWeight>;
			for(var i:int;i<meshData.weightItem.length;i++){
				weightAry.push(meshData.weightItem[i].clone());
			}
			
			var mapkeyAry:Array = getMapValue(meshData.boneItem);
			
			for(i=0;i<weightAry.length;i++){
				//trace(weightAry[i].boneId,mapkeyAry[weightAry[i].boneId])
				weightAry[i].boneId = mapkeyAry[weightAry[i].boneId]
			}
//			meshData.souceBoneItem
			meshData.weightItem = weightAry;
			
			processForAgal(meshData);

		}
		
		/**
		 * 返回映射关系列表 
		 * @param targetAry
		 * @return 
		 * 
		 */		
		private function getMapValue(targetAry:Vector.<ObjectBone>):Array{
			var newTargetAry:Vector.<ObjectBone> = new Vector.<ObjectBone>;
			//添加bip骨骼到新数组
			for(var i:int;i<targetAry.length;i++){
				if(targetAry[i].name.indexOf("Bip") != -1){
					newTargetAry.push(targetAry[i]);
				}
			}
			//添加weapon骨骼到新数组
			for(i = 0;i<targetAry.length;i++){
				if(targetAry[i].name.indexOf("weapon") != -1){
					newTargetAry.push(targetAry[i]);
				}
			}
			//添加剩余的骨骼到新数组
			for(i = 0;i<targetAry.length;i++){
				if(newTargetAry.indexOf(targetAry[i]) == -1){
					newTargetAry.push(targetAry[i]);
				}
			}
			
			var mapkeyAry:Array = new Array;//新旧ID映射关系
			
			for(i = 0;i<targetAry.length;i++){
				var index:int = newTargetAry.indexOf(targetAry[i]);
				mapkeyAry.push(index);
			}
			return mapkeyAry;
		}
		/**
		 * 重新上传到显卡 
		 * @param meshData
		 * 
		 */		
		private function processForAgal(meshData:MeshData):void{
			
			var beginKey:int = MeshDataManager.getInstance().beginKey;
			
			var uvItem:Vector.<ObjectUv> = meshData.uvItem;
			var weightItem:Vector.<ObjectWeight> = meshData.weightItem;
			var triItem:Vector.<ObjectTri> = meshData.triItem;
			
			var uvArray:Array=new Array();
			var ary:Array = [[],[],[],[]];
			var boneWeightAry:Array = new Array;
			var bonetIDAry:Array = new Array;
			var indexAry:Array = new Array;
			
			var skipNum:int;
			var beginIndex:int;
			var allNum:int;
			
			var boneUseAry:Array = new Array;
			
			for(var i:int = 0;i<uvItem.length;i++){
				beginIndex = uvItem[i].a;
				allNum = uvItem[i].b;
				for(skipNum = 0;skipNum<4;skipNum++){
					if(skipNum<allNum){
						boneUseAry.push((weightItem[beginIndex+skipNum].boneId));
					}else{
						boneUseAry.push(0);
					}
				}
			}
			
			boneUseAry = getboneNum(boneUseAry);
			
			for(i = 0;i<uvItem.length;i++){
				beginIndex = uvItem[i].a;
				allNum = uvItem[i].b;
				for(skipNum = 0;skipNum<4;skipNum++){
					if(skipNum<allNum){
						ary[skipNum].push(weightItem[beginIndex+skipNum].x,weightItem[beginIndex+skipNum].y,weightItem[beginIndex+skipNum].z);
						bonetIDAry.push(beginKey + boneUseAry.indexOf((weightItem[beginIndex+skipNum].boneId))*4);
						boneWeightAry.push(weightItem[beginIndex+skipNum].w);
					}else{
						ary[skipNum].push(0,0,0);
						bonetIDAry.push(beginKey + boneUseAry.indexOf(0));
						boneWeightAry.push(0);
					}
				}
				uvArray.push(uvItem[i].x);
				uvArray.push(uvItem[i].y);
			}
			
			meshData.boneNewIDAry = boneUseAry;
			
			for(i=0;i<triItem.length;i++){
				indexAry.push(triItem[i].t0,triItem[i].t1,triItem[i].t2);
			}
			meshData.faceNum = indexAry.length/3;
			uplodToGpu(meshData,uvArray,ary,
				boneWeightAry,bonetIDAry,indexAry);
			//getboneNum(bonetIDAry);
		}
		
		
		private function getboneNum(ary:Array):Array{
			var numAry:Array = new Array;
			for(var i:int;i<ary.length;i++){
				if(numAry.indexOf(ary[i]) == -1){
					numAry.push(ary[i]);
				}
			}
			//trace(numAry.length);
			return numAry;
		}
		
		private function uplodToGpu(meshData:MeshData,uvArray:Array,ary:Array,
									boneWeightAry:Array,bonetIDAry:Array,indexAry:Array):void{
			
			
			MeshDataManager.getInstance().uplodToGpu(meshData,uvArray,ary,boneWeightAry,bonetIDAry,indexAry)
				
			
		}
		
	}
}