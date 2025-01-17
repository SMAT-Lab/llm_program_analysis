package onnxrt
from std import collection.*
public interface IonnxruntimeApi{
    func initializeSession( onnxPath:String):Unit
    func runByInputNodeData(inputData: CPointer<InputNodeData>,out_put_name:String):OutData
    func  run():Unit
    func destroy():Unit
}
public class Session  <: IonnxruntimeApi {
   public func initializeSession( onnxPath:String){
    unsafe {
        var  model_path = LibC.mallocCString(onnxPath)
        c_initializeSession(model_path)
        LibC.free(model_path)
    }
   }
    public func run( ){
        unsafe {
            c_run()
        }
   }
// data = [1,2,3]
    public func freeInput(data: CPointer<InputNodeData>,index: Int64){
        unsafe {
            for (i in 0..index) {
                var inputData: InputNodeData = data.read(i)
                LibC.free(inputData.name)
                LibC.free<Int64>(inputData.data)
                LibC.free<Int64>(inputData.dims)
            }
            LibC.free<InputNodeData>(data)
        }
   }
      public func freeOntput(data: CPointer<C_OutNodeData>){
            print("释放")
        unsafe {
                var out: C_OutNodeData = data.read(0)
                //内存释放存在问题-------------
                // LibC.free<Float32>(out.data)
                LibC.free<Int64>(out.dims)
                LibC.free<C_OutNodeData>(data)
        }
   }
   public func runByInputNodeData(inputData: CPointer<InputNodeData>,out_put_name:String):OutData {
        var outData:OutData
        unsafe {
            var  OutName = LibC.mallocCString(out_put_name)
            var c_out:CPointer<C_OutNodeData> = c_runByInputNodeData(inputData,3,OutName)
            //对输出结果进行处理
            outData = processingData(inputData,c_out)
            //释放输入
            freeInput(inputData,3)
            //释放输出
            freeOntput(c_out)
        }
        return outData
    }
   public func  processingData(inputData: CPointer<InputNodeData>,c_out:CPointer<C_OutNodeData>):OutData{
        unsafe {
            var out:C_OutNodeData =  c_out.read()
            //默认 第三个元素是mask
            var input:InputNodeData = inputData.read(2)
            var outPutdata:ArrayList<ArrayList<ArrayList<Float32>>> = ArrayList<ArrayList<ArrayList<Float32>>>()
            //添加mask维度并 对应 py  expand(token_embeddings.size()).float()
            var input_mask_expanded:ArrayList<ArrayList<ArrayList<Float32>>> = ArrayList<ArrayList<ArrayList<Float32>>>()
            var product_data :ArrayList<ArrayList<ArrayList<Float32>>> = ArrayList<ArrayList<ArrayList<Float32>>>()
            var dataIndex = 0
            var maskIndex = 0
            for( _ in 0..out.dims.read(0)){
                var l1_data:ArrayList<ArrayList<Float32>> = ArrayList<ArrayList<Float32>>()
                var l1_mask_data:ArrayList<ArrayList<Float32>> = ArrayList<ArrayList<Float32>>()
                var l1_product_data:ArrayList<ArrayList<Float32>> = ArrayList<ArrayList<Float32>>()
                for(_ in 0..out.dims.read(1)){
                    var l2_data:ArrayList<Float32> = ArrayList<Float32>()
                    var l2_mask_data:ArrayList<Float32> = ArrayList<Float32>()
                    var l2_product_data: ArrayList<Float32> = ArrayList<Float32>()
                    var makData:Float32 =Float32(input.data.read(maskIndex))
                    for( _ in 0..out.dims.read(2)){
                            var  d:Float32 = out.data.read(dataIndex)
                            var  sumd:Float32 = d *  makData
                            // println("${level1} ----${level2}----${level3} --- v-${dataIndex} :${d} ")
                            l2_data.append(d)
                            //拓展出的第三维度中mask和之前的一样
                            l2_mask_data.append(makData)
                            l2_product_data.append( sumd )
                            dataIndex++
                        }
                        l1_data.append(l2_data);
                        l1_mask_data.append(l2_mask_data)
                        l1_product_data.append(l2_product_data)
                        maskIndex++
                }
                outPutdata.append(l1_data)
                input_mask_expanded.append(l1_mask_data)
                product_data.append(l1_product_data)
            }
            var dims_len:Int64 = out.dims_len
            var dims:ArrayList<Int64> = ArrayList<Int64>()
            for( dimsIndex in  0.. dims_len){
                var  dimSize:Int64 = out.dims.read(dimsIndex)
                dims.append(dimSize)
            }
          OutData(outPutdata,input_mask_expanded,product_data,dims,dims_len)
        }
    }
    public func destroy( ){
        unsafe {
            c_destroy()
        }
    }
}