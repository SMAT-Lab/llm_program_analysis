func main(){
    // 遍历中的数字是不能被修改的
    for(i in 0..10){
        // 打印出数字0，1，2，3，4，5，6，7，8，9
        println(i)
        println("${i}")
    }
    // 遍历中的数字条件选择
    for( i in 0..16){
        // 遍历的数字如果大于10打印i+2，否则打印i
        if(i >10){
            println(i+2)
        }else{
            println(i)
        }
    }
    for( i in 0..16){
        // 遍历出来的数字能被2整除
        if(i %2 == 0){
            println(i)
        }
    }
}